(* Depends on Extra, ByteString *)

exception Undef

(* () -> 'a *)
fun undefined () = (
    TextIO.print_err "Undefined value encountered";
    raise Undef
)

datatype ('a, 'e) result = 
      Ok  'a
    | Err 'e

structure Result = struct
    exception Exn

    (* 'a -> ('a, 'e) result *)
    fun ok x = Ok x
    
    (* 'e -> ('a, 'e) result *)
    fun err e = Err e

    (* ('a, 'e) result -> 'a *)
    fun okValOf xr = case xr of
          Ok x => x
        | Err _ => raise Exn

    (* ('a, 'e) result -> 'e *)
    fun errValOf xr = case xr of
          Ok _ => raise Exn
        | Err e => e

    (* ('a -> 'c) -> ('b -> 'c) -> ('a, 'b) result -> 'c *)
    fun result fo fe res = case res of 
          Ok  a => fo a
        | Err e => fe e

    (* ('a, 'e) result -> 'a -> 'a *)
    fun getRes xr default = result id (const default) xr    

    (* ('a -> 'b) -> ('a, 'e) result -> ('b, 'e) result *)
    fun map f res = result (ok o f) err res

    (* ('e -> 'f) -> ('a, 'e) result -> ('a, 'f) result *)
    fun mapErr f res = result ok (err o f) res

    (* (('a, 'e) result, 'e) result -> ('a, 'e) result *)
    fun join res = result id err res

    (* ('a -> ('b, 'e) result) -> ('a, 'e) result -> ('b, 'e) result *)
    fun bind f = result f err

    (* ('a -> unit) -> ('a, 'e) result -> unit *)
    fun app f = result f (const ())

    (* ('e -> unit) -> ('a, 'e) result -> unit *)
    fun appErr f = result (const ()) f

    (* ('a, 'e) result -> bool *)
    fun isOk xr = result (const True) (const False) xr

    (* ('a, 'e) result -> bool *)
    fun isErr xr = result (const False) (const True) xr

    (* ('a -> 'a -> bool) -> ('e -> 'e -> bool) -> ('a, 'e) result -> ('a, 'e) result -> bool *)
    fun equal okeq erreq xr yr = case (xr, yr) of
          (Ok x, Ok y) => okeq x y
        | (Err ex, Err ey) => erreq ex ey
        | (Ok _, Err _) => False
        | (Err _, Ok _) => False
    
    (* ('a -> 'a -> ordering) -> ('e -> 'e -> ordering) -> ('a, 'e) result -> ('a, 'e) result -> ordering *)
    fun compare okord errord xr yr = case (xr, yr) of
          (Ok x, Ok y) => okord x y
        | (Ok _, Err _) => Less
        | (Err _, Ok _) => Greater
        | (Err ex, Err ey) => errord ex ey
end

structure FFI = struct 
    type ffi = string -> byte_array -> unit

    val success = Word8.fromInt 0
    val failure = Word8.fromInt 1
    val bufferTooSmall = Word8.fromInt 2

    (* ffi -> int -> bstring -> bstring *)
    fun call ffi len input = 
        let val out = Word8ArrayExtra.nulls len 
        in ffi (BString.toString input) out;
            BString.fromByteArray out 
        end

    (* ffi -> int -> bstring -> bstring option *)
    fun callOpt ffi len input = 
        let val result = call ffi (len+1) input
         in if BString.hd result = success then 
                Some (BString.tl result)
            else 
                None
        end

    (* ffi -> int -> bstring -> bstring option *)
    fun callOptFlex ffi defaultLen input = 
        let fun callOptFlex_aux len = 
                let val result = call ffi len input
                    val status = BString.hd result
                 in if status = success then 
                        Some (BString.tl result)
                    else if status = failure then 
                        None
                    else 
                        callOptFlex_aux (len*2)
                end
         in callOptFlex_aux defaultLen
        end
    
    (* ffi -> bstring -> bool *)
    fun callBool ffi input = BString.hd (call ffi 1 input) = success

    local 
        val wbuf = Word8ArrayExtra.nulls 2
    in
        (* int -> bstring *)
        fun n2w2 i = (
            Marshalling.n2w2 i wbuf 0;
            BString.fromByteArray wbuf
        )
    end

    (* string list -> bstring *)
    val nullSeparated = BString.concatList
                      o ListExtra.intersperse BString.nullByte
                      o List.map BString.fromString
end

(* bool -> (() -> ()) -> () *)
fun when cond io = if cond then io () else ()

(* 'a option -> ('a -> ()) -> () *)
fun whenSome opt io = OptionExtra.option () io opt

(* ('a, 'e) result -> ('a -> ()) -> () *)
fun whenOk res io = Result.result io (const ()) res

(* ('a -> 'b) -> 'a -> 'c *)
fun loop io x = (
    io x;
    loop io x
)