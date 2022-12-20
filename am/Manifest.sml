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
