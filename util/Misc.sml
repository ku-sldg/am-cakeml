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

    (* ('a, 'e) result -> ('a -> ('b, 'e) result) -> ('b, 'e) result *)
    fun bind xr f = result f err xr

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

    (* 'a option -> 'e -> ('a, 'e) result *)
    fun fromOption opt e = OptionExtra.option (Err e) ok opt

    (* ('a, 'e) result -> 'a option *)
    fun toOption r = result OptionExtra.some (const None) r
end

structure FFI = struct 
    type ffi = string -> byte_array -> unit

    val success = Word8.fromInt 0
    val failure = Word8.fromInt 1
    val bufferTooSmall = Word8.fromInt 2

    val resp_code_SUCCESS = Word8.fromInt 0

    val resp_code_FAILED_TO_READ_FILE = Word8.fromInt 237
    val resp_code_FAILED_TO_REALLOC_BUFFER = Word8.fromInt 238
    val resp_code_FAILED_TO_ALLOCATE_BUFFER = Word8.fromInt 239
    val resp_code_INSUFFICIENT_OUTPUT = Word8.fromInt 240
    val resp_code_NEED_MORE_THAN_32_BITS_FOR_LENGTH = Word8.fromInt 241

    val resp_code_FILE_READ_ERROR = Word8.fromInt 254
    val resp_code_FILE_CLOSE_ERROR = Word8.fromInt 255

    val resp_CODE_START : int = 0
    val resp_CODE_LEN : int = 1
    val output_LEN_START : int = 1
    val output_LEN_LEN : int = 4
    val header_END = 5

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

    (* This is a call for a FFI function that abides by the standard
    that is utilized in the sys_ffi popen_string code.
    Basically it allows for a variable length output buffer where if
    it fails the first time due to insufficient space, it will
    call it again with a sufficient amount (because the FFI function
    will return how much space it needs)
    *)
    (* ffi -> int -> bstring -> bstring *)
    fun callVariableResp ffi defaultLen input = 
      let fun callVarResp_aux len = 
            let val result = call ffi len input
                val resp_code_str = (BString.substring result resp_CODE_START resp_CODE_LEN)
                val resp_code_int : int = BString.toInt BString.LittleEndian resp_code_str
                val resp_code : Word8.word = Word8.fromInt resp_code_int
                val output_len_str = (BString.substring result output_LEN_START output_LEN_LEN)
                val output_len = BString.toInt BString.LittleEndian output_len_str
            in 
              if resp_code = resp_code_SUCCESS
              then BString.substring result header_END output_len
              else if resp_code = resp_code_INSUFFICIENT_OUTPUT
              then callVarResp_aux (2 * output_len)
              else if resp_code = resp_code_FAILED_TO_READ_FILE
              then raise (Exception "FAILED_TO_READ_FILE")
              else if resp_code = resp_code_FAILED_TO_REALLOC_BUFFER
              then raise (Exception "FAILED_TO_REALLOC_BUFFER")
              else if resp_code = resp_code_FAILED_TO_ALLOCATE_BUFFER
              then raise (Exception "FAILED_TO_ALLOCATE_BUFFER")
              else if resp_code = resp_code_FILE_READ_ERROR
              then raise (Exception "FILE_READ_ERROR")
              else if resp_code = resp_code_FILE_CLOSE_ERROR
              then raise (Exception "FILE_CLOSE_ERROR")
              else raise (Exception ("Unknown Response Code returned to FFI callVariableResp during: \"" ^ (BString.toString input) ^ "\"\n"))
            end
      in 
        callVarResp_aux defaultLen
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