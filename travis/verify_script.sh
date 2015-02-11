#!/usr/bin/env bash
cd "${TRAVIS_BUILD_DIR}/verify"

mix compile
mix ua_inspector.databases.download --force
mix ua_inspector.verify
