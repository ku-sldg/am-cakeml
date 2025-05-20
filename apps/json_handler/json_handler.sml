(* 
For do_JSON_handler (now extracted from Coq):
...
 *)
 (*
fun respondToMsg ammconf client nonce = 
  let val inString  = Socket.read client 
      val _ = print ("\n\nReceived request string: \n" ^ inString ^ "\n")
      val time = timestamp ()
      val _ = TextIOExtra.printLn ("Time: " ^ Int.toString time)
      val outString = handle_AM_request ammconf inString nonce
      val _ = print ("\n\nSending response string: \n" ^ outString) 
      val num_written = Socket.write client outString
      val _ = print ("Closing Socket")
      val _ = Socket.close client
      val _ = print ("Closed Socket")
  in 
    ()
  end
  handle Json.Exn s1 s2 =>
          (TextIO.print_err ("JSON error" ^ s1 ^ ": " ^ s2 ^ "\n"); ())
*)

(* fun do_JSON_handler inString = inString *)

(* () -> () *)
fun main () =
  let val inString = TextIO.inputAll TextIO.stdIn
      val newString = (handle_FS_request inString) in
    TextIOExtra.printLn newString
  end
  handle Exception e => TextIO.print_err e 
          | Word8Extra.InvalidHex => TextIO.print_err "BSTRING UNSHOW ERROR"
          | _          => TextIO.print_err "Fatal: unknown error!\n"

val () = main ()