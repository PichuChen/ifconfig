#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
CGO_ENABLED=0 GOOS="${GOOS:-linux}" GOARCH="${GOARCH:-amd64}" go build -trimpath -o ifconfig .
