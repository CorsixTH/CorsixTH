# Copies the required files and folders from the source folder to the destination

# Bitmap folder
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${CMAKE_SOURCE_DIR}/CorsixTH/Bitmap
  $<TARGET_FILE_DIR:CorsixTH>/Bitmap)

# Campaigns Folder
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${CMAKE_SOURCE_DIR}/CorsixTH/Campaigns
  $<TARGET_FILE_DIR:CorsixTH>/Campaigns)

# Levels Folder
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${CMAKE_SOURCE_DIR}/CorsixTH/Levels
  $<TARGET_FILE_DIR:CorsixTH>/Levels)

# Lua Folder
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  ${CMAKE_SOURCE_DIR}/CorsixTH/Lua
  $<TARGET_FILE_DIR:CorsixTH>/Lua)

# CorsixTH.lua
add_custom_command(TARGET CorsixTH POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
  ${CMAKE_SOURCE_DIR}/CorsixTH/CorsixTH.lua
  $<TARGET_FILE_DIR:CorsixTH>/CorsixTH.lua)