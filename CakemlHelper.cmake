set(CAKE_FLAGS CACHE PATH "Flags passed to the CakeML compiler")
string(REGEX REPLACE "[ \t\r\n]+" ";" cakeflag_list "${CAKE_FLAGS}")

# Takes a name and a list of cml source files. Generates an executable target.
# Add additional sources/libs with target_sources/target_link_libraries
function(gen_cakeml name cml_source)
    set(catlist "")
    foreach(source ${cml_source} ${ARGN})
        list(APPEND catlist "${CMAKE_SOURCE_DIR}/${source}")
    endforeach(source)
    cat(${name}.cml ${catlist})

    add_custom_command(
        OUTPUT ${name}.cake.S
        COMMAND ${cakec} ${cakeflag_list} < ${name}.cml > ${name}.cake.S
        DEPENDS ${name}.cml
        VERBATIM
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
