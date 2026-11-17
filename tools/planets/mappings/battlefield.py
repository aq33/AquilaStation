"""Zamienniki dla ruin pola bitwy: Shiptest nie ma własnych ruin pola bitwy, więc pole bitwy pożycza wojskowe ruiny
śmietniska (icwbase, smugglerbunker, yard). Ten moduł bierze wszystko z modułu waste i podmienia turfy wysypiska
(atmosfera wysypiska) na turfy pola bitwy (zwykłe powietrze) i obszary na osobne obszary pola bitwy.
Użycie: python tools/planets/convert_maps.py --mappings battlefield --out aquila/_maps/RandomRuins/PlanetBattlefield <mapy>
"""
from mappings import waste  # noqa: F401 (zamienniki ruin śmietniska)
from mappings.common import TURFS, AREAS

TURFS.update({
	'/turf/open/floor/plating/asteroid/wasteplanet': '/turf/open/floor/plating/asteroid/dirt/battlefield',
	'/turf/open/floor/plating/asteroid/wasteplanet/lit': '/turf/open/floor/plating/asteroid/dirt/battlefield',
	'/turf/open/floor/plating/wasteplanet': '/turf/open/floor/plating',
	'/turf/open/floor/plating/wasteplanet/lit': '/turf/open/floor/plating',
	'/turf/open/floor/plating/wasteplanet/rust': '/turf/open/floor/plating/rust',
	'/turf/open/floor/plating/wasteplanet/rust/lit': '/turf/open/floor/plating/rust',
	'/turf/open/floor/concrete/wasteplanet': '/turf/open/floor/concrete',
	'/turf/open/floor/concrete/pavement/wasteplanet': '/turf/open/floor/concrete/pavement',
	'/turf/open/floor/concrete/pavement/wasteplanet/lit': '/turf/open/floor/concrete/pavement',
	'/turf/open/floor/concrete/reinforced/wasteplanet': '/turf/open/floor/concrete/slab_4',
	'/turf/open/floor/concrete/reinforced/wasteplanet/lit': '/turf/open/floor/concrete/slab_4',
	'/turf/open/floor/plasteel/wasteplanet': '/turf/open/floor/plasteel',
	'/turf/open/floor/plasteel/dark/wasteplanet': '/turf/open/floor/plasteel/dark',
	'/turf/open/floor/plasteel/stairs/wasteplanet': '/turf/open/floor/plasteel/stairs',
	'/turf/open/floor/plasteel/stairs/wasteplanet/lit': '/turf/open/floor/plasteel/stairs',
	'/turf/open/floor/pod/wasteplanet': '/turf/open/floor/pod/dark',
	'/turf/open/floor/pod/wasteplanet/lit': '/turf/open/floor/pod/dark',
	'/turf/open/floor/engine/waste/lit': '/turf/open/floor/engine',
	'/turf/open/floor/engine/hull/reinforced/waste': '/turf/open/floor/engine',
	'/turf/open/floor/mineral/plastitanium/wasteplanet': '/turf/open/floor/mineral/plastitanium',
	'/turf/open/floor/mineral/plastitanium/red/wasteplanet': '/turf/open/floor/mineral/plastitanium/red',
	'/turf/open/water/tar/waste': '/turf/open/water/planet/battlefield',
	'/turf/open/water/tar/waste/lit': '/turf/open/water/planet/battlefield',
	'/turf/closed/mineral/random/wasteplanet': '/turf/closed/mineral/random/jungle/battlefield',
	'/turf/closed/wall/wasteplanet': '/turf/closed/wall',
	'/turf/closed/wall/rust/wasteplanet': '/turf/closed/wall/rust',
	'/turf/closed/wall/r_wall/wasteplanet': '/turf/closed/wall/r_wall',
	'/turf/closed/wall/r_wall/rust/wasteplanet': '/turf/closed/wall/r_wall/rust',
	'/turf/closed/wall/concrete/wasteplanet': '/turf/closed/wall',
	'/turf/closed/wall/concrete/reinforced/wasteplanet': '/turf/closed/wall/r_wall',
})

for source, target in list(AREAS.items()):
	if target.startswith('/area/ruin/unpowered/planet_waste'):
		AREAS[source] = target.replace('/planet_waste', '/planet_battlefield', 1)
AREAS['/area/overmap_encounter/planetoid/wasteplanet'] = '/area/lavaland/surface/outdoors'
AREAS['/area/overmap_encounter/planetoid/wasteplanet/explored'] = '/area/lavaland/surface/outdoors'
