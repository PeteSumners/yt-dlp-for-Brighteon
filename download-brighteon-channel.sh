#!/bin/bash
# given a brighteon channel's base URL, parses/downloads all the videos in it
# TODO: refactor sed commands (try doing some of them right after getting html pages)
# TODO: remove duplicates? (may not be necessary)
# TODO: ALL the html codes
channelurl=$1

# html postprocessing command to replace &codes
htmlprocessing="sed 's/&quot;/\\\"/g' | sed \"s/&#x27;/'/g\" | sed 's/&amp;/\\&/g' | sed 's/&gt;/>/g' | sed 's/&lt;/</g'"

i=1;
nextbutton=1; # number of "Next" buttons found on current videos page
while [ $nextbutton -ge 1 ]
do
    currenturl="$channelurl/videos?page=$i"
    echo "DOWNLOADING PAGE $i..."
    currenthtml=`wget -q -O- "$currenturl"`
    videolinks=(`echo $currenthtml | sed 's/>/>\n/g' | grep -A 1 '<div class="title">' | grep href | cut -c 10- | rev | cut -c 3- | rev | sed 's/^/https\:\/\/www.brighteon.com/'`)
    nextbutton=`echo $currenthtml | grep "Next</button>" | wc -l`
    
    j=1;
    videocount=${#videolinks[@]}
    while [ $j -le $videocount ]
    do
        link=${videolinks[j-1]}
        linkhtml=`wget -q -O- "$link"`
        videotitle=`echo $linkhtml | sed 's/>/>\n/g' | grep "og:title" | awk -F 'content=' '{print $2}' | cut -c 2- | rev | cut -c 4- | rev | eval $htmlprocessing`
        echo -e "Downloading video \033[0;32m$j\033[0m of \033[0;34m$videocount\033[0m..." # pretty colors
        echo "VIDEO TITLE: $videotitle"
        yt-dlp -q --write-description -o "$videotitle" $link # download!
        ((j++));
    done
    ((i++))
done
