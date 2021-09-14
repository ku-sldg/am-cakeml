(* Dependencies:
 * Blockchain.sml
 * ../../util/Bytestring.sml, ../../util/Http.sml
 *   ../../util/Extra.sml
 * ../../util/Json.sml
 * ../../system/posix/sockets/SocketFFI.sml
 * ../../system/posix/time/TimeFFI.sml
 * ../../util/Misc.sml
 *)
structure HealthRecord =
struct
    (* HealthRecord appraiserId phrase result signature targetId timestamp
     * - appraiserId: BString.bstring
     *   The id (hash of the public key) for the appraiser
     * - phrase: 
     *   The Copland phrase about which the appraisal was performed
     * - result:
     *   The result of the attestation
     * - signature: BString.bstring option
     *   Signature of the appraiser
     * - targetId: BString.bstring
     *   Id of the target being appraised
     * - timestamp: int
     *   UNIX timestamp of the appraisal
     *)
    datatype healthRecord =
        HealthRecordC BString.bstring term Json.json (BString.bstring option) BString.bstring int
    
    fun healthRecord appraiserId phrase result signatureo targetId timestamp =
        HealthRecordC appraiserId phrase result signatureo targetId timestamp
    (* getX: HealthRecord.healthRecord -> T
     * Gets attribute `X`, of type `T`, from the health record
     *)
    fun getAppraiserId (HealthRecordC appraiserId _ _ _ _ _) = appraiserId
    fun getPhrase (HealthRecordC _ phrase _ _ _ _) = phrase
    fun getResult (HealthRecordC _ _ result _ _ _ ) = result
    fun getSignature (HealthRecordC _ _ _ signature_ _ _) = signature_
    fun getTargetId (HealthRecordC _ _ _ _ targetId _) = targetId
    fun getTimestamp (HealthRecordC _ _ _ _ _ timestamp) = timestamp

    (* isSigned: HealthRecord.healthRecord -> bool
     * Returns `true` if and only if the health record has a non-`None`
    * signature field.
     *)
    fun isSigned hr = Option.isSome (getSignature hr)

    (* toJson: HealthRecord.healthRecord -> Json.json
     * Converts the given health record into its Json format. If the health
     * record is signed, then the Json object will have a "signature" field
     * which is filled. Otherwise, there will be no "signature" field.
     *)
    fun toJson hr =
        let
            val unsignedRecord = [
                ("appraiserId", Json.fromString (BString.show (getAppraiserId hr))),
                ("phrase", termToJson (getPhrase hr)),
                ("result", getResult hr),
                ("targetId", Json.fromString (BString.show (getTargetId hr))),
                ("timestamp", Json.fromInt (getTimestamp hr))
            ]
        in
            Json.fromPairList
                (OptionExtra.option unsignedRecord
                    (fn signature_ =>
                        ("signature",
                        Json.fromString (BString.show signature_))::unsignedRecord)
                    (getSignature hr))
        end
    
    (* fromJson: Json.json -> (HealthRecord.healthRecord, string) result
     * Takes a Json object and pulls out a health record or returns an error
     * message.
     *)
    fun fromJson json =
        case (Option.mapPartial Json.toString (Json.lookup "appraiserId" json)) of
          None => Err "Health record missing appraiser id"
        | Some appraiserId =>
            case (Option.map jsonToTerm (Json.lookup "phrase" json)) of
              None => Err "Health record missing Copland phrase"
            | Some phrase =>
                case (Json.lookup "result" json) of
                  None => Err "Health record missing result"
                | Some result =>
                    case (Option.mapPartial Json.toString (Json.lookup "targetId" json)) of
                      None => Err "Health record missing target id"
                    | Some targetId =>
                        case (Option.mapPartial Json.toInt (Json.lookup "timestamp" json)) of
                          None => Err "Health record missing timestamp"
                        | Some timestamp =>
                            let
                                val signatureStro = Option.mapPartial Json.toString (Json.lookup "signature" json)
                                val signatureo = Option.map BString.unshow signatureStro
                            in
                                Ok (healthRecord (BString.unshow appraiserId) phrase
                                    result signatureo (BString.unshow targetId) timestamp)
                            end
            handle Json.Exn msg1 msg2 => Err (String.concat [msg1, ": ", msg2])
                | Word8Extra.InvalidHex => Err "A health record's byte string has an odd length."
    
    (* signAndToJson: BString.bstring -> HealthRecord.healthRecord -> Json.json
     * `signAndToJson privKey hr`
     * Takes a health record `hr` and fills in the signature field using the
     * private key `privKey`, if needed. Then converts the whole structure to a
     * JSON object.
     *)
    fun signAndToJson privKey hr =
        let
            val hrJson = toJson hr
        in
            if isSigned hr
            then hrJson
            else
                let
                    val signatureBs =
                        Crypto.signMsg
                            privKey
                            (BString.fromString (Json.stringify hrJson))
                    val signatureStr = BString.show signatureBs
                in
                    (Option.valOf
                        (Json.insert
                            hrJson
                            "signature"
                            (Json.fromString signatureStr)))
                end
        end
    
    (* signAndToString: BString.bstring -> HealthRecord.healthRecord -> string
     * `signAndToString privKey hr`
     * Takes a health record `hr` and fills in the signature field using the
     * private key `privKey`, if needed. Then converts the whole structure to a
     * JSON object, and finally, stringifies the JSON object.
     *)
    fun signAndToString privKey hr =
        Json.stringify (signAndToJson privKey hr)

    (* checkSignature: BString.bstring -> HealthRecord.healthRecord -> bool
     * `checkSignature pubKey hr`
     * Checks the signature field of the health record `hr` against the public
     * key `pubKey`. Returns true if and only if the signature check passes.
     *)
    fun checkSignature pubKey hr =
        let
            fun clearSig (HealthRecordC appraiserId phrase result _ targetId timestamp) =
                HealthRecordC appraiserId phrase result None targetId timestamp
            val hrClearedBs =
                BString.fromString (Json.stringify (toJson (clearSig hr)))
            fun checkSig signatureBs =
                Crypto.sigCheck pubKey signatureBs hrClearedBs
        in
            Option.getOpt (Option.map checkSig (getSignature hr)) False
        end
    
    (* checkFreshness: HealthRecord.healthRecord -> int
     * Takes the difference of a current timestamp with the timestamp of the
     * given health record.
     *)
    fun checkFreshness hr = (timestamp ()) - (getTimestamp hr)
    
    (* encodeBytesBytesString: BString.bstring -> BString.bstring -> string -> string
     * `encodeBytesBytesString bs1 bs2 str`
     * Encodes two arbitrary length byte strings and an arbitrary length string
     * into Ethereum ABI format.
     *)
    fun encodeBytesBytesString bs1 bs2 str =
        let
            val bs1Offset = 96 (* 3 * 32 *)
            val bs2Offset = bs1Offset + BString.length bs1
            val strOffset = bs2Offset + BString.length bs2
            val toIntABI = BString.fromIntLength 32 BString.BigEndian
        in
            BString.show (BString.concatList [
                toIntABI bs1Offset,
                toIntABI bs2Offset,
                toIntABI strOffset,
                bs1,
                bs2,
                BString.fromString str
            ])
        end

    (* encodeBytesBytes: BString.bstring -> BString.bstring -> string
     * `encodeBytesBytes bs1 bs2`
     * Encodes two arbitrary length byte strings into Ethereum ABI format.
     *)
    fun encodeBytesBytes bs1 bs2 =
        let
            val bs1Offset = 64 (* 2 * 32 *)
            val bs2Offset = bs1Offset + BString.length bs1
            val toIntABI = BString.fromIntLength 32 BString.BigEndian
        in
            BString.show (BString.concatList [
                toIntABI bs1Offset,
                toIntABI bs2Offset,
                bs1,
                bs2
            ])
        end

    (* decodeString: string -> (string, string) result
     * `decodeString enc`
     * Decodes arbitrary length strings from Ethereum ABI format.
     *)
    fun decodeString stream =
        BinaryParser.map BString.toString Blockchain.decodeBytes stream
    
    fun decodeStringArray stream =
        let
            val stringParser =
                BinaryParser.bind
                    Blockchain.decodeInt
                    (fn strLen =>
                        BinaryParser.map
                            BString.toString
                            (BinaryParser.bind
                                (BinaryParser.any strLen)
                                (fn bs =>
                                    BinaryParser.return
                                        bs
                                        (BinaryParser.leftoverNulls 32))))
            fun mainParser arrLen =
                BinaryParser.resetPos 0 (BinaryParser.bind
                    (BinaryParser.count arrLen Blockchain.decodeInt)
                    (fn strOffsets =>
                        BinaryParser.bind
                            (BinaryParser.seqs
                                (List.map
                                    (fn strOffset =>
                                        BinaryParser.at strOffset stringParser)
                                    strOffsets))
                        (fn strs =>
                            BinaryParser.return strs BinaryParser.empty)))
        in
            BinaryParser.bind
                Blockchain.decodeInt
                (fn n =>
                    if n = 32
                    then BinaryParser.choice [
                            BinaryParser.bind
                                Blockchain.decodeInt
                                (fn arrLen => mainParser arrLen),
                            mainParser 32
                        ]
                    else mainParser n)
                stream
        end
    (* (* decodeStringArray: string -> (string list, string) result
     * `decodeStringArray enc`
     * Decodes an array of arbitrary length strings from Ethereum ABI format.
     *)
    fun decodeStringArray enc = 
        if String.size enc < 66 orelse String.substring enc 0 2 <> "0x"
        then Err "HealthRecord.decodeStringArray: byte string either was not long enough or did not start with \"0x\"."
        else
            (let
                fun decode_aux bs n =
                    let
                        val start = 32 * n
                        val lenOffset =
                            BString.toInt BString.BigEndian
                                (BString.substring bs start 32) - start
                        val length =
                            BString.toInt BString.BigEndian
                                (BString.substring bs lenOffset 32)
                        val strOffset = 32 + lenOffset
                    in
                        BString.toString
                            (BString.substring bs strOffset length)
                    end
                fun decode bs = 
                    let
                        val arrLen =
                            BString.toInt BString.BigEndian
                                (BString.substring bs 0 32)
                        val rest = BString.extract bs 32 None
                    in
                        Ok (List.genlist (decode_aux rest) arrLen)
                    end
                val bs = BString.unshow (String.extract enc 2 None)
                val first =
                    BString.substring bs 0 32
                val rest =
                    BString.extract bs 32 None
            in
                if BString.toInt BString.BigEndian first <> 32
                then decode bs
                else
                    case decode rest of
                      Err _ => decode bs
                    | Ok result => Ok result
            end
            handle
                Word8Extra.InvalidHex => Err "HealthRecord.decodeStringArray: invalid hex") *)
    
    (* addRecord: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> Json.json -> (BString.bstring, string) result
     * `addRecord host port jsonId sender recipient appraiserId targetId record`
     * Queries the Ethereum blockchain at host `host` and at port number `port`,
     * calling the `addRecord` method of the smart contract at `recipient` from
     * `sender` with the parameters `appraiserId`, `targetId`, and `record`. The
     * `jsonId` is an arbitrary integer used to identify the corresponding
     * response to this request. `sender` and `recipient` need to be hexadecimal
     * strings prefixed by "0x" and represent a 20 byte Ethereum address. The
     * transaction hash is returned.
     *)
    fun addRecord host port jsonId recipient sender appraiserId targetId record =
        let
            val funSig = "0xec2eb5a4"
            val argsEnc =
                encodeBytesBytesString appraiserId targetId (Json.stringify record)
            fun formEthFunc data =
                Blockchain.formEthSendTransaction jsonId sender recipient data
            fun respFunc resp =
                Ok (BString.unshow (String.extract resp 2 None))
                handle Word8Extra.InvalidHex =>
                    Err "HealthRecord.addRecord: Error from BString.unshow caught."
        in
            case (Blockchain.sendRequest funSig argsEnc formEthFunc host port) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.addRecord"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.addRecord: failed to parse HTTP response.\n",
                    msg, "\n"])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.addRecord, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.addRecord, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.addRecord: unknown error"
    
    (* getRecentRecord: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> (Json.json, string) result
     * `getRecentRecord host port jsonId sender recipient appraiserId targetId record`
     * Queries the Ethereum blockchain at host `host` and at port number `port`,
     * calling the `getRecentRecord` method of the smart contract at `recipient`
     * from `sender` with the parameters `appraiserId` and `targetId`. The
     * `jsonId` is an arbitrary integer used to identify the corresponding
     * response to this request. `sender` and `recipient` need to be hexadecimal
     * strings prefixed by "0x" and represent a 20 byte Ethereum address. The
     * result of parsing the Json health record is returned.
     *)
    fun getRecentRecord host port jsonId recipient sender appraiserId targetId =
        let
            val funSig = "0x973edffe"
            val argsEnc = encodeBytesBytes appraiserId targetId
            fun formEthFunc data =
                Blockchain.formEthCallLatest jsonId sender recipient data
            val decoder = BinaryParser.parseWithPrefix decodeString "0x"
            fun respFunc resp =
                Result.bind (decoder resp) Json.parse
        in
            case (Blockchain.sendRequest funSig argsEnc formEthFunc host port) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.getRecentRecord"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.getRecentRecord: failed to parse HTTP response.\n",
                    msg, "\n"])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.getRecentRecord, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.getRecentRecord, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.getRecentRecord: unknown error"

    (* getAllRecords: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> (((Json.json, string) result) list, string) result
     * `getAllRecords host port jsonId sender recipient appraiserId targetId record`
     * Queries the Ethereum blockchain at host `host` and at port number `port`,
     * calling the `getAllRecords` method of the smart contract at `recipient`
     * from `sender` with the parameters `appraiserId` and `targetId`. The
     * `jsonId` is an arbitrary integer used to identify the corresponding
     * response to this request. `sender` and `recipient` need to be hexadecimal
     * strings prefixed by "0x" and represent a 20 byte Ethereum address. The
     * result of parsing the Json health record is returned.
     *)
    fun getAllRecords host port jsonId recipient sender appraiserId targetId =
        let
            val funSig = "0x2317c148"
            val argsEnc = encodeBytesBytes appraiserId targetId
            fun formEthFunc data =
                Blockchain.formEthCallLatest jsonId sender recipient data
            fun stringToHR str =
                Result.bind (Json.parse str) fromJson
            val decoder = BinaryParser.parseWithPrefix decodeStringArray "0x"
            fun respFunc resp =
                Result.bind
                    (decoder resp)
                    (fn respStrs => Ok (List.map stringToHR respStrs))
        in
            case (Blockchain.sendRequest funSig argsEnc formEthFunc host port) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.getAllRecords"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.getAllRecords: failed to parse HTTP response.\n",
                    msg, "\n"])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.getAllRecords, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.getAllRecords, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.getAllRecords: unknown error"
end

(* testing code
fun test_decodeStringArray () =
    let
        val bs = String.concat ["0x",
            "0000000000000000000000000000000000000000000000000000000000000020",
            "0000000000000000000000000000000000000000000000000000000000000002",
            "0000000000000000000000000000000000000000000000000000000000000040",
            "0000000000000000000000000000000000000000000000000000000000000080",
            "0000000000000000000000000000000000000000000000000000000000000003",
            "6162630000000000000000000000000000000000000000000000000000000000",
            "0000000000000000000000000000000000000000000000000000000000000004",
            "6465666700000000000000000000000000000000000000000000000000000000"
        ]
        fun listToString_aux toString x accum =
            String.concat [toString x, ", ", accum]
        fun listToString toString xs =
            case xs of
              [] => ""
            | x::xs' => List.foldl (listToString_aux toString) (toString x) xs'
    in
        case BinaryParser.parseWithPrefix HealthRecord.decodeStringArray "0x" bs of
          Err err => TextIO.print_list [err, "\n"]
        | Ok strs => TextIO.print_list ["[", listToString id strs, "]\n"]
    end

val _ =
    test_decodeStringArray ()
*)
