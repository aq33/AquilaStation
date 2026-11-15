/// AQUILA - głowice specjalne (aquila/code/modules/overmap/warheads/): każda głowica ma skutek na module okrętu AI bez
/// wnętrza (pożar, straty załogi, ogłuszenie, moduł wyłączony jonami i z powrotem włączony, desant), trafienie pociskiem
/// odpala skutek w module, AI Syndykatu wybiera specjalną torpedę tylko na okręt z wnętrzem, a ładunek na pokładzie
/// zapala plazmę, robi EMP, puszcza trujący obłok i zrzuca droidy z frakcją strzelca.
/datum/unit_test/aquila_special_warheads
	var/obj/structure/overmap/ship
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_special_warheads/Run()
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	target.forceMove(locate(30, 10, run_loc_floor_bottom_left.z))
	var/fail = check_items() || check_modules() || check_projectile_hit() || check_ai_choice() || check_deck_payloads()
	if(fail)
		return Fail(fail)

/// Głowica do budowy daje torpedę, której pocisk przenosi ładunek na pokład
/datum/unit_test/aquila_special_warheads/proc/check_items()
	for(var/warhead_type in subtypesof(/obj/item/ship_weapon/parts/missile/warhead))
		if(!findtext("[warhead_type]", "/special_"))
			continue
		var/obj/item/ship_weapon/parts/missile/warhead/warhead = warhead_type
		var/obj/item/ship_weapon/ammunition/torpedo/torpedo = initial(warhead.build_path)
		var/obj/item/projectile/guided_munition/torpedo/special/projectile = initial(torpedo.projectile_type)
		if(!ispath(projectile, /obj/item/projectile/guided_munition/torpedo/special))
			return "[warhead_type] buduje torpedę bez pocisku specjalnego ([projectile])"
		if(!ispath(initial(projectile.relay_projectile_type), /obj/item/projectile/bullet/delayed_prime/special_warhead))
			return "Pocisk [projectile] nie przenosi ładunku na pokład"

/datum/unit_test/aquila_special_warheads/proc/check_modules()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules)
		return "Fregata AI nie ma modułów"
	var/datum/ship_module/bridge = modules.modules_of("bridge")[1]
	modules.special_warhead_effect(bridge, "incendiary")
	if(bridge.fire < 2)
		return "Głowica zapalająca dała pożar [bridge.fire] zamiast co najmniej 2"
	bridge.fire = 0
	var/crew_before = bridge.crew_lost
	modules.special_warhead_effect(bridge, "chemical")
	if(bridge.crew_lost <= crew_before)
		return "Głowica chemiczna nie zabiła załogi modułu"
	var/efficiency_before = modules.crew_efficiency()
	modules.special_warhead_effect(bridge, "flash")
	if(modules.crew_efficiency() >= efficiency_before)
		return "Głowica ogłuszająca nie obniżyła sprawności załogi"
	modules.crew_stunned_until = 0
	// jony: moduł nie liczy się do sprawności, po czasie wraca
	var/datum/ship_module/engine = modules.modules_of("engine")[1]
	var/engine_before = modules.kind_efficiency("engine")
	modules.special_warhead_effect(engine, "ion")
	if(modules.kind_efficiency("engine") >= engine_before)
		return "Głowica jonowa nie wyłączyła silników ([modules.kind_efficiency("engine")] z [engine_before])"
	engine.offline_until = world.time - 1
	modules.special_warhead_ion_restore(engine)
	if(modules.kind_efficiency("engine") < engine_before)
		return "Silniki nie wróciły po wyłączeniu jonowym ([modules.kind_efficiency("engine")] z [engine_before])"
	var/integrity_before = bridge.integrity
	crew_before = bridge.crew_lost
	modules.special_warhead_effect(bridge, "boarding")
	if(bridge.integrity >= integrity_before || bridge.crew_lost <= crew_before)
		return "Głowica desantowa nie uszkodziła modułu albo nie zabiła załogi"

/// Trafienie pociskiem w okręt bez wnętrza odpala skutek w module
/datum/unit_test/aquila_special_warheads/proc/check_projectile_hit()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	for(var/datum/ship_module/module as anything in modules.modules)
		module.fire = 0
	var/obj/item/projectile/guided_munition/torpedo/special/incendiary/torpedo = allocate(/obj/item/projectile/guided_munition/torpedo/special/incendiary, get_turf(ship))
	torpedo.spec_overmap_hit(ship)
	qdel(torpedo) // pocisk na polu trafiałby w to, co na nie wejdzie
	for(var/datum/ship_module/module as anything in modules.modules)
		if(module.fire >= 2)
			return
	return "Trafienie torpedą zapalającą nie zapaliło żadnego modułu"

/// AI Syndykatu strzela specjalną torpedą tylko w okręt z wnętrzem
/datum/unit_test/aquila_special_warheads/proc/check_ai_choice()
	var/old_chance = GLOB.ai_special_torpedo_chance
	var/old_ai = ship.ai_controlled
	GLOB.ai_special_torpedo_chance = 100
	ship.ai_controlled = TRUE
	. = null
	if(ship.ai_special_torpedo_type(target))
		. = "AI wybrało specjalną torpedę na myśliwiec bez wnętrza"
	target.role = MAIN_OVERMAP
	var/chosen = ship.ai_special_torpedo_type(target)
	target.role = initial(target.role)
	if(!. && !(chosen in GLOB.ai_special_torpedo_types))
		. = "AI nie wybrało specjalnej torpedy na okręt gracza ([chosen])"
	GLOB.ai_special_torpedo_chance = old_chance
	ship.ai_controlled = old_ai

/// Ładunek na pokładzie okrętu z wnętrzem
/datum/unit_test/aquila_special_warheads/proc/check_deck_payloads()
	var/turf/open/T = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	if(!istype(T))
		return "Brak podłogi do testu ładunku"
	// zapalająca: pocisk przekazany na pokład wypuszcza tlen i plazmę w 1000 K
	var/datum/gas_mixture/air = T.return_air()
	var/old_plasma = air.get_moles(GAS_PLASMA)
	var/old_oxygen = air.get_moles(GAS_O2)
	var/old_temperature = air.return_temperature()
	var/obj/item/projectile/bullet/delayed_prime/special_warhead/incendiary/payload = allocate(/obj/item/projectile/bullet/delayed_prime/special_warhead/incendiary, T)
	payload.release_payload(T)
	qdel(payload)
	var/plasma = air.get_moles(GAS_PLASMA)
	var/temperature = air.return_temperature()
	air.set_moles(GAS_PLASMA, old_plasma)
	air.set_moles(GAS_O2, old_oxygen)
	air.set_temperature(old_temperature)
	if(plasma < old_plasma + 100 || temperature < 500)
		return "Głowica zapalająca dała [plasma] mol plazmy w [temperature] K"
	// jonowa: EMP rozładowuje ogniwo obok
	var/obj/item/stock_parts/cell/high/cell = allocate(/obj/item/stock_parts/cell/high, T)
	var/charge_before = cell.charge
	special_warhead_detonate(T, "ion")
	if(cell.charge >= charge_before)
		return "Głowica jonowa nie zrobiła EMP (ogniwo [cell.charge] z [charge_before])"
	// chemiczna: trujący dym albo piana
	special_warhead_detonate(T, "chemical")
	var/found_cloud = FALSE
	for(var/obj/effect/particle_effect/cloud in range(7, T))
		if(istype(cloud, /obj/effect/particle_effect/smoke/chem) || istype(cloud, /obj/effect/particle_effect/foam))
			found_cloud = TRUE
		qdel(cloud)
	if(!found_cloud)
		return "Głowica chemiczna nie wypuściła dymu ani piany"
	// desantowa: droidy z frakcją strzelca
	var/list/droids = special_warhead_detonate(T, "boarding", "Syndicate")
	var/count = length(droids)
	var/wrong_faction = FALSE
	for(var/mob/living/droid as anything in droids)
		if(!("Syndicate" in droid.faction))
			wrong_faction = TRUE
		qdel(droid)
	if(count != 3 || wrong_faction)
		return "Głowica desantowa zrzuciła [count] droidów (frakcja zła: [wrong_faction ? "tak" : "nie"]) zamiast 3 Syndykatu"
