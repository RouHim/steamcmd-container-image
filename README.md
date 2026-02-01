# steamcmd-container-image

This base container image provides everything you need to run a linux based dedicated server which is to be installed
via SteamCMD. It's based on the latest packages provided by `ubuntu:devel` and is built weekly.

![Docker Image Version](https://img.shields.io/docker/v/_/ubuntu?label=ubuntu)

## How to use

```Dockerfile
FROM docker.io/rouhim/steamcmd:latest
USER $USER

# Set the following environment variables: STEAM_APP_ID, STARTUP_COMMAND

# STEAM_APP_ID: The Steam App ID of the game server to install
ENV STEAM_APP_ID "123456789"

# STARTUP_COMMAND:  The command to run to start the server, 
#                   the current working directory is the server directory ($SERVER_DIR)
ENV STARTUP_COMMAND "server -configpath "$SERVER_CONFIG_DIR""

# Optional pre.sh script to run before the server starts
COPY pre.sh $USER_HOME/pre.sh

# Optional post.sh script to run after the server stops
COPY post.sh $USER_HOME/post.sh
```

If you want to install additional packages via apt,
make sure to become `USER root` before executing apt commands.
Obviously, you should also switch back to `USER $USER` after installing the packages.

## Environment Variables

The following environment variables are available in the base image:

| Variable            | Default Value                     | Description                                                                       |
|---------------------|-----------------------------------|-----------------------------------------------------------------------------------|
| `USER`              | `ubuntu`                          | The user to run the server as                                                     |
| `GROUP`             | `ubuntu`                          | The group to run the server as                                                    |
| `USER_HOME`         | `/home/$USER`                     | The home directory of the user                                                    |
| `STEAMCMD`          | `$USER_HOME/steamcmd/steamcmd.sh` | The path to the steamcmd executable                                               |
| `SERVER_DIR`        | `/data`                           | The directory where the server files are stored                                   |
| `SERVER_CONFIG_DIR` | `/config`                         | The directory where the server configuration files are stored                     |
| `STEAM_USERNAME`     | ``                                | Steam account username (empty = use anonymous login)                              |
| `STEAM_PASSWORD`     | ``                                | Steam account password (required if `STEAM_USERNAME` is set)                      |
| `STEAM_GUARD_CODE`   | ``                                | Steam Guard 2FA code (optional; if set, passed to SteamCMD login)                 |
| `FAST_BOOT`         | `false`                           | If set to `true`, the server will not be installed / updated / validated on start |

## Authentication

By default this image uses `login anonymous` when running SteamCMD.

Some dedicated servers (or private/beta branches) require an authenticated Steam account to download. In that case set:

- `STEAM_USERNAME`
- `STEAM_PASSWORD`

If Steam Guard (2FA) is enabled for the account, set `STEAM_GUARD_CODE` at container start.

Notes:
- Steam Guard codes expire quickly (typically ~30 seconds). If the container is restarted, you may need to provide a new code.
- SteamCMD stores login state under `~/.steam/`. If you mount a persistent volume for `$USER_HOME/.steam/`, restarts may not require Steam Guard again.
- Credentials passed via environment variables can be visible via `docker inspect` and similar tooling. Prefer Docker/Kubernetes secrets for production, and avoid baking credentials into images.
- SteamCMD script parsing is whitespace-based; usernames/passwords containing spaces may not work reliably.
