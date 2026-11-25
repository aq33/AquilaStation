"""Bot Discorda: komendy /wojna (stan wojny) i /mapa (obrazek mapy) z zapisu kampanii Aquili.

Zmienne środowiskowe:
  DISCORD_TOKEN       token bota (wymagany)
  AQUILA_STARMAP_DIR  folder z hexmap.json i starmap.json (domyślnie config/starmap tego repo)
  DISCORD_GUILD_ID    opcjonalnie: serwer Discorda, na którym komenda pojawi się od razu
"""

import asyncio
import io
import os
import sys
from pathlib import Path

import discord
from discord import app_commands

import war_map
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


def field_chunks(body, limit=1024):
    """Dzieli treść po wierszach na kawałki mieszczące się w polu embeda (1024 znaki)."""
    chunks = [""]
    for line in body.split("\n"):
        line = line[:limit]
        if chunks[-1] and len(chunks[-1]) + 1 + len(line) > limit:
            chunks.append("")
        chunks[-1] = f"{chunks[-1]}\n{line}" if chunks[-1] else line
    return chunks


@bot.tree.command(name="wojna", description="Stan wojny frakcji w kampanii Aquili")
async def wojna(interaction: discord.Interaction):
    state = war_status.load(STARMAP_DIR)
    if not state:
        await interaction.response.send_message("Brak zapisu kampanii albo wojna jeszcze nie ruszyła.", ephemeral=True)
        return
    embed = discord.Embed(title="Stan wojny", colour=FACTION_COLOUR)
    for title, body in war_status.sections(state):
        for i, chunk in enumerate(field_chunks(body)):
            embed.add_field(name=title if i == 0 else f"{title} (cd.)", value=chunk, inline=False)
    embed.set_footer(text=war_status.footer(state))
    await interaction.response.send_message(embed=embed)


@bot.tree.command(name="mapa", description="Mapa wojny frakcji w kampanii Aquili")
async def mapa(interaction: discord.Interaction):
    await interaction.response.defer()  # rysowanie może przekroczyć 3 s, w których Discord czeka na odpowiedź
    png = await asyncio.to_thread(war_map.render, STARMAP_DIR)
    if not png:
        await interaction.followup.send("Brak zapisu kampanii albo wojna jeszcze nie ruszyła.")
        return
    await interaction.followup.send(file=discord.File(io.BytesIO(png), filename="mapa_wojny.png"))


def main():
    token = os.environ.get("DISCORD_TOKEN")
    if not token:
        print("Ustaw zmienną DISCORD_TOKEN (token bota z Discord Developer Portal).")
        return 1
    bot.run(token)
    return 0


if __name__ == "__main__":
    sys.exit(main())
