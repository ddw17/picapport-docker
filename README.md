# picapport-docker
Dockerfile for Picapport is inspired by existing docker files for Picapport (my thanks go to fionnb and whatever4711!) but has different goals, e.g.:
- Running as a normal, non-priviledged user
- Support configuration of (default) picapport user id at image build time
- Support configuring the user (id) also at start-up of the container, not only at build time
- Support defining Java memory properties without recreating the image, i.e. through a config file (one reason not to use whatever4711's image)
- Download the Picapport jar at build time and thus avoid requiring Internet connectivity at start time (one reason not to use fionnb's image)
- Lean container, but with tools required for Picapport plugins installed
- Open source (fionnb's Dockerfile is not openly available)
- No filesystem operation as root if a user is provided
- Support configuring the listen port without re-building the image
- Not exporting a port (since can only be configured at build time, while it technically does nothing, see docs)

Folder structure:
- volume at /opt/picapport/data contains all picapport-specific data:
  - picapport.properties
  - optionally the ENV file
  - other files created by picapport: cached thumbnails, the database, plugins, user & permission configuration ...
- volume at/opt/picapport/photos contains photos only.
  Note: The picapport user needs write permission to this volume for any write features e.g. setting tags. If starting you start the container without user parameter, it uses UID 5000 by default. 

# starting the container
Either you start the container using plain docker or using docker-compose. 
dcoker run -v '<yourpicpath>:/opt/picapport/photos' -v '<yourdatapath>:/opt/picapport/data' -p 80:8888 <image-name>

# docker-compose
I recommend using docker-compose and also defining
Example docker-compose.yml:
