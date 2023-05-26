structure ManCompConfig = struct
  exception Excn string

  type FormalManifestPath   = string
  type AmLibraryPath        = string
  type AmExecutableName     = string
  type ConcreteManifestPath = string
  type CompileTarget        = string
  type ManCompArgs          = (FormalManifestPath * AmLibraryPath * AmExecutableName * ConcreteManifestPath * CompileTarget)

  (**
    gets the command line arguments used to configure the manifest compiler
    : () -> ManCompArgs
  *)
  fun get_args () = 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "-m <abstract_manifest_file> -l <am_library_file> [-s | -c] (-o <executable_output_path>) (-om <concrete manifest_output_path)\n" ^ 
        "e.g\t" ^ name ^ "-m -c fman.json -l AMLib.sml")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val formManInd = ListExtra.find_index argList "-m"
              val amLibInd = ListExtra.find_index argList "-l"
              val execOutInd = ListExtra.find_index argList "-o"
              val concManOutInd = ListExtra.find_index argList "-om"
              val clientCompileInd = ListExtra.find_index argList "-c"
              val serverCompileInd = ListExtra.find_index argList "-s"
              val defaultExecOut = "am_executable.exe"
              val defaultConcreteOut = "concrete_manifest.json"
          in
            if (formManInd = ~1)
            then raise (Excn "Manifest Compiler Arg Error: required field '-m' for Abstract Manifest missing\n")
            else (
              if (amLibInd = ~1)
              then raise (Excn "Manifest Compiler Arg Error: required field '-l' for AM Library missing\n")
              else (
                if ((clientCompileInd = ~1 andalso serverCompileInd = ~1) orelse (clientCompileInd <> ~1 andalso serverCompileInd <> ~1))
                then raise (Excn "Manifest Compiler Arg Error: must choose either '-c' to compile a client or '-s' to compile a server, but not both\n")
                else (
                  (* TODO: Add the output path handling! *)
                  let val formManFile = List.nth argList (formManInd + 1)
                      val amLibFile = List.nth argList (amLibInd + 1)
                      (* If we have the client compile flag, it will <> -1 *)
                      val execOutFile : AmExecutableName = 
                        if (execOutInd = ~1)
                        then defaultExecOut
                        else List.nth argList (execOutInd + 1)
                      val concOutFile : ConcreteManifestPath = 
                        if (concManOutInd = ~1)
                        then defaultConcreteOut
                        else List.nth argList (concManOutInd + 1)
                      val buildClient = clientCompileInd <> ~1
                  in
                    ((formManFile, amLibFile, execOutFile, concOutFile, (if buildClient then "CLIENT" else "SERVER")) : ManCompArgs)
                  end
                )
              )
            )
          end
    end

end

fun makeAM_CmakeFile fm_path am_library_path targetFile = "cmake_minimum_required(VERSION 3.10.2)\nget_files(man_comp_src ${server_am_src_tpm} " ^ fm_path ^ " " ^ am_library_path ^ " " ^ targetFile ^ " )\nbuild_posix_am_tpm(\"COMPILED_AM\" ${man_comp_src})\n"

fun makeConcMan_CmakeFile fm_path am_library_path = "cmake_minimum_required(VERSION 3.10.2)\nget_files(man_builder_src ${server_am_src_tpm} " ^ fm_path ^ " " ^ am_library_path ^ " ../apps/ManifestCompiler/ManifestBuilder.sml)\nbuild_posix_am_tpm(\"CONC_MAN_BUILDER\" ${man_builder_src})\n"


(* () -> () *)
fun main () =
  let val (fmPath, libPath, execOutFileName, concOutFileName, targetType) = ManCompConfig.get_args()
      val targetFile = if (targetType = "CLIENT") then "../apps/ManifestCompiler/Client.sml" else "../apps/ManifestCompiler/Server.sml"
      val _ = (print ("Formal Manifest: " ^ fmPath ^ "\nAM Library: " ^ libPath ^ "\n\n"))
      val am_cmakefile = makeAM_CmakeFile fmPath libPath targetFile
      val concman_cmakefile = makeConcMan_CmakeFile fmPath libPath
      val _ = c_system ("echo '" ^ concman_cmakefile ^ "' > CMakeLists.txt")
      val _ = c_system ("cmake ..")
      val _ = c_system ("make CONC_MAN_BUILDER")
      val _ = c_system ("./build/CONC_MAN_BUILDER -om " ^ concOutFileName)
      val _ = c_system ("echo '" ^ am_cmakefile ^ "' > CMakeLists.txt")
      val _ = c_system ("cmake ..")
      val _ = c_system ("make COMPILED_AM")
      val am_cakeml_path_prefix = "/Users/adampetz/Documents/Spring_2023/am-cakeml"
      val am_exe_path = am_cakeml_path_prefix ^ "/build/build"
      (* TODO: get rid of this hard-coded path...ENV var? *)
      val _ = c_system ("mv " ^ am_exe_path ^ "/COMPILED_AM" ^ " " ^ am_exe_path ^ "/" ^ execOutFileName)
  in
    ()
  end
  handle  Exception e => TextIO.print_err e
          | ManCompConfig.Excn e => TextIO.print_err e

val () = main ()
