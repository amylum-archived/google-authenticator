google-authenticator
=======

[![Build Status](https://img.shields.io/circleci/project/amylum/google-authenticator.svg)](https://circleci.com/gh/amylum/google-authenticator)
[![GitHub release](https://img.shields.io/github/release/amylum/google-authenticator.svg)](https://github.com/amylum/google-authenticator/releases)
[![Apache Licensed](http://img.shields.io/badge/license-Apache-green.svg)](https://tldrlegal.com/license/apache-license-2.0-(apache-2.0))

PAM package for [Google's HOTP/TOTP implementation](https://github.com/google/google-authenticator)

## Usage

To build a new package, update the submodule and run `make`. This launches the docker build container and builds the package.

To start a shell in the build environment for manual actions, run `make manual`.

## License

This repo is released under the MIT License. See the bundled LICENSE file for details.

Google's PAM code is licensed under the Apache License, Version 2.0.

