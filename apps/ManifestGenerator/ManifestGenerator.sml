(* Depends on: util, copland, am/Measurements, am/ServerAm *)

type TermPlcConfigPath_In = string
type FormalManifestPath_Out = string


type ManGenArgs = (string * string)

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
    let val (outFilePathPrefix, typeSwitch) = get_args ()
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
        val _ = print "\n\n"
        val phrases = 
          if (typeSwitch = "kim")
          then (kim_phrases)
          else (
            if (typeSwitch = "cert")
            then (cert_phrases)
            else (
              if (typeSwitch = "cache")
              then (cache_phrases)
              else (
                if (typeSwitch = "parmut")
                then (parmut_phrases)
                else (
                  if (typeSwitch = "lbg")
                  then (layered_bg_phrases)
                  else (kim_phrases)))))
        val _ = ManifestJsonConfig.write_form_man_list_json_and_print_json outFilePathPrefix phrases
        val _ = print "\n\n" in
      ()
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | ManifestJsonConfig.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"

val _ = main ()
