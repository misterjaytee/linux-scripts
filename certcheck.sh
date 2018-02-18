#!/bin/bash
if [ "$1" == "-h" ] || [ -z "$1" ]; then
usage="$(basename "$0") [-h] servername -- script to obtain certificate details from a server

where:
    -h          show this help text
    servername  the server you want to grab the details for (e.g. gmail.com)"
  echo "$usage"
  exit 0
fi

certinfo="$(echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -subject -issuer -dates)"

IFS=$'\n'

for item in $certinfo
do
case $(echo $item | awk -F= '{print $1}') in
  subject)
    echo "Subject: $(echo $item | awk -FCN= '{print $2}')"
    ;;
  issuer)
    echo "Issuer: $(echo $item | awk -FCN= '{print $2}')"
    ;;
  notBefore)
    echo "Valid From: $(echo $item | awk -F= '{print $2}')"
    ;;
  notAfter)
    echo "Valid Until: $(echo $item | awk -F= '{print $2}')"
    echo "Valid For:" $(( ($(date -d "$(echo $item | awk -F= '{print $2}')" '+%s') - $(date '+%s')) / 86400 )) "Days"
    ;;
  *)
    echo $item
    ;;
esac
done

unset IFS
