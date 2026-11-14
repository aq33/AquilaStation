// AQUILA - silniki okrętowe (rework systemów okrętu, etap A1).
// Duże dysze na rufie to maszyny: biorą prąd z APC obszaru i plazmę ze zbiorników paliwa statku. Zbiornik to
// podgrzewacz z promów tg, napełniany z kanistra przez port przyłączeniowy obok, i może stać w dowolnym miejscu
// statku (zwykle w maszynowni), bo za dyszami na mapach nie ma miejsca na stanowiska z kanistrami.
// Ciąg statku to jego dotychczasowy ciąg razy udział dysz, które teraz mogą odpalić, w ciągu wszystkich dysz,
// jakie statek miał. Sprawny statek lata więc jak przed reworkiem, a statek bez dysz okrętowych (SI, starsze
// mapy) bez zmian. Zniszczona dysza zostaje jako wrak do naprawy: najpierw płyty plastali, potem spawarka.

/// Najmniejszy ciąg statku z dyszami okrętowymi, gdy żadna nie działa (manewrowanie awaryjne)
#define SHIP_THRUSTER_MIN_THRUST 0.1
/// Ile plastali trzeba na załatanie zniszczonej dyszy
#define SHIP_THRUSTER_REPAIR_SHEETS 5
/// Co ile statek na nowo szuka swoich zbiorników paliwa (dobudowane, rozkręcone)
#define SHIP_FUEL_TANK_REFRESH (5 SECONDS)

/// Wszystkie zbiorniki paliwa silników okrętowych w świecie; statek wybiera z nich swoje
GLOBAL_LIST_EMPTY(ship_engine_fuel_tanks)

/obj/structure/overmap
	/// Dysze okrętowe zgłoszone na tym statku
	var/list/ship_thrusters
	/// Ciąg dysz okrętowych, które teraz mogą odpalić
	var/engine_thrust_active = 0
	/// Największy ciąg dysz okrętowych, jaki statek miał. Zniszczona dysza go nie obniża.
	var/engine_thrust_design = 0
	/// Zbiorniki paliwa silników na pokładzie (odświeżane co SHIP_FUEL_TANK_REFRESH)
	var/list/engine_fuel_tanks
	var/engine_fuel_tanks_refresh = 0

/obj/structure/overmap/Destroy()
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		thruster.linked_ship = null
	ship_thrusters = null
	engine_fuel_tanks = null
	return ..()

/// Mnożnik ciągu od dysz okrętowych: 1 dla statków bez nich, inaczej udział działających dysz
/obj/structure/overmap/proc/get_engine_thrust_mult()
	if(engine_thrust_design <= 0)
		return 1
	return clamp(engine_thrust_active / engine_thrust_design, SHIP_THRUSTER_MIN_THRUST, 1)

/// Czy statek właśnie używa ciągu (lot, hamowanie, manewr na boki)
/obj/structure/overmap/proc/is_thrusting()
	return last_thrust_forward != 0 || last_thrust_right != 0

/obj/structure/overmap/proc/recalculate_engine_thrust()
	var/total = 0
	var/active = 0
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		total += thruster.thrust_power
		if(thruster.can_fire)
			active += thruster.thrust_power
	engine_thrust_design = max(engine_thrust_design, total)
	engine_thrust_active = active

/// Zbiorniki paliwa na pokładzie, które mogą teraz oddawać paliwo (przykręcone, zamknięty panel)
/obj/structure/overmap/proc/get_engine_fuel_tanks()
	if(world.time >= engine_fuel_tanks_refresh)
		engine_fuel_tanks_refresh = world.time + SHIP_FUEL_TANK_REFRESH
		engine_fuel_tanks = list()
		for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank as anything in GLOB.ship_engine_fuel_tanks)
			if(tank.get_overmap() == src)
				engine_fuel_tanks += tank
	. = list()
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank as anything in engine_fuel_tanks)
		if(!QDELETED(tank) && tank.anchored && !tank.panel_open)
			. += tank

/// Plazma we wszystkich zbiornikach paliwa statku (mole)
/obj/structure/overmap/proc/get_engine_fuel(list/tanks = get_engine_fuel_tanks())
	. = 0
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank as anything in tanks)
		var/datum/gas_mixture/air_contents = tank.airs[1]
		. += air_contents.get_moles(tank.gas_type)

/// Spala paliwo po równo ze zbiorników, które je mają. Zwraca, ile spaliło.
/obj/structure/overmap/proc/burn_engine_fuel(amount, list/tanks = get_engine_fuel_tanks())
	. = 0
	var/list/with_fuel = list()
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank as anything in tanks)
		var/datum/gas_mixture/air_contents = tank.airs[1]
		if(air_contents.get_moles(tank.gas_type) > 0)
			with_fuel += tank
	while(amount > 0.0001 && length(with_fuel))
		var/share = amount / length(with_fuel)
		for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank as anything in with_fuel.Copy())
			var/datum/gas_mixture/air_contents = tank.airs[1]
			var/burned = min(air_contents.get_moles(tank.gas_type), share)
			air_contents.adjust_moles(tank.gas_type, -burned)
			tank.update_parents()
			amount -= burned
			. += burned
			if(air_contents.get_moles(tank.gas_type) <= 0)
				with_fuel -= tank

/obj/machinery/ship_thruster
	name = "dysza okrętowa"
	desc = "Wielka dysza napędowa okrętu. Spala plazmę ze zbiorników paliwa statku i potrzebuje prądu do zapłonu."
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	dir = WEST
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	bound_width = 96
	bound_height = 96
	appearance_flags = LONG_GLIDE
	max_integrity = 600
	integrity_failure = 200
	armor = list("melee" = 50, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 20, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 70, "stamina" = 0, "bleed" = 0)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 15000
	/// Udział w ciągu statku
	var/thrust_power = 3
	/// Ile moli plazmy dysza spala na sekundę ciągu
	var/fuel_per_second = 0.15
	/// Statek, któremu ta dysza daje ciąg
	var/obj/structure/overmap/linked_ship
	/// Czy dysza może teraz odpalić (sprawna, zasilona, statek ma paliwo)
	var/can_fire = FALSE
	/// Czy zniszczona dysza jest już załatana płytami i czeka na spawanie
	var/plated = FALSE

/obj/machinery/ship_thruster/large
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	bound_width = 64
	bound_height = 64
	max_integrity = 400
	integrity_failure = 130
	active_power_usage = 10000
	thrust_power = 2
	fuel_per_second = 0.1

/obj/machinery/ship_thruster/Destroy()
	unlink_ship()
	return ..()

/obj/machinery/ship_thruster/proc/link_to_ship(obj/structure/overmap/ship)
	if(linked_ship == ship)
		return
	unlink_ship()
	if(!ship)
		return
	linked_ship = ship
	LAZYOR(ship.ship_thrusters, src)
	ship.recalculate_engine_thrust()

/obj/machinery/ship_thruster/proc/unlink_ship()
	if(!linked_ship)
		return
	var/obj/structure/overmap/ship = linked_ship
	linked_ship = null
	LAZYREMOVE(ship.ship_thrusters, src)
	ship.recalculate_engine_thrust()

/obj/machinery/ship_thruster/proc/check_can_fire(delta_time)
	if(machine_stat & (BROKEN|NOPOWER))
		return FALSE
	if(!anchored || !linked_ship)
		return FALSE
	return linked_ship.get_engine_fuel() >= fuel_per_second * delta_time

/obj/machinery/ship_thruster/process(delta_time)
	if(!linked_ship || QDELETED(linked_ship))
		link_to_ship(get_overmap())
	var/new_can_fire = check_can_fire(delta_time)
	var/firing = new_can_fire && linked_ship.is_thrusting()
	if(firing)
		linked_ship.burn_engine_fuel(fuel_per_second * delta_time)
	use_power = firing ? ACTIVE_POWER_USE : IDLE_POWER_USE
	if(new_can_fire != can_fire)
		can_fire = new_can_fire
		linked_ship?.recalculate_engine_thrust()

/obj/machinery/ship_thruster/obj_break(damage_flag)
	. = ..()
	if(machine_stat & BROKEN)
		do_sparks(5, TRUE, src)
		add_atom_colour("#6a6a6a", FIXED_COLOUR_PRIORITY)
		if(can_fire)
			can_fire = FALSE
			linked_ship?.recalculate_engine_thrust()

/// Zniszczona dysza zostaje jako wrak do naprawy, zamiast się rozpadać
/obj/machinery/ship_thruster/obj_destruction(damage_flag)
	obj_integrity = 1
	obj_break(damage_flag)

/obj/machinery/ship_thruster/proc/finish_repair()
	obj_integrity = max_integrity
	plated = FALSE
	set_machine_stat(machine_stat & ~BROKEN)
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	update_icon()

/obj/machinery/ship_thruster/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/plasteel) && (machine_stat & BROKEN))
		if(plated)
			to_chat(user, "<span class='warning'>[src] jest już załatana, teraz trzeba ją zespawać.</span>")
			return
		var/obj/item/stack/sheet/plasteel/sheets = I
		if(sheets.get_amount() < SHIP_THRUSTER_REPAIR_SHEETS)
			to_chat(user, "<span class='warning'>Potrzebujesz [SHIP_THRUSTER_REPAIR_SHEETS] arkuszy plastali, żeby załatać [src].</span>")
			return
		to_chat(user, "<span class='notice'>Zaczynasz łatać rozbitą [src]...</span>")
		if(!do_after(user, 5 SECONDS, target = src) || plated || !sheets.use(SHIP_THRUSTER_REPAIR_SHEETS))
			return
		plated = TRUE
		user.visible_message("<span class='notice'>[user] łata rozbitą [src] plastalą.</span>", "<span class='notice'>Łatasz [src]. Teraz trzeba ją zespawać.</span>")
		return
	return ..()

/obj/machinery/ship_thruster/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE
	if((machine_stat & BROKEN) && !plated)
		to_chat(user, "<span class='warning'>[src] jest rozbita. Najpierw załataj ją [SHIP_THRUSTER_REPAIR_SHEETS] arkuszami plastali.</span>")
		return TRUE
	if(obj_integrity >= max_integrity && !(machine_stat & BROKEN))
		to_chat(user, "<span class='notice'>[src] nie wymaga naprawy.</span>")
		return TRUE
	if(!I.tool_start_check(user, amount = 1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz spawać [src]...</span>")
	if(!I.use_tool(src, user, (machine_stat & BROKEN) ? 10 SECONDS : 5 SECONDS, volume = 50, amount = 1))
		return TRUE
	finish_repair()
	user.visible_message("<span class='notice'>[user] kończy naprawiać [src].</span>", "<span class='notice'>Naprawiasz [src].</span>")
	return TRUE

/obj/machinery/ship_thruster/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		if(plated)
			. += "<span class='warning'>Dysza jest załatana plastalą. Trzeba ją jeszcze zespawać.</span>"
		else
			. += "<span class='warning'>Dysza jest rozbita. Załataj ją [SHIP_THRUSTER_REPAIR_SHEETS] arkuszami plastali, a potem zespawaj.</span>"
	else if(obj_integrity < max_integrity)
		. += "<span class='notice'>Osłona jest uszkodzona ([round(obj_integrity / max_integrity * 100)]%). Spawarka ją naprawi.</span>"
	if(machine_stat & NOPOWER)
		. += "<span class='warning'>Dysza nie ma prądu.</span>"
	if(linked_ship)
		. += "<span class='notice'>Plazma w zbiornikach paliwa statku: [round(linked_ship.get_engine_fuel(), 0.1)] mol.</span>"

/// Zbiornik paliwa silników okrętowych: podgrzewacz z promów, na start z zapasem plazmy. Napełnia się go
/// z kanistra przez port przyłączeniowy po stronie króćca, a karmi wszystkie dysze statku.
/obj/machinery/atmospherics/components/unary/shuttle/heater/ship
	name = "zbiornik paliwa silników"
	desc = "Zbiornik plazmy, z którego spalają paliwo dysze okrętu. Napełnia się go z kanistra przez port przyłączeniowy."
	circuit = /obj/item/circuitboard/machine/shuttle/heater/ship
	/// Ile moli plazmy jest w zbiorniku na starcie rundy (tylko zbiorniki z mapy, nie zbudowane)
	var/starting_fuel = 600

/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/Initialize(mapload)
	. = ..()
	GLOB.ship_engine_fuel_tanks += src
	if(!mapload)
		return
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(gas_type, starting_fuel)
	air_contents.set_temperature(T20C)

/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/Destroy()
	GLOB.ship_engine_fuel_tanks -= src
	return ..()

/obj/item/circuitboard/machine/shuttle/heater/ship
	name = "zbiornik paliwa silników (płytka maszyny)"
	build_path = /obj/machinery/atmospherics/components/unary/shuttle/heater/ship

#undef SHIP_THRUSTER_MIN_THRUST
#undef SHIP_THRUSTER_REPAIR_SHEETS
#undef SHIP_FUEL_TANK_REFRESH
