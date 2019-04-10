#!/bin/bash
#

while [ $# -gt 0 ]; do
  case "$1" in
    --value*)
      value="$2"
      shift
      ;;
    --type*)
      type="$2"
      shift
      ;;
    --secret-name*)
      name="$2"
      shift
      ;;
    --namespace*|-n*)
      namespace="$2"
      direct_params+="$1 $2"
      shift
      ;;
    *)
      params+="$1 "
      direct_params+="$1"
      ;;
  esac
  shift
done

if [[ -n "$value" ]]
then
    cat <<EOF | kubeseal $params | grep ".*value\"*: \"*\([^\"]*\)\"*" | sed -e 's/.*: \"*\([^"]*\)\"*/\1/'
apiVersion: v1
metadata:
  name: "$name"
  namespace: "${namespace:-default}"
kind: Secret
type: "${type:-Opaque}"
data:
  value: $( echo -n "$value" | base64 )
EOF
else
    kubeseal $direct_params
fi
