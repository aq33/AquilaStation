"""Bot Discorda: komendy /wojna (stan wojny) i /mapa (obrazek mapy) z zapisu kampanii Aquili.

Zmienne środowiskowe:
  DISCORD_TOKEN       token bota (wymagany)
  AQUILA_STARMAP_DIR  folder z hexmap.json i starmap.json (domyślnie config/starmap tego repo)
  DISCORD_GUILD_ID    opcjonalnie: serwer Discorda, na którym komenda pojawi się od razu
"""

import asyncio
import io
import logging
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
NO_SAVE_TEXT = "Brak zapisu kampanii albo wojna jeszcze nie ruszyła."
ERROR_TEXT = "Nie udało się odczytać zapisu kampanii. Szczegóły są w konsoli bota."


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
        # Wiersz dłuższy niż pole idzie w kilku kawałkach, nic nie jest ucinane
        pieces = [line[i:i + limit] for i in range(0, len(line), limit)] or [""]
        for piece in pieces:
            if chunks[-1] and len(chunks[-1]) + 1 + len(piece) > limit:
                chunks.append("")
            chunks[-1] = f"{chunks[-1]}\n{piece}" if chunks[-1] else piece
    return chunks


# Limity Discorda: 25 pól w embedzie, 6000 znaków we wszystkich embedach jednej wiadomości (zapas na tytuł i stopkę)
EMBED_FIELDS = 25
EMBED_CHARS = 5500


def build_embeds(state):
    """Raport jako lista embedów; każdy mieści się w limitach i idzie w osobnej wiadomości."""
    fields = []
    for title, body in war_status.sections(state):
        for i, chunk in enumerate(field_chunks(body)):
            fields.append((title if i == 0 else f"{title} (cd.)", chunk))
    embeds = []
    embed = None
    size = 0
    for name, value in fields:
        if embed is None or len(embed.fields) >= EMBED_FIELDS or size + len(name) + len(value) > EMBED_CHARS:
            embed = discord.Embed(title="Stan wojny" if not embeds else "Stan wojny (cd.)", colour=FACTION_COLOUR)
            embeds.append(embed)
            size = 0
        embed.add_field(name=name, value=value, inline=False)
        size += len(name) + len(value)
    embeds[-1].set_footer(text=war_status.footer(state))
    return embeds


@bot.tree.command(name="wojna", description="Stan wojny frakcji w kampanii Aquili")
async def wojna(interaction: discord.Interaction):
    # Odczyt może czekać na zapis kampanii (ponowienia w load), a Discord czeka na odpowiedź tylko 3 s
    await interaction.response.defer()
    try:
        state = await asyncio.to_thread(war_status.load, STARMAP_DIR)
        embeds = build_embeds(state) if state else None
    except Exception:
        logging.exception("/wojna: błąd przy czytaniu zapisu kampanii")
        await interaction.followup.send(ERROR_TEXT)
        return
    if not embeds:
        await interaction.followup.send(NO_SAVE_TEXT)
        return
    for embed in embeds:
        await interaction.followup.send(embed=embed)


@bot.tree.command(name="mapa", description="Mapa wojny frakcji w kampanii Aquili")
async def mapa(interaction: discord.Interaction):
    await interaction.response.defer()  # rysowanie może przekroczyć 3 s, w których Discord czeka na odpowiedź
    try:
        png = await asyncio.to_thread(war_map.render, STARMAP_DIR)
    except Exception:
        logging.exception("/mapa: błąd przy rysowaniu mapy")
        await interaction.followup.send(ERROR_TEXT)
        return
    if not png:
        await interaction.followup.send(NO_SAVE_TEXT)
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
