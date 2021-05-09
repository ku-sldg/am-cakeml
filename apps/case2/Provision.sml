(* Depends on copland, sockets, am, protocol *)

exception Undef
(* () -> 'a *)
fun undefined () = (
    TextIO.print_err "Undefined value encountered";
    raise Undef
)

(* ev -> ByteString.bs list *)
fun goldenHashes ev = case ev of
      Mt         => []
    | U _ _ bs e => bs :: (goldenHashes e)
    | G bs e     => goldenHashes e
    | H bs       => [bs]
    | N _ _ e    => goldenHashes e
    | SS e1 e2   => goldenHashes e1 @ goldenHashes e2 
    | PP e1 e2   => goldenHashes e1 @ goldenHashes e2

(* 'a -> 'a list -> 'a list *)
fun intersperse a alist = case alist of
      h1 :: h2 :: t => h1 :: a :: (intersperse a (h2 :: t))
    | _ => alist

(* ('a -> string) -> 'a list -> string *)
fun showList show l = "[" ^ String.concat (intersperse ", " (List.map show l)) ^ "]"

(* string -> string *)
fun quotes str = "\"" ^ str ^ "\""

(* ByteString.bs list -> string *)
val showGoldens = showList (quotes o ByteString.show)

(* ByteString.bs list -> () *)
fun writeGoldens goldens = 
    let val header  = "(* This file was auto-generated. Do not edit *)\n\n"
        val content = "val goldenHashes = " ^ (showGoldens goldens) ^ "\n"
        val file = TextIO.openOut "GoldenHashes.sml"
     in TextIO.output file (header ^ content);
        TextIO.closeOut file
    end

fun main () =
    let val priv = (ByteString.toRawString o ByteString.fromHexString) "2E5773B2A19A2CB05FEE44650D8DC877B3D806F74C199043657C805288CD119B"
        val am = serverAm priv emptyNsMap (* TODO: provisioner am template *)
        val _ = startVdtu ()
        val ev = (evalTerm am Mt protocol) handle _ => (TextIO.print_err "Protocol evaluation failed\n"; Mt)
     in print "Writing to GoldenHashes.sml\n";
        writeGoldens (goldenHashes ev)
    end handle _ => TextIO.print_err "Fatal error\n"
val () = main ()