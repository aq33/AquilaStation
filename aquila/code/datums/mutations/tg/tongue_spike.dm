// AQUILA - port z tgstation (code/datums/mutations/tongue_spike.dm)
// tg ma /datum/embedding, u nas embedding to lista na przedmiocie + /datum/component/embedded.

/datum/mutation/tongue_spike
	name = "Tongue Spike"
	desc = "The subject gains the ability to voluntary shoot their tongue out as a deadly weapon."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz, że mógłbyś rzucić swoim głosem.</span>"
	instability = 5
	action_path = /datum/action/cooldown/spell/tongue_spike
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/cooldown/spell/tongue_spike
	name = "Launch spike"
	desc = "Wystrzel język w kierunku, w którym patrzysz. Wbija się w cel i rani go, dopóki ktoś go nie wyciągnie."
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "spike"
	cooldown_time = 1 SECONDS
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	/// Co wystrzeliwujemy
	var/spike_path = /obj/item/hardened_spike

/datum/action/cooldown/spell/tongue_spike/is_valid_target(atom/cast_on)
	return iscarbon(cast_on)

/datum/action/cooldown/spell/tongue_spike/cast(mob/living/carbon/cast_on)
	. = ..()
	if(HAS_TRAIT(cast_on, TRAIT_NODISMEMBER))
		to_chat(cast_on, "<span class='notice'>Skupiasz się z całych sił, ale nic się nie dzieje.</span>")
		return
	var/obj/item/organ/tongue/to_fire = cast_on.getorganslot(ORGAN_SLOT_TONGUE)
	if(!to_fire)
		to_chat(cast_on, "<span class='notice'>Nie masz języka, którym mógłbyś strzelić!</span>")
		return
	to_fire.Remove(cast_on, TRUE)
	var/obj/item/hardened_spike/spike = new spike_path(get_turf(cast_on), cast_on)
	to_fire.forceMove(spike)
	spike.throw_at(get_edge_target_turf(cast_on, cast_on.dir), 14, 4, cast_on)

/obj/item/hardened_spike
	name = "biomass spike"
	desc = "Hardened biomass, shaped into a spike. Very pointy!"
	icon = 'aquila/icons/mutations/tg/items.dmi'
	icon_state = "tonguespike"
	force = 2
	throwforce = 25
	throw_speed = 4
	w_class = WEIGHT_CLASS_SMALL
	sharpness = IS_SHARP
	embedding = list("embed_chance" = 100, "fall_chance" = 0, "pain_mult" = 15, "ignore_throwspeed_threshold" = TRUE)
	/// Kto wystrzelił język
	var/datum/weakref/fired_by_ref
	/// W kim tkwimy
	var/datum/weakref/embedded_in_ref

/obj/item/hardened_spike/Initialize(mapload, mob/living/carbon/source)
	. = ..()
	fired_by_ref = WEAKREF(source)
	addtimer(CALLBACK(src, PROC_REF(check_morph)), 5 SECONDS)

/obj/item/hardened_spike/proc/check_morph()
	// Nie wbił się, więc wraca do postaci języka
	if(!embedded_in_ref?.resolve())
		morph_back()

/obj/item/hardened_spike/proc/morph_back()
	if(QDELETED(src))
		return
	visible_message("<span class='warning'>[src] pęka i wykręca się, zmieniając kształt!</span>")
	var/turf/drop_turf = get_turf(src)
	for(var/obj/tongue in contents)
		tongue.forceMove(drop_turf)
	qdel(src)

/obj/item/hardened_spike/embedded(atom/embedded_target)
	. = ..()
	embedded_in_ref = WEAKREF(embedded_target)

/obj/item/hardened_spike/unembedded()
	embedded_in_ref = null
	morph_back()
	return TRUE

/datum/mutation/tongue_spike/chem
	name = "Chem Spike"
	desc = "The subject gains the ability to voluntary shoot their tongue out as biomass, allowing a long range transfer of chemicals."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Czujesz, że rzucając głosem mógłbyś naprawdę zbliżyć się do ludzi.</span>"
	instability = 10
	locked = TRUE
	action_path = /datum/action/cooldown/spell/tongue_spike/chem
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/action/cooldown/spell/tongue_spike/chem
	name = "Launch chem spike"
	desc = "Wystrzel język w kierunku, w którym patrzysz. Wbija się w cel i prawie go nie rani, \
		a dopóki w nim tkwi, możesz przelać mu swoje chemikalia."
	button_icon_state = "spikechem"
	spike_path = /obj/item/hardened_spike/chem

/obj/item/hardened_spike/chem
	name = "chem spike"
	desc = "Hardened biomass, shaped into... something."
	icon_state = "tonguespikechem"
	throwforce = 2
	embedding = list("embed_chance" = 100, "fall_chance" = 0, "pain_mult" = 0, "pain_chance" = 0, "jostle_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)
	/// Akcja przelewu dana strzelającemu
	var/datum/action/send_chems/chem_action

/obj/item/hardened_spike/chem/embedded(atom/embedded_target)
	. = ..()
	var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
	if(!istype(fired_by) || !isliving(embedded_target))
		return
	QDEL_NULL(chem_action)
	chem_action = new(src)
	chem_action.transferred_ref = WEAKREF(embedded_target)
	chem_action.Grant(fired_by)
	to_chat(fired_by, "<span class='notice'>Połączenie nawiązane! Użyj zdolności „Transfer Chemicals”, żeby przelać swoje chemikalia do połączonego celu!</span>")

/obj/item/hardened_spike/chem/Destroy()
	if(chem_action)
		var/mob/living/carbon/fired_by = fired_by_ref?.resolve()
		if(fired_by)
			to_chat(fired_by, "<span class='warning'>Połączenie zerwane!</span>")
		QDEL_NULL(chem_action)
	return ..()

/datum/action/send_chems
	name = "Transfer Chemicals"
	desc = "Przelej wszystkie swoje reagenty do osoby, w której tkwi chemiczny kolec. Jednorazowe."
	background_icon_state = "bg_spell"
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "spikechemswap"
	check_flags = AB_CHECK_CONSCIOUS
	/// Do kogo przelewamy
	var/datum/weakref/transferred_ref

/datum/action/send_chems/New(Target)
	. = ..()
	if(!istype(target, /obj/item/hardened_spike/chem))
		qdel(src)

/datum/action/send_chems/Trigger()
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner) || !owner.reagents)
		return FALSE
	var/mob/living/carbon/human/transferer = owner
	var/mob/living/carbon/human/transferred = transferred_ref?.resolve()
	if(!ishuman(transferred))
		return FALSE
	to_chat(transferred, "<span class='warning'>Czujesz delikatne ukłucie!</span>")
	transferer.reagents.trans_to(transferred, transferer.reagents.total_volume, transfered_by = transferer)
	var/obj/item/hardened_spike/chem/chem_spike = target
	transferred.visible_message("<span class='notice'>[chem_spike] wypada z [transferred]!</span>")
	// Kolec wraca do postaci języka i znika z rany
	chem_spike.morph_back()
	return TRUE
