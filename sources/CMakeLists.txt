cmake_minimum_required(VERSION 2.6)

enable_language(C)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
find_package(Kbuild)
include(kbuild_system)

include(kmodule)
# See conventions
set(KEDR_INSTALL_PREFIX_LIB "lib")
set(KEDR_INSTALL_PREFIX_INCLUDE "include/kedr")
#set(KEDR_INSTALL_PREFIX_KINCLUDE "include/kedr")
set(KEDR_INSTALL_PREFIX_KMODULE "lib/modules/${KBUILD_VERSION_STRING}/misc")
set(KEDR_INSTALL_PREFIX_KSYMVERS "lib/modules/${KBUILD_VERSION_STRING}/symvers")

#kedr_install_library(library_name)
function(kedr_install_library library_name)
	install(TARGETS ${library_name} LIBRARY
			DESTINATION ${KEDR_INSTALL_PREFIX_LIB})
endfunction(kedr_install_library library_name)
#kedr_install_headers(install_subdir header_file [..])
function(kedr_install_headers install_subdir)
	install(FILES ${header_file} ${ARGN}
			DESTINATION ${KEDR_INSTALL_PREFIX_INCLUDE}/${install_subdir})
endfunction(kedr_install_headers install_subdir)
#kedr_install_kmodule(kmodule_name)
function(kedr_install_kmodule kmodule_name)
	install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${kmodule_name}.ko"
			DESTINATION "${KEDR_INSTALL_PREFIX_KMODULE}")
endfunction(kedr_install_kmodule kmodule_name)
#kedr_install_symvers(kmodule_name)
function(kedr_install_symvers kmodule_name)
	install(FILES "${CMAKE_CURRENT_BINARY_DIR}/Module.symvers"
			DESTINATION "${KEDR_INSTALL_PREFIX_KSYMVERS}"
			RENAME "${kmodule_name}.symvers")
endfunction(kedr_install_symvers kmodule_name)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY)

add_custom_target(uninstall
  "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

#${CMAKE_SOURCE_DIR} - root of the include tree(common and internal).
include_directories(${CMAKE_SOURCE_DIR})
kbuild_include_directories(${CMAKE_SOURCE_DIR})

add_subdirectory(controller)
add_subdirectory(module_weak_ref)
add_subdirectory(syscall_connector)
add_subdirectory(fault_simulation)
add_subdirectory(kedr)

add_subdirectory(mist_gen)
add_subdirectory(payloads_callm)