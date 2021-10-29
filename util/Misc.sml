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

    (* ffi -> bstring -> () *)
    fun callUnit ffi input = ((call ffi 0 input); ())

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

(* Bijective maps *)
structure BiMap = struct
    local 
        datatype ('a, 'b) biMap = BiMap (('a, 'b) map) (('b, 'a) map)

        fun left  bmap = case bmap of BiMap l _ => l
        fun right bmap = case bmap of BiMap _ r => r
    in
        type ('a, 'b) biMap = ('a, 'b) biMap

        (* ('a, 'b) biMap -> 'a -> 'b option *)
        fun lookupl bmap l = Map.lookup (left bmap) l

        (* ('a, 'b) biMap -> 'b -> 'a option *)
        fun lookupr bmap r = Map.lookup (right bmap) r

        (* ('a, 'b) biMap -> 'a -> bool *)
        fun existsl bmap l = MapExtra.exists (left bmap) l

        (* ('a, 'b) biMap -> 'b -> bool *)
        fun existsr bmap r = MapExtra.exists (right bmap) r
 
        (* ('a, 'b) biMap -> 'a -> 'b -> ('a, 'b) biMap *)
        fun insert bmap l r = case bmap of BiMap lmap rmap =>
            let val lmap' = OptionExtra.option lmap (Map.delete lmap) (Map.lookup rmap r)
                val rmap' = OptionExtra.option rmap (Map.delete rmap) (Map.lookup lmap l)
             in BiMap (Map.insert lmap' l r) (Map.insert rmap' r l)
            end

        (* ('a, 'b) biMap -> 'a -> 'b -> (('a, 'b) biMap) option *)
        fun maybeInsert bmap l r = case bmap of BiMap lmap rmap =>
            if existsl bmap l orelse existsr bmap r then 
                None 
            else 
                Some (BiMap (Map.insert lmap l r) (Map.insert rmap r l))

        (* ('a, 'b) biMap -> 'a -> -> ('a, 'b) biMap *)
        fun deletel bmap l = case bmap of BiMap lmap rmap =>
            BiMap (Map.delete lmap l) rmap

        (* ('a, 'b) biMap -> 'b -> -> ('a, 'b) biMap *)
        fun deleter bmap r = case bmap of BiMap lmap rmap =>
            BiMap lmap (Map.delete rmap r)

        (* ('a, 'b) biMap -> bool *)
        fun null bmap = Map.null (left bmap)

        (* ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('a, 'b) biMap *)
        fun empty lord rord = BiMap (Map.empty lord) (Map.empty rord)

        (* ('a -> 'a -> ordering) -> ('b -> 'b -> ordering) -> ('a, 'b) list -> ('a, 'b) biMap *)
        fun fromList lord rord = List.foldr (flip (uncurry o insert)) (empty lord rord)
    end
end

(* 'a ref -> ('a -> 'a) -> unit *)
fun updateRef r f = r := f (!r)

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

(* ('a -> 'b) -> 'a -> () *)
fun loop_ io x = (loop io x) : unit

