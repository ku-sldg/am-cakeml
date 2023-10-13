(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* fun main () = (run_client_demo_am_comp kim_meas ) *)
        
fun main () = 
    let 
        val _ = print("Client AM Awake. Requesting Measurement.\n")
        val _ = emitDataport "/dev/uio0"
    in
        print("client done!\n")
    end

val _ = main ()      
