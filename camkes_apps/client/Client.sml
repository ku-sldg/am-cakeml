(* Depends on: util, copland, am/Measurements, am/ServerAm *)

(* fun main () = (run_client_demo_am_comp kim_meas ) *)
        
fun main () = 
    let 
        val _ = print("Client AM Awake. Alerting Server. Waiting on Inspector.\n")
        val _ = emitDataport "/dev/uio0"
        val _ = print("Client AM recv Inspector signal. Signalling Inspector. Waiting on Server.\n")

        val read1 = BString.toCString(readDataport "/dev/uio0" 4096)
        val read2 = BString.toCString(readDataport "/dev/uio1" 4096)
        val _ = print("This should be 2: " ^ read1)
        val _ = print("This should be 4: " ^ read2)
        val _ = writeDataport "/dev/uio0" (BString.fromString "5")
        val _ = writeDataport "/dev/uio1" (BString.fromString "6")

        val _ = emitDataport "/dev/uio1"
        val _ = print("Client AM recv Server signal. Passing control back to Server.\n")
        val _ = emitDataport "/dev/uio0"

        val _ = print("Client AM Start\n")
        val _ = writeDataport "/dev/uio0" (BString.fromString "test")
        val read = BString.toCString(readDataport "/dev/uio0" 4096)
    in
        print("client done: " ^ read ^ "\n")
    end

val _ = main ()      
