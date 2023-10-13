(* () -> () *)
fun main () = (
    log Debug "Server AM Awake. Wait for VM to start before doing anything...";
    waitDataportId 1;
    log Debug "Server AM learned the VM is ready. Requesting a measurement.";
    kernelMeasurement 0;
    log Debug "Server AM received a measurement. Having it appraised.";
    kernelAppraisal 0;
    waitDataportId 1;
    ()
    )
    handle DataportErr str => log Error str
        | RPCCallErr str => log Error str
        | _ => log Error "Fatal: unknown error"
        
(* val () = main () *)
val _ = main ()
