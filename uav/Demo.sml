(* Depends on Cache.sml, Instr.sml *)

type uxasMsg = string
type addr    = string

(* uxas : uxasMsg -> () *)
(* Dummy UxAS. Represents message delivery to UxAS *)
fun uxas msg = print ("UxAS recieved message: " ^ msg ^ "\n")

(* attest : addr -> bool *)
(* Dummy attestation. Only approves localhost *)
fun attest a = (a = "127.0.0.1")

(* checkAddr : addr -> bool *)
(* returns cached go/nogo decision, or else returns result of a full
   attestation/appraisal if no cache entry exists for the address *)
local
    val cache : (addr, bool) Cache.cache = Cache.new ()
in
    fun checkId a = Option.getOpt (Cache.lookup cache a)
                    let val res = attest a
                     in Cache.update cache (a,res); res
                    end
end

(* filter : addr -> uxasMsg -> () *)
(* Takes an addr and a UxAS message. Forwards or drops the message
   depending on cache's response to the id. *)
fun filter a msg = if checkId a then uxas msg else ()


val demo = (filter "badAddr"   "This message will be dropped";
            filter "127.0.0.1" "This message will be forwarded to UxAS")
