exception Undef
(* () -> 'a *)
fun undefined () = (
    TextIO.print_err "Undefined value encountered";
    raise Undef
)

(* 'b -> ('a -> 'b) 'a option -> 'b *)
fun option b f opt = case opt of 
      Some a => f a 
    | None   => b

(* bool -> (() -> ()) -> () *)
fun when cond io = if cond then io () else ()

(* 'a option -> ('a -> ()) -> () *)
fun whenSome opt io = option () io opt
(* val whenSome = flip (option ())  *)

(* 'a -> 'a list -> 'a list *)
fun intersperse a alist = case alist of
      h1 :: h2 :: t => h1 :: a :: (intersperse a (h2 :: t))
    | _ => alist
