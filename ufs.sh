#!/bin/sh
echo "Scatter XML to Fastboot by RiProG-ID"
printf "Enter firmware location: "
read -r input
echo ""
scatter=$(find "$input" -maxdepth 1 -type f -name '*.xml')
if [ -z "$scatter" ]; then
  echo "Warning: Scatter XML not found."
  exit 1
fi
scatterdir=$(dirname "$scatter")
header='#!/bin/sh
echo "RiProG Flashtool"'
echo "$header" > "$scatterdir/flash_all.sh"
echo "$header" > "$scatterdir/flash_all_except_data_storage.sh"
while IFS= read -r line || [ -n "$line" ]; do
  if echo "$line" | grep -q '<partition_index'; then
    partition_index=$(echo "$line" | grep -o 'name="[^"]*"' | cut -d '"' -f 2)
  fi
  if echo "$line" | grep -q '<partition_name>'; then
    partition_name=$(echo "$line" | sed -n 's/.*<partition_name>\(.*\)<\/partition_name>.*/\1/p')
  fi
  if echo "$line" | grep -q '<file_name>'; then
    file_name=$(echo "$line" | sed -n 's/.*<file_name>\(.*\)<\/file_name>.*/\1/p')
  fi
  if echo "$line" | grep -q '<is_download>'; then
    is_download=$(echo "$line" | sed -n 's/.*<is_download>\(.*\)<\/is_download>.*/\1/p')
  fi
  if echo "$line" | grep -q '<is_upgradable>'; then
    is_upgradable=$(echo "$line" | sed -n 's/.*<is_upgradable>\(.*\)<\/is_upgradable>.*/\1/p')
  fi
  if [ -n "$partition_index" ] && [ -n "$partition_name" ] && [ -n "$file_name" ] && [ -n "$is_download" ]; then
    if [ "$is_download" = "true" ]; then
      echo "Processing $partition_index"
      echo "fastboot flash $partition_name $file_name" >> "$scatterdir/flash_all.sh"
      if [ "$is_upgradable" = "true" ]; then
        echo "fastboot flash $partition_name $file_name" >> "$scatterdir/flash_all_except_data_storage.sh"
      fi
    else
      echo "Skipping $partition_index"
    fi
    partition_index=""
    partition_name=""
    file_name=""
    is_download=""
    is_upgradable=""
  fi
done < "$scatter"
grep -q '<partition_name>metadata</partition_name>' "$scatter" && echo "fastboot erase metadata" >> "$scatterdir/flash_all.sh"
grep -q '<partition_name>md_udc</partition_name>' "$scatter" && echo "fastboot erase md_udc" >> "$scatterdir/flash_all.sh"
grep -q -e '<partition_name>boot_a</partition_name>' -e '<partition_name>boot_b</partition_name>' "$scatter" && {
  echo "fastboot --set-active=a" >> "$scatterdir/flash_all.sh"
  echo "fastboot --set-active=a" >> "$scatterdir/flash_all_except_data_storage.sh"
}
footer='fastboot oem cdms
fastboot reboot
echo "Done"'
echo "$footer" >> "$scatterdir/flash_all.sh"
echo "$footer" >> "$scatterdir/flash_all_except_data_storage.sh"
echo ""
echo "Done"
echo "Check firmware directory to see output"
echo ""
