

val passed_string = "504153534544" (* "PASSED" in hex encoding *)
val failed_string = "4641494C4544" (* "FAILED" in hex encoding *)

(** val ex_targJudgement_fun : coq_RawEv -> string **)
fun ex_targJudgement_fun rev =
    let val _ = print ("\n" ^ "Judging this RawEv string:  " ^ (BString.toString (List.hd rev)) ^ "\n\n") in 
         (BString.toString (List.hd rev))
         (*
        val golden = BString.unshow "7461726746696C65436F6E74656E74730A" in
          (* BString.unshow "676174686572696E6746696C65436F6E74656E74732829" in *)
        if (List.member golden rev) 
        then "I JUDGE YOU GOLDEN !!!!!"
        else "GOLDEN CHECK FAILED :( "
        *)
    end

(** val ex_targJudgement_fun' : coq_RawEv -> string **)

fun ex_targJudgement_fun' rev =
    let val _ = print ("\n" ^ "Judging this RawEv string:  " ^ (BString.toString (List.hd rev)) ^ "\n\n")
            val golden = BString.unshow passed_string in
            if (List.member golden rev) 
            then "I JUDGE YOU GOLDEN !!!!!"
            else "GOLDEN CHECK FAILED :( "
        end


(*

(* [appraise_id, gather_file_contents_id] *)

["61707072616973696E6728676174686572696E6746696C65436F6E74656E7473282929",
 "676174686572696E6746696C65436F6E74656E74732829"]

*)



(*  

(* NOTE:  Below is copied directly from extraction *)

(** val ex_targJudgement_fun : coq_RawEv -> string **)

fun ex_targJudgement_fun _ =
  "SAMPLE JUDGEMENT STRING ONE"

(** val ex_targJudgement_fun' : coq_RawEv -> string **)

fun ex_targJudgement_fun' _ =
  "SAMPLE JUDGEMENT STRING TWO"

*)