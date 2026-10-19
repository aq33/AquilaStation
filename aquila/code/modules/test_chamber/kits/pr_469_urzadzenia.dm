/datum/test_chamber_kit/pr_469
	name = "Urządzenia z Paradise"
	pr = "aq33/AquilaStation#469"
	description = "Rząd ścian z urządzeniami naściennymi (czujnik powietrza, alarm pożarowy, gaśnica, włącznik światła, guzik) \
		i urządzenia na podłodze: automat, SMES, generator PACMAN, ładowarki, holopad, sleeper, went i scrubber. \
		Sprawdź, czy naścienne siedzą na ścianie, a nie w powietrzu, i czy animacje działają (włącz went i scrubber, otwórz automat)."
	items = list(
		/obj/machinery/vending/cola = 1,
		/obj/machinery/power/smes = 1,
		/obj/machinery/power/port_gen/pacman = 1,
		/obj/machinery/cell_charger = 1,
		/obj/machinery/recharger = 1,
		/obj/machinery/holopad = 1,
		/obj/machinery/sleeper = 1,
		/obj/machinery/atmospherics/components/unary/vent_pump/on = 1,
		/obj/machinery/atmospherics/components/unary/vent_scrubber/on = 1
	)

/datum/test_chamber_kit/pr_469/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Ściana dwa kafle nad środkiem, urządzenia naścienne na podłodze pod nią
	var/list/mounts = list(
		/obj/machinery/airalarm/directional/north,
		/obj/machinery/firealarm/directional/north,
		/obj/structure/extinguisher_cabinet/north,
		/obj/machinery/light_switch,
		/obj/machinery/button/door)
	for(var/i in 1 to length(mounts))
		var/turf/wall_spot = locate(center.x - 3 + i, center.y + 3, center.z)
		var/turf/floor_spot = locate(center.x - 3 + i, center.y + 2, center.z)
		if(!wall_spot || !floor_spot || !(wall_spot in turfs) || !(floor_spot in turfs))
			continue
		wall_spot.PlaceOnTop(/turf/closed/wall)
		var/mount_type = mounts[i]
		var/atom/movable/mount = new mount_type(floor_spot)
		if(!mount.pixel_y)
			mount.pixel_y = 24
