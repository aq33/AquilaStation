// AQUILA - reszta HFR spoza katalogu fusion w Yogu: pętla dźwięku, płytki, skrzynia w cargo, wyrzut rdzenia (plan maszynowni E17).

/datum/looping_sound/hypertorus
	mid_sounds = list('aquila/sound/machines/hypertorus/hypertorus_nominal.ogg' = 1)
	mid_length = 60
	volume = 55
	extra_range = 15

// --- Płytki (Yog: machine_circuitboards.dm) ---

/obj/item/circuitboard/machine/HFR_fuel_input
	name = "wlot paliwa HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/fuel_input
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_waste_output
	name = "wylot odpadów HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/waste_output
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_moderator_input
	name = "wlot moderatora HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/moderator_input
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_core
	name = "rdzeń HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/hypertorus/core
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 10)

/obj/item/circuitboard/machine/HFR_corner
	name = "narożnik HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/hypertorus/corner
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/HFR_interface
	name = "panel sterowania HFR (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/hypertorus/interface
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 5)

// --- Cargo (Yog: packs.dm) ---

/datum/supply_pack/engine/hypertorus_fusion_reactor
	name = "Skrzynia reaktora fuzyjnego HFR"
	desc = "Hipertoroidalny reaktor fuzyjny w dziewięciu skrzynkach do złożenia w kwadrat 3×3. Otwiera tylko główny inżynier."
	cost = 10000
	access = ACCESS_CE
	contains = list(/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/corner,
					/obj/item/hfr_box/body/fuel_input,
					/obj/item/hfr_box/body/moderator_input,
					/obj/item/hfr_box/body/waste_output,
					/obj/item/hfr_box/body/interface,
					/obj/item/hfr_box/core,
					/obj/item/paper/guides/jobs/atmos/hypertorus)
	crate_name = "skrzynia HFR"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

// --- Wyrzut rdzenia (aq33/AquilaStation#708) ---

/datum/component/core_ejection/hfr
	core_name = "rdzenia reaktora fuzyjnego"

/datum/component/core_ejection/hfr/eject_block_reason()
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/core = parent
	if(!core.internal_fusion.total_moles() && !core.moderator_internal.total_moles())
		return "Komora fuzji jest pusta."
	return null

/datum/component/core_ejection/hfr/eject_fault_reason()
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/core = parent
	if(core.critical_threshold_proximity >= core.warning_point)
		return null
	return "Reaktor jest sprawny. Wyrzut jest dostępny dopiero przy uszkodzeniu pola magnetycznego."

/datum/component/core_ejection/hfr/blast_damage()
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/core = parent
	return 100 + core.power_level * 40 + core.critical_threshold_proximity / 10

/// Rdzeń wylatuje razem z mieszanką fuzji i moderatorem. Maszyna zostaje, pusta i sprawna, gotowa do ponownego rozruchu
/datum/component/core_ejection/hfr/purge_core()
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/core = parent
	core.internal_fusion.remove_ratio(1)
	core.moderator_internal.remove_ratio(1)
	core.critical_threshold_proximity = 0
	core.critical_threshold_proximity_archived = 0
	core.iron_content = 0
	core.power_level = 0
	core.energy = 0
	core.internal_power = 0
	core.power_output = 0
	core.heat_output = 0
	core.fusion_temperature = 0
	core.moderator_temperature = 0
	core.start_power = FALSE
	core.start_fuel = FALSE
	core.start_moderator = FALSE
	core.use_power = IDLE_POWER_USE
	for(var/obj/machinery/atmospherics/components/unary/hypertorus/part in core.machine_parts)
		part.cracked = FALSE
		part.update_appearance()
