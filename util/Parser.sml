structure Parser =
struct
    type 'a stream = 'a list * int * int
    type ('a, 'b) parser = ('b stream) -> ('a, string) result * 'b list * int * int
    (* parse: ('a, char) parser -> string -> ('a, string) result
     * `parse p str`
     * Runs the parser `p` over the string `str`.
     *)
    fun parse p str =
        case p (String.explode str, 1, 1) of
          (Ok x, _, _, _) => Ok x
        | (Err msg, _, line, col) =>
            Err (String.concat ["Error on line ", Int.toString line,
                " and column ", Int.toString col, ": ", msg])
    (* bind: ('a, 'b) parser -> ('a -> ('c, 'b) parser) -> ('c, 'b) parser
     * `bind p funcp`
     * Runs the parser `p` and upon success, applies `funcp` to the result and
     * continue to parse.
     *)
    fun bind p funcp stream =
        case p stream of
          (Ok x, cs', line', col') => funcp x (cs', line', col')
        | (Err msg, cs', line', col') => (Err msg, cs', line', col')
    (* bindResult: ('a -> ('b, string) result) -> ('a, 'c) parser -> ('b, 'c) parser
     * `bindResult func p`
     * Runs the parser `p` and upon success, applies `func` to the result.
     *)
    fun bindResult func p stream =
        case p stream of
          (Ok x, cs', line', col') => (func x, cs', line', col')
        | (Err err, cs', line', col') =>
            (Err err, cs', line', col')
    (* map: ('a -> 'b) -> ('a, 'c) parser -> ('b, 'c) parser
     * `map func p`
     * Runs parser `p` and upon success, applies `func` to the result.
     *)
    fun map func p stream =
        case p stream of
          (Ok x, cs', line', col') =>
            (Ok (func x), cs', line', col')
        | (Err err, cs', line', col') =>
            (Err err, cs', line', col')
    (* mapErr: (string -> string) -> ('a, 'b) parser -> ('a, 'b) parser
     * `mapErr func p`
     * Runs parser `p` and upon failure, applies `func` to the error message.
     *)
    (* fun mapErr func p stream =
        case p stream of
          (Ok x, cs', line', col') =>
            (Ok x, cs', line', col')
        | (Err err, cs', line', col') =>
            (Err (func err), cs', line', col') *)
    (* pure: 'a -> ('a, 'b) parser
     * `pure x`
     * A simple parser that successfully returns `x` without consuming any
     * input.
     *)
    fun pure x (cs, line, col) = (Ok x, cs, line, col)
    (* fail: 'b -> ('a, 'b) parser
     * `fail err`
     * A simple parser that fails, returning `err`, without consuming any input.
     *)
    fun fail err (cs, line, col) = (Err err, cs, line, col)
    (* eof: (unit, string) parser
     * `eof`
     * A simple parser that succeeds exactly when there is no more input.
     *)
    fun eof (cs, line, col) =
        case cs of
          [] => (Ok (), [], line, col)
        | c::cs' => (Err "End of stream expected.", c::cs', line, col)
    (* seq: ('a, 'b) parser -> ('c, 'b) parser -> ('c, 'b) parser
     * `seq p1 p2`
     * Runs parser `p1` and then, upon success, runs parser `p2`, discarding the
     * previous results.
     *)
    fun seq p1 p2 stream = bind p1 (fn _ => p2) stream
        (* case p1 stream of
          (Ok _, cs, line, col) => p2 (cs, line, col)
        | (Err msg, cs, line, col) => (Err msg, cs, line, col) *)
    (* satisfy: (char -> bool) -> (char, char) parser
     * `satisfy pred`
     * A simple parser that succeeds exactly when `pred` returns true on the
     * next element in the stream. Does not consume input upon failure.
     *)
    fun satisfy pred (cs, line, col) =
        case cs of
          [] => (Err "End of stream reached too early.", [], line, col)
        | c::cs' =>
            if pred c
            then if c <> #"\n"
                then (Ok c, cs', line, 1 + col)
                else (Ok c, cs', 1 + line, 1)
            else (Err "Failed to satisfy a predicate.", cs, line, col)
    (* label: string -> ('a, 'b) parser -> ('a, 'b) parser
     * `label errMsg p`
     * Runs parser `p` and if it fails without consuming input, then the error
     * message is replaced by `errMsg`.
     *)
    fun label errMsg p (cs, line, col) =
        case p (cs, line, col) of
          (Err str, cs', line', col') =>
            if line = line' andalso col = col' andalso cs = cs'
            then (Err errMsg, cs, line, col)
            else (Err str, cs', line', col')
        | (Ok x, cs', line', col') => (Ok x, cs', line', col')
    (* return: 'a -> ('b, 'c) parser -> ('a, 'c) parser
     * `return x p`
     * Runs parser `p` and if it succeeds replace the result with `x`.
     *)
    fun return x p stream =
        case p stream of
          (Ok _, cs', line', col') => (Ok x, cs', line', col')
        | (Err err, cs', line', col') =>
            (Err err, cs', line', col')
    (* char: char -> (char, char) parser
     * `char c`
     * Returns a simple parser that expects the next character in the stream to
     * be `c`. Does not consume input upon failure.
     *)
    fun char inc =
        label (String.concat ["Expected to see character '", String.str inc, "'."])
            (satisfy (op = inc))
    (* notChar: char -> (char, char) parser
     * `notChar c`
     * Returns a simple parser that expects the next character in the stream to
     * not be `c`. Does not consume input upon failure.
     *)
    fun notChar inc =
        label (String.concat ["Expected not to see character '", String.str inc, "'."])
            (satisfy (op <> inc))
    (* newline: (char, char) parser
     * Parses a line feed character. Does not consume input upon failure.
     *)
    (* val newline = label "Expected a line feed/newline character." (char #"\n") *)
    (* tab: (char, char) parser
     * Parses a tab character. Does not consume input upon failure.
     *)
    (* val tab = label "Expected a tab character." (char (Char.chr 9)) *)
    (* oneOf: char list -> (char, char) parser
     * `oneOf cs`
     * A parser that succeeds exactly when the next character in the stream is
     * one of the characters in the list `cs`. Does not consume input upon
     * failure.
     *)
    fun oneOf incs =
        label (String.concat ["Expected one of the following characters \"",
                String.implode incs, "\"."])
            (satisfy (fn inc => List.exists (op = inc) incs))
    (* noneOf: char list -> (char, char) parser
     * `noneOf cs`
     * A parser that succeeds exactly when the next character in the stream is
     * not one of the characters in the list `cs`. Does not consume input upon
     * failure.
     *)
    fun noneOf incs =
        label (String.concat ["Expected not to see any of the following characters \"",
                String.implode incs, "\"."])
            (satisfy (fn inc => List.all (op <> inc) incs))
    (* anyChar: (char, char) parser
     * A simple parser that succeeds so long as there is another character in
     * the stream. Does not consume input upon failure.
     *)
    val anyChar = label "Expected any character." (satisfy (const True))
    (* digit: (char, char) Parser
     * A simple parser that succeeds upon seeing a digit, '0'..'9'. Does not
     * consume input upon failure.
     *)
    val digit = 
        label "Expected a digit." (satisfy CharExtra.isDigit)
    (* octalDigit: (char, char) Parser
     * A simple parser that succeeds upon seeing an octal numeral, '0'..'7'.
     * Does not consume input upon failure.
     *)
    val octalDigit = 
        label "Expected an octal digit." (satisfy CharExtra.isOctal)
    (* hexDigit: (char, char) Parser
     * A simple parser that succeeds upon seeing a hexadecimal numeral,
     * '0'..'9' or 'a'..'f' or 'A'..'F'. Does not consume input upon
     * failure.
     *)
    val hexDigit = 
        label "Expected a hexidecimal digit." (satisfy CharExtra.isHex)
    (* lower: (char, char) Parser
     * A simple parser that succeeds upon seeing a lowercase ASCII
     * character, 'a'..'z'. Does not consume input upon failure.
     *)
    val lower = 
        label
            "Expected a lower-case ascii character."
            (satisfy CharExtra.isLower)
    (* upper: (char, char) Parser
     * A simple parser that succeeds upon seeing an uppercase ASCII
     * character, 'A'..'Z'. Does not consume input upon failure.
     *)
    val upper = 
        label
            "Expected an upper-case ascii character."
            (satisfy CharExtra.isUpper)
    (* letter: (char, char) Parser
     * A simple parser that succeeds upon seeing an ASCII alphabet
     * character, 'a'..'z' or 'A'..'Z'. Does not consume input upon failure.
     *)
    val letter = 
        label
            "Expected an ascii alphabet character."
            (satisfy CharExtra.isAlpha)
    (* alphaNum: (char, char) Parser
     * A simple parser that succeeds upon seeing an ASCII digit or alphabet
     * character: 'a'..'z', 'A'..'Z', or '0'..'9'. Does not consume input
     * upon failure.
     *)
    val alphaNum = 
        label
            "Expected an ascii alphanumeric character."
            (satisfy CharExtra.isAlphaNum)
    (* space: (char, char) Parser
     * A simple parser that succeeds upon seeing any ASCII whitespace
     * characters. Does not consume input upon failure.
     *)
    val space = 
        label
            "Expected an ascii whitespace character."
            (satisfy CharExtra.isSpace)
    (* string: string -> (string, char) parser
     * `string str`
     * A parser that succeeds when the characters of `str` are the characters
     * that appear next in the stream. Does not consume input upon failure.
     *)
    fun string str (cs, line, col) =
        let
            val chars = String.explode str
            fun advancePos cs' (line', col') =
                case cs' of
                  [] => (line', col')
                | #"\n"::cs'' => advancePos cs'' (1 + line', 1)
                | c::cs'' => advancePos cs'' (line', 1 + col')
        in
            if List.isPrefix chars cs
            then
                let
                    val (line', col') = advancePos chars (line, col)
                in
                    (Ok str, List.drop cs (String.size str), line', col')
                end
            else (Err (String.concat ["Expect the literal string \"", str, "\""]),
                    cs, line, col)
        end
    (* crlf: (char, char) parser
     * A simple parser that succeeds upon seeing '\r\n' and returns '\n'. Does
     * not consume input upon failure.
     *)
    val crlf =
        label "Expected a carriage return followed by a line feed."
            (return #"\n" (string (String.concat [String.str (Char.chr 13), "\n"])))
    (* choice: (('a, 'b) parser) list -> ('a, 'b) parser
     * `choice ps`
     * A parser that tries one parser after another until one succeeds or one
     * fails and consumes input. Should the next parser to try fails and
     * consumes input, then this function will do the same.
     *)
    fun choice ps (cs, line, col) =
        case ps of
          [] => (Err "No more parsers to try", cs, line, col)
        | p::ps' =>
            case p (cs, line, col) of
              (Ok x, cs', line', col') =>
                (Ok x, cs', line', col')
            | (Err err, cs', line', col') =>
                if line = line' andalso col = col' andalso cs = cs'
                then choice ps' (cs, line, col)
                else (Err err, cs', line', col')
    (* endOfLine: (char, char) parser
     * `endOfLine = choice [newline, crlf]`
     * A simple parser that succeeds upon seeing the character '\n' or the
     * string "\r\n", returning '\n' upon any success. Does not consume input
     * upon failure.
     *)
    (* val endOfLine = choice [newline, crlf] *)
    (* try: ('a, 'b) parser -> ('a, 'b) parser
     * `try p`
     * Tries parser `p` remembering the state of the stream so that if it fails
     * and consumes input, then `try p` fails but does _not_ consume input.
     *)
    fun try p (cs, line, col) =
        case p (cs, line, col) of
          (Err err, _, _, _) => (Err err, cs, line, col)
        | (Ok x, cs', line', col') => (Ok x, cs', line', col')
    (* many: ('a, 'b) parser -> ('a list, 'b) parser
     * `many p`
     * Tries parser `p` zero or more times. As long as `p` succeeds, `many p`
     * will continue to consume input. Once `p` fails whether it has consumed
     * input or not, `many p` succeeds returning the empty list withut consuming
     * input.
     *)
    fun many p (cs, line, col) =
        case p (cs, line, col) of
          (Ok x, cs', line', col') =>
            let
                val (Ok xs, cs'', line'', col'') =
                    many p (cs', line', col')
            in
                (Ok (x::xs), cs'', line'', col'')
            end
        | (Err _, _, _, _) => (Ok [], cs, line, col)
    (* many1: ('a, 'b) parser -> ('a list, 'b) parser
     * `many1 p`
     * Tries parser `p` one or more times. As long as `p` succeeds, `many1 p`
     * will continue to consume input.
     *)
    fun many1 p stream = bind p (fn x => map (fn xs => x::xs) (many p)) stream
        (* case p stream of
          (Ok x, cs', line', col') =>
            let
                val (Ok xs, cs'', line'', col'') =
                    many p (cs', line', col')
            in
                (Ok (x::xs), cs'', line'', col'')
            end
        | (Err err, cs', line', col') => (Err err, cs', line', col') *)
    (* skipMany: ('a, 'b) parser -> (unit, 'b) parser
     * `skipMany p`
     * Tries parser `p` zero or more times, discarding the results. As long as
     * `p` succeeds, `skipMany p` will consume input. Succeeds the first time
     * `p` fails and does not consume input. Should `p` fail and consume input,
     * then so does this function.
     *)
    fun skipMany p (cs, line, col) =
        case p (cs, line, col) of
          (Ok _, cs', line', col') => skipMany p (cs', line', col')
        | (Err err, cs', line', col') =>
            if line = line' andalso col = col' andalso cs = cs'
            then (Ok (), cs, line, col)
            else (Err err, cs', line', col')
    (* skipMany1: ('a, 'b) parser -> (unit, 'b) parser
     * `skipMany1 p`
     * Tries parser `p` one or more times, discarding the results. As long as
     * `p` succeeds, `skipMany1 p` will consume input. Succeeds the first time
     * `p` fails and does not consume input. Should `p` fail and consume input,
     * then so does this function.
     *)
    (* fun skipMany1 p stream = bind p (fn _ => skipMany p) stream
        (* case p stream of
          (Ok _, cs', line', col') => skipMany p (cs', line', col')
        | (Err err, cs', line', col') =>
            (Err err, cs', line', col') *) *)
    (* spaces: (unit, char) parser
     * `spaces = skipMany space`
     * Skips zero or more ASCII whitespace characters. Does not consume input
     * upon failure.
     *)
    val spaces = skipMany space
    (* count: int -> ('a, 'b) parser -> ('a list, 'b) parser
     * `count n p`
     * Applies the parser `p` at most `n` times or until the first time `p`
     * fails. Consumes input whenever `p` does so.
     *)
    fun count n p (cs, line, col) =
        if n <= 0
        then (Ok [], cs, line, col)
        else
            bind p
                (fn x => map (fn xs => x::xs) (count (n - 1) p))
                (cs, line, col)
            (* case p (cs, line, col) of
              (Ok x, cs', line', col') =>
                let
                    val (xsr, cs'', line'', col'') =
                        count (n - 1) p (cs', line', col')
                in
                    case xsr of
                      Ok xs => (Ok (x::xs), cs'', line'', col'')
                    | Err err => (Err err, cs'', line'', col'')
                end
            | (Err err, cs', line', col') => (Err err, cs', line', col') *)
    (* between: ('a, 'b) parser -> ('c, 'b) parser -> ('d, 'b) parser -> ('d, 'b) parser
     * `between open close p`
     * Runs parser `open`, then runs `p`, then `close` keeping only the result
     * of `p` upon success.
     *)
    fun between openp closep p stream =
        bind openp (fn _ => bind p (fn x => return x closep)) stream
        (* case openp stream of
          (Err err, cs', line', col') =>
            (Err err, cs', line', col')
        | (Ok _, cs', line', col') =>
            case p (cs', line', col') of
              (Err err, cs'', line'', col'') =>
                (Err err, cs'', line'', col'')
            | (Ok x, cs'', line'', col'') =>
                case closep (cs'', line'', col'') of
                  (Err err, cs''', line''', col''') =>
                    (Err err, cs''', line''', col''')
                | (Ok _, cs''', line''', col''') =>
                    (Ok x, cs''', line''', col''') *)
    (* option: 'a -> ('a, 'b) parser -> ('a, 'b) parser
     * `option x p`
     * Runs parser `p` and succeeds returning `x` should `p` fail and not
     * consume input. If `p` succeeds, then this function returns whatever
     * result `p` produces. If `p` fails and consumes input, then this function
     * does the same.
     *)
    fun option x p (cs, line, col) =
        case p (cs, line, col) of
          (Ok y, cs', line', col') => (Ok y, cs', line', col')
        | (Err err, cs', line', col') =>
            if line = line' andalso col = col' andalso cs = cs'
            then (Ok x, cs, line, col)
            else (Err err, cs', line', col')
    (* optionOpt: ('a, 'b) parser -> ('a option, 'b) parser
     * Runs parser `p` and succeeds returning `None` should `p` fail and not
     * consume input.
     *)
    (* fun optionOpt p (cs, line, col) =
        case p (cs, line, col) of
          (Ok x, cs', line', col') => (Ok (Some x), cs', line', col')
        | (Err err, cs', line', col') =>
            if line = line' andalso col = col' andalso cs = cs'
            then (Ok None, cs, line, col)
            else (Err err, cs', line', col') *)
    (* sepBy: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `sepBy p sep`
     * Runs zero or more iterations of `p` separated by iterations of `sep` and
     * only the results of `p` are retained. Does not consume input upon
     * failure.
     *)
    fun sepBy p sepp (cs, line, col) =
        case p (cs, line, col) of
          (Err _, _, _, _) => (Ok [], cs, line, col)
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Err _, _, _, _) =>
                (Ok [x], cs', line', col')
            | (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (sepBy p sepp) (cs'', line'', col'')
                (* let
                    val (Ok xs, cs''', line''', col''') =
                        sepBy p sepp (cs'', line'', col'')
                in
                    (Ok (x::xs), cs''', line''', col''')
                end *)
    (* sepBy1: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `sepBy1 p sep`
     * Runs one or more iterations of `p` separated by iterations of `sep` and
     * only the results of `p` are retained.
     *)
    (* fun sepBy1 p sepp stream =
        case p stream of
          (Err err, cs', line', col') => (Err err, cs', line', col')
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Err _, _, _, _) =>
                (Ok [x], cs', line', col')
            | (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (sepBy p sepp) (cs'', line'', col'')
                (* let
                    val (Ok xs, cs''', line''', col''') =
                        sepBy p sepp (cs'', line'', col'')
                in
                    (Ok (x::xs), cs''', line''', col''')
                end *) *)
    (* endBy: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `endBy p sep`
     * Runs zero or more iterations of `p` where each iteration ends with `sep`,
     * and only the results of `p` are retained. Does not consume input upon
     * failure.
     *)
    (* fun endBy p sepp (cs, line, col) =
        case p (cs, line, col) of
          (Err _, _, _, _) => (Ok [], cs, line, col)
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Err err, cs'', line'', col'') =>
                (Err err, cs'', line'', col'')
            | (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (endBy p sepp) (cs'', line'', col'')
                (* let
                    val (xsr, cs''', line''', col''') =
                        endBy p sepp (cs'', line'', col'')
                in
                    case xsr of
                      Ok xs => (Ok (x::xs), cs''', line''', col''')
                    | Err err => (Err err, cs'', line'', col'')
                end *) *)
    (* endBy1: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `endBy1 p sep`
     * Runs one or more iterations of `p` where each iteration ends with `sep`,
     * and only the results of `p` are retained.
     *)
    (* fun endBy1 p sepp stream =
        case p stream of
          (Err err, cs', line', col') => (Err err, cs', line', col')
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Err err, cs'', line'', col'') =>
                (Err err, cs'', line'', col'')
            | (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (endBy p sepp) (cs'', line'', col'')
                (* let
                    val (xsr, cs''', line''', col''') =
                        endBy p sepp (cs'', line'', col'')
                in
                    case xsr of
                      Ok xs => (Ok (x::xs), cs''', line''', col''')
                    | Err err => (Err err, cs'', line'', col'')
                end *) *)
    (* sepEndBy: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `sepEndBy p sep`
     * Runs zero or more iterations of `p` interspersed with `sep` and an
     * optional instance of `sep` at the end. Only the results of `p` are
     * retained. Does not consume input upon failure.
     *)
    fun sepEndBy p sepp (cs, line, col) =
        case p (cs, line, col) of
          (Err _, _, _, _) => (Ok [], cs, line, col)
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Err _, _, _, _) =>
                (Ok [x], cs', line', col')
            | (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (sepEndBy p sepp) (cs'', line'', col'')
    (* sepEndBy1: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `sepEndBy1 p sep`
     * Runs one or more iterations of `p` interspersed with `sep` and an
     * optional instance of `sep` at the end. Only the results of `p` are
     * retained.
     *)
    (* fun sepEndBy1 p sepp stream =
        case p stream of
          (Err err, cs', line', col') => (Err err, cs', line', col')
        | (Ok x, cs', line', col') =>
            case sepp (cs', line', col') of
              (Ok _, cs'', line'', col'') =>
                map (fn xs => x::xs) (sepEndBy p sepp) (cs'', line'', col'')
                (* let
                    val (Ok xs, cs''', line''', col''') =
                        sepEndBy p sepp (cs'', line'', col'')
                in
                    (Ok (x::xs), cs''', line''', col''')
                end *)
            | (Err _, _, _, _) =>
                (Ok [x], cs', line', col') *)
    (* manyTill: ('a, 'b) parser -> ('c, 'b) parser -> ('a list, 'b) parser
     * `manyTill p endp`
     * Until `endp` succeeds, run parser `p` and only keeps its results. When
     * `endp` fails, whether or not it consumes input, this function backtracks
     * and then applies `p`.
     *)
    fun manyTill p endp stream =
        case endp stream of
          (Ok _, cs', line', col') => (Ok [], cs', line', col')
        | (Err _, _, _, _) =>
            case p stream of
              (Err err, cs', line', col') =>
                (Err err, cs', line', col')
            | (Ok x, cs', line', col') =>
                map (fn xs => x::xs) (manyTill p endp) (cs', line', col')
                (* let
                    val (xsr, cs'', line'', col'') =
                        manyTill p endp (cs', line', col')
                in
                    case xsr of
                      Ok xs => (Ok (x::xs), cs'', line'', col'')
                    | Err err => (Err err, cs'', line'', col'')
                end *)

    (* ('a, 'c) parser -> ('b, 'c) parser -> ('a, 'c) parser *)
    fun followedBy p q = bind p (fn a => return a q)
end
