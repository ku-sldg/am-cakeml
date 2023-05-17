(* util/BinaryParser.sml *)
structure BinaryParser =
struct
    type stream = BString.bstring * int
    type 'a parser = stream -> ('a, string) result * BString.bstring * int

    (* parse: 'a parser -> BString.bstring -> ('a, string) result
     * `parse parser bs`
     * Runs the parser `parser` over the byte string `bs` and returns the
     * result.
     *)
    fun parse parser bs =
        case parser (bs, 0) of
          (Err msg, _, n') =>
            Err (String.concat ["Error ", Int.toString n',
                " bytes into byte string: ", msg])
        | (Ok res, _, _) => Ok res
    
    (* parseWithPrefix: 'a parser -> string -> string -> ('a, string) result
     * `parseWithPrefix parser prefix str`
     * If `str` is a byte string following a prefix `prefix`, then this runs
     * `parser` over the byte string and returns the result. Otherwise, returns
     * an `Err` value.
     *)
    fun parseWithPrefix parser prefix str =
        if String.isPrefix prefix str
        then
            let
                val rest = String.extract str (String.size prefix) None
            in
                parse parser (BString.unshow rest)
            end
            handle Word8Extra.InvalidHex =>
                Err "Byte string did not an even number of hexadecimal numerals."
        else Err (String.concat ["Byte string did not start with \"", prefix, "\"."])
    
    (* empty: unit parser
     * Returns a successful result exactly when the byte string is empty.
     *)
    fun empty (bs, n) =
        if bs = BString.empty
        then (Ok (), BString.empty, n)
        else (Err "Expected end of byte string", bs, n)
    
    (* success: unit parser
     * A byte string parser that does nothing but return successfully.
     *)
    fun success (bs, n) = (Ok (), bs, n)

    (* return: 'a -> 'b parser -> 'a parser
     * `return result parser`
     * Runs the parser `parser` over the byte string and upon success, returns
     * `result`.
     *)
    fun return res parser (bs, n) =
        case parser (bs, n) of
          (Ok _, bs', n') => (Ok res, bs', n')
        | (Err msg, bs', n') => (Err msg, bs', n')
    
    (* label: string -> 'a parser -> 'a parser
     * `label errMsg parser`
     * Runs the parser `parser` over the byte string and upon failure, returns
     * the error message `errMsg`.
     *)
    fun label errMsg parser (bs, n) =
        case parser (bs, n) of
          (Ok res, bs', n') => (Ok res, bs', n')
        | (Err msg, bs', n') =>
            if bs = bs' andalso n = n'
            then (Err errMsg, bs, n)
            else (Err msg, bs', n')
    
    (* resetPos: int -> 'a parser -> 'a parser
     * Runs the given parser over the byte string with a reset position.
     *)
    fun resetPos pos parser (bs, n) = parser (bs, pos)
    
    (* at: int -> 'a parser -> 'a parser
     * `at pos parser`
     * When the byte string is at position `pos`, run `parser` over the byte
     * string. Otherwise, return an error value.
     *)
    fun at pos parser (bs, n) =
        if pos = n
        then parser (bs, n)
        else (Err (String.concat ["Expected to be at position ", Int.toString pos,
            " in byte string but was instead at ", Int.toString n]), bs, n)
    
    (* seq: 'a parser -> 'b parser -> 'b parser
     * `seq parser1 parser2`
     * Runs `parser1` on the byte string, and on success, discards the result
     * and runs `parser2` on the remaining byte string.
     *)
    fun seq parser1 parser2 (bs, n) =
        case parser1 (bs, n) of
          (Ok _, bs', n') => parser2 (bs', n')
        | (Err msg, bs', n') => (Err msg, bs', n')
    
    (* fixedInt: int -> BString.endianness -> int parser
     * `fixedInt len endianness`
     * Parses a fixed-length integer of size `len` from the byte string using
     * the given endianness from `endianness`.
     *)
    fun fixedInt len endianness (bs, n) =
        let
            val bsLen = BString.length bs
        in
            if bsLen >= len
            then
                let
                    val intPart = BString.substring bs 0 len
                    val rest = BString.extract bs len None
                in
                    (Ok (BString.toInt endianness intPart), rest, n + len)
                end
            else
                let
                    val msg = String.concat ["Could not parse int of length ",
                        Int.toString len, " from ", Int.toString bsLen, " bytes."]
                in
                    (Err msg, BString.empty, n + bsLen)
                end
        end

    (* nulls: int -> unit parser
     * `nulls len`
     * Parses a fixed number of null bytes, specifically `len` null bytes from
     * the byte string.
     *)
    fun nulls len (bs, n) =
        let
            val bsLen = BString.length bs
        in
            if bsLen >= len
            then
                let
                    val rest = BString.extract bs len None
                in
                    if BString.substring bs 0 len = BString.nulls len
                    then (Ok (), rest, n + len)
                    else (Err (String.concat ["Next ", Int.toString len,
                        " bytes were expected to be null but wasn't."]), rest,
                        n + len)
                end
            else
                (Err (String.concat ["Could not parse ", Int.toString len,
                    " null bytes from ", Int.toString bsLen, " bytes"]),
                    BString.empty, n + bsLen)
        end
    
    (* remainingNulls: int -> 'a parser -> 'a parser
     * `remainingNulls width parser`
     * If the current position in the byte string is not a multiple of `width`,
     * parse null bytes until the position rolls over to a multiple of `width`
     * and then run `parser`.
     *)
    fun remainingNulls width parser (bs, n) =
        let
            val m = n mod width
        in
            if m = 0
            then parser (bs, n)
            else seq (nulls (width - m)) parser (bs, n)
        end
    
    (* endingNulls: int -> unit parser
     * `endingNulls width = remainingNulls width empty`
     *)
    fun endingNulls width = remainingNulls width empty

    (* leftoverNulls: int -> unit parser
     * `leftoverNulls width = remainingNulls width success`
     *)
    fun leftoverNulls width = remainingNulls width success
    
    (* any: int -> BString.bstring parser
     * `any len`
     * Successfully parses any byte string that is at least `len` in length.
     *)
    fun any len (bs, n) =
        let
            val bsLen = BString.length bs
        in
            if bsLen >= len
            then (Ok (BString.substring bs 0 len),
                    BString.extract bs len None, n + len)
            else (Err (String.concat ["Expected ", Int.toString len,
                    " bytes remaining but only found ", Int.toString bsLen,
                    " bytes."]), BString.empty, n + bsLen)
        end
    
    (* choice: 'a parser list -> 'a parser
     * Takes a list of parsers and applies them one at a time until one
     * succeeds, one returns an error but makes progress, or there are no more
     * parsers left to try.
     *)
    fun choice parsers (bs, n) =
        case parsers of
          [] => (Err "No more parsers to try", bs, n)
        | parser::parsers' =>
            case parser (bs, n) of
              (Ok res, bs', n') => (Ok res, bs', n')
            | (Err msg, bs', n') =>
                if bs = bs' andalso n = n'
                then choice parsers' (bs, n)
                else (Err msg, bs', n')
    
    (* bind: 'a parser -> ('a -> 'b parser) -> 'b parser
     * `bind parser funcp`
     * Runs `parser` over the byte string and on successfully getting `result`,
     * run `funcp result` over the rest of the byte string.
     *)
    fun bind parser funcp (bs, n) =
        case parser (bs, n) of
          (Ok res, bs', n') => funcp res (bs', n')
        | (Err msg, bs', n') => (Err msg, bs', n')
    
    (* map : ('a -> 'b) -> 'a parser -> 'b parser
     * `map func parser`
     * Runs `parser` over the byte string and upon success, applies `func` to
     * the result.
     *)
    fun map func parser (bs, n) =
        case parser (bs, n) of
          (Ok res, bs', n') => (Ok (func res), bs', n')
        | (Err msg, bs', n') => (Err msg, bs', n')

    (* count: int -> 'a parser -> ('a list) parser
     * `count c parser`
     * Runs the parser `parser` repeatedly for `c` times.
     *)
    fun count c parser (bs, n) =
        if c <= 0
        then (Ok [], bs, n)
        else
            bind
                parser
                (fn result =>
                    map (fn results => result::results) (count (c - 1) parser))
                (bs, n)
    
    (* seqs: ('a parser) list -> ('a list) parser
     * `seqs parsers`
     * Runs `parsers`, one at a time, over the byte string until an error value
     * is encountered or all the parsers have been used.
     *)
    fun seqs parsers (bs, n) =
        case parsers of
          [] => (Ok [], bs, n)
        | parser::parsers' =>
            bind
                parser
                (fn result =>
                    map (fn results => result::results) (seqs parsers'))
                (bs, n)
end
