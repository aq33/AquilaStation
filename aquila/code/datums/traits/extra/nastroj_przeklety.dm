// Przeklęty (tg Cursed) z minimalną wersją /datum/component/omen.
// Z omenu tg zostały: groźne poślizgnięcia, lustra, samozapłon i wybuch ciała po śmierci.
// Pominięte (brak sygnałów u nas): zgniatanie przez śluzy, przewracające się automaty, porażenia przez lampy i spadanie z krawędzi.

/datum/quirk/cursed
	name = "Przeklęty"
	desc = "Ciąży na tobie klątwa pecha. Dużo częściej przytrafiają ci się wypadki i nieszczęścia. Nieszczęścia chodzą parami."
	icon = "cloud-showers-heavy"
	value = -2
	mob_trait = TRAIT_CURSED
	gain_text = "<span class='danger'>Czujesz, że to będzie zły dzień.</span>"
	lose_text = "<span class='notice'>Czujesz, że to będzie dobry dzień.</span>"
	medical_record_text = "Pacjent ma przeklętego pecha."

/datum/quirk/cursed/add()
	quirk_holder.AddComponent(/datum/component/omen, null, INFINITY, 0.3, 0.25, FALSE, CALLBACK(src, PROC_REF(on_death)))

/datum/quirk/cursed/remove()
	qdel(quirk_holder.GetComponent(/datum/component/omen))

/datum/quirk/cursed/proc/on_death(datum/component/omen/omen)
	var/mob/living/cursed = omen.parent
	if(!iscarbon(cursed))
		cursed.gib()
		return
	// Nie wybucha przypięty do łóżka stazy
	if(istype(cursed.buckled, /obj/machinery/stasis))
		return
	omen.death_explode(cursed)
	// Jak w tg (skip_head): głowa z mózgiem zostaje, żeby dało się wskrzesić
	var/mob/living/carbon/cursed_carbon = cursed
	for(var/obj/item/bodypart/limb as anything in cursed_carbon.bodyparts)
		if(limb.body_zone == BODY_ZONE_HEAD || limb.body_zone == BODY_ZONE_CHEST)
			continue
		limb.drop_limb()
		limb.throw_at(get_edge_target_turf(cursed, pick(GLOB.alldirs)), rand(1, 3), 5)
	cursed.spawn_gibs()

/**
 * Omen: zły dzień dla tego, kto go nosi. Kolejne wypadki przy ruchu, poślizgnięciach i co tick życia.
 * Znika po zużyciu wszystkich wypadków albo po śmierci (chyba że jest nieskończony).
 */
/datum/component/omen
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Przedmiot, który sprowadził omen (spala się, gdy omen zniknie)
	var/obj/vessel
	/// Ile wypadków zostało; INFINITY = bez końca
	var/incidents_left = INFINITY
	/// Mnożnik szansy na wypadek
	var/luck_mod = 1
	/// Mnożnik obrażeń z wypadków
	var/damage_mod = 1
	/// Czy błogosławieństwo kapelana zdejmuje omen
	var/bless_fixable = TRUE
	/// Wywoływane przy śmierci
	var/datum/callback/on_death

/datum/component/omen/Initialize(obj/vessel, incidents_left = INFINITY, luck_mod = 1, damage_mod = 1, bless_fixable = TRUE, datum/callback/on_death)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(istype(vessel))
		src.vessel = vessel
		RegisterSignal(vessel, COMSIG_PARENT_QDELETING, PROC_REF(vessel_qdeleting))
	src.incidents_left = incidents_left
	src.luck_mod = luck_mod
	src.damage_mod = damage_mod
	src.bless_fixable = bless_fixable
	src.on_death = on_death
	ADD_TRAIT(parent, TRAIT_CURSED, REF(src))

/datum/component/omen/InheritComponent(datum/component/omen/new_comp, i_am_original, obj/vessel, incidents_left, luck_mod, damage_mod)
	if(src.incidents_left > incidents_left)
		return
	src.incidents_left = incidents_left
	if(src.luck_mod > luck_mod)
		src.luck_mod += luck_mod * 0.5
	if(src.damage_mod > damage_mod)
		src.damage_mod += damage_mod * 0.5

/datum/component/omen/Destroy(force, silent)
	var/mob/living/person = parent
	REMOVE_TRAIT(person, TRAIT_CURSED, REF(src))
	if(!QDELETED(person))
		to_chat(person, "<span class='nicegreen'>Czujesz, jak spada z ciebie straszliwy omen!</span>")
	if(vessel)
		vessel.visible_message("<span class='warning'>[vessel] spala się w złowrogim błysku, zabierając ze sobą złą energię...</span>")
		UnregisterSignal(vessel, COMSIG_PARENT_QDELETING)
		vessel.burn()
		vessel = null
	on_death = null
	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_ON_CARBON_SLIP, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_ON_CARBON_SLIP, COMSIG_LIVING_DEATH, COMSIG_LIVING_LIFE))

/datum/component/omen/proc/consume_omen()
	if(incidents_left == INFINITY)
		return
	incidents_left--
	if(incidents_left < 1)
		qdel(src)

/// Rzut na wypadek; gdy ktoś (nie AFK) patrzy, szansa się podwaja
/datum/component/omen/proc/roll_for_accident(base_chance = 4)
	var/chance = base_chance * luck_mod
	for(var/mob/viewer in viewers(parent))
		if(viewer.client && !viewer.client.is_afk())
			chance *= 2
			break
	return prob(chance)

/datum/component/omen/proc/on_life(mob/living/source)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	if(roll_for_accident(0.001))
		spontaneous_combustion()

/// Nagły samozapłon
/datum/component/omen/proc/spontaneous_combustion()
	var/mob/living/target = parent
	target.adjust_fire_stacks(20)
	if(!target.IgniteMob())
		return FALSE
	target.visible_message("<span class='danger'>[target] nagle staje w płomieniach!</span>", "<span class='userdanger'>Nagle stajesz w płomieniach!</span>")
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	consume_omen()
	return TRUE

/datum/component/omen/proc/check_accident(mob/living/source)
	SIGNAL_HANDLER
	if(locate(/obj/structure/mirror) in get_turf(source))
		INVOKE_ASYNC(src, PROC_REF(mirror_interaction)) // rozbicie lustra może spać

/// Spojrzenie w lustro przy przejściu obok
/datum/component/omen/proc/mirror_interaction()
	var/mob/living/our_guy = parent
	var/obj/structure/mirror/evil_mirror = locate() in get_turf(our_guy)
	if(isnull(evil_mirror) || !roll_for_accident(10))
		return FALSE

	to_chat(our_guy, "<span class='warning'>Przechodzisz obok lustra i zerkasz w nie...</span>")
	if(evil_mirror.broken)
		to_chat(our_guy, "<span class='notice'>...i jakoś czujesz, że masz szczęście.</span>")
		return TRUE

	switch(rand(1, 5))
		if(1)
			to_chat(our_guy, "<span class='warning'>...lustro rozpada się na milion kawałków! Czy to znaczy, że masz jeszcze większego pecha?</span>")
			evil_mirror.take_damage(evil_mirror.max_integrity, BRUTE, "melee", FALSE)
			if(roll_for_accident(20))
				luck_mod += 0.25
				damage_mod += 0.25
		if(2 to 3)
			to_chat(our_guy, "<span class='big hypnophrase'>...o Boże, nie widzisz swojego odbicia!!</span>")
			INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")
		if(4 to 5)
			to_chat(our_guy, "<span class='userdanger'>Widzisz swoje odbicie, ale ono uśmiecha się złowrogo i patrzy prosto na ciebie!</span>")
			INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), "scream")

	our_guy.Jitter(25)
	if(roll_for_accident(2) && iscarbon(our_guy))
		to_chat(our_guy, "<span class='warning'>Ten obrót spraw zupełnie cię zszokował!</span>")
		to_chat(our_guy, "<span class='userdanger'>Łapiesz się za serce!</span>")
		var/mob/living/carbon/carbon_guy = our_guy
		carbon_guy.set_heartattack(TRUE)

	consume_omen()
	return TRUE

/// Groźne poślizgnięcie: uderzenie głową
/datum/component/omen/proc/check_slip(mob/living/our_guy)
	SIGNAL_HANDLER
	if(!our_guy.get_bodypart(BODY_ZONE_HEAD) || !roll_for_accident(15))
		return
	playsound(our_guy, 'sound/effects/tableheadsmash.ogg', 90, TRUE)
	our_guy.visible_message("<span class='danger'>[our_guy] przy upadku bardzo mocno uderza się w głowę!</span>", "<span class='userdanger'>Przy upadku bardzo mocno uderzasz się w głowę!</span>")
	our_guy.apply_damage(75 * damage_mod, BRUTE, BODY_ZONE_HEAD)
	our_guy.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100 * damage_mod)
	consume_omen()

/datum/component/omen/proc/check_death(mob/living/our_guy)
	SIGNAL_HANDLER
	if(on_death)
		INVOKE_ASYNC(on_death, TYPE_PROC_REF(/datum/callback, Invoke), src) // rozrzucanie kończyn może spać
	if(incidents_left == INFINITY)
		return
	qdel(src)

/// Wybuch bez obrażeń: huk i trzęsienie kamer świadków
/datum/component/omen/proc/death_explode(mob/living/our_guy)
	playsound(our_guy, "explosion", 80, TRUE)
	for(var/mob/witness in view(2, our_guy))
		shake_camera(witness, 1 SECONDS, 2)

/datum/component/omen/proc/vessel_qdeleting(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(vessel, COMSIG_PARENT_QDELETING)
	vessel = null

/// Sygnał poślizgnięcia dla omenu (tg: COMSIG_ON_CARBON_SLIP z /turf/open/handle_slip)
/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	. = ..()
	if(.)
		SEND_SIGNAL(src, COMSIG_ON_CARBON_SLIP)
