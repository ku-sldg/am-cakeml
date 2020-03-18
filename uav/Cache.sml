(* Cache clear policy: Should be random, but we don't want to use interupts.
How about, each time the cache is polled we check the current time, find
diff from last clear, and make decision accordingly. *)

structure Cache = struct
    local
        (* Perhaps type should couple mutable list with a timing policy and
           metadata *)
        datatype ('k,'v) cache = Cache ((('k * 'v) list) ref)
        fun getCache c = case c of Cache r => r
    in
        (* Exports type but not constructor. *)
        type ('k, 'v) cache = ('k, 'v) cache

        (* new : () -> ('k,'v) cache *)
        (* Provides a _unique_ reference on every invocation *)
        fun new () = Cache (Ref [])

        (* clear : ('k,'v) cache -> ('k,'v) cache *)
        fun clear c = (getCache c) := []

        (* lookup : ('k,'v) cache -> option *)
        (* TODO: add time check *)
        fun lookup c k = Alist.lookup (!(getCache c)) k

        (* update : ('k,'v) cache -> 'k * 'v -> () *)
        fun update c (k,v) =
            let val r = getCache c
             in r := Alist.update (!r) (k,v)
            end
    end
end
