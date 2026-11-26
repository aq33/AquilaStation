/// AQUILA - konsola taktyczna z ekranem kontroli ognia i DRADIS w wersji podstawowej (aquila/code/modules/overmap/fire_control.dm):
/// strzelec widzi kontakty i pancerz śledzonego celu, a DRADIS mostka na okręcie ze stanowiskiem rozpoznania
/// widzi tylko podstawowym radarem (bez teleskopu).
/datum/unit_test/aquila_fire_control
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/enemy

/datum/unit_test/aquila_fire_control/Run()
	var/was_player = GLOB.player_sensor_suites_enabled
	var/was_suites = GLOB.ai_sensor_suites_enabled
	var/was_cones = GLOB.ai_sensor_cones_enabled
	var/was_signatures = GLOB.sensor_signature_enabled
	GLOB.player_sensor_suites_enabled = TRUE
	GLOB.ai_sensor_suites_enabled = TRUE
	GLOB.ai_sensor_cones_enabled = TRUE
	GLOB.sensor_signature_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.mass = MASS_MEDIUM
	ship.ai_controlled = FALSE
	enemy.faction = "syndicate"
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(100, 60, z))
	enemy.forceMove(locate(113, 60, z))
	var/obj/machinery/computer/ship/dradis/sensors/station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	station.forceMove(ship)
	station.linked = ship
	station.set_position(ship)
	var/fail = check_armour() || check_basic_dradis()
	ship.designated_targets = null
	ship.sensor_view_basic = FALSE
	GLOB.player_sensor_suites_enabled = was_player
	GLOB.ai_sensor_suites_enabled = was_suites
	GLOB.ai_sensor_cones_enabled = was_cones
	GLOB.sensor_signature_enabled = was_signatures
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_fire_control/proc/check_armour()
	var/list/report = enemy.get_armour_report()
	if(length(report) != 5)
		return "Raport pancerza nie miał czterech ćwiartek i kadłuba ([json_encode(report)])"
	enemy.obj_integrity = enemy.max_integrity / 2
	report = enemy.get_armour_report()
	enemy.obj_integrity = enemy.max_integrity
	if(report[5] != 50)
		return "Kadłub w połowie nie dał 50% w raporcie pancerza (dał [report[5]])"

/datum/unit_test/aquila_fire_control/proc/check_basic_dradis()
	// Zimny myśliwiec 13 pól dalej w stożku teleskopu: stanowisko go widzi, podstawowy radar DRADIS nie sięga tak daleko
	enemy.thrust_heat = 0
	enemy.inertial_dampeners = FALSE
	ship.telescope_mode = "recznie"
	ship.telescope_manual_bearing = round(overmap_angle(ship, enemy))
	var/full = enemy.get_detection_range(ship)
	ship.sensor_view_basic = TRUE
	var/basic = enemy.get_detection_range(ship)
	ship.sensor_view_basic = FALSE
	if(full < 13)
		return "Okręt ze stanowiskiem rozpoznania nie widział celu w stożku teleskopu ([full] pól)"
	if(basic >= full)
		return "DRADIS w wersji podstawowej widział cel w stożku teleskopu tak daleko jak stanowisko rozpoznania ([basic] wobec [full] pól)"
	if(ship.get_contact_suite(enemy) != SENSOR_TELESCOPE)
		return "Obraz DRADIS nadpisał, czym stanowisko rozpoznania trzyma kontakt ([ship.get_contact_suite(enemy)])"

/// Strzelec widzi to samo co DRADIS: okręt na poziomie okrętu, którego nie ma w zawartości układu (np. prom antagów),
/// też jest na liście kontaktów kontroli ognia
/datum/unit_test/aquila_fire_control_contacts_off_system

/datum/unit_test/aquila_fire_control_contacts_off_system/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/other = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	other.abstract_move(locate(ship.x + 4, ship.y, ship.z)) // forceMove okrętu działa tylko na overmapie
	other.faction = ship.faction
	if(ship.current_system)
		return Fail("Okręt testowy należy do układu [ship.current_system]")
	for(var/list/contact as anything in ship.get_fire_control_contacts(50))
		if(contact["id"] == "\ref[other]")
			return
	return Fail("Okręt spoza zawartości układu nie trafił na listę kontaktów strzelca")
