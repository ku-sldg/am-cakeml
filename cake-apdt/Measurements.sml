(* Depends on: CoplandLang.sml, ByteString.sml, and Crypto.sml*)

fun encodeEv (e : ev) =
    case e
     of Mt => ByteString.empty
      | U _ _ _ bs _ => bs
      | K _ _ _ _ bs _ => bs
      | G _ _ bs => bs
      | H _ bs => bs
      | N _ bs _ => bs
      | SS e1 e2 => ByteString.append (encodeEv e1) (encodeEv e2)
      | PP e1 e2 => ByteString.append (encodeEv e1) (encodeEv e2)


fun genHash (e : ev) = hash (encodeEv e)

fun genFileHash filename =
    let
        val fd = TextIO.openIn filename
        val text = TextIO.inputAll fd
        val _ = TextIO.close fd
    in
        hashStr text
    end

(* These are just placeholders at the moment. *)
fun signEv (e : ev) = ByteString.empty
fun genNonce () = ByteString.empty
