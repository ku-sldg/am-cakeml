(*
Writing to sockets from within the Posix environment
*)
exception DispatchErr string

fun decodeUUID (u : coq_UUID) = 
  (* Splits at ":" character, into (ip, port) *)
  let val colonInt = 
        case (String.findi (fn c => (Char.chr 58) = c) 0 u) of
          None => raise Exception "Unable to decode UUID, no splitting ':' found"
          | Some v => v
      val ip = String.substring u 0 colonInt
      (* This is retrieving the rest of the string *)
      val port = String.extract u (colonInt + 1) None
      val port' = case Int.fromString port of
                    Some v => v
                    | None => raise Exception "Unable to decode UUID, port not integer"
  in
    (ip, port')
  end

(*
Code for writing to Posix Sockets 
*)
fun sendCoplandReqSocket fd req = 
  let val jsonReq = requestToJson req
      val strJsonReq = jsonToStr jsonReq
      val _ = print ("\n\n" ^ "JSON CVM request string (sendCoplandReq): \n" ^ strJsonReq ^ "\n\n") in 
        Socket.output fd strJsonReq
  end (* Socket.output fd o jsonToStr o requestToJson *)

fun receiveCoplandRespSocket fd = 
  let val inStr = Socket.inputAll fd 
      val _ = print ("\n\n" ^ "String received (receievCoplandResp): \n" ^ inStr ^ "\n\n")
      val inStrJson = strToJson inStr 
      val resp = jsonToResponse inStrJson in 
        resp 
  end (* jsonToResponse o strToJson o Socket.inputAll *)

fun sendCoplandAppReqSocket fd req = 
  let val jsonReq = appRequestToJson req
      val strJsonReq = jsonToStr jsonReq
      val _ = print ("\n\n" ^ "JSON APP request string (sendCoplandAppReq): \n" ^ strJsonReq ^ "\n\n") in 
        Socket.output fd strJsonReq
  end

fun receiveCoplandAppRespSocket fd = 
  let val inStr = Socket.inputAll fd 
      val _ = print ("\n\n" ^ "String received (receievCoplandAppResp): \n" ^ inStr ^ "\n\n")
      val inStrJson = strToJson inStr 
      val resp = jsonToAppResponse inStrJson in 
        resp 
  end

(*
Code for writing to seL4 dataports from within the Linux VM
*)
fun sendCoplandReqDataport port req =
    let
        val thisDataport = "/dev/uio" ^ (Int.toString port)
        val jsonReq = requestToJson req
        val strJsonReq = jsonToStr jsonReq
        val _ = print ("\n\n" ^ "JSON CVM request string (sendCoplandReq): \n" ^ strJsonReq ^ "\n")
    in
        writeDataport thisDataport (BString.fromString strJsonReq)
    end

fun receiveCoplandRespDataport port =
    let
        val thisDataport = "/dev/uio" ^ (Int.toString port)
        val _ = emitDataport thisDataport
        (*
        val _ = waitDataport thisDataport
        *)
        val inByteStr = readDataport thisDataport 4096
        val inStr = BString.toCString inByteStr
        val _ = print ("\n\n" ^ "String received (receiveCoplandResp): \n" ^ inStr ^ "\n\n")
        val inStrJson = strToJson inStr
        val resp = jsonToResponse inStrJson
    in
        resp
    end

fun sendCoplandAppReqDataport port req =
    let
        val thisDataport = "/dev/uio" ^ (Int.toString port)
        val jsonReq = appRequestToJson req
        val strJsonReq = jsonToStr jsonReq
        val _ = print ("\n\n" ^ "JSON CVM request string (sendCoplandAppReq): \n" ^ strJsonReq ^ "\n")
    in
        writeDataport ("/dev/uio" ^ (Int.toString port)) (BString.fromString strJsonReq)
    end

fun receiveCoplandAppRespDataport port =
    let
        val thisDataport = "/dev/uio" ^ (Int.toString port)
        val _ = waitDataport thisDataport
        val inByteStr = readDataport thisDataport 4096
        val inStr = BString.toCString inByteStr
        val _ = print ("\n\n" ^ "String received (receiveCoplandAppResp): \n" ^ inStr ^ "\n\n")
        val inStrJson = strToJson inStr
        val resp = jsonToAppResponse inStrJson
    in
        resp
    end


(* coq_Plc -> nsMap -> coq_Plc -> coq_ReqAuthTok -> (bs list) -> coq_Term -> (bs list) *)
fun networkDispatch (target : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let 
        val (ip, port) = decodeUUID target
        val isDataportOp = (ip = "dataport")
        val req  = (REQ t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
    in
        case isDataportOp of
            False => let
                        val fd   = (Socket.connect ip port)
                        val resev = (sendCoplandReqSocket fd req; receiveCoplandRespSocket fd)
                    in
                        Socket.close fd;
                        resev
                    end
           |True => let
                        val resev = (sendCoplandReqDataport port req; receiveCoplandRespDataport port)
                    in
                        resev
                    end
    end

(* coq_UUID -> coq_Term -> coq_Plc -> coq_Evidence -> coq_RawEv -> coq_AppResultC *)
fun networkDispatchApp (target : coq_UUID) (t : coq_Term) (p:coq_Plc) (et:coq_Evidence) (ev : coq_RawEv)  =
    let 
        val (ip, port) = decodeUUID target
        val isDataportOp = (ip = "dataport")
        val req  = (REQ_APP t p et ev)
        val _ = print ("Dispatching Appraisal Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
    in
        case isDataportOp of
            False => let
                        val fd   = (Socket.connect ip port)
                        val resapp = (sendCoplandAppReqSocket fd req; receiveCoplandAppRespSocket fd)
                    in
                        Socket.close fd;
                        resapp
                    end
           |True => let
                        val resapp = (sendCoplandAppReqDataport port req; receiveCoplandAppRespDataport port)
                    in
                        resapp
                    end
    end


(*
fun networkDispatch (target : coq_UUID) (authTok : coq_ReqAuthTok) (ev : (bs list)) (t : coq_Term) =
    let 
        val (ip, port) = decodeUUID target
        val isDataportOp = ip = "dataport"
        val req  = (REQ t authTok ev)
        val _ = print ("Dispatching Request Term: \n'" ^ (termToString t) ^ "'\nTo address: " ^ ip ^ ":" ^ (Int.toString port) ^ "\n")
        val fd = if isDataportOp then "/dev/" else (Socket.connect ip port)
    in
        if isDataportOp
        then
            sendCoplandReqDataport fd req;
            receiveCoplandRespDataport fd
        else
            sendCoplandReqSocket fd req;
            Socket.close fd;
            receiveCoplandRespSocket fd
    end
    *)

