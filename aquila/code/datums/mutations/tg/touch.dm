// AQUILA - port z tgstation (code/datums/mutations/touch.dm, Mending Touch)
// oraz wariant Corrupted Mending Touch z Monkestation (code/datums/mutations/touch.dm)

/datum/mutation/lay_on_hands
	name = "Mending Touch"
	desc = "The subject gains the ability to lay their hands on others to transfer a small amount of their injuries to themselves."
	quality = POSITIVE
	locked = FALSE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Twoje dłonie wydają się błogosławione!</span>"
	text_lose_indication = "<span class='notice'>Twoje dłonie nie są już błogosławione.</span>"
	action_path = /datum/action/cooldown/spell/touch/lay_on_hands
	instability = 35
	energy_coeff = 1
	power_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/lay_on_hands/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/lay_on_hands)

/datum/mutation/lay_on_hands/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	update_power()

/datum/mutation/lay_on_hands/modify()
	. = ..()
	update_power()

/datum/mutation/lay_on_hands/proc/update_power()
	var/datum/action/cooldown/spell/touch/lay_on_hands/to_modify = action_power
	if(!istype(to_modify))
		return
	// Wzmacniacz przenosi więcej (1.5), synchronizator połowę bólu (0.5)
	to_modify.power_coefficient = GET_MUTATION_POWER(src)
	to_modify.synchronizer_coefficient = GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/touch/lay_on_hands
	name = "Mending Touch"
	desc = "Możesz położyć dłonie na innych i przejąć na siebie część ich obrażeń. \
		Z jakiegoś powodu ta moc nie działa dobrze na nieumarłych."
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "mending_touch"
	sound = 'sound/magic/staff_healing.ogg'
	cooldown_time = 12 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE
	hand_path = /obj/item/melee/spell_hand/lay_on_hands
	draw_message = "<span class='notice'>Przygotowujesz dłoń, by przejąć na siebie cudze rany.</span>"
	drop_message = "<span class='notice'>Opuszczasz dłoń.</span>"
	/// Mnożnik leczenia (albo obrażeń przy karceniu)
	var/heal_multiplier = 1
	/// Mnożnik bólu, który przejmujemy
	var/pain_multiplier = 1
	/// Ikona promienia
	var/beam_icon = "blood"
	/// Współczynnik mocy z mutacji
	var/power_coefficient = 1
	/// Współczynnik synchronizacji z mutacji
	var/synchronizer_coefficient = 1
	/// Monkestation: karcenie zawsze w wersji "złej"
	var/always_evil_smite = FALSE

/datum/action/cooldown/spell/touch/lay_on_hands/create_hand(mob/living/carbon/cast_on)
	. = ..()
	if(!.)
		return
	var/obj/item/bodypart/transfer_limb = cast_on.get_active_hand()
	if(transfer_limb && !IS_ORGANIC_LIMB(transfer_limb))
		to_chat(cast_on, "<span class='notice'>Nie umiesz przepuścić mocy leczenia przez nieorganiczną dłoń.</span>")
		remove_hand(cast_on, reset_cooldown_after = TRUE)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/lay_on_hands/cast_on_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/mendicant)
	var/mob/living/hurtguy = victim
	heal_multiplier = initial(heal_multiplier) * power_coefficient
	pain_multiplier = initial(pain_multiplier) * synchronizer_coefficient
	var/peaceful_message

	var/hurt_this_guy = determine_if_this_hurts_instead(mendicant, hurtguy)
	if(hurt_this_guy && (HAS_TRAIT(mendicant, TRAIT_PACIFISM) || !mendicant.combat_mode))
		mendicant.balloon_alert(mendicant, "zraniłbyś [hurtguy]!")
		return FALSE
	if(hurt_this_guy)
		return by_gods_light_i_smite_you(mendicant, hurtguy, heal_multiplier)

	// Laska Asklepiosa (przysięga Hipokratesa) wzmacnia leczenie
	if(mendicant.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		heal_multiplier *= 2
		pain_multiplier *= 0.5
		peaceful_message = "<span class='boldnotice'>Czujesz, jak magia Laski Asklepiosa wspiera twoje starania!</span>"
		beam_icon = "sendbeam"
	else if(HAS_TRAIT(mendicant, TRAIT_PACIFISM))
		heal_multiplier *= 1.75
		peaceful_message = "<span class='boldnotice'>Twoja łagodna natura pomaga ci przejąć cały ból.</span>"

	var/success
	if(iscarbon(hurtguy))
		success = do_complicated_heal(mendicant, hurtguy, heal_multiplier, pain_multiplier)
	else
		success = do_simple_heal(mendicant, hurtguy, heal_multiplier, pain_multiplier)
	if(!success)
		beam_icon = initial(beam_icon)
		return FALSE

	if(peaceful_message)
		to_chat(mendicant, peaceful_message)

	if(hurtguy.fire_stacks > 0)
		mendicant.adjust_fire_stacks(hurtguy.fire_stacks * pain_multiplier)
		if(hurtguy.on_fire)
			mendicant.ignite_mob()
			hurtguy.extinguish_mob()

	mendicant.Beam(hurtguy, icon_state = beam_icon, time = 0.5 SECONDS)
	beam_icon = initial(beam_icon)
	hurtguy.update_damage_overlays()
	mendicant.update_damage_overlays()
	hurtguy.visible_message("<span class='notice'>[mendicant] kładzie dłonie na [hurtguy]!</span>", ignored_mobs = hurtguy)
	to_chat(hurtguy, "<span class='boldnotice'>[mendicant] kładzie na tobie dłonie i cię leczy!</span>")
	new /obj/effect/temp_visual/heal(get_turf(hurtguy), "#DDFFD3")
	return TRUE

/// Organiczne kończyny leczącego
/datum/action/cooldown/spell/touch/lay_on_hands/proc/get_organic_limbs(mob/living/carbon/mendicant)
	. = list()
	for(var/obj/item/bodypart/possible_limb as anything in mendicant.bodyparts)
		if(IS_ORGANIC_LIMB(possible_limb))
			. += possible_limb

/datum/action/cooldown/spell/touch/lay_on_hands/proc/do_simple_heal(mob/living/carbon/mendicant, mob/living/hurtguy, heal_multiplier, pain_multiplier)
	. = FALSE
	var/brute_to_heal = min(hurtguy.getBruteLoss(), 35 * heal_multiplier)
	var/burn_to_heal = min(hurtguy.getFireLoss(), (35 - brute_to_heal) * heal_multiplier)
	var/list/mendicant_organic_limbs = get_organic_limbs(mendicant)
	if(!length(mendicant_organic_limbs))
		mendicant.balloon_alert(mendicant, "brak organicznych kończyn!")
		return
	if(!brute_to_heal && !burn_to_heal)
		hurtguy.balloon_alert(mendicant, "nie jest ranny!")
		return
	var/obj/item/bodypart/mendicant_transfer_limb = mendicant.get_active_hand()
	if(!(mendicant_transfer_limb in mendicant_organic_limbs))
		mendicant_transfer_limb = pick(mendicant_organic_limbs)
	mendicant_transfer_limb.receive_damage(brute_to_heal * pain_multiplier, burn_to_heal * pain_multiplier)
	if(brute_to_heal)
		hurtguy.adjustBruteLoss(-brute_to_heal)
	if(burn_to_heal)
		hurtguy.adjustFireLoss(-burn_to_heal)
	return TRUE

/datum/action/cooldown/spell/touch/lay_on_hands/proc/do_complicated_heal(mob/living/carbon/mendicant, mob/living/carbon/hurtguy, heal_multiplier, pain_multiplier)
	. = FALSE
	var/list/mendicant_organic_limbs = get_organic_limbs(mendicant)
	var/healing_budget = 35 * heal_multiplier
	for(var/obj/item/bodypart/affected_limb as anything in hurtguy.bodyparts)
		if(!IS_ORGANIC_LIMB(affected_limb))
			continue
		var/obj/item/bodypart/mendicant_transfer_limb = mendicant.get_bodypart(affected_limb.body_zone)
		var/affected_limb_damage = affected_limb.brute_dam + affected_limb.burn_dam
		var/brute_damage = 0
		var/burn_damage = 0
		if(healing_budget >= affected_limb_damage)
			healing_budget -= affected_limb_damage
			brute_damage = affected_limb.brute_dam
			burn_damage = affected_limb.burn_dam
		else
			if(affected_limb.brute_dam > affected_limb.burn_dam)
				burn_damage = min(affected_limb.burn_dam, healing_budget / 2)
				brute_damage = healing_budget - burn_damage
			else
				brute_damage = min(affected_limb.brute_dam, healing_budget / 2)
				burn_damage = healing_budget - brute_damage
			healing_budget = 0
		if(brute_damage || burn_damage)
			. = TRUE
			affected_limb.heal_damage(brute_damage, burn_damage, 0, BODYTYPE_ORGANIC)
			if(mendicant_transfer_limb in mendicant_organic_limbs)
				mendicant_transfer_limb.receive_damage(brute_damage * pain_multiplier, burn_damage * pain_multiplier)
			else // nie mamy organicznej odpowiedniczki, rozkładamy obrażenia
				mendicant.take_overall_damage(brute_damage * pain_multiplier, burn_damage * pain_multiplier, 0, TRUE, BODYTYPE_ORGANIC)

		// Rany (lekki system Aquili) też przechodzą na leczącego
		if(mendicant_transfer_limb)
			for(var/datum/wound/iter_wound as anything in affected_limb.wounds)
				switch(iter_wound.severity)
					if(WOUND_SEVERITY_SEVERE)
						if(prob(50 * heal_multiplier))
							continue
					if(WOUND_SEVERITY_CRITICAL)
						if(heal_multiplier < 1.5 && prob(30 * heal_multiplier)) // krytyczne tylko ze wzmocnieniem
							continue
				if(mendicant_transfer_limb.get_wound(iter_wound.wound_type))
					continue
				. = TRUE
				var/datum/wound/moved_wound = new iter_wound.type()
				qdel(iter_wound)
				moved_wound.apply_wound(mendicant_transfer_limb)

		if(!healing_budget)
			break

	if(!can_share_blood(mendicant) || !can_share_blood(hurtguy))
		return

	var/max_blood_transfer = (BLOOD_VOLUME_NORMAL * 0.10) * heal_multiplier
	var/blood_compatible = (mendicant.dna.blood_type in get_safe_blood(hurtguy.dna.blood_type))
	// Za mało krwi u rannego: oddajemy swoją (zgodność grupy pomijamy, niezgodna lekko truje)
	if(hurtguy.blood_volume < BLOOD_VOLUME_NORMAL)
		var/amount_to_transfer = min(max_blood_transfer, BLOOD_VOLUME_NORMAL - hurtguy.blood_volume, mendicant.blood_volume)
		if(amount_to_transfer <= 0)
			return
		mendicant.blood_volume -= amount_to_transfer
		hurtguy.blood_volume += amount_to_transfer
		to_chat(mendicant, "<span class='notice'>Twoje żyły (i mózg) robią się lżejsze.</span>")
		. = TRUE
		if(!blood_compatible)
			hurtguy.adjustToxLoss((amount_to_transfer * 0.1) * pain_multiplier)
			to_chat(hurtguy, "<span class='notice'>Twoje żyły wydają się pełniejsze, ale trochę swędzą.</span>")
		else
			to_chat(hurtguy, "<span class='notice'>Twoje żyły wydają się pełniejsze!</span>")
		return

	if(hurtguy.blood_volume < BLOOD_VOLUME_MAXIMUM)
		return
	// Za dużo krwi u rannego: bierzemy nadmiar
	var/amount_to_receive = min(max_blood_transfer, hurtguy.blood_volume - BLOOD_VOLUME_MAXIMUM)
	if(amount_to_receive <= 0)
		return
	hurtguy.blood_volume -= amount_to_receive
	mendicant.blood_volume = min(mendicant.blood_volume + amount_to_receive, BLOOD_VOLUME_MAXIMUM)
	to_chat(hurtguy, "<span class='notice'>Twoje żyły nie są już tak nabrzmiałe.</span>")
	. = TRUE
	if(!blood_compatible)
		mendicant.adjustToxLoss((amount_to_receive * 0.1) * pain_multiplier)
		to_chat(mendicant, "<span class='notice'>Twoje żyły puchną i swędzą!</span>")
	else
		to_chat(mendicant, "<span class='notice'>Twoje żyły puchną!</span>")

/// Czy da się przelać zwykłą krew
/datum/action/cooldown/spell/touch/lay_on_hands/proc/can_share_blood(mob/living/carbon/target)
	if(!ishuman(target) || !target.dna?.species)
		return FALSE
	if((NOBLOOD in target.dna.species.species_traits) || HAS_TRAIT(target, TRAIT_NO_BLOOD))
		return FALSE
	return target.get_blood_id() == /datum/reagent/blood

/// tg: nieumarli i źli dostają zamiast leczenia. U nas nie ma TRAIT_EVIL ani sygnału COMSIG_ON_LAY_ON_HANDS.
/datum/action/cooldown/spell/touch/lay_on_hands/proc/determine_if_this_hurts_instead(mob/living/carbon/mendicant, mob/living/hurtguy)
	var/hurtguy_undead = (MOB_UNDEAD in hurtguy.mob_biotypes)
	var/mendicant_undead = (MOB_UNDEAD in mendicant.mob_biotypes)
	if(hurtguy_undead && mendicant_undead)
		return FALSE // solidarność nieumarłych
	return hurtguy_undead

/datum/action/cooldown/spell/touch/lay_on_hands/proc/by_gods_light_i_smite_you(mob/living/carbon/smiter, mob/living/target, smite_multiplier)
	var/our_smite_multiplier = smite_multiplier
	var/evil_smite = always_evil_smite
	var/divine_champion = smiter.mind?.holy_role >= HOLY_ROLE_PRIEST
	var/smite_text_to_target = "kładzie na tobie dłonie"

	if(divine_champion || HAS_TRAIT(smiter, TRAIT_SPIRITUAL))
		var/possible_deity = GLOB.deity || (evil_smite ? "Szatana" : "Boga")
		if(ishuman(smiter))
			if(evil_smite)
				INVOKE_ASYNC(smiter, TYPE_PROC_REF(/atom/movable, say), "W mrocznym imieniu [possible_deity] ROZKAZUJĘ CI ZGINĄĆ!!!", forced = "compelled by the power of their deity")
			else
				INVOKE_ASYNC(smiter, TYPE_PROC_REF(/atom/movable, say), "Mocą [possible_deity] KARZĘ CIĘ!!!", forced = "compelled by the power of their deity")
		our_smite_multiplier *= divine_champion ? 5 : 1

	if(evil_smite)
		target.visible_message("<span class='warning'>[smiter] pstryka palcami przed twarzą [target], a ciało [target] wykręca się gwałtownie pod wpływem niewidzialnej siły!</span>")
		target.take_overall_damage(10 * our_smite_multiplier)
		// tg spowalnia (stagger), u nas zmęczenie
		target.adjustStaminaLoss(15 * our_smite_multiplier)
		INVOKE_ASYNC(smiter, TYPE_PROC_REF(/mob, emote), "snap")
		smite_text_to_target = "miażdży cię psychicznie pstryknięciem palców"
	else
		target.visible_message("<span class='warning'>[smiter] kładzie dłonie na [target], ale rozdziera [target] oślepiająca energia!</span>")
		target.take_overall_damage(0, 10 * our_smite_multiplier)
		target.adjust_fire_stacks(3 * our_smite_multiplier)
		target.ignite_mob()

	target.update_damage_overlays()
	to_chat(target, "<span class='userdanger'>[smiter] [smite_text_to_target] i cię rani!</span>")
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	var/obj/effect/temp_visual/explosion/smite_visual = new(get_turf(target))
	smite_visual.color = evil_smite ? LIGHT_COLOR_BLOOD_MAGIC : LIGHT_COLOR_HOLY_MAGIC
	return TRUE

/obj/item/melee/spell_hand/lay_on_hands
	name = "mending touch"
	desc = "Inaczej niż w ulubionych grach planszowych, nie możesz rzucić tego na siebie."
	icon = 'aquila/icons/mutations/tg/items.dmi'
	icon_state = "greyscale"
	item_state = "greyscale"
	lefthand_file = 'aquila/icons/mutations/tg/touch_lefthand.dmi'
	righthand_file = 'aquila/icons/mutations/tg/touch_righthand.dmi'
	color = "#DDFFD3"
	item_flags = ABSTRACT | DROPDEL

// --- Monkestation: Corrupted Mending Touch ---

/datum/mutation/lay_on_hands/syndicate
	name = "Corrupted Mending Touch"
	desc = "A genetic sequence thats highly corrupted sharing some nucleotides with mending touch, use is not advised."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Twoja dłoń wydaje się dziwna.</span>"
	text_lose_indication = "<span class='notice'>Twoja dłoń znów jest zwyczajna.</span>"
	action_path = /datum/action/cooldown/spell/touch/lay_on_hands/syndicate
	instability = 50

/datum/action/cooldown/spell/touch/lay_on_hands/syndicate
	name = "Corrupted Mending Touch"
	desc = "Możesz położyć dłonie na innych i przejąć na siebie część ich obrażeń. \
		Ta wersja mutacji pozwala ukarać każdego, komu chcesz zrobić KRZYWDĘ (tryb walki)."
	button_icon_state = "corrupted_mending_touch"
	always_evil_smite = TRUE

/datum/action/cooldown/spell/touch/lay_on_hands/syndicate/determine_if_this_hurts_instead(mob/living/carbon/mendicant, mob/living/hurtguy)
	if(HAS_TRAIT(mendicant, TRAIT_PACIFISM))
		return FALSE
	. = ..()
	if(!. && mendicant.combat_mode)
		return TRUE
