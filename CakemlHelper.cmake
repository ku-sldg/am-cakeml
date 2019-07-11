# Takes a name and a list of cml source files. Generates an executable target.
# Add additional sources/libs with target_sources/target_link_libraries
function(gen_cakeml name cml_source)
    cat(${name}.cml ${cml_source} ${ARGN})
    add_custom_command(
        OUTPUT ${name}.cake.S
        COMMAND ${cakec} ${cakeflags} < ${name}.cml > ${name}.cake.S
        DEPENDS ${name}.cml
    )
    add_executable(${name} ${name}.cake.S)
endfunction(gen_cakeml)


function(cat name file)
    add_custom_command(
        OUTPUT ${name}
        COMMAND cat ${file} ${ARGN} > ${name}
        DEPENDS ${file} ${ARGN}
    )
    set_source_files_properties(${name} PROPERTIES GENERATED TRUE)
endfunction(cat)
