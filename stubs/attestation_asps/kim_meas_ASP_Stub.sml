(* Stub code for ASP with asp ID:  kim_meas_aspid *)

(* kim_meas_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun kim_meas_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               let val _ = () in
                   print ("Matched aspid:  " ^ aspid ^ "\n");
                   let val targ_file = List.hd args (* "/Users/adampetz/Documents/Spring_2023/am-cakeml/apps/demo/server/kim_targ.txt" *)   (* "kim_targ.txt" *)
                       val _ = (print ("\nREADING Bytes from file '" ^ targ_file ^ "'\n\n"))
                       val targ_file_contents =
                       String.concat
                           (Option.getOpt
                                (TextIO.b_inputLinesFrom targ_file)
                                [])
                       val _ = (print ("\nREAD Bytes from file '" ^ targ_file ^ "' :\n" ^ targ_file_contents ^ "\n\n")) in
                       BString.fromString targ_file_contents
                   end
               end
