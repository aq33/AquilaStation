// AQUILA - Ciecze: przenośna pompa, port z Monkestation 2.0 (monkestation/code/modules/liquids/liquid_pump.dm)

//Right now it's a structure that works off of magic, as it'd require an internal power source for what its supposed to do
/obj/structure/liquid_pump
	name = "przenośna pompa cieczy"
	desc = "Przemysłowa pompa, która wysysa albo wylewa ciecze. Musi być przykręcona, żeby działać. Ma ograniczony zbiornik."
	icon = 'aquila/icons/obj/structures/liquid_pump.dmi'
	icon_state = "liquid_pump"
	base_icon_state = "liquid_pump"
	density = TRUE
	max_integrity = 500
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// How many reagents at maximum can it hold
	var/max_volume = 10000
	/// Whether spewing reagents out, instead of siphoning them
	var/spewing_mode = FALSE
	/// Whether its turned on and processing
	var/turned_on = FALSE
	/// How fast does the pump work, in percentages relative to the volume we're working with
	var/pump_speed_percentage = 0.4
	/// How fast does the pump work, in flat values. Flat values on top of percentages to help processing
	var/pump_speed_flat = 20

/obj/structure/liquid_pump/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, NO_REACT)

/obj/structure/liquid_pump/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(reagents)
	return ..()

/obj/structure/liquid_pump/wrench_act(mob/living/user, obj/item/wrench)
	. = TRUE
	default_unfasten_wrench(user, wrench, 0.5 SECONDS)
	if(!anchored && turned_on)
		toggle_working()

/obj/structure/liquid_pump/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>Najpierw przykręć [src]!</span>")
		balloon_alert(user, "najpierw przykręć!")
		return
	balloon_alert(user, turned_on ? "wyłączona" : "włączona")
	to_chat(user, "<span class='notice'>[turned_on ? "Wyłączasz" : "Włączasz"] [src].</span>")
	toggle_working()

/obj/structure/liquid_pump/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	spewing_mode = !spewing_mode
	to_chat(user, "<span class='notice'>Przestawiasz [src] na [spewing_mode ? "wylewanie" : "wysysanie"].</span>")
	update_icon()

/obj/structure/liquid_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Śruby mocujące są [anchored ? "dokręcone" : "odkręcone"].</span>"
	. += "<span class='notice'>Pompa jest [turned_on ? "WŁĄCZONA" : "WYŁĄCZONA"].</span>"
	. += "<span class='notice'>Tryb: [spewing_mode ? "WYLEWANIE" : "WYSYSANIE"] (Alt-klik przełącza).</span>"
	. += "<span class='notice'>Wskaźnik ciśnienia pokazuje [round(reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)]/[round(reagents.maximum_volume, CHEMICAL_VOLUME_ROUNDING)].</span>"

/obj/structure/liquid_pump/process(delta_time)
	if(!isturf(loc))
		return
	if(spewing_mode)
		spew(delta_time)
	else
		suck(delta_time)

/obj/structure/liquid_pump/proc/suck(delta_time)
	if(!turned_on)
		return PROCESS_KILL
	var/free_space = round(reagents.maximum_volume - reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
	if(!free_space)
		return
	var/list/turfs_to_suck = list()
	for(var/turf/open/turf in range(1, loc))
		if(turf.liquids?.liquid_group?.total_reagent_volume && !turf.liquids.liquid_group.frozen)
			turfs_to_suck += turf
	var/turfs_amt = length(turfs_to_suck)
	if(!turfs_amt) // don't bother
		return
	var/pump_speed_percentage = src.pump_speed_percentage * delta_time
	var/pump_speed_flat = src.pump_speed_flat * delta_time
	for(var/turf/open/turf_to_suck as anything in turfs_to_suck)
		var/datum/liquid_group/turf_liquid_group = turf_to_suck.liquids?.liquid_group
		if(!turf_liquid_group?.total_reagent_volume)
			turfs_amt-- // turf must have lost liquid from us sucking up a different turf
			if(!turfs_amt) // no more turfs to succ, just stop
				return
			continue
		var/target_siphon_amt = min((turf_liquid_group.total_reagent_volume * (pump_speed_percentage / turfs_amt)) + (pump_speed_flat / turfs_amt), free_space)
		turf_liquid_group.trans_to_seperate_group(reagents, round(target_siphon_amt, CHEMICAL_VOLUME_ROUNDING))
		free_space = round(reagents.maximum_volume - reagents.total_volume, CHEMICAL_VOLUME_ROUNDING)
		if(!free_space)
			return

/obj/structure/liquid_pump/proc/spew(delta_time)
	if(!turned_on)
		return PROCESS_KILL
	if(!reagents.total_volume)
		return
	var/turf/turf = loc
	var/datum/reagents/tempr = new(10000, NO_REACT)
	var/target_amt = ((reagents.total_volume * pump_speed_percentage) + pump_speed_flat) * delta_time
	reagents.trans_to(tempr, round(target_amt, CHEMICAL_VOLUME_ROUNDING), no_react = TRUE)
	turf.add_liquid_from_reagents(tempr)
	qdel(tempr)

/obj/structure/liquid_pump/update_icon_state()
	if(turned_on)
		icon_state = spewing_mode ? "[base_icon_state]_spewing" : "[base_icon_state]_siphoning"
	else
		icon_state = base_icon_state
	return ..()

/obj/structure/liquid_pump/proc/toggle_working()
	if(turned_on)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
	turned_on = !turned_on
	update_icon()

/// Nadajnik pompy dla woźnego (Monke: generic_beacon/liquid_pump): po użyciu zrzuca pompę i klucz
/obj/item/liquid_pump_beacon
	name = "nadajnik pompy cieczy"
	desc = "Nadajnik NT. Po włączeniu zrzuca przenośną pompę cieczy razem z kluczem do jej przykręcenia, na najgorsze zalania."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/liquid_pump_beacon/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		return
	to_chat(user, "<span class='notice'>Włączasz [src]. Pompa jest w drodze!</span>")
	new /obj/effect/temp_visual/emp/pulse(T)
	new /obj/structure/liquid_pump(T)
	new /obj/item/wrench(T)
	playsound(T, 'sound/machines/twobeep.ogg', 40, TRUE)
	qdel(src)

/// Woźny dostaje nadajnik pompy w plecaku (Monke: janitor.dm)
/datum/outfit/job/janitor
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced = 1, /obj/item/liquid_pump_beacon = 1)

/// Monke: monkestation/code/modules/cargo/packs/service.dm
/datum/supply_pack/service/liquid_pump
	name = "Pompy cieczy (3 szt.)"
	desc = "Trzy przenośne pompy cieczy na zalane korytarze. Klucz do przykręcenia we własnym zakresie."
	cost = 1500
	contains = list(/obj/structure/liquid_pump, /obj/structure/liquid_pump, /obj/structure/liquid_pump)
	crate_name = "skrzynia z pompami cieczy"
	crate_type = /obj/structure/closet/crate/large

/// Odpływy do samodzielnego montażu (u Monke tylko na mapach)
/datum/supply_pack/service/drains
	name = "Odpływy podłogowe (4 szt.)"
	desc = "Cztery kratki odpływowe do wbudowania w podłogę. Przykręć je kluczem tam, gdzie często coś się rozlewa."
	cost = 800
	contains = list(/obj/item/drain_kit, /obj/item/drain_kit, /obj/item/drain_kit, /obj/item/drain_kit)
	crate_name = "skrzynia z odpływami"
