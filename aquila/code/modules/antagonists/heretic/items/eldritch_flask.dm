// An unholy water flask, but for heretics.
// Heals heretics, harms non-heretics. Pretty much identical.
/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Trująca dla ciasnych umysłów, a orzeźwiająca dla tych, którzy znają to, co poza."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	icon_state = "eldritch_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)
	fill_icon_thresholds = null

// Unique bottle that lets you instantly draw blood from a victim
/obj/item/reagent_containers/glass/phylactery
	name = "phylactery of damnation"
	desc = "Służy do kradzieży krwi przyszłym ofiarom. Prawym przyciskiem (w intencjach: na rozbrajaniu) pobierasz krew, nawet z daleka."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	icon_state = "phylactery"
	possible_transfer_amounts = list(5)
	amount_per_transfer_from_this = 5
	volume = 10
	fill_icon_thresholds = null
	/// Bazowy stan ikony
	var/phylactery_icon_state = "phylactery"
	/// Cooldown before you can steal blood again
	COOLDOWN_DECLARE(drain_cooldown)

/obj/item/reagent_containers/glass/phylactery/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!isliving(target) || get_dist(user, target) > 30)
		return
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, drain_cooldown))
		user.balloon_alert(user, "nie tak szybko!")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/mob/living/living_target = target
	if(living_target == user)
		return
	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[src] jest pełne."))
		return
	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		to_chat(user, span_warning("Nie udaje ci się pobrać krwi od [living_target]!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		to_chat(living_target, span_warning("Czujesz, jak jakaś siła próbuje ukraść ci krew, ale zostaje odparta!"))
		return
	var/drawn_amount = min(reagents.maximum_volume - reagents.total_volume, 5)
	if(living_target.transfer_blood_to(src, drawn_amount))
		to_chat(user, span_notice("Pobierasz próbkę krwi od [living_target]."))
		to_chat(living_target, span_warning("Czujesz lekkie ukłucie!"))
		COOLDOWN_START(src, drain_cooldown, 5 SECONDS)
		playsound(src, 'aquila/sound/effects/chemistry/catalyst.ogg', 20, TRUE, SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)
	else
		to_chat(user, span_warning("Nie udaje ci się pobrać krwi od [living_target]!"))
	update_icon()

/obj/item/reagent_containers/glass/phylactery/update_icon_state()
	switch(reagents?.total_volume)
		if(0.1 to 5)
			icon_state = "[phylactery_icon_state]_1"
		if(5.1 to INFINITY)
			icon_state = "[phylactery_icon_state]_2"
		else
			icon_state = phylactery_icon_state
	return ..()

// Funny potion that is basically an aheal. The downside is that it puts you to sleep for a minute.
/obj/item/ether
	name = "ether of the newborn"
	desc = "Flaszka mdlącego, gęstego, zielonego płynu. W pełni przywraca ciało, a potem zapada się w pogłębiony sen na pełną minutę."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	icon_state = "poison_flask"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ether/attack_self(mob/living/user, modifiers)
	. = ..()
	if(!isliving(user))
		return
	user.revive(full_heal = TRUE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
		for(var/datum/disease/disease as anything in carbon_user.diseases)
			disease.cure(FALSE)
		for(var/obj/item/implant/to_remove in carbon_user.implants)
			to_remove.removed(carbon_user)
			qdel(to_remove)

	user.apply_status_effect(/datum/status_effect/eldritch_sleep)
	user.SetSleeping(60 SECONDS)
	qdel(src)

/datum/status_effect/eldritch_sleep
	id = "eldritch_sleep"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_sleep
	show_duration = TRUE
	remove_on_fullheal = TRUE
	/// List of traits our drinker gets while they are asleep
	var/list/sleeping_traits = list(TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT)

/datum/status_effect/eldritch_sleep/on_apply()
	. = ..()
	owner.add_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.SetStasis(TRUE)

/datum/status_effect/eldritch_sleep/on_remove()
	owner.SetSleeping(0) // Wake up bookworm, we have some heathens to burn
	owner.remove_traits(sleeping_traits, TRAIT_STATUS_EFFECT(id))
	owner.reagents?.remove_all(100) // If someone gives you over 100 units of poison while you sleep then you deserve this L
	owner.SetStasis(FALSE)

/atom/movable/screen/alert/status_effect/eldritch_sleep
	name = "Eldritch Slumber"
	desc = "Czujesz nieopisane ciepło, które cię chroni..."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "eldritch_slumber"
