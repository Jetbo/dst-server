# dst-server

Simple docker-compose setup for a Don't Starve Together server running on LinuxGSM. App can be built to be portable for cloud container services.

Build the app with `docker-compose up --build`.

You can change the ENVs in the docker-compose. ENVs control the basic server config.

```
SERVER_PASSWORD       # Sets the server password (string)
SERVER_NAME           # Sets the server name (string)
SERVER_DESCRIPTION    # Sets the server description (string)
SERVER_INTENTION      # Sets the server intention (cooperative|competitive|social|madness)
CLUSTER_NAME          # Sets the cluster name. This controls what directory your cluster runs in. (string)
CLUSTER_TOKEN         # Required token from Klei to run a server. SERVER WILL NOT START WITHOUT THIS! (string)
GAME_MODE             # Sets the game mode (survival|endless|wilderness)
MAX_PLAYERS           # Sets the max players (int, 1..64)
ENABLE_PVP            # Enables PVP (true|false)
ENABLE_CONSOLE        # Enables the Lua console (true|false)
MAX_SNAPSHOTS         # Number of backup snapshots to keep of your world (int)
HEALTH_CHECK_PORT     # Sets the health check port (int)
ENABLE_CLEAN_SHUTDOWN # Enables the clean shutdown script. This script runs the vhserver stop command on SIG traps. (0, 1)
UPDATE_ON_RUN         # Updates LinuxGSM and the Valheim server on run (0, 1)
```

If you want to make sure the world saves before the container exits, enable `ENABLE_CLEAN_SHUTDOWN` in the ENV. Don't Starve Together saves to the world files when players leave and in time intervals. Killing the container suddenly could lead to corruption or world progress loss, so I recommend enabling this option.

If you want to the server to update itself (like on a nightly reboot cron) enable `UPDATE_ON_RUN` in the ENV. This will run both the LinuxGSM and Don't Starve Together server update commands before the server boots up. Keep in mind the server will start faster with this disabled. If disabled, remember to update the server manually or re-build the container periodically to install new versions.

## Useful file locations

```
# Holds the Don't Starve Together world files
# This directory is setup as a volume to remain persistent
/home/linuxgsm/.klei/DoNotStarveTogether/

# GSM and game logs
# This directory is setup as a volume to remain persistent
/home/linuxgsm/gsm/log/
```

## Hot Tips

Don't forget to your Cluster Token from Klei or your game won't start!

- Go to the [Klei website](https://accounts.klei.com/login?goto=https://accounts.klei.com/account/game/servers).
- Get your game server authentication token.
- Enter a friendly name for your server and copy the access token and set CLUSTER_TOKEN.
