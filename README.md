# Boxcar

[![Build Status](https://travis-ci.org/smashingboxes/boxcar.svg?branch=master)](https://travis-ci.org/smashingboxes/boxcar)

Boxcar is the base Rails application used at [Smashing Boxes](http://smashingboxes.com/). It is heavily inspired by [thoughtbot's suspenders](https://github.com/thoughtbot/suspenders).

## Installation

First install the boxcar gem (eventually, we'll have it published on rubygems, but there's [some
naming conflicts](https://github.com/dstrctrng/boxcar/issues/2) at the moment):

```sh
git clone git@github.com:smashingboxes/boxcar.git
cd boxcar
bundle install
```

## Usage

```sh
bin/boxcar new path/to/project_name
```

Don't forget to replace `path/to/project_name` with the actual path. For example, if you want to
make a hello world app, you might run `bin/boxcar new ~/repos/hello-world`.

## Contributing

If you'd like to contribute to Boxcar, please see [CONTRIBUTING.md](/.github/CONTRIBUTING.md).
