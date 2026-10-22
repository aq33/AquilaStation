// AQUILA - warianty naszych mutacji z Monkestation2.0
// (code/datums/mutations/fire_breath.dm, matter_eater.dm, species/oozeling.dm)

/datum/mutation/firebreath/unstable
	name = "Unstable Fire Breath"
	desc = "An unstable mutation that gives subjects the ability to make fire in their lungs and expel it. It is more unstable than lizards native fire breath."
	locked = TRUE
	instability = 50
	conflicts = list(/datum/mutation/firebreath)

// U nas Matter Eater to /datum/mutation/vore
/datum/mutation/vore/syndicate
	name = "Refined Matter Eater"
	desc = "Allows the subject to eat just about anything without harm. This seems to be a strain that was marked as too dangerous by Nanotrasen and thus is outlawed."
	locked = TRUE
	instability = 20
	conflicts = list(/datum/mutation/vore)

// U nas Acidic Hands to /datum/mutation/acidooze (tylko oozelingi). Ta wersja jest dla każdego i działa na nowym systemie zaklęć.
/datum/mutation/acidooze/unstable
	name = "Unstable Acidic Hands"
	desc = "Allows a host to metabolize some of their blood into acid, concentrated on their hands. This strain is more unstable than the one found on oozelings."
	text_gain_indication = "<span class='notice'>Czujesz, jak moc spływa do twoich dłoni.</span>"
	text_lose_indication = "<span class='notice'>Energia w twoich dłoniach słabnie.</span>"
	difficulty = 16
	instability = 50
	power = null
	action_path = /datum/action/cooldown/spell/touch/monke_acid
	species_allowed = list()
	conflicts = list(/datum/mutation/acidooze)
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/acidooze/unstable/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	update_power()

/datum/mutation/acidooze/unstable/modify()
	..()
	update_power()

/datum/mutation/acidooze/unstable/proc/update_power()
	var/datum/action/cooldown/spell/touch/monke_acid/acid = action_power
	if(!istype(acid))
		return
	acid.acid_volume = initial(acid.acid_volume) * GET_MUTATION_POWER(src)
	acid.blood_cost = initial(acid.blood_cost) * GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/touch/monke_acid
	name = "Acid Touch"
	desc = "Concentrate to move acid into your hand, using some of your blood."
	button_icon_state = "summons"
	sound = 'sound/effects/bubbles.ogg'
	cooldown_time = 10 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	hand_path = /obj/item/melee/spell_hand/monke_acid
	draw_message = "<span class='notice'>Wydzielasz kwas do dłoni.</span>"
	drop_message = "<span class='notice'>Pozwalasz, by kwas w twojej dłoni się rozwiał.</span>"
	/// Ile kwasu nakładamy
	var/acid_volume = 15
	/// Ile krwi kosztuje użycie dłoni
	var/blood_cost = 20

/datum/action/cooldown/spell/touch/monke_acid/is_valid_target(atom/cast_on)
	return isatom(cast_on)

/// Skuty może przepalić kajdanki - wtedy nie blokują go AB_CHECK_HANDS_BLOCKED ani brak MOBILITY_USE
/datum/action/cooldown/spell/touch/monke_acid/proc/cuffed_and_conscious()
	var/mob/living/carbon/carbon_owner = owner
	return istype(carbon_owner) && carbon_owner.stat == CONSCIOUS && !isnull(carbon_owner.handcuffed)

/datum/action/cooldown/spell/touch/monke_acid/check_action_flags(feedback = FALSE)
	if(cuffed_and_conscious())
		return TRUE
	return ..()

/datum/action/cooldown/spell/touch/monke_acid/can_cast_spell(feedback = TRUE)
	if(cuffed_and_conscious())
		return TRUE
	return ..()

/// Skuty od razu przepala kajdanki zamiast dostawać dłoń
/datum/action/cooldown/spell/touch/monke_acid/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/carbon_caster = cast_on
	if(!istype(carbon_caster) || isnull(carbon_caster.handcuffed))
		return
	do_hand_hit(null, carbon_caster.handcuffed, carbon_caster)
	return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/touch/monke_acid/cast_on_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	if(caster.blood_volume < BLOOD_VOLUME_OKAY)
		to_chat(caster, "<span class='warning'>Twój kwas jest zbyt słabo stężony, by cokolwiek rozpuścić!</span>")
		return FALSE

	if(caster.handcuffed)
		var/obj/handcuffs = caster.handcuffed
		if(!istype(handcuffs))
			return FALSE
		caster.visible_message("<span class='warning'>Kwas w dłoniach [caster] gęstnieje i zaczyna przepalać [handcuffs]!</span>", \
			"<span class='notice'>Skupiasz się na przepaleniu więzów kwasem z dłoni...</span>")
		caster.blood_volume = max(caster.blood_volume - blood_cost, 0)
		addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), caster, handcuffs), 90 SECONDS / max(acid_volume, 1)) // domyślnie 6 sekund
		return TRUE

	if(victim.acid_act(50, acid_volume))
		caster.visible_message("<span class='warning'>[caster] rozsmarowuje kwas z dłoni po [victim]!</span>")
		caster.blood_volume = max(caster.blood_volume - blood_cost, 0)
		return TRUE

	to_chat(caster, "<span class='notice'>Nie możesz tego rozpuścić.</span>")
	return TRUE

/datum/action/cooldown/spell/touch/monke_acid/proc/dissolve_handcuffs(mob/living/carbon/user, obj/cuffs)
	if(QDELETED(cuffs) || QDELETED(user) || user.handcuffed != cuffs)
		return
	user.visible_message("<span class='warning'>[cuffs] rozpuszczają się w kałużę skwierczącej mazi.</span>")
	qdel(cuffs)

/obj/item/melee/spell_hand/monke_acid
	name = "\improper acidic hand"
	desc = "This is kind of like when you drink acid to replenish your blood, only a lot less safe for others."
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	color = "#7FFF00"
	item_state = "fleshtostone"

/obj/item/melee/spell_hand/monke_acid/equipped(mob/user, slot)
	. = ..()
	// odwrócone celowo, jak w acidooze
	var/i = user.get_held_index_of_item(src)
	icon_state = (i % 2) ? "bloodhand_right" : "bloodhand_left"
