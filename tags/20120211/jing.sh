#!/bin/sh
INPUT_FILE=./test/z3998/genericdocument-valid-01.html
SCHEMA=./src/schema/z3998-genericdocument.rng
java -jar ./lib/jing.jar $SCHEMA $INPUT_FILE 