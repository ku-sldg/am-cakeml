(* Depends on: CoplandLang.sml, CoqDefaults.sml, ByteString.sml, and Measurements.sml*)

type pubKey = nat
type privKey = nat

type platform = pubKey * privKey
type system = platform list

val public = fst
val private = snd

fun platforms s = List.map public s

val emptyUSM : (id, string list -> ByteString.bs) mymap = map_empty
fun dummyUSM args = Word8Array.array 1 (Word8.fromInt (List.length args + 1))
fun dummyUSM' args = Word8Array.array 1 (Word8.fromInt (List.length args + 1))

val emptyKIM : (id, nat -> string list -> ByteString.bs) mymap = map_empty
fun dummyKIM p args = Word8Array.array 1 (Word8.fromInt (List.length args + 1))
fun dummyKIM' p args = Word8Array.array 1 (Word8.fromInt (List.length args + 1))

val dummyAmUSM =  let val y = map_set emptyUSM (Id (natFromInt 0)) dummyUSM
                  in map_set y (Id (natFromInt 1)) dummyUSM'
                  end

val dummyAmKIM =  let val y = map_set emptyKIM (Id (natFromInt 0)) dummyKIM
                  in map_set y (Id (natFromInt 1)) dummyKIM'
                  end

fun splitEv s e = case s
                   of ALL => e
                    | NONE => Mt

exception USMexpn id 
exception KIMexpn id

fun measureUsm am id args =
    case map_get am id
     of None => raise USMexpn id
      | Some f => f args

fun measureKim am id p args =
    case map_get am id
     of None => raise KIMexpn id
      | Some f => f p args


(* Raises USMexpn and KIMexpn when bad ids are given! *)
fun eval (p : pl) (e : ev) (term : t) =
    case term
     of USM id args => U id args p (measureUsm dummyAmUSM id args) e
      | KIM id p' args => K id args p p' (measureKim dummyAmKIM id p args) e
      | SIG => G p e (signEv e)
      | HSH => H p (genHash e)
      | CPY => e 
      | NONCE => N p 0 (genNonce ()) e (* TODO: replace '0' with a real ID *)
      | AT p' t' => eval p' e t'
      | LN t1 t2 => let val e1 = eval p e t1 in eval p e1 t2 end
      | BRS (s1, s2) t1 t2 => SS (eval p (splitEv s1 e) t1) (eval p (splitEv s2 e) t2)
      | BRP (s1, s2) t1 t2 => PP (eval p (splitEv s1 e) t1) (eval p (splitEv s2 e) t2)
