#!/bin/bash



api_url=$1
echo $api_url
conn_name=$2
echo $conn_name
host_name=$3
echo $host_name
host_username=$4
echo $host_username
private_key=$5
echo $private_key

common_parameters="{ 
  \"parentIdentifier\": \"ROOT\",
  \"name\": \"$conn_name\",
  \"protocol\": \"ssh\",
  \"parameters\": {
    \"port\": \"22\",
    \"read-only\": \"\",
    \"swap-red-blue\": \"\",
    \"cursor\": \"\",
    \"color-depth\": \"\",
    \"clipboard-encoding\": \"\",
    \"disable-copy\": \"\",
    \"disable-paste\": \"\",
    \"dest-port\": \"\",
    \"recording-exclude-output\": \"\",
    \"recording-exclude-mouse\": \"\",
    \"recording-include-keys\": \"\",
    \"create-recording-path\": \"\",
    \"enable-sftp\": \"\",
    \"sftp-port\": \"\",
    \"sftp-server-alive-interval\": \"\",
    \"enable-audio\": \"\",
    \"color-scheme\": \"\",
    \"font-size\": \"\",
    \"scrollback\": \"\",
    \"timezone\": null,
    \"server-alive-interval\": \"\",
    \"backspace\": \"\",
    \"terminal-type\": \"\",
    \"create-typescript-path\": \"\",
    \"hostname\": \"$host_name\",
    \"host-key\": \"\",
    \"private-key\": \"$private_key\",
    \"username\": \"$host_username\",
    \"password\": \"\",
    \"passphrase\": \"\",
    \"font-name\": \"\",
    \"command\": \"\",
    \"locale\": \"\",
    \"typescript-path\": \"\",
    \"typescript-name\": \"\",
    \"recording-path\": \"\",
    \"recording-name\": \"\",
    \"sftp-root-directory\": \"\"
  },
  \"attributes\": {
    \"max-connections\": \"\",
    \"max-connections-per-user\": \"\",
    \"weight\": \"\",
    \"failover-only\": \"\",
    \"guacd-port\": \"\",
    \"guacd-encryption\": \"\",
    \"guacd-hostname\": \"\"
  }
}"

echo $common_parameters

echo "obtaining token"
token=$(curl --location "$api_url/guacamole/api/tokens" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "username=guacadmin" \
    --data-urlencode "password=guacadmin" \
    | jq -r '.authToken')

echo "Token generated token=$token"


sleep 3
echo "making connection request"
curl --location "$api_url/guacamole/api/session/data/mysql/connections?token=$token" --write-out "\nHTTP_RESPONSE_CODE:%{http_code}\n" --header 'Content-Type: application/json' --data-raw "$common_parameters"


sleep 3
echo "Closing  the connection"
curl --location --write-out "\nHTTP_RESPONSE_CODE:%{http_code}\n" --request DELETE "$api_url/guacamole/api/tokens/$token"


