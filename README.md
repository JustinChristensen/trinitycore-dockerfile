# TrinityCore Dockerfiles

This project is an attempt to absolve you of the need to worry about the details of compiling TrinityCore, extracting your
WoW Client's data, managing the database, and configuring your network by abstracting it away behind Docker. 

## System Requirements

The scripts and configuration in this repository depend on recent versions of [docker] and [docker-compose]. Click the links
and follow the installation instructions for your system.

You'll also need version 3.3.5a of World of Warcraft.

## Usage

### Building

```
                     +--------------------+                     
                     |  trinitycore-base  |                     
                     +--------------------+                     
                                ^                               
                                |                               
               +----------------+-----------------+             
               |                                  |             
  +------------------------+         +-------------------------+
  | trinitycore-authserver |         | trinitycore-worldserver |
  +------------------------+         +-------------------------+
```

#### TL;DR

```bash
git clone https://github.com/JustinChristensen/trinitycore-dockerfile.git 
cd trinitycore-dockerfile
TRINITYCORE_VERSION="3.3.5" docker build -t trinitycore-base --build-arg TRINITYCORE_VERSION base
docker build -t trinitycore-authserver authserver
docker build -t trinitycore-worldserver worldserver
```

#### Long Explanation

The **[authserver]** and **[worldserver]** images are both based on the trinitycore **[base]** image (which is based on a slim build of debian). 
To build base run:

```bash
TRINITYCORE_VERSION="3.3.5" docker build -t trinitycore-base --build-arg TRINITYCORE_VERSION base
```

After the build of base succeeds, build the authserver and worldserver images with:
```bash
docker build -t trinitycore-authserver authserver
docker build -t trinitycore-worldserver worldserver
```

#### Build Args

The build args for each build are:

**base**
```Dockerfile
ARG TRINITYCORE_VERSION     # the specific git ref of TrinityCore to build
```

**authserver**
```Dockerfile
ARG BUILD_VERBOSE           # verbose TrinityCore make output
ARG BUILD_JOBS              # the number of parallel build jobs (defaults to 4)
```

**worldserver**
```Dockerfile
ARG BUILD_VERBOSE           # verbose TrinityCore make output
ARG BUILD_JOBS              # the number of parallel build jobs (defaults to 4)
ARG BUILD_TOOLS             # whether or not to build the client data extraction tools (defaults to 1)
```

### Running

#### TL;DR

```bash
# given a WoW client directory like:
tree -d -L 1 /absolute/path/to/client
# client
# ├── Data
# ├── World\ of\ Warcraft.app
# └── ...

# run
CLIENT_DIR=/absolute/path/to/client ./start.sh

# or 

# worldserver's entrypoint expects a named volume, trinitycore-data, to contain the WoW client's Data directory
# execute the following:
docker volume create trinitycore-data > /dev/null
CLIENT_DIR=/absolute/path/to/client docker run --rm -i -v "$CLIENT_DIR:/client:cached" -v trinitycore-data:/data debian:buster-slim cp -rn /client/Data /data

# start docker compose
docker-compose up
```

#### Long Explanation

If your worldserver image was built with the TrinityCore WoW client [data extraction tools](https://github.com/TrinityCore/TrinityCore/tree/3.3.5/src/tools),
it'll attempt to extract the WoW client's data into a named volume mounted at /usr/local/data inside of the container. On OSX (and probably Windows), using a bind
mount on the host causes this process to become ridiculously slow. We can speed this up drastically by copying the `Data` directory to a named docker volume on
the docker host with:

```bash
docker volume create trinitycore-data > /dev/null
docker run --rm -i -v "/absolute/path/to/client:/client:cached" -v trinitycore-data:/data debian:buster-slim cp -rn /client/Data /data
```

If this succeeds, you can then run containers for the database, authserver, and worldserver using `docker-compose`. Run this to start everything up:

```bash
docker-compose up
```

And you should be all set! 

Configure your WoW client to connect to your running servers by [following these instructions](https://trinitycore.atlassian.net/wiki/spaces/tc/pages/74006268/Client+Setup).

Then, open up WoW, and use **root** and **root** for the username and password, respectively. See [Creating Accounts](#creating-accounts) for more information
on creating accounts outside of the game.

The container entrypoints work as follows:

##### Authserver Entrypoint

1. On startup the authserver will attempt to create the databases.
2. Then, it'll create the auth database tables and populate them with data.
3. After creating the auth database it'll create an initial **root** user.
4. Finally, it'll start the server.

##### Worldserver Entrypoint

1. On startup, the worldserver container will attempt to extract your WoW client's data using the TrinityCore client data extraction tools.
2. Then, after it completes extracting the data (this will take a long time) it will download a release of the world database from Github.
3. After downloading the database, it'll attempt to create the databases and tables, and populate the tables with data.
4. Finally, it'll start the server.

#### Environment Variables

The environment variables available to tweak the behavior of your containers at runtime are as follows. See the Dockerfiles for defaults:

**worldserver**
```Dockerfile
ENV MYSQL_ADMIN_USER        # mysql admin user
ENV MYSQL_ADMIN_PASS        # mysql admin pass
ENV MYSQL_USER              # the mysql user the server uses to connect
ENV MYSQL_PASS              # the mysql user the server uses to connect
ENV MYSQL_HOST              # the hostname or ip of the database server
ENV MYSQL_PORT              # the port number for the database server
ENV WORLD_DB_RELEASE        # the specific database release to download, see ./start.sh in this repository
ENV EXTRACT_DATA            # whether or not to extract the data WoW clients Data directory, defaults to true
ENV CREATE_DATABASES        # whether or not to create the database and load them with data on startup
ENV CONNECT_RETRIES         # how many times the container should try to connect to the database server before giving up
ENV RETRY_INTERVAL          # the period of time between each connection attempt
```

**authserver**
```Dockerfile
ENV MYSQL_ADMIN_USER        # mysql admin user
ENV MYSQL_ADMIN_PASS        # mysql admin pass
ENV MYSQL_USER              # the mysql user the server uses to connect
ENV MYSQL_PASS              # the mysql user the server uses to connect
ENV MYSQL_HOST              # the hostname or ip of the database server
ENV MYSQL_PORT              # the port number for the database server
ENV CREATE_DATABASES        # whether or not to create the database and load them with data on startup
ENV CONNECT_RETRIES         # how many times the container should try to connect to the database server before giving up
ENV RETRY_INTERVAL          # the period of time between each connection attempt
```

### Creating Accounts

The worldserver container exposes **Remote Administration** on port 3443. See the [TrinityCore documentation] for usage.

Note that Telnet is not installed by default on recent versions of OSX. Netcat is though, and will work just fine as a replacement:

```bash
# the -c flag instructs netcat to send CRLF instead of LF, which is what the TrinityCore RA uses
nc -c localhost 3443
```

## Known Issues

1. At the time of this writing, the only TrinityCore branch supported by these dockerfiles is 3.3.5. That may change in the future.
2. Ideally these images wouldn't need to build TrinityCore from scratch, and would instead install the prebuilt binaries from a debian package repository.
3. TrinityCore expects to dynamically link against a variety of libraries at runtime. With the built executables and runtime libraries, these images clock
   in at roughly 2GB in size each. Building the executables statically and basing these images on Alpine Linux should dramatically reduce the size (but that's
   a project for another day).

## License

The scripts and configuration in this repository are licensed using the [GPL V3 License](./LICENSE.md).

[TrinityCore documentation]: https://trinitycore.atlassian.net/wiki/spaces/tc/overview?mode=global
[docker]: https://docs.docker.com/install/
[docker-compose]: https://docs.docker.com/compose/install/
[docker-compose.yml]: ./docker-compose.yml
[base]: ./base/Dockerfile
[authserver]: ./authserver/Dockerfile
[worldserver]: ./worldserver/Dockerfile

