// AQUILA - port z tgstation (code/datums/mutations/body.dm, /datum/mutation/headless)
// tg COMSIG_ATTEMPT_CARBON_ATTACH_LIMB podpięty nadpisaniami procedur (bez edycji rdzenia).

// --- tg COMSIG_ATTEMPT_CARBON_ATTACH_LIMB ---

/// Przyczepienie głowy (chirurgia, TRAIT_LIMBATTACHMENT, klonowanie itd.) można zablokować sygnałem
/obj/item/bodypart/head/attach_limb(mob/living/carbon/C, special)
	if(C && (SEND_SIGNAL(C, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH))
		// Głowa zostaje obok ciała zamiast zniknąć w nullspace
		if(!QDELETED(src))
			forceMove(C.drop_location())
		return FALSE
	return ..()

/// Odrastanie kończyn (pełne leczenie, rdzenie regeneracji) też pyta o zgodę
/mob/living/carbon/regenerate_limb(limb_zone, noheal)
	if(limb_zone == BODY_ZONE_HEAD && !get_bodypart(BODY_ZONE_HEAD))
		var/obj/item/bodypart/head/fake_head = /obj/item/bodypart/head
		if(SEND_SIGNAL(src, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, fake_head, TRUE) & COMPONENT_NO_ATTACH)
			return 0
	return ..()

// --- Mutacja ---

/datum/mutation/headless
	name = "H.A.R.S."
	desc = "Short for \"Head Allergic Rejection Syndrome\", the subject's body rejects the head, causing its brain to recede into the chest. \
		Reversing this mutation is very dangerous, though it will regenerate non-vital head organs."
	difficulty = 12 //pretty good for traitors
	quality = NEGATIVE //holy shit no eyes or tongue or ears
	text_gain_indication = "<span class='warning'>Coś jest nie tak.</span>"

/datum/mutation/headless/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE

	var/obj/item/organ/brain/brain = owner.getorganslot(ORGAN_SLOT_BRAIN)
	if(brain)
		// special + no_id_transfer: umysł zostaje w ciele, nikt nie umiera
		brain.Remove(owner, TRUE, TRUE)
		brain.zone = BODY_ZONE_CHEST
		brain.Insert(owner, TRUE, TRUE)

	var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		owner.visible_message("<span class='warning'>Głowa [owner] rozbryzguje się z obrzydliwym chrupnięciem!</span>", ignored_mobs = list(owner))
		new /obj/effect/gibspawner/generic(get_turf(owner), owner)
		head.drop_limb()
		head.drop_organs()
		qdel(head)
		owner.add_bleeding(BLEED_CRITICAL)
	RegisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, PROC_REF(abort_attachment))

/datum/mutation/headless/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE

	UnregisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB)
	// Nowa głowa nadpisuje fryzurę domyślną, więc zapamiętujemy wygląd
	var/mob/living/carbon/human/human_owner = ishuman(owner) ? owner : null
	var/list/saved_look
	if(human_owner)
		saved_look = list(human_owner.hair_style, human_owner.hair_color, human_owner.facial_hair_style, human_owner.facial_hair_color, human_owner.lip_style, human_owner.lip_color)
	var/successful = owner.regenerate_limb(BODY_ZONE_HEAD)
	if(!successful)
		stack_trace("HARS mutation head regeneration failed! (usually caused by headless syndrome having a head)")
		return TRUE
	if(human_owner)
		human_owner.hair_style = saved_look[1]
		human_owner.hair_color = saved_look[2]
		human_owner.facial_hair_style = saved_look[3]
		human_owner.facial_hair_color = saved_look[4]
		human_owner.lip_style = saved_look[5]
		human_owner.lip_color = saved_look[6]

	var/obj/item/organ/brain/brain = owner.getorganslot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(owner, TRUE, TRUE)
		brain.zone = initial(brain.zone)
		brain.Insert(owner, TRUE, TRUE)

	// tg: regenerate_organs z wykluczeniem stref innych niż głowa - u nas odtwarzamy tylko narządy głowy
	var/datum/species/species = owner.dna?.species
	if(species)
		if(!owner.getorganslot(ORGAN_SLOT_EYES) && species.mutanteyes)
			var/obj/item/organ/eyes/new_eyes = new species.mutanteyes
			new_eyes.Insert(owner)
		if(!owner.getorganslot(ORGAN_SLOT_EARS) && species.mutantears)
			var/obj/item/organ/ears/new_ears = new species.mutantears
			new_ears.Insert(owner)
		if(!owner.getorganslot(ORGAN_SLOT_TONGUE) && species.mutanttongue)
			var/obj/item/organ/tongue/new_tongue = new species.mutanttongue
			new_tongue.Insert(owner)

	owner.apply_damage(50, BRUTE, BODY_ZONE_HEAD) //and this to DISCOURAGE organ farming, or at least not make it free.
	owner.update_hair()
	owner.update_body()
	owner.visible_message("<span class='warning'>Głowa [owner] odrasta z obrzydliwym chrupnięciem!</span>", "<span class='warning'>Twoja głowa odrasta z obrzydliwym trzaskiem! Au.</span>")
	new /obj/effect/gibspawner/generic(get_turf(owner), owner)

/// Głowy nie da się przyczepić z powrotem
/datum/mutation/headless/proc/abort_attachment(datum/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER
	if(ispath(new_limb, /obj/item/bodypart/head) || istype(new_limb, /obj/item/bodypart/head))
		return COMPONENT_NO_ATTACH
