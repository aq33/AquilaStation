// AQUILA - moduł kalibracji działa pokładowego dostaje działanie (raport nsv_martwe_08, pkt 3).
// W NSV13 był tylko nazwą i ikoną (deck_guns.dm), bez płytki i kodu. Stoi obok rdzenia działa, jak moduł samonaprawy.
// Skalibrowany moduł:
// - wydłuża naprowadzanie pocisku (zwykły pocisk 0,2 s) i podwaja jego skręt, a rozrzut pocisku z rozrzutem
//   zmniejsza o połowę, więc pociski rzadziej mijają ruchomy cel,
// - przyspiesza podawanie i ładowanie zamka działa o połowę, a ładowanie bramek pocisku i prochu o 1/4.
// Obrażeń nie zmienia. Po 15 minutach traci kalibrację i nic nie daje, dopóki ktoś nie skalibruje go multitoolem.

/// Jak długo trzyma kalibracja
#define DECK_GUN_CALIBRATION_TIME (15 MINUTES)
/// Kalibracja multitoolem
#define DECK_GUN_CALIBRATION_DELAY (4 SECONDS)
/// Naprowadzanie skalibrowanego pocisku (zwykły: 0,2 s)
#define DECK_GUN_CALIBRATED_HOMING (1.5 SECONDS)
/// Mnożnik czasu podawania i ładowania zamka działa
#define DECK_GUN_CALIBRATED_BREECH_MULT 0.5
/// Mnożnik czasu ładowania bramek pocisku i prochu
#define DECK_GUN_CALIBRATED_GATE_MULT 0.75

/obj/item/circuitboard/machine/deck_gun/calibrator
	name = "moduł kalibracji działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/mineral/copper = 10,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/calibrator

/obj/machinery/deck_turret/calibrator
	desc = "Moduł, który na bieżąco koryguje celownik działa pokładowego, gdy stoi obok jego rdzenia. Skalibrowany wydłuża naprowadzanie pocisków, zmniejsza ich rozrzut i przyspiesza ładowanie. Po kwadransie traci kalibrację: wtedy skalibruj go multitoolem."
	circuit = /obj/item/circuitboard/machine/deck_gun/calibrator
	/// world.time, do którego moduł jest skalibrowany
	var/calibrated_until = 0

/obj/machinery/deck_turret/calibrator/Initialize(mapload)
	. = ..()
	calibrate()

/obj/machinery/deck_turret/calibrator/proc/is_calibrated()
	return anchored && world.time < calibrated_until

/obj/machinery/deck_turret/calibrator/proc/calibrate()
	calibrated_until = world.time + DECK_GUN_CALIBRATION_TIME
	color = null
	addtimer(CALLBACK(src, PROC_REF(lose_calibration)), DECK_GUN_CALIBRATION_TIME, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/obj/machinery/deck_turret/calibrator/proc/lose_calibration()
	calibrated_until = 0
	color = "#8c8c8c"
	visible_message("<span class='warning'>[src] piszczy: kalibracja wygasła.</span>")
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)

/obj/machinery/deck_turret/calibrator/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, "<span class='notice'>Zaczynasz kalibrować moduł...</span>")
	if(!I.use_tool(src, user, DECK_GUN_CALIBRATION_DELAY, volume = 50))
		return
	calibrate()
	to_chat(user, "<span class='notice'>Moduł skalibrowany. Kalibracja wytrzyma około [DisplayTimeText(DECK_GUN_CALIBRATION_TIME)].</span>")

/obj/machinery/deck_turret/calibrator/examine(mob/user)
	. = ..()
	if(is_calibrated())
		. += "<span class='notice'>Skalibrowany jeszcze przez [DisplayTimeText(calibrated_until - world.time, 1)].</span>"
	else
		. += "<span class='warning'>Nieskalibrowany. Skalibruj go multitoolem.</span>"

/// Skalibrowany moduł kalibracji obok rdzenia, jeśli jest
/obj/machinery/deck_turret/core/proc/get_calibrator()
	for(var/obj/machinery/deck_turret/calibrator/calibrator in orange(1, src))
		if(calibrator.is_calibrated())
			return calibrator
	return null

// ---------------------------------------------------------------- ładowanie

/obj/machinery/ship_weapon/deck_turret/proc/aq_update_calibrated_delays()
	var/mult = core?.get_calibrator() ? DECK_GUN_CALIBRATED_BREECH_MULT : 1
	feed_delay = initial(feed_delay) * mult
	chamber_delay = initial(chamber_delay) * mult

/obj/machinery/ship_weapon/deck_turret/feed()
	aq_update_calibrated_delays()
	return ..()

/obj/machinery/ship_weapon/deck_turret/chamber(rapidfire = FALSE)
	aq_update_calibrated_delays()
	return ..()

/obj/machinery/deck_turret/payload_gate/load(obj/item/A, mob/user)
	var/base_delay = load_delay
	if(core?.get_calibrator())
		load_delay *= DECK_GUN_CALIBRATED_GATE_MULT
	. = ..()
	load_delay = base_delay

/obj/machinery/deck_turret/powder_gate/load(obj/item/A, mob/user)
	var/base_delay = load_delay
	if(core?.get_calibrator())
		load_delay *= DECK_GUN_CALIBRATED_GATE_MULT
	. = ..()
	load_delay = base_delay

// ---------------------------------------------------------------- pocisk

/obj/item/projectile/bullet/mac_round
	/// Skalibrowany pocisk: world.time, do którego naprowadzanie zostaje włączone
	var/aq_homing_until = 0

/// Pocisk wystrzelony z działa ze skalibrowanym modułem: dłuższe i ostrzejsze naprowadzanie, mniejszy rozrzut
/obj/item/projectile/bullet/mac_round/proc/aq_calibrate()
	homing_turn_speed = initial(homing_turn_speed) * 2
	spread *= 0.5
	if(homing_benefit_time >= DECK_GUN_CALIBRATED_HOMING)
		return
	aq_homing_until = world.time + DECK_GUN_CALIBRATED_HOMING
	addtimer(CALLBACK(src, PROC_REF(stop_homing)), DECK_GUN_CALIBRATED_HOMING)

/obj/item/projectile/bullet/mac_round/stop_homing()
	if(aq_homing_until > world.time)
		return // Zwykły timer z Initialize(); skalibrowany pocisk wyłączy naprowadzanie własnym
	return ..()

/// Działo, z którego wystrzelono pocisk, ma skalibrowany moduł obok rdzenia
/obj/item/ship_weapon/ammunition/naval_artillery/proc/aq_apply_calibration(obj/item/projectile/proj)
	var/obj/machinery/ship_weapon/deck_turret/turret = loc
	if(!istype(turret) || !istype(proj, /obj/item/projectile/bullet/mac_round) || !turret.core?.get_calibrator())
		return
	var/obj/item/projectile/bullet/mac_round/round = proj
	round.aq_calibrate()

/obj/item/ship_weapon/ammunition/naval_artillery/handle_shell_modifiers(obj/item/projectile/proj)
	. = ..()
	aq_apply_calibration(proj)

// Pocisk przeciwpancerny nadpisuje modyfikatory bez ..(), więc dostaje kalibrację osobno
/obj/item/ship_weapon/ammunition/naval_artillery/ap/handle_shell_modifiers(obj/item/projectile/proj)
	. = ..()
	aq_apply_calibration(proj)

// ---------------------------------------------------------------- badania i handel

/datum/design/board/deck_gun_calibrator
	name = "Projekt maszyny (moduł kalibracji działa pokładowego)"
	desc = "Moduł obok rdzenia działa pokładowego: dłuższe naprowadzanie pocisków, mniejszy rozrzut i szybsze ładowanie. Co kwadrans trzeba go skalibrować multitoolem."
	id = "deck_gun_calibrator"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 5000, /datum/material/titanium = 10000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/circuitboard/machine/deck_gun/calibrator
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/ship_armament/New()
	. = ..()
	design_ids += "deck_gun_calibrator"

/datum/trader_item/deck_gun_calibrator
	name = "Płytka modułu kalibracji działa pokładowego"
	desc = "Moduł obok rdzenia działa pokładowego: dłuższe naprowadzanie pocisków, mniejszy rozrzut i szybsze ładowanie. Co kwadrans trzeba go skalibrować multitoolem."
	price = 10000
	stock = 1
	unlock_path = /obj/item/circuitboard/machine/deck_gun/calibrator

/datum/trader/stock_items()
	if(type == /datum/trader/armsdealer)
		sold_items |= list(/datum/trader_item/deck_gun_calibrator)
	return ..()

#undef DECK_GUN_CALIBRATION_TIME
#undef DECK_GUN_CALIBRATION_DELAY
#undef DECK_GUN_CALIBRATED_HOMING
#undef DECK_GUN_CALIBRATED_BREECH_MULT
#undef DECK_GUN_CALIBRATED_GATE_MULT
