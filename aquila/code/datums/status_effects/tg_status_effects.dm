// AQUILA - zgodność statusów z tgstation (port heretyka). U nas duration to czas końca (world.time),
// a tick_interval po nałożeniu to czas następnego tyknięcia, a nie odstęp jak w tg.

/datum/status_effect
	/// tg: pokazuje czas trwania na alercie (u nas bez efektu)
	var/show_duration = FALSE
	/// tg: szybkość przetwarzania (u nas zawsze SSfastprocess)
	var/processing_speed = STATUS_EFFECT_FAST_PROCESS
	/// tg: zdejmowany przy pełnym leczeniu
	var/remove_on_fullheal = FALSE
	/// tg: flaga leczenia potrzebna do zdjęcia (u nas fully_heal nie ma flag, więc wystarcza każde)
	var/heal_flag_necessary = NONE

/datum/status_effect/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(owner && remove_on_fullheal)
		RegisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(remove_effect_on_heal))
	if(owner)
		update_particles()

/datum/status_effect/Destroy()
	if(owner && remove_on_fullheal)
		UnregisterSignal(owner, COMSIG_LIVING_POST_FULLY_HEAL)
	return ..()

/datum/status_effect/proc/remove_effect_on_heal(datum/source, admin_revive)
	SIGNAL_HANDLER
	if(remove_on_fullheal)
		qdel(src)

/// tg: odświeża cząsteczki statusu
/datum/status_effect/proc/update_particles()
	return

/// tg: zatrzymuje tykanie
/datum/status_effect/proc/stop_ticking()
	tick_interval = -1
	if(duration == -1)
		STOP_PROCESSING(SSfastprocess, src)

/// Status bez własnego id - nakładany ze źródłami. Usuwa się dopiero, gdy zniknie ostatnie źródło.
/datum/status_effect/grouped
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	status_type = STATUS_EFFECT_MULTIPLE
	/// Źródła statusu
	var/list/sources = list()

/datum/status_effect/grouped/on_creation(mob/living/new_owner, source, ...)
	var/list/new_source_args = args.Copy(2)
	if(isnull(source))
		stack_trace("Grouped status effect applied without a source")
		qdel(src)
		return FALSE
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(existing)
		existing.sources |= source
		existing.source_added(arglist(new_source_args))
		qdel(src)
		return FALSE
	. = ..()
	if(.)
		sources |= source
		source_added(arglist(new_source_args))

/datum/status_effect/grouped/proc/source_added(source, ...)
	return

/datum/status_effect/grouped/proc/source_removed(source, removing)
	return

/datum/status_effect/grouped/before_remove(source)
	sources -= source
	var/was_last_source = !length(sources)
	source_removed(source, was_last_source)
	return was_last_source

/// Status z ładunkami: rośnie od nakładania, po progu robi efekt, a z czasem opada
/datum/status_effect/stacking
	id = STATUS_EFFECT_ID_ABSTRACT
	duration = -1
	tick_interval = 1 SECONDS
	alert_type = null
	/// Ładunki
	var/stacks = 0
	/// Ile czekamy po dodaniu ładunków, zanim zaczną opadać
	var/delay_before_decay
	/// Ile ładunków ubywa na tyknięcie
	var/stack_decay = 1
	/// Próg efektu
	var/stack_threshold
	/// Najwięcej ładunków
	var/max_stacks
	/// Czy przekroczenie progu zużywa status
	var/consumed_on_threshold = TRUE
	/// Czy próg jest teraz przekroczony
	var/threshold_crossed = FALSE
	/// Plik nakładki z liczbą ładunków
	var/overlay_file
	/// Stan nakładki (z dopiskiem liczby ładunków)
	var/overlay_state
	var/mutable_appearance/status_overlay

/datum/status_effect/stacking/Destroy()
	if(owner && status_overlay)
		owner.cut_overlay(status_overlay)
	status_overlay = null
	return ..()

/datum/status_effect/stacking/proc/threshold_cross_effect()
	return

/datum/status_effect/stacking/proc/stacks_consumed_effect()
	return

/datum/status_effect/stacking/proc/fadeout_effect()
	return

/datum/status_effect/stacking/proc/stack_decay_effect()
	return

/datum/status_effect/stacking/proc/on_threshold_cross()
	threshold_cross_effect()
	if(consumed_on_threshold)
		stacks_consumed_effect()
		qdel(src)

/datum/status_effect/stacking/proc/on_threshold_drop()
	return

/datum/status_effect/stacking/proc/can_have_status()
	return owner.stat != DEAD

/datum/status_effect/stacking/proc/can_gain_stacks()
	return owner.stat != DEAD

/datum/status_effect/stacking/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(.)
		add_stacks(stacks_to_apply)

/datum/status_effect/stacking/on_apply()
	if(!can_have_status())
		return FALSE
	if(overlay_file && overlay_state)
		status_overlay = mutable_appearance(overlay_file, "[overlay_state][stacks]")
		owner.add_overlay(status_overlay)
	return ..()

/datum/status_effect/stacking/tick(seconds_between_ticks)
	if(!can_have_status())
		qdel(src)
		return
	add_stacks(-stack_decay)
	stack_decay_effect()

/datum/status_effect/stacking/proc/add_stacks(stacks_added)
	if(stacks_added > 0 && !can_gain_stacks())
		return FALSE
	if(status_overlay)
		owner.cut_overlay(status_overlay)
	stacks = min(stacks + stacks_added, max_stacks)
	if(stacks <= 0)
		fadeout_effect()
		qdel(src)
		return
	if(stacks >= stack_threshold && !threshold_crossed)
		threshold_crossed = TRUE
		on_threshold_cross()
		if(consumed_on_threshold)
			return
	else if(stacks < stack_threshold && threshold_crossed)
		threshold_crossed = FALSE
		on_threshold_drop()
	if(stacks_added > 0 && delay_before_decay)
		// u nas tick_interval to czas następnego tyknięcia
		tick_interval = max(tick_interval, world.time) + delay_before_decay
	if(status_overlay)
		status_overlay.icon_state = "[overlay_state][stacks]"
		owner.add_overlay(status_overlay)
