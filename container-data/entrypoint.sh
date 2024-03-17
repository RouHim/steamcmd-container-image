#!/usr/bin/env bash

# Make sure that $SERVER_DIR is accessible for all
chmod -R 777 "$SERVER_DIR" 2> /dev/null
chown -R nobody:nogroup "$SERVER_DIR" 2> /dev/null

# Make sure that $SERVER_CONFIG_DIR is accessible for all
chmod -R 777 "$SERVER_CONFIG_DIR" 2> /dev/null
chown -R nobody:nogroup "$SERVER_CONFIG_DIR" 2> /dev/null

# Check if $SERVER_DIR is writeable
if [ ! -w "$SERVER_DIR" ]; then
    echo "❌ Error: $SERVER_DIR is not writeable!"
    exit 1
fi
echo "✅ Server data is writeable!"

# Check if $SERVER_DIR is readable
if [ ! -r "$SERVER_DIR" ]; then
    echo "❌ Error: $SERVER_DIR is not readable!"
    exit 1
fi
echo "✅ Server data is readable!"

# Check if $SERVER_CONFIG_DIR is writeable
if [ ! -w "$SERVER_CONFIG_DIR" ]; then
    echo "❌ Error: $SERVER_CONFIG_DIR is not writeable!"
    exit 1
fi
echo "✅ Server config is writeable!"

# Check if $SERVER_CONFIG_DIR is readable
if [ ! -r "$SERVER_CONFIG_DIR" ]; then
    echo "❌ Error: $SERVER_CONFIG_DIR is not readable!"
    exit 1
fi
echo "✅ Server config is readable!"

# Check if STEAM_APP_ID is set
if [ -z "$STEAM_APP_ID" ]; then
    echo "❌ Error: STEAM_APP_ID is not set!"
    exit 1
fi

# Replace %STEAM_APP_ID% in steam-game.script
sed -i "s/%STEAM_APP_ID%/$STEAM_APP_ID/g" "$USER_HOME"/steam-game.script

# Update server
echo "🔄 Updating server..."
$STEAMCMD +runscript "$USER_HOME/steam-game.script"

# Check if pre.sh exists and execute it
if [ -f "$USER_HOME/pre.sh" ]; then
    echo "🔧 Executing pre.sh..."
    bash "$USER_HOME/pre.sh"
fi

# Start server and hold the process
echo "🎮 Starting server..."
cd "$SERVER_DIR" || exit
eval "$STARTUP_COMMAND"

# Check if post.sh exists and execute it
if [ -f "$USER_HOME/post.sh" ]; then
    echo "🔧 Executing post.sh..."
    bash USER_HOME/post.sh$
fi