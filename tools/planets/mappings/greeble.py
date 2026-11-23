"""Greeble ładują się na istniejący teren planety: każdy obszar z map greebli -> /area/template_noop (pola zostają
w obszarze powierzchni albo jaskini planety). Moduł czyta ścieżki .dmm z wiersza poleceń convert_maps.py."""
import re
import sys

from mappings.common import AREAS

for arg in sys.argv[1:]:
	source = arg.split('=', 1)[0]
	if not source.endswith('.dmm'):
		continue
	for area in set(re.findall(r'/area/[\w/]+', open(source, encoding='utf-8', errors='replace').read())):
		AREAS[area] = '/area/template_noop'
