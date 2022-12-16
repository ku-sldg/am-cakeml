(* Depends on: ... TODO *)

type aspMap = ((coq_ASP_ID, addr) map)

type plcMap = nsMap (* :: ((coq_Plc, addr) map) -- Defined in am/CommTypes.sml *)

type pubkeyMap = ((coq_Plc, string) map)


(* Params:
     - (me::addr):  An address string encoding how to contact current AM
     - (sigAsp::coq_ASP_ID):  ASP ID to manage signing (default for the SIG Copland phrase)
     - (aspMap::(coq_ASP_ID, addr) map):  Mapping of ASP_ID to its implementation address.
         If and ASP_ID is mentioned in a phrase but not present in this mapping, it should be 
         "locally invokable" directly by the AM source code.
     - (plcMap::(coq_Plc, addr) map):  Mapping of Place to external AM address.  Used to contact 
         other AMs for Copland remote attestation requests.
     - (pubkeyMap::(coq_Plc, string) map):  Mapping of Place to string (hex) encoding of 
         public keys used for encrypting Copland evidence.    *)

datatype concreteManifest = ManifestC addr coq_ASP_ID aspMap plcMap pubkeyMap

(* :: string -> Coq_Manifest -> unit *)
fun outputManifestJsonString fileString manifest =
    let val ostream = TextIO.openOut fileString
        val jsonString = jsonToStr (manifestToJson manifest) in
        TextIO.output ostream jsonString
    end

fun build_formalManifest asps plcs =
    Build_Manifest asps plcs

val exampleFormalManifest = build_formalManifest
                                ["asp1", "asp2"]
                                [natFromInt 22, natFromInt 42]

fun outputExampleFormalManifest () =
    let val _ = outputManifestJsonString "manifest.out" exampleFormalManifest in
        ()
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
