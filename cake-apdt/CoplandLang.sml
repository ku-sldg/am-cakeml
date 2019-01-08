(* Depends on: CoqDefaults.sml, ByteString.sml*)

(* Copland Language Definition *)

datatype id = Id of nat

fun id_compare i j = let val (Id i) = i in
                         let val (Id j) = j in
                             nat_compare i j
                         end
                     end

fun idToString i = case i of Id i' => "Id " ^ natToString i'

type pl = nat
val plToString = natToString

type asp_id = id
val aspIdToString = idToString
(* val aspIdToString = Int.toString *)

type arg = string
fun argToString a = a

datatype sp = ALL
            | NONE

fun spToString s = case s
                    of ALL => "ALL"
                     | NONE => "NONE"

datatype t = USM of asp_id * arg list
           | KIM of asp_id * pl * arg list
           | SIG
           | HSH
           | NONCE
           | AT of pl * t
           | LN of t * t
           | BRS of sp * sp * t * t
           | BRP of sp * sp * t * t

fun tToString a =
    let
        val concat = concatWith " "
        fun wrapped a' = String.concat ["(", tToString a', ")"]
    in
        case a
         of USM a al => concat ["USM", aspIdToString a, listToString al argToString]
          | KIM a p al => concat ["KIM", aspIdToString a, plToString p, listToString al argToString]
          | SIG => "SIG"
          | HSH => "HSH"
          | NONCE => "NONCE"
          | AT p a' => concat ["AT", plToString p, wrapped a']
          | LN a1 a2 => concat ["LN", wrapped a1, wrapped a2]
          | BRS s1 s2 a1 a2 => concat ["BRS (", (spToString s1 ^ ", " ^ spToString s2), ") ", wrapped a1, wrapped a2]
          | BRP s1 s2 a1 a2 => concat ["BRP (", (spToString s1 ^ ", " ^ spToString s2), ") " , wrapped a1, wrapped a2]
    end

(* Evidence Values *)
local type bs = ByteString.bs in
datatype ev = Mt                                         (* Empty evidence *)
            | U of asp_id * arg list * pl * bs * ev      (* User space measurement *)
            | K of asp_id * arg list * pl * pl * bs * ev (* Kernel measurement *)
            | G of pl * ev * bs                          (* Signature *)
            | H of pl * bs                               (* Hash *)
            | N of pl * bs * ev                          (* Nonce *)
            | SS of ev * ev                              (* Sequence *)
            | PP of ev * ev                              (* Parallel *)
end

fun evToString e =
    let
        val concat = concatWith " "
        fun evToString' ev = String.concat ["(", evToString ev, ")"]
    in
        case e
         of Mt => "Mt"
          | U i al p bs e'   => concat ["U", aspIdToString i,
                                        listToString al (fn x => x),
                                        plToString p,
                                        ByteString.toString bs,
                                        evToString' e']
          | K i al p1 p2 bs e' => concat ["K", aspIdToString i,
                                          listToString al (fn x => x),
                                          plToString p1,
                                          plToString p2,
                                          ByteString.toString bs,
                                          evToString' e']
          | G p e' bs => concat ["G", plToString p, evToString' e', ByteString.toString bs]
          | H p bs    => concat ["H", plToString p, ByteString.toString bs]
          | N p bs e' => concat ["N", plToString p, ByteString.toString bs, evToString' e']
          | SS e1 e2  => concat ["SS", evToString' e1, evToString' e2]
          | PP e1 e2   => concat ["PP", evToString' e1, evToString' e2]
    end
