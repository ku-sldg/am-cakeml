(* Depends on: util, copland, am/Measurements, am/ServerAm *)

val kim_meas = Coq_asp (ASPC ALL EXTD (Coq_asp_paramsC kim_meas_aspid [] dest_plc
    kim_meas_targid))

fun main () =
    let val authb = True
        val (concrete, aspDisp, plcDisp, pubKeyDisp, uuidDisp) = ManifestUtils.setup_and_get_AM_config formal_manifest client_am_library
        val main_phrase = kim_meas (*demo_phrase3*)
        (* Retrieving implicit self place from manifest here *)
        val my_plc = ManifestUtils.get_myPlc()
        (* NOTE: The dest plc is hardcoded here! *)
        val _ = TextIO.print ("Client Launched!\nLoaded following implicit place from Manifest: '" ^ my_plc ^ "'\n\n")
        val am_comp = (am_sendReq_dispatch authb main_phrase my_plc dest_plc aspDisp plcDisp plcDisp) in
        print ( (evidenceCToString (run_am_app_comp am_comp Coq_mtc_app)
          ) ^ "\n\n")
    end
    handle Exception e => TextIO.print_err e 
          | ManifestUtils.Excn e => TextIO.print_err ("ManifestUtils Error: " ^ e)

val _ = main ()
