(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* fun main () = (run_client_demo_am_comp kim_meas ) *)
        
        (*
fun main () = 
    let 
        val _ = print("Client AM Awake. Requesting Measurement.\n")
        (*
        val _ = writeDataport "/dev/uio0" (BString.fromString payload)
        val _ = emitDataport "/dev/uio0"
        *)
        val t' = cert_style
        val t = t' (* Coq_lseq cert_style (Coq_asp SIG) *)
        val tok : coq_ReqAuthTok = mt_evc
        val ev : coq_RawEv = []
        val req : coq_CvmRequestMessage = REQ t tok ev
        val resp : coq_CvmResponseMessage = []
        val js =  responseToJson resp
                    (* requestToJson req *)
                    (* termToJson t  *)
        val _ = print "running demo client\n"
        val tstr = Json.stringify js
    in
        print ("Json representation of term: \n" ^ tstr ^ "\n\n");
        print("client done!\n")
    end

val _ = main ()      
*)


fun main () =
    let
        val (manifestFileName, privKey, phraseFileName, provisioningBool) : (string * coq_PrivateKey * string * bool) = BashFunctions.retrieve_CLI_args ()
        val _ = 
                (
                if(provisioningBool) 
                then (
                    let val provisioningPhrase = ManGenConfig.cm_layered_phrase in 
                                BashFunctions.write_term_file_json phraseFileName provisioningPhrase
                    end
                )
                else ()
                )

    (* START:  UNCOMMENT FOR PROVISIONING CLIENT CVM PHRASE *)
    (*
        val main_phrase = example_phrase (* cert_style *)
        val _ = ManifestJsonConfig.write_term_file_json phraseFileName main_phrase

    *)
    (* END:  UNCOMMENT FOR PROVISIONING CLIENT CVM PHRASE *)
        val main_phrase = BashFunctions.read_term_file_json phraseFileName

        val formal_manifest = BashFunctions.read_FormalManifest_file_json manifestFileName
        val _ = ManifestUtils.setup_and_get_AM_config formal_manifest am_library privKey
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        val auth_phrase = ssl_sig_parameterized my_plc
        val _ = print ("\n\nClient my_plc: \n" ^ my_plc ^ "\n\n")
        val uuid = ManifestUtils.get_myUUID()
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val _ = TextIO.print ("Loaded following implicit UUID from Client Manifest: '" ^ uuid ^ "'\n\n")

        val nonceB    : bool = True
        val appraiseB : bool = True
        val am_comp = am_client_gen_local main_phrase my_plc None formal_manifest am_library
                        (* am_client_auth main_phrase my_plc my_plc auth_phrase nonceB appraiseB  *)
        val am_res = run_am_app_comp am_comp empty_am_result True
            (* the bool here is to force evaluation of unit-typed error prints from extracted code *)
        (*
        val my_amconfig = ManifestUtils.get_AM_config ()
        val da_manifest =
            case my_amconfig of Coq_mkAmConfig m _ _ _ _ _ => m
        val _ = print ("Manifest from AM Config: \n" ^ (pretty_print_manifest_simple da_manifest) ^ "\n\n")
        (*
        val my_amlib = ManifestUtils.get_local_amLib ()
        *)
        val my_amconfig_app_cb = case my_amconfig of Coq_mkAmConfig _ _ appcb _ _ _ => appcb
        val app_cb_resultT = my_amconfig_app_cb (Coq_asp_paramsC appraise_id [] coq_P2 sys) coq_P2 passed_bs []
                                (* (Coq_asp_paramsC attest1_id [] coq_P1 sys) coq_P1 passed_bs [passed_bs] *)
        val _ = case app_cb_resultT of
                Coq_resultC _ => print "\n\nAPP CB Succeeded\n\n"
                | Coq_errC Unavailable => print "\n\nAPP CB Error (Unavailable)\n\n"
        *)
    in
        print ( ("\n\nClient Result:\n" ^ am_result_ToString (am_res))  ^ "\n\n")
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
          | BashFunctions.Excn e => TextIO.print_err e
          | _ => TextIO.print_err "Unknown Error Encountered!\n"


val _ = main ()




