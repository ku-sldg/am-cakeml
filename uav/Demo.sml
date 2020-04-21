(* Depends on Instr.sml, JsonToCopland.sml, and Measurements.sml *)

(* updateWhitelist : id -> bool -> () *)
(* temp stub *)
(* TODO: link with HAMR API *)
fun updateWhitelist _ _ = ()

(* checkInMsg : () -> (id, string) option *)
(* temp stub *)
(* TODO: link with HAMR API *)
fun checkInMsg () = None

(* send : id -> string -> () *)
(* temp stub *)
(* TODO: link with HAMR API *)
fun send id msg = ()

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

(* getMsg : () -> (id, string) *)
fun getMsg () =
    let val inMsg = checkInMsg ()
     in case inMsg of
          Some (id, msg) => (id, msg)
        | None => getMsg ()
    end

(* parseEvC : string -> evC *)
val parseEvC =
    let fun strToJson str = List.hd (fst (Json.parse ([], str)))
     in JsonToCopland.jsonToEvC o strToJson
    end

(* appraise : ByteString.bs -> evC -> bool *)
(* TODO: check sigs, hashes, nonce. Change evidence shape to match protocol *)
fun appraise nonce ev = case ev of
      Gc evSig (Uc (Id O) ["hashTest.txt"] evHash evNonce) => True
    | _ => False

(* attest : id -> () *)
fun attest id =
    let val nonce = genNonce ()
        val _ = send id nonce
        val evC = parseEvC (snd (getMsg ()))
     in updateWhitelist id (appraise nonce evC)
    end


(* main : () -> 'a *)
fun main () =
    let val (id, _) = getMsg ()
     in pulse 1000000 attest id
    end
val () = main ()
