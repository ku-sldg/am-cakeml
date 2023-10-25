(* Depends on: util, copland, am/Measurements, am/ServerAm *)


fun main () =
    let val (manifestFileName, privKey, phraseFileName) : (string * coq_PrivateKey * string) = ManifestJsonConfig.retrieve_CLI_args () 

        (*

        (* UNCOMMENT BELOW FOR PROVISIONING CLIENT CVM PHRASE *)
        val main_phrase = cert_style
        val _ = ManifestJsonConfig.write_term_file_json phraseFileName main_phrase

        *)

        val main_phrase = ManifestJsonConfig.read_term_file_json phraseFileName


        val formal_manifest = ManifestJsonConfig.read_FormalManifest_file_json manifestFileName
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
          | _ => TextIO.print_err "Unknown Error Encountered!\n"


val _ = main ()
