cmake_minimum_required(VERSION 3.10.2)

get_files(evidenceToJson_src 
  ${util_src}  
  ${extraction_preamble_src}  
  
  ../../extracted/ResultT.cml
  ../../extracted/EqClass.cml
  ../../extracted/Stringifiable.cml
  ../../extracted/ID_Type.cml
  ../../extracted/Maps.cml
  ../../extracted/JSON_Type.cml
  ../../extracted/ErrorStringConstants.cml

  ../../stubs/JSON_Admits.sml
  ../../stubs/Stringifiable_Class_Admits.sml

  ../../extracted/JSON.cml

  ../../stubs/BS.sml

  ../../extracted/Term_Defs_Core.cml
  ../../extracted/JSON_Core.cml

  ../../stubs/Params_Admits.sml

  ../../extracted/Term_Defs.cml
  ../../extracted/Flexible_Mechanisms_Vars.cml
  ../../extracted/Flexible_Mechanisms.cml
  evidence_to_json.sml)
build_posix_am("evidence_to_json" ${evidenceToJson_src})
