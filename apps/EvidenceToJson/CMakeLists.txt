cmake_minimum_required(VERSION 3.10.2)

get_files(evidenceToJson_src 
  ${server_am_src}  
  EvidenceToJson.sml)
build_posix_am("evidence_to_json" ${evidenceToJson_src})
