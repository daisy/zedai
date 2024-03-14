@echo off
setlocal
if exist "%JAVA_HOME%\bin\java.exe" goto found
echo You must set JAVA_HOME to the directory containing the JDK
exit /b 1
:found
set ANT_OPTS=-Xms256m -Xmx1024m
set ZEDNEXT_HOME=%~dp0.
"%JAVA_HOME%\bin\java.exe" -Xmx1024m -Xms256m -classpath "%ZEDNEXT_HOME%\lib\ant-launcher.jar" "-Dant.home=%ZEDNEXT_HOME%" org.apache.tools.ant.launch.Launcher -buildfile "%ZEDNEXT_HOME%\build-dist.xml" %*

