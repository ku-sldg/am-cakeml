# A REPL for Copland prototyping

## Build
Build with `make repl`. This will create an executable called `repl` in the `apps/repl` subdirectory of the build directory.

## Run
Launch the executable, passing the full filepath to a configuration (e.g. `example.ini` in this directory). This drops you into a REPL.
You can execute arbitrary concrete Copland phrases, which are executed with respect to an empty initial evidence value.

We use the following grammar:
```
term    ::= '(' term ')'
          | asp
          | term '->' term 
          | term sp '<' sp term
          | term sp '~' sp term
          | '@' NUMERAL '[' term ']'
sp      ::= '+' | '-'
asp     ::= NUMERAL STRING*
          | '_' | '!' | '#'
NUMERAL ::= [0-9]+
STRING  ::= '"' [^"] '"'
```