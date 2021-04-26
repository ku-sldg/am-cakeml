(* Depends on util, copland *)

exception Undef
(* () -> 'a *)
fun undefined () = raise Undef


(* string -> string *)
val hexToRaw = ByteString.toRawString o ByteString.fromHexString

val pub = hexToRaw "490E2422528F14AC6A48DDB9D72CB30B8345AF2E939003BC7A33A6057F2FFB0101000000000000002DD0B7F53A560000A049D882A37F00000000000000000000"

(* () -> connection *)
(* Blocking/waiting. *)
(* connection type includes relevant info like ip address, whatever we need to send requests and add to whitelist *)
fun waitGetConnection () = undefined ()

(* () -> string option *)
(* returns Nothing in the case of a timeout. *)
fun waitGetResponse conn = undefined ()

(* connection -> string -> () *)
fun sendReq conn req = undefined ()

(* connection -> () *)
(* idempotent *)
fun addToWhitelist conn = undefined ()

(* connection -> () *)
(* idempotent *)
fun removeFromWhitelist conn = undefined ()

(* string -> ev option *)
fun parseResp resp = 
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
     in Some (jsonToEv (strToJson resp))
    end
    handle _ => None

(* ev -> bool *)
(* true if appraisal succeeds *)
fun appraise ev = undefined ()

(* () -> ByteString *)
fun genNonce () = undefined ()

(* true if appraisal succeeds *)
(* might need to be refactored to differentiate bad appraisal from timeout and misc. errors (the former might warrant a permanent blacklisting, while the latter would not) *)
fun attest conn = 
    let val nonce = ByteString.toRawString (genNonce ())
        val _ = sendReq conn nonce
     in case waitGetResponse () of
              Some resp => case parseResp resp of
                    Some ev => if appraise ev
                        then (addToWhitelist conn; True)
                        else (removeFromWhitelist conn; False)
                  | _ => (removeFromWhitelist conn; False)
            | _ => (removeFromWhitelist conn; False)
    end

(* () -> () *)
(* blocks/waits until start of next period *)
fun waitForNextTick () = undefined ()

(* conn -> () *)
(* Loops infinitely unless appraisal fails, or timeout *)
fun attestLoop conn = (
    if attest conn
        then (waitForNextTick (); attestLoop conn)
        else () (* TODO: log message *)
)

(* () -> 'a *)
(* Infinite loop *)
fun mainLoop () = (
    attestLoop (waitGetConnection ());
    mainLoop ()
)
val () = mainLoop ()
