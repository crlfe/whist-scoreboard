#!/bin/bash
set -e

hash=$(git rev-parse --short=12 HEAD)
cd dist/web && git commit -a -m "Update for ${hash}"
