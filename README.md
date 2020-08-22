# mikenye/virtualradarserver

Docker container for Virtual Radar Server (http://www.virtualradarserver.co.uk).

Builds and runs on x86_64, arm32v6, arm32v7 and arm64v8 (and possibly other architectures).

---

![VRS logo](https://github.com/mikenye/docker-virtualradarserver/raw/master/vrs-logo.png) [Virtual Radar Server](http://www.virtualradarserver.co.uk)

Virtual Radar Server (VRS) plots aircraft positions on a map.

VRS is an open-source .NET application that runs a local web server.

You can connect to the web server with any modern browser and see the aircraft plotted on a map.

This container is designed to work in conjunction with a Mode-S / BEAST provider. Check out [mikenye/readsb](https://hub.docker.com/repository/docker/mikenye/readsb) or [mikenye/piaware](https://hub.docker.com/repository/docker/mikenye/piaware) for this, or BYO.

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example and parameters should be adjusted to suit your needs.

Launch the VRS docker container with the following commands:

```
docker volume create vrsconfig
docker run -d \
    --name=vrs \
    -p 8080:8080 \
    -e USERNAME=vrsadmin \
    -e PASSWORD=very_secure_password_123 \
    -e BASESTATIONHOST=readsb \
    -v vrsconfig:/config \
    mikenye/virtualradarserver 
```

Browse to `http://dockerhost:8080/VirtualRadar/` to access the VRS GUI.

Browse to `http://dockerhost:8080/VirtualRadar/WebAdmin/Index.html` to access the Admin area.

## Usage

```
docker run [-d] \
    --name=vrs \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    mikenye/virtualradarserver
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background.  If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host).  See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`TZ`| [TimeZone] of the container. Optional. Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`USERNAME`|Username for the admin area. Required.| |
|`PASSWORD`|Password for the admin area. Required.| |
|`BASESTATIONHOST`|IP/hostname of `dump1090`/`readsb` or another program/device providing Basestation protocol data. Optional.| |
|`BASESTATIONPORT`|TCP port for program/device providing Basestation protocol data. Optional. | `30003` |
|`BEASTHOST`|IP/hostname of `dump1090`/`readsb` or another program/device providing BEAST protocol data. Optional.| |
|`BEASTPORT`|TCP port for program/device providing BEAST protocol data. Optional. | `30005` |
|`MLATHOST`|IP/hostname of `dump1090`/`readsb/mlat-client` or another program/device providing MLAT protocol data. Optional.| |
|`MLATPORT`|TCP port for program/device providing MLAT protocol data. Optional. | `30105` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<NAMED_VOL>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/config`| rw | This is where the application stores its configuration, log, operator flags and silhouette images, and any other files needing persistency. If mounted, this must be a named volume.|

As mentioned above, `/config` needs to be a named volume. A bind mount won't work properly.

The docker run command initializes the newly created volume with any data that exists at the specified location within the base image. However, this only works for named volumes, not bind mounts (see [moby/moby#17470](https://github.com/moby/moby/issues/17470)).

If you want to map the container's `/config` to a specific path on your system, you can:

1.  Use the `docker volume create` command with arguments, eg:

```shell
docker volume create vrsconfig --opt o="bind" --opt device="/path/to/vrs/config" --opt type="none"
```

2.  If using `docker-compose`, use the following syntax in your `docker-compose.yml`, eg:

```yaml
version: '2.0'

volumes:
  vrsconfig:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/path/to/vrs/config'

services:
  virtualradarserver:
    image: mikenye/virtualradarserver:latest
    tty: true
    container_name: vrs
    restart: always
    volumes:
      - vrsconfig:/config
    ports:
      - 8077:8080
    environment:
      - USERNAME=vrsadmin
      - PASSWORD=vrsadmin
      - BASESTATIONHOST=readsb
```

Change `/path/to/vrs/config` to a directory on your system. Please be mindful that the contents of this directory (if it exists) will be overwritten with the contents of `/config` from the docker image.

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 8080 | Recommended | Port used to access VRS's web GUI. |

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.

```yaml
version: '2.0'
volumes:
  vrsconfig:
services:
  vrs:
    image: mikenye/virtualradarserver
    tty: true
    container_name: vrs
    restart: always
    ports:
      - 8080:8080
    environment:
      - USERNAME=vrsadmin
      - PASSWORD=very_secure_password_123
      - BASESTATIONHOST=readsb
    volumes:
      - vrsconfig:/config
```

## Getting Help

Having troubles with the container or have questions?  Please [create a new issue](https://github.com/mikenye/docker-virtualradarserver/issues).

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
