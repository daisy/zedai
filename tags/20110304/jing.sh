#!/bin/sh
INPUT_FILE=./test/z3986a/genericdocument-valid-01.html
SCHEMA=./src/schema/z3986a-genericdocument.rng
java -jar ./lib/jing.jar $SCHEMA $INPUT_FILE 