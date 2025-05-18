#!/bin/bash

PORT="${PORT:-8080}"
AUTOR="HUBERT KISZKA"
echo "% $(date) -- $AUTOR -- $PORT %"
if [ -z "$KEY" ]; then
  echo "PLEASE PROVIDE API KEY" >&2
  exit 1
fi
while true; do
    coproc nc -l -p "$PORT"
    read -r line <&${COPROC[0]}
    CITY_VAL=$(echo $line | awk '{print substr($2, 2)}')
    URL="http://api.weatherapi.com/v1/current.json?key=$KEY&q=$CITY_VAL&aqi=no"
    while read -r header && [ "$header" != $'\r' ] && [ "$header" != "" ]; do
        true
    done <&${COPROC[0]}
    response=$(wget -q -O - "$URL")
    IFS=":" read -ra tab <<< "$response"
    for ((i=0; i<${#tab[@]}; i++)); do
        line="${tab[$i]}"
        if [ "$(echo "$line" | awk '/temp_c/')" ]; then
            ((i++))
            IFS="," read -ra vals <<< "${tab[$i]}"
            temp="${vals[0]}"
        fi
        if [ "$(echo "$line" | awk '/humidity/')" ]; then
            ((i++))
            IFS="," read -ra vals <<< "${tab[$i]}"
            humidity="${vals[0]}"
        fi
    done
    
    cat <<EOF >&${COPROC[1]}
HTTP/1.1 200 OK
Content-Type: text/plain
Connection: close

Wilgotność $humidity temperatura $temp
EOF
    exec {COPROC[0]}>&- {COPROC[1]}>&-
done

