#!/bin/sh
INPUT_FILE=./test/z3986/genericdocument-valid-01.html
SCHEMA=./src/schema/z3986-genericdocument.rng
java -jar ./lib/jing.jar $SCHEMA $INPUT_FILE 