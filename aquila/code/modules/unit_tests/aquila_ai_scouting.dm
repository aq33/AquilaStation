/// AQUILA - zwiad myśliwców i łącze danych (aquila/code/modules/overmap/ai_scouting.dm): kto idzie na zwiad,
/// radar frontalny namierza tylko cel przed nosem, okręt rakietowy dostaje namiar tylko przy trzymanym
/// namierzaniu, a torpeda bez namierzania traci cel, chyba że jest blisko.

/// Podtyp testowy: okręt rakietowy, bez prawdziwej wyrzutni (zależy od uzbrojenia typu)
/obj/structure/overmap/small_craft/combat/light/scout_test_shooter

/obj/structure/overmap/small_craft/combat/light/scout_test_shooter/is_ai_missile_ship()
	return TRUE

/datum/unit_test/aquila_ai_scouting
	var/obj/structure/overmap/small_craft/combat/light/scout
	var/obj/structure/overmap/small_craft/combat/light/scout_test_shooter/shooter
	var/obj/structure/overmap/small_craft/combat/light/enemy
	var/datum/fleet/flota

/datum/unit_test/aquila_ai_scouting/Run()
	var/was_enabled = GLOB.ai_scouting_enabled
	GLOB.ai_scouting_enabled = TRUE
	var/z = run_loc_floor_bottom_left.z
	scout = allocate(/obj/structure/overmap/small_craft/combat/light)
	shooter = allocate(/obj/structure/overmap/small_craft/combat/light/scout_test_shooter)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	scout.ai_controlled = TRUE
	shooter.ai_controlled = TRUE
	shooter.mass = MASS_MEDIUM
	enemy.faction = "syndicate"
	enemy.mass = MASS_MEDIUM
	scout.forceMove(locate(100, 60, z))
	shooter.forceMove(locate(100, 20, z))
	enemy.forceMove(locate(100, 90, z)) // 30 pól na północ od zwiadowcy
	flota = new /datum/fleet()
	flota.all_ships = list(scout, shooter)
	scout.fleet = flota
	shooter.fleet = flota
	var/fail = check_slots() || check_lock_geometry() || check_datalink() || check_homing() || check_end() || check_radar_track() || check_lead()
	scout.fleet = null
	shooter.fleet = null
	flota.all_ships = null
	scout.ai_controlled = FALSE
	shooter.ai_controlled = FALSE
	GLOB.ai_scouting_enabled = was_enabled
	if(fail)
		return Fail(fail)

/// Zwiadowca jest potrzebny tylko wtedy, gdy flota ma dla kogo celować
/datum/unit_test/aquila_ai_scouting/proc/check_slots()
	if(flota.ai_scout_slots() != 1)
		return "Flota z okrętem rakietowym i bez lotniskowca nie chciała jednego zwiadowcy ([flota.ai_scout_slots()])"
	flota.all_ships = list(scout)
	var/bez = flota.ai_scout_slots()
	flota.all_ships = list(scout, shooter)
	if(bez)
		return "Flota bez okrętu rakietowego wysłała zwiadowcę"
	GLOB.ai_scouting_enabled = FALSE
	var/wylaczone = flota.ai_scout_slots()
	GLOB.ai_scouting_enabled = TRUE
	if(wylaczone)
		return "Z wyłączonym przełącznikiem flota dalej chciała zwiadowcy"

/// Radar frontalny myśliwca: cel w zasięgu i przed nosem
/datum/unit_test/aquila_ai_scouting/proc/check_lock_geometry()
	scout.angle = overmap_angle(scout, enemy)
	if(!scout.ai_lock_geometry_ok(enemy))
		return "Myśliwiec nie mógł namierzyć celu prosto przed nosem"
	scout.angle = overmap_angle(scout, enemy) + 90
	if(scout.ai_lock_geometry_ok(enemy))
		return "Myśliwiec namierzył cel 90 stopni od nosa"
	scout.angle = overmap_angle(scout, enemy)
	enemy.forceMove(locate(100, 140, run_loc_floor_bottom_left.z)) // 80 pól
	var/daleko = scout.ai_lock_geometry_ok(enemy)
	enemy.forceMove(locate(100, 90, run_loc_floor_bottom_left.z))
	if(daleko)
		return "Myśliwiec namierzył cel daleko poza zasięgiem radaru"

/// Okręt rakietowy dostaje namiar tylko wtedy, gdy zwiadowca naprawdę trzyma namierzanie
/datum/unit_test/aquila_ai_scouting/proc/check_datalink()
	scout.ai_scout_target = enemy
	flota.ai_scouts = list(scout)
	scout.target_painted -= enemy
	if(shooter.get_ai_datalink_target())
		return "Okręt rakietowy dostał namiar, choć zwiadowca tylko śledził cel, bez namierzania"
	scout.target_painted[enemy] = FALSE
	var/list/namiar = shooter.get_ai_datalink_target()
	scout.target_painted -= enemy
	if(!namiar || namiar[1] != scout || namiar[2] != enemy)
		return "Okręt rakietowy nie dostał namiaru od zwiadowcy, który namierzał cel"
	if(scout.get_ai_tactic() != "zwiad")
		return "Zwiadowca bez namierzania ma etykietę [scout.get_ai_tactic()] zamiast zwiad"
	scout.ai_scout_target = null
	flota.ai_scouts = null

/// Torpeda na namiar ze zwiadu: trzyma cel przy namierzaniu, bez niego tylko z bliska
/datum/unit_test/aquila_ai_scouting/proc/check_homing()
	scout.target_painted[enemy] = FALSE
	if(!ai_datalink_keeps_homing(scout, enemy, 60))
		return "Torpeda zgubiła cel, choć zwiadowca go namierzał"
	scout.target_painted -= enemy
	if(ai_datalink_keeps_homing(scout, enemy, 60))
		return "Torpeda 60 pól od celu trzymała go bez namierzania"
	if(!ai_datalink_keeps_homing(scout, enemy, 5))
		return "Torpeda tuż przy celu zgubiła go, choć ma własną głowicę"
	if(!ai_datalink_keeps_homing(null, enemy, 5))
		return "Torpeda tuż przy celu zgubiła go po śmierci zwiadowcy"

/// Zwiad trwa, dopóki okręt rakietowy potrzebuje namiaru; kończy się, gdy widzi cel sam, gdy cel goni zwiadowcę
/// albo po czasie służby. Zgłoszony przypadek: zwiad kończył się po ok. 3 s, bo ktoś z floty był blisko celu.
/datum/unit_test/aquila_ai_scouting/proc/check_end()
	var/z = run_loc_floor_bottom_left.z
	scout.ai_scout_target = enemy
	scout.ai_scout_until = world.time + 60 SECONDS
	scout.ai_fleeing = FALSE
	enemy.last_target = null
	enemy.forceMove(locate(100, 90, z))
	shooter.forceMove(locate(100, 20, z))
	LAZYREMOVE(shooter.sensor_contact_suites, enemy)
	var/powod = scout.get_ai_scout_end_reason()
	if(powod)
		return "Zwiad skończył się, choć okręt rakietowy potrzebował namiaru: [powod]"
	// Inny okręt floty walczy blisko celu: to nie powód, okręt rakietowy dalej go nie widzi
	var/obj/structure/overmap/small_craft/combat/light/bliski = allocate(/obj/structure/overmap/small_craft/combat/light)
	bliski.mass = MASS_MEDIUM
	bliski.forceMove(locate(100, 80, z))
	flota.all_ships += bliski
	powod = scout.get_ai_scout_end_reason()
	flota.all_ships -= bliski
	if(powod)
		return "Zwiad skończył się, bo inny okręt floty był blisko celu: [powod]"
	LAZYSET(shooter.sensor_contact_suites, enemy, SENSOR_OPTICAL)
	powod = scout.get_ai_scout_end_reason()
	LAZYREMOVE(shooter.sensor_contact_suites, enemy)
	if(powod != "okręty rakietowe widzą cel same")
		return "Zwiad trwał, choć okręt rakietowy widział cel sam (powód: [powod || "brak"])"
	enemy.last_target = scout
	powod = scout.get_ai_scout_end_reason()
	enemy.last_target = null
	if(powod != "ścigany przez cel")
		return "Zwiad trwał, choć cel gonił zwiadowcę (powód: [powod || "brak"])"
	scout.ai_scout_until = world.time - 1
	powod = scout.get_ai_scout_end_reason()
	if(powod != "koniec służby")
		return "Zwiad trwał po końcu służby (powód: [powod || "brak"])"
	scout.ai_scout_target = null

/// Tor radaru: okręt floty pulsuje radarem, okręt rakietowy strzela do tego, co ten radar widzi, a pocisk
/// trzyma cel, dopóki trwa impuls; potem tylko z bliska
/datum/unit_test/aquila_ai_scouting/proc/check_radar_track()
	var/z = run_loc_floor_bottom_left.z
	var/obj/structure/overmap/small_craft/combat/light/radar = allocate(/obj/structure/overmap/small_craft/combat/light)
	radar.mass = MASS_MEDIUM
	radar.max_tracking_range = 100
	radar.forceMove(locate(100, 40, z))
	flota.all_ships += radar
	flota.ai_scouts = null
	shooter.forceMove(locate(100, 20, z))
	enemy.forceMove(locate(100, 90, z)) // 70 pól od okrętu rakietowego, 50 od radaru
	LAZYREMOVE(shooter.sensor_contact_suites, enemy)
	var/list/okrety = list(scout, shooter, radar, enemy)
	var/wynik
	radar.last_radar_pulse = -INFINITY
	if(shooter.get_ai_datalink_target(okrety))
		wynik = "Okręt rakietowy dostał tor radaru, choć nikt nie pulsował"
	if(!wynik)
		radar.last_radar_pulse = world.time
		var/list/namiar = shooter.get_ai_datalink_target(okrety)
		if(!namiar || namiar[1] != radar || namiar[2] != enemy)
			wynik = "Okręt rakietowy nie dostał toru od okrętu floty, który pulsował i widział cel"
	if(!wynik && !ai_datalink_keeps_homing(radar, enemy, 60))
		wynik = "Pocisk na tor radaru zgubił cel w czasie impulsu"
	if(!wynik)
		radar.last_radar_pulse = -INFINITY
		if(ai_datalink_keeps_homing(radar, enemy, 60))
			wynik = "Pocisk na tor radaru trzymał cel 60 pól dalej po końcu impulsu"
		else if(!ai_datalink_keeps_homing(radar, enemy, 10))
			wynik = "Pocisk na tor radaru nie złapał celu własną głowicą z bliska"
	flota.all_ships -= radar
	return wynik

/// Zwiad wysunięty: zanim ktokolwiek widzi wroga, zwiadowca dostaje miejsce z namiaru nasłuchu
/datum/unit_test/aquila_ai_scouting/proc/check_lead()
	var/z = run_loc_floor_bottom_left.z
	scout.ai_scout_target = null
	scout.ai_scout_lead = null
	flota.ai_contact_picture = null
	var/obj/structure/overmap/small_craft/combat/light/sluchacz = allocate(/obj/structure/overmap/small_craft/combat/light)
	sluchacz.forceMove(locate(100, 50, z))
	flota.all_ships += sluchacz
	enemy.forceMove(locate(100, 140, z))
	var/wynik
	if(flota.get_ai_scout_lead(scout))
		wynik = "Zwiadowca dostał miejsce do zwiadu, choć flota nic nie słyszała ani nie widziała"
	if(!wynik)
		sluchacz.hear_radar_emission(enemy)
		var/turf/lead = flota.get_ai_scout_lead(scout)
		if(!lead)
			wynik = "Zwiadowca nie dostał miejsca do zwiadu z namiaru nasłuchu"
		else if(get_dist(lead, enemy) > 60)
			wynik = "Miejsce zwiadu z nasłuchu wypadło daleko od nadawcy ([get_dist(lead, enemy)] pól)"
		else
			scout.ai_scout_lead = lead
			if(scout.get_ai_tactic() != "zwiad wysunięty" || !scout.is_ai_scouting())
				wynik = "Zwiadowca lecący do namiaru nie był na zwiadzie wysuniętym ([scout.get_ai_tactic()])"
			scout.ai_scout_lead = null
	LAZYREMOVE(sluchacz.radar_emissions, enemy)
	flota.all_ships -= sluchacz
	return wynik
