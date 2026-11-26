// AQUILA - Regenerator tlenu (plan maszynowni E11), wersja uproszczona regeneratora z Baystation12 (Torch).
// Urządzenie na rurze: z rury wejściowej (z tyłu) bierze sam dwutlenek węgla, rozkłada go i oddaje tlen rurą wyjściową (z przodu).
// Węgiel odkłada się w środku i co OXYREGEN_CARBON_PER_SHEET wypada jako bryłka węgla.
// Różnice względem Baya: bez faz napełniania i wypuszczania zbiornika (ciągły przepływ), bez ustawiania mocy,
// węgiel zamiast grafitu (nie mamy go jako materiału). Sprite z Baya (icons/atmos/oxyregenerator.dmi, stany off/on, CC-BY-SA 3.0).

/// Ile moli CO2 na cykl atmosfery rozkłada regenerator na każdy stopień manipulatorów
#define OXYREGEN_MOLES_PER_RATING 0.5
/// Powyżej tego ciśnienia w rurze wyjściowej regenerator czeka
#define OXYREGEN_MAX_OUTPUT_PRESSURE (ONE_ATMOSPHERE * 45)
/// Ile moli węgla daje jedną bryłkę
#define OXYREGEN_CARBON_PER_SHEET 20
/// Ile watów kosztuje rozkładanie mola CO2 na cykl
#define OXYREGEN_POWER_PER_MOLE 2000

/obj/machinery/atmospherics/components/binary/oxygen_regenerator
	name = "regenerator tlenu"
	desc = "Rozkłada dwutlenek węgla z rury na tlen. Węgiel zostaje w środku i co jakiś czas wypada jako bryłka."
	icon = 'aquila/icons/obj/atmospherics/oxygen_regenerator.dmi'
	icon_state = "regenerator"
	density = TRUE
	layer = OBJ_LAYER
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/oxygen_regenerator
	pipe_flags = PIPING_ONE_PER_TURF
	idle_power_usage = 200
	active_power_usage = 200
	/// Ile moli CO2 rozkłada na cykl (z manipulatorów)
	var/moles_per_tick = OXYREGEN_MOLES_PER_RATING * 2
	/// Ile moli węgla zostaje z mola CO2 (z pojemników materii)
	var/carbon_efficiency = 0.5
	/// Uzbierany węgiel w molach
	var/stored_carbon = 0

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/RefreshParts()
	var/manipulator_rating = 0
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		manipulator_rating += manipulator.rating
	moles_per_tick = OXYREGEN_MOLES_PER_RATING * max(1, manipulator_rating)
	var/bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		bin_rating += bin.rating
	carbon_efficiency = min(1, 0.25 + 0.25 * bin_rating)

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/examine(mob/user)
	. = ..()
	. += span_notice("Jest [on ? "włączony" : "wyłączony"]. Kliknij, żeby go [on ? "wyłączyć" : "włączyć"].")
	. += span_notice("Dwutlenek węgla wchodzi rurą z tyłu, tlen wychodzi rurą z przodu. Rozkłada do [moles_per_tick] mol CO2 na cykl.")
	. += span_notice("Przy otwartym panelu można go obrócić <b>kluczem</b>.")
	if(stored_carbon >= 1)
		. += span_notice("W środku zebrało się [round(stored_carbon, 1)] z [OXYREGEN_CARBON_PER_SHEET] moli węgla na kolejną bryłkę.")

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/update_icon_nopipes()
	if(panel_open)
		icon_state = "regenerator-o"
	else if(on && is_operational)
		icon_state = "regenerator_on"
	else
		icon_state = "regenerator"

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/on_construction()
	return ..(null, PIPING_LAYER_DEFAULT)

/// Odłącza maszynę od rur (otwarty panel) albo podłącza ją z powrotem, np. po obróceniu kluczem
/obj/machinery/atmospherics/components/binary/oxygen_regenerator/proc/change_pipe_connection(disconnect)
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node && (src in node.nodes))
			node.disconnect(src)
		nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])
	if(disconnect)
		return
	atmos_init()
	for(var/obj/machinery/atmospherics/node as anything in nodes)
		if(!node)
			continue
		node.atmos_init()
		node.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	set_init_directions()
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/interact(mob/user)
	if(panel_open)
		to_chat(user, span_warning("Najpierw zamknij panel."))
		return
	on = !on
	if(!on)
		use_power = IDLE_POWER_USE
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	balloon_alert(user, on ? "włączony" : "wyłączony")
	update_icon()

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/attackby(obj/item/I, mob/user, params)
	if(!on && default_deconstruction_screwdriver(user, "regenerator-o", "regenerator", I))
		change_pipe_connection(panel_open)
		update_icon()
		return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/binary/oxygen_regenerator/process_atmos()
	if(!on || !is_operational)
		return
	regenerate(airs[1], airs[2])

/// Rozkłada CO2 z wejścia na tlen w wyjściu. Zwraca liczbę rozłożonych moli
/obj/machinery/atmospherics/components/binary/oxygen_regenerator/proc/regenerate(datum/gas_mixture/input, datum/gas_mixture/output)
	use_power = IDLE_POWER_USE
	if(output.return_pressure() >= OXYREGEN_MAX_OUTPUT_PRESSURE)
		return 0
	var/converted = min(input.get_moles(GAS_CO2), moles_per_tick)
	if(converted < MINIMUM_MOLE_COUNT)
		return 0
	// Prąd płaci się tylko za pracę: stawka w watach, pobierana raz na cykl zasilania przez auto_use_power
	use_power = ACTIVE_POWER_USE
	active_power_usage = idle_power_usage + converted * OXYREGEN_POWER_PER_MOLE
	var/datum/gas_mixture/oxygen = new
	oxygen.set_temperature(input.return_temperature())
	oxygen.set_moles(GAS_O2, converted)
	input.adjust_moles(GAS_CO2, -converted)
	output.merge(oxygen)
	stored_carbon += converted * carbon_efficiency
	while(stored_carbon >= OXYREGEN_CARBON_PER_SHEET)
		stored_carbon -= OXYREGEN_CARBON_PER_SHEET
		new /obj/item/stack/sheet/mineral/coal(drop_location())
	update_parents()
	return converted

/obj/item/circuitboard/machine/oxygen_regenerator
	name = "regenerator tlenu (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/oxygen_regenerator
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 2)

/datum/design/board/oxygen_regenerator
	name = "Projekt maszyny (regenerator tlenu)"
	desc = "Płytka drukowana: regenerator tlenu."
	id = "oxygen_regenerator"
	build_path = /obj/item/circuitboard/machine/oxygen_regenerator
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "oxygen_regenerator"

#undef OXYREGEN_MOLES_PER_RATING
#undef OXYREGEN_MAX_OUTPUT_PRESSURE
#undef OXYREGEN_CARBON_PER_SHEET
#undef OXYREGEN_POWER_PER_MOLE
