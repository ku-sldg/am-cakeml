(* Depends on _ and Measurements.sml *)

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

(* appraise : ByteString.bs -> string -> bool *)
(* temp stub *)
(* TODO: parse msg into evidence ast, check sigs, golden values, and nonce *)
fun appraise nonce msg = True

(* attest : id -> () *)
fun attest id =
    let val nonce = genNonce ()
        val _ = send id nonce
        val (_, response) = getMsg ()
     in updateWhitelist id (appraise nonce response)
    end


(* main : () -> 'a *)
fun main () =
    let val (id, _) = getMsg ()
     in pulse 1000000 attest id
    end
val () = main ()
