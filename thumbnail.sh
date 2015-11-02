#!/bin/bash
inputfile=$1
mode=$2
setting=$3
tile=$4

if [ ! -f "$inputfile" ]
then
    echo "$(tput setaf 1)no input file$(tput sgr0)"
    exit 1
fi
outputfile=${inputfile%.*}.jpg # without file type
if [ -z "$tile" ]
then
    tile="3x3"
fi

if [ "$mode" == "best" ]
then
    if [ -z "$setting" ] || (( $setting < 50 ))
    then
        setting="800"
        echo "$(tput setaf 2)using default number of frames to analyse: $(tput setaf 3)$setting$(tput sgr0)"
    fi
     < /dev/null ffmpeg -y -i $inputfile -vsync 0 -vf  "thumbnail=$setting,tile=$tile" -frames:v 1 $outputfile

elif [ "$mode" == "fast" ]
then
    if [ -z "$setting" ] || (( $setting < 1 ))
    then
        setting="120" #min seconds between keyframes
        echo "$(tput setaf 2)using default seconds between keyframes: $(tput setaf 3)$setting$(tput sgr0)"
    fi
     < /dev/null ffmpeg -y -i $inputfile -vsync 0 -vf select="eq(pict_type\,I)*(isnan(prev_selected_t)+gte(t-prev_selected_t\,$setting))",tile=$tile -frames:v 1  $outputfile
elif [ "$mode" == "equal" ]
then
    if [ -z "$setting" ] || (( $setting < 1 ))
        then
        setting="600" #seconds of video to look at
        echo "$(tput setaf 2)only looking at the first $(tput setaf 3)$setting$(tput setaf 2) seconds.$(tput sgr0)"
    fi
    duration=$(ffprobe -i $inputfile -show_format -v quiet | sed -n 's/duration=//p')
    if [ "$setting" -gt "${duration%.*}" ]
    then
        echo "$(tput setaf 1)video is shorter than $setting seconds$(tput sgr0)"
        exit 1
    fi
    frames=$((${tile/"x"/"*"})) # 3x3 -> 3*3
    sec_between=$(python3 -c "print($setting/$frames)")
    echo $sec_between
     < /dev/null ffmpeg -y -i $inputfile -vsync 0 -vf  "fps=1/$sec_between,tile=$tile" -frames:v 1 $outputfile
# alternativ: select every x frame https://ffmpeg.org/ffmpeg-filters.html#select_002c-aselect
else

    echo "$(tput setaf 1)invalid mode$(tput sgr0)"
    echo "use \"best\", \"equal\" or \"fast\""
    exit 1
fi
