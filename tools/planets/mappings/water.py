"""Ruiny plaży postawione na planecie wodnej (Shiptest nie ma tam ruin): te same zamienniki co beach.py, ale lodowata
atmosfera planety wodnej na wszystkich podłogach i osobne obszary (/area/ruin/unpowered/planet_water/...).
Użycie: --mappings water (moduł sam wczytuje beach)."""
from mappings import beach
from mappings.common import TURFS

beach.GAS = '"o2=22;n2=82;TEMP=255.37"'
beach.planet_turfs()
# piasek i trawa ruin mają tu atmosferę planety wodnej (turfy plaży domyślnie mają ciepłą)
for path in ['/turf/open/floor/plating/asteroid/sand', '/turf/open/floor/plating/asteroid/sand/lit',
		'/turf/open/floor/plating/asteroid/sand/dense', '/turf/open/floor/plating/asteroid/sand/dense/lit',
		'/turf/open/floor/plating/asteroid/dirt/beach', '/turf/open/floor/plating/asteroid/dirt/grass/beach']:
	target = TURFS[path]
	if isinstance(target, tuple):
		target = target[0]
	TURFS[path] = (target, {'initial_gas_mix': beach.GAS})
TURFS['/turf/open/floor/concrete/beachplanet/lit'] = ('/turf/open/floor/concrete', beach.planetary())
TURFS['/turf/open/floor/plasteel/mono/white/beachplanet/lit'] = ('/turf/open/floor/monotile/light', beach.planetary())
TURFS['/turf/open/water/beach'] = ('/turf/open/water/planet/beach', {'initial_gas_mix': beach.GAS})
TURFS['/turf/open/water/beach/deep'] = '/turf/open/water/planet/stormy'
beach.ruin_areas('planet_water')
