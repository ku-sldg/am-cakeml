(* Depends on: util, copland, am/Measurements, am/ServerAm *)

type ConcreteManifestPath = string
type ManBuildArgs = ConcreteManifestPath

fun get_args () =  (* : ManBuildArgs *) 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "(-om <concrete manifest_output_path>)\n" ^ 
        "e.g\t" ^ name ^ "-om concrete_manifest.json")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val concManOutInd = ListExtra.find_index argList "-om"
              val defaultConcreteOut = "concrete_manifest.json"
          in
            if (concManOutInd = ~1)
            then defaultConcreteOut
            else List.nth argList (concManOutInd + 1)
            end
      end

fun main () =
    (* Retrieve the provided "formal_manifest" and "am_library" *)
    let val concManFile : ManBuildArgs = get_args()
        val concrete = ManifestUtils.compile_manifest formal_manifest am_library 
        val concreteJson = ManifestJsonConfig.encode_ConcreteManifest concrete
        (* TODO: Note that the name is hardcoded right now *)
        (* val concManFile = "concrete_manifest.json" *)
        (* Write out the JSON file *)
        val _ = ManifestJsonConfig.writeJsonFile concreteJson concManFile
        val _ = c_system ("chmod 777 " ^ concManFile)
    in
      ()
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | Socket.Err s => TextIO.print_err ("Socket failure on listener instantiation: " ^ s ^ "\n")
          | Crypto.Err s => TextIO.print_err ("Crypto error: " ^ s ^ "\n")
          | Json.Exn s1 s2 => TextIO.print_err ("Json Exception: " ^ s1 ^ "\n" ^ s2 ^ "\n")
          | Result.Exn => TextIO.print_err ("Result Exn:\n")
          | Undef => TextIO.print_err ("Undefined Exception:\n")
          | _ => TextIO.print_err "Unknown Error Encountered!\n"

val _ = main ()
