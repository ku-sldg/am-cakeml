(* Depends on: util, extracted/,
   copland/Json/CoplandToJson *)

type addr = string
(* Nameserver mapping *)
(* We could map to an address/port pair, but for now we assume the port number
   is 5000 *)
(*                  plc     (keyName -> value for the keys "ip", "port", "publicKey") *)
type jsonPlcMap = ((string, ((string, string) map)) map)

type nsMap = ((coq_Plc, addr) map)
val emptyNsMap : nsMap = Map.empty nat_compare
                                   

(* To place,
   From place,
   Nameserver mapping,
   Term to execute,
   Initial evidence *)
datatype requestMessage = REQ coq_Plc coq_Plc nsMap coq_Term coq_Evidence (bs list)

datatype requestMessage_json = REQ_json coq_Plc coq_Plc jsonPlcMap coq_Term coq_Evidence (bs list)

                              
(* To place,
   From place,
   Gathered evidence *)
datatype responseMessage = RES coq_Plc coq_Plc (bs list)
