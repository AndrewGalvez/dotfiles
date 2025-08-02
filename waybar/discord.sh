#!/bin/bash

# Discord Bot Setup and Online Friends Checker
# This script helps you create and use a Discord bot to check online friends

# Configuration
CONFIG_DIR="$HOME/.config/discord_bot"
CONFIG_FILE="$CONFIG_DIR/bot_config"
BOT_SCRIPT="$CONFIG_DIR/discord_bot.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Create config directory
mkdir -p "$CONFIG_DIR"

# Function to display bot creation instructions
show_bot_creation_instructions() {
    echo -e "${CYAN}=== Discord Bot Creation Instructions ===${NC}"
    echo ""
    echo -e "${YELLOW}Step 1: Create the Bot${NC}"
    echo "1. Go to https://discord.com/developers/applications"
    echo "2. Click 'New Application' and give it a name"
    echo "3. Go to the 'Bot' section in the left sidebar"
    echo "4. Click 'Add Bot'"
    echo "5. Under 'Token', click 'Copy' to get your bot token"
    echo ""
    echo -e "${YELLOW}Step 2: Configure Bot Permissions${NC}"
    echo "6. In the 'Bot' section, enable these Privileged Gateway Intents:"
    echo "   - Presence Intent"
    echo "   - Server Members Intent"
    echo "   - Message Content Intent (optional)"
    echo ""
    echo -e "${YELLOW}Step 3: Invite Bot to Your Server${NC}"
    echo "7. Go to the 'OAuth2' > 'URL Generator' section"
    echo "8. Select 'bot' in Scopes"
    echo "9. Select these Bot Permissions:"
    echo "   - View Channels"
    echo "   - Read Message History"
    echo "10. Copy the generated URL and open it to invite your bot"
    echo ""
    echo -e "${GREEN}Now run this script again to configure your bot!${NC}"
    echo ""
}

# Function to get bot configuration
setup_bot_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
    
    if [ -z "$BOT_TOKEN" ] || [ -z "$GUILD_ID" ]; then
        echo -e "${BLUE}=== Bot Configuration Setup ===${NC}"
        echo ""
        
        if [ -z "$BOT_TOKEN" ]; then
            echo -n "Enter your bot token: "
            read -r BOT_TOKEN
        fi
        
        if [ -z "$GUILD_ID" ]; then
            echo ""
            echo "To find your server (guild) ID:"
            echo "1. Enable Developer Mode in Discord (Settings > Advanced > Developer Mode)"
            echo "2. Right-click your server name and select 'Copy ID'"
            echo ""
            echo -n "Enter your server/guild ID: "
            read -r GUILD_ID
        fi
        
        # Save configuration
        cat > "$CONFIG_FILE" << EOF
BOT_TOKEN="$BOT_TOKEN"
GUILD_ID="$GUILD_ID"
EOF
        chmod 600 "$CONFIG_FILE"
        echo -e "${GREEN}Configuration saved!${NC}"
    fi
}

# Function to create Python bot script
create_bot_script() {
    cat > "$BOT_SCRIPT" << 'EOF'
#!/usr/bin/env python3
import discord
import asyncio
import os
import sys
from datetime import datetime

# Load configuration
config_file = os.path.expanduser("~/.config/discord_bot/bot_config")
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        for line in f:
            if line.startswith('BOT_TOKEN='):
                BOT_TOKEN = line.split('=')[1].strip().strip('"')
            elif line.startswith('GUILD_ID='):
                GUILD_ID = int(line.split('=')[1].strip().strip('"'))

# Bot setup with required intents
intents = discord.Intents.default()
intents.presences = True
intents.members = True
intents.guilds = True

client = discord.Client(intents=intents)

# Status symbols
STATUS_SYMBOLS = {
    discord.Status.online: "🟢",
    discord.Status.idle: "🟡", 
    discord.Status.dnd: "🔴",
    discord.Status.offline: "⚫",
    discord.Status.invisible: "⚫"
}

@client.event
async def on_ready():
    print(f'✅ Bot connected as {client.user}')
    print(f'📊 Monitoring server: {client.get_guild(GUILD_ID)}')
    print('-' * 50)
    
    guild = client.get_guild(GUILD_ID)
    if not guild:
        print("❌ Could not find the specified server!")
        await client.close()
        return
    
    # Get all members and their status
    online_members = []
    idle_members = []
    dnd_members = []
    offline_members = []
    
    for member in guild.members:
        if member.bot:
            continue  # Skip bots
            
        status = member.status
        name = f"{member.display_name}"
        
        # Group by status
        if status == discord.Status.online:
            online_members.append(name)
        elif status == discord.Status.idle:
            idle_members.append(name)
        elif status == discord.Status.dnd:
            dnd_members.append(name)
        else:
            offline_members.append(name)
    
    # Display results
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    if online_members:
        print("🟢 ONLINE:")
        for member in sorted(online_members):
            print(f"   • {member}")
        print()
    
    if idle_members:
        print("🟡 IDLE/AWAY:")
        for member in sorted(idle_members):
            print(f"   • {member}")
        print()
    
    if dnd_members:
        print("🔴 DO NOT DISTURB:")
        for member in sorted(dnd_members):
            print(f"   • {member}")
        print()
    
    total_online = len(online_members) + len(idle_members) + len(dnd_members)
    total_members = len([m for m in guild.members if not m.bot])
    
    print(f"📈 Summary: {total_online}/{total_members} members online")
    print(f"   Online: {len(online_members)} | Idle: {len(idle_members)} | DND: {len(dnd_members)} | Offline: {len(offline_members)}")
    
    await client.close()

@client.event
async def on_error(event, *args, **kwargs):
    print(f"❌ An error occurred: {event}")

# Run the bot
if __name__ == "__main__":
    try:
        if 'BOT_TOKEN' not in locals() or 'GUILD_ID' not in locals():
            print("❌ Bot token or guild ID not configured!")
            print("Run the setup script first.")
            sys.exit(1)
        
        client.run(BOT_TOKEN)
    except discord.LoginFailure:
        print("❌ Invalid bot token!")
    except discord.PrivilegedIntentsRequired:
        print("❌ Bot needs privileged intents enabled!")
        print("Enable Presence Intent and Server Members Intent in Discord Developer Portal")
    except Exception as e:
        print(f"❌ Error: {e}")
EOF
    
    chmod +x "$BOT_SCRIPT"
    echo -e "${GREEN}Bot script created at $BOT_SCRIPT${NC}"
}

# Function to check if discord.py is installed
check_discord_py() {
    if ! python3 -c "import discord" 2>/dev/null; then
        echo -e "${YELLOW}discord.py not installed. Installing...${NC}"
        
        # Try different installation methods
        if command -v pip3 >/dev/null; then
            pip3 install discord.py
        elif command -v pip >/dev/null; then
            pip install discord.py
        else
            echo -e "${RED}pip not found. Please install discord.py manually:${NC}"
            echo "pip3 install discord.py"
            exit 1
        fi
    fi
}

# Function to run the bot
run_bot() {
    echo -e "${BLUE}🤖 Starting Discord bot...${NC}"
    echo ""
    python3 "$BOT_SCRIPT"
}

# Function to create a simple shell interface
create_shell_wrapper() {
    cat > "$CONFIG_DIR/check_friends.sh" << EOF
#!/bin/bash
cd "$CONFIG_DIR"
python3 discord_bot.py
EOF
    chmod +x "$CONFIG_DIR/check_friends.sh"
    
    echo -e "${GREEN}Shell wrapper created at $CONFIG_DIR/check_friends.sh${NC}"
    echo "You can run it with: $CONFIG_DIR/check_friends.sh"
}

# Main execution
echo -e "${CYAN}=== Discord Bot Setup for Online Friends ===${NC}"
echo ""

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}First time setup detected.${NC}"
    echo ""
    echo "Do you already have a Discord bot? (y/n)"
    read -r has_bot
    
    if [[ $has_bot != "y" && $has_bot != "Y" ]]; then
        show_bot_creation_instructions
        exit 0
    fi
fi

# Setup configuration
setup_bot_config

# Check Python dependencies
check_discord_py

# Create bot script
create_bot_script

# Create shell wrapper
create_shell_wrapper

# Ask if user wants to run now
echo ""
echo "Setup complete! Would you like to test the bot now? (y/n)"
read -r run_now

if [[ $run_now == "y" || $run_now == "Y" ]]; then
    run_bot
else
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
    echo "To check online friends, run:"
    echo "  $CONFIG_DIR/check_friends.sh"
    echo ""
    echo "Or run the Python script directly:"
    echo "  python3 $BOT_SCRIPT"
fi
