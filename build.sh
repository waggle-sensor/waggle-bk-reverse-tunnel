#!/bin/bash -e

docker run --rm \
  -e NAME="waggle-bk-reverse-tunnel" \
  -e DESCRIPTION="Waggle reverse SSH tunnel to Beekeeper" \
  -v "$PWD:/repo" \
  waggle/waggle-deb-builder:latest
