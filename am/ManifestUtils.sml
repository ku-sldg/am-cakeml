(* Depends on: ... TODO *)

(* :: string -> Coq_Manifest -> unit *)
fun outputManifestJsonString fileString manifest =
    let val ostream = TextIO.openOut fileString
        val jsonString = jsonToStr (manifestToJson manifest) in
        TextIO.output ostream jsonString
    end

(* :: string -> Coq_Manifest *)
fun inputManifestJsonString fileString =
    let val istream = TextIO.openIn fileString
        val inString = TextIO.inputAll istream
        (* val _ = print inString *)
        val jsonManifest = strToJson inString
        val res = jsonToManifest jsonManifest
        (* val _ = print "\nIn inputManifestJsonString\n" *) in
        res
    end

(* :: Coq_Manifest -> string *)
fun formalManifestToString manifest =
    case manifest of
        Build_Manifest asps plcs =>
        let val header = "\nManifest: \n  {"
            val aspsStr = "  asps: " ^ (listToString asps aspIdToString) ^ " \n"
            val plcsStr = "     plcs: " ^ (listToString plcs plToString) ^ " \n"
            val footer = "  }\n"
            val res = header ^ aspsStr ^ plcsStr ^ footer
            (*val _ = print "In formalManifestToString" *)
            (*val _ = print res*) in 
            res
        end
      | _ => let val _ =
                     print ("\nError: Did not match Build_Manifest constructor in formalManifestToString\n") in ""
             end

fun build_formalManifest asps plcs =
    Build_Manifest asps plcs

val exampleFormalManifest = build_formalManifest
                                ["asp11", "asp25"]
                                [natFromInt 22, natFromInt 42]

fun outputExampleFormalManifest fileString =
    let val _ = outputManifestJsonString fileString exampleFormalManifest in
        ()
    end

fun inputAndPrintExampleFormalManifest fileString =
    let val manifest = inputManifestJsonString fileString
        val str = formalManifestToString manifest in
        (*print "hi" ; *)
        print str
    end
fun build_concreteManifest myAddress defaultSigAsp aspList plcList pubList =
    ManifestC myAddress
              defaultSigAsp
              (Map.fromList String.compare aspList)
              (Map.fromList nat_compare plcList)
              (Map.fromList nat_compare pubList)

val example_demo_server_manifest =
    build_concreteManifest
        "5000"
        ssl_sig_aspid
        []
        [((natFromInt 0), "5000"), ((natFromInt 2),"5002")]
        []

val example_demo_client_manifest =
    build_concreteManifest
        ""
        ssl_sig_aspid
        []
        [((natFromInt 0), "5000"), ((natFromInt 2),"5002")]
        []
