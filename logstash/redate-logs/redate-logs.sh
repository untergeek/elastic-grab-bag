#!/bin/bash

export LS_JAVA_OPTS="-Duser.language=en -Duser.country=en"

PARAM_DATE=$1
PARAM_TIMEZONE=$2
PARAM_LOCATION=$3
if [ -z "$1" ]; then
  PROMPT=Y
fi 

promptyn () {
  if [ -n "$PROMPT" ]; then
    while true; do
        read -p "$1 [Y]/n? " yn
        if [ -z "$yn" ]; then
        	yn="y"
        fi
        case ${yn:-$2} in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
  else
    return 0;
  fi
}

# Read a value and fallback to a default value
readvalue () {
    if [ -n "$PROMPT" ]; then
      read -p "$1 [$2]:" value
    fi
    if [ -z "$value" ]; then
    	value=$2
    fi
    echo $value
}


# Detecting linux platform
PLATFORM_LINUX=linux
PLATFORM_MAC=mac
PLATFORM=$PLATFORM_LINUX
if [[ "$OSTYPE" == "darwin"* ]]; then 
  PLATFORM=$PLATFORM_MAC
fi

# Enter a date with this format (default = today + 7 days):
if [ "$PLATFORM" == "$PLATFORM_MAC" ]; then
  NEXTWEEK=$(date -v "+7d" +"%Y-%m-%d")
else
  NEXTWEEK=$(date --date='next week' +%Y-%m-%d)
fi

TZ=$(date +%z)
WORKSHOP_DATE=$(readvalue "Enter the workshop date format YYYY-MM-DD" ${PARAM_DATE:-$(echo $NEXTWEEK)})
WORKSHOP_OFFSET=$(readvalue "Enter your UTC offset format +/-HH, examples +00 -08 +01" ${PARAM_TIMEZONE:-$(echo ${TZ:0:3})})
WORKSHOP_TIME=$WORKSHOP_DATE"T15:00:00.000"$WORKSHOP_OFFSET":00"

echo "You set $WORKSHOP_TIME as the workshop date."
if ! promptyn "Ok to proceed"; then
	echo "exiting..."
    exit
fi

cat <<EOF > update-times.conf
input { stdin { } }

filter {
  dissect {
    mapping => { message => '%{start}[%{timestamp}]%{end}' }
  }

  date {
    match => [ "timestamp", "dd/MMM/YYYY:HH:mm:ss Z" ]
    locale => en
  }

  # Bump the time forward
  ruby {
    init => "last = LogStash::Timestamp.parse_iso8601('2014-09-25T12:00:00+00:00'); @shift = LogStash::Timestamp.parse_iso8601('$WORKSHOP_TIME') - last"
    code => "event.set('@timestamp', LogStash::Timestamp.new(event.get('@timestamp') + @shift))"
  }

}

output {
  file { path => "logs-OUTPUT" codec => line { format => "%{start}[%{+dd/MMM/YYYY:HH:mm:ss Z}]%{end}" } }
}
EOF

echo "Generating logs-OUTPUT..."
gzip -dc logs.gz | sed 1d | ./bin/logstash -f update-times.conf

echo "FYI logs looks like"
head -1 logs-OUTPUT
echo "   [... skipped ...]"
tail -1 logs-OUTPUT
