
# Attempt to find gengetopt. If not found, compile it.
FIND_PROGRAM(GENGETOPT gengetopt)
IF ((GENGETOPT STREQUAL "GENGETOPT-NOTFOUND") OR (GENGETOPT STREQUAL ""))
DD(GENGETOPT)
  GET_FILENAME_COMPONENT(CLITK_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
  ADD_SUBDIRECTORY(${CLITK_CMAKE_DIR}/../utilities/gengetopt ${CMAKE_CURRENT_BINARY_DIR}/gengetopt)
ELSE()
  ADD_EXECUTABLE(gengetopt IMPORTED)
  SET_PROPERTY(TARGET gengetopt PROPERTY IMPORTED_LOCATION ${GENGETOPT})
ENDIF()

MACRO (WRAP_GGO GGO_SRCS)
  FOREACH(GGO_FILE ${ARGN})
    GET_FILENAME_COMPONENT(GGO_BASEFILENAME ${GGO_FILE} NAME_WE)
    GET_FILENAME_COMPONENT(GGO_FILE_ABS ${GGO_FILE} ABSOLUTE)
    SET(GGO_H ${GGO_BASEFILENAME}_ggo.h)
    SET(GGO_C ${GGO_BASEFILENAME}_ggo.c)
    SET(GGO_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${GGO_H} ${CMAKE_CURRENT_BINARY_DIR}/${GGO_C})
    ADD_CUSTOM_COMMAND(OUTPUT ${GGO_OUTPUT}
                       COMMAND gengetopt
                       ARGS < ${GGO_FILE_ABS}
                              --output-dir=${CMAKE_CURRENT_BINARY_DIR}
                              --arg-struct-name=args_info_${GGO_BASEFILENAME}
                              --func-name=cmdline_parser_${GGO_BASEFILENAME}
                              --file-name=${GGO_BASEFILENAME}_ggo
                              --unamed-opts
                              --conf-parser
                              --include-getopt
                       DEPENDS ${GGO_FILE_ABS}
                      )
    SET(${GGO_SRCS} ${${GGO_SRCS}} ${GGO_OUTPUT})
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})
  ENDFOREACH(GGO_FILE)
  SET_SOURCE_FILES_PROPERTIES(${${GGO_SRCS}} PROPERTIES GENERATED TRUE)
  IF(CMAKE_COMPILER_IS_GNUCXX)
    FIND_PROGRAM(DEFAULT_GCC gcc)
    EXEC_PROGRAM(${DEFAULT_GCC} ARGS "-dumpversion" OUTPUT_VARIABLE GCCVER)
    IF("${GCCVER}" VERSION_GREATER "4.5.2")
      SET_SOURCE_FILES_PROPERTIES(${${GGO_SRCS}} PROPERTIES COMPILE_FLAGS "-Wno-unused-but-set-variable")
    ENDIF("${GCCVER}" VERSION_GREATER "4.5.2")
  ENDIF(CMAKE_COMPILER_IS_GNUCXX)
ENDMACRO (WRAP_GGO)
