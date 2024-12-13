
val passed_string = "UEFTU0VE" (* "PASSED" in hex encoding *)  (* TODO:  move this to base64 *)
val failed_string = "RkFJTEVE" (* "FAILED" in hex encoding *)  (* TODO:  move this to base64 *)

(** val ex_targJudgement_fun : coq_RawEv -> string **)
fun ex_targJudgement_fun rev =
    let val v = (BString.toString (List.hd rev)) in
        (* val _ = print ("\n" ^ "Judging this RawEv string:  " ^ v ^ "\n") in *)
          v
    end

(** val ex_targJudgement_fun' : coq_RawEv -> string **)
fun ex_targJudgement_fun' rev =
    let val v = (BString.toString (List.hd rev))
        (* val _ = print ("\n" ^ "Judging this RawEv string:  " ^ v ^ "\n\n") *)
        val golden = BString.unshow passed_string in
            if (List.member golden rev) 
            then "I JUDGE YOU GOLDEN !!!!!"
            else "GOLDEN CHECK FAILED :( "
        end