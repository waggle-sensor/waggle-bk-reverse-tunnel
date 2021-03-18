#!/bin/bash -e

# getconf returns the first value for a key in a config file and section
# TODO(sean) factor this out so this code and tests can share it
getconf() {
    file="$1"
    sec="$2"
    key="$3"

    awk -v matchsec="$sec" -v matchkey="$key" '
# skip comments
/^#/ { next }

# track current section
/^\[.*\]/ {
    # removes outer [ ]
    gsub(/\[|\]/, "", $1);
    sec = $1;
}

# print everything to after = when we match section and key 
($2 == "=") && (sec == matchsec) && ($1 == matchkey) {
    for (i = 3; i <= NF; i++) {
        printf $i
        if (i < NF) {
            printf " "
        }
    }
    exit
}
' "$file"
}

VERSION="{{VERSION}}"  # do not edit

CONFIG_FILE=/etc/waggle/config.ini

id=$(</etc/waggle/node-id)

if [ "${id}_" == "_" ] ; then
    echo "Error: Node id missing"
    exit 1
fi

if [ ! -e ${CONFIG_FILE} ] ; then
    echo "Error: Config file ${CONFIG_FILE} missing"
    exit 1
fi

BK_HOST=$(getconf ${CONFIG_FILE} reverse-tunnel host)
BK_PORT=$(getconf ${CONFIG_FILE} reverse-tunnel port)
KEY_FILE=$(getconf ${CONFIG_FILE} reverse-tunnel key)
SSH_OPTIONS=$(getconf ${CONFIG_FILE} reverse-tunnel ssh-options)
SSH_OPTIONS="${SSH_OPTIONS:-vv}"

echo "BK_HOST=${BK_HOST}"
echo "BK_PORT=${BK_PORT}"
echo "KEY_FILE=${KEY_FILE}"
echo "SSH_OPTIONS=${SSH_OPTIONS}"

set -x

ssh ${SSH_OPTIONS} \
    -o "ServerAliveInterval 60" \
    -o "ServerAliveCountMax 3" \
    -N \
    -R "/home_dirs/node-$id/rtun.sock:localhost:22" "node-${id}@${BK_HOST}" -p "${BK_PORT}" -i "${KEY_FILE}"

# ssh flag notes:
# -vv Enable extra verbose logging.
# -o "ServerAliveInterval 60" Node requests a ping response from server every 60s.
# -o "ServerAliveCountMax 3" Server can fail to respond to 3 pings before node closes connection.
# -N Do not execute a remote command. This is useful for just forwarding ports (protocol version 2 only).
# -R [bind_address:]port:host:hostport Specifies that the given port on the remote (server) host is to be forwarded to the given host and port on the local side.

