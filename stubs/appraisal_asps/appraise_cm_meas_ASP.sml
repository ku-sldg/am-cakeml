(* Appraisal Stub code for ASP with asp ID:  cm_aspid *)

(* appraise_cm_asp_stub :: coq_ASP_PARAMS -> coq_Plc -> coq_BS -> coq_RawEv -> coq_BS *)
fun appraise_cm_asp_stub ps p bs ls =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = print ("Appraising ASP with ID:  " ^ aspid ^ "\n") in 
                    (Coq_resultC passed_bs)


                    (*
                   let val targ_file = "../apps/demo/server/kim_targ_golden.txt"
                       val targ_file_contents =
                       String.concat
                           (Option.getOpt
                                (TextIO.b_inputLinesFrom targ_file)
                                [])
		       val _ = () (* (print ("\nRead Bytes from file '" ^ targ_file ^ "' :\n" ^ targ_file_contents)) *)
                       val bs_contents = BString.fromString targ_file_contents 
                       val bool_res = (bs_contents = bs)
                       val _ = print ("\nKIM file bs raw evidence:   " ^ (BString.toString bs))
                   in
                       if bool_res
                       then (print ("KIM Appraisal Check PASSED\n\n");
                             Coq_resultC passed_bs)
                       else (print ("KIM Appraisal Check FAILED\n\n");
                             Coq_resultC failed_bs)
                             *)
                   end
              (* end *)
