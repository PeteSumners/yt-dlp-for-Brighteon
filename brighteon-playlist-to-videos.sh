#!/bin/bash
playlisturl=$1
playlisthtml=`wget -q -O- "$playlisturl"`
videolinks=(`echo $playlisthtml | sed 's/>/>\n/g' | grep index | grep playlist-table | awk '{print $3}' | cut -c 7- | rev | cut -c 3- | rev | sed 's/^/https\:\/\/www.brighteon.com/'`)

# explanation: sed command adds newlines to the end of each html tag, grep looks for the playlist's video tags
# awk/rev/cut converts the html tags into partial URLs
# the final sed command inserts brighteon's base URL to each of the partial video URLs: now you've got a bunch of brighteon video URLs. 
# the parentheses convert the list of links into an actual bash list


# now get playlist's title to save video files into their own playlist folder
playlisttitle=`echo $playlisthtml | sed 's/>/>\n/g' | grep "playlist-title" -A 1 | grep "/div" | rev | cut -c 7- | rev`
echo "PLAYLIST TITLE: $playlisttitle"



# now download the videos
mkdir "$playlisttitle"
cd "$playlisttitle"

i=1;
videocount=${#videolinks[@]}
while [ $i -le $videocount ]
do
    link=${videolinks[i-1]}
    linkhtml=`wget -q -O- "$link"`
    videotitle=`echo $linkhtml | sed 's/>/>\n/g' | grep "og:title" | awk -F 'content=' '{print $2}' | cut -c 2- | rev | cut -c 4- | rev | sed 's/&quot;/\"/g' | sed 's/&amp;/\&/g' | sed 's/&gt;/>/g' | sed 's/&lt;/</g'` # (bunch of html processing)
    echo -e "Downloading video \033[0;32m$i\033[0m of \033[0;34m$videocount\033[0m..." # pretty colors
    echo "VIDEO TITLE: $videotitle"
    yt-dlp -o "$videotitle" $link # download!
    ((i++));
done
