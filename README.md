# openfire-docker

__Openfire version__: _`4.6.2`_

![GitHub license](https://img.shields.io/badge/license-MIT-%23fe7d37) ![GitHub last commit](https://img.shields.io/github/last-commit/EndMove/openfire-docker)

[![Donate][link-icon-coffee]][link-paypal-me] [![Website][link-icon-website]][link-website]

[link-icon-coffee]: https://img.shields.io/badge/%E2%98%95-Buy%20me%20a%20cup%20of%20coffee-991481.svg
[link-paypal-me]: https://www.paypal.me/EndMove/2.5eur
[link-icon-website]: https://img.shields.io/badge/%F0%9F%92%BB-My%20Web%20Site-0078D4.svg
[link-website]: https://www.endmove.eu/

openfire-docker is a docker image based on Ubuntu 18.04 that implements Openfire from [Ignite Realtime](https://github.com/igniterealtime/Openfire).

## Requirements

You only need a stable version of docker `docker`.

### Installing Docker

To begin updating the system if necessary:

````sh
sudo apt-get update && sudo apt-get upgrade
````

Install Docker at the latest stable version:

````sh
sudo apt-get install docker-ce docker-ce-cli containerd.io
````

## Installation

### _Step One_

To start download or build the "`openfire-docker`" image (the recommended method is to do a pull request to Dockerhub).

- Methode 1 : Pull from __Dockerhub__

````sh
docker pull endmove/openfire:latest
````

- Methode 2 : build from __Github__

````sh
docker build -t endmove/openfire github.com/EndMove/openfire-docker
````

### _Step Two_

Create the Docker container, open the ports and connect the volumes.

````bash
docker create -i -t \
  --name=openfire \
  --publish 9090:9090 \
  --publish 5222:5222 \
  --publish 7777:7777 \
  --volume /home/openfire/data:/var/lib/openfire \
  --restart unless-stopped \
  endmove/openfire:latest
````

### _Step Three_

Command to start the container

````sh
docker start openfire
````

Command to stop the container

````sh
docker stop openfire
````

Command to remove openfire

````sh
docker rm -f openfire
````

## Utilities

This Openfire installation script provides two important volume locations to track and keep the installation up to date and in a safe place.

### Openfire - db, conf, plugins

> To access the configuration files and store the users, data and plugins (during an update for example) it is important to store these files outside the container in a safe and secure space.

````sh
# in container location:
/var/lib/openfire

# recommended docker volume:
--volume /home/openfire:/var/lib/openfire
````

### Openfire - log

> To benefit from error tracking it is recommended to keep an access to the folder containing all log files of Openfire.

````sh
# in container location:
/var/log/openfire

# recommended docker volume:
--volume /home/openfire/log:/var/log/openfire
````

## Update ?

When an update of Openfire is available and I updated the repository you just have to remove and install again the container to migrate to the new version.

__WARNING__: this requires that you store the Openfire data as recommended above.

## Available features

- [x] Log file available out of container.
- [x] Configuration file, security and embedded-database available out of the container.
- [x] Makes available all the ports available in Openfire version 4.6.2.
- [ ] Allows the import of SSL certificates that are external to the container.
