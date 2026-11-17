"""Automatyczne zamienniki dla ścieżek Shiptesta, których nie ma w tablicach (resolve wołany przez convert_maps.py
po wczytaniu map). Ładuj jako ostatni moduł: ręczne zamienniki z modułów planet mają pierwszeństwo.

Reguły:
- turfy: zdejmuje przyrostki planet i wariantów (/lit, /interior, /iceplanet, /jungleplanet, /airless...), przyrostek
  planety daje atmosferę z PLANET_GAS (bez /interior: planetary_atmos), potem idzie w górę drzewa typów do pierwszego
  istniejącego u nas typu;
- obiekty /directional/<strona>: bez przyrostka, krzesła i kanapy dostają dir, kamery dir od ściany;
- pozostałe obiekty i moby: pierwszy istniejący przodek, jeśli nie jest zbyt ogólny (ABSTRACT) — wtedy pominięcie;
- dekale bez odpowiednika: pominięcie.
Każda decyzja trafia do DECISIONS (raport decisions.json).
"""
import re

from mappings.common import AREAS, DECISIONS, R, TURFS, WALL_CLOSETS

DIRS = {'north': 1, 'south': 2, 'east': 4, 'west': 8}
OPP = {'north': 2, 'south': 1, 'east': 8, 'west': 4}

# Przyrostek ścieżki turfu -> atmosfera (dopisują moduły planet)
PLANET_GAS = {}
# Przyrostki zdejmowane z turfów (warianty oświetlenia, atmosfery, smoothingu)
TURF_STRIP = {'lit', 'interior', 'airless', 'cold', 'safe', 'underground', 'high_chance', 'yesdiag', 'nodiag', 'mid',
	'surface', 'surface_craters', 'tesla_lab', 'hydrogen_fuel', 'noplanet', 'temperate', 'icemoon_turf'}
# Zbyt ogólni przodkowie: zamiast nich pominięcie (puste albo niewidoczne typy bazowe)
ABSTRACT = {
	'/turf', '/turf/open', '/turf/closed', '/turf/open/floor', '/turf/closed/wall', '/turf/closed/indestructible',
	'/obj', '/obj/item', '/obj/structure', '/obj/machinery', '/obj/effect', '/obj/effect/spawner', '/obj/effect/decal',
	'/obj/effect/decal/cleanable', '/obj/effect/mapping_helpers', '/obj/effect/abstract', '/obj/effect/landmark',
	'/obj/effect/mob_spawn', '/obj/effect/mob_spawn/human', '/obj/effect/turf_decal',
	'/obj/item/clothing', '/obj/item/clothing/under', '/obj/item/clothing/suit', '/obj/item/clothing/head',
	'/obj/item/clothing/mask', '/obj/item/clothing/neck', '/obj/item/clothing/glasses', '/obj/item/clothing/shoes',
	'/obj/item/clothing/gloves', '/obj/item/clothing/accessory', '/obj/item/storage', '/obj/item/reagent_containers',
	'/obj/item/reagent_containers/food', '/obj/item/reagent_containers/food/drinks', '/obj/item/reagent_containers/glass',
	'/obj/item/reagent_containers/pill', '/obj/item/stack', '/obj/item/stack/sheet', '/obj/item/stack/sheet/mineral',
	'/obj/item/gun', '/obj/item/gun/ballistic', '/obj/item/gun/energy', '/obj/item/ammo_box', '/obj/item/ammo_box/magazine',
	'/obj/item/ammo_casing', '/obj/item/food', '/obj/item/melee', '/obj/item/toy', '/obj/item/bodypart', '/obj/item/stock_parts',
	'/obj/item/circuitboard', '/obj/item/circuitboard/machine', '/obj/item/circuitboard/computer', '/obj/item/disk',
	'/obj/item/seeds', '/obj/item/trash', '/obj/item/mecha_parts', '/obj/item/documents', '/obj/item/storage/box/ammo',
	'/obj/structure/sign', '/obj/structure/flora', '/obj/structure/fluff', '/obj/structure/chair/sofa', '/obj/structure/platform',
	'/obj/machinery/computer', '/obj/machinery/power', '/obj/machinery/atmospherics', '/obj/machinery/atmospherics/components',
	'/obj/machinery/atmospherics/components/unary', '/obj/machinery/portable_atmospherics', '/obj/machinery/door',
	'/obj/item/attachment', '/obj/item/advertisement', '/obj/structure/hazard', '/obj/structure/salvageable',
	'/mob', '/mob/living', '/mob/living/basic', '/mob/living/simple_animal', '/mob/living/simple_animal/hostile',
	'/mob/living/carbon', '/mob/living/basic/human', '/obj/projectile', '/obj/item/projectile',
}
CHAIR_PREFIXES = ('/obj/structure/chair', '/obj/structure/barricade')


def ancestor(path, ours):
	"""Pierwszy istniejący przodek (albo sama ścieżka), None gdy trafimy na zbyt ogólny typ."""
	parts = path.split('/')
	for i in range(len(parts), 1, -1):
		cand = '/'.join(parts[:i])
		if cand in ABSTRACT:
			return None
		if cand in ours or cand in R or cand in TURFS:
			if cand in R:
				return R[cand]
			if cand in TURFS:
				return TURFS[cand]
			return cand
	return None


def resolve_turf(path, ours):
	segs = path.split('/')
	gas = None
	interior = False
	kept = []
	for seg in segs:
		if seg in PLANET_GAS:
			gas = PLANET_GAS[seg]
			continue
		if seg == 'interior':
			interior = True
			continue
		if seg in TURF_STRIP:
			continue
		kept.append(seg)
	base = '/'.join(kept)
	target = ancestor(base, ours)
	if target is None:
		return None
	extra = {}
	if isinstance(target, tuple):
		target, extra = target[0], dict(target[1])
	if gas and target.startswith('/turf/open'):
		extra['initial_gas_mix'] = gas
		if not interior:
			extra['planetary_atmos'] = '1'
		else:
			extra.pop('planetary_atmos', None)
	return (target, extra) if extra else target


def resolve(missing, ours):
	for path in sorted(missing):
		if path in R or path in TURFS or path in AREAS:
			continue
		if path.startswith('/area'):
			continue
		if path.startswith('/turf'):
			target = resolve_turf(path, ours)
			if target is not None:
				TURFS[path] = target
				DECISIONS[path] = 'auto: %s' % (target,)
			continue
		if path.startswith('/obj/effect/turf_decal'):
			R[path] = None
			DECISIONS[path] = 'auto: pominięty dekal bez odpowiednika'
			continue
		m = re.match(r'(.*?)/directional(?:/(north|south|east|west))?$', path)
		if m:
			base, side = m.group(1), m.group(2)
			if base in WALL_CLOSETS:
				continue  # convert_atom zamienia szafki ścienne sam
			target = R[base] if base in R else ancestor(base, ours)
			if target is None:
				R[path] = None
				DECISIONS[path] = 'auto: pominięty (brak odpowiednika)'
				continue
			extra = {}
			if isinstance(target, tuple):
				target, extra = target[0], dict(target[1])
			if side and base.startswith(CHAIR_PREFIXES) and DIRS[side] != 2:
				extra['dir'] = str(DIRS[side])
			elif side and base.startswith('/obj/machinery/camera') and OPP[side] != 2:
				extra['dir'] = str(OPP[side])
			R[path] = (target, extra) if extra else target
			DECISIONS[path] = 'auto: %s' % (R[path],)
			continue
		target = ancestor(path, ours)
		R[path] = target
		DECISIONS[path] = 'auto: %s' % (target if target else 'pominięty (brak odpowiednika)',)
