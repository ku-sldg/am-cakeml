(* Depends on: CoplandLang.sml, CoqDefaults.sml, ByteString.sml, and Measurements.sml*)

type pubKey = nat
type privKey = nat

type platform = pubKey * privKey
type system = platform list

val public = fst
val private = snd

fun platforms s = List.map public s

fun splitEv s e =
    case s
      of ALL => e
       | NONE => Mt

exception USMexpn id
exception KIMexpn id

val emptyUSM : (id, string list -> ByteString.bs) mymap = map_empty
val emptyKIM : (id, nat -> string list -> ByteString.bs) mymap = map_empty

val mapUSM =
    let fun hashFileUSM args =
            case args
              of [fileName] => genFileHash fileName
               | _ => raise USMexpn (Id O)
     in map_set emptyUSM (Id O) hashFileUSM
    end

val mapKIM = emptyKIM

fun measureUsm map id args =
    case map_get map id
     of None => raise USMexpn id
      | Some f => f args

fun measureKim map id p args =
    case map_get map id
     of None => raise KIMexpn id
      | Some f => f p args


(* eval probably doesn't need a place argument, when it just represents "me"
   (invariant). Could pass me+map together in a copEnv-like thing. Throw in
   USM and KIM maps to? *)
val me = O

(* May raise USMexpn, KIMexpn, DispatchErr, Json.ERR, or Socket.Err *)
(* I'd love to refactor the various exceptions into a Result/Either type,
   but without do notation, infix ops, or typeclasses, monads become
   pretty unwieldy :( *)
fun eval map ev t =
    case t
     of USM id args => U id args me (measureUsm mapUSM id args) ev
      | KIM id pl args => K id args me pl (measureKim mapKIM id me args) ev
      | SIG => G me ev (signEv ev)
      | HSH => H me (genHash ev)
      | CPY => ev
      | AT pl t' => dispatchAt (REQ me pl map t' ev)
      | LN t1 t2 => eval map (eval map ev t1) t2
      | BRS (s1, s2) t1 t2 => SS (eval map (splitEv s1 ev) t1) (eval map (splitEv s2 ev) t2)
      | BRP (s1, s2) t1 t2 => PP (eval map (splitEv s1 ev) t1) (eval map (splitEv s2 ev) t2)
