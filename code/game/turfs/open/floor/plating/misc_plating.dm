
/turf/open/floor/plating/airless
	icon_state = "plating"
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/lavaland
	icon_state = "plating"
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/plating/abductor
	name = "obca podłoga"
	icon_state = "alienpod1"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"


/turf/open/floor/plating/abductor2
	name = "obce poszycie"
	icon_state = "alienplating"
	tiled_dirt = FALSE

/turf/open/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/open/floor/plating/abductor2/burn_tile()
	return //unburnable

/turf/open/floor/plating/abductor2/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet
	icon = 'icons/turf/mining.dmi'
	gender = PLURAL
	name = "popiół"
	icon_state = "ash"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	var/smooth_icon = 'icons/turf/floors/ash.dmi'
	desc = "Ziemię pokrywa wulkaniczny popiół."
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/plating/ashplanet/Initialize(mapload)
	if(smooth)
		var/matrix/M = new
		M.Translate(-4, -4)
		transform = M
		icon = smooth_icon
	. = ..()

/turf/open/floor/plating/ashplanet/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ashplanet/break_tile()
	return

/turf/open/floor/plating/ashplanet/burn_tile()
	return

/turf/open/floor/plating/ashplanet/ash
	canSmoothWith = list(/turf/open/floor/plating/ashplanet/ash, /turf/closed)
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/floor/plating/ashplanet/rocky
	gender = PLURAL
	name = "skaliste podłoże"
	icon_state = "rockyash"
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	layer = MID_TURF_LAYER
	canSmoothWith = list(/turf/open/floor/plating/ashplanet/rocky, /turf/closed)
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock
	gender = PLURAL
	name = "mokre skaliste podłoże"
	smooth = null
	icon_state = "wateryrock"
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ashplanet/wateryrock/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()


/turf/open/floor/plating/beach
	name = "plaża"
	icon = 'icons/misc/beach.dmi'
	flags_1 = NONE
	attachment_holes = FALSE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/beach/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/beach/ex_act(severity, target)
	contents_explosion(severity, target)

/turf/open/floor/plating/beach/sand
	gender = PLURAL
	name = "piasek"
	desc = "Fale w sam raz."
	icon_state = "sand"
	baseturfs = /turf/open/floor/plating/beach/sand

/turf/open/floor/plating/beach/coastline_t
	name = "linia brzegowa"
	desc = "Dziś wysoki przypływ. Naładuj pałki."
	icon_state = "sandwater_t"
	baseturfs = /turf/open/floor/plating/beach/coastline_t

/turf/open/floor/plating/beach/coastline_b
	name = "linia brzegowa"
	icon_state = "sandwater_b"
	baseturfs = /turf/open/floor/plating/beach/coastline_b

/turf/open/floor/plating/beach/water
	gender = PLURAL
	name = "woda"
	desc = "Masz wrażenie, że nikomu nie chciało się sprawić, żeby ta woda naprawdę działała..."
	icon_state = "water"
	baseturfs = /turf/open/floor/plating/beach/water

/turf/open/floor/plating/beach/coastline_t/sandwater_inner
	icon_state = "sandwater_inner"
	baseturfs = /turf/open/floor/plating/beach/coastline_t/sandwater_inner

/turf/open/floor/plating/ironsand
	gender = PLURAL
	name = "piasek żelazisty"
	desc = "Jak piasek, tylko bardziej <i>żelazny</i>."
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"

/turf/open/floor/plating/ironsand/burn_tile()
	return

/turf/open/floor/plating/ironsand/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice
	name = "tafla lodu"
	desc = "Tafla litego lodu. Wygląda na śliską."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "unsmooth"
	initial_gas_mix = FROZEN_ATMOS
	initial_temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/ice
	slowdown = 1
	attachment_holes = FALSE
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/plating/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/ice/smooth
	icon_state = "smooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/floor/plating/ice/smooth, /turf/open/floor/plating/ice, /turf/open/floor/plating/ice/colder)

/turf/open/floor/plating/ice/colder
	initial_temperature = 140

/turf/open/floor/plating/ice/temperate
	initial_temperature = 255.37

/turf/open/floor/plating/ice/break_tile()
	return

/turf/open/floor/plating/ice/burn_tile()
	return


/turf/open/floor/plating/snowed
	name = "zaśnieżone poszycie"
	desc = "Fragment podgrzewanego poszycia. Nie pozwala, by śnieg piętrzył się zbyt wysoko."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snowplating"
	initial_gas_mix = FROZEN_ATMOS
	initial_temperature = 180
	attachment_holes = FALSE
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/snowed/cavern
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"

/turf/open/floor/plating/snowed/smoothed
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/open/floor/plating/snowed/smoothed, /turf/open/floor/plating/snowed)
	planetary_atmos = TRUE
	icon = 'icons/turf/floors/snow_turf.dmi'
	icon_state = "smooth"

/turf/open/floor/plating/snowed/colder
	initial_temperature = 140

/turf/open/floor/plating/snowed/temperatre
	initial_temperature = 255.37

