(* fun ffi_system           x y = #(system) x y *)

(* () -> () *)
fun main () =
  let val _ = (#(system) (BString.unshow "10") (BString.unshow "ls"))
  in 
    ()
  end

val () = main ()
