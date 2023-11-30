#/bin/sh

PWD=$(pwd)

vlog -reportprogress 300 -work $1 $(PWD)/$2 -sv
