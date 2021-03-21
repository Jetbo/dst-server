#!/bin/bash
set -e

# Require ENVs
: "${SERVER_PASSWORD?Need to set SERVER_PASSWORD}";
: "${SERVER_NAME?Need to set SERVER_NAME}";
: "${SERVER_DESCRIPTION?Need to set SERVER_DESCRIPTION}";
: "${SERVER_INTENTION?Need to set SERVER_INTENTION}";
: "${CLUSTER_NAME?Need to set CLUSTER_NAME}";
: "${CLUSTER_TOKEN?Need to set CLUSTER_TOKEN}";
: "${GAME_MODE?Need to set GAME_MODE}";
: "${MAX_PLAYERS?Need to set MAX_PLAYERS}";
: "${ENABLE_PVP?Need to set ENABLE_PVP}";
: "${ENABLE_CONSOLE?Need to set ENABLE_CONSOLE}";
: "${MAX_SNAPSHOTS?Need to set MAX_SNAPSHOTS}";

: "${HEALTH_CHECK_PORT?Need to set HEALTH_CHECK_PORT}";
: "${ENABLE_CLEAN_SHUTDOWN?Need to set ENABLE_CLEAN_SHUTDOWN}";
: "${UPDATE_ON_RUN?Need to set UPDATE_ON_RUN}";


# Output settings (but not password obviously)
echo "cluster_name is set to: $SERVER_NAME";
echo "cluster_description is set to: $SERVER_DESCRIPTION";
echo "cluster_intention is set to: $SERVER_INTENTION"
echo "game_mode is set to: $GAME_MODE";
echo "max_players is set to: $MAX_PLAYERS"
echo "pvp is set to: $ENABLE_PVP"
echo "console_enabled is set to: $ENABLE_CONSOLE"
echo "max_snapshots is set to: $MAX_SNAPSHOTS"
echo "Password will not be displayed";
echo "Cluster token will not be displayed";
echo "Server files will be under ~/.klei/DoNotStarveTogether/$CLUSTER_NAME"

echo "Health checks can be performed on port $HEALTH_CHECK_PORT";
echo "Clean shutdown is set to: $ENABLE_CLEAN_SHUTDOWN";
echo "Updates on run is set to: $UPDATE_ON_RUN";

# Set LinuxGSM config values with sed
sed -i "s/cluster=.*/cluster=\"$CLUSTER_NAME\"/" /home/linuxgsm/gsm/dstserver.cfg;
# Set cluster_token.txt value
echo '[AUTHTOKEN]' > /home/linuxgsm/gsm/cluster_token.txt
# Set cluster.ini config values with sed
sed -i "s/cluster_name =.*/cluster_name = $SERVER_NAME/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/cluster_description =.*/cluster_description = $SERVER_DESCRIPTION/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/cluster_password =.*/cluster_password = $SERVER_PASSWORD/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/cluster_intention =.*/cluster_intention = $SERVER_INTENTION/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/game_mode =.*/game_mode = $GAME_MODE/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/max_players =.*/max_players = $MAX_PLAYERS/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/pvp =.*/pvp = $ENABLE_PVP/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/console_enabled =.*/console_enabled = $ENABLE_CONSOLE/" /home/linuxgsm/gsm/cluster.ini
sed -i "s/max_snapshots =.*/max_snapshots = $MAX_SNAPSHOTS/" /home/linuxgsm/gsm/cluster.ini

# Create world (cluster) folder based on cluster name
mkdir -p /home/linuxgsm/.klei/DoNotStarveTogether/$CLUSTER_NAME/Master

# Move token and ini files to world (cluster) folder
cp /home/linuxgsm/gsm/cluster_token.txt /home/linuxgsm/.klei/DoNotStarveTogether/$CLUSTER_NAME/cluster_token.txt;
cp /home/linuxgsm/gsm/cluster.ini /home/linuxgsm/.klei/DoNotStarveTogether/$CLUSTER_NAME/cluster.ini;
cp /home/linuxgsm/gsm/server.ini /home/linuxgsm/.klei/DoNotStarveTogether/$CLUSTER_NAME/Master/server.ini;

# Replace LinuxGSM config
cp /home/linuxgsm/gsm/dstserver.cfg /home/linuxgsm/gsm/lgsm/config-lgsm/dstserver/dstserver.cfg;

# Enable mods
if [ "$ENABLE_MODS" = "1" ]
then
  echo "Enabling Mods...";
  cp /home/linuxgsm/gsm/dedicated_server_mods_setup.lua /home/linuxgsm/serverfiles/mods/dedicated_server_mods_setup.lua
  cp /home/linuxgsm/gsm/modsettings.lua /home/linuxgsm/serverfiles/mods/modsettings.lua
fi

# Run Updates
if [ "$UPDATE_ON_RUN" = "1" ]
then
  /home/linuxgsm/gsm/dstserver update-lgsm;
  /home/linuxgsm/gsm/dstserver update;
fi

# Start server
/home/linuxgsm/gsm/dstserver start;

# Start simple health check service
python3 -m http.server -d /home/linuxgsm/healthcheck/ $HEALTH_CHECK_PORT > /dev/null 2>&1 &

# Add a blank log so we can tail the initial setup
touch /home/linuxgsm/gsm/log/console/dstserver-console.log;

# Push the logs to stdout
tail -f /home/linuxgsm/gsm/log/console/dstserver-console.log &

# Server shutdown logic
shutdown() {
  echo "Saving World...";
  /home/linuxgsm/gsm/dstserver stop;
  echo "World was saved!";
}
if [ "$ENABLE_CLEAN_SHUTDOWN" = "1" ]
then
  # Trap exit signals
  trap 'shutdown' HUP INT QUIT TERM
fi

# Keep execution open and make sure signals are processed
wait $!
