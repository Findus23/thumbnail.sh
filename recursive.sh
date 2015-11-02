#!/bin/bash

exec 3> >(zenity --progress --title="generating thumbnails..." --percentage=0 --width=400 --no-cancel )
echo "# searching for files..." >&3
files=$(find . -name '*.webm')
echo "$(tput setaf 2)The following files werde found:$(tput sgr0)"
echo "$files"
echo "----"
num_files=$(echo "$files"| wc -l)
a=1
find . -name '*.webm' -print0 | while read -d $'\0' file # http://stackoverflow.com/a/15931055
do
    echo "$(tput setaf 2)$file$(tput sgr0)"
	echo "# $file ($a/$num_files)" >&3;
    ./thumbnail.sh "$file" best
	echo "$a/$num_files*100" | bc -l >&3 #percentage
	((a++))
done

echo "# finished generating thumbnails" >&3
notify-send "Thumbnails" "finished" #im Paket libnotify-bin
