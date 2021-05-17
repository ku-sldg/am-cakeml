(* Depends on copland, sockets, am, protocol *)

(* ev -> ByteString.bs list *)
(* fun goldenHashes ev = case ev of
      Mt         => []
    | U _ _ bs e => bs :: (goldenHashes e)
    | G bs e     => goldenHashes e
    | H bs       => [bs]
    | N _ _ e    => goldenHashes e
    | SS e1 e2   => goldenHashes e1 @ goldenHashes e2 
    | PP e1 e2   => goldenHashes e1 @ goldenHashes e2 *)

(* ('a -> string) -> 'a list -> string *)
fun showList show l = "[" ^ String.concat (intersperse ", " (List.map show l)) ^ "]"

(* string -> string *)
fun quotes str = "\"" ^ str ^ "\""

(* ByteString.bs -> string *)
val showGolden = quotes o ByteString.show
(* ByteString.bs list -> string *)
val showGoldens = showList showGolden

fun valFile name v = String.concat (intersperse "\n\n"
    ["(* This file was auto-generated. Do not edit manually. Use the provisioner to generate new golden hashes. *)",
     "val " ^ name ^ " = " ^ v ^ "\n"])

fun writeDtuGoldens dtuGolden goldenEv = 
    let val goldenHashesFile = TextIO.openOut "GoldenHashes.sml"
        val dtuGoldenFile = TextIO.openOut "DtuGolden.sml"
     in TextIO.output goldenHashesFile (valFile "goldenHashes" (showGoldens [goldenEv]));
        TextIO.closeOut goldenHashesFile;
        TextIO.output dtuGoldenFile (valFile "dtuGolden" (showGolden dtuGolden));
        TextIO.closeOut dtuGoldenFile
    end

fun waitForDtuTerminate () = if checkDtuTerminated () then () else waitForDtuTerminate ()

fun provisionMain () = (
    startDtuUnsafe ();
    print "Writing golden hashes\n";
    uncurry writeDtuGoldens (provisionDtu ());
    waitForDtuTerminate ()
) handle _ => TextIO.print_err "Fatal: unknown error\n"
