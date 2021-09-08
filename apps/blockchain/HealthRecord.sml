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
    (* encodeByteByteString: BString.bstring -> BString.bstring -> string -> string
     * `encodeByteByteString bs1 bs2 str`
     * Encodes two arbitrary length byte strings and an arbitrary length string
     * into Ethereum ABI format.
     *)
    fun encodeByteByteString bs1 bs2 str =
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

    (* encodeByteByte: BString.bstring -> BString.bstring -> string
     * `encodeByteByte bs1 bs2`
     * Encodes two arbitrary length byte strings into Ethereum ABI format.
     *)
    fun encodeByteByte bs1 bs2 =
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
    fun decodeString enc =
        Result.map BString.toString (Blockchain.decodeBytes enc)
    
    (* decodeStringArray: string -> (string list, string) result
     * `decodeStringArray enc`
     * Decodes an array of arbitrary length strings from Ethereum ABI format.
     *)
    (* Example: ["abc", "defg"]
     * Encoding:
        0000000000000000000000000000000000000000000000000000000000000020 = 32
        0000000000000000000000000000000000000000000000000000000000000002 = 2
        0000000000000000000000000000000000000000000000000000000000000040 = 64
        0000000000000000000000000000000000000000000000000000000000000080 = 128
        0000000000000000000000000000000000000000000000000000000000000003 = 3
        6162630000000000000000000000000000000000000000000000000000000000 = 'abc'
        0000000000000000000000000000000000000000000000000000000000000004 = 4
        6465666700000000000000000000000000000000000000000000000000000000 = 'defg'
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
                                (BString.substring bs start 32)
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
                Word8Extra.InvalidHex => Err "HealthRecord.decodeStringArray: invalid hex")
end

(* testing code *)
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
        case HealthRecord.decodeStringArray bs of
          Err err => TextIO.print_list [err, "\n"]
        | Ok strs => TextIO.print_list [listToString id strs, "\n"]
    end

val _ =
    test_decodeStringArray ()
(**)
