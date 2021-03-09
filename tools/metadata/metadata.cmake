#[[
This script generates and example of metadata that could be used for generating a CMSIS pack. The
metadata in this example includes dependencies on other repositories, files required to build the
library, and include paths that must be added to the include path.

To run the script:
1. cd to the root directory of the repository
2. Create a build directory (e.g. "mkdir build")
3. cd to the build directory
4. run "cmake -P ../tools/metadata/metadata.cmake"

This will generate a file called "manifest.yml" in the build directory.

This script does the following steps to create this file:
1. Include the otaFilePaths.cmake file that contains variables containing information on what files
   and include paths are required for building.
2. Create a copy of the manifest.yml file that exists in the root of the library repository.
3. Append the source files and include paths to the copy of the manifest.yml file.

Notes: 
       1) This script does not include information for optional ports and dependencies such as the
       FreeRTOS port. Adding these items would be the same process that is shown below.
       2) This example script is hosted in this repository, but this process could be done by a
       cmake file that is external to this repository if the file paths are changed.
]]

cmake_minimum_required(VERSION 3.13)

# Add the variables that exist in otaFilePaths.cmake to this scope.
# These variables contain the list of files that are needed to build this library.
get_filename_component(REPO_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
include( ${REPO_ROOT_DIR}/otaFilePaths.cmake )

# Copy the manifest file so that we can append to it. We could have opened a new file, but it's
# likely that we will need the other information that exists in the manifest anyways.
file(COPY "${REPO_ROOT_DIR}/manifest.yml" DESTINATION ${CMAKE_BINARY_DIR})

set(METADATA_FILE "${CMAKE_BINARY_DIR}/manifest.yml")

# Add the source files to the manifest.yml file
file( APPEND ${METADATA_FILE} "library_sources:" )
foreach( FILE IN LISTS OTA_CORE_LIBRARY_FILES)
    # Remove the local section of the path.
    string(REPLACE "${REPO_ROOT_DIR}" "" FILE ${FILE} )
    # Write the remaining relative path to the manifest.
    file( APPEND ${METADATA_FILE} "\n  - \"${FILE}\"" )
endforeach()

# Add the public include paths to the manifest.yml file
file( APPEND ${METADATA_FILE} "\npublic_include_paths:" )
foreach( INCLUDE_DIR IN LISTS OTA_INCLUDE_PUBLIC_DIRS)
    # Remove the local section of the path.
    string(REPLACE "${REPO_ROOT_DIR}" "" INCLUDE_DIR ${INCLUDE_DIR} )
    # Write the remaining relative path to the manifest.
    file( APPEND ${METADATA_FILE} "\n  - \"${INCLUDE_DIR}\"" )
endforeach()

# Add the private include paths to the manifest.yml file
file( APPEND ${METADATA_FILE} "\nprivate_include_paths:" )
foreach( INCLUDE_DIR IN LISTS OTA_INCLUDE_PRIVATE_DIRS)
    # Remove the local section of the path.
    string(REPLACE "${REPO_ROOT_DIR}" "" INCLUDE_DIR ${INCLUDE_DIR} )
    # Write the remaining relative path to the manifest.
    file( APPEND ${METADATA_FILE} "\n  - \"${INCLUDE_DIR}\"" )
endforeach()

# Add a newline at the end of the file
file( APPEND ${METADATA_FILE} "\n" )
