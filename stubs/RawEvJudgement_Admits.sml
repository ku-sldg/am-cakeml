
val passed_string = "UEFTU0VE" (*"504153534544" *)(* "PASSED" in hex encoding *)  (* TODO:  move this to base64 *)
val failed_string = "4641494C4544" (* "FAILED" in hex encoding *)  (* TODO:  move this to base64 *)

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