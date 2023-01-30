#!/bin/bash

lines=200

prefix=pdf2mp3_tmpsplit_
ascii_file_name=_ascii.txt
tmp_dir_prefix=$(dirname $0)/tmp
out_dir_prefix=$(dirname $0)/produced

if [ "$#" == 0 ]; then
        echo "Usage: $0 [-l lines] <pdf file>"
        exit 1
fi

while getopts "l:" option
do
case "$option" in
        l) lines="$OPTARG";;
esac
done

shift $((OPTIND-1))

pdf_file="$1"

file_hash=$(echo "$pdf_file" | md5sum | awk '{print $1}')
echo "Processing $pdf_file under $file_hash"
mkdir -p "$tmp_dir_prefix/$file_hash"
mkdir -p "$out_dir_prefix"

function ascii_to_audio_gtts()
{
        local i="$1"
        echo "Processing $i"
        output=`gtts-cli -f "$i" -l en -o $i.mp3 2>&1`
        local code=$?
        if [ "$code" == "0" ] ; then
                if [ -f "$i.mp3" ] ; then
                        echo "Processing $i was completed succesfully"
                        rm -f "$i"
                else
                        echo "Processing $i failed due to unknown error"
                        rm -f "$i.mp3"
                fi
        else
                echo "Processing $i failed due to: $output"
                rm -f "$i.mp3"
        fi
}

function get_list_of_parts()
{
        ls -1 $tmp_dir_prefix/$file_hash/${prefix}* | grep -E -v "[.]mp3"
}

function ascii_to_audio()
{
        for i in $(get_list_of_parts)
        do
                if [ ! -f "$i.mp3" ] ; then
                        ascii_to_audio_gtts "$i"
                fi
        done
}

function pdf_to_ascii()
{
        local ascii_file=$tmp_dir_prefix/$file_hash/$ascii_file_name
        if [ ! -f ${ascii_file} ] ; then
                echo "Converting $1 to ascii"
                ps2ascii "$1" | tr -s '[:space:]' > ${ascii_file} 
                echo "Splitting text into chunks of $lines lines"
                cat ${ascii_file} | split -l $lines --numeric-suffixes=1 - $tmp_dir_prefix/$file_hash/${prefix}
        fi
}

function combine_audio_chunks()
{
        local in_file="$1"
        rm -f $tmp_dir_prefix/$file_hash/_output.mp3 $tmp_dir_prefix/$file_hash/_output_MP3WRAP.mp3
        local bf=$(basename -s.pdf "$in_file")
        mp3wrap $tmp_dir_prefix/$file_hash/_output.mp3 $tmp_dir_prefix/$file_hash/${prefix}*.mp3
        echo "Producing $out_dir_prefix/${bf}.mp3"
        mv -f $tmp_dir_prefix/$file_hash/_output_MP3WRAP.mp3 "$out_dir_prefix/${bf}.mp3"
}

pdf_to_ascii "$pdf_file"
ascii_to_audio "$pdf_file"

remaining_parts=$(get_list_of_parts | wc -w)
if [ "$remaining_parts" == "0" ] ; then
        echo "Chunk processing complete, combining the parts :"
        combine_audio_chunks "$pdf_file"
        #rm -rf "$tmp_dir_prefix/$file_hash/"
fi

