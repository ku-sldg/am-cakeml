(* () -> () *)
fun main () = (
    log Debug "Server AM Awake. Wait for VM to start before doing anything...";
    waitDataportId 1;

    kernelMeasurement 0;

    writeDataportId 0 (BString.fromString "1");
    writeDataportId 1 (BString.fromString "2");
    log Debug "Server AM emitting to Inspector.";
    emitDataportId 0;
    log Debug "Server AM waiting for Inspector signal.";
    waitDataportId 0;
    log Debug "Server AM recv Inspector signal. Emitting to Client.";
    emitDataportId 1;
    log Debug "Server AM waiting for Client signal.";
    waitDataportId 1;
    log Debug "Server AM recv Client signal.";
    log Debug "This number should be 3";
    log Debug (BString.toCString (readDataportId 0 4096));
    log Debug "This number should be 5";
    log Debug (BString.toCString (readDataportId 1 4096));

    log Debug "Server AM Start.";
    emitDataportId 0;
    log Debug "server requested a measurement";
    waitDataportId 0;
    log Debug "server recv measurement";
    log Debug (BString.toCString (readDataportId 0 4096));
    ()
    )
    handle DataportErr str => log Error str
        | _ => log Error "Fatal: unknown error"
        
(* val () = main () *)
val _ = main ()
