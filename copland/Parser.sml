(* util/Extra.sml
 * util/ByteString.sml
 * util/Misc.sml
 * util/Parsing.sml
 * copland/CoqDefaults.sml
 * copland/Instr.sml
 *)
(* term    ::= WS asp
 *           | WS '(' term WS '->' term WS ')'
 *           | WS '(' term WS sp WS '<' WS sp term WS ')'
 *           | WS '(' term WS sp WS '~' WS sp term WS ')'
 *           | WS '@' WS NUMERAL WS '[' term WS ']'
 * sp      ::= '+' | '-'
 * asp     ::= NUMERAL (WS STRING)*
 *           | '_' | '!' | '#'
 * NUMERAL ::= [0-9]+
 * STRING  ::= '"' [^"] '"'
 * WS      ::= [ \t\r\n]*
 *)
(* numeralP :: (nat, string) parser *)
val numeralP =
    Parser.bindResult
        (fn numStr =>
            OptionExtra.option
                (Err "failed to parse an integer")
                (fn x => Ok (natFromInt x))
                (Int.fromString (String.implode numStr)))
        (Parser.many1 Parser.digit)
(* identifierP :: (id, string) parser *)
val identifierP =
    Parser.map (fn x => Id x) numeralP
(* stringP :: (string, string) parser *)
val stringP =
    Parser.map
        String.implode
        (Parser.between
            (Parser.char #"\"")
            (Parser.char #"\"")
            (Parser.many (Parser.noneOf [#"\""])))
(* copyP, signP, hashP, aspcP :: (asp, string) parser *)
val copyP = Parser.return Cpy (Parser.char #"_")
val signP = Parser.return Sig (Parser.char #"!")
val hashP = Parser.return Hsh (Parser.char #"#")
val aspcP =
    Parser.bind
        identifierP
        (fn identifier =>
            Parser.map
                (fn args => Aspc identifier args)
                (Parser.seq
                    Parser.spaces
                    (Parser.sepBy stringP Parser.spaces)))
(* allP, noneP, spP :: (sp, string) parser *)
val allP = Parser.return ALL (Parser.char #"+")
val noneP = Parser.return NONE (Parser.char #"-")
val spP = Parser.choice [allP, noneP]
(* splitOpP :: char -> (sp -> sp -> term -> term -> term) -> (term -> term -> term, string) parser *)
fun splitOpP char constructor =
    Parser.bind
        spP
        (fn lsplitter =>
            Parser.seq
                Parser.spaces
                (Parser.seq
                    (Parser.char char)
                    (Parser.seq
                        Parser.spaces
                        (Parser.map
                            (fn rsplitter =>
                                constructor lsplitter rsplitter)
                            spP))))
(* bseqP, bparP, lseqP, infixOpP :: (term -> term -> term, string) parser *)
val bseqP =
    splitOpP #"<" (fn lsp => fn rsp => fn x => fn y => Bseq (lsp, rsp) x y)
val bparP =
    splitOpP #"~" (fn lsp => fn rsp => fn x => fn y => Bpar (lsp, rsp) x y)
val lseqP = Parser.return (fn x => fn y => Lseq x y) (Parser.string "->")
val infixOpP = Parser.choice [lseqP, Parser.try bseqP, bparP]
(* aspP :: (term, string) parser *)
val aspP =
    Parser.map
        (fn x => Asp x)
        (Parser.seq
            Parser.spaces
            (Parser.choice [copyP, signP, hashP, aspcP]))
(* atP, termP :: (term, string) parser *)
fun termP stream =
    Parser.between
        Parser.spaces
        Parser.spaces
        (Parser.choice [
            Parser.between
                (Parser.char #"(")
                (Parser.char #")")
                (Parser.bind
                    termP
                    (fn lterm =>
                        Parser.bind
                            infixOpP
                            (fn infixOp =>
                                Parser.map
                                    (fn rterm =>
                                        infixOp lterm rterm)
                                    termP))),
            atP,
            aspP
        ])
        stream
and atP stream =
    Parser.seq
        (Parser.char #"@")
        (Parser.bind
            (Parser.seq Parser.spaces numeralP)
            (fn pl =>
                Parser.between
                    (Parser.seq Parser.spaces (Parser.char #"["))
                    (Parser.seq (Parser.char #"]") Parser.spaces)
                    (Parser.map
                        (fn term => Att pl term)
                        termP)))
        stream

fun parseTerm str =
    Parser.parse
        (Parser.bind termP (fn term => Parser.return term Parser.eof))
        str

(* Testing *)
(* 
val asps = ["_", " !", "# ", " 1 \"\" ", "2 \"hello\" \"world\""]
val infixes = ["(_ -> !)", " (_ +<+ # )", "( ! - ~ - #) "]
val ats = ["@ 0 [_]", " @ 0 [ # ] "]
val testStrings = List.concat [asps, infixes, ats]
fun testString str =
    case parseTerm str of
      Err msg =>
        print (String.concatWith "\n"
            ["Error parsing string:", str, msg, ""])
    | Ok term => print (String.concatWith "\n" [termToString term, ""])
fun main () =
    List.app testString testStrings
val _ = main ()
*)
