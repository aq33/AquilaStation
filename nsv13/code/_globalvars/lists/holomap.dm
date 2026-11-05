/// A list of fire alarms on the station, separated by Z. Used cause there are a lot of fire alarms on any given station Z.
GLOBAL_LIST_EMPTY(station_fire_alarms)

GLOBAL_LIST_EMPTY(holomap_default_legend)

/// Used in generating area preview icons.
GLOBAL_LIST_INIT(holomap_color_to_name, list(
	HOLOMAP_AREACOLOR_COMMAND = "Dowództwo",
	HOLOMAP_AREACOLOR_SECURITY = "Ochrona",
	HOLOMAP_AREACOLOR_MEDICAL = "Medyczny",
	HOLOMAP_AREACOLOR_SCIENCE = "Nauka",
	HOLOMAP_AREACOLOR_ENGINEERING = "Inżynieria",
	HOLOMAP_AREACOLOR_CARGO = "Zaopatrzenie",
	HOLOMAP_AREACOLOR_HALLWAYS = "Korytarze",
	HOLOMAP_AREACOLOR_MAINTENANCE = "Techniczne",
	HOLOMAP_AREACOLOR_ARRIVALS = "Przyloty",
	HOLOMAP_AREACOLOR_ESCAPE = "Odloty",
	HOLOMAP_AREACOLOR_DORMS = "Rekreacja",
	HOLOMAP_AREACOLOR_SERVICE = "Serwis",
	HOLOMAP_AREACOLOR_MUNITION = "Amunicja",
	HOLOMAP_AREACOLOR_HANGAR = "Hangar",
))
