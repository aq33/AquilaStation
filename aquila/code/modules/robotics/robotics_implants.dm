// AQUILA - implanty z części ROBOTYKA (część IMPLANTY ich nie dubluje):
// - implant zakłócający augmenty (Aurora code/game/objects/items/weapons/implants/implants/anti-augment.dm): dopóki siedzi
//   w nosicielu, jego implanty cybernetyczne się nie uruchamiają (przyciski akcji, implanty rąk się chowają, pasywne implanty
//   chemiczne i odżywcze stają). EMP może go spalić (lekkie 50%, silne 75%). Dla ochrony, w brygu na zcyborgizowanych więźniów,
// - implant skoku w nodze (SS220 code/modules/surgery/organs/augments_legs.dm, jumpboots): u SS220 para w obu nogach,
//   u nas jeden implant w dowolnej nodze; akcja skoku o 4 pola w kierunku patrzenia, nad przepaściami i dziurami w kadłubie,
//   co 6 s; bez grawitacji nie działa,
// - wzmocnienie stawów (Daedalus Dock augments_fluff.dm): trudniej o rany od uderzeń i zwichnięcia.
// Ikony: istniejące ikony implantów i akcji.

// --- Implant zakłócający augmenty ---

/obj/item/implant/aq_anti_augment
	name = "implant zakłócający augmenty"
	desc = "Implant nadający sygnał, który blokuje działanie popularnych implantów cybernetycznych nosiciela."
	icon_state = "emp"
	activated = FALSE

/obj/item/implant/aq_anti_augment/get_data()
	return {"<b>Dane implantu:</b><BR>
<b>Nazwa:</b> Hephaestus Industries HP-152, zakłócacz augmentacji<BR>
<b>Działanie:</b> nadaje krótkie fale radiowe, które blokują większość implantów cybernetycznych nosiciela.<BR>
<b>Uwagi:</b> działa, dopóki siedzi w nosicielu. Wrażliwy na EMP."}

/obj/item/implant/aq_anti_augment/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(target, TRAIT_AQ_AUGMENTS_DISRUPTED, AQ_ANTI_AUGMENT_TRAIT)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		for(var/obj/item/organ/cyberimp/arm/arm_implant in C.internal_organs)
			arm_implant.Retract()
	if(!silent)
		to_chat(target, "<span class='warning'>Twoje implanty cybernetyczne milkną.</span>")

/obj/item/implant/aq_anti_augment/removed(mob/living/source, silent = FALSE, special = 0)
	REMOVE_TRAIT(source, TRAIT_AQ_AUGMENTS_DISRUPTED, AQ_ANTI_AUGMENT_TRAIT)
	if(!silent)
		to_chat(source, "<span class='notice'>Twoje implanty cybernetyczne znów odpowiadają.</span>")
	return ..()

/obj/item/implant/aq_anti_augment/emp_act(severity)
	. = ..()
	if(prob(severity == EMP_HEAVY ? 75 : 50))
		if(imp_in)
			to_chat(imp_in, "<span class='notice'>Coś w twoim ciele cicho trzaska.</span>")
		qdel(src)

/obj/item/implantcase/aq_anti_augment
	name = "etui na implant – „Zakłócacz augmentów”"
	desc = "Szklane etui z implantem zakłócającym augmenty."
	imp_type = /obj/item/implant/aq_anti_augment

/obj/item/implanter/aq_anti_augment
	imp_type = /obj/item/implant/aq_anti_augment

/obj/item/storage/lockbox/aq_anti_augment
	name = "skrzynka implantów zakłócających augmenty"
	req_access = list(ACCESS_BRIG)

/obj/item/storage/lockbox/aq_anti_augment/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/aq_anti_augment(src)
	new /obj/item/implanter(src)

/datum/design/aq_anti_augment
	name = "Etui z implantem zakłócającym augmenty"
	desc = "Szklane etui z implantem blokującym implanty cybernetyczne nosiciela."
	id = "aq_implant_anti_augment"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500)
	build_path = /obj/item/implantcase/aq_anti_augment
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/subdermal_implants/New()
	. = ..()
	design_ids += "aq_implant_anti_augment"

/// Zakłócony implant nie daje się uruchomić
/obj/item/organ/cyberimp/proc/aq_is_disrupted()
	return owner && HAS_TRAIT(owner, TRAIT_AQ_AUGMENTS_DISRUPTED)

/datum/action/item_action/organ_action/IsAvailable()
	if(istype(target, /obj/item/organ/cyberimp))
		var/obj/item/organ/cyberimp/implant = target
		if(implant.aq_is_disrupted())
			return FALSE
	return ..()

/obj/item/organ/cyberimp/arm/ui_action_click()
	if(aq_is_disrupted())
		to_chat(owner, "<span class='warning'>[src] nie odpowiada, coś zagłusza sygnał.</span>")
		return
	return ..()

/obj/item/organ/cyberimp/chest/nutriment/on_life()
	if(aq_is_disrupted())
		return
	return ..()

/obj/item/organ/cyberimp/chest/reviver/on_life()
	if(aq_is_disrupted())
		return
	return ..()

/obj/item/organ/cyberimp/arm/cooler/on_life()
	if(aq_is_disrupted())
		return
	return ..()

/obj/item/organ/cyberimp/leg/chemplant/on_life()
	if(aq_is_disrupted())
		return
	return ..()

/obj/item/organ/cyberimp/chest/spinal/chemvat/on_life()
	if(aq_is_disrupted())
		return
	return ..()

// --- Implant skoku ---

/obj/item/organ/cyberimp/leg/aq_jumpboots
	name = "implant skoku"
	desc = "Wszczep z napędem odrzutowym w nodze. Pozwala przeskoczyć do czterech pól, także nad przepaścią. Wystarczy jeden implant w dowolnej nodze."
	icon_state = "implant-toolkit"
	implant_color = "#4a9ed6"
	aq_cyberpsychosis_cost = 6
	/// Akcja skoku
	var/datum/action/innate/aq_implant_jump/jump_action

/obj/item/organ/cyberimp/leg/aq_jumpboots/on_full_insert(mob/living/carbon/user)
	if(aq_duplicate_in_other_leg(user))
		return
	if(!jump_action)
		jump_action = new(src)
	jump_action.Grant(user)

/obj/item/organ/cyberimp/leg/aq_jumpboots/on_full_remove(mob/living/carbon/user)
	QDEL_NULL(jump_action)

/obj/item/organ/cyberimp/leg/aq_jumpboots/Destroy()
	QDEL_NULL(jump_action)
	return ..()

/datum/action/innate/aq_implant_jump
	name = "Skok"
	desc = "Odpala napęd w nogach i przeskakuje do czterech pól w kierunku, w którym patrzysz."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED | AB_CHECK_STUN
	/// Długość skoku
	var/jump_distance = 5
	var/jump_speed = 3
	var/cooldown_time = 6 SECONDS
	COOLDOWN_DECLARE(jump_cooldown)

/// Implant usuwa akcję razem z właścicielem, a sygnał usunięcia może jeszcze dojść do usuniętej akcji
/datum/action/innate/aq_implant_jump/owner_deleted(datum/source)
	if(QDELETED(src))
		return
	return ..()

/datum/action/innate/aq_implant_jump/Activate()
	var/mob/living/carbon/user = owner
	if(!istype(user))
		return
	if(!COOLDOWN_FINISHED(src, jump_cooldown))
		to_chat(user, "<span class='warning'>Napęd w nogach jeszcze się nie naładował!</span>")
		return
	if(!user.has_gravity())
		to_chat(user, "<span class='warning'>Bez grawitacji nie ma od czego się odbić!</span>")
		return
	if(user.throwing || user.buckled)
		to_chat(user, "<span class='warning'>Nie możesz teraz skoczyć!</span>")
		return
	var/atom/target = get_edge_target_turf(user, user.dir)
	if(user.throw_at(target, jump_distance, jump_speed, spin = FALSE, diagonals_first = TRUE))
		COOLDOWN_START(src, jump_cooldown, cooldown_time)
		playsound(user, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
		user.visible_message("<span class='warning'>[user] wystrzeliwuje w powietrze!</span>")
	else
		to_chat(user, "<span class='warning'>Coś blokuje skok!</span>")

/datum/design/aq_jumpboots
	name = "Implant skoku"
	desc = "Wszczep z napędem w nogę: skok o cztery pola, także nad przepaścią."
	id = "aq_ci_jumpboots"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/organ/cyberimp/leg/aq_jumpboots
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/// Jednorazowy alarm śmierci na kanale medycznym (BurgerStation death_alarm)
/obj/item/implant/aq_death_alarm
	name = "alarm śmierci"
	desc = "Implant, który po śmierci nosiciela raz nadaje komunikat na kanale medycznym."
	activated = FALSE

/obj/item/implant/aq_death_alarm/get_data()
	return "<b>Dane implantu:</b><BR><b>Działanie:</b> po śmierci nosiciela nadaje jeden komunikat na kanale medycznym, potem się wyłącza."

/obj/item/implant/aq_death_alarm/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_death_alarm))

/obj/item/implant/aq_death_alarm/removed(mob/living/source, silent = FALSE, special = 0)
	UnregisterSignal(source, COMSIG_MOB_DEATH)
	return ..()

/obj/item/implant/aq_death_alarm/proc/on_death_alarm(mob/living/source)
	SIGNAL_HANDLER
	var/area/where = get_area(source)
	broadcast_alarm("Alarm medyczny: [source.real_name] nie żyje ([where?.name || "nieznane miejsce"]).")
	qdel(src)

/// Nadaje na kanale medycznym przez wspólne radio stacji
/obj/item/implant/aq_death_alarm/proc/broadcast_alarm(message)
	var/obj/item/radio/radio = new /obj/item/radio(src)
	radio.listening = FALSE
	radio.set_frequency(FREQ_MEDICAL)
	radio.talk_into(src, message, RADIO_CHANNEL_MEDICAL)
	qdel(radio)

/obj/item/implantcase/aq_death_alarm
	name = "etui na implant – „Alarm śmierci”"
	desc = "Szklane etui z implantem alarmu śmierci."
	imp_type = /obj/item/implant/aq_death_alarm

/datum/design/aq_death_alarm
	name = "Etui z implantem alarmu śmierci"
	desc = "Implant, który po śmierci nosiciela woła lekarzy."
	id = "aq_implant_death_alarm"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/aq_death_alarm
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

// --- Wzmocnienie stawów ---

/obj/item/organ/cyberimp/chest/aq_bracing
	name = "wzmocnienie stawów"
	desc = "Tytanowe zawiasy i sprężyny wzmacniają stawy, więc wysiłek mniej boli, a uderzenia rzadziej wybijają kończyny."
	icon_state = "chest_implant"
	implant_color = "#c0c0c0"
	slot = ORGAN_SLOT_AQ_BRACING
	aq_cyberpsychosis_cost = 3

/// Wzmocnione stawy: rzut na rany od uderzeń na organicznych kończynach jest o 15 niższy
/mob/living/carbon/check_wounding(obj/item/bodypart/limb, damage, wound_type, wound_bonus = 0, bare_wound_bonus = 0, atom/wound_source)
	if(wound_type == WOUND_BLUNT && wound_bonus != CANT_WOUND && limb && IS_ORGANIC_LIMB(limb))
		wound_bonus += aq_bracing_wound_modifier()
	return ..()

/// Ile odejmuje wzmocnienie stawów od rzutu na rany od uderzeń
/mob/living/carbon/proc/aq_bracing_wound_modifier()
	var/obj/item/organ/cyberimp/chest/aq_bracing/bracing = getorganslot(ORGAN_SLOT_AQ_BRACING)
	if(bracing && !bracing.aq_is_disrupted())
		return -15
	return 0

/datum/design/aq_fluff_implant
	name = "Implant drobny"
	desc = "Drobny implant cybernetyczny."
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	category = list("Implants", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_fluff_implant/bracing
	name = "Wzmocnienie stawów"
	id = "aq_ci_bracing"
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/organ/cyberimp/chest/aq_bracing

/datum/techweb_node/cyber_implants/New()
	. = ..()
	design_ids += list("aq_ci_bracing", "aq_implant_death_alarm")

/datum/techweb_node/adv_cyber_implants/New()
	. = ..()
	design_ids += "aq_ci_jumpboots"
