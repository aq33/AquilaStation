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
	var/fail = check_slots() || check_lock_geometry() || check_datalink() || check_homing() || check_end()
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

/// Zwiad się kończy, gdy flota wchodzi w zasięg dział albo mija czas służby
/datum/unit_test/aquila_ai_scouting/proc/check_end()
	scout.ai_scout_target = enemy
	scout.ai_scout_until = world.time + 60 SECONDS
	scout.ai_fleeing = FALSE
	enemy.forceMove(locate(100, 90, run_loc_floor_bottom_left.z))
	shooter.forceMove(locate(100, 20, run_loc_floor_bottom_left.z))
	// Bez sprawdzania wykrycia (zależy od sygnatur myśliwca), tylko powody od floty i czasu
	var/powod = scout.get_ai_scout_end_reason()
	if(powod && powod != "wykryty")
		return "Zwiad skończył się bez powodu: [powod]"
	shooter.forceMove(locate(100, 75, run_loc_floor_bottom_left.z)) // 15 pól od celu
	powod = scout.get_ai_scout_end_reason()
	shooter.forceMove(locate(100, 20, run_loc_floor_bottom_left.z))
	if(powod != "flota w zasięgu dział")
		return "Zwiad trwał, choć okręt floty był w zasięgu dział od celu (powód: [powod || "brak"])"
	scout.ai_scout_until = world.time - 1
	powod = scout.get_ai_scout_end_reason()
	if(powod != "koniec służby")
		return "Zwiad trwał po końcu służby (powód: [powod || "brak"])"
	scout.ai_scout_target = null
