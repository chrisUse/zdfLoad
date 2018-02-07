#!/bin/bash
#
baseURL=""
outputFile=""
if [ "$1" != "" ] && [ "$2" != "" ]; then
  baseURL="$1"
  outputFile="$2"
else
  echo "Usage: $0 ZDFFilmUrl OutputFileName"
  exit 1
fi

wget -v "$baseURL" -O film.html
apiToken=$(grep -A13 -e "data-zdfplayer-jsb" film.html | grep -e "apiToken" | sed "s/.*apiToken\": \"\(.*\)\".*/\1/")
nextUrl=$(grep -e "\.json" film.html | grep "profile=player" | sed "s/.*content\": \"\(.*\)\".*/\1/")

echo "$apiToken - $nextUrl"
wget -v --header="Api-Auth:Bearer $apiToken" "$nextUrl" -O film.json
nextUrl=$(sed "s/.*ptmd\":\"\([^\"]*\)\".*/\1/" film.json | sed "s/\\\//g")

echo "https://api.zdf.de$nextUrl"
wget -v --header="Api-Auth:Bearer $apiToken" "https://api.zdf.de$nextUrl" -O apiTex.html
filmURL=$(grep "\.mp4" apiTex.html | grep "14" | tail -n1 | sed "s/.*uri\" : \"\(.*\)\".*/\1/")

wget "$filmURL" -O "$outputFile"
#
rm film.json
rm apiTex.html
rm film.html
