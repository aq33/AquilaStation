// AQUILA - chłodzenie i przegrzewanie syntetyków (Aurora code/modules/organs/internal/species/machine/cooling_unit.dm,
// Polaris code/modules/organs/internal/robotic/heatsink.dm). Ciało IPC stale się nagrzewa (1 punkt na sekundę, w trybie walki
// i w gorącym otoczeniu więcej), a organ chłodzenia oddaje to ciepło do otoczenia:
// - chłodzenie powietrzem (domyślne): najwydajniejsze, ale w próżni i rzadkim powietrzu przestaje działać, w skafandrze słabnie,
// - chłodzenie cieczą: trochę słabsze, działa w próżni, zużywa więcej energii,
// - pasywny radiator: bez energii i w próżni, ale ledwo nadąża i nie radzi sobie z wysiłkiem.
// Nagrzanie (0-100) zamiast temperatury ciała: u nas temperaturę ciała IPC w próżni ściąga w dół otoczenie, więc przegrzanie
// w próżni by się nie dało. Od 50 ostrzeżenie, od 75 oparzenia klatki i spowolnienie, od 90 do tego awaryjne wyłączenia.
// Organy da się wydrukować i wszczepić (sloty ORGAN_SLOT_AQ_COOLING), część IMPLANTY ich nie dubluje.
// Ikony: Aurora Station (ipc_organs.dmi, CC BY-SA 3.0).

/mob/living/carbon/human
	/// AQUILA - nagrzanie syntetyka (0-100), synth_cooling.dm
	var/aq_synth_heat = 0

/// Czy ten mob się nagrzewa (syntetyk z pozytronowym mózgiem)
/mob/living/carbon/human/proc/aq_has_synth_heat()
	return isipc(src)

/mob/living/carbon/human/proc/aq_adjust_synth_heat(amount)
	if(!aq_has_synth_heat())
		return
	aq_synth_heat = clamp(aq_synth_heat + amount, 0, 100)

/// Krok nagrzewania i chłodzenia (z /datum/species/ipc/spec_life)
/mob/living/carbon/human/proc/aq_synth_heat_tick(delta_time)
	if(stat == DEAD || !aq_has_synth_heat())
		return
	var/gain = AQ_SYNTH_HEAT_GAIN
	if(combat_mode)
		gain *= 1.5
	var/turf/our_turf = get_turf(src)
	var/datum/gas_mixture/environment = our_turf?.return_air()
	var/ambient = environment ? get_temperature(environment) : TCMB
	if(environment && environment.return_pressure() > HAZARD_LOW_PRESSURE && ambient > T0C + 60)
		gain += (ambient - (T0C + 60)) / 50
	if(on_fire)
		gain += 3
	var/obj/item/organ/aq_cooling/cooler = getorganslot(ORGAN_SLOT_AQ_COOLING)
	var/cooling = cooler ? cooler.get_cooling(src, environment, ambient) : 0
	var/old_heat = aq_synth_heat
	aq_synth_heat = clamp(aq_synth_heat + (gain - cooling) * delta_time, 0, 100)
	aq_synth_heat_effects(old_heat, delta_time)

/mob/living/carbon/human/proc/aq_synth_heat_effects(old_heat, delta_time)
	if(aq_synth_heat >= AQ_SYNTH_HEAT_WARN && old_heat < AQ_SYNTH_HEAT_WARN)
		to_chat(src, "<span class='warning'>Alarm: temperatura rdzenia rośnie. Sprawdź chłodzenie.</span>")
	if(aq_synth_heat >= AQ_SYNTH_HEAT_DAMAGE && old_heat < AQ_SYNTH_HEAT_DAMAGE)
		to_chat(src, "<span class='userdanger'>Alarm: przegrzanie! Obudowa się topi!</span>")
	if(aq_synth_heat >= AQ_SYNTH_HEAT_CRITICAL)
		throw_alert("aq_synth_heat", /atom/movable/screen/alert/aq_synth_heat, 3)
	else if(aq_synth_heat >= AQ_SYNTH_HEAT_DAMAGE)
		throw_alert("aq_synth_heat", /atom/movable/screen/alert/aq_synth_heat, 2)
	else if(aq_synth_heat >= AQ_SYNTH_HEAT_WARN)
		throw_alert("aq_synth_heat", /atom/movable/screen/alert/aq_synth_heat, 1)
	else
		clear_alert("aq_synth_heat")
	if(aq_synth_heat >= AQ_SYNTH_HEAT_DAMAGE)
		add_movespeed_modifier("aq_synth_heat", override = TRUE, multiplicative_slowdown = 0.5)
		apply_damage((aq_synth_heat >= AQ_SYNTH_HEAT_CRITICAL ? 1 : 0.5) * delta_time, BURN, BODY_ZONE_CHEST)
		if(aq_synth_heat >= AQ_SYNTH_HEAT_CRITICAL && DT_PROB(3, delta_time) && stat == CONSCIOUS)
			visible_message("<span class='warning'>[src] nieruchomieje, z obudowy bucha gorące powietrze!</span>", \
				"<span class='userdanger'>Awaryjne wyłączenie z przegrzania!</span>")
			Unconscious(4 SECONDS)
	else
		remove_movespeed_modifier("aq_synth_heat")

/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	. = ..()
	H.aq_synth_heat_tick(SSMOBS_DT)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/C)
	. = ..()
	if(ishuman(C))
		C.aq_synth_heat = 0
		C.clear_alert("aq_synth_heat")
		C.remove_movespeed_modifier("aq_synth_heat")

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	aq_synth_heat = 0
	return ..()

/atom/movable/screen/alert/aq_synth_heat
	name = "Przegrzanie"
	desc = "Rdzeń się przegrzewa! Wyjdź z próżni i gorąca, zdejmij skafander albo poproś robotyka o sprawdzenie chłodzenia."
	icon_state = "hot"

// --- Organy chłodzenia ---

/// Chłodzenie powietrzem. Podtypy: chłodzenie cieczą i pasywny radiator. getorgan() znajduje każdy z nich po typie bazowym,
/// więc gatunek nie dokłada nowego chłodzenia, gdy IPC ma już inny rodzaj.
/obj/item/organ/aq_cooling
	name = "chłodzenie powietrzem"
	desc = "Wentylatory i radiator, które oddają ciepło syntetyka do powietrza. Najwydajniejsze, ale w próżni nie działa."
	icon = 'aquila/icons/obj/robotics/synth_organs.dmi'
	icon_state = "ipc_fans"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_AQ_COOLING
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.7
	actions_types = list(/datum/action/item_action/organ_action/use)
	/// Ile nagrzania odbiera na sekundę przy pełnej sprawności
	var/cooling_rate = 1.6
	/// Potrzebuje powietrza dookoła
	var/needs_air = TRUE
	/// Zużycie energii (nutrition) na sekundę pracy
	var/power_use = 0.05

/obj/item/organ/aq_cooling/proc/get_efficiency(mob/living/carbon/human/H, datum/gas_mixture/environment, ambient)
	. = 1 - (damage / maxHealth)
	if(organ_flags & ORGAN_FAILING)
		. *= 0.5
	if(needs_air)
		var/pressure = environment ? H.calculate_affecting_pressure(environment.return_pressure()) : 0
		. *= clamp(pressure / (ONE_ATMOSPHERE * 0.5), 0, 1)
		if(istype(H.wear_suit, /obj/item/clothing/suit/space))
			. *= 0.5
	if(ambient < T0C && (!needs_air || environment?.return_pressure() > HAZARD_LOW_PRESSURE))
		. *= 1.5
	return max(0, .)

/obj/item/organ/aq_cooling/proc/get_cooling(mob/living/carbon/human/H, datum/gas_mixture/environment, ambient)
	var/efficiency = get_efficiency(H, environment, ambient)
	if(!efficiency)
		return 0
	if(power_use)
		if(H.nutrition <= 0)
			return cooling_rate * efficiency * 0.25
		H.adjust_nutrition(-power_use * SSMOBS_DT)
	return cooling_rate * efficiency

/obj/item/organ/aq_cooling/ui_action_click(mob/user, datum/actiontype)
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	var/turf/our_turf = get_turf(H)
	var/datum/gas_mixture/environment = our_turf?.return_air()
	var/efficiency = get_efficiency(H, environment, environment ? H.get_temperature(environment) : TCMB)
	to_chat(H, "<span class='notice'>Diagnostyka chłodzenia: nagrzanie rdzenia [round(H.aq_synth_heat)]%, sprawność [round(efficiency * 100)]%, uszkodzenia [round(damage / maxHealth * 100)]%.</span>")

/obj/item/organ/aq_cooling/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	applyOrganDamage(severity == EMP_HEAVY ? 20 : 10)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.aq_adjust_synth_heat(severity == EMP_HEAVY ? 25 : 10)

/obj/item/organ/aq_cooling/liquid
	name = "chłodzenie cieczą"
	desc = "Pompa i obieg chłodziwa. Działa w próżni, ale potrzebuje więcej energii niż wentylatory."
	icon_state = "ipc_liquid_cooler"
	cooling_rate = 1.4
	needs_air = FALSE
	power_use = 0.15

/obj/item/organ/aq_cooling/passive
	name = "pasywny radiator"
	desc = "Wielki radiator bez ruchomych części. Nie potrzebuje energii ani powietrza, ale ledwo nadąża i nie radzi sobie z wysiłkiem."
	icon_state = "ipc_heatsink"
	cooling_rate = 1.1
	needs_air = FALSE
	power_use = 0

/datum/species/ipc/New()
	. = ..()
	mutant_organs |= /obj/item/organ/aq_cooling

/datum/design/aq_cooling
	name = "Chłodzenie powietrzem"
	desc = "Organ chłodzenia syntetyka."
	id = "aq_cooling_air"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500)
	build_path = /obj/item/organ/aq_cooling
	category = list("Cyborg", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/aq_cooling/liquid
	name = "Chłodzenie cieczą"
	id = "aq_cooling_liquid"
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/organ/aq_cooling/liquid

/datum/design/aq_cooling/passive
	name = "Pasywny radiator"
	id = "aq_cooling_passive"
	materials = list(/datum/material/iron = 3000, /datum/material/copper = 1000)
	build_path = /obj/item/organ/aq_cooling/passive
