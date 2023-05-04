structure ManCompConfig = struct
  exception Excn string

  type FormalManifestPath   = string
  type AmLibraryPath        = string
  type AmExecutablePath     = string
  type ConcreteManifestPath = string
  type ManCompArgs          = (FormalManifestPath * AmLibraryPath * AmExecutablePath * ConcreteManifestPath)

  (**
    gets the command line arguments used to configure the manifest compiler
    : () -> ManCompArgs
  *)
  fun get_args () = 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "-m <abstract_manifest_file> -l <am_library_file> (-o <executable_output_path>) (-om <concrete manifest_output_path)\n" ^ 
        "e.g\t" ^ name ^ "-m fman.json -l AMLib.sml")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val formManInd = ListExtra.find_index argList "-m"
              val amLibInd = ListExtra.find_index argList "-l"
              val execOutInd = ListExtra.find_index argList "-o"
              val concManOutInd = ListExtra.find_index argList "om"
              val defaultExecOut = "am_executable.exe"
              val defaultConcreteOut = "concrete_manifest.json"
          in
            if (formManInd = ~1)
            then raise (Excn "Manifest Compiler Arg Error: required field '-m' for Abstract Manifest missing\n")
            else (
              if (amLibInd = ~1)
              then raise (Excn "Maniest Compiler Arg Error: required field '-l' for AM Library missing\n")
              else (
                (* TODO: Add the output path handling! *)
                let val formManFile = List.nth argList (formManInd + 1)
                    val amLibFile = List.nth argList (amLibInd + 1)
                in
                  ((formManFile, amLibFile, defaultExecOut, defaultConcreteOut) : ManCompArgs)
                end
              )
            )
          end
    end

end

fun makeCmakeFile fm_path am_library_path = "cmake_minimum_required(VERSION 3.10.2)\nget_files(client_src ${server_am_src_tpm} " ^ fm_path ^ " " ^ am_library_path ^ " ./Client.sml)\nbuild_posix_am_tpm(\"COMPILED_AM\" ${client_src})\n"

(* () -> () *)
fun main () =
  let val (fmPath, libPath, _, _) = ManCompConfig.get_args()
      val _ = (print ("Formal Manifest: " ^ fmPath ^ "\nAM Library: " ^ libPath ^ "\n\n"))
      val cmakefile = makeCmakeFile fmPath libPath
      val _ = c_system ("echo '" ^ cmakefile ^ "' > CMakeLists.txt")
      (* val x = c_system "ajsks" *)
      (* val _ = print (Int.toString x)
      val y = c_system "echo 'test'" *)
      (* val _ = print (Int.toString y) *)
  in
    ()
  end
  handle  Exception e => TextIO.print_err e
          | ManCompConfig.Excn e => TextIO.print_err e

val () = main ()
