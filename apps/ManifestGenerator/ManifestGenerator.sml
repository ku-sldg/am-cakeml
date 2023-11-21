(* Depends on: util, copland, am/Measurements, am/ServerAm *)

type FormalManifestPath_Out = string
type TermPlcConfigPath_In = string


type ManGenArgs = (FormalManifestPath_Out * TermPlcConfigPath_In)


  (**
    gets the command line arguments used to configure the manifest generator
    : () -> ManGenArgs
  *)
fun get_args () = 
    let val name = CommandLine.name()
        val usage = ("Usage: " ^ name ^ "-om <formal_manifest_outfile> -t <term_plc_file>")
    in
      case (CommandLine.arguments()) of
        argList =>
          let val formManOutInd = ListExtra.find_index argList "-om"
              val termPlcInInd = ListExtra.find_index argList "-t" in
            if (formManOutInd = ~1)
            then raise (Exception "Manifest Generator Arg Error: required field '-om' for Formal Manifest Output FileName missing\n")
            else
              if (termPlcInInd = ~1)
              then raise (Exception "Manifest Generator Arg Error: required field '-t' for Input Term Plc List FileName missing\n")
              else
                let val formManOutFile = List.nth argList (formManOutInd + 1)
                    val termPlcInFile  = List.nth argList (termPlcInInd + 1) in
                      ((formManOutFile, termPlcInFile))
                 end
           end
     end

fun main () =
    let val (outFilePathPrefix, cvmPlcTermsFilepath) = get_args ()

        val _ = print "\n\n"
        val phrases =  (* TODO:  add "provisioning" capability (to exe for Manifest Generator? Copland Parser?), 
                                 to output Json files with ((coq_Term, coq_Plc) prod) lists that become inputs 
                                 to the Generator exe *)

              let 

                (* START:  UNCOMMENT FOR PROVISIONING SERVER TERMPLC LIST JSON FILE *)
                (*
                  val _ = ManifestJsonConfig.write_termPlcList_file_json cvmPlcTermsFilepath kim_enc_phrases (* cert_phrases *) (* kim_phrases *)
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
              let val appEvidencePlcFilepath = cvmPlcTermsFilepath ^ "_Evidence.json"
                  

              (* START:  UNCOMMENT FOR PROVISIONING APPRAISAL EVIDENCEPLC LIST JSON FILE  *)
                (*
                  val temp_ets = ets_kim_enc (* ets_cert *) (* ets_example_phrase *)(* ets_kim *) (* ets_cert *)
                  val _ = ManifestJsonConfig.write_EvidencePlcList_file_json appEvidencePlcFilepath temp_ets
                *)
              (* END:    UNCOMMENT FOR PROVISIONING APPRAISAL EVIDENCEPLC LIST JSON FILE  *)
                  
                  
                  val ls = ManifestJsonConfig.read_EvidencePlcList_file_json appEvidencePlcFilepath in 
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
