(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* fun main () = (run_client_demo_am_comp kim_meas ) *)
        
fun main () = 
    let 
        val _ = print("client start\n")
        val _ = writeDataport "/dev/uio0" (BString.fromString "test")
        val read = BString.toCString(readDataport "/dev/uio0" 32)
    in
        print("client done: " ^ read ^ "\n")
    end

val _ = main ()      
