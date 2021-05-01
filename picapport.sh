#!/bin/bash

PICAPPORT_PORT="$1"
PICAPPORT_LANG="$2"
PICAPPORT_LOGLEVEL="$3"
PICAPPORT_JAVAPARS="$4"

PAUSERHOME="/opt/picapport"
PAPHOTOPATH="${PAUSERHOME}/photos"
PADIR="data"
CONFIG="$PAUSERHOME/$PADIR/picapport.properties"
ENVFILE="$PADIR/ENV"
PLUGINSDIR="$PAUSERHOME/$PADIR/pugins"
ADDONSDIR="$PAUSERHOME/$PADIR/groovy"

function clean_up {
  echo "=== Shutting down..."
  killall java
  wait %1
  echo "=== Shutdown complete. ==="
  exit
}

# Clean shutdown
trap clean_up SIGHUP SIGINT SIGTERM

# ENV file overrides parameters
if [ -f "$ENVFILE" ]; then
  echo "=== Found ENV file, overwriting command line parameters with parameters defined in that file."
  source "$ENVFILE"
fi

# create & polulate plugin dir if it does not exist
if [ ! -e "$PLUGINSDIR" ]; then
  echo "=== Plugin directory ($PLUGINSDIR) does not exist. Will create it and copy plugins from image..."
  mkdir "$PLUGINSDIR"
  cp -av /plugins/* "$PLUGINSDIR"
  echo "=== Plugin directory created and populated. ==="
fi

# create & polulate addons dir if it does not exist
if [ ! -e "$ADDONSDIR" ]; then
  echo "=== Addons directory ($ADDONSDIR) does not exist. Will create it and copy plugins from image..."
  mkdir "$ADDONSDIR"
  cp -av /addons/* "$ADDONSDIR"
  echo "=== Addons directory created and populated. ==="
fi

# defaults: port 8888, German, WARNING, "". This should be set by the Dockerfile, but can also be overriden on command line or via ENV file.
[ -z "$PICAPPORT_PORT" ] && PICAPPORT_PORT="8888"
[ -z "$PICAPPORT_LANG" ] && PICAPPORT_LANG="de"
[ -z "$PICAPPORT_LOGLEVEL" ] && PICAPPORT_LOGLEVEL="WARNING"
[ -z "$PICAPPORT_JAVAPARS" ] && PICAPPORT_JAVAPARS=" "

# install a minimal config if there is none present
[ ! -f "$CONFIG" ] && printf "%s\n%s\n%s\n" "server.port=$PICAPPORT_PORT" "robot.root.0.path=$PAPHOTOPATH" "foto.jpg.usecache=2" > "$CONFIG"

echo "=== Starting picapport process (with $(id))..."
java -Duser.language="$PICAPPORT_LANG" -DTRACE="$PICAPPORT_LOGLEVEL" -Duser.home="$PAUSERHOME" -Dpicapport.directory="$PADIR" $PICAPPORT_JAVAPARS \
  -jar "$PAUSERHOME/picapport-headless.jar" -configfile="$CONFIG" -pgui.enabled=false &

while true; do sleep 1; done    # wait for shutdown signals


