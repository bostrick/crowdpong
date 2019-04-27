======================================================================
Southern Dev Conference
======================================================================

.. contents::


**************************************
Introduction
**************************************

About me...
=====================

    - Bowe Strickland <bowe@redhat.com>

    - https://github.com/bostrick/crowdpong

    - https://github.com/bostrick/crowdpong/docs/so_dev.rst

    - I want to build a game that a room full of geeks can play

    - Through the process, I want to convence you containers are not only
      cool, but very useful...

    - ... and Red Hat Openshift (or the upstream project, "origin" "OKD")
      can help you manage them.

Game Design - Three Tier App
=======================================

    - Front End Single Page Apps ("SPA") - JavaScript
        - "Board" - single instanced - "crowdpong-board-client"
        - "Controller" - one per player - "crowdpong-controller-client"

    - Backend API - python - "crowdpong-api"

    - Storage: redis

**************************************
Getting Started
**************************************

Work on the API locally
==================================

    - download the api code::

        git clone https://github.com/bostrick/crowdpong-api
        cd crowdpong-api

    - install and activate a python virtual environment::

        python3 -m venv venv_cp
        source venv_cp/bin/activate
        pip install -U pip setuptools
        pip install -r requirements.txt

    - fire up the app::

        pserve development.ini

    - oh no's!  no storage!

Install a redis server
==================================

    - (1995?) rpm -ihv redis-...errr...
    - (2005?) yum install redis && systemctl start redis
    - (2015?) docker run -p 6379:6379 redis

Exericse the API server
=========================

    - http://localhost:8080/
    - http://localhost:8080/api/controller
    - http://localhost:8080/api/game_state

    - redis-cli -scan

Sidebar - what is a container?
=====================================

- docker ps
- docker image ls
- docker exec -ti ... /bin/bash

- diagram::

    --------------------------------
    | laptop                       |
    |                   python-api-| 8080
    |                              |      -----------
    |                             -| 6379 |-redis   | (container)
    --------------------------------      -----------


******************************************
Maybe I want to containerize my app...
******************************************

Docker Build: Dockerfile
=====================================

- Many people build their own images using Docker build::

    FROM busybox
    ENV foo /bar
    WORKDIR ${foo}   # WORKDIR /bar
    ADD . $foo       # ADD . /bar
    COPY \$foo /quux # COPY $foo /quux
    
- Yeah, we're not doing that...

source-to-image ("source2image") ("s2i")
==========================================

- Use an image to build another image.

- Assume you're starting from a "conventional" starting point

- The s2i executable::

    s2i build https://github.com/sclorg/django-ex centos/python-35-centos7 hello-python

- Or, use openshift...

    - projects
    - builds
    - services
    - routes
    - deployments
    - secrets
    - oh my!

how to use the container?
==========================================

- pull the container from the custom repo::

    docker pull ...customrepo...:crowdpong-api
    docker run -p 8080:8080 crowdpong-api
   
- diagram::

    --------------------------------
    | laptop                       |
    |                              |      -------------
    |                             -| 8080 |-python-api| 
    |                              |      -------------
    |                              |      -----------
    |                             -| 6379 |-redis   |
    --------------------------------      -----------

We have some issues:

    - networks: ports 8080 and 6379 can't talk to each other!
    - storage: if i kill the redis container, i lose the data!


Docker Compose: Manage groups of containers locally
=======================================================

- Define networks, storage, settings, sources, ... in a
  *docker-compose.yaml* file::

        webapp:
          image: examples/web
          ports:
            - "8000:8000"
          volumes:
            - "/data"

- shared network by default

- easy to map storage to local volumes

- Compose file for my project thus far::

    version: '3'
    services:
    
      api:
        image: docker-registry-default.apps.os-gamma.ole.redhat.com/crowdpong/crowdpong-api:latest
        environment:
          xCONTAINER_DEBUG: 1
        ports:
          - "8080:8080"
        volumes:
          - ./api:/opt/app-root/src
    
      redis:
        image: redis
        ports: 
          - "6379:6379"
        volumes:
          - redis:/var/lib/redis/data
    
    volumes:
      redis:
    
- manage with **docker-compose** command (context directory dependent)::

    docker-compose pull
    docker-compose up
    docker-compose ps
    docker-compose exec webapp /bin/bash
    docker-compose down

- Compare to underlying docker management::

    docker ps
    docker volume ls

******************************************
The SPA Projects
******************************************

Manual Installation: conventional layout
=============================================

- Check out the Repo::

    git clone https://github.com/bostrick/crowdpong-board-client
    cd crowdpoint-board-client

- Install node modules::

    npm install

- Build or Develop::

    npm run build
    npm run dev

How Containerize?
==============================
   
    - Openshift console!

    - Openshift command line! ::

        oc login ...
        oc project crowdpong
        oc new-app https://github.com/bostrick/crowdpong-board-client

Helpful to have overriding project
=========================================

  - git clone --recursive https://github.com/bostrick/crowdpong

  - cd crowdpong

  - docker-compose up -d

