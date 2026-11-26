/// AQUILA - symulacja wnętrza wrogiego okrętu (plan walki na overmapie, etap „symulacja wnętrza”).
/// Moduły (ship_modules.dm) mają pożar, wyłom i straty załogi. Co 10 sekund ogień niszczy moduł i przechodzi na sąsiednie,
/// wyłom zabija załogę, a żywa załoga gasi, łata i powoli naprawia (damage control AI, lustro konsoli DC gracza).
/// Gdy wnętrze wczytuje się do abordażu, stan modułów przechodzi na mapę: martwi KNPC, rozbite maszyny, ogień, dziury
/// w poszyciu w miejscach trafień.

#define SHIP_SIM_TICK (10 SECONDS)
#define SHIP_SIM_MAX_FIRE 3
/// Poniżej tej części żywej załogi okręt przestaje walczyć: nie strzela, nie manewruje, dryfuje
#define SHIP_SIM_CREW_DEAD 0.05

/datum/ship_module
	/// Pożar 0..3
	var/fire = 0
	/// Wyłom w poszyciu (dekompresja)
	var/breached = FALSE
	/// Część załogi modułu, która zginęła (0..1)
	var/crew_lost = 0

/datum/ship_modules
	var/sim_timer
	/// Stan przeniesiony już na wczytane wnętrze
	var/applied_to_interior = FALSE
	/// Cała załoga zginęła: okręt nie walczy (strat załogi nic nie cofa)
	var/crew_dead = FALSE

/// Skutki trafienia w środku: ogień w pierwszym trafionym module, wyłom przy głębokim wejściu, straty załogi
/datum/ship_modules/proc/on_inside_hit(list/hit_modules, depth, damage)
	if(!length(hit_modules))
		return
	var/datum/ship_module/first = hit_modules[1]
	if(prob(min(100, 25 + damage / 2))) // od 150 obrażeń zawsze
		first.fire = min(SHIP_SIM_MAX_FIRE, first.fire + 1)
	if(depth >= 3)
		first.breached = TRUE
	for(var/datum/ship_module/module as anything in hit_modules)
		module.crew_lost = min(1, module.crew_lost + 0.15 + (module.destroyed() ? 1 : 0))
	start_sim()

/datum/ship_modules/proc/start_sim()
	if(sim_timer || QDELETED(ship))
		return
	sim_timer = addtimer(CALLBACK(src, PROC_REF(sim_tick)), SHIP_SIM_TICK, TIMER_STOPPABLE)

/// Sprawność załogi w gaszeniu i łataniu: żywi w kwaterach i działający mostek
/datum/ship_modules/proc/crew_efficiency()
	var/total = 0
	var/count = 0
	for(var/datum/ship_module/module as anything in modules)
		total += 1 - module.crew_lost
		count++
	var/crew = count ? total / count : 1
	return crew * (0.5 + 0.5 * kind_efficiency("bridge"))

/// Część żywej załogi całego okrętu (0..1)
/datum/ship_modules/proc/crew_alive()
	var/total = 0
	var/count = 0
	for(var/datum/ship_module/module as anything in modules)
		total += 1 - module.crew_lost
		count++
	return count ? total / count : 1

/// Sprawdza, czy załoga nie wymarła; martwy okręt przestaje walczyć
/datum/ship_modules/proc/check_crew_dead()
	if(crew_dead || QDELETED(ship) || derelict || crew_alive() >= SHIP_SIM_CREW_DEAD)
		return
	crew_dead = TRUE
	ship.visible_message("<span class='warning'>[ship] milknie: broń przestaje strzelać, a okręt dryfuje bezwładnie.</span>")

/datum/ship_modules/proc/neighbours(datum/ship_module/module)
	. = list()
	for(var/datum/ship_module/other as anything in modules)
		if(other == module)
			continue
		if(other.x0 <= module.x1 + 2 && other.x1 >= module.x0 - 2 && other.y0 <= module.y1 + 2 && other.y1 >= module.y0 - 2)
			. += other

/datum/ship_modules/proc/sim_tick()
	sim_timer = null
	if(QDELETED(ship))
		return
	var/crew = crew_efficiency()
	var/active = FALSE
	for(var/datum/ship_module/module as anything in modules)
		if(module.fire > 0)
			active = TRUE
			damage_module(module, module.max_integrity * 0.03 * module.fire)
			module.crew_lost = min(1, module.crew_lost + 0.03 * module.fire)
			if(prob(10 * module.fire))
				var/list/near = neighbours(module)
				if(length(near))
					var/datum/ship_module/spread = pick(near)
					spread.fire = max(spread.fire, 1)
			if(prob(35 * crew))
				module.fire--
		if(module.breached)
			active = TRUE
			module.crew_lost = min(1, module.crew_lost + 0.1)
			if(prob(12 * crew))
				module.breached = FALSE
		if(module.destroyed())
			module.crew_lost = 1
			module.fire = 0
		else if(!module.fire && module.integrity < module.max_integrity && crew > 0.2)
			active = TRUE
			module.integrity = min(module.max_integrity, module.integrity + module.max_integrity * 0.01 * crew)
	apply_effects()
	if(active)
		start_sim()

/// Przenosi stan modułów na wczytane wnętrze (lewy dolny róg szablonu w bottom_left)
/datum/ship_modules/proc/apply_to_interior(turf/bottom_left, list/layout)
	if(applied_to_interior || !bottom_left || length(layout) < 5)
		return
	applied_to_interior = TRUE
	var/hull_x0 = layout[4]
	var/hull_y1 = layout[5]
	for(var/datum/ship_module/module as anything in modules)
		if(module.fraction() >= 0.95 && !module.fire && !module.breached && module.crew_lost < 0.05)
			continue
		var/list/turfs = block(
			locate(bottom_left.x + hull_x0 + module.x0 - 1, bottom_left.y + hull_y1 - module.y1 - 1, bottom_left.z),
			locate(bottom_left.x + hull_x0 + module.x1 - 1, bottom_left.y + hull_y1 - module.y0 - 1, bottom_left.z))
		apply_module_to_turfs(module, turfs)
	// dziury w poszyciu w miejscach głębokich trafień
	for(var/list/hole as anything in holes)
		if(hole[3] < 2)
			continue
		var/turf/T = locate(bottom_left.x + hull_x0 + round(hole[1]) - 1, bottom_left.y + hull_y1 - round(hole[2]) - 1, bottom_left.z)
		if(T)
			explosion(T, 0, 1, 2, adminlog = FALSE)

/datum/ship_modules/proc/apply_module_to_turfs(datum/ship_module/module, list/turfs)
	var/destroyed = module.destroyed()
	var/list/floors = list()
	for(var/turf/T as anything in turfs)
		if(isopenturf(T) && !isspaceturf(T))
			floors += T
		for(var/mob/living/carbon/human/ai_boarder/crewman in T)
			if(crewman.stat != DEAD && prob(module.crew_lost * 100))
				crewman.death()
		if(destroyed)
			for(var/obj/effect/mob_spawn/spawner in T)
				qdel(spawner)
		for(var/obj/machinery/machine in T)
			if(machine.resistance_flags & INDESTRUCTIBLE)
				continue
			if(destroyed || prob((1 - module.fraction()) * 100))
				machine.take_damage(machine.max_integrity * (destroyed ? 0.9 : 0.5), BRUTE, "bomb")
	if(!length(floors))
		return
	for(var/i in 1 to round((1 - module.fraction()) * 6))
		var/turf/T = pick(floors)
		new /obj/effect/decal/cleanable/ash(T)
		if(prob(40))
			new /obj/effect/decal/cleanable/glass(T)
	for(var/i in 1 to module.fire * 2)
		var/turf/open/T = pick(floors)
		T.atmos_spawn_air("plasma=4;TEMP=1000")

/obj/structure/overmap/post_load_interior()
	. = ..()
	if(!ship_modules || !boarding_reservation_z)
		return
	ship_modules.apply_to_interior(locate(1, 1, boarding_reservation_z), ship_module_layout())

/datum/ship_modules/Destroy(force)
	deltimer(sim_timer)
	sim_timer = null
	return ..()

/datum/ship_modules/apply_effects()
	. = ..()
	check_crew_dead()

// Okręt bez załogi nie podejmuje decyzji (nie strzela, nie manewruje, nie wypuszcza myśliwców)
/obj/structure/overmap/ai_process()
	if(ship_modules?.crew_dead)
		return
	return ..()

// Broń okrętu bez załogi nie strzela
/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	. = ..()
	if(!. || !linked_overmap?.ship_modules?.crew_dead)
		return
	if(inplace_report)
		inplace_report[1] = "Błąd - brak żywej załogi. ([src])"
	return FALSE

#undef SHIP_SIM_TICK
#undef SHIP_SIM_MAX_FIRE
#undef SHIP_SIM_CREW_DEAD
