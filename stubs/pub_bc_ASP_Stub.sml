(* Stub code for ASP with asp ID:  pub_bc_aspid *)

(* pub_bc_asp_stub :: coq_ASP_PARAMS -> coq_RawEv -> coq_BS *)
fun pub_bc_asp_stub ps e =
    case ps of Coq_asp_paramsC aspid args tpl tid =>
               (* if aspid = pub_bc_aspid
                  then *)
               let
                   (* FIX IDs *)
                   val attestId = BString.unshow "deadbeef"
                   val targetId = BString.unshow "facefeed"
                   (* FIX change to target IP info *)
                   val blockchainIp =
                       HealthRecord.TcpIp blockchainIpAddr
                                          blockchainIpPort
		   val pubkey_src_file = "src-pub.pem" (* "src-pub-temp.pem" *)
                   val signingKeyNull =
                       String.concat
                           (Option.getOpt
                                (TextIO.b_inputLinesFrom pubkey_src_file)
                                [])
		   val _=(print ("\nRead Bytes from file '" ^ pubkey_src_file ^ "' :\n" ^ signingKeyNull))
                   val signingKeyNullSize =
                       String.size signingKeyNull
                   val signingKeyNullEnd =
                       if signingKeyNullSize > 1
                       then signingKeyNullSize - 1
                       else signingKeyNullSize
                   val signingKey =
                       BString.fromString
                           ((String.substring
                                 signingKeyNull
                                 0
                                 signingKeyNullEnd) ^ "\n")
		   (* val signingKey = signingKey' ^ "\n" *)
                   (* val _ = print (String.concat ["\nSigning key size: ", Int.toString (BString.length signingKey), "\n"]) *)
                   val phrase = Coq_asp NULL
                   val hr = HealthRecord.healthRecord
                                targetId phrase (Json.fromBool True) None
                                attestId blockchainIp pub1 signingKey
                                (timestamp ())
                   val hrAddResult = HealthRecord.addRecord
                                         blockchainIpAddr blockchainIpPort jsonId
                                         healthRecordContract userAddress attestId
                                         targetId (HealthRecord.toJson hr)
               in
                   case hrAddResult of
                       Ok bstring => bstring
                     | Err str =>
                       (print (String.concat [str, "\n"]);
                        BString.nulls 1)
               end
                   
