(* Depends on Cache.sml, Instr.sml *)

type uxasMsg = string
type addr    = string

(* uxas : uxasMsg -> () *)
(* Dummy UxAS. Represents message delivery to UxAS *)
fun uxas msg = print ("UxAS recieved message: " ^ msg ^ "\n")

(* attest : addr -> bool *)
(* Dummy attestation. Only approves localhost *)
fun attest a = (a = "127.0.0.1")
(* fun attest i =
    let val term = Asp Cpy
        val map  = Map.insert emptyNsMap (S O) "127.0.0.1"
        val ev   = evalTerm O map Mtc (Att (idToPl i) term)
     in appraise ev
    end *)


(* checkAddr : addr -> bool *)
(* returns cached go/nogo decision, or else returns result of a full
   attestation/appraisal if no cache entry exists for the address *)
local
    val cache : (addr, bool) Cache.cache = Cache.new 10000000
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


(* val demo = (filter "badAddr"   "This message will be dropped";
            filter "127.0.0.1" "This message will be forwarded to UxAS") *)

(* pulse : int -> ('a -> 'b) -> 'a -> 'c *)
(* Takes a frequency (in microseconds), a function, and that function's argument.
   Repeatedly calls the function with the argument, on intervals defined by the
   frequency. *)
fun pulse freq f x =
    let val next = Ref (timestamp () + freq)
        fun spinUntil c = if c () then () else spinUntil c
        fun loop io = (io (); loop io)
     in loop (fn () => (
            f x;
            spinUntil (fn () => timestamp () >= !next);
            next := !next + freq
        ))
    end

local
    val count  = Ref 0
    val oneSec = 1000000
in
    val _ = pulse oneSec (fn () => (
        print ("Pretend attestation request " ^ Int.toString (!count) ^ "\n");
        count := !count + 1
    )) ()
end
