/*
	AQUILA - kapsuła ksenoflory z zamkniętego PR tgstation/tgstation#82089 (Xenoflora, autorzy: Smartkar i SELFHELL).
	Sprite kapsuły z tego PR-a (aquila/icons/obj/hydroponics/ported_ksenoflora_pod.dmi), licencja CC-BY-SA 3.0.

	Maszyna 2×2 z naszą botaniką w środku (/datum/component/planter), więc rośnie w niej każda roślina, a skaner,
	łopatka, kultywator i reszta sprzętu działają jak przy tacy. Do tego własna atmosfera pod kopułą:
	- rura z zachodu (lewy dolny kafel) odbiera gazy, których rośliny nie potrzebują, rura z południa podaje gazy wymagane przez rośliny,
	- kopuła zamknięta trzyma gaz w środku, otwarta wypuszcza go do pomieszczenia i rośliny oddychają powietrzem z kafla,
	- grzałka i chłodnica ustawiają temperaturę w komorze,
	- zbiornik na odczynniki (woda i chemia dla roślin) napełnia się ręcznie albo rurami z południa.
	Różnice względem PR: płytka maszyny w R&D zamiast składania z czterech części, grzanie i chłodzenie (w PR temperatura szła tylko z gazu z rur),
	rury chemiczne tylko na wejście (w PR także wyjście z blokadą wymaganych odczynników), rośliny nie wytwarzają gazów ani odczynników.
*/

/// Ile moli gazu mieści kapsuła
#define XENOFLORA_MAX_MOLES 3000
/// Pojemność zbiornika na odczynniki
#define XENOFLORA_MAX_REAGENTS 500
/// Na ile sekund kapsuła trzyma zapas wymaganego gazu (u tg XENOFLORA_POD_INPUT_MULTIPLIER)
#define XENOFLORA_GAS_BUFFER_SECONDS 10
/// Zakres temperatury, którą da się ustawić
#define XENOFLORA_MIN_TARGET (T0C - 100)
#define XENOFLORA_MAX_TARGET (T0C + 200)
/// Od tej temperatury pod kopułą widać ogień
#define XENOFLORA_FIRE_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70)

/obj/machinery/atmospherics/components/binary/xenoflora_pod
	name = "kapsuła ksenoflory"
	desc = "Duża taca hydroponiczna z wysuwaną szklaną kopułą, na wypadek gdyby twoi zieloni przyjaciele potrzebowali specjalnej atmosfery. Tylko w niej rośnie ksenoflora."
	icon = 'aquila/icons/obj/hydroponics/ported_ksenoflora_pod.dmi'
	icon_state = "pod"
	density = TRUE
	layer = OBJ_LAYER
	bound_width = 64
	bound_height = 64
	dir = SOUTH
	initialize_directions = SOUTH|WEST
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/xenoflora_pod
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	idle_power_usage = 50
	active_power_usage = 1000
	on = TRUE
	/// Gaz pod kopułą
	var/datum/gas_mixture/internal_gases
	/// Czy kopuła jest zamknięta
	var/dome_extended = TRUE
	/// Temperatura komory, gdy pod kopułą nie ma gazu
	var/chamber_temperature = T20C
	/// Temperatura, do której dąży grzałka i chłodnica
	var/target_temperature = T20C
	/// O ile kelwinów na cykl atmosfery zmienia się temperatura (z mikrolaserów)
	var/heating_rate = 10
	/// Nasza taca
	var/datum/component/planter/planter
	/// Czy ostatnio rysowaliśmy ogień, żeby nie przerysowywać ikony co cykl
	var/drawn_fire = FALSE

/obj/machinery/atmospherics/components/binary/xenoflora_pod/Initialize(mapload)
	internal_gases = new(500) //przed ..(), bo bazowe Initialize już odświeża ikonę
	internal_gases.set_temperature(T20C)
	. = ..()
	create_reagents(XENOFLORA_MAX_REAGENTS, TRANSPARENT | REFILLABLE)
	AddComponent(/datum/component/plumbing/simple_demand)
	planter = AddComponent(/datum/component/planter, list(16, 22), (ABOVE_ALL_MOB_LAYER + 0.2) - OBJ_LAYER, TRUE)
	planter.set_substrate(/datum/plant_subtrate/xenoflora)
	planter.allow_substrate_change = FALSE
	update_icon()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/Destroy()
	if(planter)
		for(var/datum/component/plant/plant as anything in planter.plants.Copy())
			qdel(plant.plant_item)
	if(internal_gases?.total_moles())
		var/turf/open/pod_turf = get_turf(src)
		if(istype(pod_turf))
			pod_turf.assume_air(internal_gases.remove(internal_gases.total_moles()))
			pod_turf.air_update_turf()
	planter = null
	QDEL_NULL(internal_gases)
	return ..()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/on_construction()
	return ..(null, PIPING_LAYER_DEFAULT)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/RefreshParts()
	var/laser_rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating
	heating_rate = max(5, 5 * laser_rating)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/set_init_directions()
	initialize_directions = SOUTH|WEST

/obj/machinery/atmospherics/components/binary/xenoflora_pod/get_node_connects()
	return list(WEST, SOUTH)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/examine(mob/user)
	. = ..()
	var/temperature = round(get_chamber_temperature() - T0C, 0.1)
	if(dome_extended)
		. += span_notice("Kopuła jest zamknięta, w komorze jest [temperature] °C.")
	else
		. += span_notice("Kopuła jest otwarta, w pomieszczeniu jest [temperature] °C.")
	. += span_notice("Rura z południa podaje gazy wymagane przez rośliny, rura z zachodu odbiera pozostałe. Odczynniki wlewa się ręcznie albo rurami chemicznymi z południa.")

/obj/machinery/atmospherics/components/binary/xenoflora_pod/power_change()
	. = ..()
	update_icon()

/// Kapsuła jest włączona i ma zasilanie
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/is_working()
	return on && is_operational

/// Gaz, którym oddychają rośliny: pod kopułą albo z pomieszczenia, gdy kopuła jest otwarta
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/get_plant_air()
	if(dome_extended)
		return internal_gases
	var/turf/pod_turf = get_turf(src)
	return pod_turf?.return_air()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/get_chamber_temperature()
	if(!dome_extended)
		var/datum/gas_mixture/room_air = get_plant_air()
		return room_air ? room_air.return_temperature() : T20C
	if(internal_gases?.total_moles() > MINIMUM_MOLE_COUNT)
		return internal_gases.return_temperature()
	return chamber_temperature

/// Stan kapsuły do skanera roślin
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/get_scan_lines()
	. = list()
	. += is_working() ? "Kapsuła działa." : "Kapsuła nie działa: włącz ją i podłącz zasilanie."
	. += dome_extended ? "Kopuła jest zamknięta." : "Kopuła jest otwarta."
	var/temperature = round(get_chamber_temperature() - T0C, 0.1)
	var/target = round(target_temperature - T0C, 0.1)
	. += "Temperatura: [temperature] °C (docelowa [target] °C)"
	var/datum/gas_mixture/air = get_plant_air()
	var/list/gas_texts = list()
	for(var/gas_id in air?.get_gases())
		var/moles = air.get_moles(gas_id)
		if(moles >= 0.01)
			gas_texts += "[GLOB.gas_data.names[gas_id]] [round(moles, 0.01)] mol"
	. += length(gas_texts) ? "Gazy: [jointext(gas_texts, ", ")]" : "Gazy: brak"

/// Gazy wymagane przez rośliny w kapsule: id gazu = mol/s
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/get_required_gases()
	. = list()
	for(var/datum/component/plant/plant as anything in planter?.plants)
		for(var/datum/plant_feature/feature as anything in plant.plant_features)
			for(var/datum/plant_need/xenoflora/need in feature.plant_needs)
				for(var/gas_id in need.required_gases)
					.[gas_id] += need.required_gases[gas_id]

/obj/machinery/atmospherics/components/binary/xenoflora_pod/process_atmos()
	if(!is_working())
		return
	inject_gases()
	if(dome_extended)
		regulate_temperature()
	else
		spread_gases()
	dump_gases()
	var/fire = dome_extended && get_chamber_temperature() >= XENOFLORA_FIRE_TEMPERATURE
	if(fire != drawn_fire)
		update_icon()

/// Przenosi ilość jednego gazu między mieszaninami razem z jego temperaturą
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/transfer_gas(datum/gas_mixture/source, datum/gas_mixture/destination, gas_id, amount)
	var/datum/gas_mixture/portion = new
	portion.set_temperature(source.return_temperature())
	portion.set_moles(gas_id, amount)
	source.adjust_moles(gas_id, -amount)
	destination.merge(portion)

/// Dobiera z rury wejściowej gazy, których potrzebują rośliny, z zapasem na kilka sekund
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/inject_gases()
	var/list/wanted = get_required_gases()
	if(!length(wanted))
		return
	var/datum/gas_mixture/input = airs[2]
	var/moved = FALSE
	for(var/gas_id in wanted)
		var/space = XENOFLORA_MAX_MOLES - internal_gases.total_moles()
		if(space <= 0)
			break
		var/amount = min(input.get_moles(gas_id), wanted[gas_id] * XENOFLORA_GAS_BUFFER_SECONDS - internal_gases.get_moles(gas_id), space)
		if(amount <= 0)
			continue
		transfer_gas(input, internal_gases, gas_id, amount)
		moved = TRUE
	if(moved)
		update_parents()

/// Oddaje do rury wyjściowej gazy, których rośliny nie potrzebują (bez roślin wszystkie)
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/dump_gases()
	var/list/wanted = get_required_gases()
	var/datum/gas_mixture/output = airs[1]
	var/moved = FALSE
	for(var/gas_id in internal_gases.get_gases())
		if(wanted[gas_id])
			continue
		var/amount = internal_gases.get_moles(gas_id)
		if(amount <= 0)
			continue
		transfer_gas(internal_gases, output, gas_id, amount)
		moved = TRUE
	if(moved)
		update_parents()

/// Przy otwartej kopule gaz z kapsuły uchodzi do pomieszczenia
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/spread_gases()
	if(internal_gases.total_moles() <= 0)
		return
	var/turf/open/pod_turf = get_turf(src)
	if(!istype(pod_turf))
		return
	pod_turf.assume_air(internal_gases.remove(internal_gases.total_moles()))
	pod_turf.air_update_turf()

/// Grzałka i chłodnica: temperatura komory idzie do docelowej o heating_rate na cykl
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/regulate_temperature()
	var/has_gas = internal_gases.total_moles() > MINIMUM_MOLE_COUNT
	var/current = has_gas ? internal_gases.return_temperature() : chamber_temperature
	var/delta = clamp(target_temperature - current, -heating_rate, heating_rate)
	if(abs(delta) < 0.1)
		use_power = IDLE_POWER_USE
		return
	use_power = ACTIVE_POWER_USE
	chamber_temperature = current + delta
	if(has_gas)
		internal_gases.set_temperature(chamber_temperature)

/// Zbiera owoce ze wszystkich roślin naraz, zwraca TRUE, jeśli coś zebrano
/obj/machinery/atmospherics/components/binary/xenoflora_pod/proc/harvest_all(mob/living/user)
	. = FALSE
	if(!planter)
		return
	for(var/datum/component/plant/plant as anything in planter.plants.Copy())
		if(QDELETED(plant))
			continue
		for(var/datum/plant_feature/fruit/fruit in plant.plant_features)
			if(length(fruit.fruits) && fruit.catch_attack_hand(src, user))
				. = TRUE

/obj/machinery/atmospherics/components/binary/xenoflora_pod/attack_hand(mob/living/user, list/modifiers)
	if(isliving(user) && harvest_all(user))
		playsound(src, 'sound/effects/footstep/grass3.ogg', 50, TRUE)
		return TRUE
	return ..()

// Poza walką przedmioty (nasiona, zlewki, skaner, łopatka) nie uderzają w kapsułę, tylko działają w afterattack jak przy tacy
/obj/machinery/atmospherics/components/binary/xenoflora_pod/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!user.combat_mode)
		return FALSE
	return ..()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/screwdriver_act(mob/living/user, obj/item/tool)
	if(on)
		balloon_alert(user, "najpierw wyłącz kapsułę!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "pod-open", "pod-unpowered", tool))
		update_icon()
		return TRUE

/obj/machinery/atmospherics/components/binary/xenoflora_pod/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/atmospherics/components/binary/xenoflora_pod/Exited(atom/movable/gone, direction)
	. = ..()
	vis_contents -= gone
	if(!QDELETED(src) && gone.GetComponent(/datum/component/plant))
		update_icon()

/obj/machinery/atmospherics/components/binary/xenoflora_pod/update_icon_nopipes()
	cut_overlays()
	if(panel_open)
		icon_state = "pod-open"
	else if(is_working())
		icon_state = "pod"
	else
		icon_state = "pod-unpowered"
	var/list/new_overlays = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, new_overlays) //złącza rur chemicznych
	new_overlays += mutable_appearance(icon, "dirt", ABOVE_ALL_MOB_LAYER + 0.15)
	var/temperature = get_chamber_temperature()
	drawn_fire = dome_extended && temperature >= XENOFLORA_FIRE_TEMPERATURE
	if(dome_extended)
		new_overlays += mutable_appearance(icon, "glass_behind", ABOVE_ALL_MOB_LAYER + 0.1)
		new_overlays += mutable_appearance(icon, "glass_front", ABOVE_ALL_MOB_LAYER + 0.3)
	if(drawn_fire)
		new_overlays += mutable_appearance(icon, "fire", ABOVE_ALL_MOB_LAYER + 0.25)
	if(is_working() && length(planter?.plants))
		new_overlays += mutable_appearance(icon, temperature >= XENOFLORA_FIRE_TEMPERATURE ? "pod-screen-fire" : "pod-screen", ABOVE_ALL_MOB_LAYER)
	add_overlay(new_overlays)

/obj/machinery/atmospherics/components/binary/xenoflora_pod/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(arrived.GetComponent(/datum/component/plant))
		update_icon()

/*
	Okno
*/
/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenofloraPod", name)
		ui.open()
		ui.set_autoupdate(TRUE) // gazy, temperatura i wzrost roślin

/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["working"] = is_working()
	data["dome"] = dome_extended
	data["temperature"] = round(get_chamber_temperature(), 0.1)
	data["target_temperature"] = round(target_temperature, 0.1)
	data["min_temperature"] = XENOFLORA_MIN_TARGET
	data["max_temperature"] = XENOFLORA_MAX_TARGET
//Rośliny
	var/list/plants = list()
	for(var/datum/component/plant/plant as anything in planter?.plants)
		var/datum/plant_feature/body/body = locate() in plant.plant_features
		var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
		var/list/requirements = list()
		var/list/missing = list()
		for(var/datum/plant_feature/feature as anything in plant.plant_features)
			for(var/datum/plant_need/xenoflora/need in feature.plant_needs)
				requirements += need.get_requirement_texts()
				missing += need.get_unmet(src, 1)
		plants += list(list(
			"name" = capitalize(plant.plant_item.name),
			"health" = body ? round(clamp(body.health / max(1, initial(body.health)), 0, 1) * 100) : 100,
			"growth" = body ? round(clamp(body.growth_time_elapsed / max(1, body.growth_time), 0, 1) * 100) : 100,
			"fruits" = length(fruit?.fruits),
			"requirements" = requirements,
			"missing" = missing,
		))
	data["plants"] = plants
//Gazy
	var/datum/gas_mixture/air = get_plant_air()
	var/list/gases = list()
	var/total_moles = 0
	if(air)
		for(var/gas_id in air.get_gases())
			var/moles = air.get_moles(gas_id)
			if(moles < 0.01)
				continue
			total_moles += moles
			gases += list(list("id" = gas_id, "name" = GLOB.gas_data.names[gas_id], "amount" = round(moles, 0.01)))
	data["gases"] = gases
	data["total_moles"] = round(total_moles, 0.01)
//Odczynniki
	var/list/chemicals = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		chemicals += list(list("name" = reagent.name, "color" = reagent.color, "amount" = round(reagent.volume, 0.01)))
	data["chemicals"] = chemicals
	data["total_volume"] = round(reagents.total_volume, 0.01)
	data["max_volume"] = reagents.maximum_volume
	return data

/obj/machinery/atmospherics/components/binary/xenoflora_pod/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("dome")
			if(!is_working())
				return
			dome_extended = !dome_extended
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)
			. = TRUE
		if("target")
			var/target = text2num(params["target"])
			if(isnull(target))
				return
			target_temperature = clamp(target, XENOFLORA_MIN_TARGET, XENOFLORA_MAX_TARGET)
			investigate_log("was set to [target_temperature] K by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
	if(.)
		update_icon()

/*
	Płytka i projekt
*/
/obj/item/circuitboard/machine/xenoflora_pod
	name = "kapsuła ksenoflory (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/atmospherics/components/binary/xenoflora_pod
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/glass = 4)

/datum/design/board/xenoflora_pod
	name = "Projekt maszyny (kapsuła ksenoflory)"
	desc = "Płytka do budowy kapsuły ksenoflory: tacy 2×2 z kopułą, własną atmosferą i regulacją temperatury."
	id = "xenoflora_pod_board"
	build_path = /obj/item/circuitboard/machine/xenoflora_pod
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_SCIENCE

/*
	Zaopatrzenie: nasiona ksenoflory są tylko tu (w PR skrzynia z kapsułą i nasionami)
*/
/datum/supply_pack/organic/xenoflora
	name = "Skrzynia ksenobotaniki"
	desc = "Wszystko na start własnej szklarni obcych roślin: płytka kapsuły ksenoflory i nasiona pięciu gatunków ksenoflory. Części maszyny nie są w zestawie."
	cost = 1500
	access_budget = ACCESS_HYDROPONICS
	contains = list(/obj/item/circuitboard/machine/xenoflora_pod,
					/obj/item/plant_seeds/preset/alien/xenoflora/broombush,
					/obj/item/plant_seeds/preset/alien/xenoflora/cubomelon,
					/obj/item/plant_seeds/preset/alien/xenoflora/hyperlattice,
					/obj/item/plant_seeds/preset/alien/xenoflora/bluespace_limon,
					/obj/item/plant_seeds/preset/alien/xenoflora/pyrite_peach)
	crate_name = "skrzynia ksenobotaniki"
	crate_type = /obj/structure/closet/crate/hydroponics

#undef XENOFLORA_MAX_MOLES
#undef XENOFLORA_MAX_REAGENTS
#undef XENOFLORA_GAS_BUFFER_SECONDS
#undef XENOFLORA_MIN_TARGET
#undef XENOFLORA_MAX_TARGET
#undef XENOFLORA_FIRE_TEMPERATURE
