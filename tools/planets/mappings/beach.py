"""Zamienniki dla ruin planety oceanicznej (Shiptest _maps/RandomRuins/BeachRuins) i ich kopii na planecie wodnej.
Frontiersmeni -> nasi piraci (basic trooper/pirate), Klika Ramziego -> żołnierze Syndykatu, roboty -> hivebot.
Atmosfera podłóg: plaża (PLANET_BEACH_ATMOS z shiptest_flora/beach.dm). Moduł water.py podmienia ją na lodowatą.
"""
from mappings.common import rep, R, TURFS, AREAS, TR, DECISIONS, NO_POPULATE, WALL_CLOSETS

GAS = '"o2=22;n2=82;TEMP=293.15"'
PREFIX = 'planet_beach'


def planetary():
	return {'initial_gas_mix': GAS, 'planetary_atmos': '1'}


def floor():
	return {'initial_gas_mix': GAS}


DIRN = {'north': '1', 'south': '2', 'east': '4', 'west': '8'}

# --- ludzie i roboty
PIRATE_MELEE = '/mob/living/basic/trooper/pirate/melee'
PIRATE_RANGED = '/mob/living/basic/trooper/pirate/ranged'
for p in ['', '/axe']:
	rep('/mob/living/basic/human/frontier' + p, PIRATE_MELEE)
for p in ['/ranged', '/ranged/mosin', '/ranged/mosin/neutered', '/ranged/mosin/neutered/sentry', '/ranged/officer',
		'/ranged/pounder', '/ranged/surgeon/neutered', '/ranged/trooper', '/ranged/trooper/f3/sentry', '/ranged/wasp']:
	rep('/mob/living/basic/human/frontier' + p, PIRATE_RANGED)
DECISIONS['/mob/living/basic/human/frontier/*'] = 'Frontiersmeni -> nasi piraci (basic trooper/pirate) według broni'
for p, n in {
	'/mob/living/basic/human/ramzi/civilian': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/melee/hatchet': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/melee/hatchet/engi': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/melee/runt': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/ranged/cottonmouth/scout': '/mob/living/basic/trooper/syndicate/ranged/smg',
	'/mob/living/basic/human/ramzi/ranged/hydra/gunsmith': '/mob/living/basic/trooper/syndicate/ranged/smg',
	'/mob/living/basic/human/ramzi/ranged/officer/captain': '/mob/living/basic/trooper/syndicate/ranged',
	'/mob/living/basic/human/ramzi/ranged/officer/lieutenant': '/mob/living/basic/trooper/syndicate/ranged',
	'/mob/living/basic/human/ramzi/ranged/officer/ngr': '/mob/living/basic/trooper/syndicate/ranged',
	'/mob/living/basic/human/ramzi/ranged/runt/flapcap': '/mob/living/basic/trooper/syndicate/ranged',
	'/mob/living/basic/human/ramzi/ranged/smg/sidewinder/ballistic': '/mob/living/basic/trooper/syndicate/ranged/smg',
	'/mob/living/basic/human/ramzi/ranged/sniper/sentry': '/mob/living/basic/trooper/syndicate/ranged',
}.items():
	rep(p, n)
rep('/mob/living/basic/hivebot/mechanic', '/mob/living/basic/hivebot')
rep('/mob/living/basic/hivebot/ranged', '/mob/living/basic/hivebot/range')
rep('/mob/living/basic/mouse/rat', '/mob/living/basic/mouse/brown', 'szczur -> brązowa mysz')
rep('/mob/living/simple_animal/crab', '/mob/living/basic/crab')
rep('/mob/living/simple_animal/hostile/automated/agrav/cybersun', ('/mob/living/basic/hivebot/rapid', {'faction': 'list("Syndicate")'}), 'dron antygrawitacyjny Cybersun -> szybki hivebot Syndykatu')
rep('/mob/living/simple_animal/hostile/automated/rover/coalition', ('/mob/living/basic/hivebot/rapid', {'faction': 'list("pirate")'}), 'łazik Koalicji -> szybki hivebot obrońców (piraci)')
rep('/mob/living/simple_animal/hostile/automated/rover/coalition/dmr', ('/mob/living/basic/hivebot/range', {'faction': 'list("pirate")'}))

# --- zwłoki
for p, n in {
	'/obj/effect/mob_spawn/animal_corpse/wolf': None,
	'/obj/effect/mob_spawn/human/corpse/clip/vc': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/frontier/fake': '/obj/effect/mob_spawn/human/corpse/pirate',
	'/obj/effect/mob_spawn/human/corpse/indie/engineer': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/ramzi/runt/noarmour': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/mob_spawn/human/corpse/ramzi/trooper': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
}.items():
	rep(p, n)

# --- efekty, dekale, pomocnicy map
for p, n in {
	'/obj/effect/decal/cleanable/confetti': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/decal/cleanable/robot_debris/gib': '/obj/effect/decal/cleanable/robot_debris',
	'/obj/effect/mapping_helpers/airlock/sealed': '/obj/effect/mapping_helpers/airlock/locked',
	'/obj/effect/mapping_helpers/airlock/welded': '/obj/effect/mapping_helpers/airlock/locked',
	'/obj/effect/mapping_helpers/crate_shelve': None,
	'/obj/effect/mapping_helpers/turf/burnt': None,
	'/obj/effect/radiation': None,
	'/obj/effect/spawner/random/food_or_drink/garden': '/obj/item/food/grown/potato/sweet',
	'/obj/effect/spawner/random/food_or_drink/garden/seaweed': '/obj/item/food/fishmeat',
	'/obj/effect/spawner/random/trash/crushed_can': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/turf_decal/corner_steel_grid': None,
	'/obj/effect/turf_decal/corner_steel_grid/full': None,
	'/obj/effect/turf_decal/corner_techfloor_grid': None,
	'/obj/effect/turf_decal/corner_techfloor_grid/full': None,
	'/obj/effect/turf_decal/industrial/hatch/orange': '/obj/effect/turf_decal/delivery',
	'/obj/effect/turf_decal/industrial/outline/orange': '/obj/effect/turf_decal/box',
	'/obj/effect/turf_decal/industrial/outline/red': '/obj/effect/turf_decal/box/red',
	'/obj/effect/turf_decal/industrial/traffic/fulltile': '/obj/effect/turf_decal/delivery',
	'/obj/effect/turf_decal/industrial/warning/full': '/obj/effect/turf_decal/delivery',
	'/obj/effect/turf_decal/rechargefloor': None,
	'/obj/effect/turf_decal/road': None,
	'/obj/effect/turf_decal/solarpanel': None,
	'/obj/effect/turf_decal/techfloor/orange': '/obj/effect/turf_decal/ship/techfloor',
}.items():
	rep(p, n)
for n in ['two', 'three', 'four', 'five', 'six', 'seven']:
	rep('/obj/effect/turf_decal/hardline_big/' + n, None)
DECISIONS['/obj/effect/turf_decal/hardline_big/*'] = 'pominięte: wielkie logo Twardogłowych na podłodze'
for wood in ['bamboo', 'ebony', 'mahogany', 'maple', 'walnut']:
	for shape in ['', '/corner', '/end']:
		R['/obj/effect/turf_decal/siding/wood%s/%s' % (shape, wood)] = '/obj/effect/turf_decal/siding/wood' + shape
		R['/obj/effect/turf_decal/siding/wood/%s%s' % (wood, shape)] = '/obj/effect/turf_decal/siding/wood' + shape

# --- broń i amunicja
for p, n in {
	'/obj/item/ammo_box/magazine/boomslang/empty': ('/obj/item/ammo_box/magazine/m556', {'start_empty': '1'}),
	'/obj/item/ammo_box/magazine/cm23': '/obj/item/ammo_box/magazine/m10mm',
	'/obj/item/ammo_box/magazine/f4_308/empty': ('/obj/item/ammo_box/magazine/m556', {'start_empty': '1'}),
	'/obj/item/ammo_box/magazine/illestren_a850r': '/obj/item/ammo_box/a762',
	'/obj/item/ammo_box/magazine/illestren_a850r/empty': None,
	'/obj/item/ammo_box/magazine/m10mm_cottonmouth': '/obj/item/ammo_box/magazine/m10mm',
	'/obj/item/ammo_box/magazine/m10mm_ringneck/empty': ('/obj/item/ammo_box/magazine/m10mm', {'start_empty': '1'}),
	'/obj/item/ammo_box/magazine/m556_42_hydra/empty': ('/obj/item/ammo_box/magazine/m556', {'start_empty': '1'}),
	'/obj/item/ammo_box/magazine/m57_39_asp': '/obj/item/ammo_box/magazine/pistolm9mm',
	'/obj/item/ammo_casing/spent/big_brass': '/obj/item/ammo_casing/spent',
	'/obj/item/attachment/energy_bayonet': None,
	'/obj/item/gun/ballistic/automatic/pistol/asp': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/ballistic/automatic/pistol/cm23': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/ballistic/automatic/pistol/rattlesnake/cottonmouth': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/ballistic/automatic/pistol/rattlesnake/no_mag': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
	'/obj/item/gun/ballistic/revolver/shadow/empty': '/obj/item/gun/ballistic/revolver/detective',
	'/obj/item/gun/ballistic/rifle/illestren/factory': '/obj/item/gun/ballistic/rifle/boltaction',
	'/obj/item/gun/ballistic/rifle/illestren/sawn': '/obj/item/gun/ballistic/rifle/boltaction',
	'/obj/item/gun/ballistic/shotgun/doublebarrel/empty': '/obj/item/gun/ballistic/shotgun/doublebarrel',
	'/obj/item/grenade/c4/x4': '/obj/item/grenade/plastic/x4',
	'/obj/item/mine/pressure/explosive': '/obj/effect/mine/explosive',
	'/obj/item/mine/pressure/explosive/rusty/live': '/obj/effect/mine/explosive',
	'/obj/item/storage/box/ammo/a44roum': '/obj/item/ammo_box/a357',
	'/obj/item/storage/box/ammo/a44roum_hp': '/obj/item/ammo_box/a357',
	'/obj/item/storage/box/ammo/a65clip/trac': '/obj/item/ammo_box/a762',
	'/obj/item/storage/box/ammo/a762_40': '/obj/item/ammo_box/a762',
	'/obj/item/storage/box/ammo/a8_50r': '/obj/item/ammo_box/a762',
	'/obj/item/storage/box/ammo/a8_50r/match': '/obj/item/ammo_box/a762',
	'/obj/item/storage/box/ammo/a8_50r/trac': '/obj/item/ammo_box/a762',
	'/obj/item/storage/toolbox/ammo/c10mm': '/obj/item/storage/toolbox/ammo',
	'/obj/item/storage/toolbox/ammo/c65': '/obj/item/storage/toolbox/ammo',
	'/obj/item/stock_parts/cell/gun/sharplite/plus/empty': '/obj/item/stock_parts/cell/empty',
	'/obj/item/circuitboard/machine/turret/ship': None,
}.items():
	rep(p, n)

# --- ubrania
for p, n in {
	'/obj/item/clothing/gloves/insulated': '/obj/item/clothing/gloves/color/yellow',
	'/obj/item/clothing/head/frontier/peaked': '/obj/item/clothing/head/pirate',
	'/obj/item/clothing/head/hardhat/frontier': '/obj/item/clothing/head/hardhat/orange',
	'/obj/item/clothing/head/hardhat/ramzi': '/obj/item/clothing/head/hardhat/red',
	'/obj/item/clothing/head/helmet/bulletproof/x11/clip': '/obj/item/clothing/head/helmet/alt',
	'/obj/item/clothing/head/helmet/m10/clip_vc': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/helmet/m10/warra': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/sunhat': '/obj/item/clothing/head/soft',
	'/obj/item/clothing/head/warra': '/obj/item/clothing/head/beret',
	'/obj/item/clothing/head/warra/cap/janitor': '/obj/item/clothing/head/soft/purple',
	'/obj/item/clothing/mask/gas/frontiersmen': '/obj/item/clothing/mask/gas',
	'/obj/item/clothing/shoes/combat/knife': '/obj/item/clothing/shoes/combat',
	'/obj/item/clothing/suit/armor/frontier': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/space/hardsuit/collapsar/paramed': '/obj/item/clothing/suit/space/hardsuit/medical',
	'/obj/item/clothing/suit/space/hardsuit/stealth': '/obj/item/clothing/suit/space/hardsuit/syndi',
	'/obj/item/clothing/suit/space/hardsuit/syndi/cybersun/paramed': '/obj/item/clothing/suit/space/hardsuit/medical',
	'/obj/item/clothing/suit/space/hardsuit/syndi/ramzi': '/obj/item/clothing/suit/space/hardsuit/syndi',
	'/obj/item/clothing/under/cybersun/medic': '/obj/item/clothing/under/rank/medical/doctor',
	'/obj/item/clothing/under/cybersun/suit': '/obj/item/clothing/under/suit/black',
	'/obj/item/clothing/under/frontiersmen': '/obj/item/clothing/under/costume/pirate',
	'/obj/item/clothing/under/pants/pajamared': '/obj/item/clothing/under/misc/pj/red',
	'/obj/item/clothing/under/shorts/dolphin': '/obj/item/clothing/under/shorts/red',
	'/obj/item/clothing/under/shorts/explorer': '/obj/item/clothing/under/shorts',
	'/obj/item/storage/belt/security/military/frontiersmen': '/obj/item/storage/belt/military',
}.items():
	rep(p, n)

# --- jedzenie, napoje, chemia
for p, n in {
	'/obj/item/fish/lanternfish': '/obj/item/fish',
	'/obj/item/food/grown/sweet_potato': '/obj/item/food/grown/potato/sweet',
	'/obj/item/food/meat/slab/miras': '/obj/item/food/meat/slab',
	'/obj/item/food/ration/entree/battered_fish_sticks': '/obj/item/food/fishfingers',
	'/obj/item/food/shoalpocket': '/obj/item/food/donkpocket',
	'/obj/item/storage/box/shoalpockets': '/obj/item/storage/box/donkpockets',
	'/obj/item/reagent_containers/condiment/enzyme': '/obj/item/reagent_containers/food/condiment/enzyme',
	'/obj/item/reagent_containers/condiment/oliveoil': '/obj/item/reagent_containers/food/condiment/enzyme',
	'/obj/item/reagent_containers/food/drinks/bottle/chemshine': '/obj/item/reagent_containers/food/drinks/bottle/moonshine',
	'/obj/item/reagent_containers/food/drinks/bottle/dotusira': '/obj/item/reagent_containers/food/drinks/bottle/vodka',
	'/obj/item/reagent_containers/food/drinks/colocup/lean': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/reagent_containers/food/drinks/drinkingglass/filled/gorlex_surprise': '/obj/item/reagent_containers/food/drinks/drinkingglass',
	'/obj/item/reagent_containers/glass/beaker/large/napalm': '/obj/item/reagent_containers/glass/beaker/large',
	'/obj/item/reagent_containers/glass/bottle/vial/large/preloaded/morphine': '/obj/item/reagent_containers/glass/bottle/morphine',
	'/obj/item/reagent_containers/glass/bucket/wooden': '/obj/item/reagent_containers/glass/bucket',
	'/obj/item/reagent_containers/glass/chem_jug/hexacrete': None,
	'/obj/item/reagent_containers/hypospray/medipen/mammoth': '/obj/item/reagent_containers/hypospray/medipen',
	'/obj/item/reagent_containers/hypospray/medipen/rabbit': '/obj/item/reagent_containers/hypospray/medipen',
	'/obj/item/hypospray/mkii/mkiii': '/obj/item/reagent_containers/hypospray/CMO',
	'/obj/item/storage/bottles/chemshine': '/obj/item/reagent_containers/food/drinks/bottle/moonshine',
	'/obj/item/storage/bottles/chemshine/sealed': '/obj/item/reagent_containers/food/drinks/bottle/moonshine',
	'/obj/item/storage/cans/sixsoda': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/storage/firstaid/radiation': '/obj/item/storage/firstaid/radbgone',
	'/obj/item/storage/pill_bottle/charcoal/less': '/obj/item/storage/pill_bottle/charcoal',
	'/obj/item/seeds/cabbage': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/storage/box/fishing_hooks': '/obj/item/storage/box/fishing_worms',
	'/obj/item/storage/toolbox/fishing': '/obj/item/fishing_rod',
}.items():
	rep(p, n)
DECISIONS['wędkarstwo w ruinach'] = 'skrzynka wędkarska -> wędka, haczyki -> puszka robaków (nasze wędkarstwo z water/)'

# --- narzędzia i drobiazgi
for p, n in {
	'/obj/item/cultivator/rake': '/obj/item/cultivator',
	'/obj/item/desynchronizer/tvstatic': None,
	'/obj/item/documents/frontier': '/obj/item/documents',
	'/obj/item/documents/frontier/logistics': '/obj/item/documents',
	'/obj/item/door_seal': None,
	'/obj/item/extinguisher/empty': '/obj/item/extinguisher',
	'/obj/item/hatchet/wooden': '/obj/item/hatchet',
	'/obj/item/mecha_parts/mecha_equipment/salvage_saw': None,
	'/obj/item/melee/knife/pizza_cutter': '/obj/item/kitchen/knife',
	'/obj/item/melee/knife/switchblade': '/obj/item/switchblade',
	'/obj/item/modular_computer/laptop/preset/civilian': None,
	'/obj/item/pickaxe/drill/jackhammer/old': '/obj/item/pickaxe/drill',
	'/obj/item/pickaxe/improvised': '/obj/item/pickaxe',
	'/obj/item/plasmacutter': '/obj/item/gun/energy/plasmacutter',
	'/obj/item/radio/intercom/wideband/table': None,
	'/obj/item/screwdriver/power': '/obj/item/screwdriver',
	'/obj/item/shovel/spoon': '/obj/item/shovel/spade',
	'/obj/item/spacecash/bundle/pocketchange': '/obj/item/stack/spacecash/c10',
	'/obj/item/stack/ore/salvage/scrapmetal/twenty': ('/obj/item/stack/ore/iron', {'amount': '20'}),
	'/obj/item/stack/sheet/mineral/wood/twentyfive': ('/obj/item/stack/sheet/mineral/wood', {'amount': '25'}),
	'/obj/item/stack/tape/industrial': '/obj/item/stack/sticky_tape',
	'/obj/item/stack/tape/industrial/electrical': '/obj/item/stack/sticky_tape',
	'/obj/item/stack/tile/carpet/executive': '/obj/item/stack/tile/carpet/royalblue',
	'/obj/item/stamp/ngr/ensign': '/obj/item/stamp',
	'/obj/item/storage/box/stockparts/t2': '/obj/item/storage/box/stockparts/basic',
	'/obj/item/toy/plush/landmine': '/obj/item/toy/plush/lizardplushie',
	'/obj/item/weldingtool/empty': '/obj/item/weldingtool',
	'/obj/item/wrench/syndie': '/obj/item/wrench',
}.items():
	rep(p, n)

# --- maszyny
for p, n in {
	'/obj/machinery/atmospherics/components/unary/shuttle/fire_heater': None,
	'/obj/machinery/power/shuttle/engine/fire': None,
	'/obj/machinery/autolathe/hacked': '/obj/machinery/modular_fabricator/autolathe/hacked',
	'/obj/machinery/coffeemaker/premium': '/obj/machinery/coffeemaker',
	'/obj/machinery/computer/crew/retro': '/obj/machinery/computer/crew',
	'/obj/machinery/computer/helm/retro': ('/obj/structure/frame/computer', {'anchored': '1'}),
	'/obj/machinery/computer/mech_bay_power_console/retro': '/obj/machinery/computer/mech_bay_power_console',
	'/obj/machinery/computer/solar_control': '/obj/machinery/computer/monitor',
	'/obj/machinery/computer/transponder': ('/obj/structure/frame/computer', {'anchored': '1'}),
	'/obj/machinery/fax/ramzi': None,
	'/obj/machinery/hydroponics/soil': None,
	'/obj/machinery/power/smes/shuttle/micro/precharged': '/obj/machinery/power/smes/engineering',
	'/obj/machinery/turretid/lethal': '/obj/machinery/turretid',
	'/obj/mecha/working/ripley/cargo': '/obj/mecha/working/ripley',
}.items():
	rep(p, n)
DECISIONS['statek Ramziego w kurorcie'] = 'silniki i grzejniki promu Shiptesta pominięte, ster i transponder -> puste ramy komputera (wrak)'
DECISIONS['/obj/machinery/hydroponics/soil'] = 'pominięte: grządki ziemi (nasza botanika ma inne tace)'

# --- struktury
for p, n in {
	'/obj/structure/barricade/directional/flippedtable/wood': '/obj/structure/barricade/wooden/crude',
	'/obj/structure/bed/bunk': '/obj/structure/bed',
	'/obj/structure/chair/bench/red': '/obj/structure/chair/fancy/bench',
	'/obj/structure/chair/comfy/grey': '/obj/structure/chair/fancy/comfy',
	'/obj/structure/chair/pew/left': '/obj/structure/chair/fancy/bench/pew/left',
	'/obj/structure/closet/crate/rations': '/obj/structure/closet/crate',
	'/obj/structure/closet/crate/trashcart/laundry': '/obj/structure/closet/crate/trashcart',
	'/obj/structure/closet/secure_closet/cabinet': '/obj/structure/closet/cabinet',
	'/obj/structure/curtain/cloth/fancy': '/obj/structure/curtain',
	'/obj/structure/destructible/tribal_torch/lit': '/obj/structure/bonfire/prelit',
	'/obj/structure/displaycase/broken': '/obj/structure/displaycase',
	'/obj/structure/flora/ash/garden': '/obj/structure/flora/ausbushes/genericbush',
	'/obj/structure/flora/tree/tall': '/obj/structure/flora/tree/jungle',
	'/obj/structure/fluff/beach_umbrella': None,
	'/obj/structure/fluff/beach_umbrella/syndi': None,
	'/obj/structure/fluff/hedge/opaque': '/obj/structure/flora/ausbushes/sparsegrass',
	'/obj/structure/fluff/minefield_sign': '/obj/structure/sign/warning/explosives',
	'/obj/structure/hazard/spray/steam/safe': None,
	'/obj/structure/hazard_shutoff/electrical_shutoff/resets': None,
	'/obj/structure/railing/corner/wood': '/obj/structure/railing/corner',
	'/obj/structure/railing/thin': '/obj/structure/railing',
	'/obj/structure/railing/thin/corner': '/obj/structure/railing/corner',
	'/obj/structure/reagent_dispensers/cooking_oil': '/obj/structure/reagent_dispensers/watertank',
	'/obj/structure/salvageable/autolathe': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/kitchenvend': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/seed': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/server': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/sign/number/random': None,
	'/obj/structure/sign/poster/official/miners': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/radio/mwra': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/random': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/warning/nosmoking/burnt': '/obj/structure/sign/warning/nosmoking',
	'/obj/structure/sign/warra/ns': None,
	'/obj/structure/sign/warra/old': None,
	'/obj/structure/spacevine/dead': '/obj/structure/flora/ausbushes/sparsegrass',
	'/obj/structure/spacevine/dense': '/obj/structure/flora/junglebush/large',
	'/obj/structure/spacevine/weak': '/obj/structure/flora/junglebush',
	'/obj/structure/table/rolling': '/obj/structure/table',
	'/obj/structure/dresser/wall/directional/north': '/obj/structure/dresser',
}.items():
	rep(p, n)
for p in ['', '/corner', '/manifold', '/exposed_wires_stun', '/frayed_sparks']:
	rep('/obj/structure/hazard/electrical/conduit' + p, None)
for p in ['', '/corner', '/ship', '/ship_three', '/ship_three/corner', '/wood', '/wood/corner']:
	rep('/obj/structure/platform' + p, None)
DECISIONS['spacevine (gęste, słabe, martwe)'] = 'statyczne pnącza -> krzewy dżungli i trawa (statycznych pnączy u nas nie ma)'
DECISIONS['/obj/structure/fluff/beach_umbrella'] = 'pominięte: parasole plażowe (brak sprite\'a)'

# sofy i fotele z kierunkiem
for colour in ['brown', 'olive', 'red', 'beige']:
	for side in ['', '/left', '/right', '/corner']:
		base = '/obj/structure/chair/fancy/sofa/old' + side
		R['/obj/structure/chair/sofa/%s/old%s' % (colour, side)] = base
		for d, n in DIRN.items():
			R['/obj/structure/chair/sofa/%s/old%s/directional/%s' % (colour, side, d)] = (base, {'dir': n} if n != '2' else {})
	for d, n in DIRN.items():
		R['/obj/structure/chair/comfy/%s/old/directional/%s' % (colour, d)] = ('/obj/structure/chair/fancy/comfy', {'dir': n} if n != '2' else {})

# szafki ścienne
WALL_CLOSETS['/obj/structure/closet/secure_closet/brig/wall'] = '/obj/structure/closet/secure_closet/brig'
WALL_CLOSETS['/obj/structure/closet/wall/blue'] = '/obj/structure/closet'
WALL_CLOSETS['/obj/structure/closet/wall/orange'] = '/obj/structure/closet'

# --- turfy
for p, n in {
	'/turf/closed/mineral/random/beach': '/turf/closed/mineral/random/beach',
	'/turf/open/floor/carpet/executive': '/turf/open/floor/carpet/royalblue',
	'/turf/open/floor/plasteel/patterned/grid': '/turf/open/floor/plasteel/tech/grid',
	'/turf/open/floor/plasteel/stairs/wood/walnut/left': '/turf/open/floor/plasteel/stairs/left',
	'/turf/open/floor/plasteel/stairs/wood/walnut/right': '/turf/open/floor/plasteel/stairs/right',
	'/turf/open/floor/plasteel/telecomms_floor': '/turf/open/floor/plasteel/telecomms',
	'/turf/open/floor/suns/dark/plain': '/turf/open/floor/pod/dark',
	'/turf/open/floor/suns/hatch/bamboo': '/turf/open/floor/wood',
	'/turf/open/floor/suns/hatch/mahogany': '/turf/open/floor/wood',
	'/turf/open/floor/suns/hatch/maple': '/turf/open/floor/wood',
	'/turf/open/floor/wood/ebony': '/turf/open/floor/wood',
	'/turf/open/floor/wood/mahogany': '/turf/open/floor/wood',
	'/turf/open/floor/wood/maple': '/turf/open/floor/wood',
	'/turf/open/floor/concrete/slab_2': '/turf/open/floor/concrete/slab_1',
	'/turf/open/floor/concrete/slab_3': '/turf/open/floor/concrete/slab_4',
	'/turf/open/floor/concrete/tiles': '/turf/open/floor/concrete/slab_4',
	'/turf/open/floor/concrete/reinforced': '/turf/open/floor/concrete',
	'/turf/open/water/beach': '/turf/open/water/planet/beach',
	'/turf/open/water/beach/deep': '/turf/open/water/planet/beach/deep',
}.items():
	TURFS[p] = n


def planet_turfs():
	"""Turfy z atmosferą planety (moduł water.py woła to drugi raz z lodowatą atmosferą)."""
	for p, n in {
		'/turf/open/floor/plating/asteroid/sand': '/turf/open/floor/plating/asteroid/sand',
		'/turf/open/floor/plating/asteroid/sand/lit': '/turf/open/floor/plating/asteroid/sand',
		'/turf/open/floor/plating/asteroid/sand/dense': '/turf/open/floor/plating/asteroid/sand/dense',
		'/turf/open/floor/plating/asteroid/sand/dense/lit': '/turf/open/floor/plating/asteroid/sand/dense',
		'/turf/open/floor/plating/asteroid/dirt/beach': '/turf/open/floor/plating/asteroid/dirt/beach',
		'/turf/open/floor/plating/asteroid/dirt/grass/beach': '/turf/open/floor/plating/asteroid/dirt/grass/beach',
	}.items():
		TURFS[p] = n
	for p, n in {
		'/turf/open/floor/concrete/pavement/beachplanet': '/turf/open/floor/concrete/pavement',
		'/turf/open/floor/concrete/pavement/beachplanet/lit': '/turf/open/floor/concrete/pavement',
		'/turf/open/floor/concrete/reinforced/beachplanet/lit': '/turf/open/floor/concrete',
		'/turf/open/floor/concrete/slab_1/beachplanet/lit': '/turf/open/floor/concrete/slab_1',
		'/turf/open/floor/engine/hull/reinforced/beach': '/turf/open/floor/engine',
		'/turf/open/floor/engine/hull/reinforced/beach/lit': '/turf/open/floor/engine',
		'/turf/open/floor/plasteel/dark/beachplanet/lit': '/turf/open/floor/plasteel/dark',
		'/turf/open/floor/plasteel/mono/dark/beachplanet/lit': '/turf/open/floor/monotile/dark',
		'/turf/open/floor/wood/beach/lit': '/turf/open/floor/wood',
		'/turf/open/floor/wood/birch/beach/lit': '/turf/open/floor/wood',
	}.items():
		TURFS[p] = (n, planetary())


planet_turfs()

# --- obszary
AREAS['/area/overmap_encounter/planetoid/beachplanet/explored'] = '/area/lavaland/surface/outdoors'
AREAS['/area/overmap_encounter/planetoid/cave/explored'] = '/area/ruin/unpowered/%s/cave' % PREFIX


def ruin_areas(prefix):
	subareas = {
		'bunker': ['', '/living', '/office', '/side_one', '/side_two'],
		'corpo_resort': ['/bar', '/electrical', '/hotel', '/hotel/rooms/officer', '/hotel/rooms/one', '/hotel/rooms/three',
			'/hotel/rooms/two', '/office', '/ramzi_emplacement', '/ramzi_emplacement/north', '/ramzi_emplacement/west',
			'/ramzi_shuttle', '/ramzi_tent', '/security', '/staff_dorms', '/supply'],
		'csunpad': ['', '/canteen', '/director', '/dorm', '/engineering', '/june', '/medical', '/security'],
		'gunsmith': ['', '/bathroom', '/crewquarters', '/dorms', '/dorms/officer', '/electrical', '/kitchen', '/workshop'],
		'village': ['/armory', '/dorm', '/infirmary', '/kitchen', '/officers'],
	}
	for ruin, subs in subareas.items():
		for sub in subs:
			AREAS['/area/ruin/beach/%s%s' % (ruin, sub)] = '/area/ruin/unpowered/%s/%s%s' % (prefix, ruin, sub)
	AREAS['/area/overmap_encounter/planetoid/cave/explored'] = '/area/ruin/unpowered/%s/cave' % prefix


ruin_areas(PREFIX)

# --- tłumaczenia nazw edytowanych na mapach
TR.update({
	'Aide Dormitory': 'Sypialnia pomocników',
	'Armory': 'Zbrojownia',
	'Boss Bedroom': 'Sypialnia szefa',
	'Bunk Rooms': 'Sypialnie',
	'Cargo Doors': 'drzwi ładowni',
	'Cockpit': 'Kokpit',
	'Corpse Storage': 'Przechowalnia zwłok',
	'Crew Quarters': 'Kwatery załogi',
	'Deck': 'Pokład',
	'Detainment Window Covers': 'osłony okien aresztu',
	"Director's Dormitory": 'Sypialnia dyrektora',
	'Dormitory': 'Sypialnia',
	'Emplacement': 'Stanowisko',
	'Engineering Compartment': 'Przedział inżynieryjny',
	'Exterior Window Control': 'sterowanie oknami zewnętrznymi',
	'External Storage Hatch': 'zewnętrzny właz magazynu',
	'Fire Exit': 'Wyjście ewakuacyjne',
	'Generator': 'Generator',
	'Head Boss Bedroom': 'Sypialnia głównego szefa',
	'Loading Gate': 'brama załadunkowa',
	'Medical': 'Ambulatorium',
	'Medical Bay': 'Izba chorych',
	"Officer's Suite": 'Apartament oficerski',
	'Officers Quarters': 'Kwatery oficerów',
	'Operations': 'Operacje',
	'Operations Office': 'Biuro operacji',
	'Room 1': 'Pokój 1',
	'Room 2': 'Pokój 2',
	'Room 3': 'Pokój 3',
	'Sauna': 'Sauna',
	'Sauna Changing Room': 'Przebieralnia sauny',
	'Shed Door': 'drzwi szopy',
	'Shed Override': 'odblokowanie szopy',
	'Trauma Team Post': 'Posterunek zespołu urazowego',
	'Window Covers': 'osłony okien',
	'You can barely make out a few lines amidst the dried blood and gradual damage to the paper.':
		'Spośród zaschniętej krwi i zniszczeń papieru da się odczytać zaledwie kilka linijek.',
	'ammo crate': 'skrzynia z amunicją',
	'armor closet': 'szafa z pancerzami',
	'automated security release': 'automatyczne zwolnienie zabezpieczeń',
	'bathroom mat': 'mata łazienkowa',
	'bolts': 'rygle',
	'cheap plastic curtain': 'tania plastikowa zasłona',
	'concrete brush': 'szczotka do betonu',
	'door lock': 'zamek drzwi',
	'double purple bedsheet': 'podwójne fioletowe prześcieradło',
	'dropship bay door control': 'sterowanie wrotami hangaru desantowca',
	'engineering bay shutter control': 'sterowanie roletami warsztatu',
	'frontiersmen cow': 'krowa pograniczników',
	'half-opened command airlock assembly': 'na wpół otwarta rama śluzy dowodzenia',
	'power station camera console': 'konsola kamer elektrowni',
	'power storage unit': 'magazyn energii',
	'rat milk': 'szczurze mleko',
	're: Rats': 'odp.: Szczury',
	're: Wires': 'odp.: Kable',
	'rotten mess': 'zgniła breja',
	'supply cabinet': 'szafka z zaopatrzeniem',
	'the Meal': 'Posiłek',
	'to-do': 'do zrobienia',
	'uprooted machine': 'wyrwana maszyna',
	'ventilation network-outside air valve': 'zawór powietrza zewnętrznego wentylacji',
	'stale shoalwich': 'czerstwa kanapka z ławicą',
	'cargo shed lock': 'zamek szopy ładunkowej',
	'bedroom lock <3': 'zamek sypialni <3',
	'To-Do List': 'Lista rzeczy do zrobienia',
	'reminder': 'przypomnienie',
	# treść notatek (default_raw_text)
	'1. Refill the shadow <br> 2. Take stock of who has what gun. <br> 3. Clean desk.':
		'1. Uzupełnić shadowa <br> 2. Spisać, kto ma jaką broń. <br> 3. Posprzątać biurko.',
	"Stop asking about the rats. I'm not hiding rats. I don't have rats. I don't know why you fuckers are OBSESSED with rats. Just. Stop.":
		'Przestańcie pytać o szczury. Nie ukrywam szczurów. Nie mam szczurów. Nie wiem, czemu macie taką OBSESJĘ na punkcie szczurów. Po prostu. Przestańcie.',
	"So help me god. If you don't fix the wire. You KNOW what's wrong. So help me by Rawk and all that Juice. I will have your FUCKING head. On a pike. In my office. For the rats to eat.":
		'Jak Boga kocham. Jeśli nie naprawisz tego kabla. WIESZ, co jest nie tak. Na Rawka i cały ten Sok. Twoja PIEPRZONA głowa skończy na palu. W moim biurze. Szczurom na pożarcie.',
	"Central recently advised that there's a Coalition fleet approaching our system. Going to speak with the resort management soon, see what the drill is. I'm thinking we'll have to evacuate, though. Nothing we can do if a whole Gorlex killteam drops here and takes everyone hostage, apparently we have some low-level of-":
		'Centrala niedawno ostrzegła, że do naszego układu zbliża się flota Koalicji. Niedługo porozmawiam z zarządem kurortu, zobaczymy, jaka jest procedura. Myślę jednak, że trzeba będzie się ewakuować. Nic nie zrobimy, jeśli wyląduje tu cały oddział Gorlexa i weźmie wszystkich jako zakładników, podobno mamy jakiś niski poziom-',
	"The inspector came in a few weeks ago and said that the wiring for the alarm in the officers' suite case is, and I quote, 'absolutely awful', and thus a fire hazard. Tried to raise it to management, but they just brushed it off. Pah. I'll tell whoever's booked in there next until I can talk to someone who actually knows their bloody job description.":
		'Inspektor był tu kilka tygodni temu i stwierdził, że okablowanie alarmu w apartamencie oficerskim jest, cytuję, „absolutnie fatalne”, a więc grozi pożarem. Próbowałem to zgłosić zarządowi, ale zbyli mnie. Phi. Będę uprzedzać każdego, kto się tam zamelduje, dopóki nie porozmawiam z kimś, kto naprawdę zna swoje obowiązki.',
	"note to self: GET CORPORATE TO REWIRE THIS PIECE OF SHIT!!!!! there isn't even a dedicated shutoff switch and because of how the chamber is designed if it floods the water risks becoming electrified, and we can only shut off the generators for half a minute because we can only reboot it with the switch. i COULD theoretically turn it off indefinitely by cutting off the flow of steam into the geothermal generators from underground but if it floods that'll become far too dangerous to even attempt!!!!":
		'notatka dla siebie: NIECH KORPORACJA PRZEŁOŻY KABLE W TYM BADZIEWIU!!!!! nie ma nawet osobnego wyłącznika, a przez budowę komory, jeśli ją zaleje, woda może być pod napięciem, a generatory da się wyłączyć tylko na pół minuty, bo restartuje je przełącznik. TEORETYCZNIE mógłbym wyłączyć je na stałe, odcinając dopływ pary z podziemia do generatorów geotermalnych, ale jak zaleje, to będzie o wiele za niebezpieczne, żeby w ogóle próbować!!!!',
	"oh god. its midnight as i write this, or at least feels like it. i heard a loud bang coming from the security building. the staff say we're under attack and need to evacuate now. apparently gorlex marauders are in orbit. if i dont make it send all my things to a charity. alright?":
		'o boże. piszę to o północy, a przynajmniej tak się czuję. z budynku ochrony dobiegł głośny huk. obsługa mówi, że nas atakują i musimy się natychmiast ewakuować. podobno na orbicie są maruderzy gorlexa. jeśli nie przeżyję, oddajcie wszystkie moje rzeczy na cele dobroczynne. dobrze?',
	"If you nitwits keep forgetting to have the water building up below the geothermal generators cleaned, someone's going to get killed and I'm *not* pulling them out.":
		'Jeśli dalej będziecie zapominać, matoły, o wypompowywaniu wody zbierającej się pod generatorami geotermalnymi, ktoś w końcu zginie, a ja go *nie* będę wyciągać.',
	"<h1>TODO:</h1>-Remind the new people that love is one of us<br>-Negotiate hydra shipment proceeds with love's boss<br>-See about getting a new salt supplier<br>-Plaster more warning signs by the explosives":
		'<h1>DO ZROBIENIA:</h1>-Przypomnieć nowym, że kochanie jest jedną z nas<br>-Wynegocjować z szefem kochania zysk z dostawy hydr<br>-Rozejrzeć się za nowym dostawcą soli<br>-Nakleić więcej ostrzeżeń przy materiałach wybuchowych',
	'remind rei to replace my damn stash floorboards by the south wall':
		'przypomnieć rei, żeby wymienił moje cholerne deski nad skrytką przy południowej ścianie',
	'hey love. remember to be a little more careful moving the bookcase for the stash. gonna have to get rei to fix the floorboards again':
		'hej kochanie. pamiętaj, żeby ostrożniej przesuwać regał przy skrytce. znowu trzeba będzie prosić rei, żeby naprawił deski',
})

# --- druga runda: rzeczy znalezione po pierwszym przebiegu
for p, n in {
	'/mob/living/basic/human/ramzi/civilian/runt/flapcap': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/melee/runt/chef': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/ranged/himehabu': '/mob/living/basic/trooper/syndicate/ranged',
	'/obj/effect/spawner/random/trash/food_packaging': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/turf_decal/corner_steel_grid/diagonal': None,
	'/obj/item/ammo_box/magazine/ammo_stack/prefilled/c10mm': '/obj/item/ammo_box/c10mm',
	'/obj/item/ammo_box/magazine/fa2_762_40/empty': None,
	'/obj/item/ammo_casing/a556_42': '/obj/item/ammo_casing/a556',
	'/obj/item/attachment/gun/flamethrower': '/obj/item/flamethrower',
	'/obj/item/bait_can/worm': '/obj/item/storage/box/fishing_worms',
	'/obj/item/bait_can/worm/premium': '/obj/item/storage/box/fishing_worms',
	'/obj/item/clothing/head/hardhat/warra': '/obj/item/clothing/head/hardhat',
	'/obj/item/clothing/head/hardhat/warra/white': '/obj/item/clothing/head/hardhat/white',
	'/obj/item/clothing/mask/gas/clip': '/obj/item/clothing/mask/gas/sechailer',
	'/obj/item/clothing/suit/ramzi': '/obj/item/clothing/suit/syndicatefake',
	'/obj/item/clothing/suit/space/syndicate/ramzi': '/obj/item/clothing/suit/space/syndicate',
	'/obj/item/clothing/under/cybersun/medic/skirt': '/obj/item/clothing/under/rank/medical/doctor/skirt',
	'/obj/item/clothing/under/cybersun/overalls': '/obj/item/clothing/under/misc/overalls',
	'/obj/item/clothing/under/frontiersmen/deckhand': '/obj/item/clothing/under/costume/pirate',
	'/obj/item/clothing/under/shorts/cookjorts': '/obj/item/clothing/under/rank/civilian/chef',
	'/obj/item/clothing/under/shorts/jorts': '/obj/item/clothing/under/shorts',
	'/obj/item/clothing/under/shorts/pink': '/obj/item/clothing/under/shorts/purple',
	'/obj/item/clothing/under/warra/affairs': '/obj/item/clothing/under/suit/black',
	'/obj/item/clothing/under/warra/janitor': '/obj/item/clothing/under/rank/civilian/janitor',
	'/obj/item/clothing/under/warra/security': '/obj/item/clothing/under/rank/security/officer',
	'/obj/item/desk_flag': None,
	'/obj/item/documents/syndicate/ngr': '/obj/item/documents/syndicate',
	'/obj/item/fish/pufferfish': '/obj/item/fish',
	'/obj/item/folder/documents/syndicate/ngr': '/obj/item/folder/syndicate',
	'/obj/item/food/meat/slab/remes': '/obj/item/food/meat/slab',
	'/obj/item/food/ration/side/beef_sticks': '/obj/item/food/meatball',
	'/obj/item/gear_pack/anglegrinder': None,
	'/obj/item/mine/pressure/explosive/rusty': '/obj/effect/mine/explosive',
	'/obj/item/pda/engineering': None,
	'/obj/item/reagent_containers/condiment/sugar': '/obj/item/reagent_containers/food/condiment/sugar',
	'/obj/item/reagent_containers/glass/bottle/vial/large/preloaded/silfrine': '/obj/item/reagent_containers/glass/bottle',
	'/obj/item/reagent_containers/glass/chem_jug/eznutriment': '/obj/item/reagent_containers/glass/bottle/nutrient/ez',
	'/obj/item/reagent_containers/hypospray/medipen/combat_drug': '/obj/item/reagent_containers/hypospray/combat',
	'/obj/item/seeds/carrot/parsnip': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/stack/cable_coil/red': '/obj/item/stack/cable_coil',
	'/obj/item/stack/sheet/metal/five': '/obj/item/stack/sheet/iron/five',
	'/obj/item/stock_parts/cell/gun': '/obj/item/stock_parts/cell',
	'/obj/item/storage/box/ammo/a12g_beanbag': '/obj/item/storage/box/beanbag',
	'/obj/item/storage/box/ammo/a308': '/obj/item/ammo_box/a762',
	'/obj/item/storage/box/fishing_lines': '/obj/item/storage/box/fishing_worms',
	'/obj/item/storage/box/shoalpockets/shoalpocketberry': '/obj/item/storage/box/donkpockets/donkpocketberry',
	'/obj/item/storage/toolbox/ammo/c556': '/obj/item/storage/toolbox/ammo',
	'/obj/item/storage/toolbox/ammo/c57': '/obj/item/storage/toolbox/ammo',
	'/obj/item/toy/plush/rilena': '/obj/item/toy/plush/carpplushie',
	'/obj/structure/fluff/ladder': None,
}.items():
	rep(p, n)
for d, n in DIRN.items():
	R['/obj/machinery/camera/autoname/directional/' + d] = ('/obj/machinery/camera/autoname', {'dir': n} if n != '2' else {})
DECISIONS['/obj/structure/fluff/ladder'] = 'pominięta atrapa drabiny'

TR.update({
	'A blob of various meats, formed into some strange clump. Are you seriously considering eating this?':
		'Bryła różnych mięs zlepiona w dziwną grudę. Naprawdę zamierzasz to zjeść?',
	'A congealed mass of decayed food. Good grief, it stinks.': 'Zastygła masa zepsutego jedzenia. Na litość boską, ale cuchnie.',
	'A high-capacity superconducting magnetic energy storage (SMES) unit.': 'Nadprzewodzący magnetyczny magazyn energii (SMES) o dużej pojemności.',
	'A large, comfy bedsheet.': 'Duże, wygodne prześcieradło.',
	'A member of the brutal Frontiersman terrorist fleet! Bedecked in military-grade armor, they steadily hold their well-kept DMR in your direction.':
		'Członek brutalnej terrorystycznej floty Pograniczników! W wojskowym pancerzu, pewnie celuje w ciebie z zadbanego karabinu wyborowego.',
	"APLU 'Forklift'": 'APLU „Wózek widłowy”',
	"Commander's sleep aid": 'Nasenne wsparcie dowódcy',
	'Frontiersman Adjunct': 'adiutant Pograniczników',
	'Frontiersman Chef': 'kucharz Pograniczników',
	'Frontiersman Supply Reports': 'Raporty zaopatrzenia Pograniczników',
	"If not for the fact it's probably full of various nasty bacteria, this Shoalwich would be perfectly preserved.":
		'Gdyby nie to, że pewnie roi się w niej od paskudnych bakterii, ta kanapka byłaby świetnie zachowana.',
	"It's broken beyond repair. Some sort of explosion seems to have ripped its bolts out. You may be able to salvage something from this.":
		'Zepsute nie do naprawy. Jakiś wybuch wyrwał mocowania. Może da się z tego coś odzyskać.',
	'Richie': 'Ryś',
	"This probably isn't good to drink": 'Tego chyba lepiej nie pić',
	'You could probably squeeze through this easily.': 'Pewnie bez trudu dałoby się tędy przecisnąć.',
	"You get the feeling that somehow, this cow wishes they'd hit Luna-Town again.":
		'Masz wrażenie, że ta krowa marzy, żeby znowu zabawić w Księżycowym Mieście.',
	"You get the feeling that somehow, this cow wishes they'd hit Luna-Town again. They also have a pancake in their mouth.":
		'Masz wrażenie, że ta krowa marzy, żeby znowu zabawić w Księżycowym Mieście. Do tego trzyma w pysku naleśnika.',
	"You're fairly certain this is just a mop.": 'Masz prawie pewność, że to zwykły mop.',
	'away shuttle supply crate': 'skrzynia zaopatrzenia promu wyprawowego',
	"captain's closet": 'szafa kapitana',
	'maintenance access shutter control': 'sterowanie roletami dostępu technicznego',
	'privacy shutters': 'rolety prywatności',
})
TURFS['/turf/open/floor/concrete/beachplanet/lit'] = ('/turf/open/floor/concrete', planetary())

# --- trzecia runda
for p, n in {
	'/mob/living/basic/human/frontier/ranged/officer/rifle': PIRATE_RANGED,
	'/mob/living/basic/human/ramzi/ranged/officer/beach': '/mob/living/basic/trooper/syndicate/ranged',
	'/mob/living/simple_animal/hostile/automated/walkmine/cybersun': '/obj/effect/mine/explosive',
	'/obj/effect/spawner/random/trash/misc_containers': '/obj/effect/decal/cleanable/dirt',
	'/obj/effect/turf_decal/industrial/shutoff': None,
	'/obj/item/attachment/gun/ballistic/shotgun': None,
	'/obj/item/bodypart/leg/left': '/obj/item/bodypart/l_leg',
	'/obj/item/clothing/head/helmet/space/syndicate/ramzi': '/obj/item/clothing/head/helmet/space/syndicate',
	'/obj/item/clothing/head/ramzi': '/obj/item/clothing/head/HoS/beret/syndicate',
	'/obj/item/clothing/head/soft/cybersun/medical': '/obj/item/clothing/head/soft',
	'/obj/item/clothing/head/soft/frontiersmen': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/warra/beret/security/command': '/obj/item/clothing/head/beret/sec',
	'/obj/item/clothing/mask/breath/facemask': '/obj/item/clothing/mask/breath',
	'/obj/item/clothing/suit/armor/captaincoat': '/obj/item/clothing/suit/captunic',
	'/obj/item/clothing/suit/armor/vest/cybersun/trauma': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/clothing/suit/armor/warra/slim': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/under/cybersun': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/cybersun/sneak': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/pants/cargo/khaki': '/obj/item/clothing/under/pants/khaki',
	'/obj/item/clothing/under/syndicate/ramzi/overalls': '/obj/item/clothing/under/misc/overalls',
	'/obj/item/clothing/under/warra/engineering': '/obj/item/clothing/under/rank/engineering/engineer',
	'/obj/item/clothing/under/warra/security/director': '/obj/item/clothing/under/rank/security/head_of_security',
	'/obj/item/fish/bass': '/obj/item/fish',
	'/obj/item/food/lifosa/homemade': '/obj/item/food/bread/plain',
	'/obj/item/food/meat/slab/tiris': '/obj/item/food/meat/slab/bear',
	'/obj/item/food/ration/condiment/chunky_peanut_butter': '/obj/item/food/sandwich',
	'/obj/item/gun/energy/sharplite/volt/empty_cell': '/obj/item/gun/energy/laser/retro',
	'/obj/item/radio/headset/alt': '/obj/item/radio/headset',
	'/obj/item/radio/weather_monitor': None,
	'/obj/item/reagent_containers/condiment/ketchup': '/obj/item/reagent_containers/food/condiment/ketchup',
	'/obj/item/reagent_containers/condiment/soysauce': '/obj/item/reagent_containers/food/condiment/soysauce',
	'/obj/item/seeds/carrot': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/sign/flag/ngr': None,
	'/obj/item/spacecash/bundle/mediumrand': '/obj/item/stack/spacecash/c100',
	'/obj/item/storage/box/ammo/c9mm_ap': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/shoalpockets/shoalpocketpizza': '/obj/item/storage/box/donkpockets/donkpocketpizza',
	'/obj/item/toy/plush/xader': '/obj/item/toy/plush/beeplushie',
	'/obj/item/wallframe/intercom/wideband/table': None,
	'/obj/machinery/atmospherics/components/binary/pump/layer5': '/obj/machinery/atmospherics/components/binary/pump',
	'/obj/machinery/light/street': '/obj/machinery/light',
	'/obj/structure/chair/bench/orange': '/obj/structure/chair/fancy/bench',
	'/obj/structure/chair/pew/right': '/obj/structure/chair/fancy/bench/pew/right',
	'/obj/structure/chair/sofa/blue/corpo/left/directional/south': '/obj/structure/chair/fancy/sofa/corp/left',
	'/obj/structure/chair/sofa/blue/corpo/right/directional/south': '/obj/structure/chair/fancy/sofa/corp/right',
	'/obj/structure/hazard/fire/wires/alarm': None,
	'/obj/structure/sauna_oven': ('/obj/structure/frame/machine', {'anchored': '1', 'name': '"piec do sauny"'}),
	'/obj/structure/sign/poster/contraband/eoehoma': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/warra/vigilitas': None,
}.items():
	rep(p, n)
WALL_CLOSETS['/obj/structure/closet/secure_closet/freezer/wall'] = '/obj/structure/closet/secure_closet/freezer/kitchen'
DECISIONS['/obj/structure/sauna_oven'] = 'piec sauny -> pusta rama maszyny (nie mamy saun)'
DECISIONS['walkmine'] = 'chodząca mina Cybersun -> zwykła mina'
TURFS['/turf/open/floor/plasteel/mono/white/beachplanet/lit'] = ('/turf/open/floor/monotile/light', planetary())

TR.update({
	'A crab. The insignia of the Ramzi Clique has been tattooed on its right claw, and you can see a little chip on its back.':
		'Krab. Na prawych szczypcach ma wytatuowany znak Kliki Ramziego, a na grzbiecie widać mały czip.',
	'A member of the brutal Frontiersman terrorist fleet! This one clutches an average looking kitchen knife, and seems quite frustrated.':
		'Członek brutalnej terrorystycznej floty Pograniczników! Ściska zwykły nóż kuchenny i wygląda na mocno sfrustrowanego.',
	'Armoury Shutters': 'rolety zbrojowni',
	'frontiersmen jorts': 'dżinsowe szorty Pograniczników',
	'incredibly stale sandwich': 'niesamowicie czerstwa kanapka',
	'shutters': 'rolety',
	'piec do sauny': 'piec do sauny',
})

# --- czwarta runda
for p, n in {
	'/obj/item/clothing/head/helmet/m10/cybersun/trauma': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/warra/beret': '/obj/item/clothing/head/beret',
	'/obj/item/clothing/neck/cloak/warra': '/obj/item/clothing/neck/cloak',
	'/obj/item/clothing/suit/armor/ramzi/officer': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/clothing/under/cybersun/officer': '/obj/item/clothing/under/syndicate',
	'/obj/item/desk_flag/ngr': None,
	'/obj/item/fish/emulsijack': '/obj/item/fish',
	'/obj/item/food/dofi_nari': '/obj/item/food/tofu',
	'/obj/item/reagent_containers/condiment/mayonnaise': '/obj/item/reagent_containers/food/condiment/ketchup',
	'/obj/item/seeds/cherry': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/storage/belt/security/webbing/ramzi': '/obj/item/storage/belt/military',
	'/obj/item/storage/box/shoalpockets/shoalpocketspicy': '/obj/item/storage/box/donkpockets/donkpocketspicy',
	'/obj/item/storage/fancy/cigarettes/derringer': '/obj/item/storage/fancy/cigarettes',
	'/obj/structure/hazard/electrical/electric_sparks/alarm': None,
}.items():
	rep(p, n)
TR.update({
	'...They make these?': '...To takie robią?',
	'You get the feeling that eating this is pretty high on the list of bad ideas.': 'Masz wrażenie, że zjedzenie tego jest dość wysoko na liście złych pomysłów.',
	'cybersun jorts': 'dżinsowe szorty Cybersun',
	"officer's suite lock": 'zamek apartamentu oficerskiego',
	'storage door': 'drzwi magazynu',
	"torn captain's fur coat": 'podarte kapitańskie futro',
})

# --- piąta runda
for p, n in {
	'/obj/item/clothing/head/cybersun': '/obj/item/clothing/head/HoS/beret/syndicate',
	'/obj/item/clothing/head/ngr': '/obj/item/clothing/head/beret',
	'/obj/item/clothing/under/warra/captain': '/obj/item/clothing/under/suit/black',
	'/obj/item/fish/salmon': '/obj/item/fish',
	'/obj/item/food/grown/berries/poison/stealth': '/obj/item/food/grown/potato/sweet',
	'/obj/item/reagent_containers/condiment/hotsauce': '/obj/item/reagent_containers/food/condiment/ketchup',
	'/obj/item/seeds/garlic': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/storage/belt/military/cybersun': '/obj/item/storage/belt/military',
	'/obj/item/storage/box/shoalpockets/shoalpocketteriyaki': '/obj/item/storage/box/donkpockets',
}.items():
	rep(p, n)
TR.update({
	'A long, stiff commanding coat, meant for frigid conditions. There are noticeable gashes all across it.':
		'Długi, sztywny płaszcz dowódcy na mrozy. Cały jest pocięty.',
	'A pair of Cybersun-branded jorts, possibly dating back to the Inter-Corporate War. For styling on your corporate rivals.':
		'Dżinsowe szorty z logo Cybersun, pewnie jeszcze z wojny międzykorporacyjnej. Żeby szpanować przed korporacyjną konkurencją.',
	'armory lockdown': 'blokada zbrojowni',
})
R['/obj/item/food/grown/berries/poison/stealth'] = '/obj/item/food/grown/berries/poison'
R['/obj/item/reagent_containers/condiment/hotsauce'] = '/obj/item/reagent_containers/food/condiment/hotsauce'
R['/obj/item/storage/box/shoalpockets/shoalpocketteriyaki'] = '/obj/item/storage/box/donkpockets/donkpocketteriyaki'
for p, n in {
	'/obj/item/clothing/suit/armor/cybersun': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/armor/ngr/lieutenant': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/seeds/grape/green': '/obj/effect/spawner/lootdrop/random_seeds',
	'/obj/item/storage/box/ammo/a357': '/obj/item/ammo_box/a357',
}.items():
	rep(p, n)
TR.update({
	'particularly bad bunch of berries': 'wyjątkowo podła kiść jagód',
	'windows': 'okna',
})
for p, n in {
	'/obj/item/clothing/suit/armor/ramzi/captain': '/obj/item/clothing/suit/armor/vest/capcarapace',
	'/obj/item/clothing/under/syndicate/ngr/officer': '/obj/item/clothing/under/syndicate/combat',
	'/obj/item/seeds/tomato': '/obj/effect/spawner/lootdrop/random_seeds',
}.items():
	rep(p, n)
TR.update({
	'Good grief is this a bad idea.': 'Na litość boską, co za zły pomysł.',
	'Mr. Duffel': 'Pan Torba',
})
rep('/obj/item/clothing/head/ramzi/peaked', '/obj/item/clothing/head/HoS/beret/syndicate')
for seed in ['sweet_potato', 'potato', 'carrot/parsnip', 'cabbage', 'garlic', 'cherry', 'grape', 'grape/green', 'tomato', 'berry', 'tea', 'coffee', 'cotton', 'sugarcane', 'watermelon', 'wheat', 'corn', 'onion', 'soya', 'eggplant', 'lettuce', 'pumpkin', 'banana', 'apple', 'orange', 'lemon', 'lime', 'chili', 'rice']:
	rep('/obj/item/seeds/' + seed, '/obj/effect/spawner/lootdrop/random_seeds')
DECISIONS['/obj/item/seeds/*'] = 'nasiona Shiptesta -> losowe nasiona (nasza botanika ma inne gatunki)'
R['/obj/machinery/atmospherics/components/binary/pump/layer5'] = ('/obj/machinery/atmospherics/components/binary/pump', {'piping_layer': '5'})
