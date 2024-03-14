#!/bin/sh

export JAVA_HOME=/System/Library/Frameworks/JavaVM.Framework/Versions/CurrentJDK/Home
export ANT_HOME=/lib/

test -x "$JAVA_HOME/bin/java" || {
    cat <<EOF 1>&2
You must set JAVA_HOME environment variable to point to
the directory where your JDK is installed.
EOF
    exit 1
}
ZEDNEXT_HOME=`dirname $0`
"$JAVA_HOME/bin/java" \
  "-Dant.home=$ZEDNEXT_HOME" \
  -cp "$ZEDNEXT_HOME/lib/ant-launcher.jar" \
  org.apache.tools.ant.launch.Launcher \
  -buildfile "$ZEDNEXT_HOME/build-ai.xml" \
  "$@"
