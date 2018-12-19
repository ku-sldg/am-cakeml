(* Eval.v *)
type pubKey = nat
type privKey = nat

type platform = pubKey * privKey
type system = platform list

fun public p = case p of (x,y) => x
fun private p = case p of (x,y) => y

fun platforms s = List.map public s

val emptyUSM : (id, string list -> nat) map = map_empty
fun dummyUSM args = natFromInt (List.length args + 1)
fun dummyUSM' args = natFromInt (List.length args + 2)

val emptyKIM : (id, nat -> string list -> nat) map = map_empty
fun dummyKIM p args = natFromInt (List.length args + 1)
fun dummyKIM' p args = natFromInt (List.length args + 2)

val dummyAmUSM =  let val y = map_set emptyUSM (Id (natFromInt 0)) dummyUSM
                  in map_set y (Id (natFromInt 1)) dummyUSM'
                  end

val dummyAmKIM =  let val y = map_set emptyKIM (Id (natFromInt 0)) dummyKIM
                  in map_set y (Id (natFromInt 1)) dummyKIM'
                  end

fun splitEv s e = case s
                   of ALL => e
                    | NONE => Mt

fun measureUsm am id args =
    case map_get am id
     of None => O
      | Some f => f args


fun measureKim am id p args =
    case map_get am id
     of None => O
      | Some f => f p args

fun signEv (p : pl) (e : ev) = p
fun genHash (p : pl) (e : ev) = p
fun genNonce (p : pl) = p

exception USMexpn
exception KIMexpn

fun eval (p : pl)  (e : ev) (term : t) =
    case term
     of USM id args => (case measureUsm dummyAmUSM id args
                        of O => (print (String.concat ["USM ", idToString id, " fails\n"]); raise USMexpn)
                         | n => U id args p n e)
      | KIM id p' args=> (case measureKim dummyAmKIM id p args
                          of O => (print (String.concat ["KIM ", idToString id, " fails\n"]); raise KIMexpn)
                           | n => K id args p p' n e)
      | SIG => G p e (signEv p e)
      | HSH => H p (genHash p e)
      | NONCE => N p (genNonce p) e
      | AT p' t' => eval p' e t'
      | LN t1 t2 => let val e1 = eval p e t1 in eval p e1 t2 end
      | BRS s1 s2 t1 t2 => SS (eval p (splitEv s1 e) t1) (eval p (splitEv s2 e) t2)
      | BRP s1 s2 t1 t2 => PP (eval p (splitEv s1 e) t1) (eval p (splitEv s2 e) t2)
