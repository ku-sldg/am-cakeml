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
            val bs1Len = BString.length bs1
            val bs2Offset = bs1Offset + 32 + bs1Len
            val bs2Len = BString.length bs2
            val strOffset = bs2Offset + 32 + bs2Len
            val strLen = String.size str
            val toIntABI = BString.fromIntLength 32 BString.BigEndian
        in
            BString.show (BString.concatList [
                toIntABI bs1Offset,
                toIntABI bs2Offset,
                toIntABI strOffset,
                toIntABI bs1Len,
                bs1,
                toIntABI bs2Len,
                bs2,
                toIntABI strLen,
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
            val bs1Len = BString.length bs1
            val bs2Offset = bs1Offset + 32 + bs1Len
            val bs2Len = BString.length bs2
            val toIntABI = BString.fromIntLength 32 BString.BigEndian
        in
            BString.show (BString.concatList [
                toIntABI bs1Offset,
                toIntABI bs2Offset,
                toIntABI bs1Len,
                bs1,
                toIntABI bs2Len,
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
    
    (* addAppraiser: string -> int -> int -> string -> string -> BString.bstring
        -> (BString.bstring, string) result
     * `addAppraiser host port jsonId sender recepient appraiserId`
     * Calls the Ethereum blockchain at host `host` and port number `port`,
     * calling the `addAppraiser` method of the smart contract at `recipient`
     * from `sender` with parameters `appraiserId`. The `jsonId` is an
     * arbitrary integer used to identify the corresponding repsonse to this
     * request. `sender` and `recipient` need to be hexademical strings
     * prefixed by "0x" and represent a 20 byte Ethereum address. The
     * transaction hash is returned.
     *)
     fun addAppraiser host port jsonId recipient sender appraiserId =
        let
            fun formEthFunc data =
                Blockchain.formEthSendTransaction jsonId sender recipient data
            val argsEnc =
                Blockchain.encodeBytes appraiserId
            val message = formEthFunc ("0xbd53605c" ^ argsEnc)
            fun respFunc resp =
                Ok (BString.unshow (String.extract resp 2 None))
                handle Word8Extra.InvalidHex =>
                    Err "HealthRecord.addAppraiser: Error from BString.unshow caught"
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.addAppraiser"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.addAppraiser: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat
                    ["HealthRecord.addAppraiser, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.addAppraiser, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.addAppraiser: unknown error"

    (* removeAppraiser: string -> int -> int -> string -> string -> BString.bstring
        -> (BString.bstring, string) result
     * `removeAppraiser host port jsonId sender recepient appraiserId`
     * Calls the Ethereum blockchain at host `host` and port number `port`,
     * calling the `removeAppraiser` method of the smart contract at `recipient`
     * from `sender` with parameters `appraiserId`. The `jsonId` is an
     * arbitrary integer used to identify the corresponding repsonse to this
     * request. `sender` and `recipient` need to be hexademical strings
     * prefixed by "0x" and represent a 20 byte Ethereum address. The
     * transaction hash is returned.
     *)
     fun removeAppraiser host port jsonId recipient sender appraiserId =
        let
            fun formEthFunc data =
                Blockchain.formEthSendTransaction jsonId sender recipient data
            val argsEnc =
                Blockchain.encodeBytes appraiserId
            val message = formEthFunc ("0x8586e8e9" ^ argsEnc)
            fun respFunc resp =
                Ok (BString.unshow (String.extract resp 2 None))
                handle Word8Extra.InvalidHex =>
                    Err "HealthRecord.removeAppraiser: Error from BString.unshow caught"
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.removeAppraiser"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.removeAppraiser: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat
                    ["HealthRecord.removeAppraiser, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.removeAppraiser, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.removeAppraiser: unknown error"

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
            fun formEthFunc data =
                Blockchain.formEthSendTransaction jsonId sender recipient data
            val argsEnc =
                encodeBytesBytesString appraiserId targetId (Json.stringify record)
            val message = formEthFunc ("0xec2eb5a4" ^ argsEnc)
            fun respFunc resp =
                Ok (BString.unshow (String.extract resp 2 None))
                handle Word8Extra.InvalidHex =>
                    Err "HealthRecord.addRecord: Error from BString.unshow caught."
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.addRecord"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.addRecord: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat
                    ["HealthRecord.addRecord, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.addRecord, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.addRecord: unknown error"
    
    (* getRecentRecord: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> (Json.json, string) result
     * `getRecentRecord host port jsonId sender recipient appraiserId targetId`
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
            fun formEthFunc data =
                Blockchain.formEthCallLatest jsonId sender recipient data
            val argsEnc = encodeBytesBytes appraiserId targetId
            val message = formEthFunc ("0x973edffe" ^ argsEnc)
            val decoder = BinaryParser.parseWithPrefix decodeString "0x"
            fun respFunc resp =
                Result.bind (decoder resp) Json.parse
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.getRecentRecord"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.getRecentRecord: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.getRecentRecord, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.getRecentRecord, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.getRecentRecord: unknown error"

    (* getAllRecords: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> (((Json.json, string) result) list, string) result
     * `getAllRecords host port jsonId sender recipient appraiserId targetId`
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
            fun formEthFunc data =
                Blockchain.formEthCallLatest jsonId sender recipient data
            val argsEnc = encodeBytesBytes appraiserId targetId
            val message = formEthFunc ("0x2317c148" ^ argsEnc)
            fun stringToHR str =
                Result.bind (Json.parse str) fromJson
            val decoder = BinaryParser.parseWithPrefix decodeStringArray "0x"
            fun respFunc resp =
                Result.bind
                    (decoder resp)
                    (fn respStrs => Ok (List.map stringToHR respStrs))
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.getAllRecords"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.getAllRecords: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.getAllRecords, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.getAllRecords, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.getAllRecords: unknown error"

    (* clearRecords: string -> int -> int -> string -> string -> BString.bstring ->
        BString.bstring -> (BString.bstring, string) result
     * `clearRecords host port jsonId sender recipient appraiserId targetId`
     * Queries the Ethereum blockchain at host `host` and at port number `port`,
     * calling the `clearRecord` method of the smart contract at `recipient`
     * from `sender` with the parameters `appraiserId` and `targetId`. The
     * `jsonId` is an arbitrary integer used to identify the corresponding
     * response to this request. `sender` and `recipient` need to be hexadecimal
     * strings prefixed by "0x" and represent a 20 byte Ethereum address.
     *)
    fun clearRecords host port jsonId recipient sender appraiserId targetId =
        let
            fun formEthFunc data =
                Blockchain.formEthSendTransaction jsonId sender recipient data
            val argsEnc = encodeBytesBytes appraiserId targetId
            val message = formEthFunc ("0x36ae4bb1" ^ argsEnc)
            fun stringToHR str =
                Result.bind (Json.parse str) fromJson
            val decoder = BinaryParser.parseWithPrefix decodeStringArray "0x"
            fun respFunc resp =
                Ok (BString.unshow (String.extract resp 2 None))
                handle Word8Extra.InvalidHex =>
                    Err "HealthRecord.addRecord: Error from BString.unshow caught."
        in
            case (Blockchain.sendRequest host port message) of
              Ok resp =>
                Blockchain.processResponse resp jsonId respFunc "HealthRecord.clearRecords"
            | Err msg =>
                Err (String.concat [
                    "HealthRecord.clearRecords: failed to parse HTTP response.\n",
                    msg])
        end
        handle Socket.Err msg =>
                Err (String.concat ["HealthRecord.clearRecords, socket error: ", msg])
            | Socket.InvalidFD =>
                Err "HealthRecord.clearRecords, socket error: invalid file descriptor."
            | _ => Err "HealthRecord.clearRecords: unknown error"
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
