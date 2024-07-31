cmake_minimum_required(VERSION 3.10.2)



get_files(manGen_src
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
  ../../stubs/Params_Admits.sml
  ../../extracted/Term_Defs.cml
  ../../extracted/ErrorStMonad_Coq.cml
  ../../stubs/Manifest_Admits.sml
  ../../extracted/Manifest_Set.cml
  ../../extracted/Manifest.cml
  ../../extracted/Interface_Strings_Vars.cml
  ../../extracted/Attestation_Session.cml
  ../../extracted/Anno_Term_Defs.cml
  ../../extracted/Interface_Types.cml
  ../../extracted/Interface_JSON.cml
  ../../extracted/Cvm_St.cml
  ../../extracted/AM_Manager.cml
  ../../stubs/Axioms_Io.sml
  ../../extracted/Evidence_Bundlers.cml
  ../../extracted/EnvironmentM.cml
  ../../extracted/Manifest_Union.cml
  ../../extracted/Manifest_Generator.cml
  ../../extracted/Manifest_Generator_Union.cml
  manifest_generator.sml)

build_posix_am("manifest_generator" ${manGen_src})
