#!/bin/bash

for file in "$@"
do
  awk '{\
  gsub("<script language=JavaScript src=\"../javascript/prettify.js\"><\/script>", "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" \/>");\
  gsub(" onLoad=\"NDOnLoad\\(\\);prettyPrint\\(\\);\"", "");\
  print}' "$file" > tmp && mv tmp "$file"
done
