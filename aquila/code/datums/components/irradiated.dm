// Napromieniowanie z BeeStation/BeeStation-Hornet#13442 (port tg) z poprawkami
// BeeStation/BeeStation-Hornet#14011 (mutacje od 75% z odstępem), #14339 (can_mutate), #14393 (radhealer bez obrażeń).
// Aquila: powolny naturalny zanik natężenia, prysznic woła on_radiation_clean() bezpośrednio.

/// Obrażenia od toksyn na sekundę × natężenie
#define RADIATION_TOX_DAMAGE_PER_INTENSITY 0.01
/// Najwyżej tyle obrażeń od toksyn na sekundę
#define RADIATION_MAX_TOX_DAMAGE 0.5

#define RADIATION_GLOW_THRESHOLD 20
#define RADIATION_ALERT_THRESHOLD 20
#define RADIATION_MUTATE_THRESHOLD 75
#define RADIATION_BURN_THRESHOLD 75

#define RADIATION_BURN_SPLOTCH_DAMAGE 11
#define RADIATION_BURN_INTERVAL_MIN (30 SECONDS)
#define RADIATION_BURN_INTERVAL_MAX (60 SECONDS)

/// O ile spada natężenie na sekundę z TRAIT_RADHEALER
#define RAD_HEALER_DECREASE_PER_SECOND 0.5

// Prysznice działają na SSmachines
#define RADIATION_CLEAN_IMMUNITY_TIME (SSMACHINES_DT + (1 SECONDS))

/// Atom jest napromieniowany i świeci na zielono.
/// Ludzie dostają obrażenia od toksyn, dopóki natężenie nie spadnie do zera.
/datum/component/irradiated
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// Kiedy nastąpiło napromieniowanie
	var/beginning_of_irradiation
	/// Natężenie (0-100%)
	var/intensity = 1
	/// Czy właśnie czekamy na oparzenie
	var/trying_to_burn = FALSE

	COOLDOWN_DECLARE(clean_cooldown)
	COOLDOWN_DECLARE(irradiated_mutation)

/datum/component/irradiated/Initialize(intensity)
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	// To nie jest niezgodność, po prostu błąd
	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return

	if (!isnull(intensity))
		src.intensity = clamp(intensity, 0, 100)
	else
		src.intensity = 0

	ADD_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	beginning_of_irradiation = world.time

	if (ishuman(parent))
		START_PROCESSING(SSobj, src)
	else
		QDEL_IN(src, 30 SECONDS)
		create_glow()

/datum/component/irradiated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))

/datum/component/irradiated/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN)

/datum/component/irradiated/Destroy(force)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("rad_glow")

	var/mob/living/carbon/human/human_parent = parent
	if (istype(human_parent))
		human_parent.clear_alert(ALERT_IRRADIATED)

	REMOVE_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	STOP_PROCESSING(SSobj, src)

	return ..()

// Przy COMPONENT_DUPE_UNIQUE stary komponent dostaje tu nowy, który zaraz zostanie usunięty
/datum/component/irradiated/InheritComponent(datum/component/irradiated/new_component, i_am_original)
	adjust_intensity(new_component.intensity)

/datum/component/irradiated/process(delta_time)
	if (!ishuman(parent))
		return PROCESS_KILL

	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return PROCESS_KILL

	// Aquila: powolny naturalny zanik (w Bee natężenie spada tylko od leków)
	intensity = max(intensity - RADIATION_NATURAL_DECAY_PER_SECOND * delta_time, 0)

	if (intensity <= 0)
		qdel(src)
		return PROCESS_KILL

	var/mob/living/carbon/human/human_parent = parent

	if (intensity >= RADIATION_GLOW_THRESHOLD)
		if (!human_parent.get_filter("rad_glow"))
			create_glow()
	else if(human_parent.get_filter("rad_glow"))
		human_parent.remove_filter("rad_glow")

	if (intensity >= RADIATION_ALERT_THRESHOLD)
		human_parent.throw_alert(ALERT_IRRADIATED, /atom/movable/screen/alert/irradiated)
	else if(human_parent.alerts[ALERT_IRRADIATED])
		human_parent.clear_alert(ALERT_IRRADIATED)

	if (should_halt_effects(human_parent))
		return

	if (human_parent.stat != DEAD)
		human_parent.dna?.species?.handle_radiation(human_parent, intensity, delta_time)

	if (HAS_TRAIT(human_parent, TRAIT_RADHEALER))
		intensity = max(intensity - RAD_HEALER_DECREASE_PER_SECOND * delta_time, 0)
		return

	if (intensity >= RADIATION_BURN_THRESHOLD && !trying_to_burn)
		start_burn_splotch_timer()

	if (intensity >= RADIATION_MUTATE_THRESHOLD && COOLDOWN_FINISHED(src, irradiated_mutation) && DT_PROB(5, delta_time))
		mutate_human_parent(human_parent)

	// NSV13: odporni na toksyny (np. IPC) nie dostają obrażeń od promieniowania; Bee dawał im oparzenia
	if (!HAS_TRAIT(human_parent, TRAIT_TOXIMMUNE))
		human_parent.adjustToxLoss(min(RADIATION_TOX_DAMAGE_PER_INTENSITY * intensity * delta_time, RADIATION_MAX_TOX_DAMAGE))

/datum/component/irradiated/proc/adjust_intensity(amount)
	intensity = clamp(intensity + amount, 0, 100)

/datum/component/irradiated/proc/should_halt_effects(mob/living/carbon/human/target)
	if (IS_IN_STASIS(target))
		return TRUE

	if (HAS_TRAIT(target, TRAIT_HALT_RADIATION_EFFECTS))
		return TRUE

	if (!COOLDOWN_FINISHED(src, clean_cooldown))
		return TRUE

	return FALSE

/datum/component/irradiated/proc/mutate_human_parent(mob/living/carbon/human/human_parent)
	COOLDOWN_START(src, irradiated_mutation, rand(45, 120) SECONDS)
	if (!human_parent.can_mutate() || HAS_TRAIT(human_parent, TRAIT_MUTATEIMMUNE))
		return
	if (prob(75)) // zwykle mutacja, czasem zmiana wyglądu
		human_parent.easy_randmut()
	else
		human_parent.randmuti()

/datum/component/irradiated/proc/start_burn_splotch_timer()
	trying_to_burn = TRUE
	addtimer(CALLBACK(src, PROC_REF(give_burn_splotches)), rand(RADIATION_BURN_INTERVAL_MIN, RADIATION_BURN_INTERVAL_MAX), TIMER_STOPPABLE)

/datum/component/irradiated/proc/give_burn_splotches()
	trying_to_burn = FALSE

	if (QDELETED(src))
		return

	if (intensity < RADIATION_BURN_THRESHOLD)
		return

	start_burn_splotch_timer()

	var/mob/living/carbon/human/human_parent = parent

	if (should_halt_effects(parent))
		return

	var/obj/item/bodypart/affected_limb = human_parent.get_bodypart(ran_zone(probability = 0))
	if (!affected_limb)
		return
	var/zone_name = strefa_pl(affected_limb.body_zone)
	human_parent.visible_message(
		span_boldwarning("Skóra [human_parent] ([zone_name]) nienaturalnie bulgocze, po czym pokrywa się pęcherzami!"),
		span_boldwarning("Skóra ([zone_name]) nienaturalnie bulgocze, po czym pokrywa się pęcherzami!"),
	)

	if (human_parent.is_blind())
		to_chat(human_parent, span_boldwarning("Czujesz, jak skóra ([zone_name]) bulgocze, a potem pali jak diabli!"))

	human_parent.apply_damage(RADIATION_BURN_SPLOTCH_DAMAGE, BURN, affected_limb)
	playsound(human_parent, 'aquila/sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)

/datum/component/irradiated/proc/create_glow()
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return

	parent_movable.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop), parent_movable), rand(0.1 SECONDS, 1.9 SECONDS)) // Nierówne świecenie

/datum/component/irradiated/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/// Prysznic (w Bee sygnał czyszczenia z CLEAN_TYPE_RADIATION): przedmiot traci skażenie,
/// a człowiek ma wstrzymane skutki, dopóki stoi pod wodą.
/datum/component/irradiated/proc/on_radiation_clean()
	if (isitem(parent))
		qdel(src)
		return

	COOLDOWN_START(src, clean_cooldown, RADIATION_CLEAN_IMMUNITY_TIME)

/datum/component/irradiated/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER

	if (isliving(source))
		to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Obiekt jest napromieniowany. Skażenie nastąpiło około [DisplayTimeText(world.time - beginning_of_irradiation, 5)] temu. Obecny poziom promieniowania: [round(intensity)]%."))
	else
		to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Przedmiot jest napromieniowany."))

	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL

/atom/movable/screen/alert/irradiated
	name = "Napromieniowanie"
	desc = "Jesteś napromieniowany! Weź leki przeciwradiacyjne i stań pod prysznicem, żeby wstrzymać obrażenia."
	icon = 'aquila/icons/hud/screen_alert_radiation.dmi'
	icon_state = ALERT_IRRADIATED

#undef RADIATION_TOX_DAMAGE_PER_INTENSITY
#undef RADIATION_MAX_TOX_DAMAGE
#undef RADIATION_GLOW_THRESHOLD
#undef RADIATION_ALERT_THRESHOLD
#undef RADIATION_MUTATE_THRESHOLD
#undef RADIATION_BURN_THRESHOLD
#undef RADIATION_BURN_SPLOTCH_DAMAGE
#undef RADIATION_BURN_INTERVAL_MIN
#undef RADIATION_BURN_INTERVAL_MAX
#undef RAD_HEALER_DECREASE_PER_SECOND
#undef RADIATION_CLEAN_IMMUNITY_TIME
