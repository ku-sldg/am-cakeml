(* () -> () *)
fun main () = (
    log Debug "server started";
    ()
    )
    handle DataportErr str => log Error str
        | _ => log Error "Fatal: unknown error"
        
(* val () = main () *)
val _ = main ()
