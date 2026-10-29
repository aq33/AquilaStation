/turf/open/floor/goonplaque
	name = "tablica pamiątkowa"
	icon_state = "plaque"
	desc = "„Tablica ku czci naszych towarzyszy ze Stacji G4407. Oby model TG4407 dorównał waszej sławie i fortunie”. Pod spodem ktoś wydrapał prymitywny rysunek meteoru i kosmonauty. Kosmonauta się śmieje. Meteor wybucha."
	floor_tile = /obj/item/stack/tile/plasteel
	tiled_dirt = FALSE

/turf/open/floor/goonplaque/fland
	name = "tablica pamiątkowa"
	icon_state = "plaque"
	desc = "„Ta tablica upamiętnia cały trud budowniczych tej stacji, ekspertów i doradców z ich działów oraz wielu wędrownych kosmonautów, którzy zadali sobie trud obchodzenia stacji i wykrywania anomalii znalezionych podczas jej budowy. To serdeczne podziękowanie od głównego twórcy tej stacji, który ma nadzieję, że przetrwa ona jak najdłużej”. Pod tekstem widzisz wygrawerowaną dziwną kulistą istotę ze śmigłem na głowie i uśmiechem na twarzy."
	floor_tile = /obj/item/stack/tile/plasteel
	tiled_dirt = FALSE

/turf/open/floor/vault
	icon_state = "rockvault"
	floor_tile = /obj/item/stack/tile/plasteel

//Circuit flooring, glows a little
/turf/open/floor/circuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	var/icon_normal = "bcircuit"
	light_color = LIGHT_COLOR_CYAN
	floor_tile = /obj/item/stack/tile/circuit
	var/on = TRUE

/turf/open/floor/circuit/Initialize(mapload)
	SSmapping.nuke_tiles += src
	update_icon()
	. = ..()

/turf/open/floor/circuit/Destroy()
	SSmapping.nuke_tiles -= src
	return ..()

/turf/open/floor/circuit/update_icon()
	if(on)
		if(LAZYLEN(SSmapping.nuke_threats))
			icon_state = "rcircuitanim"
			light_color = LIGHT_COLOR_FLARE
		else
			icon_state = icon_normal
			light_color = initial(light_color)
		set_light(1.4, 0.5)
	else
		icon_state = "[icon_normal]off"
		set_light(0)

/turf/open/floor/circuit/off
	icon_state = "bcircuitoff"
	on = FALSE

/turf/open/floor/circuit/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/telecomms/mainframe
	name = "podstawa komputera centralnego"

/turf/open/floor/circuit/telecomms/server
	name = "podstawa serwera"

/turf/open/floor/circuit/green
	icon_state = "gcircuit"
	icon_normal = "gcircuit"
	light_color = LIGHT_COLOR_GREEN
	floor_tile = /obj/item/stack/tile/circuit/green

/turf/open/floor/circuit/green/off
	icon_state = "gcircuitoff"
	on = FALSE

/turf/open/floor/circuit/green/anim
	icon_state = "gcircuitanim"
	icon_normal = "gcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/green/anim

/turf/open/floor/circuit/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/green/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/green/telecomms/mainframe
	name = "podstawa komputera centralnego"

/turf/open/floor/circuit/red
	icon_state = "rcircuit"
	icon_normal = "rcircuit"
	light_color = LIGHT_COLOR_FLARE
	floor_tile = /obj/item/stack/tile/circuit/red

/turf/open/floor/circuit/red/off
	icon_state = "rcircuitoff"
	on = FALSE

/turf/open/floor/circuit/red/anim
	icon_state = "rcircuitanim"
	icon_normal = "rcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/red/anim

/turf/open/floor/circuit/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/red/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/pod
	name = "podłoga kapsuły"
	icon_state = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/open/floor/pod/light
	icon_state = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/open/floor/pod/dark
	icon_state = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark


/turf/open/floor/noslip
	name = "podłoga antypoślizgowa"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/open/floor/noslip/standard
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_standard"
	floor_tile = /obj/item/stack/tile/noslip/standard
	broken_states = list("noslip-damaged1_standard","noslip-damaged2_standard","noslip-damaged3_standard")
	burnt_states = list("noslip-scorched1_standard","noslip-scorched2_standard")

/turf/open/floor/noslip/white
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_white"
	floor_tile = /obj/item/stack/tile/noslip/white
	broken_states = list("noslip-damaged1_white","noslip-damaged2_white","noslip-damaged3_white")
	burnt_states = list("noslip-scorched1_white","noslip-scorched2_white")

/turf/open/floor/noslip/blue
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_blue"
	floor_tile = /obj/item/stack/tile/noslip/blue
	broken_states = list("noslip-damaged1_blue","noslip-damaged2_blue","noslip-damaged3_blue")
	burnt_states = list("noslip-scorched1_blue","noslip-scorched2_blue")

/turf/open/floor/noslip/darkblue
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_darkblue"
	floor_tile = /obj/item/stack/tile/noslip/darkblue
	broken_states = list("noslip-damaged1_darkblue","noslip-damaged2_darkblue","noslip-damaged3_darkblue")
	burnt_states = list("noslip-scorched1_darkblue","noslip-scorched2_darkblue")

/turf/open/floor/noslip/dark
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_dark"
	floor_tile = /obj/item/stack/tile/noslip/dark
	broken_states = list("noslip-damaged1_dark","noslip-damaged2_dark","noslip-damaged3_dark")
	burnt_states = list("noslip-scorched1_dark","noslip-scorched2_dark")

/turf/open/floor/noslip/vaporwave
	name = "podłoga antypoślizgowa"
	icon_state = "noslip_pinkblack"
	floor_tile = /obj/item/stack/tile/noslip/vaporwave
	broken_states = list("noslip-damaged1_pinkblack","noslip-damaged2_pinkblack","noslip-damaged3_pinkblack")
	burnt_states = list("noslip-scorched1_pinkblack","noslip-scorched2_pinkblack")

/turf/open/floor/noslip/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/oldshuttle
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Dzięki serii mikroteleportacji te płytki pozwalają poruszać się z niesamowitą prędkością."
	floor_tile = /obj/item/stack/tile/bluespace


/turf/open/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Czas wokół tych płytek zdaje się płynąć bardzo powoli."
	floor_tile = /obj/item/stack/tile/sepia


/turf/open/floor/bronze
	name = "podłoga z brązu"
	desc = "Ciężkie płytki z brązu."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "clockwork_floor"
	floor_tile = /obj/item/stack/tile/bronze

/turf/open/floor/white
	name = "biała podłoga"
	desc = "Płytka w czysto białym kolorze."
	icon_state = "pure_white"

/turf/open/floor/black
	name = "czarna podłoga"
	icon_state = "black"
//NSV13 changed monotile floor tiles to durasteel
/turf/open/floor/monotile
	icon_state = "monotile"

/turf/open/floor/monotile/steel
	icon_state = "steel_monotile"
	floor_tile = /obj/item/stack/tile/durasteel/mono_steel

/turf/open/floor/monotile/dark
	icon_state = "monotile_dark"
	floor_tile = /obj/item/stack/tile/durasteel/mono_dark

/turf/open/floor/monotile/light
	icon_state = "monotile_light"
	floor_tile = /obj/item/stack/tile/durasteel/mono_light

/turf/open/floor/monofloor
	icon_state = "steel_monofloor"
	floor_tile = /obj/item/stack/tile/durasteel/monofloor
//NSV13 end
/turf/open/floor/monofloor/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/stone
	icon_state = "stone"

/turf/open/floor/plating/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_BROWN

/turf/open/floor/plating/rust/Initialize(mapload)
	. = ..()
	color = null

/turf/open/floor/plating/rust/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rust)
