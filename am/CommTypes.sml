(* Depends on: CoplandLang.sml *)

type address = string

(* Nameserver mapping *)
type nsMap = ((pl, address) map)
val emptyNsMap : nsMap = Map.empty nat_compare

(* To place,
   From place,
   Nameserver mapping,
   Term to execute,
   Initial evidence *)
datatype requestMessage = REQ pl pl nsMap t ev

(* To place,
   From place,
   Gathered evidence *)
datatype responseMessage = RES pl pl ev
