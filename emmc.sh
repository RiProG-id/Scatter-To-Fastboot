#!/bin/sh
echo "Scatter To Fastboot by RiProG-ID"
printf "Enter firmware location: "
read -r input
echo ""
scatter=$(find "$input" -maxdepth 1 -type f -name '*scatter*.txt')
if [ -z "$scatter" ]; then
	echo "Warning: Scatter.txt not found."
	exit 1
fi
scatterdir=$(dirname "$scatter")
dummy1='#!/bin/sh
echo "RiProG Flashtool"'
echo "$dummy1" >"$scatterdir"/flash_all.sh
echo "$dummy1" >"$scatterdir"/flash_all_except_data_storage.sh
while IFS= read -r line || [ -n "$line" ]; do
	if [ -n "$partition_index" ] && [ -n "$partition_name" ] && [ -n "$file_name" ] && [ -n "$is_download" ] && [ -n "$is_upgradable" ]; then
		if [ "$is_download" = "true" ]; then
			echo "Processing $partition_index"
			echo "fastboot flash $partition_name $file_name" >>"$scatterdir"/flash_all.sh
			if [ "$is_upgradable" = "true" ]; then
				echo "fastboot flash $partition_name $file_name" >>"$scatterdir"/flash_all_except_data_storage.sh
			fi
		else
			echo "Skipping $partition_index"
		fi
		partition_index=""
		partition_name=""
		file_name=""
		is_download=""
		is_upgradable=""
	else
		if echo "$line" | grep -q partition_index; then
			partition_index=$(echo "$line" | awk '{print $3}')
		fi
		if echo "$line" | grep -q partition_name; then
			partition_name=$(echo "$line" | awk '{print $2}')
		fi
		if echo "$line" | grep -q file_name; then
			file_name=$(echo "$line" | awk '{print $2}')
		fi
		if echo "$line" | grep -q is_download; then
			is_download=$(echo "$line" | awk '{print $2}')
		fi
		if echo "$line" | grep -q is_upgradable; then
			is_upgradable=$(echo "$line" | awk '{print $2}')
		fi
	fi
done <"$scatter"
if grep -q metadata "$scatter"; then
	echo "fastboot erase metadata" >>"$scatterdir/flash_all.sh"
fi
if grep -q md_udc "$scatter"; then
	echo "fastboot erase md_udc" >>"$scatterdir/flash_all.sh"
fi
if grep -q -e boot_a -e boot_b "$scatter"; then
	echo "fastboot --set-active=a" >>"$scatterdir/flash_all.sh"
	echo "fastboot --set-active=a" >>"$scatterdir/flash_all_except_data_storage.sh"
fi
dummy2='fastboot oem cdms
fastboot reboot
echo "Done"'
echo "$dummy2" >>"$scatterdir"/flash_all.sh
echo "$dummy2" >>"$scatterdir"/flash_all_except_data_storage.sh
awk '!seen[$0]++' "$scatterdir/flash_all.sh" >"$scatterdir/temp" && mv "$scatterdir/temp" "$scatterdir/flash_all.sh"
awk '!seen[$0]++' "$scatterdir/flash_all_except_data_storage.sh" >"$scatterdir/temp" && mv "$scatterdir/temp" "$scatterdir/flash_all_except_data_storage.sh"
echo ""
echo "Done"
echo "Check firmware diretory to see output"
echo ""
