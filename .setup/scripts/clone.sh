#!/bin/bash

git clone git@github.com:jeksterslab/dynTools.git
rm -rf "$PWD.git"
mv dynTools/.git "$PWD"
rm -rf dynTools
