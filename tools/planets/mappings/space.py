"""Obszary ruin kosmicznych Shiptesta (SpaceRuins) dla planety „słaby sygnał”. Przedmioty, maszyny i turfy wspólne
z ruinami księżyca są w moon.py (podawaj --mappings moon,space).
Na zewnątrz ruin (puste /area/ruin/space, skała asteroidy w /area/ruin/space/has_grav, /area/space/nearstation, panele
słoneczne bez APC) -> /area/space, które load_ruin przepina na obszar powierzchni planety.
"""
from mappings import moon  # noqa: F401 (wspólne zamienniki)
from mappings.common import AREAS

for p in ['/area/ruin/space', '/area/ruin/space/has_grav', '/area/space/nearstation', '/area/ruin/space/deepstorage',
		'/area/ruin/space/refuelingsolars', '/area/ruin/space/pgf_wreck/external']:
	AREAS[p] = '/area/space'

for sub in ['hivebotshuttle', 'shuttle1', 'shuttle2', 'shuttle3', 'pgf_wreck', 'pgf_wreck/bridge', 'pgf_wreck/cargo',
		'pgf_wreck/dorms', 'pgf_wreck/engineering']:
	AREAS['/area/ruin/space/' + sub] = '/area/ruin/space/planet_space/' + sub

for sub in ['deepstorage/bathroom', 'deepstorage/canteen', 'deepstorage/cargo', 'deepstorage/crewquarters', 'deepstorage/engineering',
		'deepstorage/hallway', 'deepstorage/hallway/east', 'deepstorage/hallway/upper', 'deepstorage/lobby', 'deepstorage/lobby/med',
		'deepstorage/med', 'deepstorage/overwatch', 'deepstorage/security', 'deepstorage/security/bedroom', 'deepstorage/security/lobby',
		'deepstorage/security/office', 'deepstorage/security/vault',
		'refuelingpost/armory', 'refuelingpost/bridge', 'refuelingpost/cargo', 'refuelingpost/cargobay', 'refuelingpost/dorms',
		'refuelingpost/engineering', 'refuelingpost/infirmary', 'refuelingpost/lower', 'refuelingpost/solarstorage',
		'refuelingpost/starboard', 'refuelingpost/upper',
		'singularitylab', 'singularitylab/cargo', 'singularitylab/civvie', 'singularitylab/engineering', 'singularitylab/hangar',
		'singularitylab/lab', 'singularitylab/reactor']:
	AREAS['/area/ruin/space/has_grav/' + sub] = '/area/ruin/space/has_grav/planet_space/' + sub

for sub in ['', '/armory', '/canteen', '/cargo', '/dorms', '/engi', '/foreman', '/hangar', '/med', '/solars', '/starboard',
		'/toilet', '/upper']:
	AREAS['/area/ruin/space/has_grav/powered/ramzi_station' + sub] = '/area/ruin/space/has_grav/powered/planet_space/ramzi_station' + sub
