#!/bin/bash

export CONFLUENT_DISABLE_ENV=yes
export CONFLUENT_HOME=/opt/confluent
eval "optbin -s $CONFLUENT_HOME/bin"

