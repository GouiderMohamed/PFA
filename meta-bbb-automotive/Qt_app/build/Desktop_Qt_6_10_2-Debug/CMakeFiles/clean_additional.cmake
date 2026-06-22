# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles/appAutomotiveDashboard_autogen.dir/AutogenUsed.txt"
  "CMakeFiles/appAutomotiveDashboard_autogen.dir/ParseCache.txt"
  "appAutomotiveDashboard_autogen"
  )
endif()
