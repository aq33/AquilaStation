// AQUILA - turfy planety wulkanicznej z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/game/turfs/open/floor/plating/lavaland.dm i planet.dm. Shiptest wygładza te turfy nowym bitmaskiem (sprite'y 70x70),
// u nas stary smoothing, więc to pojedyncze kafle 32x32 wycięte ze środka stanu "-255" z losowymi wariantami
// mechanizmem /turf/open/floor/plating/asteroid (floor_variance + environment_type). Warianty "/lit" pominięte:
// obszary planet mają stałe światło.

/// Wulkaniczny piasek (Shiptest: /turf/open/floor/plating/asteroid/purple)
/turf/open/floor/plating/asteroid/purple
	name = "wulkaniczny piasek"
	desc = "Piasek pełen minerałów wulkanicznych, które zabarwiły go na miękką czerń. Jak na takie warunki zaskakująco dobry dla roślin."
	icon = 'aquila/icons/planets/turf/volcanic_sand.dmi'
	icon_state = "sand"
	environment_type = "sand"
	floor_variance = 83
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE

/// Obsydian - zastygła magma, nie da się w nim kopać
/turf/open/floor/plating/asteroid/obsidian
	name = "obsydian"
	desc = "Zastygła magma tworzy ciemne, chłodne szkło."
	icon = 'aquila/icons/planets/turf/planet_floors.dmi'
	icon_state = "obsidian"
	floor_variance = 0
	dug = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	layer = MID_TURF_LAYER
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/// Ziemia (Shiptest: ogólny typ ziemi i trawy planet)
/turf/open/floor/plating/asteroid/dirt
	name = "ziemia"
	desc = "Jest dość brudna."
	icon = 'aquila/icons/planets/turf/planet_floors.dmi'
	icon_state = "dirt"
	floor_variance = 0
	dug = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/dirt

/turf/open/floor/plating/asteroid/dirt/burn_tile()
	ScrapeAway()
	return TRUE

/turf/open/floor/plating/asteroid/dirt/ex_act(severity, target)
	. = ..()
	ScrapeAway()

/turf/open/floor/plating/asteroid/dirt/grass
	name = "trawa"
	desc = "Kępa trawy."
	icon = 'aquila/icons/planets/turf/grass.dmi'
	icon_state = "grass"
	environment_type = "grass"
	floor_variance = 100
	planetary_atmos = TRUE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS

/// Szkarłatna trawa planet wulkanicznych
/turf/open/floor/plating/asteroid/dirt/grass/lavaland
	name = "szkarłatna trawa"
	desc = "Trawa pochodząca z Teceti. Świetnie przystosowała się do gorąca planet wulkanicznych, bo dobrze pochłania czerwone światło przenikające przez atmosferę."
	icon = 'aquila/icons/planets/turf/crimson_grass.dmi'
	baseturfs = /turf/open/floor/plating/asteroid/purple
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/// Mszysty dywan: sprite 50x50 przesunięty o -9 px nachodzi na sąsiednie kafle, dzięki czemu brzegi mchu są postrzępione bez smoothingu
/turf/open/floor/plating/moss
	name = "mszysty dywan"
	desc = "Gdy lasy spłonęły, a niebo pociemniało, mech nauczył się żywić opadającym popiołem."
	icon = 'aquila/icons/planets/turf/moss.dmi'
	icon_state = "moss"
	gender = PLURAL
	baseturfs = /turf/open/floor/plating/ashplanet/ash
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	attachment_holes = FALSE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	layer = HIGH_TURF_LAYER
	pixel_x = -9
	pixel_y = -9

// Mech nie ma stanów uszkodzeń poszycia: wybuch, uszkodzenie albo ogień zdzierają go do popiołu (w Shiptescie przez baseturfs)
/turf/open/floor/plating/moss/break_tile()
	ScrapeAway()

/turf/open/floor/plating/moss/burn_tile()
	ScrapeAway()
