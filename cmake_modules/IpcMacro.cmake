# Macros and functions for build support of Inter-process communication

set(capi-core-gen ${COMMONAPI_PATH}/capicxx-core-tools/org.genivi.commonapi.core.cli.product/target/products/org.genivi.commonapi.core.cli.product/linux/gtk/x86_64/commonapi-generator-linux-x86_64)
set(capi-someip-gen ${COMMONAPI_PATH}/capicxx-someip-tools/org.genivi.commonapi.someip.cli.product/target/products/org.genivi.commonapi.someip.cli.product/linux/gtk/x86_64/commonapi-someip-generator-linux-x86_64)

function(get_interface_path IName IPath)
    string(FIND ${IName} ":" DELIMITER_INDEX)
    string(SUBSTRING ${IName} 0 ${DELIMITER_INDEX} INTERFACE_NAME)
    string(REPLACE "." "/" INTERFACE_PATH ${INTERFACE_NAME})
    set(${IPath} ${INTERFACE_PATH} PARENT_SCOPE)
endfunction(get_interface_path)


function(get_interface_file IName IFile)
    string(FIND ${IName} ":" DELIMITER_INDEX)
    string(SUBSTRING ${IName} 0 ${DELIMITER_INDEX} INTERFACE_NAME)
    string(FIND ${INTERFACE_NAME} "." FDEPL_INDEX REVERSE)
    math(EXPR FILE_INDEX ${FDEPL_INDEX}+1)
    string(SUBSTRING ${INTERFACE_NAME} ${FILE_INDEX} -1 FILE_NAME)
    set(${IFile} ${FILE_NAME} PARENT_SCOPE)
endfunction(get_interface_file)


function(get_interface_version IName IVersion)
    string(FIND ${IName} ":" DELIMITER_INDEX)
    math(EXPR VERSION_INDEX ${DELIMITER_INDEX}+1)
    string(SUBSTRING ${IName} ${VERSION_INDEX} -1 INTERFACE_VERSION)
    set(${IVersion} ${INTERFACE_VERSION} PARENT_SCOPE)
endfunction(get_interface_version)


macro(append_fidl_file Target FileName)
    set(FIDL_LINK ${Target}_FIDL_FILES)
    list(APPEND ${FIDL_LINK}
        ${FIDL_PATH}/${FileName}.fidl
    )
endmacro(append_fidl_file)


macro(append_fdepl_file Target FileName)
    set(FDEPL_LINK ${Target}_FDEPL_FILES)
    list(APPEND ${FDEPL_LINK}
        ${FIDL_PATH}/${FileName}.fdepl
    )
endmacro(append_fdepl_file)


macro(append_someip_type_collection Target Path Version)
    set(SOURCE_LINK ${Target}_SOURCE_SOMEIP_FILES)
    list(APPEND ${SOURCE__LINK}
        ${CMAKE_CURRENT_BINARY_DIR}/v${Version}/${Path}SomeIPDeployment.cpp
    )
endmacro(append_someip_type_collection)


macro(append_someip_interface Target Path Version)
    set(SOURCE_LINK ${Target}_SOURCE_SOMEIP_FILES)
    list(APPEND ${SOURCE_LINK}
        ${CMAKE_CURRENT_BINARY_DIR}/v${Version}/${Path}SomeIPStubAdapter.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/v${Version}/${Path}SomeIPDeployment.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/v${Version}/${Path}SomeIPProxy.cpp
    )
endmacro(append_someip_interface)


# Type is formated string:
# <name>[.<name>...]:<major_version>
# For example: ford.rnd.types.VR:1

macro(add_someip_types Target Type...)
    set(Types ${ARGV})
    list(REMOVE_AT Types 0)
    message(STATUS "Configure collections of types for SOME/IP - [ ${Types} ]")
    foreach(iface ${Types})
        get_interface_path(${iface} INTERFACE_PATH)
        get_interface_version(${iface} INTERFACE_VERSION)
        append_someip_type_collection(${Target} ${INTERFACE_PATH} ${INTERFACE_VERSION})
        get_interface_file(${iface} FILE_NAME)
        append_fidl_file(${Target} ${FILE_NAME})
        append_fdepl_file(${Target} ${FILE_NAME})
    endforeach(iface)
endmacro(add_someip_types)


# Interface is formated string:
# <name>[.<name>...]:<major_version>
# For example: ford.rnd.VR:1

macro(add_someip_interfaces Target Interface...)
    set(Interfaces ${ARGV})
    list(REMOVE_AT Interfaces 0)
    message(STATUS "Configure interfaces for SOME/IP - [ ${Interfaces} ]")
    foreach(iface ${Interfaces})
        get_interface_path(${iface} INTERFACE_PATH)
        get_interface_version(${iface} INTERFACE_VERSION)
        append_someip_interface(${Target} ${INTERFACE_PATH} ${INTERFACE_VERSION})
        get_interface_file(${iface} FILE_NAME)
        append_fidl_file(${Target} ${FILE_NAME})
        append_fdepl_file(${Target} ${FILE_NAME})
    endforeach(iface)
endmacro(add_someip_interfaces)


macro(add_someip_library Target)
    set(SOURCE_LINK ${Target}_SOURCE_SOMEIP_FILES)
    set(FIDL_LINK ${Target}_FIDL_FILES)
    set(FDEPL_LINK ${Target}_FDEPL_FILES)
    add_custom_command(OUTPUT ${${SOURCE_LINK}}
        COMMAND ${capi-core-gen} --printfiles
            --dest ${CMAKE_CURRENT_BINARY_DIR} ${${FIDL_LINK}}
        COMMAND ${capi-someip-gen} --printfiles
            --dest ${CMAKE_CURRENT_BINARY_DIR} ${${FDEPL_LINK}}
        DEPENDS ${${FIDL_LINK}} ${${FDEPL_LINK}}
        COMMENT "Generate source files for ${Target} (SOME/IP) library"
    )
    add_library(${Target} SHARED ${${SOURCE_LINK}})
    target_link_libraries(${Target} CommonAPI-SomeIP)
    install(TARGETS ${Target}
        LIBRARY DESTINATION ${CMAKE_BINARY_DIR}/build/lib
        PERMISSIONS OWNER_READ OWNER_WRITE
    )
    message(STATUS "Configure ${Target} (SOME/IP) library")
endmacro(add_someip_library)


macro(append_capi_interface Target Path Version)
    set(SOURCE_LINK ${Target}_SOURCE_CAPI_FILES)
    list(APPEND ${SOURCE_LINK}
        ${CMAKE_CURRENT_BINARY_DIR}/v${Version}/${Path}StubDefault.cpp
    )
endmacro(append_capi_interface)


# Type is formated string:
# <name>[.<name>...]:<major_version>
# For example: ford.rnd.types.VR:1

macro(add_capi_types Target Type...)
    set(Types ${ARGV})
    list(REMOVE_AT Types 0)
    message(STATUS "Configure collections of types for CommonAPI - [ ${Types} ]")
    foreach(iface ${Types})
        get_interface_path(${iface} INTERFACE_PATH)
        get_interface_version(${iface} INTERFACE_VERSION)
        get_interface_file(${iface} FILE_NAME)
        append_fidl_file(${Target} ${FILE_NAME})
    endforeach(iface)
endmacro(add_capi_types)


# Interface is formated string:
# <name>[.<name>...]:<major_version>
# For example: ford.rnd.VR:1

macro(add_capi_interfaces Target Interface...)
    set(Interfaces ${ARGV})
    list(REMOVE_AT Interfaces 0)
    message(STATUS "Configure interfaces for CommonAPI - [ ${Interfaces} ]")
    foreach(iface ${Interfaces})
        get_interface_path(${iface} INTERFACE_PATH)
        get_interface_version(${iface} INTERFACE_VERSION)
        append_capi_interface(${Target} ${INTERFACE_PATH} ${INTERFACE_VERSION})
        get_interface_file(${iface} FILE_NAME)
        append_fidl_file(${Target} ${FILE_NAME})
    endforeach(iface)
endmacro(add_capi_interfaces)


macro(add_capi_library Target)
    find_package(CommonAPI 3.1.10 REQUIRED)
    include_directories(
        ${CMAKE_CURRENT_BINARY_DIR}
        ${COMMONAPI_INCLUDE_DIRS}
    )
    set(SOURCE_LINK ${Target}_SOURCE_CAPI_FILES)
    set(FIDL_LINK ${Target}_FIDL_FILES)
    add_custom_command(OUTPUT ${${SOURCE_LINK}}
        COMMAND ${capi-core-gen} --printfiles --skel
            --dest ${CMAKE_CURRENT_BINARY_DIR} ${${FIDL_LINK}}
        DEPENDS ${${FIDL_LINK}}
        COMMENT "Generate source files for ${Target} (CommonAPI) library"
    )
    add_library(${Target} ${${SOURCE_LINK}})
    message(STATUS "Configure ${Target} (CommonAPI) library")
endmacro(add_capi_library)