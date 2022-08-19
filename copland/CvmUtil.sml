(* Depends on: extracted/ *)

(* cvm_st_ToString : cvm_st -> string *)
fun cvm_st_ToString st =
    case st of
        Coq_mk_st evc ls p i =>
        concatWith " " ["(Cvm_St", evCToString evc, "...", ")"]
