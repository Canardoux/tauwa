#!/bin/bash

rm -r doc/api/*
dart doc .
if [ $? -ne 0 ]; then
    echo "Error: dart doc"
    exit -1
fi
