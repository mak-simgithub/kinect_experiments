#!/bin/bash

# Default input file
input_file=${1:-videos.txt}

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file not found!"
    exit 1
fi

# Read each line from the text file and download the video if not already present
while IFS= read -r url; do
    # Get video title and escape special characters
    title=$(yt-dlp --get-title "$url" | sed 's/[^a-zA-Z0-9]/_/g')
    output_file="${title}.mp4"
    if [ ! -f "$output_file" ]; then
        # Download the video with FullHD resolution, preferring MP4 format
        yt-dlp -f "bestvideo[ext=mp4][height<=1080]/bestvideo[height<=1080]" -o "%(title)s.%(ext)s" "$url" --merge-output-format mp4 -k

        # Get the actual file name of the downloaded video
        downloaded_file=$(yt-dlp --get-filename -o "%(title)s.%(ext)s" "$url")
        ext="${downloaded_file##*.}"

        # Convert to MP4 if not already in MP4 format
        if [ "$ext" != "mp4" ]; then
            ffmpeg -i "$downloaded_file" -c:v copy "$output_file"
            rm "$downloaded_file"  # Remove the original file
        fi
    else
        echo "${output_file} already exists, skipping download."
    fi
done < "$input_file"
