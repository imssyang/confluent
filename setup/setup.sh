#!/bin/bash

APP=confluent
GROUP=confluent
USER=confluent
HOME=/opt/$APP
SYSD=/etc/systemd/system
SERFILE=confluent-kafka-rest.service

init() {
  egrep "^$GROUP" /etc/group >/dev/null
  if [[ $? -ne 0 ]]; then
    groupadd -r $GROUP
  fi

  egrep "^$USER" /etc/passwd >/dev/null
  if [[ $? -ne 0 ]]; then
    useradd -r -g $GROUP -s /usr/sbin/nologin -M $USER
  fi

  if [[ ! -d $HOME/log ]]; then
    mkdir $HOME/log
    chmod 755 $HOME/log
  fi

  chown -R $GROUP:$USER $HOME

  if [[ ! -s $SYSD/$SERFILE ]]; then
    ln -s $HOME/setup/$SERFILE $SYSD/$SERFILE
    systemctl enable $SERFILE
    echo "($APP) create symlink: $SYSD/$SERFILE --> $HOME/setup/$SERFILE"
  fi

  systemctl daemon-reload
}

deinit() {
  egrep "^$USER" /etc/passwd >/dev/null
  if [[ $? -eq 0 ]]; then
    userdel $USER
  fi

  egrep "^$GROUP" /etc/group >/dev/null
  if [[ $? -eq 0 ]]; then
    groupdel $GROUP
  fi

  chown -R root:root $HOME

  if [[ -d $HOME/log ]]; then
    rm -rf $HOME/log
    echo "($APP) delete $HOME/log"
  fi

  if [[ -s $SYSD/$SERFILE ]]; then
    systemctl disable $SERFILE
    rm -rf $SYSD/$SERFILE
    echo "($APP) delete symlink: $SYSD/$SERFILE"
  fi

  systemctl daemon-reload
}

start() {
  local pid=$(jps -l -m | grep kafka-rest | awk '{print $1}')
  if [[ "x" == "x$pid" ]]; then
    systemctl start $SERFILE
    echo "($APP) $SERFILE start!"
  fi

  show
}

stop() {
  local pid=$(jps -l -m | grep kafka-rest | awk '{print $1}')
  if [[ "x" != "x$pid" ]]; then
    systemctl stop $SERFILE
    echo "($APP) $SERFILE stop!"
  fi

  show
}

show() {
  jps -l -m | grep kafka-rest
}

case "$1" in
  init)
    init
    ;;
  deinit)
    deinit
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  show)
	show
	;;
  *)
    SCRIPTNAME="${0##*/}"
    echo "Usage: $SCRIPTNAME {init|deinit|start|stop|show}"
    exit 3
    ;;
esac

exit 0

# vim: syntax=sh ts=4 sw=4 sts=4 sr noet
