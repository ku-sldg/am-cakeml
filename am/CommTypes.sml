(* Depends on: util, extracted/,
   copland/Json/CoplandToJson *)

type addr = string
(* Nameserver mapping *)
type nsMap = ((coq_Plc, addr) map)
val emptyNsMap : nsMap = Map.empty nat_compare
                                   
datatype requestMessage = REQ coq_Plc coq_Plc coq_Term coq_Evidence (bs list)

                              
(* To place,
   From place,
   Gathered evidence *)
datatype responseMessage = RES coq_Plc coq_Plc (bs list)
