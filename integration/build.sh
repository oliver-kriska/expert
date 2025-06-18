#!/usr/bin/env bash
set -eo pipefail

docker build -t xp -f integration/Dockerfile .
