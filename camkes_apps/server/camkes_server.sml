(* () -> () *)
fun main () = (
    log Debug "server started";
    emitDataportId 0;
    log Debug "server requested a measurement";
    ()
    )
    handle DataportErr str => log Error str
        | _ => log Error "Fatal: unknown error"
        
(* val () = main () *)
val _ = main ()
