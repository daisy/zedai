@echo off
setlocal
if exist "%JAVA_HOME%\bin\java.exe" goto found
echo You must set JAVA_HOME to the directory containing the JDK
exit /b 1
:found
set ZEDNEXT_HOME=%~dp0.
"%JAVA_HOME%\bin\java.exe" -classpath "%ZEDNEXT_HOME%\lib\ant-launcher.jar" "-Dant.home=%ZEDNEXT_HOME%" org.apache.tools.ant.launch.Launcher -buildfile "%ZEDNEXT_HOME%\build-ai.xml" %*

