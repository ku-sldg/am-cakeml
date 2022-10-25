(* Depends on: (TODO: dependencies?) *)
fun iniPubkeyMap m =
    MapExtra.mapPartial nat_compare
                        (fn k => fn v =>
                            case String.tokens ((op =) #".") k of
                                ["place", ident, "publicKey"] => 
                                Option.map (fn x => (x, (BString.unshow v)))
                                           (Result.toOption (Parser.parse numeralP ident))
                              | _ => None
                        ) m

        
fun get_ini_pubkey ini p =
    let val pubkey_map = iniPubkeyMap ini
        val res =
            case Map.lookup pubkey_map p of
                Some a => a
              | None =>
                let val _ = print ("Place "^ plToString p ^" not in ini pubkey map") in
                    BString.empty
                end in
        res
    end
