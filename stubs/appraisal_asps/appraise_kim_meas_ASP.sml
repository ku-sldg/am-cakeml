(* Appraisal Stub code for ASP with asp ID:  kim_meas_aspid *)

(* appraise_kim_meas_asp_stub :: coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS *)
fun appraise_kim_meas_asp_stub ps p bs ls =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               (* let val _ = () in ()
                  print ("Appraising ASP with ID:  " ^ aspid ^ "\n"); *)
                   let val targ_file = "kim_targ_golden.txt"
                       val targ_file_contents =
                       String.concat
                           (Option.getOpt
                                (TextIO.b_inputLinesFrom targ_file)
                                [])
		       val _ = () (* (print ("\nRead Bytes from file '" ^ targ_file ^ "' :\n" ^ targ_file_contents)) *)
                       val bs_contents = BString.fromString targ_file_contents 
                       val bool_res = (bs_contents = bs)
                   in
                       if bool_res
                       then (print ("\nKIM Appraisal Check PASSED\n\n");
                             passed_bs)
                       else (print ("\nKIM Appraisal Check FAILED\n\n");
                             failed_bs)
                   end
              (* end *)