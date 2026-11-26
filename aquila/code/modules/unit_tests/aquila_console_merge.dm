/// AQUILA - konsolidacja konsol mostka (sensor_console.dm, fire_control.dm): na okręcie bez osobnego DRADIS stanowisko
/// rozpoznania jest DRADIS-em okrętu, okno otwarte z daleka (pilot przy sterze) jest tylko do podglądu, a ustawienia
/// AMS z dawnej osobnej konsoli działają z konsoli taktycznej.
/datum/unit_test/aquila_console_merge

/datum/unit_test/aquila_console_merge/Run()
	var/obj/structure/overmap/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	ship.ai_controlled = FALSE
	ship.dradis = null
	var/obj/machinery/computer/ship/dradis/sensors/station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	var/obj/machinery/computer/ship/tactical/tactical = allocate(/obj/machinery/computer/ship/tactical)
	for(var/obj/machinery/computer/ship/console as anything in list(station, tactical))
		console.forceMove(ship)
		console.linked = ship
		console.set_position(ship)
		console.machine_stat = NONE
	if(ship.dradis != station)
		return Fail("Stanowisko rozpoznania nie zajęło miejsca DRADIS na okręcie bez DRADIS mostka")

	var/turf/near = get_turf(station)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, locate(min(near.x + 6, world.maxx), near.y, near.z))
	if(!station.is_sensor_readonly(crew))
		return Fail("Okno stanowiska otwarte z daleka (przy sterze) pozwalało sterować sensorami")
	crew.forceMove(near)
	if(station.is_sensor_readonly(crew))
		return Fail("Operator przy samym stanowisku dostał okno tylko do podglądu")

	// bazowe ui_act bez okna w stanie interaktywnym odrzuca każdą akcję, więc test otwiera okno jak gracz
	var/datum/tgui/ui = new(crew, tactical, "FireControl")
	usr = crew
	ship.ams_shot_limit = 5
	tactical.ui_act("fc_ams_limit", list("shot_limit" = 12), ui)
	var/datum/ams_mode/mode = ship.ams_modes[1]
	var/was_enabled = mode.enabled
	tactical.ui_act("fc_ams_mode", list("id" = "\ref[mode]"), ui)
	var/source = ship.ams_data_source
	tactical.ui_act("fc_ams_source", list(), ui)
	usr = null
	qdel(ui)
	if(ship.ams_shot_limit != 12)
		return Fail("Limit strzałów AMS z konsoli taktycznej się nie zmienił (jest [ship.ams_shot_limit])")
	if(mode.enabled == was_enabled)
		return Fail("Przełączenie trybu AMS z konsoli taktycznej nic nie zmieniło")
	if(ship.ams_data_source == source)
		return Fail("Źródło celów AMS z konsoli taktycznej się nie zmieniło")
	var/list/data = tactical.ui_data(crew)
	var/list/ams = data["ams"]
	if(!ams || length(ams["modes"]) != length(ship.ams_modes) || ams["shot_limit"] != 12)
		return Fail("Konsola taktyczna nie wysłała ustawień AMS do okna ([json_encode(ams)])")
