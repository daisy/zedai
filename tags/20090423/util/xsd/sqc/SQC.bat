@echo off
rem Licensed Materials - Property of IBM (C) Copyright IBM Corp. 2000, 2002 All Rights Reserved. 
set OLDCLASSPATH=%CLASSPATH%
set STYLESHEET=.
set XML4J=xml4j.jar
set MOF=mofrt.jar
set XSCHEMA=xschemaREC.jar
set XERCES=xmlParserAPIs.jar;xercesImpl.jar
set parameters=%1
:begin
shift
if "%1"=="" goto end
set parameters=%parameters% %1
goto begin
:end
set CLASSPATH=.;%XERCES%;%XSCHEMA%;%XML4J%;%MOF%;%STYLESHEET%
java -classpath %CLASSPATH% com.ibm.sketch.util.SchemaQualityChecker %parameters%
set CLASSPATH=%OLDCLASSPATH%