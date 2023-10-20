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
        val auth_phrase = ssl_sig_parameterized default_place
        fun auth_phrase_list p = [(Coq_pair auth_phrase p)]
        val kim_phrase = Coq_att coq_P1 (kim_meas dest_plc kim_meas_targid)
        val kim_phrases =   [(Coq_pair kim_phrase coq_P0)] @ (auth_phrase_list coq_P0)
        val cert_phrases =  [(Coq_pair cert_style coq_P0)] @ (auth_phrase_list coq_P0)
        val cache_phrases = [(Coq_pair cert_cache_p0 coq_P0), (Coq_pair cert_cache_p1 coq_P1)] @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1)
        val parmut_phrases' = [(Coq_pair par_mut_p0 coq_P3), (Coq_pair par_mut_p0 coq_P0), (Coq_pair par_mut_p1 coq_P1), (Coq_pair par_mut_p1 coq_P4)] 
        val parmut_phrases_auth = (auth_phrase_list coq_P3) @ (auth_phrase_list coq_P0) @ (auth_phrase_list coq_P1) @ (auth_phrase_list coq_P4)
        val parmut_phrases = parmut_phrases' @ parmut_phrases_auth
        val layered_bg_phrases = [(Coq_pair layered_bg_strong coq_P0)] @ (auth_phrase_list coq_P0)
        val cm_phrase = Coq_lseq (cm_meas coq_P0 cm_targid) (Coq_asp SIG)
          (* Coq_lseq (cm_meas coq_P0 cm_targid) (ssl_sig_parameterized coq_P0) *)
        val cm_phrases = [(Coq_pair cm_phrase coq_P0)] (* @ (auth_phrase_list coq_P0) *)
        val _ = print "\n\n"
        val phrases =  (* TODO:  add "provisioning" capability (to exe for Manifest Generator? Copland Parser?), 
                                 to output Json files with ((coq_Term, coq_Plc) prod) lists that become inputs 
                                 to the Generator exe *)
              let (* val _ = ManifestJsonConfig.write_termPlcList_file_json cvmPlcTermsFilepath layered_bg_phrases *)
                  val ts = ManifestJsonConfig.read_termPlcList_file_json cvmPlcTermsFilepath in 
                    ts 
              end


(*

(** val eval : coq_Term -> coq_Plc -> coq_Evidence -> coq_Evidence **)

datatype coq_Evidence =
  Coq_mt 
| Coq_nn coq_N_ID
| Coq_uu coq_Plc coq_FWD coq_ASP_PARAMS coq_Evidence
| Coq_ss coq_Evidence coq_Evidence

*)
        val my_plc = coq_P0 
        val appraiser_evidence_kim = eval kim_phrase coq_P0 (Coq_nn O)
        val appraiser_evidence_cm = eval cm_phrase coq_P0 (Coq_nn O)
        val appraiser_evidence_cert = eval cert_style coq_P0 (Coq_nn O)
        val appraiser_evidence_cache_p0 = eval cert_cache_p0 coq_P0 (Coq_nn O)
        val appraiser_evidence_cache_p1 = eval cert_cache_p1 coq_P1 (Coq_nn O)
        val appraiser_evidence_parmut_p0 = eval par_mut_p0 coq_P0 (Coq_nn O)
        val appraiser_evidence_parmut_p1 = eval par_mut_p1 coq_P1 (Coq_nn O)
        val appraiser_evidence_layeredbg = eval layered_bg_strong coq_P0 (Coq_nn O)

        val ets_kim = [(Coq_pair appraiser_evidence_kim coq_P0)]
        val ets_cm = [(Coq_pair appraiser_evidence_cm coq_P0)]
        val ets_cert = [(Coq_pair appraiser_evidence_cert coq_P0)]
        val ets_cache = [(Coq_pair appraiser_evidence_cache_p0 coq_P0),
                         (Coq_pair appraiser_evidence_cache_p1 coq_P1)]
        val ets_parmut = [(Coq_pair appraiser_evidence_parmut_p0 coq_P0),
                          (Coq_pair appraiser_evidence_parmut_p1 coq_P1)]
        val ets_layeredbg = [(Coq_pair appraiser_evidence_layeredbg coq_P0)]

        val ets = ets_layeredbg
                  (* ets_kim *)
                  (* ets_cm *)
                  (* ets_cert *)
                  (* ets_cache *)
                  (* ets_parmut *)
                  (* ets_layeredbg *)

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
