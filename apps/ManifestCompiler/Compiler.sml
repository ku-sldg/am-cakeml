(* Depends:  TODO *)
structure ManCompConfig = struct
  exception Excn string

  type FormalManifestPath   = string
  type AmLibraryPath        = string
  type AmExecutableName     = string
  type CompileTarget        = string
  (* type CvmTermFilePath      = string *)
  type ManCompArgs          = (FormalManifestPath * AmLibraryPath * AmExecutableName * CompileTarget (* * CvmTermFilePath *) (* * CvmTermFilePath  *))

  (**
    gets the command line arguments used to configure the manifest compiler
    : () -> ManCompArgs
  *)
  fun get_args () = 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "-m <manifest_file>.json -l <am_library_file>.sml [-s | -c] (-o <executable_output_path>)\n" ^ 
        "e.g\t" ^ name ^ "-m fman.json -l AMLib.sml -c client_term.sml  -o am_out")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val formManInd = ListExtra.find_index argList "-m"
              val amLibInd = ListExtra.find_index argList "-l"
              val execOutInd = ListExtra.find_index argList "-o"
              val clientCompileInd = ListExtra.find_index argList "-c"
              val serverCompileInd = ListExtra.find_index argList "-s"
              val defaultExecOut = "am_executable.exe"
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
                      val buildClient = clientCompileInd <> ~1
                      (*
                      val buildServer = serverCompileInd <> ~1
                      val clientCvmTermFile : CvmTermFilePath = 
                        if (buildClient) 
                        then (List.nth argList (clientCompileInd + 1))
                        else "" *)
                  in
                    (( formManFile, 
                       amLibFile, 
                       execOutFile, 
                       (if buildClient then "CLIENT" else "SERVER") (*, 
                       clientCvmTermFile *) ) : ManCompArgs)
                  end
                )
              )
            )
          end
    end

end

fun makeAM_CmakeFile fm_path am_library_path (* cvmTermFile *) targetFile = "cmake_minimum_required(VERSION 3.10.2)\nget_files(man_comp_src ${server_am_src} " ^ am_library_path ^ " " (* ^ cvmTermFile ^ " " *) ^ targetFile ^ " )\nbuild_posix_am(\"COMPILED_AM\" ${man_comp_src})\n"

(* () -> () *)
fun main () =
  let val (fmPath, libPath, execOutFileName, targetType (* , cvmClientTermFile *) ) = ManCompConfig.get_args()
      val targetFile = if (targetType = "CLIENT") then "../apps/ManifestCompiler/Client.sml" else "../apps/ManifestCompiler/Server.sml"
      (* val cvmTermFilePath = if (targetType = "CLIENT") 
                            then cvmClientTermFile
                            else ( "" ) *)
      val _ = (print ("Formal Manifest: " ^ fmPath ^ "\nAM Library: " ^ libPath ^ "\n\n"))
      val am_cmakefile = makeAM_CmakeFile fmPath libPath (* cvmTermFilePath *) targetFile
      val _ = c_system ("echo '" ^ am_cmakefile ^ "' > CMakeLists.txt")
      val _ = c_system ("cmake ..")
      val _ = c_system ("make COMPILED_AM")
      val am_exe_path = "./build"
      val _ = c_system ("mv " ^ am_exe_path ^ "/COMPILED_AM" ^ " " ^ am_exe_path ^ "/" ^ execOutFileName)
  in
    ()
  end
  handle  Exception e => TextIO.print_err e
          | ManCompConfig.Excn e => TextIO.print_err e

val () = main ()
