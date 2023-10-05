(* Stub code for ASP with asp ID:  cm_aspid *)

(* cm_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun cm_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n\n");
                   print ("Running ASP with aspid:  " ^ aspid ^ "\n\n");
                    (Coq_resultC passed_bs)


                   (*
                   let val targ_file = List.hd args
                       val _ = (print ("\nREADING Bytes from file '" ^ targ_file ^ "'\n\n"))
                       val targ_file_contents =
                       String.concat
                           (Option.getOpt
                                (TextIO.b_inputLinesFrom targ_file)
                                [])
                       val _ = (print ("\nREAD Bytes from file '" ^ targ_file ^ "' :\n" ^ targ_file_contents ^ "\n\n")) in
                       Coq_resultC (BString.fromString targ_file_contents)
                   end 
                   *)
               end
