#!/bin/bash
set -x

oc new-project crowdpong

oc new-app --template=redis-persistent
oc new-app https://github.com/bostrick/crowdpong-api.git
oc create route edge --service=crowdpong-api

oc new-app https://github.com/bostrick/crowdpong-board-client.git
oc create route edge --service=crowdpong-board-client

oc new-app https://github.com/bostrick/crowdpong-controller-client.git
oc create route edge --service=crowdpong-controller-client 

#############################################
# external routes
#############################################

HOSTNAME=crowdpong.ole.redhat.com
CERT_DIR=$HOME/crowdpong-certs
COMMON_ARGS="--hostname=$HOSTNAME --insecure-policy=Redirect \
       --cert $CERT_DIR/crowdpong.crt --key $CERT_DIR/crowdpong.key \
       --ca-cert $CERT_DIR/crowdpong-ca.crt"

_S=crowdpong-api
oc create route edge $_S-ext --service=$_S --path /api $COMMON_ARGS

_S=crowdpong-board-client
oc create route edge $_S-ext --service=$_S --path /board $COMMON_ARGS

_S=crowdpong-controller-client
oc create route edge $_S-ext --service=$_S $COMMON_ARGS

