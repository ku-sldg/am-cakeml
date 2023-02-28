(* Depends on: util, copland, am/Measurements, am/ServerAm *)

fun main () =
    let val authb = True
        val main_phrase = kim_meas (*demo_phrase3*) in
        if (authb)
        then
            print ( (evidenceCToString (client_demo_am_comp_auth main_phrase )) ^ "\n\n")
        else
            print ( (evidenceCToString (client_demo_am_comp main_phrase )) ^ "\n\n")
    end
        
val _ = main ()      
