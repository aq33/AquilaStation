/// AQUILA - sensory okrętu gracza z konsolą sensorów (aquila/code/modules/overmap/player_sensors.dm):
/// bez konsoli zostaje stary zasięg, z konsolą okręt widzi przez kamerę, teleskop i podczerwień,
/// teleskopem steruje operator, a raport sensorów mówi, czym widać kontakt i czemu nie.
/datum/unit_test/aquila_player_sensors
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/enemy
	var/obj/machinery/computer/ship/dradis/sensors/station

/datum/unit_test/aquila_player_sensors/Run()
	var/was_player = GLOB.player_sensor_suites_enabled
	var/was_suites = GLOB.ai_sensor_suites_enabled
	var/was_cones = GLOB.ai_sensor_cones_enabled
	GLOB.player_sensor_suites_enabled = TRUE
	GLOB.ai_sensor_suites_enabled = TRUE
	GLOB.ai_sensor_cones_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.mass = MASS_MEDIUM // myśliwiec nie ma teleskopu, okręt tak
	ship.ai_controlled = FALSE
	enemy.faction = "syndicate"
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(100, 60, z))
	enemy.forceMove(locate(113, 60, z)) // 13 pól na wschód
	ship.angle = 0
	var/was_signatures = GLOB.sensor_signature_enabled
	GLOB.sensor_signature_enabled = TRUE
	var/fail = check_console() || check_range_mult() || check_telescope() || check_report() || check_radar_beam() || check_faint()
	GLOB.sensor_signature_enabled = was_signatures
	ship.designated_targets = null
	ship.last_radar_pulse = 0
	GLOB.player_sensor_suites_enabled = was_player
	GLOB.ai_sensor_suites_enabled = was_suites
	GLOB.ai_sensor_cones_enabled = was_cones
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_player_sensors/proc/check_console()
	if(ship.uses_sensor_suites())
		return "Okręt gracza bez konsoli sensorów wykrywał przez zestawy sensorów"
	station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	station.forceMove(ship)
	station.linked = ship
	station.set_position(ship)
	if(!ship.uses_sensor_suites())
		return "Okręt gracza z konsolą sensorów nie wykrywał przez zestawy sensorów"
	GLOB.player_sensor_suites_enabled = FALSE
	var/off = ship.uses_sensor_suites()
	GLOB.player_sensor_suites_enabled = TRUE
	if(off)
		return "Wyłączony przełącznik admina nie wyłączył sensorów gracza"

/datum/unit_test/aquila_player_sensors/proc/check_range_mult()
	ship.ai_controlled = TRUE
	var/ai_range = ship.get_suite_range(SENSOR_OPTICAL, enemy)
	ship.ai_controlled = FALSE
	var/player_range = ship.get_suite_range(SENSOR_OPTICAL, enemy)
	if(abs(player_range - ai_range * 1.2) > 0.01)
		return "Kamera gracza nie sięga 1,2 raza dalej niż AI ([player_range] wobec [ai_range])"

/datum/unit_test/aquila_player_sensors/proc/check_telescope()
	ship.telescope_mode = "kurs"
	if(ship.get_telescope_bearing() != ship.angle)
		return "Teleskop w trybie kursu nie patrzył wzdłuż kursu"
	ship.telescope_mode = "recznie"
	ship.telescope_manual_bearing = 123
	if(ship.get_telescope_bearing() != 123)
		return "Teleskop w trybie ręcznym nie patrzył tam, gdzie ustawił operator"
	ship.telescope_mode = "cel"
	if(ship.get_telescope_bearing() != ship.angle)
		return "Teleskop bez celu nie patrzył wzdłuż kursu"
	LAZYSET(ship.designated_targets, enemy, "primary")
	var/to_enemy = overmap_angle(ship, enemy)
	if(abs(ship.get_telescope_bearing() - to_enemy) > 1)
		return "Teleskop w trybie celu nie śledził celu głównego (namiar [ship.get_telescope_bearing()], cel [to_enemy])"

/// Raport sensorów: state dla danego zestawu
/datum/unit_test/aquila_player_sensors/proc/state_of(suite)
	for(var/list/report as anything in ship.get_suite_report(enemy))
		if(report["suite"] == suite)
			return report["state"]

/datum/unit_test/aquila_player_sensors/proc/check_report()
	// Zimny myśliwiec 13 pól dalej: kamera go nie sięga, teleskop wycelowany w niego tak
	enemy.thrust_heat = 0
	enemy.inertial_dampeners = FALSE
	ship.thrust_heat = 0
	if(state_of(SENSOR_OPTICAL) != "far")
		return "Kamera sięgała zimnego myśliwca z 13 pól (stan [state_of(SENSOR_OPTICAL)])"
	if(state_of(SENSOR_TELESCOPE) != "sees")
		return "Teleskop wycelowany w cel go nie widział (stan [state_of(SENSOR_TELESCOPE)])"
	if(enemy.get_detection_range(ship) < 13)
		return "Okręt z teleskopem na celu nie wykrywał zimnego myśliwca z 13 pól ([enemy.get_detection_range(ship)])"
	ship.telescope_mode = "recznie"
	ship.telescope_manual_bearing = SIMPLIFY_DEGREES(overmap_angle(ship, enemy) + 90)
	if(state_of(SENSOR_TELESCOPE) != "cone")
		return "Teleskop odwrócony od celu nie zgłaszał „poza stożkiem” (stan [state_of(SENSOR_TELESCOPE)])"
	if(enemy.get_detection_range(ship) >= 13)
		return "Okręt wykrywał zimnego myśliwca z 13 pól bez teleskopu ([enemy.get_detection_range(ship)])"
	// Gorący cel prosto za rufą, a własny napęd pracuje: podczerwień oślepiona
	enemy.thrust_heat = 1
	ship.thrust_heat = 1
	ship.angle = SIMPLIFY_DEGREES(overmap_angle(ship, enemy) + 180)
	if(state_of(SENSOR_INFRARED) != "blind")
		return "Podczerwień nie była ślepa na cel za rufą przy pracującym napędzie (stan [state_of(SENSOR_INFRARED)])"
	ship.thrust_heat = 0
	if(state_of(SENSOR_INFRARED) != "sees")
		return "Podczerwień nie widziała gorącego celu przy wyłączonym napędzie (stan [state_of(SENSOR_INFRARED)])"
	if(state_of(SENSOR_LIDAR) != "off")
		return "Radar bez impulsu nie był wyłączony (stan [state_of(SENSOR_LIDAR)])"
	ship.angle = 0
	enemy.thrust_heat = 0

/// Radar kierunkowy: wiązka sięga dalej niż impuls dookólny, widzi tylko w swoim wycinku i tylko tam ją słychać
/datum/unit_test/aquila_player_sensors/proc/check_radar_beam()
	var/to_enemy = overmap_angle(ship, enemy)
	if(ship.get_radar_reach(0) != 100)
		return "Impuls dookólny gracza nie sięgał 100 pól ([ship.get_radar_reach(0)])"
	if(ship.get_radar_reach(60) <= ship.get_radar_reach(0))
		return "Wiązka 60° nie sięgała dalej niż impuls dookólny ([ship.get_radar_reach(60)])"
	ship.last_radar_pulse = world.time
	ship.radar_pulse_width = 60
	ship.radar_pulse_bearing = to_enemy
	if(ship.get_player_lidar_range(enemy) != ship.get_radar_reach(60))
		return "Cel w wiązce nie był widoczny na pełny zasięg wiązki ([ship.get_player_lidar_range(enemy)])"
	ship.radar_pulse_bearing = SIMPLIFY_DEGREES(to_enemy + 90)
	if(ship.get_player_lidar_range(enemy))
		return "Wiązka radaru widziała cel 90° obok swojego kierunku"
	LAZYREMOVE(enemy.radar_emissions, ship)
	ship.broadcast_radar_emission(300, ship.radar_pulse_bearing, 30)
	if(LAZYACCESS(enemy.radar_emissions, ship))
		return "Okręt poza wiązką usłyszał impuls kierunkowy"
	ship.broadcast_radar_emission(300, to_enemy, 30)
	if(!LAZYACCESS(enemy.radar_emissions, ship))
		return "Okręt w wiązce nie usłyszał impulsu kierunkowego"
	LAZYREMOVE(enemy.radar_emissions, ship)
	ship.radar_pulse_width = 0
	if(ship.get_player_lidar_range(enemy) != 100)
		return "Impuls dookólny nie widział celu 13 pól obok"
	ship.last_radar_pulse = 0
	if(ship.get_player_lidar_range(enemy))
		return "Radar widział cel bez impulsu"

/// Słaby sygnał: kontakt trochę poza zasięgiem wykrycia widać jako niepewny, ale nie da się go namierzyć
/datum/unit_test/aquila_player_sensors/proc/check_faint()
	enemy.thrust_heat = 0
	enemy.inertial_dampeners = FALSE
	ship.telescope_mode = "kurs"
	ship.angle = SIMPLIFY_DEGREES(overmap_angle(ship, enemy) + 180) // teleskop patrzy w drugą stronę
	var/range = enemy.get_detection_range(ship)
	var/dist = overmap_dist(ship, enemy)
	if(dist <= range || dist > range * 1.6)
		return "Ustawienie testu słabego sygnału nie wyszło (odległość [dist], zasięg [range])"
	var/visible = enemy.is_sensor_visible(ship)
	ship.angle = 0
	if(visible != SENSOR_VISIBILITY_FAINT)
		return "Kontakt tuż poza zasięgiem wykrycia nie był słabym sygnałem (widoczność [visible])"
	if(visible >= SENSOR_VISIBILITY_TARGETABLE)
		return "Słaby sygnał dało się namierzyć"
