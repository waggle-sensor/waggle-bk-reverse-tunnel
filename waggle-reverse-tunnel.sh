#!/bin/bash -e


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

CONFIG_SECTION=$(grep '^\[reverse-tunnel\]' -A 999 ${CONFIG_FILE} | tail -n +2  | grep -m1 -B 999 '^\[' | head -n -1)

BK_HOST=$(echo "${CONFIG_SECTION}" | grep host | cut -d '=' -f 2 |  tr -d ' ' )
echo "BK_HOST=${BK_HOST}"

BK_PORT=$(echo "${CONFIG_SECTION}" | grep port | cut -d '=' -f 2 |  tr -d ' ' )
echo "BK_PORT=${BK_PORT}"

KEY_FILE=$(echo "${CONFIG_SECTION}" | grep key | cut -d '=' -f 2 |  tr -d ' ' )
echo "KEY_FILE=${KEY_FILE}"

# source: https://stackoverflow.com/a/64993893/2069181


set -x

ssh -vv -N  -R /home_dirs/node-$id/rtun.sock:localhost:22 node-${id}@${BK_HOST} -p ${BK_PORT} -i ${KEY_FILE}


# -N Do not execute a remote command. This is useful for just forwarding ports (protocol version 2 only).
# -R [bind_address:]port:host:hostport Specifies that the given port on the remote (server) host is to be forwarded to the given host and port on the local side.
