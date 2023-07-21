(* Depends on: util, extracted/,
   copland/Json/CoplandToJson *)

type addr = string
(* Nameserver mapping *)
(* We could map to an address/port pair, but for now we assume the port number
   is 5000 *)
(*                  plc     (keyName -> value for the keys "ip", "port", "publicKey") *)




(*
datatype requestMessage = REQ coq_Term coq_ReqAuthTok (bs list)


(* Gathered evidence *)
datatype responseMessage = RES (bs list)


datatype cvmInMessage  = CVM_IN coq_Term (bs list) 
datatype cvmOutMessage = CVM_OUT (bs list)

*)