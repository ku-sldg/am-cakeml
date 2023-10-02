(* Depends on: util, copland, am/Measurements, am/ServerAm *)


fun main () = 
  let val _ = print "running demo client\n"
      val t' = cert_style 
      val t = t' (* Coq_lseq cert_style (Coq_asp SIG) *)
      val tok : coq_ReqAuthTok = mt_evc
      val ev : coq_RawEv = [] 
      val req : coq_CvmRequestMessage = REQ t tok ev 
      val resp : coq_CvmResponseMessage = [] 
      val js =  responseToJson resp
                (* requestToJson req *)
                (* termToJson t  *)
      val tstr = Json.stringify js in 
        print ("Json representation of term: \n" ^ tstr ^ "\n\n")
  end


val _ = main ()
