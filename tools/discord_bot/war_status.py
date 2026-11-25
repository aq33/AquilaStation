"""Stan wojny frakcji z zapisu kampanii Aquili (config/starmap/hexmap.json i starmap.json).

Czyta tylko pliki, które gra zapisuje na koniec rundy (i przy restarcie), więc nie wymaga żadnych zmian w grze ani
połączenia z serwerem. Pokazuje stan z chwili ostatniego zapisu, nie na żywo.

Bez Discorda: python tools/discord_bot/war_status.py [folder z hexmap.json]
"""

import json
import sys
from collections import Counter
from pathlib import Path

# Te same wartości co w aquila/code/modules/overmap/hexmap/ (war_core.dm, war_end.dm, war_nuke.dm, war_commanders.dm)
FACTION_NAMES = {
    "nanotrasen": "Nanotrasen",
    "solgov": "SolGov",
    "syndicate": "Syndykat",
    "pirate": "Piraci",
    "whiterapids": "White Rapids",
    "hostile": "Wrogie siły",
    "unaligned": "Niezależni",
    "uncharted": "Niezbadane",
}
MAIN_FACTIONS = ["nanotrasen", "solgov", "syndicate", "pirate"]
NT_BLOC = {"nanotrasen", "solgov", "whiterapids"}
HQ_SYSTEMS = {"nanotrasen": "Medea", "solgov": "Sol", "syndicate": "Abassi", "pirate": "Tortuga"}
HEX_WAR_END_ROUNDS = 2
RANKS = ["Kapitan", "Komandor", "Kontradmirał", "Admirał"]


def faction_name(faction):
    return FACTION_NAMES.get(faction, faction or "?")


def allied(a, b):
    return a == b or (a in NT_BLOC and b in NT_BLOC)


def defcon(tension):
    # war_nuke.dm, update_defcon(); blokady DEFCON 1 po wystrzale zapis nie przechowuje
    if tension >= 22:
        return 2
    if tension >= 13:
        return 3
    if tension >= 6:
        return 4
    return 5


def plural(n, one, few, many):
    """Polska odmiana: 1 flota, 2 floty, 5 flot."""
    if n == 1:
        return f"{n} {one}"
    if n % 10 in (2, 3, 4) and n % 100 not in (12, 13, 14):
        return f"{n} {few}"
    return f"{n} {many}"


def commander_name(c):
    rank = RANKS[max(0, min(c.get("rank") or 0, len(RANKS) - 1))]
    nick = f" „{c['nick']}”" if c.get("nick") else ""
    return f"{rank} {c.get('first', '')}{nick} {c.get('last', '')}".strip()


def load(folder):
    """Zwraca słownik ze stanem wojny albo None, gdy zapisu nie ma lub kampania jeszcze nie ruszyła."""
    folder = Path(folder)
    try:
        hexmap = json.loads((folder / "hexmap.json").read_text(encoding="utf-8"))
        starmap = json.loads((folder / "starmap.json").read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None
    war = hexmap.get("war")
    if not isinstance(war, dict):
        return None
    occupied = war.get("occupied") or {}
    if not isinstance(occupied, dict):  # pusta lista asocjacyjna DM zapisuje się jako []
        occupied = {}

    holders = {}
    owners = {}
    for system in starmap:
        name = system.get("name")
        if not name or name == "Staging":
            continue
        holders[name] = occupied.get(name, system.get("alignment"))
        owners[name] = system.get("owner")

    systems = Counter(holders.values())

    relocations = war.get("hq_relocations") or {}
    if not isinstance(relocations, dict):
        relocations = {}
    hqs = []
    for faction in MAIN_FACTIONS:
        hq = relocations.get(HQ_SYSTEMS[faction], HQ_SYSTEMS[faction])
        holder = holders.get(hq)
        hqs.append({"faction": faction, "system": hq, "holder": holder, "held": holder is None or allied(faction, holder),
                    "moved": hq != HQ_SYSTEMS[faction]})

    fleets = Counter()
    convoys = Counter()
    ships = Counter()
    for fleet in war.get("fleets") or []:
        side = fleet.get("alignment")
        if "aquila_convoy" in (fleet.get("type") or ""):
            convoys[side] += 1
        else:
            fleets[side] += 1
            ships[side] += fleet.get("ships") or 0

    commanders = war.get("commanders") or []
    status = Counter(c.get("status") for c in commanders)
    nemeses = [c for c in commanders if c.get("nemesis") and c.get("status") != "dead"]

    hq_lost = war.get("hq_lost") or {}
    nukes = war.get("nuke_stocks") or {}
    tension = war.get("tension") or 0
    return {
        "hexmap": hexmap,
        "starmap": starmap,
        "saved_at": hexmap.get("saved_at"),
        "map_name": hexmap.get("map_name"),
        "ship_system": hexmap.get("ship_system"),
        "systems": systems,
        "hqs": hqs,
        "occupied": {name: side for name, side in occupied.items() if owners.get(name) != side},
        "owners": owners,
        "fleets": fleets,
        "convoys": convoys,
        "ships": ships,
        "commanders": status,
        "nemeses": nemeses,
        "nt_rounds_without_hq": hq_lost.get("nanotrasen", 0) if isinstance(hq_lost, dict) else 0,
        "nt_evacuated": "nanotrasen" in {hq["faction"] for hq in hqs if hq["moved"]},
        "nukes": nukes if isinstance(nukes, dict) else {},
        "tension": tension,
        "defcon": defcon(tension),
        "syndicate_defeated": bool(war.get("syndicate_defeated")),
    }


def sections(state):
    """Stan wojny jako lista (tytuł, treść) gotowa do embeda Discorda albo wydruku."""
    out = []

    if state["syndicate_defeated"]:
        verdict = "Kwatera Syndykatu w Abassi zdobyta. Wojna kończy się zwycięstwem Nanotrasen."
    elif state["nt_rounds_without_hq"]:
        # war_end.dm: po HEX_WAR_END_ROUNDS rundach pierwsza utrata kwatery kończy się ewakuacją sztabu (war_retake.dm),
        # o ile jest dokąd; dopiero utrata kwatery po ewakuacji to przegrana
        outcome = "przegrana" if state["nt_evacuated"] else "ewakuacja sztabu albo przegrana"
        verdict = (f"Nanotrasen bez kwatery głównej od {plural(state['nt_rounds_without_hq'], 'rundy', 'rund', 'rund')} z rzędu "
                   f"({outcome} po {HEX_WAR_END_ROUNDS}).")
    else:
        verdict = "Wojna trwa."
    out.append(("Sytuacja", verdict))

    lines = []
    for faction in MAIN_FACTIONS:
        lines.append(f"**{faction_name(faction)}**: {plural(state['systems'].get(faction, 0), 'układ', 'układy', 'układów')}, "
                     f"{plural(state['fleets'].get(faction, 0), 'flota', 'floty', 'flot')} "
                     f"({plural(state['ships'].get(faction, 0), 'okręt', 'okręty', 'okrętów')})")
    others = sum(count for side, count in state["systems"].items() if side not in MAIN_FACTIONS)
    if others:
        lines.append(f"Pozostałe układy (niezależne, niezbadane): {others}")
    out.append(("Siły frakcji", "\n".join(lines)))

    lines = []
    for hq in state["hqs"]:
        where = hq["system"] + (" (po ewakuacji)" if hq["moved"] else "")
        if hq["held"]:
            lines.append(f"{faction_name(hq['faction'])}: {where}, w swoich rękach")
        else:
            lines.append(f"{faction_name(hq['faction'])}: {where}, **zajęta przez {faction_name(hq['holder'])}**")
    out.append(("Kwatery główne", "\n".join(lines)))

    if state["occupied"]:
        lines = [f"{name}: {faction_name(side)} (wcześniej {faction_name(state['owners'].get(name))})"
                 for name, side in sorted(state["occupied"].items())]
        out.append(("Zajęte układy", "\n".join(lines)))

    nukes = ", ".join(f"{faction_name(f)} {n}" for f, n in state["nukes"].items() if n) or "brak"
    out.append(("Napięcie", f"DEFCON {state['defcon']}\nGłowice atomowe: {nukes}"))

    cmd = state["commanders"]
    lines = [f"Aktywni: {cmd.get('active', 0)}, ranni: {cmd.get('wounded', 0)}, polegli: {cmd.get('dead', 0)}"]
    for c in state["nemeses"]:
        lines.append(f"Nemezis: {commander_name(c)} ({faction_name(c.get('faction'))})")
    out.append(("Dowódcy", "\n".join(lines)))

    if state["ship_system"]:
        out.append(("Okręt załogi", f"Ostatnio w układzie {state['ship_system']}"))
    return out


def footer(state):
    return f"Stan z zapisu kampanii {state['saved_at'] or '?'} (mapa {state['map_name'] or '?'})"


def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parents[2] / "config" / "starmap"
    sys.stdout.reconfigure(encoding="utf-8")
    state = load(folder)
    if not state:
        print("Brak zapisu kampanii albo wojna jeszcze nie ruszyła.")
        return 1
    for title, body in sections(state):
        print(f"== {title} ==\n{body}\n")
    print(footer(state))
    return 0


if __name__ == "__main__":
    sys.exit(main())
