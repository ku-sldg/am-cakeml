(* Depends on: util, extracted/,
   copland/Json/CoplandToJson *)

type addr = string
(* Nameserver mapping *)
(* We could map to an address/port pair, but for now we assume the port number
   is 5000 *)
(*                  plc     (keyName -> value for the keys "ip", "port", "publicKey") *)
type nsMap = ((coq_Plc, addr) map)
val emptyNsMap : nsMap = Map.empty nat_compare
                                   
datatype requestMessage = REQ coq_Plc coq_Plc JsonConfig.PlcMap coq_Term coq_Evidence (bs list) (bs list)

                              
(* To place,
   From place,
   Gathered evidence *)
datatype responseMessage = RES coq_Plc coq_Plc (bs list)
