"""Zamienniki dla ruin księżyca (MoonRuins), kraterów (greeble moon_crater*) i ruin kosmicznych (SpaceRuins) Shiptesta.
Wspólne dla obu partii map: przedmioty, maszyny, struktury i dekale. Obszary i turfy ruin kosmicznych są w space.py,
obszary ruin księżyca tutaj. Kolory i kształty dekali Shiptesta, których nie zna convert_maps.py, dopisujemy do jego
tablic (moduł __main__), a dekale bez odpowiednika obsługuje owinięta funkcja decal().
"""
import __main__ as cm

from mappings.common import AREAS, DECISIONS, R, TR, TURFS, rep

AIRLESS = '"TEMP=2.7"'
PLASMA_HALF = '"n2=50;plasma=50;TEMP=293.15"'
BREATHABLE = '"o2=22;n2=82;TEMP=293.15"'

# ---------------------------------------------------------------- dekale
cm.ST_COLORS.update({
	'lightgrey': '#a8b2b6', 'bottlegreen': '#57967f', 'nsorange': '#f97016', 'vired': '#c92020',
	'cybersunteal': '#4C9C9C', 'orange': '#b95a00', 'purple': '#a2819e', 'brown': '#917448',
})
cm.OUR_COLOR.update({
	'lightgrey': 'neutral', 'bottlegreen': 'green', 'nsorange': 'yellow', 'vired': 'red',
	'cybersunteal': 'blue', 'orange': 'yellow', 'purple': 'purple', 'brown': 'brown',
})
cm.CORNER_SHAPES.update({
	'bordercee': ('fourcorners', None),
	'borderfull': ('fourcorners', None),
})

EXTRA_DECALS = {
	'/obj/effect/turf_decal/borderfloor/cee': '/obj/effect/turf_decal/ship/borderfloor',
	'/obj/effect/turf_decal/borderfloor/full': '/obj/effect/turf_decal/ship/borderfloor',
	'/obj/effect/turf_decal/borderfloorblack/corner': '/obj/effect/turf_decal/ship/borderfloor/corner',
	'/obj/effect/turf_decal/industrial/caution': '/obj/effect/turf_decal/caution',
	'/obj/effect/turf_decal/industrial/hatch/yellow': '/obj/effect/turf_decal/delivery',
	'/obj/effect/turf_decal/industrial/outline/blue': '/obj/effect/turf_decal/box/white',
	'/obj/effect/turf_decal/industrial/warning/cee': '/obj/effect/turf_decal/stripes/end',
	'/obj/effect/turf_decal/industrial/warning/fulltile': '/obj/effect/turf_decal/stripes/box',
	'/obj/effect/turf_decal/industrial': '/obj/effect/turf_decal/stripes/line',
	'/obj/effect/turf_decal/siding/wood/bamboo': '/obj/effect/turf_decal/siding/wood',
	'/obj/effect/turf_decal/siding/wood/mahogany': '/obj/effect/turf_decal/siding/wood',
	'/obj/effect/turf_decal/siding/wood/walnut': '/obj/effect/turf_decal/siding/wood',
	'/obj/effect/turf_decal/siding/wood/corner/bamboo': '/obj/effect/turf_decal/siding/wood/corner',
	'/obj/effect/turf_decal/siding/wood/corner/mahogany': '/obj/effect/turf_decal/siding/wood/corner',
	'/obj/effect/turf_decal/siding/wood/corner/walnut': '/obj/effect/turf_decal/siding/wood/corner',
	'/obj/effect/turf_decal/siding/wood/end/bamboo': '/obj/effect/turf_decal/siding/wood/end',
}
# Dekoracje bez odpowiednika (godła, detale posadzek, panele, ładowarki): pomijamy
DROP_DECALS = ('/obj/effect/turf_decal/syndicateemblem', '/obj/effect/turf_decal/etherbor', '/obj/effect/turf_decal/floordetail',
	'/obj/effect/turf_decal/rechargefloor', '/obj/effect/turf_decal/solarpanel', '/obj/effect/turf_decal/corner_steel_grid',
	'/obj/effect/turf_decal/corner_techfloor_gray', '/obj/effect/turf_decal/radiation', '/obj/effect/turf_decal/industrial/radiation')

EXTRA_DECALS_COLORED = {
	'/obj/effect/turf_decal/trimline/transparent/syndiered': ('/obj/effect/turf_decal/trimline/red/line', '"#730622"', '140'),
}

_original_decal = cm.decal


def _decal(path, vars_, mapname):
	if path in EXTRA_DECALS:
		nv = {}
		d = int(vars_.get('dir', '2'))
		if d != 2:
			nv['dir'] = str(d)
		if 'color' in vars_:
			nv['color'] = vars_['color']
		return [cm.atom(EXTRA_DECALS[path], nv)]
	if path.startswith(DROP_DECALS):
		return None
	if path in EXTRA_DECALS_COLORED:
		target, color, alpha = EXTRA_DECALS_COLORED[path]
		nv = {}
		d = int(vars_.get('dir', '2'))
		if d != 2:
			nv['dir'] = str(d)
		nv['color'] = color
		nv['alpha'] = alpha
		return [cm.atom(target, nv)]
	if path == '/obj/effect/turf_decal/corner/opaque':
		return None
	return _original_decal(path, vars_, mapname)


cm.decal = _decal
DECISIONS['dekale Shiptesta bez odpowiednika (godła Syndykatu, etherbor, detale, panele, ładowarki)'] = 'pominięte'

# ---------------------------------------------------------------- moby
for p, n in {
	'/mob/living/basic/hivebot/core': '/mob/living/basic/hivebot/strong',
	'/mob/living/basic/hivebot/mechanic': '/mob/living/basic/hivebot',
	'/mob/living/basic/hivebot/ranged': '/mob/living/basic/hivebot/range',
	'/mob/living/basic/human/ramzi/civilian': '/mob/living/basic/trooper/syndicate/melee',
	'/mob/living/basic/human/ramzi/civilian/space': '/mob/living/basic/trooper/syndicate/melee/space',
	'/mob/living/basic/human/ramzi/melee/machete': '/mob/living/basic/trooper/syndicate/melee/sword',
	'/mob/living/basic/human/ramzi/melee/space/soft/machete': '/mob/living/basic/trooper/syndicate/melee/sword/space',
	'/mob/living/basic/human/ramzi/ranged/space/soft': '/mob/living/basic/trooper/syndicate/ranged/space',
	'/mob/living/basic/human/ramzi/ranged/space/soft/smg': '/mob/living/basic/trooper/syndicate/ranged/smg/space',
	'/mob/living/basic/human/ramzi/ranged/space/stormtrooper/shotgun/incendiary': '/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper',
	'/mob/living/basic/human/ramzi/ranged/space/stormtrooper/sniper': '/mob/living/basic/trooper/syndicate/ranged/space/stormtrooper',
	'/mob/living/basic/human/warra/elite/shotgun': '/mob/living/basic/trooper/nanotrasen/ranged/smg',
	'/mob/living/basic/human/warra/ranged/laser/space': '/mob/living/basic/trooper/nanotrasen/ranged',
	'/mob/living/basic/human/warra/ranged/trooper/rifle/space': '/mob/living/basic/trooper/nanotrasen/ranged',
	'/mob/living/basic/human/warra/ranged/trooper/shotgun/space': '/mob/living/basic/trooper/nanotrasen/ranged/smg',
	'/mob/living/basic/human/warra/ranged/trooper/smg/space': '/mob/living/basic/trooper/nanotrasen/ranged/smg',
	'/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/forgotten': '/mob/living/basic/mining/watcher/forgotten',
	'/mob/living/simple_animal/hostile/netherworld/asteroid': '/mob/living/basic/creature',
	'/mob/living/simple_animal/hostile/venus_human_trap': '/mob/living/basic/venus_human_trap',
	'/mob/living/simple_animal/hostile/human/zombie/kudzu': '/mob/living/basic/zombie',
	'/mob/living/simple_animal/hostile/human/shell': ('/mob/living/basic/hivebot', {'name': '"pusta skorupa"'}),
	'/mob/living/simple_animal/beachcarp/bass': None,
}.items():
	rep(p, n)
# Frontiersmen (kozacy z mosinami) -> nasi rosyjscy żołnierze, w próżni piraci w skafandrach
for p in ['/mob/living/basic/human/frontier', '/mob/living/basic/human/frontier/internals']:
	rep(p, '/mob/living/basic/trooper/russian')
for p in ['/mob/living/basic/human/frontier/ranged/internals', '/mob/living/basic/human/frontier/ranged/mosin/internals/neutered/sentry',
		'/mob/living/basic/human/frontier/ranged/wasp/internals']:
	rep(p, '/mob/living/basic/trooper/russian/ranged/mosin')
for p in ['/mob/living/basic/human/frontier/ranged/officer/cm15', '/mob/living/basic/human/frontier/ranged/officer/internals']:
	rep(p, '/mob/living/basic/trooper/russian/ranged/officer')
rep('/mob/living/basic/human/frontier/ranged/pounder/internals', '/mob/living/basic/trooper/russian/ranged/trooper')
rep('/mob/living/basic/human/frontier/ranged/trooper/spitter', '/mob/living/basic/trooper/russian/ranged/trooper')
for p in ['/mob/living/basic/human/frontier/ranged/mosin/space/sentry', '/mob/living/basic/human/frontier/ranged/pounder/space',
		'/mob/living/basic/human/frontier/ranged/space', '/mob/living/basic/human/frontier/ranged/trooper/fa2/space',
		'/mob/living/basic/human/frontier/ranged/trooper/heavy/space/neutered', '/mob/living/basic/human/frontier/ranged/trooper/space',
		'/mob/living/basic/human/frontier/ranged/trooper/space/spitter']:
	rep(p, '/mob/living/basic/trooper/pirate/ranged/space')
DECISIONS['/mob/living/basic/human/frontier/*'] = 'Frontiersmen -> nasi rosyjscy żołnierze (w próżni: piraci w skafandrach)'
# Automaty Shiptesta -> hivebot z frakcją obrońców ruiny (jak przy lawie)
for p, n in {
	'/mob/living/simple_animal/hostile/automated/agrav/cybersun': ('/mob/living/basic/hivebot/range', {'faction': 'list("Syndicate")'}),
	'/mob/living/simple_animal/hostile/automated/quadrotor/cybersun': ('/mob/living/basic/hivebot/rapid', {'faction': 'list("Syndicate")'}),
	'/mob/living/simple_animal/hostile/automated/hopper/coalition': ('/mob/living/basic/hivebot/rapid', {'faction': 'list("nanotrasenprivate")'}),
	'/mob/living/simple_animal/hostile/automated/rover/coalition': ('/mob/living/basic/hivebot/rapid', {'faction': 'list("nanotrasenprivate")'}),
	'/mob/living/simple_animal/hostile/automated/rover/coalition/dmr': ('/mob/living/basic/hivebot/range', {'faction': 'list("nanotrasenprivate")'}),
}.items():
	rep(p, n)

# ---------------------------------------------------------------- zwłoki
for p, n in {
	'/obj/effect/mob_spawn/human/corpse/clip/minuteman/eod/bombsuit': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/cybersun': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/cybersun/dev': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/cybersun/engineer': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/cybersun/troubleshooter': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/mob_spawn/human/corpse/cybersun/troubleshooter/hardsuit': '/obj/effect/mob_spawn/human/corpse/syndicatecommando',
	'/obj/effect/mob_spawn/human/corpse/cybersun/troubleshooter/hardsuit/heavy': '/obj/effect/mob_spawn/human/corpse/syndicatecommando',
	'/obj/effect/mob_spawn/human/corpse/frontier/space': '/obj/effect/mob_spawn/human/corpse/pirate',
	'/obj/effect/mob_spawn/human/corpse/ipcshell': '/obj/effect/mob_spawn/human/corpse/damaged',
	'/obj/effect/mob_spawn/human/corpse/pgf': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/pgf/captain': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/pgf/marine': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
	'/obj/effect/mob_spawn/human/corpse/ramzi/space/soft/surplus': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/mob_spawn/human/corpse/vigilitas_director': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
}.items():
	rep(p, n)

# ---------------------------------------------------------------- efekty, spawnery
for p, n in {
	'/obj/effect/decal/cleanable/glass/plastitanium': '/obj/effect/decal/cleanable/glass',
	'/obj/effect/mapping_helpers/airlock/sealed': '/obj/effect/mapping_helpers/airlock/locked',
	'/obj/effect/mapping_helpers/airlock/welded': '/obj/effect/mapping_helpers/airlock/locked',
	'/obj/effect/radiation': None,
	'/obj/effect/spawner/random/food_or_drink/shoalpockets': '/obj/item/food/donkpocket',
	'/obj/effect/spawner/random/maintenance/two': '/obj/effect/spawner/lootdrop/maintenance/two',
	'/obj/effect/spawner/random/trash/crushed_can': '/obj/item/trash/can',
	'/obj/effect/spawner/random/vending/cola': '/obj/machinery/vending/cola/random',
}.items():
	rep(p, n)
DECISIONS['/obj/effect/radiation'] = 'pominięte: źródło promieniowania Shiptesta (stary model); planeta-śmietnisko robi własne'
DECISIONS['/obj/effect/mapping_helpers/airlock/sealed, /welded'] = 'zablokowane śluzy -> zamknięte na stałe (locked)'

# ---------------------------------------------------------------- przedmioty
EMPTY = {'start_empty': '1'}
for p, n in {
	'/obj/item/ammo_box/magazine/boomslang/empty': ('/obj/item/ammo_box/magazine/m556', EMPTY),
	'/obj/item/ammo_box/magazine/cm15_12g': '/obj/item/ammo_box/magazine/m12g',
	'/obj/item/ammo_box/magazine/cs_gauss/pistol/empty': ('/obj/item/ammo_box/magazine/pistolm9mm', EMPTY),
	'/obj/item/ammo_box/magazine/cs_gauss/rifle/empty': ('/obj/item/ammo_box/magazine/m556', EMPTY),
	'/obj/item/ammo_box/magazine/m12g_bulldog/empty': ('/obj/item/ammo_box/magazine/m12g', EMPTY),
	'/obj/item/ammo_box/magazine/m556_42_hydra': '/obj/item/ammo_box/magazine/m556',
	'/obj/item/ammo_box/magazine/m57_39_asp': '/obj/item/ammo_box/magazine/wt550m9',
	'/obj/item/ammo_casing/spent/magnum_brass': '/obj/item/ammo_casing/spent',
	'/obj/item/ammo_casing/spent/slug': '/obj/item/ammo_casing/spent',
	'/obj/item/ammo_casing/spent/slug/beanbag': '/obj/item/ammo_casing/spent',
	'/obj/item/bedsheet/warra': '/obj/item/bedsheet/blue',
	'/obj/item/bodycamera/broadcast_camera': None,
	'/obj/item/bodypart/leg/left': '/obj/item/bodypart/l_leg',
	'/obj/item/book/manual/wiki/engineering': '/obj/item/book/manual/wiki/engineering_guide',
	'/obj/item/circuitboard/machine/shuttle/engine/electric': '/obj/item/circuitboard/machine/shuttle/engine',
	'/obj/item/clothing/glasses/safety': '/obj/item/clothing/glasses/regular',
	'/obj/item/clothing/gloves/gezena': '/obj/item/clothing/gloves/color/black',
	'/obj/item/clothing/gloves/insulated': '/obj/item/clothing/gloves/color/yellow',
	'/obj/item/clothing/head/helmet/space/gezena': '/obj/item/clothing/head/helmet/space',
	'/obj/item/clothing/head/ramzi': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/soft/frontiersmen': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/mask/gas/atmos': '/obj/item/clothing/mask/gas',
	'/obj/item/clothing/mask/gas/clip': '/obj/item/clothing/mask/gas',
	'/obj/item/clothing/neck/cloak/gezena/engi': '/obj/item/clothing/neck/cloak',
	'/obj/item/clothing/neck/dogtag/ramzi': '/obj/item/clothing/neck/necklace',
	'/obj/item/clothing/suit/armor/ramzi/officer': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/clothing/suit/armor/vest/syndie': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/armor/warra': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/space/hardsuit/security/hos': '/obj/item/clothing/suit/space/hardsuit/security/head_of_security',
	'/obj/item/clothing/suit/space/hardsuit/security/independent/frontier': '/obj/item/clothing/suit/space/hardsuit/security',
	'/obj/item/clothing/suit/space/hardsuit/stealth': '/obj/item/clothing/suit/space/hardsuit/syndi',
	'/obj/item/clothing/suit/space/hardsuit/syndi/ramzi': '/obj/item/clothing/suit/space/hardsuit/syndi',
	'/obj/item/clothing/suit/space/syndicate/engie': '/obj/item/clothing/suit/space/syndicate',
	'/obj/item/clothing/suit/space/syndicate/ramzi': '/obj/item/clothing/suit/space/syndicate/black/red',
	'/obj/item/clothing/under/cybersun/sneak': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/cybersun/suit': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/frontiersmen': '/obj/item/clothing/under/syndicate/combat',
	'/obj/item/clothing/under/syndicate/gorlex': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/syndicate/ramzi/overalls': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/warra/security': '/obj/item/clothing/under/rank/security/officer',
	'/obj/item/clothing/under/warra/security/director': '/obj/item/clothing/under/rank/security/officer',
	'/obj/item/coffee_cartridge/fancy/blue': '/obj/item/coffee_cartridge/fancy',
	'/obj/item/crowbar/syndie': '/obj/item/crowbar/red',
	'/obj/item/documents/syndicate/cybersun': '/obj/item/documents/syndicate',
	'/obj/item/documents/warra': '/obj/item/documents',
	'/obj/item/door_seal': None,
	'/obj/item/extinguisher/empty': '/obj/item/extinguisher',
	'/obj/item/flashlight/flare/burnt': None,
	'/obj/item/food/dofi_tese': '/obj/item/food/donkpocket',
	'/obj/item/food/meat/slab/tiris': '/obj/item/food/meat/slab',
	'/obj/item/food/ration/entree/battered_fish_sticks': '/obj/item/food/donkpocket',
	'/obj/item/gear_pack/anglegrinder': None,
	'/obj/item/gun/ballistic/automatic/assault/hydra/dmr/no_mag': ('/obj/item/gun/ballistic/automatic/wt550', {'spawnwithmagazine': '0'}),
	'/obj/item/gun/ballistic/automatic/pistol/asp/no_mag': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
	'/obj/item/gun/ballistic/automatic/pistol/mauler/regular': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/ballistic/automatic/pistol/rattlesnake/cottonmouth': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/ballistic/automatic/smg/resolution/no_mag': ('/obj/item/gun/ballistic/automatic/wt550', {'spawnwithmagazine': '0'}),
	'/obj/item/gun/ballistic/cs_gauss/rectifier/no_mag': ('/obj/item/gun/ballistic/automatic/wt550', {'spawnwithmagazine': '0'}),
	'/obj/item/gun/ballistic/cs_gauss/vector/no_mag': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
	'/obj/item/gun/ballistic/shotgun/automatic/bulldog/no_mag': '/obj/item/gun/ballistic/shotgun',
	'/obj/item/gun/ballistic/shotgun/blasting_hammer': '/obj/item/melee/sledgehammer',
	'/obj/item/gun/energy/cybersun/lorentz/opportunist': '/obj/item/gun/energy/laser',
	'/obj/item/gun/energy/e_gun/e11/empty_cell': '/obj/item/gun/energy/e_gun/mini',
	'/obj/item/gun/energy/e_gun/rdgun': '/obj/item/gun/energy/e_gun',
	'/obj/item/gun/energy/kalix/pgf/heavy': '/obj/item/gun/energy/laser',
	'/obj/item/gun/energy/laser/wasp': '/obj/item/gun/energy/laser',
	'/obj/item/gun/energy/sharplite/amperage': '/obj/item/gun/energy/e_gun/mini',
	'/obj/item/gun/energy/sharplite/rush': '/obj/item/gun/energy/laser/retro',
	'/obj/item/gun/energy/sharplite/yari': '/obj/item/gun/energy/laser',
	'/obj/item/hypospray/mkii': '/obj/item/reagent_containers/hypospray/medipen',
	'/obj/item/inducer/syndicate': '/obj/item/inducer',
	'/obj/item/melee/knife/combat': '/obj/item/kitchen/knife/combat',
	'/obj/item/melee/knife/switchblade': '/obj/item/switchblade',
	'/obj/item/mine/pressure/explosive/live': '/obj/effect/mine/explosive',
	'/obj/item/paper/crumpled/fluff': '/obj/item/paper/crumpled',
	'/obj/item/paper_bin/carbon': '/obj/item/paper_bin',
	'/obj/item/pickaxe/rusted': '/obj/item/pickaxe',
	'/obj/item/radio/intercom/wideband/table': '/obj/item/radio',
	'/obj/item/reagent_containers/condiment/ketchup': '/obj/item/reagent_containers/food/condiment/ketchup',
	'/obj/item/reagent_containers/condiment/mayonnaise': '/obj/item/reagent_containers/food/condiment/mayonnaise',
	'/obj/item/reagent_containers/food/drinks/beaglemug': '/obj/item/reagent_containers/food/drinks/mug',
	'/obj/item/reagent_containers/food/drinks/bottle/amaretto': '/obj/item/reagent_containers/food/drinks/bottle/kahlua',
	'/obj/item/reagent_containers/food/drinks/coffee/large': '/obj/item/reagent_containers/food/drinks/coffee',
	'/obj/item/reagent_containers/food/drinks/mug/coco': '/obj/item/reagent_containers/food/drinks/mug/coco',
	'/obj/item/reagent_containers/food/drinks/soda_cans/comet_trail': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/reagent_containers/food/drinks/soda_cans/lunapunch': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/reagent_containers/food/drinks/soda_cans/tadrixx': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/reagent_containers/food/drinks/waterbottle': '/obj/item/reagent_containers/food/drinks/waterbottle',
	'/obj/item/reagent_containers/food/drinks/waterbottle/large/empty': '/obj/item/reagent_containers/food/drinks/waterbottle/empty',
	'/obj/item/reagent_containers/glass/bottle/chitosan': '/obj/item/reagent_containers/glass/bottle/charcoal',
	'/obj/item/reagent_containers/glass/bottle/dimorlin': '/obj/item/reagent_containers/glass/bottle/morphine',
	'/obj/item/reagent_containers/glass/bottle/vial/small/preloaded/indomide': '/obj/item/reagent_containers/glass/bottle/morphine',
	'/obj/item/reagent_containers/glass/chem_jug/chlorine': '/obj/item/reagent_containers/glass/bottle/chlorine',
	'/obj/item/reagent_containers/glass/mortar/metal': '/obj/item/reagent_containers/glass/mortar',
	'/obj/item/reagent_containers/hypospray/medipen/mammoth': '/obj/item/reagent_containers/hypospray/medipen/stimulants',
	'/obj/item/reagent_containers/hypospray/medipen/rabbit': '/obj/item/reagent_containers/hypospray/medipen',
	'/obj/item/reagent_containers/hypospray/medipen/tramal': '/obj/item/reagent_containers/hypospray/medipen/morphine',
	'/obj/item/reagent_containers/medigel/sterilizine': '/obj/item/reagent_containers/spray/cleaner',
	'/obj/item/reagent_containers/syringe/contraband/morphine': '/obj/item/reagent_containers/syringe/contraband/morphine',
	'/obj/item/research_notes/loot/small': '/obj/item/disk/tech_disk',
	'/obj/item/sales_tagger': None,
	'/obj/item/screwdriver/power': '/obj/item/screwdriver',
	'/obj/item/seeds/kudzu': '/obj/item/seeds/kudzu',
	'/obj/item/shard/plastitanium': '/obj/item/shard',
	'/obj/item/stack/cable_coil/red': '/obj/item/stack/cable_coil',
	'/obj/item/stack/medical/splint': '/obj/item/stack/medical/bone_gel',
	'/obj/item/stack/ore/salvage/scrapmetal/twenty': ('/obj/item/stack/ore/iron', {'amount': '20'}),
	'/obj/item/stack/sheet/metal/five': ('/obj/item/stack/sheet/iron', {'amount': '5'}),
	'/obj/item/stack/sheet/mineral/plastitanium/twenty': ('/obj/item/stack/sheet/mineral/plastitanium', {'amount': '20'}),
	'/obj/item/stack/sheet/mineral/uranium/ten': ('/obj/item/stack/sheet/mineral/uranium', {'amount': '10'}),
	'/obj/item/stack/tape/industrial': '/obj/item/stack/sticky_tape/super',
	'/obj/item/stack/tile/plasteel/dark': '/obj/item/stack/tile/plasteel',
	'/obj/item/stack/tile/plasteel/tech/techmaint': '/obj/item/stack/tile/plasteel',
	'/obj/item/stack/tile/plasteel/white': '/obj/item/stack/tile/plasteel',
	'/obj/item/stamp/qm': '/obj/item/stamp',
	'/obj/item/stock_parts/cell/gun': '/obj/item/stock_parts/cell',
	'/obj/item/stock_parts/cell/gun/empty': '/obj/item/stock_parts/cell/empty',
	'/obj/item/stock_parts/cell/gun/kalix': '/obj/item/stock_parts/cell',
	'/obj/item/stock_parts/cell/gun/pgf': '/obj/item/stock_parts/cell/high',
	'/obj/item/storage/backpack/satchel/flat/onehalftwo': '/obj/item/storage/backpack/satchel/flat',
	'/obj/item/storage/box/ammo/a12g_blank': '/obj/item/storage/box/beanbag',
	'/obj/item/storage/box/ammo/a357': '/obj/item/ammo_box/a357',
	'/obj/item/storage/box/ammo/c22lr/ap': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/ammo/c320': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/ammo/pulseslug': '/obj/item/storage/box/lethalshot',
	'/obj/item/storage/box/firecrackers': '/obj/item/storage/box/matches',
	'/obj/item/storage/box/stockparts/t2': '/obj/item/storage/box/stockparts/basic',
	'/obj/item/storage/case/surgery': '/obj/item/storage/backpack/duffelbag/med/surgery',
	'/obj/item/storage/pill_bottle/tramal': '/obj/item/storage/pill_bottle/psicodine',
	'/obj/item/storage/toolbox/ammo/c65': '/obj/item/ammo_box/a762',
	'/obj/item/toy/cards/deck/kotahi': '/obj/item/toy/cards/deck',
	'/obj/item/toy/seashell': None,
	'/obj/item/trash/can/food/peaches': '/obj/item/trash/can',
	'/obj/item/wallframe/intercom/table': '/obj/item/wallframe/intercom',
	'/obj/item/weldingtool/empty': '/obj/item/weldingtool',
	'/obj/item/wrench/crescent': '/obj/item/wrench',
}.items():
	rep(p, n)
# kartki z ruin: zwykłe zmięte kartki (fluff Shiptesta bez naszego tekstu)
for p in ['/obj/item/paper/crumpled/bloody/fluff/ruin/space/ramzistation/maintlog', '/obj/item/paper/crumpled/bloody/fluff/ruin/space/ramzistation/toilet']:
	rep(p, '/obj/item/paper/crumpled/bloody')
for p in ['/obj/item/paper/crumpled/fluff/ruin/space/deepstorage/diary', '/obj/item/paper/crumpled/fluff/ruin/space/deepstorage/orders']:
	rep(p, '/obj/item/paper/crumpled')

# ---------------------------------------------------------------- maszyny
for p, n in {
	'/obj/machinery/atmospherics/components/unary/hydrogen_pump': None,
	'/obj/machinery/atmospherics/components/unary/portables_connector/layer1': '/obj/machinery/atmospherics/components/unary/portables_connector/visible',
	'/obj/machinery/atmospherics/components/unary/shuttle/fire_heater': None,
	'/obj/machinery/atmospherics/components/unary/vent_pump/layer2': '/obj/machinery/atmospherics/components/unary/vent_pump/on/layer2',
	'/obj/machinery/atmospherics/components/unary/vent_pump/layer4': '/obj/machinery/atmospherics/components/unary/vent_pump/on/layer4',
	'/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/layer1': '/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on',
	'/obj/machinery/coffeemaker/premium': '/obj/machinery/coffeemaker',
	'/obj/machinery/computer/electrolyzer_console/directional/north': ('/obj/structure/frame/computer', {'anchored': '1'}),
	'/obj/machinery/computer/helm/viewscreen/directional/west': None,
	'/obj/machinery/computer/processing_unit_console/directional/north': ('/obj/machinery/mineral/processing_unit_console', {'pixel_y': '28'}),
	'/obj/machinery/computer/processing_unit_console/directional/west': ('/obj/machinery/mineral/processing_unit_console', {'pixel_x': '-28'}),
	'/obj/machinery/computer/solar_control': '/obj/machinery/power/solar_control',
	'/obj/machinery/door/firedoor/heavy/closed': '/obj/machinery/door/firedoor/closed',
	'/obj/machinery/field/generator/anchored': ('/obj/machinery/field/generator', {'anchored': '1'}),
	'/obj/machinery/flasher/portable/anchored': ('/obj/machinery/flasher/portable', {'anchored': '1'}),
	'/obj/machinery/holosign/evacuation': None,
	'/obj/machinery/hydroponics/constructable': '/obj/machinery/hydroponics',
	'/obj/machinery/mineral/electrolyzer': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/machinery/mineral/electrolyzer_unloader': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/machinery/plantgenes/seedvault': '/obj/machinery/seed_extractor',
	'/obj/machinery/porta_turret/ruin/cybersun': '/obj/machinery/porta_turret/syndicate',
	'/obj/machinery/porta_turret/ruin/ramzi': '/obj/machinery/porta_turret/syndicate',
	'/obj/machinery/porta_turret/ruin/warra': ('/obj/machinery/porta_turret/syndicate', {'faction': 'list("nanotrasenprivate")'}),
	'/obj/machinery/porta_turret/ruin/warra/light': ('/obj/machinery/porta_turret/syndicate', {'faction': 'list("nanotrasenprivate")'}),
	'/obj/machinery/porta_turret/ruin/warra/light/sniper': ('/obj/machinery/porta_turret/syndicate', {'faction': 'list("nanotrasenprivate")'}),
	'/obj/machinery/portable_atmospherics/canister/hydrogen': '/obj/machinery/portable_atmospherics/canister/nitrogen',
	'/obj/machinery/power/shieldwallgen/anchored': ('/obj/machinery/shieldwallgen', {'anchored': '1'}),
	'/obj/machinery/power/shieldwallgen/atmos': None,
	'/obj/machinery/power/shieldwallgen/atmos/strong/roundstart': None,
	'/obj/machinery/power/shuttle/engine/fire': None,
	'/obj/machinery/seed_extractor': '/obj/machinery/seed_extractor',
	'/obj/machinery/smartfridge/bloodbank/preloaded': '/obj/machinery/smartfridge/organ',
	'/obj/machinery/suit_storage_unit/inherit/locked': None,
	'/obj/machinery/telecomms/relay/preset/warra': None,
	'/obj/machinery/telecomms/server/presets/cybersun': None,
}.items():
	rep(p, n)
for side, pix in {'north': ('pixel_y', '28'), 'south': ('pixel_y', '-28'), 'east': ('pixel_x', '28'), 'west': ('pixel_x', '-28')}.items():
	rep('/obj/machinery/camera/autoname/directional/' + side, ('/obj/machinery/camera/autoname', {'dir': str({'north': 2, 'south': 1, 'east': 8, 'west': 4}[side])}))
	rep('/obj/machinery/newscaster/security_unit/directional/' + side, ('/obj/machinery/newscaster/security_unit', {pix[0]: pix[1]}))
DECISIONS['wodór (hydrogen_pump, kanister wodoru, podłoga wodorowa)'] = 'nie mamy wodoru: pompa pominięta, kanister -> azot'
DECISIONS['elektrolizer i jego rozładowarka (Moonbase)'] = 'puste ramy maszyn (rudy lodu i elektrolizera nie ma w tej partii)'
DECISIONS['tarcze atmosferyczne, silniki i grzejniki statków Shiptesta, przekaźniki telekomunikacji frakcji'] = 'pominięte'

# ---------------------------------------------------------------- struktury
for p, n in {
	'/obj/structure/aquarium/prefilled': '/obj/structure/aquarium',
	'/obj/structure/bed/bunk': '/obj/structure/bed',
	'/obj/structure/cabinet/fireaxe': '/obj/structure/fireaxecabinet',
	'/obj/structure/catwalk': '/obj/structure/lattice/catwalk',
	'/obj/structure/closet/crate/freezer/surplus_limbs/organs': '/obj/structure/closet/crate/freezer/surplus_limbs',
	'/obj/structure/closet/crate/rations': '/obj/structure/closet/crate/freezer',
	'/obj/structure/closet/crate/trashcart/laundry': '/obj/structure/closet/crate/trashcart',
	'/obj/structure/closet/mob_capture': '/obj/structure/closet/crate/critter',
	'/obj/structure/closet/secure_closet/cabinet': '/obj/structure/closet/cabinet',
	'/obj/structure/closet/toolcloset/empty': '/obj/structure/closet/toolcloset',
	'/obj/structure/crate_shelf/built': None,
	'/obj/structure/curtain/cloth/fancy': '/obj/structure/curtain',
	'/obj/structure/flora/ash/garden/seaweed': '/obj/structure/flora/ausbushes/reedbush',
	'/obj/structure/flora/grass/rockplanet/dead': '/obj/structure/flora/ausbushes/sparsegrass',
	'/obj/structure/flora/tree/cactus': '/obj/structure/flora/ash/cacti',
	'/obj/structure/fluff/beach_umbrella': None,
	'/obj/structure/fluff/hedge': '/obj/structure/flora/ausbushes/genericbush',
	'/obj/structure/frame/computer/retro': '/obj/structure/frame/computer',
	'/obj/structure/hazard/floor/burglar_alarm': None,
	'/obj/structure/holosign/barrier/engineering/infinite': '/obj/structure/holosign/barrier/engineering',
	'/obj/structure/platform/ship_four': None,
	'/obj/structure/platform/ship_three': None,
	'/obj/structure/platform/ship_three/corner': None,
	'/obj/structure/poddoor_assembly': None,
	'/obj/structure/railing/thick': '/obj/structure/railing',
	'/obj/structure/railing/thin': '/obj/structure/railing',
	'/obj/structure/railing/thin/corner': '/obj/structure/railing/corner',
	'/obj/structure/reagent_dispensers/foamtank/antirad': '/obj/structure/reagent_dispensers/foamtank',
	'/obj/structure/reagent_dispensers/servingdish': '/obj/structure/table',
	'/obj/structure/salvageable/autolathe': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/circuit_imprinter': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/destructive_analyzer': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/server': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/salvageable/server/safe': ('/obj/structure/frame/machine', {'anchored': '1'}),
	'/obj/structure/sign/flag/gezena': '/obj/structure/sign/flag',
	'/obj/structure/sign/number/random': None,
	'/obj/structure/sign/poster/contraband/aclf': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/poster/contraband/engis_unite': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/poster/contraband/eoehoma': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/poster/contraband/syndicate': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/poster/official/moth/boh': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/pgf/random': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/build': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/lasergun': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/random': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/science': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/rilena/tali': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/poster/syndicate/random': '/obj/structure/sign/poster/contraband/random',
	'/obj/structure/sign/warning/testchamber': '/obj/structure/sign/warning',
	'/obj/structure/sign/warra': None,
	'/obj/structure/spacevine/dense': None,
	'/obj/structure/table/rolling': '/obj/structure/table',
	'/obj/structure/transit_tube/station/dispenser': '/obj/structure/transit_tube/station',
	'/obj/structure/transit_tube/station/dispenser/flipped': '/obj/structure/transit_tube/station',
	'/obj/structure/vein/moon/classfour': '/obj/structure/vein/moon/classfour',
	'/obj/structure/window/plasma/reinforced/plastitanium/indestructible': ('/obj/structure/window/plastitanium', {'resistance_flags': '115'}),
}.items():
	rep(p, n)
DECISIONS['/obj/structure/spacevine/dense'] = 'pominięte: statyczne gęste pnącza (u nas kudzu się rozrasta)'
DECISIONS['/obj/structure/salvageable/*'] = 'wraki maszyn -> puste ramy (jak przy lawie)'
# fotele i kanapy
for col in ['beige', 'grey']:
	rep('/obj/structure/chair/comfy/%s/old/alt' % col, '/obj/structure/chair/fancy/comfy')
for side, d in {'east': '4', 'north': '1', 'south': '2', 'west': '8'}.items():
	for c in ['blue/corpo', 'orange', 'red']:
		rep('/obj/structure/chair/comfy/%s/directional/%s' % (c, side), ('/obj/structure/chair/fancy/comfy', {'dir': d} if d != '2' else {}))
SOFA = {
	'/obj/structure/chair/sofa/blue/corpo/corner/directional/east': ('/obj/structure/chair/fancy/sofa/corp/corner', '4'),
	'/obj/structure/chair/sofa/blue/corpo/directional/south': ('/obj/structure/chair/fancy/sofa/corp', '2'),
	'/obj/structure/chair/sofa/blue/corpo/left': ('/obj/structure/chair/fancy/sofa/corp/left', None),
	'/obj/structure/chair/sofa/blue/corpo/right/directional/east': ('/obj/structure/chair/fancy/sofa/corp/right', '4'),
	'/obj/structure/chair/sofa/grey/old': ('/obj/structure/chair/fancy/sofa/old', None),
	'/obj/structure/chair/sofa/grey/old/corner': ('/obj/structure/chair/fancy/sofa/old/corner', None),
	'/obj/structure/chair/sofa/grey/old/corner/directional/east': ('/obj/structure/chair/fancy/sofa/old/corner', '4'),
	'/obj/structure/chair/sofa/grey/old/directional': ('/obj/structure/chair/fancy/sofa/old', None),
	'/obj/structure/chair/sofa/grey/old/left': ('/obj/structure/chair/fancy/sofa/old/left', None),
	'/obj/structure/chair/sofa/grey/old/left/directional/south': ('/obj/structure/chair/fancy/sofa/old/left', '2'),
	'/obj/structure/chair/sofa/grey/old/right': ('/obj/structure/chair/fancy/sofa/old/right', None),
	'/obj/structure/chair/sofa/grey/old/right/directional/east': ('/obj/structure/chair/fancy/sofa/old/right', '4'),
	'/obj/structure/chair/sofa/red/old': ('/obj/structure/chair/fancy/sofa/old', None),
	'/obj/structure/chair/sofa/red/old/corner': ('/obj/structure/chair/fancy/sofa/old/corner', None),
	'/obj/structure/chair/sofa/red/old/left/directional/west': ('/obj/structure/chair/fancy/sofa/old/left', '8'),
	'/obj/structure/chair/sofa/red/old/right/directional/south': ('/obj/structure/chair/fancy/sofa/old/right', '2'),
}
for p, (n, d) in SOFA.items():
	rep(p, (n, {'dir': d}) if d and d != '2' else n)
rep('/obj/structure/closet/wall/orange/directional/north', '/obj/structure/closet')
rep('/obj/structure/dresser/wall/directional/east', '/obj/structure/dresser')

# ---------------------------------------------------------------- turfy (wspólne i księżycowe)
TURFS.update({
	'/turf/closed/indestructible/titanium/nodiagnonal': '/turf/closed/indestructible/riveted',
	'/turf/closed/mineral/random/desert': '/turf/closed/mineral/random/moon',
	'/turf/closed/mineral/random/moon': '/turf/closed/mineral/random/moon',
	'/turf/closed/mineral/random/moon/lit': '/turf/closed/mineral/random/moon',
	'/turf/closed/mineral/random/moon/safe': ('/turf/closed/mineral/random/moon', {'initial_gas_mix': BREATHABLE}),
	'/turf/open/floor/carpet/blue/airless': ('/turf/open/floor/carpet/blue', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/carpet/blue/plasma': ('/turf/open/floor/carpet/blue', {'initial_gas_mix': PLASMA_HALF}),
	'/turf/open/floor/carpet/nanoweave/beige': '/turf/open/floor/carpet',
	'/turf/open/floor/carpet/nanoweave/purple': '/turf/open/floor/carpet/purple',
	'/turf/open/floor/carpet/red_gold': '/turf/open/floor/carpet/red',
	'/turf/open/floor/concrete/pavement/airless': ('/turf/open/floor/concrete/pavement', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/concrete/reinforced': '/turf/open/floor/concrete',
	'/turf/open/floor/engine/hull/reinforced': ('/turf/open/floor/engine', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/engine/hull/reinforced/interior': '/turf/open/floor/engine',
	'/turf/open/floor/engine/hydrogen': ('/turf/open/floor/engine', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/hangar/plasteel/dark': '/turf/open/floor/plasteel/dark',
	'/turf/open/floor/plasteel/mono/airless': ('/turf/open/floor/monotile/steel', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/mono/dark/airless': ('/turf/open/floor/monotile/dark', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/mono/dark/plasma': ('/turf/open/floor/monotile/dark', {'initial_gas_mix': PLASMA_HALF}),
	'/turf/open/floor/plasteel/mono/white/plasma': ('/turf/open/floor/monotile/light', {'initial_gas_mix': PLASMA_HALF}),
	'/turf/open/floor/plasteel/patterned/grid': '/turf/open/floor/plasteel/tech/grid',
	'/turf/open/floor/plasteel/stairs/mid': '/turf/open/floor/plasteel/stairs',
	'/turf/open/floor/plasteel/tech/airless': ('/turf/open/floor/plasteel/tech', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/tech/grid/airless': ('/turf/open/floor/plasteel/tech/grid', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/tech/techmaint/airless': ('/turf/open/floor/plasteel/techmaint', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/telecomms_floor': '/turf/open/floor/circuit',
	'/turf/open/floor/plasteel/telecomms_floor/airless': ('/turf/open/floor/circuit', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/plasteel/white/plasma': ('/turf/open/floor/plasteel/white', {'initial_gas_mix': PLASMA_HALF}),
	'/turf/open/floor/plastic': '/turf/open/floor/plasteel/white',
	'/turf/open/floor/plating/asteroid/desert': '/turf/open/floor/plating/asteroid/moon_coarse',
	'/turf/open/floor/plating/asteroid/dirt/grass/jungle': '/turf/open/floor/grass',
	'/turf/open/floor/plating/asteroid/moon': '/turf/open/floor/plating/asteroid/moon',
	'/turf/open/floor/plating/asteroid/moon/lit': '/turf/open/floor/plating/asteroid/moon',
	'/turf/open/floor/plating/asteroid/moon/lit/surface_craters': '/turf/open/floor/plating/asteroid/moon/craters',
	'/turf/open/floor/plating/asteroid/moon/safe': ('/turf/open/floor/plating/asteroid/moon', {'initial_gas_mix': BREATHABLE, 'planetary_atmos': '0'}),
	'/turf/open/floor/plating/asteroid/moon_coarse': '/turf/open/floor/plating/asteroid/moon_coarse',
	'/turf/open/floor/plating/asteroid/moon_coarse/dark': '/turf/open/floor/plating/asteroid/moon_coarse/dark',
	'/turf/open/floor/plating/asteroid/moon_coarse/dark/lit': '/turf/open/floor/plating/asteroid/moon_coarse/dark',
	'/turf/open/floor/plating/asteroid/moon_coarse/lit': '/turf/open/floor/plating/asteroid/moon_coarse',
	'/turf/open/floor/plating/asteroid/moon_coarse/lit/surface_craters': '/turf/open/floor/plating/asteroid/moon_coarse/craters',
	'/turf/open/floor/plating/asteroid/smoothed': '/turf/open/floor/plating/asteroid',
	'/turf/open/floor/plating/asteroid/smoothed/airless': '/turf/open/floor/plating/asteroid/airless',
	'/turf/open/floor/plating/asteroid/snow/safe/noplanet': '/turf/open/floor/plating/asteroid/snow/atmosphere',
	'/turf/open/floor/plating/rust/airless': ('/turf/open/floor/plating/rust', {'initial_gas_mix': AIRLESS}),
	'/turf/open/floor/pod/rockplanet': '/turf/open/floor/pod',
	'/turf/open/floor/suns/dark/plain': '/turf/open/floor/pod/dark',
	'/turf/open/floor/suns/hatch/ebony': '/turf/open/floor/pod/dark',
	'/turf/open/floor/suns/hatch/maple': '/turf/open/floor/pod/light',
	'/turf/open/water/beach': '/turf/open/water/planet/beach',
	'/turf/open/water/beach/deep': '/turf/open/water/planet/beach/deep',
})
DECISIONS['/turf/open/floor/*/plasma'] = 'podłogi z plazmą w powietrzu -> nasza podłoga z mieszanką azot/plazma (jak ATMOS_TANK_PLASMAHALF)'
DECISIONS['/turf/open/floor/*/airless'] = 'podłogi bez powietrza -> nasza podłoga z initial_gas_mix próżni'

# ---------------------------------------------------------------- obszary ruin księżyca
# Na zewnątrz: powierzchnia planety (load_ruin przepina /area/lavaland/surface/outdoors na obszar planety)
for p in ['/area/overmap_encounter/planetoid/moon/explored', '/area/ruin/moon/bunker/exterior', '/area/ruin/moon/cybergrind/exterior',
		'/area/ruin/moon/hideout/exterior']:
	AREAS[p] = '/area/lavaland/surface/outdoors'
MOON_AREAS = [
	'bunker', 'bunker/armory', 'bunker/bathroom', 'bunker/cargo', 'bunker/dorms/lounge', 'bunker/dorms/one', 'bunker/dorms/two',
	'bunker/drone', 'bunker/engineering',
	'cybergrind/aicore', 'cybergrind/atrium', 'cybergrind/bathroom', 'cybergrind/cargo', 'cybergrind/centralhallway',
	'cybergrind/decontam', 'cybergrind/directors', 'cybergrind/dormitory', 'cybergrind/engineering', 'cybergrind/hangar',
	'cybergrind/lab', 'cybergrind/medbay', 'cybergrind/northhallway', 'cybergrind/observatory', 'cybergrind/reception',
	'cybergrind/secdorm', 'cybergrind/simdomeengi', 'cybergrind/terrarium', 'cybergrind/terrarium/simdome',
	'hideout', 'hideout/bathroom', 'hideout/bathroom/officer', 'hideout/canteen', 'hideout/command', 'hideout/dorms',
	'hideout/dorms/five', 'hideout/dorms/four', 'hideout/dorms/officer', 'hideout/dorms/officer/bedroom', 'hideout/dorms/one',
	'hideout/dorms/three', 'hideout/dorms/two', 'hideout/engineering', 'hideout/fortress',
	'moonbase/armory', 'moonbase/cargo', 'moonbase/dorms', 'moonbase/engineering', 'moonbase/refinery',
]
for sub in MOON_AREAS:
	AREAS['/area/ruin/moon/' + sub] = '/area/ruin/unpowered/planet_moon/' + sub

# ---------------------------------------------------------------- tłumaczenia (nazwy i opisy edytowane na mapach)
TR.update({
	"'EMERGENCY' safe": 'sejf „AWARYJNY”',
	'A board for mounting trophies or momentos on.': 'Tablica do wieszania trofeów i pamiątek.',
	'A huge chunk of metal holding the roof of the asteroid at bay': 'Ogromny kawał metalu, który podpiera strop asteroidy.',
	"A small bottle with the words 'CONTAGIOUS SAMPLE' written on it. Probably not the best idea to drink it.":
		'Mała butelka z napisem „PRÓBKA ZAKAŹNA”. Picie tego to raczej zły pomysł.',
	'AI Core Double-Lock Door': 'podwójnie ryglowane drzwi rdzenia SI',
	'AI Output Log Recording Device': 'rejestrator dziennika wyjścia SI',
	'Aide Dorm': 'Sypialnia asystenta',
	'Ammo crate': 'skrzynia z amunicją',
	"An advanced laser cannon, a laser etched inscription in the handle states 'MW-LS-1013'. The casing is made of a lightweight alloy.":
		'Zaawansowane działo laserowe. Na rękojeści wypalono laserem napis „MW-LS-1013”. Obudowa z lekkiego stopu.',
	'Armory': 'Zbrojownia',
	'Armory Office': 'Biuro zbrojowni',
	"Assistant Development Director's Dorm": 'Sypialnia zastępcy dyrektora rozwoju',
	'Atmospherics': 'Atmosferyka',
	'Base Accessway': 'Wejście do bazy',
	"Base Commander's closet": 'szafa komendanta bazy',
	'Bedroom': 'Sypialnia',
	'Blast Door Control': 'sterowanie drzwiami przeciwwybuchowymi',
	'Canteen': 'Stołówka',
	'Captured Vigilitas defense rover': 'przechwycony łazik obronny Vigilitas',
	'Cargo': 'Ładownia',
	'Cargo Access': 'Wejście do ładowni',
	'Cargo Bay': 'Ładownia',
	'Cargo Blast Doors': 'drzwi przeciwwybuchowe ładowni',
	'Cargo Windows': 'okna ładowni',
	'Checkpoint': 'Punkt kontrolny',
	'Checkpoint Security': 'Ochrona punktu kontrolnego',
	'Cold Storage': 'Chłodnia',
	'Command Dormitory': 'Sypialnia dowództwa',
	'Conveyor Shutters': 'rolety taśmociągu',
	'Crew Quarters': 'Kwatery załogi',
	"Development Director's Dorm": 'Sypialnia dyrektora rozwoju',
	"Director's Office": 'Gabinet dyrektora',
	"Director's Quarters": 'Kwatera dyrektora',
	'Directorate Dorms': 'Sypialnie dyrekcji',
	'Dormitory': 'Sypialnia',
	'Dormitory 1': 'Sypialnia 1',
	'Dormitory 2': 'Sypialnia 2',
	'EVA Storage': 'Magazyn EVA',
	'EVA crate': 'skrzynia EVA',
	'EVA shipment': 'dostawa sprzętu EVA',
	'Emergency Repressurization': 'awaryjne przywrócenie ciśnienia',
	'Engine Control': 'Sterowanie silnikiem',
	'Engineering Compartment': 'Przedział inżynieryjny',
	'Engineering Office': 'Biuro inżynierii',
	'Engineering Shutters': 'rolety inżynierii',
	'Exterior Access': 'Wyjście na zewnątrz',
	'Exterior Door Control': 'sterowanie drzwiami zewnętrznymi',
	'Firing Range': 'Strzelnica',
	'Foreman Bonsha': 'brygadzista Bonsha',
	'Fortress Entrance': 'Wejście do twierdzy',
	'Freezer': 'Zamrażarka',
	'Front Office': 'Recepcja',
	'Hallway': 'Korytarz',
	'Hangar': 'Hangar',
	'Hangar Control': 'Sterowanie hangarem',
	'Hardsuit Access': 'Dostęp do skafandrów',
	'High Energy Applications Research Facility': 'Ośrodek Badań nad Zastosowaniami Wysokich Energii',
	'Hydroponics': 'Hydroponika',
	'Infirmary': 'Izba chorych',
	'Interior Door Control': 'sterowanie drzwiami wewnętrznymi',
	'Interior Mine': 'mina wewnętrzna',
	'Kitchen Exit': 'Wyjście z kuchni',
	'Lab Access': 'Wejście do laboratorium',
	'Laundromat': 'Pralnia',
	'Laundry': 'Pralnia',
	'Living Quarters': 'Kwatery mieszkalne',
	'Lounge': 'Świetlica',
	'Manual Drone Release': 'ręczne wypuszczenie dronów',
	'Medical': 'Ambulatorium',
	'Medical Bay': 'Ambulatorium',
	'Mess': 'Mesa',
	'Mr. Duffel': 'Pan Worek',
	'Ms. Flat Top': 'Pani Płaska',
	'Office': 'Biuro',
	'Overwatch': 'Stanowisko obserwacyjne',
	'Power Control': 'Sterowanie zasilaniem',
	'Privacy Lock': 'blokada prywatności',
	'Private Quarters': 'Kwatera prywatna',
	'Prototype Storage': 'Magazyn prototypów',
	'Refinery Shutters': 'rolety rafinerii',
	'Refueling Shutters': 'rolety stacji paliw',
	'Reserve Dormitory': 'Sypialnia rezerwowa',
	'Secure Weapon Storage': 'Zabezpieczony magazyn broni',
	'Security Hall': 'Korytarz ochrony',
	'Server Room': 'Serwerownia',
	'Shutter Control': 'sterowanie roletami',
	'Sim Dome Airgap': 'Śluza kopuły symulacyjnej',
	'Sim-Dome Accessway': 'Wejście do kopuły symulacyjnej',
	'Staff Dorm': 'Sypialnia personelu',
	'Testing Chamber Control': 'Sterowanie komorą testową',
	'Testing Lab': 'Laboratorium testowe',
	'The Ion Projector is contained within a sleek metal case. Engraved on the handle are the letters S.H. The stock is warm to the touch':
		'Projektor jonowy w smukłej metalowej obudowie. Na rękojeści wygrawerowano litery S.H. Kolba jest ciepła w dotyku.',
	'To Distro': 'Do dystrybucji',
	'Toilet': 'Toaleta',
	'Troubleshooter Dorm': 'Sypialnia rozjemców',
	'Troubleshooter Wing': 'Skrzydło rozjemców',
	'Vault': 'Skarbiec',
	'Vault Access': 'Wejście do skarbca',
	'Window Control': 'sterowanie oknami',
	'armor closet': 'szafa z pancerzami',
	'armory access': 'wejście do zbrojowni',
	'atmos waste injector': 'wtryskiwacz odpadów atmosferycznych',
	'backup generator crate': 'skrzynia z zapasowym generatorem',
	'blank IPC shells': 'puste skorupy IPC',
	'bridge shutters': 'rolety mostka',
	'canteen window': 'okno stołówki',
	'cargo blasts': 'drzwi przeciwwybuchowe ładowni',
	'cargo lockdown button': 'przycisk blokady ładowni',
	'dead potted plant': 'uschnięta roślina doniczkowa',
	'drone release': 'wypuszczenie dronów',
	'emergency gear access': 'dostęp do sprzętu awaryjnego',
	'engine shutters': 'rolety silnika',
	'exterior shutters': 'rolety zewnętrzne',
	'gameboard': 'plansza do gry',
	'gear closet': 'szafa ze sprzętem',
	'input power monitoring console': 'konsola monitorowania zasilania wejściowego',
	'internals crate': 'skrzynia z butlami tlenowymi',
	'lockdown override (WARNING)': 'obejście blokady (UWAGA)',
	'mechbay shutters': 'rolety hangaru mechów',
	'outdated nuclear authentication disk': 'przestarzały dysk uwierzytelniający',
	'picnic stool': 'taboret piknikowy',
	'picnic table': 'stół piknikowy',
	'plasma canister': 'kanister plazmy',
	'privacy lock': 'blokada prywatności',
	"proper foreman's locker": 'porządna szafka brygadzisty',
	'regal bedsheet': 'królewskie prześcieradło',
	'scorched stone': 'osmalony kamień',
	'spare ammo crate': 'skrzynia z zapasową amunicją',
	'spare material': 'zapasowy materiał',
	'spent 10mm casing': 'zużyta łuska 10 mm',
	'surplus clothing crate': 'skrzynia z nadmiarowymi ubraniami',
	'the Meal': 'Posiłek',
	'tinkering chair': 'krzesło majsterkowicza',
	'turret release': 'zwolnienie wieżyczek',
	'window shutters': 'rolety okienne',
})

# ---------------------------------------------------------------- druga runda (ścieżki widoczne po pierwszej konwersji)
for p, n in {
	'/mob/living/basic/human/frontier/ranged/surgeon/internals/neutered': '/mob/living/basic/trooper/russian/ranged',
	'/mob/living/simple_animal/hostile/automated/walkmine': '/obj/effect/mine/explosive',
	'/obj/effect/mapping_helpers/crate_shelve': None,
	'/obj/effect/mob_spawn/human/corpse/cybersun/director': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/item/ammo_box/magazine/cs_gauss/rifle': '/obj/item/ammo_box/magazine/m556',
	'/obj/item/ammo_box/magazine/m10mm_cottonmouth': '/obj/item/ammo_box/magazine/m10mm',
	'/obj/item/ammo_box/magazine/m57_39_asp/empty': ('/obj/item/ammo_box/magazine/wt550m9', EMPTY),
	'/obj/item/ammo_box/magazine/m9mm_mauler/extended': '/obj/item/ammo_box/magazine/pistolm9mm',
	'/obj/item/clothing/head/clip': '/obj/item/clothing/head/beret',
	'/obj/item/clothing/head/gezena/flap/marine': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/hardhat/ramzi': '/obj/item/clothing/head/hardhat/red',
	'/obj/item/clothing/head/helmet/space/syndicate/engie': '/obj/item/clothing/head/helmet/space/syndicate',
	'/obj/item/clothing/head/helmet/syndie': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/ngr/flap': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/ramzi/peaked': '/obj/item/clothing/head/beret',
	'/obj/item/clothing/mask/gas/cybersun': '/obj/item/clothing/mask/gas/syndicate',
	'/obj/item/clothing/mask/gas/frontiersmen': '/obj/item/clothing/mask/gas',
	'/obj/item/clothing/suit/space/hardsuit/clip_patroller': '/obj/item/clothing/suit/space/hardsuit/engine',
	'/obj/item/clothing/under/cybersun/overalls': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/pants/cargo/black': '/obj/item/clothing/under/pants/black',
	'/obj/item/clothing/under/shorts/pink': '/obj/item/clothing/under/shorts/red',
	'/obj/item/coffee_cartridge/fancy/blend': '/obj/item/coffee_cartridge/fancy',
	'/obj/item/crowbar/power': '/obj/item/crowbar/red',
	'/obj/item/food/fara_reti': '/obj/item/food/donkpocket',
	'/obj/item/gun/energy/cybersun/troubleshooter/empty_cell': '/obj/item/gun/energy/laser/retro',
	'/obj/item/melee/energy/flyssa': '/obj/item/melee/transforming/energy/sword/saber',
	'/obj/item/mine/pressure/explosive': '/obj/effect/mine/explosive',
	'/obj/item/multitool/syndie': '/obj/item/multitool',
	'/obj/item/plasmacutter': '/obj/item/gun/energy/plasmacutter',
	'/obj/item/reagent_containers/condiment/tiris_milk': '/obj/item/reagent_containers/food/condiment/milk',
	'/obj/item/reagent_containers/glass/bottle/vial/small/preloaded/morphine': '/obj/item/reagent_containers/glass/bottle/morphine',
	'/obj/item/stack/packageWrap': '/obj/item/stack/package_wrap',
	'/obj/item/stock_parts/cell/gun/cybersun': '/obj/item/stock_parts/cell',
	'/obj/item/stock_parts/cell/gun/cybersun/mini/empty': '/obj/item/stock_parts/cell/empty',
	'/obj/item/storage/pill_bottle/finobranc': '/obj/item/storage/pill_bottle/stimulant',
	'/obj/item/storage/toolbox/ammo/a12g_slug': '/obj/item/storage/box/lethalshot',
	'/obj/item/storage/toolbox/ammo/c556': '/obj/item/storage/toolbox/ammo',
	'/obj/item/storage/toolbox/ammo/c57': '/obj/item/storage/toolbox/ammo',
	'/obj/item/storage/toolbox/ammo/c9mm': '/obj/item/ammo_box/c9mm',
	'/obj/item/weldingtool/electric': '/obj/item/weldingtool/largetank',
	'/obj/machinery/computer/security/telescreen/entertainment/beige': '/obj/machinery/computer/security/telescreen/entertainment',
	'/obj/machinery/porta_turret/ruin/cybersun/heavy': '/obj/machinery/porta_turret/syndicate',
	'/obj/machinery/porta_turret/ruin/cybersun/seeker': '/obj/machinery/porta_turret/syndicate',
	'/obj/structure/platform/ship_two': None,
	'/obj/structure/platform/ship_two/corner': None,
	'/obj/structure/sign/poster/rilena/random': '/obj/structure/sign/poster/contraband/random',
}.items():
	rep(p, n)
rep('/obj/structure/chair/sofa/red/corpo/left/directional/north', ('/obj/structure/chair/fancy/sofa/corp/left', {'dir': '1'}))
rep('/obj/structure/chair/sofa/red/corpo/right/directional/north', ('/obj/structure/chair/fancy/sofa/corp/right', {'dir': '1'}))
EXTRA_DECALS['/obj/effect/turf_decal/siding/wood/end/mahogany'] = '/obj/effect/turf_decal/siding/wood/end'
EXTRA_DECALS_COLORED.update({
	'/obj/effect/turf_decal/trimline/opaque/syndiered': ('/obj/effect/turf_decal/trimline/red/line', '"#730622"', '255'),
})
DECISIONS['/mob/living/simple_animal/hostile/automated/walkmine'] = 'chodząca mina -> zwykła uzbrojona mina'
TURFS.update({
	'/turf/open/floor/plating/asteroid/sand': '/turf/open/floor/plating/beach/sand',
	'/turf/open/floor/suns/hatch/bamboo': '/turf/open/floor/pod/light',
	'/turf/open/floor/suns/hatch/mahogany': '/turf/open/floor/pod/dark',
	'/turf/open/floor/suns/hatch/walnut': '/turf/open/floor/pod/dark',
	'/turf/open/water/ngr_outpost/underground': '/turf/open/water/planet/beach/underground',
})
TR.update({
	'A box for storing blank IPC shells.': 'Skrzynia na puste skorupy IPC.',
	'A scouting drone manufactured by Sharplite during the Inter-Corporate War. Commonly fielded in small forward groups ahead of Vigilitas teams, or placed in security checkpoints. This one seems to have been reappropriated for other means':
		'Dron zwiadowczy Sharplite z czasów wojny korporacyjnej. Zwykle wysyłany w małych grupach przed oddziałami Vigilitas albo stawiany w punktach kontrolnych. Ten najwyraźniej przerobiono do innych celów.',
	'Cargo Shutters': 'rolety ładowni',
	'Dorms Shutters': 'rolety sypialni',
	"Lieutenant's Closet": 'szafa porucznika',
	"Stores and Records the Petabytes of information from an AI's central processor, and stores it for analysis should it be required..":
		'Zapisuje i przechowuje petabajty danych z procesora centralnego SI do analizy, gdyby była potrzebna.',
	'cybersun jorts': 'dżinsowe szorty Cybersun',
	'emergency eyewash station': 'awaryjna stacja przemywania oczu',
})

# ---------------------------------------------------------------- trzecia runda
for p, n in {
	'/obj/item/ammo_casing/shotgun/blank': '/obj/item/ammo_casing/spent',
	'/obj/item/clothing/neck/cloak/gezena': '/obj/item/clothing/neck/cloak',
	'/obj/item/clothing/neck/shemagh/ngr': '/obj/item/clothing/mask/bandana/red',
	'/obj/item/clothing/suit/armor/cybersun': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/armor/ramzi/captain': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/clothing/suit/ramzi': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/under/cybersun': '/obj/item/clothing/under/syndicate',
	'/obj/item/food/eggrolls': '/obj/item/food/donkpocket',
	'/obj/item/food/grown/refa_li': '/obj/item/food/grown/apple',
	'/obj/item/grenade/lorentz': '/obj/item/grenade/empgrenade',
	'/obj/item/reagent_containers/glass/bottle/vial/tiny/preloaded/ysiltane': '/obj/item/reagent_containers/glass/bottle/epinephrine',
	'/obj/item/storage/belt/military/cybersun': '/obj/item/storage/belt/military',
}.items():
	rep(p, n)
TURFS['/turf/open/floor/plasteel/mono/white/beachplanet/lit'] = '/turf/open/floor/monotile/light'
TR.update({
	'Armory Shutters': 'rolety zbrojowni',
	'Combat Aids': 'Środki bojowe',
	'Fire Safety Equipment': 'Sprzęt przeciwpożarowy',
	'Gear Closet': 'szafa ze sprzętem',
})

# ---------------------------------------------------------------- czwarta runda (pełny skan wszystkich atomów)
for p, n in {
	'/mob/living/basic/human/frontier/ranged/mosin/space': '/mob/living/basic/trooper/pirate/ranged/space',
	'/mob/living/basic/human/ramzi/melee/space/stormtrooper/sledge': '/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper',
	'/mob/living/simple_animal/pet/dog/pug': '/mob/living/basic/pet/dog/pug',
	'/obj/effect/mob_spawn/human/corpse/assistant/husked': '/obj/effect/mob_spawn/human/corpse/assistant',
	'/obj/effect/mob_spawn/human/corpse/damaged/whitesands': '/obj/effect/mob_spawn/human/corpse/damaged',
	'/obj/effect/mob_spawn/human/corpse/ramzi/space/soft': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
	'/obj/effect/spawner/random/trash': '/obj/effect/spawner/lootdrop/maintenance',
	'/obj/effect/spawner/random/trash/grime': '/obj/effect/decal/cleanable/dirt',
	'/obj/item/attachment/bayonet': '/obj/item/kitchen/knife/combat',
	'/obj/item/attachment/rail_light': '/obj/item/flashlight/seclite',
	'/obj/item/circuitboard/machine/shuttle/engine/fire': '/obj/item/circuitboard/machine/shuttle/engine',
	'/obj/item/clothing/gloves/gezena/engi': '/obj/item/clothing/gloves/color/yellow',
	'/obj/item/clothing/head/cybersun': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/gezena/flap': '/obj/item/clothing/head/soft/black',
	'/obj/item/clothing/head/helmet/gezena': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/helmet/m10/cybersun': '/obj/item/clothing/head/helmet',
	'/obj/item/clothing/head/helmet/m10/warra': '/obj/item/clothing/head/helmet/sec',
	'/obj/item/clothing/head/helmet/space/syndicate/ramzi': '/obj/item/clothing/head/helmet/space/syndicate/black/red',
	'/obj/item/clothing/head/warra/cap/security': '/obj/item/clothing/head/soft/sec',
	'/obj/item/clothing/mask/gas/vigilitas': '/obj/item/clothing/mask/gas',
	'/obj/item/clothing/shoes/combat/gezena': '/obj/item/clothing/shoes/combat',
	'/obj/item/clothing/shoes/combat/gezena/marine': '/obj/item/clothing/shoes/combat',
	'/obj/item/clothing/suit/armor/gezena/marine': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/armor/vest/cybersun': '/obj/item/clothing/suit/armor/vest',
	'/obj/item/clothing/suit/armor/warra/sec_director': '/obj/item/clothing/suit/armor/vest/alt',
	'/obj/item/clothing/suit/space/gezena': '/obj/item/clothing/suit/space',
	'/obj/item/clothing/under/cybersun/officer': '/obj/item/clothing/under/syndicate',
	'/obj/item/clothing/under/gezena': '/obj/item/clothing/under/syndicate/combat',
	'/obj/item/food/grown/dote_berries': '/obj/item/food/grown/berries',
	'/obj/item/food/grown/sososi': '/obj/item/food/grown/apple',
	'/obj/item/food/meat/slab/miras': '/obj/item/food/meat/slab/xeno',
	'/obj/item/food/remes_li': '/obj/item/food/donkpocket',
	'/obj/item/gun/ballistic/automatic/pistol/challenger': '/obj/item/gun/ballistic/automatic/pistol',
	'/obj/item/gun/energy/kalix/pistol/empty_cell': '/obj/item/gun/energy/e_gun/mini',
	'/obj/item/gun/energy/sharplite/surge': '/obj/item/gun/energy/ionrifle/carbine',
	'/obj/item/gun/energy/sharplite/surge/resistor': '/obj/item/gun/energy/ionrifle/carbine',
	'/obj/item/melee/energy/sword/saber/blue': '/obj/item/melee/transforming/energy/sword/saber',
	'/obj/item/paper/crumpled/fluff/fueling/command': '/obj/item/paper/crumpled',
	'/obj/item/pickaxe/drill/jackhammer/old': '/obj/item/pickaxe/drill/jackhammer',
	'/obj/item/radio/headset/alt': '/obj/item/radio/headset',
	'/obj/item/reagent_containers/food/drinks/soda_cans/sol_dry': '/obj/item/reagent_containers/food/drinks/soda_cans/cola',
	'/obj/item/reagent_containers/hypospray/medipen/bonefixingjuice': '/obj/item/reagent_containers/hypospray/medipen',
	'/obj/item/reagent_containers/hypospray/medipen/combat_drug': '/obj/item/reagent_containers/hypospray/medipen/stimulants',
	'/obj/item/reagent_containers/hypospray/medipen/cureall': '/obj/item/reagent_containers/hypospray/medipen/survival',
	'/obj/item/shovel/spoon': '/obj/item/shovel/spade',
	'/obj/item/stock_parts/cell/gun/sharplite/heavy': '/obj/item/stock_parts/cell/high',
	'/obj/item/stock_parts/cell/gun/sharplite/plus': '/obj/item/stock_parts/cell/high/plus',
	'/obj/item/storage/belt/sabre/pgf': '/obj/item/storage/belt/sabre',
	'/obj/item/storage/belt/security/webbing/ramzi': '/obj/item/storage/belt/security/webbing',
	'/obj/item/storage/box/ammo/a556_42': '/obj/item/ammo_box/magazine/m556',
	'/obj/item/storage/box/ammo/c215': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/ammo/c46x30mm': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/ammo/c57x39': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/box/ammo/c9mm_surplus': '/obj/item/ammo_box/c9mm',
	'/obj/item/storage/guncase/pistol/a357': '/obj/item/gun/ballistic/revolver',
	'/obj/machinery/porta_turret/ruin/ramzi/heavy': '/obj/machinery/porta_turret/syndicate',
	'/obj/machinery/porta_turret/ruin/warra/heavy': ('/obj/machinery/porta_turret/syndicate', {'faction': 'list("nanotrasenprivate")'}),
	'/obj/structure/barricade/directional/flippedtable/wood': '/obj/structure/barricade/wooden/crude',
	'/obj/structure/sign/poster/official/ion_carbine': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/official/mini_energy_gun': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/poster/retro/lasergun_new': '/obj/structure/sign/poster/official/random',
	'/obj/structure/sign/warra/vigilitas': None,
}.items():
	rep(p, n)
EXTRA_DECALS['/obj/effect/turf_decal/borderfloorwhite/corner'] = '/obj/effect/turf_decal/ship/borderfloor/corner'
TURFS['/turf/open/floor/vault/airless'] = ('/turf/open/floor/vault', {'initial_gas_mix': AIRLESS})
TR.update({
	'A dead potted plant.': 'Uschnięta roślina doniczkowa.',
	"A horrifically jittery mass of plasteel and flesh. Its motions are jumpy, and faint giggling can be heard through it's faceless visor.":
		'Przerażająco roztrzęsiona masa plastali i ciała. Porusza się skokami, a zza beztwarzowego wizjera dobiega cichy chichot.',
	'A playmat for the hit board game, Spacers and Stations .': 'Mata do przebojowej gry planszowej „Kosmonauci i Stacje”.',
	'A playmat for the hit boardgame, Spacers and Stations.': 'Mata do przebojowej gry planszowej „Kosmonauci i Stacje”.',
	'A scorched and blackened chunk of rock. Seems like rubbish.': 'Osmalony, poczerniały kawał skały. Wygląda na śmieć.',
	'Chemical Storage': 'Magazyn chemikaliów',
	'Command': 'Dowództwo',
	'Dorms': 'Sypialnie',
	'Energy PDW': 'energetyczna broń osobista',
	'MW-LS-1013': 'MW-LS-1013',
	'Security': 'Ochrona',
	"Security Director's Locker": 'szafka dyrektora ochrony',
	'Technologically enhanced for the optimal research position.': 'Ulepszony technologicznie dla optymalnej pozycji badawczej.',
	'To Environment': 'Do otoczenia',
	'blast door control': 'sterowanie drzwiami przeciwwybuchowymi',
	'contagion bottle': 'butelka z zarazkami',
	'conveyor shutters': 'rolety taśmociągu',
	"doctor's aid": 'pomoc lekarska',
	'hallway turret shutters': 'rolety wieżyczek korytarza',
	'improper Modified E-TAR SMG': 'zmodyfikowany pistolet maszynowy E-TAR',
	'interior shutters': 'rolety wewnętrzne',
	'ion projector': 'projektor jonowy',
	'privacy shutters': 'rolety prywatności',
	'structural support': 'podpora konstrukcyjna',
	'wall board': 'tablica ścienna',
})
TR.update({
	"Apply once to head to anethsitize patient. Apply twice if you don't like them.": 'Raz w głowę, by znieczulić pacjenta. Dwa razy, jeśli go nie lubisz.',
	'ladle': 'chochla',
	'old jackhammer': 'stary młot pneumatyczny',
	'science chair': 'krzesło naukowca',
})
TR.update({
	'One heaping of mystery slop, coming right up!': 'Jedna kopiasta porcja tajemniczej brei, już się robi!',
	"The old fashioned solution to a stubborn wall- used heavily all over known space until the onset of sonic deconstruction technology and Rapid Construction Devices. <i>Don't forget. -485 FS.</i> is carved into the side.":
		'Staromodny sposób na upartą ścianę, powszechny w całej znanej przestrzeni, zanim przyszły dźwiękowe rozbieraki i RCD. Na boku wyryto: <i>Nie zapomnij. -485 FS.</i>',
})

# ---------------------------------------------------------------- poprawki celów (typy, których u nas nie ma pod tą nazwą)
cm.OUR_COLOR['warrablue'] = 'blue'
for p, n in {
	'/obj/item/reagent_containers/food/drinks/mug/coco': '/obj/item/reagent_containers/food/drinks/mug/cocoa',
	'/obj/item/reagent_containers/food/drinks/waterbottle': '/obj/item/reagent_containers/glass/waterbottle',
	'/obj/item/reagent_containers/food/drinks/waterbottle/large/empty': '/obj/item/reagent_containers/glass/waterbottle/large/empty',
	'/obj/item/reagent_containers/syringe/contraband/morphine': '/obj/item/reagent_containers/syringe',
	'/obj/item/seeds/kudzu': '/obj/item/plant_seeds/preset/kudzu',
	'/obj/machinery/hydroponics/constructable': '/obj/item/plant_tray',
	'/obj/machinery/seed_extractor': '/obj/machinery/seeder',
	'/obj/machinery/plantgenes/seedvault': '/obj/machinery/seeder',
}.items():
	rep(p, n)
DECISIONS['tace hydroponiczne i ekstraktor nasion'] = 'nasza botanika: taca /obj/item/plant_tray i siewnik przemysłowy'

# ---------------------------------------------------------------- rury na warstwach 1 i 5
# Shiptest ma podtypy /layer1 i /layer5 rur i urządzeń; u nas są tylko /layer2 i /layer4, ale piping_layer 1-5 działa.
# Ścieżka bez końcówki + edycja piping_layer.
import re as _re

_original_convert_atom = cm.convert_atom


def _convert_atom(a, mapname, stat):
	path = a.split('{')[0]
	m = _re.match(r'(/obj/machinery/atmospherics/.+)/layer([15])$', path)
	if m:
		rest = a[len(path):]
		inner = rest.strip('{}')
		edits = 'piping_layer = ' + m.group(2) + ('; ' + inner if inner else '')
		return [m.group(1) + '{' + edits + '}']
	return _original_convert_atom(a, mapname, stat)


cm.convert_atom = _convert_atom
DECISIONS['/obj/machinery/atmospherics/*/layer1, /layer5'] = 'rury i urządzenia na skrajnych warstwach -> nasz typ z piping_layer 1 albo 5'


# Puste ramy maszyn (elektrolizer, wraki) nie mają zmiennych maszyn Shiptesta (input_dir, output_dir)
_convert_atom_layers = cm.convert_atom
_FRAME_DROP = _re.compile(r'\s*(input_dir|output_dir) = [^;}]*;?')


def _convert_atom_frames(a, mapname, stat):
	out = []
	for atom in _convert_atom_layers(a, mapname, stat):
		if atom.startswith('/obj/structure/frame') and '{' in atom:
			atom = _re.sub(r';\s*}', '}', _FRAME_DROP.sub('', atom))
			atom = atom.replace('{}', '').replace('{ ', '{').rstrip()
			if atom.endswith('{}'):
				atom = atom[:-2]
		out.append(atom)
	return out


cm.convert_atom = _convert_atom_frames

# Zmienne Shiptesta, których nasze typy nie mają (sprawdzone skryptem edycji zmiennych na mapach)
cm.DROP_VARS |= {'dry_fire_text', 'dx', 'dy'}
_FRAME_DROP = _re.compile(r'\s*(input_dir|output_dir|empty) = [^;}]*;?')
_convert_atom_frames2 = cm.convert_atom


def _convert_atom_turretid(a, mapname, stat):
	out = []
	for atom in _convert_atom_frames2(a, mapname, stat):
		if atom.startswith('/obj/machinery/turretid{'):
			atom = _re.sub(r';\s*}', '}', _re.sub(r'\s*\bid = [^;}]*;?', '', atom)).replace('{}', '')
		out.append(atom)
	return out


cm.convert_atom = _convert_atom_turretid
