cmake_minimum_required(VERSION 3.10.2)




get_files(termToJson_src 
  ${server_am_src}
  term_to_json.sml)
build_posix_am("term_to_json" ${termToJson_src})
