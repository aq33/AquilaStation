// AQUILA - pływanie i mokra woda: port elementów swimming_tile i watery_tile z Shiptesta
// (code/datums/elements/swimming_tile.dm, watery_tile.dm, AGPLv3, z tg).
// Głęboka woda (swimming_tile): każdy krok w wodzie może kosztować staminę, a kto padnie z wyczerpania (leży) albo jest
// mały, zaczyna tonąć: obrażenia tlenowe i utrata oddechu, póki nie wyjdzie na brzeg. Butla z maską i brak oddychania
// chronią przed tonięciem, jazda na kimś albo w pojeździe przed zmęczeniem.
// Płytka woda (watery_tile): gasi płonące przedmioty i moby i moczy (u nas mokro = ujemne fire_stacks, bez wet_stacks).
// Różnice względem Shiptesta: spowolnienie z prędkości pola (slowdown), a nie z modyfikatorów prędkości; status pływania
// liczy co 5 s bez seconds_between_ticks (nasze status_effect nie podaje czasu).

/datum/element/swimming_tile
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// Koszt staminy wejścia na pole
	var/stamina_entry_cost
	/// Obrażenia tlenowe co tik u tonącego
	var/ticking_oxy_damage
	/// Szansa, że krok męczy pływaka
	var/exhaust_swimmer_prob
	/// Moby w wodzie na polach z tym elementem
	var/list/mob/living/swimmers = list()

/datum/element/swimming_tile/Attach(turf/target, stamina_entry_cost = 7, ticking_oxy_damage = 2, exhaust_swimmer_prob = 30)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	src.stamina_entry_cost = stamina_entry_cost
	src.ticking_oxy_damage = ticking_oxy_damage
	src.exhaust_swimmer_prob = exhaust_swimmer_prob
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(enter_water))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(out_of_water))
	for(var/mob/living/drownee in target)
		enter_water(target, drownee)

/datum/element/swimming_tile/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	for(var/mob/living/dry_guy in source)
		out_of_water(source, dry_guy)
	return ..()

/datum/element/swimming_tile/Destroy(force)
	swimmers = null
	return ..()

/datum/element/swimming_tile/proc/enter_water(atom/source, mob/living/swimmer)
	SIGNAL_HANDLER
	if(!istype(swimmer) || QDELETED(swimmer))
		return
	if(HAS_TRAIT(swimmer, TRAIT_IMMERSED))
		dip_in(swimmer)
	if(swimmer in swimmers)
		return
	RegisterSignal(swimmer, SIGNAL_ADDTRAIT(TRAIT_IMMERSED), PROC_REF(dip_in))
	RegisterSignal(swimmer, COMSIG_PARENT_QDELETING, PROC_REF(on_swimmer_del))
	swimmers |= swimmer

/datum/element/swimming_tile/proc/out_of_water(atom/source, mob/living/landlubber)
	SIGNAL_HANDLER
	if(!(landlubber in swimmers))
		return
	// Krok na kolejne pole głębokiej wody: dalej płynie
	var/turf/new_turf = landlubber.loc
	if(isturf(new_turf) && new_turf != source && (landlubber in new_turf) && istype(new_turf, /turf/open/water/planet))
		var/turf/open/water/planet/water = new_turf
		if(water.is_swimming_tile)
			return
	UnregisterSignal(landlubber, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSED), COMSIG_PARENT_QDELETING))
	swimmers -= landlubber
	landlubber.remove_status_effect(/datum/status_effect/swimming)

/datum/element/swimming_tile/proc/on_swimmer_del(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(SIGNAL_ADDTRAIT(TRAIT_IMMERSED), COMSIG_PARENT_QDELETING))
	swimmers -= source

/// Pływak naprawdę jest w wodzie: zmęczenie przy wejściu i status pływania
/datum/element/swimming_tile/proc/dip_in(mob/living/floater)
	SIGNAL_HANDLER
	if(!floater.buckled && prob(exhaust_swimmer_prob))
		var/gravity_modifier = floater.has_gravity() > STANDARD_GRAVITY ? 2 : 1
		floater.apply_damage(clamp(stamina_entry_cost * gravity_modifier, 1, 100), STAMINA)
	floater.apply_status_effect(/datum/status_effect/swimming, ticking_oxy_damage)

/// Status pływania: u leżących i małych mobów w głębokiej wodzie tonięcie co tik
/datum/status_effect/swimming
	id = "swimming"
	alert_type = null
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5 SECONDS
	/// Obrażenia tlenowe co tik tonięcia
	var/oxygen_per_interval = 2
	/// Szansa na utratę oddechu przy tonięciu
	var/drowning_process_probability = 20

/datum/status_effect/swimming/on_creation(mob/living/new_owner, ticking_oxy_damage = 2)
	oxygen_per_interval = ticking_oxy_damage
	return ..()

/datum/status_effect/swimming/on_apply()
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED), PROC_REF(stop_swimming))
	return TRUE

/datum/status_effect/swimming/on_remove()
	UnregisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_IMMERSED))

/datum/status_effect/swimming/tick()
	drown()

/// Czy właściciel tonie (leży albo jest mały, oddycha i nie ma butli)
/datum/status_effect/swimming/proc/is_drowning()
	if(ismob(owner.buckled))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NOBREATH))
		return FALSE
	if(owner.mob_size >= MOB_SIZE_HUMAN && (owner.mobility_flags & MOBILITY_STAND))
		return FALSE
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		if(carbon_owner.internal)
			return FALSE
	if(isbasicmob(owner))
		var/mob/living/basic/basic_owner = owner
		if(!basic_owner.unsuitable_atmos_damage)
			return FALSE
	return TRUE

/datum/status_effect/swimming/proc/drown()
	if(!is_drowning())
		return
	var/gravity_modifier = owner.has_gravity() > STANDARD_GRAVITY ? 2 : 1
	owner.apply_damage(oxygen_per_interval * (tick_interval / 10), OXY)
	if(prob(drowning_process_probability * gravity_modifier))
		owner.losebreath += oxygen_per_interval
	if(prob(20))
		to_chat(owner, span_userdanger("Toniesz! Woda zalewa ci nos i usta!"))

/datum/status_effect/swimming/proc/stop_swimming()
	SIGNAL_HANDLER
	qdel(src)

/// Płytka woda: gasi i moczy wszystko, co do niej wpadnie
/datum/element/watery_tile
	element_flags = ELEMENT_DETACH

/datum/element/watery_tile/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(enter_water))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(out_of_water))
	for(var/atom/movable/movable as anything in target)
		enter_water(target, movable)

/datum/element/watery_tile/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	for(var/mob/living/living_mob in source)
		living_mob.remove_status_effect(/datum/status_effect/watery_tile_wetness)
	return ..()

/datum/element/watery_tile/proc/enter_water(atom/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(QDELETED(entered) || entered.movement_type & (FLYING | FLOATING))
		return
	if(isobj(entered))
		var/obj/target = entered
		target.extinguish()
	if(!isliving(entered))
		return
	var/mob/living/our_mob = entered
	our_mob.adjust_fire_stacks(-3)
	our_mob.apply_status_effect(/datum/status_effect/watery_tile_wetness)

/datum/element/watery_tile/proc/out_of_water(atom/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/turf/new_turf = gone.loc
	if(isturf(new_turf) && istype(new_turf, /turf/open/water/planet))
		return
	var/mob/living/living_mob = gone
	living_mob.remove_status_effect(/datum/status_effect/watery_tile_wetness)

/// Kto stoi w wodzie, moknie co sekundę
/datum/status_effect/watery_tile_wetness
	id = "watery_tile_wetness"
	alert_type = null
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/watery_tile_wetness/tick()
	owner.adjust_fire_stacks(-1)
