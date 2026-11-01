
// CENTCOM

// Side note, be sure to change the network_root_id of any areas that are not a part of centcom
// and just using the z space as safe harbor.  It shouldn't matter much as centcom z is isolated
// from everything anyway

/area/centcom
	name = "Centrala"
	icon_state = "centcom"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	flags_1 = NONE

/area/centcom/control
	name = "Doki Centrali"

/area/centcom/evac
	name = "Statek Ratunkowy Centrali"

/area/centcom/supply
	name = "Dok Promu Zaopatrzeniowego Centrali"

/area/centcom/ferry
	name = "Dok Promu Transportowego Centrali"

/area/centcom/prison
	name = "Więzienie Adminów"

/area/centcom/holding
	name = "Ośrodek Zatrzymań"

/area/centcom/supplypod/supplypod_temp_holding
	name = "Szlak Kapsuł Zaopatrzeniowych"
	icon_state = "supplypod_flight"

/area/centcom/supplypod
	name = "Ośrodek Kapsuł Zaopatrzeniowych"
	icon_state = "supplypod"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/centcom/supplypod/podStorage
	name = "Magazyn Kapsuł Zaopatrzeniowych"
	icon_state = "supplypod_holding"

/area/centcom/supplypod/loading
	name = "Załadownia Kapsuł Zaopatrzeniowych"
	icon_state = "supplypod_loading"
	var/loading_id = ""

/area/centcom/supplypod/loading/Initialize(mapload)
	. = ..()
	if(!loading_id)
		CRASH("[type] created without a loading_id")
	if(GLOB.supplypod_loading_bays[loading_id])
		CRASH("Duplicate loading bay area: [type] ([loading_id])")
	GLOB.supplypod_loading_bays[loading_id] = src

/area/centcom/supplypod/loading/one
	name = "Stanowisko nr 1"
	loading_id = "1"

/area/centcom/supplypod/loading/two
	name = "Stanowisko nr 2"
	loading_id = "2"

/area/centcom/supplypod/loading/three
	name = "Stanowisko nr 3"
	loading_id = "3"

/area/centcom/supplypod/loading/four
	name = "Stanowisko nr 4"
	loading_id = "4"

/area/centcom/supplypod/loading/ert
	name = "Stanowisko ERT"
	loading_id = "5"
//THUNDERDOME

/area/tdome
	name = "Thunderdome"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE

/area/tdome/arena
	name = "Arena Thunderdome"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/arena_source
	name = "Szablon Areny Thunderdome"
	icon_state = "thunder"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/area/tdome/tdome1
	name = "Thunderdome (Drużyna 1)"
	icon_state = "green"

/area/tdome/tdome2
	name = "Thunderdome (Drużyna 2)"
	icon_state = "green"

/area/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "thunder_admin"

/area/tdome/tdomeobserve
	name = "Thunderdome (Obserw.)"
	icon_state = "thunder_observe"


//ENEMY

//Wizard
/area/wizard_station
	name = "Kryjówka Czarodzieja"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	flags_1 = NONE
	network_root_id = "MAGIC_NET"

//Abductors
/area/abductor_ship
	name = "Statek Porywaczy"
	icon_state = "yellow"
	requires_power = FALSE
	teleport_restriction = TELEPORT_ALLOW_ABDUCTORS
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	network_root_id = "ALIENS"

//Syndicates
/area/syndicate_mothership
	name = "Statek-Matka Syndykatu"
	icon_state = "syndie-ship"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	flags_1 = NONE
	ambience_index = AMBIENCE_DANGER
	network_root_id = SYNDICATE_NETWORK_ROOT

/area/syndicate_mothership/control
	name = "Sterownia Syndykatu"
	icon_state = "syndie-control"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	network_root_id = SYNDICATE_NETWORK_ROOT

/area/syndicate_mothership/elite_squad
	name = "Elitarny Oddział Syndykatu"
	icon_state = "syndie-elite"
	network_root_id = SYNDICATE_NETWORK_ROOT

//CAPTURE THE FLAG

/area/ctf
	name = "Zdobądź Flagę"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/area/ctf/control_room
	name = "Sterownia A"

/area/ctf/control_room2
	name = "Sterownia B"

/area/ctf/central
	name = "Środek"

/area/ctf/main_hall
	name = "Główna Hala A"

/area/ctf/main_hall2
	name = "Główna Hala B"

/area/ctf/corridor
	name = "Korytarz A"

/area/ctf/corridor2
	name = "Korytarz B"

/area/ctf/flag_room
	name = "Pokój Flagi A"

/area/ctf/flag_room2
	name = "Pokój Flagi B"

// REEBE

/area/reebe
	name = "Reebe"
	icon_state = "yellow"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	teleport_restriction = TELEPORT_ALLOW_CLOCKWORK
	area_flags = VALID_TERRITORY | UNIQUE_AREA | HIDDEN_AREA
	ambience_index = AMBIENCE_REEBE

/area/reebe/city_of_cogs
	name = "Reebe – Miasto Trybów"
	icon_state = "purple"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | HIDDEN_AREA
	var/playing_ambience = FALSE
