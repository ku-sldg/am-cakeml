(* Depends on: util, copland, am/Measurements, am/ServerAm *)

type FormalManifestPath_Out = string
type TermPlcConfigPath_In = string
type EvPlcConfigPath_In = string


type ManGenArgs = (FormalManifestPath_Out * TermPlcConfigPath_In * EvPlcConfigPath_In * bool)


  (**
    gets the command line arguments used to configure the manifest generator
    : () -> ManGenArgs
  *)
fun get_args () = 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "-om <manifest_outfiles_prefix> -t <term_plc_file> -e <evidence_plc_file> [ -p ] (provisioning) ")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val formManOutInd =    ListExtra.find_index argList "-om"
              val termPlcInInd =     ListExtra.find_index argList "-t"
              val evPlcInInd = ListExtra.find_index argList "-e"
              val provisionInd =     ListExtra.find_index argList "-p"

              val omb = (formManOutInd <> ~1)
              val tb = (termPlcInInd <> ~1)
              val eb = (evPlcInInd <> ~1)
              val pb = (provisionInd <> ~1)
               in

            if ((not omb) andalso (not pb)) 
            then raise (Exception "Manifest Generator Arg Error: One of '-om' or '-p' args required\n")
            else (* Now one of -om or -p is specified *)
              if ((not tb) andalso (not eb))
              then raise (Exception "Manifest Generator Arg Error: One of '-t' or '-e' args required\n")
              else 
                let val formManOutFile = List.nth argList (formManOutInd + 1)
                    val termPlcInFile  = List.nth argList (termPlcInInd + 1) 
                    val evPlcInFile    = List.nth argList (evPlcInInd + 1) in
                      ((formManOutFile, termPlcInFile, evPlcInFile, pb))
                 end
           end
     end

fun main () =
    let val (outFilePathPrefix, cvmPlcTermsFilepath, appEvidencePlcFilePath, provisionBool) = get_args ()

        val _ = print "\n\n"
        val phrases =  (* TODO:  add "provisioning" capability (to exe for Manifest Generator? Copland Parser?), 
                                 to output Json files with ((coq_Term, coq_Plc) prod) lists that become inputs 
                                 to the Generator exe *)

              let 

                (* START:  UNCOMMENT FOR PROVISIONING SERVER TERMPLC LIST JSON FILE *)
                (*
                  val _ = ManifestJsonConfig.write_termPlcList_file_json cvmPlcTermsFilepath ManGenConfig.demo_phrases (* kim_enc_phrases *) (* cert_phrases *) (* kim_phrases *)
                *)
                (* END:  UNCOMMENT FOR PROVISIONING SERVER TERMPLC LIST JSON FILE  *)
              
                  val ts = ManifestJsonConfig.read_termPlcList_file_json cvmPlcTermsFilepath in 
                    ts
              end

        val ets = (* TODO:  add "provisioning" capability (to exe for Manifest Generator? Copland Parser?), 
                                 to output Json files with ((coq_Evidence, coq_Plc) prod) lists that become inputs 
                                 to the Generator exe *)

              (* TODO:  add additinoal CLI param to generator executable for specifying path 
                        to EvidencePlc list input (avoid hardcoding _Evidence.json path...) *)
              (* let val appEvidencePlcFilepath = cvmPlcTermsFilepath ^ "_Evidence.json" *)
                  

              (* START:  UNCOMMENT FOR PROVISIONING APPRAISAL EVIDENCEPLC LIST JSON FILE  *)
                (*
                  let val temp_ets = ManGenConfig.ets_example_phrase (* ets_kim_enc *) (* ets_cert *) (* ets_example_phrase *)(* ets_kim *) (* ets_cert *)
                      val _ = ManifestJsonConfig.write_EvidencePlcList_file_json appEvidencePlcFilePath temp_ets
                *)
              (* END:    UNCOMMENT FOR PROVISIONING APPRAISAL EVIDENCEPLC LIST JSON FILE  *)
                  
                  
                       let val ls = ManifestJsonConfig.read_EvidencePlcList_file_json appEvidencePlcFilePath in
                            ls   
                        end

        val _ = ManifestJsonConfig.write_form_man_list_json_and_print_json_app 
                  outFilePathPrefix ets phrases
        val _ = print "\n\n" in
      ()
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"

val _ = main ()
