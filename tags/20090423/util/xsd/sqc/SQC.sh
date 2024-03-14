#!/bin/sh
# Licensed Materials - Property of IBM (C) Copyright IBM Corp. 2000, 2002 All Rights Reserved. 
CP=.
CP=$CP:xmlParserAPIs.jar
CP=$CP:xercesImpl.jar
CP=$CP:xschemaREC.jar
CP=$CP:xml4j.jar
CP=$CP:mofrt.jar


export CP

java -Djava.endorsed.dirs=. -classpath $CP com.ibm.sketch.util.SchemaQualityChecker $*
