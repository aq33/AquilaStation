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

// Define'y HFR (hfr_defines.dm) są potrzebne tylko w plikach fusion/, ten jest ostatni
#undef FUSION_MAXIMUM_TEMPERATURE
#undef FUSION_INSTABILITY_ENDOTHERMALITY_HFR
#undef INVESTIGATE_HYPERTORUS
#undef HYPERTORUS_INACTIVE
#undef HYPERTORUS_NOMINAL
#undef HYPERTORUS_WARNING
#undef HYPERTORUS_DANGER
#undef HYPERTORUS_EMERGENCY
#undef HYPERTORUS_MELTING
#undef LIGHT_SPEED
#undef PLANCK_LIGHT_CONSTANT
#undef CALCULATED_H2RADIUS
#undef CALCULATED_TRITRADIUS
#undef VOID_CONDUCTION
#undef FUSION_MOLE_THRESHOLD_HFR
#undef INSTABILITY_GAS_POWER_FACTOR_HFR
#undef TOROID_VOLUME_BREAKEVEN_HFR
#undef METALLIC_VOID_CONDUCTIVITY
#undef HIGH_EFFICIENCY_CONDUCTIVITY
#undef MIN_POWER_USAGE
#undef DAMAGE_CAP_MULTIPLIER
#undef HALLUCINATION_HFR
#undef IRON_CHANCE_PER_FUSION_LEVEL
#undef IRON_ACCUMULATED_PER_SECOND
#undef IRON_OXYGEN_HEAL_PER_SECOND
#undef OXYGEN_MOLES_CONSUMED_PER_IRON_HEAL
#undef HFR_RADIATION_FALLOFF
#undef HYPERTORUS_MELTING_PERCENT
#undef HYPERTORUS_EMERGENCY_PERCENT
#undef HYPERTORUS_DANGER_PERCENT
#undef HYPERTORUS_WARNING_PERCENT
#undef WARNING_TIME_DELAY
#undef HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN
#undef HYPERTORUS_COUNTDOWN_TIME
#undef HYPERTORUS_OVERFULL_MIN_POWER_LEVEL
#undef HYPERTORUS_OVERFULL_MAX_SAFE_COLD_FUSION_MOLES
#undef HYPERTORUS_OVERFULL_MAX_SAFE_HOT_FUSION_MOLES
#undef HYPERTORUS_OVERFULL_MOLAR_SLOPE
#undef HYPERTORUS_OVERFULL_TEMPERATURE_SLOPE
#undef HYPERTORUS_OVERFULL_CONSTANT
#undef HYPERTORUS_SUBCRITICAL_MOLES
#undef HYPERTORUS_SUBCRITICAL_SCALE
#undef HYPERTORUS_COLD_COOLANT_MAX_RESTORE
#undef HYPERTORUS_COLD_COOLANT_THRESHOLD
#undef HYPERTORUS_COLD_COOLANT_SCALE
#undef HYPERTORUS_MAX_SAFE_IRON
#undef HYPERTORUS_WARNING_MOLES
#undef HYPERTORUS_HYPERCRITICAL_MOLES
#undef HYPERTORUS_HYPERCRITICAL_SCALE
#undef HYPERTORUS_HYPERCRITICAL_MAX_DAMAGE
#undef HYPERTORUS_WEAK_SPILL_RATE
#undef HYPERTORUS_WEAK_SPILL_CHANCE
#undef HYPERTORUS_MEDIUM_SPILL_PRESSURE
#undef HYPERTORUS_MEDIUM_SPILL_INITIAL
#undef HYPERTORUS_MEDIUM_SPILL_RATE
#undef HYPERTORUS_STRONG_SPILL_PRESSURE
#undef HYPERTORUS_STRONG_SPILL_INITIAL
#undef HYPERTORUS_STRONG_SPILL_RATE
#undef HYPERTORUS_FLAG_BASE_EXPLOSION
#undef HYPERTORUS_FLAG_MEDIUM_EXPLOSION
#undef HYPERTORUS_FLAG_DEVASTATING_EXPLOSION
#undef HYPERTORUS_FLAG_RADIATION_PULSE
#undef HYPERTORUS_FLAG_EMP
#undef HYPERTORUS_FLAG_MINIMUM_SPREAD
#undef HYPERTORUS_FLAG_MEDIUM_SPREAD
#undef HYPERTORUS_FLAG_BIG_SPREAD
#undef HYPERTORUS_FLAG_MASSIVE_SPREAD
#undef HYPERTORUS_FLAG_CRITICAL_MELTDOWN
#undef HYPERTORUS_FLAG_HIGH_POWER_DAMAGE
#undef HYPERTORUS_FLAG_HIGH_FUEL_MIX_MOLE
#undef HYPERTORUS_FLAG_IRON_CONTENT_DAMAGE
#undef HYPERTORUS_FLAG_IRON_CONTENT_INCREASE
#undef HYPERTORUS_FLAG_EMPED
