FILE(REMOVE_RECURSE
  "CMakeFiles/GenerateVersion"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/GenerateVersion.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
