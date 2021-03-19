#!/bin/bash

getconf() {
    file="$1"
    sec="$2"
    key="$3"

    awk -v matchsec="$sec" -v matchkey="$key" '
# skip comments
/^#/ { next }

# keep track of current section
/^\[.*\]/ {
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
}
' "$file"
}

test_equal() {
    if [[ "$1" != "$2" ]]; then
        echo "test failed"
        echo "output: $1"
        echo "expect: $2"
        exit 1
    fi
}

host=$(getconf config.ini reverse-tunnel host)
port=$(getconf config.ini reverse-tunnel port)
ssh_options=$(getconf config.ini reverse-tunnel ssh-options)
missing=$(getconf config.ini reverse-tunnel missing)
missing="${missing:-default}"

# run tests
test_equal "$host" hostname
test_equal "$port" portnum
test_equal "$ssh_options" "-a -b -c"
test_equal "$missing" "default"

# show example
CONFIG_FILE=config.ini
BK_HOST=$(getconf ${CONFIG_FILE} reverse-tunnel host)
echo "BK_HOST=${BK_HOST}"

BK_PORT=$(getconf ${CONFIG_FILE} reverse-tunnel port)
echo "BK_PORT=${BK_PORT}"

KEY_FILE=$(getconf ${CONFIG_FILE} reverse-tunnel key)
echo "KEY_FILE=${KEY_FILE}"

SSH_OPTIONS=$(getconf ${CONFIG_FILE} reverse-tunnel ssh-options)
SSH_OPTIONS="${SSH_OPTIONS:-vv}"
echo "SSH_OPTIONS=${SSH_OPTIONS}"
