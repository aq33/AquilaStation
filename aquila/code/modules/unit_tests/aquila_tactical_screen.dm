/// AQUILA - ekran taktyczny (aquila/code/modules/overmap/tactical_screen.dm): każda konsola mostka otwiera to samo
/// okno, ale sensorami steruje tylko operator przy stanowisku rozpoznania, strzela tylko strzelec, a pilot przy
/// sterze ma impuls radaru. Konsola monitorowania uzbrojenia tylko pokazuje.
/datum/unit_test/aquila_tactical_screen

/datum/unit_test/aquila_tactical_screen/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	ship.ai_controlled = FALSE
	ship.dradis = null
	var/obj/machinery/computer/ship/dradis/sensors/station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	var/obj/machinery/computer/ship/tactical/tactical = allocate(/obj/machinery/computer/ship/tactical)
	var/obj/machinery/computer/ship/ordnance/ordnance = allocate(/obj/machinery/computer/ship/ordnance)
	for(var/obj/machinery/computer/ship/console as anything in list(station, tactical, ordnance))
		console.forceMove(ship)
		console.linked = ship
		console.set_position(ship)
		console.machine_stat = NONE
	var/turf/near = get_turf(station)
	var/mob/living/carbon/human/operator = allocate(/mob/living/carbon/human, near)
	var/mob/living/carbon/human/gunner = allocate(/mob/living/carbon/human, near)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, near)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human, locate(min(near.x + 6, world.maxx), near.y, near.z))
	ship.gunner = gunner
	ship.pilot = pilot
	if(!station.tactical_screen_ship() || !tactical.tactical_screen_ship() || !ordnance.tactical_screen_ship())
		return Fail("Konsole dużego okrętu nie otwierają ekranu taktycznego")

	var/datum/tactical_screen/sensor_screen = new(station)
	var/datum/tactical_screen/fire_screen = new(tactical)
	var/datum/tactical_screen/ordnance_screen = new(ordnance)
	var/fail = check_permissions(sensor_screen, operator, TRUE, FALSE, TRUE, "operator przy stanowisku") \
		|| check_permissions(sensor_screen, pilot, FALSE, FALSE, TRUE, "pilot przy sterze") \
		|| check_permissions(fire_screen, gunner, FALSE, TRUE, FALSE, "strzelec") \
		|| check_permissions(fire_screen, viewer, FALSE, FALSE, FALSE, "ktoś obok konsoli taktycznej") \
		|| check_permissions(ordnance_screen, viewer, FALSE, FALSE, FALSE, "ktoś przy konsoli uzbrojenia")
	if(!fail)
		fail = check_actions(ship, station, sensor_screen, fire_screen, ordnance_screen, operator, gunner, viewer, pilot)
	if(!fail)
		var/list/data = ordnance_screen.ui_data(viewer)
		var/list/sensor_data = data["sensor"]
		var/list/fire_data = data["fire"]
		if(data["mode"] != "view" || !sensor_data || !islist(sensor_data["contacts"]) || !fire_data || !islist(fire_data["own_armour"]))
			fail = "Konsola uzbrojenia nie wysłała podglądu z danymi rozpoznania i ognia ([json_encode(data)])"
		var/list/sensor_mode = sensor_screen.ui_data(operator)
		var/list/fire_mode = fire_screen.ui_data(gunner)
		if(!fail && (sensor_mode["mode"] != "sensors" || fire_mode["mode"] != "fire"))
			fail = "Stanowisko rozpoznania albo konsola taktyczna nie otwiera się w swoim trybie"
	usr = null
	qdel(sensor_screen)
	qdel(fire_screen)
	qdel(ordnance_screen)
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_tactical_screen/proc/check_permissions(datum/tactical_screen/screen, mob/user, sensors, fire, pulse, who)
	var/list/allowed = screen.permissions(user)
	if(!!allowed["sensors"] != sensors || !!allowed["fire"] != fire || !!allowed["pulse"] != pulse)
		return "Złe uprawnienia dla: [who] ([json_encode(allowed)])"

/datum/unit_test/aquila_tactical_screen/proc/check_actions(obj/structure/overmap/ship, obj/machinery/computer/ship/dradis/sensors/station, datum/tactical_screen/sensor_screen, datum/tactical_screen/fire_screen, datum/tactical_screen/ordnance_screen, mob/operator, mob/gunner, mob/viewer, mob/pilot)
	ship.ams_shot_limit = 5
	station.sensor_mode = SENSOR_MODE_PASSIVE
	var/datum/tgui/ui = new(viewer, ordnance_screen, "TacticalScreen")
	usr = viewer
	ordnance_screen.ui_act("fc_ams_limit", list("shot_limit" = 12), ui)
	qdel(ui)
	if(ship.ams_shot_limit != 5)
		return "Konsola uzbrojenia zmieniła limit strzałów AMS, choć tylko pokazuje"
	ui = new(gunner, fire_screen, "TacticalScreen")
	usr = gunner
	fire_screen.ui_act("fc_ams_limit", list("shot_limit" = 12), ui)
	fire_screen.ui_act("set_sensor_mode", list("radar" = TRUE), ui)
	qdel(ui)
	if(ship.ams_shot_limit != 12)
		return "Strzelec nie zmienił limitu strzałów AMS z ekranu taktycznego"
	if(station.sensor_mode != SENSOR_MODE_PASSIVE)
		return "Strzelec przełączył tryb sensorów z konsoli taktycznej"
	ui = new(pilot, sensor_screen, "TacticalScreen")
	usr = pilot
	sensor_screen.ui_act("set_sensor_mode", list("radar" = TRUE), ui)
	if(station.sensor_mode != SENSOR_MODE_PASSIVE)
		qdel(ui)
		return "Pilot przy sterze przełączył tryb sensorów"
	ship.last_radar_pulse = world.time - 10 MINUTES
	var/before = ship.last_radar_pulse
	sensor_screen.ui_act("radar_pulse", list(), ui)
	qdel(ui)
	if(ship.last_radar_pulse == before)
		return "Pilot przy sterze nie wysłał impulsu radaru z ekranu taktycznego"
	ui = new(operator, sensor_screen, "TacticalScreen")
	usr = operator
	sensor_screen.ui_act("set_sensor_mode", list("radar" = TRUE), ui)
	qdel(ui)
	if(station.sensor_mode != SENSOR_MODE_RADAR)
		return "Operator przy stanowisku nie przełączył radaru z ekranu taktycznego"

/// DRADIS górniczy (hangar Aquilas) nie zajmuje miejsca DRADIS-u okrętu: pilot dostaje stanowisko rozpoznania
/// niezależnie od kolejności, w jakiej konsole łączą się z okrętem
/datum/unit_test/aquila_ship_dradis_choice

/datum/unit_test/aquila_ship_dradis_choice/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/machinery/computer/ship/dradis/sensors/station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	var/obj/machinery/computer/ship/dradis/mining/mining = allocate(/obj/machinery/computer/ship/dradis/mining)
	ship.dradis = null
	station.set_position(ship)
	mining.set_position(ship)
	var/first = ship.dradis
	ship.dradis = null
	mining.set_position(ship)
	station.set_position(ship)
	var/second = ship.dradis
	ship.sensor_console = null
	ship.dradis = null
	if(first != station || second != station)
		return Fail("DRADIS okrętu to [first] (stanowisko przed górniczym) i [second] (górniczy przed stanowiskiem) zamiast stanowiska rozpoznania")

/// Pomocniczy DRADIS (kontrola lotów, ekrany) otwiera Podgląd ekranu taktycznego, a DRADIS-y ze specjalną funkcją mają
/// własne okno w tym samym wyglądzie (dradis_window.dm): kontakty radaru zamiast dawnych blipów mapy, a w ładowni
/// akcja kontaktu to dostawa ładunku
/datum/unit_test/aquila_special_dradis_window

/datum/unit_test/aquila_special_dradis_window/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/machinery/computer/ship/dradis/minor/helper = allocate(/obj/machinery/computer/ship/dradis/minor)
	var/obj/machinery/computer/ship/dradis/mining/mining = allocate(/obj/machinery/computer/ship/dradis/mining)
	var/obj/machinery/computer/ship/dradis/minor/cargo/cargo = allocate(/obj/machinery/computer/ship/dradis/minor/cargo)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	for(var/obj/machinery/computer/ship/dradis/console as anything in list(helper, mining, cargo))
		console.forceMove(ship) // get_overmap() szuka okrętu przez loc, poziom testu nie ma okrętu
		console.linked = ship
	if(!helper.tactical_screen_ship() || mining.tactical_screen_ship() || cargo.tactical_screen_ship())
		return Fail("Pomocniczy DRADIS nie otwiera Podglądu albo skaner lub ładownia straciły swoje okno")
	var/list/data = mining.ui_data(user)
	if(data["kind"] != "mining" || !islist(data["contacts"]) || !islist(data["objects"]) || ("ships" in data))
		return Fail("Okno skanera asteroid nie dostało kontaktów i obiektów radaru ([json_encode(data)])")
	data = cargo.ui_data(user)
	if(data["kind"] != "cargo" || data["hail_label"] != "Dostarcz ładunek")
		return Fail("Okno ładowni nie ma dostawy ładunku w karcie kontaktu ([data["kind"]], [data["hail_label"]])")
