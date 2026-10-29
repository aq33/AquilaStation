/turf/open/floor/holofloor
	icon_state = "floor"
	holodeck_compatible = TRUE
	thermal_conductivity = 0
	flags_1 = NONE
	var/direction = SOUTH

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open/floor/holofloor/plating
	name = "podłoga z projektorem holodeku"
	icon_state = "engine"

/turf/open/floor/holofloor/chapel
	name = "podłoga kaplicy"
	icon_state = "chapel"

/turf/open/floor/holofloor/chapel/bottom_left
	direction = WEST

/turf/open/floor/holofloor/chapel/top_right
	direction = EAST

/turf/open/floor/holofloor/chapel/bottom_right

/turf/open/floor/holofloor/chapel/top_left
	direction = NORTH

/turf/open/floor/holofloor/chapel/Initialize(mapload)
	. = ..()
	if (direction != SOUTH)
		setDir(direction)

/turf/open/floor/holofloor/white
	name = "biała podłoga"
	icon_state = "white"

/turf/open/floor/holofloor/plating/burnmix
	name = "podłoga z mieszanką palną"
	initial_gas_mix = BURNMIX_ATMOS

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "bujna trawa"
	icon_state = "grass"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach
	gender = PLURAL
	name = "piasek"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach/coast_t
	gender = NEUTER
	name = "linia brzegowa"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	gender = NEUTER
	name = "linia brzegowa"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "woda"
	icon_state = "water"
	bullet_sizzle = TRUE

/turf/open/floor/holofloor/asteroid
	name = "asteroida"
	icon_state = "asteroid0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/asteroid/Initialize(mapload)
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open/floor/holofloor/basalt
	gender = PLURAL
	name = "bazalt"
	icon_state = "basalt0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/holofloor/space
	name = "\proper kosmos"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"

/turf/open/floor/holofloor/space/Initialize(mapload)
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/open/floor/holofloor/hyperspace
	name = "\proper nadprzestrzeń"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/hyperspace/Initialize(mapload)
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open/floor/holofloor/hyperspace/ns/Initialize(mapload)
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "dywan"
	desc = "Elektryzująco zachęcający."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 1)

/turf/open/floor/holofloor/carpet/update_icon()
	. = ..()
	if(intact)
		queue_smooth(src)

/turf/open/floor/holofloor/wood
	icon_state = "wood"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow
	gender = PLURAL
	name = "śnieg"
	desc = "Wygląda na zimny."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open/floor/holofloor/asteroid
	gender = PLURAL
	name = "piasek asteroidy"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/dark
	icon_state = "darkfull"

/turf/open/floor/holofloor/clown
	icon_state = "bananium"

/turf/open/floor/holofloor/white
	name = "biała podłoga"
	desc = "Płytka w czysto białym kolorze."
	icon_state = "pure_white"

/turf/open/floor/holofloor/monotile/dark
	name = "ciemna holopłytka"
	desc = "Naprawdę duża holopłytka z ciemnej stali."
	icon_state = "monotile_dark"

/turf/open/floor/holofloor/monotile/steel
	name = "stalowa holopłytka"
	desc = "Naprawdę duża stalowa holopłytka."
	icon_state = "steel_monotile"

/turf/open/floor/holofloor/monotile/light
	name = "jasna holopłytka"
	desc = "Naprawdę duża holopłytka z jasnej stali."
	icon_state = "monotile_light"
