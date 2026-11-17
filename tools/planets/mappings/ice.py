"""Zamienniki dla map planety lodowej i dżunglowej (ruiny IceRuins/JungleRuins i greeble ice/jungle z Shiptesta).
Wspólne dla obu planet (te same frakcje, fauna i wyposażenie), jungle.py tylko importuje ten moduł.
Ładuj z auto: --mappings ice,auto (albo jungle,auto)."""
import re

from mappings import auto
from mappings.common import AREAS, DECISIONS, R, TR, TURFS, WALL_CLOSETS, rep

ICE_GAS = '"o2=26;n2=104;TEMP=255"'
JUNGLE_GAS = '"o2=22;n2=89;co2=2;TEMP=308"'
auto.PLANET_GAS.update({'iceplanet': ICE_GAS, 'icemoon': ICE_GAS, 'jungleplanet': JUNGLE_GAS})

# --- turfy naturalne (nasze typy z shiptest_flora/ice.dm i jungle.dm)
for p, n in {
	'/turf/open/floor/plating/asteroid/snow': '/turf/open/floor/plating/asteroid/snow/planet_ice',
	'/turf/open/floor/plating/asteroid/snow/lit': '/turf/open/floor/plating/asteroid/snow/planet_ice',
	'/turf/open/floor/plating/ice/icemoon': '/turf/open/floor/plating/ice/planet_ice',
	'/turf/open/floor/plating/asteroid/basalt/iceplanet': '/turf/open/floor/plating/asteroid/basalt/planet_ice',
	'/turf/open/lava/plasma/ice_moon': '/turf/open/lava/plasma/planet_ice',
	'/turf/open/lava/plasma/ice_moon/safe': '/turf/open/lava/plasma/planet_ice',
	'/turf/open/water/iceplanet': '/turf/open/water/planet/beach/ice',
	'/turf/open/water/iceplanet/deep': '/turf/open/water/planet/beach/deep/ice',
	'/turf/closed/mineral/random/snow': '/turf/closed/mineral/random/planet_ice',
	'/turf/closed/mineral/random/snow/high_chance': '/turf/closed/mineral/random/planet_ice/high_chance',
	'/turf/closed/mineral/random/snow/underground': '/turf/closed/mineral/random/planet_ice/underground',
	'/turf/closed/mineral/ice': '/turf/closed/mineral/planet_ice_wall',
	'/turf/closed/mineral/gibtonite/ice/icemoon': '/turf/closed/mineral/gibtonite/planet_ice',
	'/turf/open/floor/plating/asteroid/dirt/wasteland': '/turf/open/floor/plating/asteroid/dirt/jungle/wasteland',
	'/turf/open/floor/plating/asteroid/sand/jungle': '/turf/open/floor/plating/asteroid/river_sand',
	'/turf/open/floor/plating/asteroid/sand/jungle/lit': '/turf/open/floor/plating/asteroid/river_sand',
	'/turf/open/water/jungle': '/turf/open/water/planet/jungle',
	'/turf/open/water/jungle/lit': '/turf/open/water/planet/jungle',
	'/turf/open/water/jungle/blood': '/turf/open/water/planet/jungle/blood',
	'/turf/closed/mineral/random/jungle': '/turf/closed/mineral/random/planet_jungle',
	'/turf/closed/mineral/random/jungle/polluted': '/turf/closed/mineral/random/planet_jungle/polluted',
	'/turf/open/floor/ship/dirt/dark': '/turf/open/floor/plating/asteroid/dirt/jungle/dark',
	'/turf/open/floor/grass/ship/jungle': '/turf/open/floor/plating/asteroid/dirt/grass/jungle',
	'/turf/closed/indestructible/wood': '/turf/closed/indestructible/riveted',
	'/turf/open/floor/plastic': '/turf/open/floor/plasteel/white',
	'/turf/open/floor/suns/diagonal/walnut/cold': '/turf/open/floor/wood',
	'/turf/open/floor/wood/ebony': '/turf/open/floor/wood',
	'/turf/open/floor/wood/maple': '/turf/open/floor/wood',
	'/turf/open/floor/wood/mahogany': '/turf/open/floor/wood',
	'/turf/open/floor/plasteel/stairs/mid': '/turf/open/floor/plasteel/stairs',
}.items():
	TURFS[p] = n
DECISIONS['turfy lodu i dżungli'] = 'naturalne turfy Shiptesta -> nasze z shiptest_flora/ice.dm i jungle.dm; podłogi */iceplanet, */jungleplanet -> nasz typ z atmosferą planety (auto)'

# --- obszary: na zewnątrz -> powierzchnia planety (load_ruin przepina), jaskinie -> wspólna jaskinia, greeble bez obszaru
from mappings import ice_areas, ice_tr  # noqa: E402,F401
AREAS.update(ice_areas.AREAS)
AREAS.update({
	'/area/overmap_encounter/planetoid/ice/explored': '/area/lavaland/surface/outdoors',
	'/area/overmap_encounter/planetoid/jungle/explored': '/area/lavaland/surface/outdoors',
	'/area/overmap_encounter/planetoid/cave': '/area/ruin/unpowered/planet_lava/cave',
})

# --- fauna
for p, n in {
	'/mob/living/basic/bear/polar': '/mob/living/basic/mining/polarbear',
	'/mob/living/basic/bear/polar/warrior': '/mob/living/basic/mining/polarbear/warrior',
	'/mob/living/basic/hivebot/ranged': '/mob/living/basic/hivebot/range',
	'/mob/living/simple_animal/crab': '/mob/living/basic/crab',
	'/mob/living/simple_animal/hostile/abandoned_minebot': '/mob/living/basic/hivebot',
	'/mob/living/simple_animal/hostile/asteroid/basilisk/watcher': '/mob/living/basic/mining/watcher',
	'/mob/living/simple_animal/hostile/asteroid/brimdemon': '/mob/living/basic/mining/brimdemon',
	'/mob/living/simple_animal/hostile/asteroid/goliath': '/mob/living/basic/mining/goliath',
	'/mob/living/simple_animal/hostile/asteroid/hivelord/legion/advanced': '/mob/living/basic/mining/legion',
	'/mob/living/simple_animal/hostile/asteroid/hivelord/legion/sauna': '/mob/living/basic/mining/legion',
	'/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow': '/mob/living/basic/mining/legion/snow',
	'/mob/living/simple_animal/hostile/asteroid/hivelord/legion/snow/nest': '/mob/living/basic/mining/legion/snow/spawner_made',
	'/mob/living/simple_animal/hostile/asteroid/ice_demon': '/mob/living/basic/mining/ice_demon',
	'/mob/living/simple_animal/hostile/asteroid/old_demon': '/mob/living/basic/mining/ice_demon/old',
	'/mob/living/simple_animal/hostile/asteroid/ice_whelp': '/mob/living/basic/mining/ice_whelp',
	'/mob/living/simple_animal/hostile/asteroid/lobstrosity': '/mob/living/basic/mining/lobstrosity',
	'/mob/living/simple_animal/hostile/asteroid/wolf': '/mob/living/basic/mining/wolf',
	'/mob/living/simple_animal/hostile/asteroid/wolf/alpha': '/mob/living/basic/mining/wolf/alpha',
	'/mob/living/simple_animal/hostile/asteroid/wolf/random': '/mob/living/basic/mining/wolf/random',
	'/mob/living/simple_animal/hostile/asteroid/wolf/hound/hermit': '/mob/living/basic/mining/wolf',
	'/mob/living/simple_animal/hostile/automated/bipedal/makosso': ('/mob/living/basic/hivebot/range', {'faction': 'list("Syndicate")'}),
	'/mob/living/simple_animal/hostile/automated/walkmine/makosso': '/obj/effect/mine/explosive',
	'/mob/living/simple_animal/hostile/carp': '/mob/living/basic/carp',
	'/mob/living/simple_animal/hostile/jungle/seedling/mining': '/mob/living/simple_animal/hostile/jungle/seedling',
	'/mob/living/simple_animal/hostile/venus_human_trap/mining': '/mob/living/simple_animal/hostile/jungle/seedling',
	'/mob/living/simple_animal/hostile/poison/giant_spider': '/mob/living/simple_animal/hostile/spider/giant',
	'/mob/living/simple_animal/hostile/poison/giant_spider/hunter': '/mob/living/simple_animal/hostile/spider/giant/hunter',
	'/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper': '/mob/living/simple_animal/hostile/spider/giant/viper',
	'/mob/living/simple_animal/hostile/poison/giant_spider/nurse': '/mob/living/simple_animal/hostile/spider/giant/nurse',
	'/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife': '/mob/living/simple_animal/hostile/spider/giant/midwife',
	'/mob/living/simple_animal/hostile/poison/giant_spider/tarantula': '/mob/living/simple_animal/hostile/spider/giant/tarantula',
	'/mob/living/simple_animal/hostile/retaliate/chicken': '/mob/living/basic/chicken',
	'/mob/living/simple_animal/hostile/retaliate/poison/snake': '/mob/living/basic/snake',
}.items():
	rep(p, n)
DECISIONS['fauna Shiptesta'] = 'simple animale Shiptesta -> nasze basic moby z partii fauny (wilk, niedźwiedź polarny, demon, smok, homarzysko, śnieżny legion); pająki -> nasze simple pająki; mina krocząca -> mina; venus -> siewka'

# --- zwłoki
for p, n in {
	'/obj/effect/mob_spawn/human/corpse/clip': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/clip/medtech': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/clip/vc': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/damaged/sauna': '/obj/effect/mob_spawn/human/corpse/damaged',
	'/obj/effect/mob_spawn/human/corpse/frontier/ranged/trooper': '/obj/effect/mob_spawn/human/corpse/pirate/ranged',
	'/obj/effect/mob_spawn/human/corpse/hardliner/trooper': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/mob_spawn/human/corpse/indie/engineer': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/indie/manager': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/inteq/artificer': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/mob_spawn/human/corpse/ramzi/space': '/obj/effect/mob_spawn/human/corpse/syndicatecommando',
	'/obj/effect/mob_spawn/human/corpse/ruin/ns_mine_miner': '/obj/effect/mob_spawn/human/corpse/cargo_tech',
	'/obj/effect/mob_spawn/human/corpse/ruin/ns_mine_miner/armored': '/obj/effect/mob_spawn/human/corpse/heavy',
	'/obj/effect/mob_spawn/human/corpse/srm/hunter': '/obj/effect/mob_spawn/human/corpse/russian/ranged',
	'/obj/effect/mob_spawn/human/corpse/vigilitas_trooper': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/animal_corpse/goliath': None,
	'/obj/effect/mob_spawn/animal_corpse/junglefowl': None,
	'/obj/effect/mob_spawn/animal_corpse/monkey': None,
}.items():
	rep(p, n)
DECISIONS['/obj/effect/mob_spawn/animal_corpse/*'] = 'pominięte: zwłoki zwierząt (nie mamy spawnera zwłok zwierząt)'

# --- spawnery, efekty, pomocnicy map
for p, n in {
	'/obj/effect/abstract/particle_holder/steam': None,
	'/obj/effect/decal/cleanable/confetti': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/decal/cleanable/glass/plastitanium': '/obj/effect/decal/cleanable/glass',
	'/obj/effect/decal/cleanable/glass/strange': '/obj/effect/decal/cleanable/glass',
	'/obj/effect/decal/cleanable/robot_debris/gib': '/obj/effect/decal/cleanable/robot_debris',
	'/obj/effect/mapping_helpers/airlock/sealed': None,
	'/obj/effect/mapping_helpers/airlock/welded': None,
	'/obj/effect/mapping_helpers/airlock_note_placer': None,
	'/obj/effect/mapping_helpers/crate_shelve': None,
	'/obj/effect/mapping_helpers/turf/burnt': None,
	'/obj/effect/radiation': None,
	'/obj/effect/radiation/waste': None,
	'/obj/effect/spawner/random/bedsheet/double': '/obj/item/bedsheet/random',
	'/obj/effect/spawner/random/circuit/computer': None,
	'/obj/effect/spawner/random/circuit/machine/common': None,
	'/obj/effect/spawner/random/entertainment/cigarette': '/obj/item/storage/fancy/cigarettes',
	'/obj/effect/spawner/random/entertainment/cigarette_pack': '/obj/item/storage/fancy/cigarettes',
	'/obj/effect/spawner/random/maintenance/two': '/obj/effect/spawner/lootdrop/maintenance/two',
	'/obj/effect/spawner/random/maintenance/three': '/obj/effect/spawner/lootdrop/maintenance/three',
	'/obj/effect/spawner/random/maintenance/four': '/obj/effect/spawner/lootdrop/maintenance/four',
	'/obj/effect/spawner/random/medical/patient_stretcher': '/obj/structure/bed/roller',
	'/obj/effect/spawner/random/salvage/machine': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/effect/spawner/random/trash': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/spawner/random/trash/cigbutt': '/obj/item/cigbutt',
	'/obj/effect/spawner/random/trash/crushed_can': '/obj/item/trash/can',
	'/obj/effect/spawner/random/trash/food_packaging': '/obj/item/trash/chips',
	'/obj/effect/spawner/random/trash/garbage': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/spawner/random/trash/grime': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/spawner/random/trash/mess': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/spawner/random/trash/mopbucket': '/obj/item/reagent_containers/glass/bucket',
	'/obj/effect/spawner/random/vending/cola': '/obj/machinery/vending/cola/random',
}.items():
	rep(p, n)

# --- maszyny
TURRET = '/obj/machinery/porta_turret/syndicate'
for p, n in {
	'/obj/machinery/atmospherics/components/unary/shuttle/fire_heater': None,
	'/obj/machinery/atmospherics/components/unary/tank/fuel': None,
	'/obj/machinery/autolathe/hacked': '/obj/machinery/modular_fabricator/autolathe/hacked',
	'/obj/machinery/computer/cryopod/retro/directional/north': None,
	'/obj/machinery/computer/helm/retro': ('/obj/structure/frame/computer', {'anchored': '1'}),
	'/obj/machinery/computer/solar_control': '/obj/machinery/power/solar_control',
	'/obj/machinery/door/airlock/vault/derelict': '/obj/machinery/door/airlock/vault',
	'/obj/machinery/fax/indie': None,
	'/obj/machinery/fax/ramzi': None,
	'/obj/machinery/fax/syndicate': None,
	'/obj/machinery/holopad/emergency/command': '/obj/machinery/holopad',
	'/obj/machinery/holopad/emergency/security': '/obj/machinery/holopad',
	'/obj/machinery/hydroponics/soil': None,
	'/obj/machinery/light/street': '/obj/machinery/light',
	'/obj/machinery/navbeacon/wayfinding/dorms': None,
	'/obj/machinery/porta_turret/ruin/frontiersmen': TURRET,
	'/obj/machinery/porta_turret/ruin/frontiersmen/light': TURRET,
	'/obj/machinery/porta_turret/ruin/ramzi': TURRET,
	'/obj/machinery/porta_turret/ruin/ramzi/heavy': '/obj/machinery/porta_turret/syndicate/energy/heavy',
	'/obj/machinery/porta_turret/ruin/warra/light': TURRET,
	'/obj/machinery/porta_turret/ship/clip': TURRET,
	'/obj/machinery/porta_turret/ship/clip/light': TURRET,
	'/obj/machinery/portable_atmospherics/canister/carbon_monoxide': '/obj/machinery/portable_atmospherics/canister/carbon_dioxide',
	'/obj/machinery/portable_atmospherics/canister/chlorine': '/obj/machinery/portable_atmospherics/canister',
	'/obj/machinery/portable_atmospherics/canister/hydrogen': '/obj/machinery/portable_atmospherics/canister',
	'/obj/machinery/power/shieldwallgen/atmos': None,
	'/obj/machinery/power/shuttle/engine/fire': None,
	'/obj/machinery/power/smes/shuttle': '/obj/machinery/power/smes',
	'/obj/machinery/smartfridge/bloodbank/preloaded': '/obj/machinery/smartfridge',
	'/obj/machinery/telecomms/relay/preset/minutemen': None,
}.items():
	rep(p, n)
DECISIONS['wieżyczki frakcji'] = 'wieżyczki ruin (frontiersmen, Ramzi, Vigilitas, CLIP) -> wieżyczki Syndykatu (wrogie załodze), ciężka -> energetyczna ciężka'
DECISIONS['/obj/machinery/portable_atmospherics/canister/*'] = 'kanistry gazów, których nie mamy (CO, chlor, wodór) -> CO2 albo pusty kanister'

# --- struktury
for p, n in {
	'/obj/structure/barricade/concrete': '/obj/structure/barricade/sandbags',
	'/obj/structure/barricade/directional/flippedtable/fancy': '/obj/structure/barricade/wooden/crude',
	'/obj/structure/barricade/directional/flippedtable/wood': '/obj/structure/barricade/wooden/crude',
	'/obj/structure/catwalk': '/obj/structure/lattice/catwalk',
	'/obj/structure/chair/bench/blue': '/obj/structure/chair/fancy/bench',
	'/obj/structure/chair/bench/orange': '/obj/structure/chair/fancy/bench',
	'/obj/structure/chair/bench/red': '/obj/structure/chair/fancy/bench',
	'/obj/structure/chair/comfy/beige/corpo': '/obj/structure/chair/fancy/comfy',
	'/obj/structure/chair/comfy/beige/old': '/obj/structure/chair/fancy/comfy',
	'/obj/structure/chair/comfy/grey/old/alt': '/obj/structure/chair/fancy/comfy',
	'/obj/structure/chair/comfy/orange/old/alt': '/obj/structure/chair/fancy/comfy',
	'/obj/structure/chair/pew': '/obj/structure/chair/fancy/bench/pew',
	'/obj/structure/chair/pew/left': '/obj/structure/chair/fancy/bench/pew/left',
	'/obj/structure/chair/pew/right': '/obj/structure/chair/fancy/bench/pew/right',
	'/obj/structure/chair/sofa/blue/corpo': '/obj/structure/chair/fancy/sofa/corp',
	'/obj/structure/chair/sofa/blue/corpo/left': '/obj/structure/chair/fancy/sofa/corp/left',
	'/obj/structure/chair/sofa/blue/corpo/right': '/obj/structure/chair/fancy/sofa/corp/right',
	'/obj/structure/chair/sofa/brown/corpo': '/obj/structure/chair/fancy/sofa/corp',
	'/obj/structure/chair/sofa/blue/old/left': '/obj/structure/chair/fancy/sofa/old/left',
	'/obj/structure/chair/sofa/blue/old/right': '/obj/structure/chair/fancy/sofa/old/right',
	'/obj/structure/chair/sofa/brown/left': '/obj/structure/chair/fancy/sofa/old/left',
	'/obj/structure/chair/sofa/brown/right': '/obj/structure/chair/fancy/sofa/old/right',
	'/obj/structure/chair/sofa/olive/old/left': '/obj/structure/chair/fancy/sofa/old/left',
	'/obj/structure/chair/sofa/olive/old/right': '/obj/structure/chair/fancy/sofa/old/right',
	'/obj/structure/closet/crate/grave': '/obj/structure/closet/crate/coffin',
	'/obj/structure/closet/crate/rations': '/obj/structure/closet/crate',
	'/obj/structure/closet/crate/trashcart/laundry': '/obj/structure/closet/crate/trashcart',
	'/obj/structure/closet/mob_capture': '/obj/structure/closet/crate/critter',
	'/obj/structure/closet/secure_closet/medicalsrm': '/obj/structure/closet/secure_closet/medical1',
	'/obj/structure/closet/secure_closet/miningcloset': '/obj/structure/closet/secure_closet/miner',
	'/obj/structure/curtain/cloth/fancy': '/obj/structure/curtain',
	'/obj/structure/destructible/tribal_torch/lit': '/obj/structure/bonfire/prelit',
	'/obj/structure/displaycase/broken': '/obj/structure/displaycase',
	'/obj/structure/fermenting_barrel/distiller': '/obj/structure/fermenting_barrel',
	'/obj/structure/fermenting_barrel/trickwine': '/obj/structure/fermenting_barrel',
	'/obj/structure/flora/ash/garden/waste': '/obj/structure/flora/ash/garden',
	'/obj/structure/flora/ash/glowshroom': '/obj/structure/glowshroom',
	'/obj/structure/flora/ash/space': None,
	'/obj/structure/flora/ash/space/voidmelon': None,
	'/obj/structure/flora/bigplant': '/obj/item/kirbyplants/random',
	'/obj/structure/flora/driftlog': '/obj/structure/flora/tree/dead',
	'/obj/structure/flora/driftwood': '/obj/structure/flora/tree/dead',
	'/obj/structure/flora/grass/rockplanet': '/obj/structure/flora/ausbushes/sparsegrass',
	'/obj/structure/flora/grass/rockplanet/dead': '/obj/structure/flora/ausbushes/sparsegrass',
	'/obj/structure/flora/rock/asteroid': '/obj/structure/flora/rock',
	'/obj/structure/flora/rock/crystal/puce': '/obj/structure/flora/ash/puce',
	'/obj/structure/flora/tree/tall': '/obj/structure/flora/tree/jungle',
	'/obj/structure/fluff/beach_umbrella/cap': None,
	'/obj/structure/fluff/big_chain': None,
	'/obj/structure/fluff/hedge': '/obj/structure/flora/ausbushes/grassybush',
	'/obj/structure/fluff/hedge/opaque': '/obj/structure/flora/ausbushes/grassybush',
	'/obj/structure/fountain': None,
	'/obj/structure/geyser/water': '/obj/structure/geyser/random',
	'/obj/structure/holosign/barrier/engineering/infinite': '/obj/structure/holosign/barrier/engineering',
	'/obj/structure/mecha_wreckage/ripley/clip': '/obj/structure/mecha_wreckage/ripley',
	'/obj/structure/poddoor_assembly': None,
	'/obj/structure/railing/corner/wood': '/obj/structure/railing/corner',
	'/obj/structure/railing/modern': '/obj/structure/railing',
	'/obj/structure/railing/thick': '/obj/structure/railing',
	'/obj/structure/railing/thick/corner': '/obj/structure/railing/corner',
	'/obj/structure/railing/thin': '/obj/structure/railing',
	'/obj/structure/railing/thin/corner': '/obj/structure/railing/corner',
	'/obj/structure/reagent_dispensers/cooking_oil': '/obj/structure/reagent_dispensers/watertank',
	'/obj/structure/reagent_dispensers/servingdish': None,
	'/obj/structure/sauna_oven': '/obj/structure/fireplace',
	'/obj/structure/sink/oil_well': '/obj/structure/sink',
	'/obj/structure/spider/fake_eggcluster': '/obj/structure/spider/stickyweb',
	'/obj/structure/table/rolling': '/obj/structure/table',
	'/obj/structure/toilet/greyscale': '/obj/structure/toilet',
	'/obj/structure/toilet/secret/bolide': '/obj/structure/toilet',
}.items():
	rep(p, n)
for p in ['/obj/structure/platform', '/obj/structure/platform/corner', '/obj/structure/platform/industrial_alt',
		'/obj/structure/platform/industrial_alt/corner', '/obj/structure/platform/military', '/obj/structure/platform/military/corner',
		'/obj/structure/platform/ship', '/obj/structure/platform/ship/corner', '/obj/structure/platform/ship_two',
		'/obj/structure/platform/ship_two/corner', '/obj/structure/platform/ship_three', '/obj/structure/platform/ship_three/corner',
		'/obj/structure/platform/ship_four', '/obj/structure/platform/ship_four/corner', '/obj/structure/platform/wood',
		'/obj/structure/platform/wood/corner', '/obj/structure/platform/wood_two', '/obj/structure/platform/wood_two/corner',
		'/obj/structure/hazard/electrical/electric_sparks/alarm', '/obj/structure/hazard/fire/wires/alarm',
		'/obj/structure/hazard/floor/burglar_alarm', '/obj/structure/hazard/radioactive/stack', '/obj/structure/hazard/radioactive/waste',
		'/obj/structure/sign/number', '/obj/structure/sign/number/random']:
	R[p] = None
for p in ['/obj/structure/salvageable/airbase/cannon', '/obj/structure/salvageable/airbase/missile_launcher',
		'/obj/structure/salvageable/autolathe', '/obj/structure/salvageable/server']:
	R[p] = ('/obj/structure/frame/machine', {'anchored': '1'})
WALL_CLOSETS.update({
	'/obj/structure/closet/wall/blue': '/obj/structure/closet',
	'/obj/structure/closet/wall/orange': '/obj/structure/closet',
	'/obj/structure/closet/secure_closet/freezer/wall': '/obj/structure/closet/secure_closet/freezer/kitchen',
})
DECISIONS['/obj/structure/hazard/*'] = 'pominięte: zagrożenia Shiptesta (iskry, alarmy, beczki z odpadami) i numery na ścianach'

# --- plakaty i znaki: nieznane -> losowy plakat oficjalny albo przemytniczy
SIGN_FIXED = {
	'/obj/structure/sign/clip': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/departments/science/alt': '/obj/structure/sign/departments/science',
	'/obj/structure/sign/plaques/blank': '/obj/structure/sign/plaques',
	'/obj/structure/sign/warning/chemdiamond': '/obj/structure/sign/warning/chemdiamond',
	'/obj/structure/sign/warning/coldtemp': '/obj/structure/sign/warning/coldtemp',
	'/obj/structure/sign/warning/nosmoking/burnt': '/obj/structure/sign/warning/nosmoking',
	'/obj/structure/sign/warning/testchamber': '/obj/structure/sign/warning/testchamber',
	'/obj/structure/sign/warra/ns': '/obj/structure/sign/poster/official/random',
}


def resolve(missing, ours):
	"""Ludzie frakcji Shiptesta -> nasi żołnierze; plakaty -> losowe plakaty; amunicja i gotówka wg kalibru."""
	for path in sorted(missing):
		if path in R:
			continue
		if path.startswith('/mob/living/basic/human/'):
			R[path] = human(path)
		elif path.startswith('/obj/structure/sign/'):
			target = SIGN_FIXED.get(path)
			if target and target not in ours:
				target = '/obj/structure/sign/poster/official/random'
			if not target:
				target = '/obj/structure/sign/poster/contraband/random' if ('contraband' in path or 'syndicate' in path or 'radio' in path) else '/obj/structure/sign/poster/official/random'
			R[path] = target
		elif path.startswith('/obj/item/spacecash/bundle/'):
			R[path] = '/obj/item/stack/spacecash/' + {'c1': 'c1', 'c10': 'c10', 'c50': 'c50', 'mediumrand': 'c100', 'pocketchange': 'c10', 'smallrand': 'c20'}.get(path.rsplit('/', 1)[1], 'c20')
		elif path.startswith('/obj/item/storage/box/ammo/') or path.startswith('/obj/item/storage/toolbox/ammo/'):
			R[path] = '/obj/item/storage/box/lethalshot' if '12g' in path else ('/obj/item/ammo_box/a762' if re.search(r'308|762|8_50|4570|44', path) else '/obj/item/ammo_box/c9mm')
		elif path.startswith('/obj/item/ammo_box/magazine/'):
			empty = path.endswith('/empty')
			if 'ammo_stack' in path:
				R[path] = '/obj/item/ammo_casing/shotgun' + ('/buckshot' if 'buckshot' in path else '')
			else:
				target = '/obj/item/ammo_box/magazine/' + ('m12g' if re.search(r'12g|g12|sporter|bulldog', path) else ('m556' if re.search(r'f4|308|illestren|a850r|556', path) else 'm10mm'))
				R[path] = (target, {'start_empty': '1'}) if empty else target
		elif path.startswith('/obj/item/mine/'):
			R[path] = None if 'training' in path else ('/obj/effect/mine/sound' if 'sound' in path else ('/obj/effect/mine/shrapnel/sting' if 'sting' in path else '/obj/effect/mine/explosive'))
		elif path.startswith('/obj/item/ammo_casing/spent/'):
			R[path] = '/obj/item/ammo_casing/spent'
		elif path.startswith('/obj/item/storage/ration/') or path.startswith('/obj/item/food/ration/'):
			R[path] = '/obj/item/food/donkpocket'
		else:
			continue
		DECISIONS[path] = 'ice/jungle: %s' % (R[path],)


def human(path):
	space = 'space' in path
	if '/ramzi' in path:
		if 'melee' in path or 'civilian' in path:
			if 'stormtrooper' in path:
				return '/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper'
			return '/mob/living/basic/trooper/syndicate/melee' + ('/space' if space else '')
		if 'shotgun' in path:
			return '/mob/living/basic/trooper/syndicate/ranged/shotgun' + ('/space' if space else '')
		if 'smg' in path or 'hydra' in path:
			return '/mob/living/basic/trooper/syndicate/ranged/smg' + ('/space' if space else '')
		return '/mob/living/basic/trooper/syndicate/ranged' + ('/space' if space else '')
	# frontiersmen i pustelnicy: wrodzy ludzie bez frakcji -> piraci
	if 'ranged' in path or 'swampboss' in path:
		return '/mob/living/basic/trooper/pirate/ranged' + ('/space' if space else '')
	return '/mob/living/basic/trooper/pirate/melee' + ('/space' if space else '')


DECISIONS['/mob/living/basic/human/frontier/*, hermit/*'] = 'frontiersmen i pustelnicy -> nasi piraci (basic trooper) według broni; Klika Ramziego -> żołnierze Syndykatu'
