"""Bot Discorda: komenda /wojna pokazuje stan wojny frakcji z zapisu kampanii Aquili.

Zmienne środowiskowe:
  DISCORD_TOKEN       token bota (wymagany)
  AQUILA_STARMAP_DIR  folder z hexmap.json i starmap.json (domyślnie config/starmap tego repo)
  DISCORD_GUILD_ID    opcjonalnie: serwer Discorda, na którym komenda pojawi się od razu
"""

import os
import sys
from pathlib import Path

import discord
from discord import app_commands

import war_status

FACTION_COLOUR = 0x2B6CB0
STARMAP_DIR = Path(os.environ.get("AQUILA_STARMAP_DIR") or Path(__file__).resolve().parents[2] / "config" / "starmap")
GUILD_ID = os.environ.get("DISCORD_GUILD_ID")


class WarBot(discord.Client):
    def __init__(self):
        super().__init__(intents=discord.Intents.none())
        self.tree = app_commands.CommandTree(self)

    async def setup_hook(self):
        if GUILD_ID:
            guild = discord.Object(id=int(GUILD_ID))
            self.tree.copy_global_to(guild=guild)
            await self.tree.sync(guild=guild)
        else:
            await self.tree.sync()  # komendy globalne Discord rozsyła z opóźnieniem


bot = WarBot()


@bot.tree.command(name="wojna", description="Stan wojny frakcji w kampanii Aquili")
async def wojna(interaction: discord.Interaction):
    state = war_status.load(STARMAP_DIR)
    if not state:
        await interaction.response.send_message("Brak zapisu kampanii albo wojna jeszcze nie ruszyła.", ephemeral=True)
        return
    embed = discord.Embed(title="Stan wojny", colour=FACTION_COLOUR)
    for title, body in war_status.sections(state):
        embed.add_field(name=title, value=body[:1024], inline=False)  # limit pola embeda
    embed.set_footer(text=war_status.footer(state))
    await interaction.response.send_message(embed=embed)


def main():
    token = os.environ.get("DISCORD_TOKEN")
    if not token:
        print("Ustaw zmienną DISCORD_TOKEN (token bota z Discord Developer Portal).")
        return 1
    bot.run(token)
    return 0


if __name__ == "__main__":
    sys.exit(main())
