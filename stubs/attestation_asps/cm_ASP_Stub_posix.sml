(* Stub code for ASP with asp ID:  cm_aspid *)

(* cm_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun cm_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
                let 
                    val _ = print ("Matched aspid:  " ^ aspid ^ "\n\n");
                    val _ = print ("Running ASP with aspid:  " ^ aspid ^ "\n\n");
                    val authEv = [];
                    val authEt = Coq_mt;
                    val authToken = (Coq_evc authEv authEt);
                    (*
                    val result = (am_sendReq [] "dataport:uio0" authToken []);
                    val _ = emitDataport "/dev/uio0";
                    val _ = waitDataport "/dev/uio0";
                    *)
                    val _ = print ("Hi mom")
                in
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
