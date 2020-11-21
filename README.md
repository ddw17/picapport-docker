# picapport-docker
This Docker file for Picapport is inspired by existing Docker files for Picapport (my thanks go to fionnb and whatever4711!) but has different goals, e.g.:
* Running Picapport as a normal, non-priviledged user
* Support configuration of (default) Picapport user id at image build time (default uid is 5000)
* Support configuring the user (id) also at start-up of the container, not only at build time
* Support using Java's own memory management on single purpose hosts or resource-limited containers (see examples below)
* Support defining Java memory properties without recreating the image, i.e. through a config file
* Download the Picapport jar at build time and thus avoid requiring Internet connectivity at start time
* Container with tools required for Picapport plugins installed (dcraw, exiftool)
* Picapport plugins included and installed on fresh installs (no Internet required)
* Open source: you can see, check and alter all the sources
* No host filesystem operation as root
* Support configuring the listen port without re-building the image
* Not exporting a port (since can only be configured at build time, while it technically does nothing, see docs)

Folder structure:
* volume at /opt/picapport/data contains all picapport-specific data:
  * picapport.properties
  * optionally the ENV file
  * the groovy subdirectory for the Picapport plugins
  * other files created by picapport: cached thumbnails, the database, plugins, user & permission configuration ...
* volume at/opt/picapport/photos contains photos only.
  Note: The picapport user needs write permission to this volume for any write features e.g. setting tags. If starting you start the container without user parameter, it uses UID 5000 by default. 

# starting the container
Either you start the container using plain docker or using docker-compose, see below for examples.

## docker run
Note that both following example commands publish the Picapport at port 80 of the host. 
Allow 2G memory and let Java do the configuration accordingly:
`docker run -v '<yourpicpath>:/opt/picapport/photos' -v '<yourdatapath>:/opt/picapport/data' -m 2G -p 80:8888 ddw17/picapport:latest`

  
Provide Java with the Xmx option (to define maximum memory allocation, although Java may consume more than that) without an external enforcement of any limit:
`docker run -v '<yourpicpath>:/opt/picapport/photos' -v '<yourdatapath>:/opt/picapport/data' -e PICAPPORT_JAVAPARS=-Xmx2048m -p 80:8888 ddw17/picapport:latest`

## docker-compose
I recommend using docker-compose and to use it to limit the containers resources. The following example additionally configures an own docker network so Picapport can be reached at http://172.22.42.42:8888 
Remarks
* If you want your Picapport running as a different user, uncomment the user line and provide UID:GID. 
* If you want Docker to do the NATing and proxying to make Picapport service available at the host's IP, uncomment (and adapt) the ports statement. 

Example docker-compose.yml:
```
version: '2.4'

services:
  picapport:
    container_name: 'picapport1'
    image: 'ddw17/picapport:9.0.01'
    hostname: 'somename.tld'
    restart: 'unless-stopped'
#    user: '2204:2204'
     # The ports statement works independently of the image having an expose statement. 
#    ports:
#      - "8888"
    # NB: cpu_count and cpu_percent are valid only for Windows hosts!
    cpus: '1.0'
    mem_limit: '4G'
    volumes:
      - '/mnt/picapport/data:/opt/picapport/data:rw'
      - '/mnt/picapport/photos:/opt/picapport/photos:rw'
    networks:
      'picapport-net':
        ipv4_address: '172.22.42.42'
        # ipv6_address: 2001:3984:3989::1
networks:
  'picapport-net':
    name: 'picapport-net'
    driver: 'bridge'
    ipam:
      driver: 'default'
      config:
        - subnet: '172.22.42.0/24'
          gateway: '172.22.42.1'
```
