(* Depends on: util, copland/Instr *)

local type bs = BString.bstring in
(*type copEval = ev -> term -> ev
type key = bs
type usm = arg list -> bs *)

datatype app = App
         id               (* nonce id *)
         ((id, bs) map)   (* nonce map *)
end
    
(*
    pl                (* me *)
    (pl -> copEval)   (* remote dispatcher *)
    ((id, usm) map)   (* usm map *)
    key               (* private key *)
    (key -> bs -> bs) (* sign function *)
    (bs -> bs)        (* hash function *)
end
*)

(* app *)
val empty_app = (App (Id O) (Map.empty id_compare))
    
fun nid        (App x _) = x
fun nmap       (App _ x) = x

fun setNid  (App _ nm) i = (App i nm)
fun setNmap (App i _) nm = (App i nm)


exception NONCEexpn string

(* id -> id *)
fun incNid (Id i) = (Id (S i))

(* app -> id -> bstring *)
fun getNonceVal app i =
    case Map.lookup (nmap app) i of
        Some bs => bs
      | None =>
        raise NONCEexpn
              ("getNonceVal failed:  nonce id " ^ (idToString i) ^ " not in nonce map.")


(* app -> (ev x app) *)
fun newNonce (App oldId oldNm) =
    let val nonce = Random.random (Random.seed (Meas.urand 32)) 16
        val newId = incNid oldId
        val newNm = Map.insert oldNm oldId nonce
    in ((N oldId nonce),(App newId newNm))
    end

(* app -> Id -> bstring -> bstring *)
fun checkNonce app i bs =
    let val golden_bs = getNonceVal app i in
        if (golden_bs = bs)
        then (BString.fromInt BString.LittleEndian 1)
        else (BString.fromInt BString.LittleEndian 0)
    end
                                    
            
                               
(*
fun me       (Am x _ _ _ _ _) = x
fun dispatch (Am _ x _ _ _ _) = x
fun usmMap   (Am _ _ x _ _ _) = x
fun privKey  (Am _ _ _ x _ _) = x
fun sign     (Am _ _ _ _ x _) = x
fun hash     (Am _ _ _ _ _ x) = x

fun setMe       (Am _ d u p s h) m = Am m d u p s h
fun setDispatch (Am m _ u p s h) d = Am m d u p s h
fun setUsmMap   (Am m d _ p s h) u = Am m d u p s h
fun setPrivKey  (Am m d u _ s h) p = Am m d u p s h
fun setSign     (Am m d u p _ h) s = Am m d u p s h
fun setHash     (Am m d u p s _) h = Am m d u p s h

fun signEv am priv = sign am priv o encodeEv
fun genHash am = hash am o encodeEv

exception USMexpn string
fun measureUsm map id args = case Map.lookup map id of
      Some f => f args
    | None   => raise USMexpn "USM id not found"
*)
