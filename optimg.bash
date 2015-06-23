#!/bin/bash

#
# Optimize the images
#
function optimg()
{
    local input_file_size=
    local output_file_size=
    local output
    local percent
    local diff=0
    local width=$( tput cols )
    local pad=$( printf '%*s' "$width" | tr " " "." )

    for img in "$@"; do
        if [ ! -f "$img" ]; then
            continue;
        fi
        
        input_file_size=$(stat -c%s "$img")

        if [ "${img##*.}" = "png" ]; then
            output="PNG-image:  $img "
            optipng -o1 --quiet "$img"
            pngcrush -q "$img" /tmp/$$; mv /tmp/$$ "$img"
        fi

        if [ "${img##*.}" = "jpg" -o "${img##*.}" = "jpeg" ]; then
            output="JPEG-image: $img "
            jpegtran -copy none -optimize -outfile /tmp/$$ "$img"; mv /tmp/$$ "$img"
        fi

        output_file_size=$(stat -c%s "$img")
        diff=$(( diff + input_file_size - output_file_size ))
        percent=$( echo "scale=2; $output_file_size*100/$input_file_size" | bc )

        printf '%s %*.*s %6s\n' "$output" 0 $(( ${#pad} - ${#output} - 8 )) "$pad" "$percent"

    done

    echo "Saved " $(( diff / 1000 )) " kB."
}
