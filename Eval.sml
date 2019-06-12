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


(* eval probably doesn't need a place argument, when it just represents "me"
  (invariant). Could pass me+map together in a copEnv-like thing. *)
val me = O

(* May raise USMexpn, KIMexpn, DispatchErr, Json.ERR, or Socket.Err *)
(* I'd love to refactor the various exceptions into a Result/Either type,
   but without do notation, infix ops, or typeclasses, monads become
   pretty unwieldy :( *)
fun eval map ev t =
    case t
     of USM id args => U id args me (measureUsm dummyAmUSM id args) ev
      | KIM id pl args => K id args me pl (measureKim dummyAmKIM id me args) ev
      | SIG => G me ev (signEv ev)
      | HSH => H me (genHash ev)
      | CPY => ev
      | NONCE => N me 0 (genNonce ()) ev (* TODO: replace '0' with a real ID *)
      | AT pl t' => dispatchAt (REQ me pl map t' ev)
      | LN t1 t2 => eval map (eval map ev t1) t2
      | BRS (s1, s2) t1 t2 => SS (eval map (splitEv s1 ev) t1) (eval map (splitEv s2 ev) t2)
      | BRP (s1, s2) t1 t2 => PP (eval map (splitEv s1 ev) t1) (eval map (splitEv s2 ev) t2)
