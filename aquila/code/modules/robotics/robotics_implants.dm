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

// --- Implant agonalny: kanał radia i cyborgi ---
// Zamiast osobnego alarmu śmierci (BurgerStation death_alarm) implant agonalny z core (/obj/item/implant/deathrattle) dostaje
// przycisk wyboru kanału radia: po śmierci nosiciela nadaje zgłoszenie na wybranym kanale (w tym medycznym), a grupa implantów
// działa jak dotąd. Da się go wszczepić cyborgowi zwykłym implanterem (inne implanty cyborgów nie przyjmują).

/obj/item/implant/deathrattle
	activated = TRUE
	/// Kanał radia, na który implant zgłasza śmierć nosiciela (null = tylko grupa implantów)
	var/aq_radio_channel
	/// Radio bez głośnika, przez które idzie zgłoszenie
	var/obj/item/radio/aq_alert_radio

/obj/item/implant/deathrattle/Destroy()
	QDEL_NULL(aq_alert_radio)
	return ..()

/obj/item/implant/deathrattle/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(iscyborg(target))
		force = TRUE
	return ..()

/obj/item/implant/deathrattle/activate()
	. = ..()
	if(imp_in)
		INVOKE_ASYNC(src, PROC_REF(aq_pick_channel), imp_in)

/// Kanały, na które implant może nadawać
/obj/item/implant/deathrattle/proc/aq_channels()
	return list(RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_COMMON, RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_ENGINEERING, RADIO_CHANNEL_SCIENCE, \
		RADIO_CHANNEL_COMMAND, RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_MUNITIONS)

/obj/item/implant/deathrattle/proc/aq_pick_channel(mob/living/user)
	var/list/choices = list("Wyłączony") + aq_channels()
	var/picked = tgui_input_list(user, "Na który kanał radia implant ma zgłosić twoją śmierć?", "Implant agonalny", choices, aq_radio_channel || "Wyłączony")
	if(!picked || QDELETED(src) || imp_in != user)
		return
	aq_radio_channel = (picked in aq_channels()) ? picked : null
	if(aq_radio_channel)
		to_chat(user, span_notice("Implant agonalny zgłosi twoją śmierć na kanale: [aq_radio_channel]."))
	else
		to_chat(user, span_notice("Implant agonalny nie nadaje na radiu."))

/obj/item/implant/deathrattle/on_mob_death(mob/living/L, gibbed)
	. = ..()
	if(aq_radio_channel && L == imp_in)
		aq_broadcast_death(L)

/// Treść zgłoszenia (osobno, żeby test mógł ją sprawdzić bez radia)
/obj/item/implant/deathrattle/proc/aq_death_message(mob/living/victim)
	return "Implant agonalny: [victim.real_name] nie żyje ([get_area_name(victim, TRUE) || "nieznane miejsce"])."

/obj/item/implant/deathrattle/proc/aq_broadcast_death(mob/living/victim)
	if(!aq_alert_radio)
		aq_alert_radio = new(src)
		aq_alert_radio.keyslot = new /obj/item/encryptionkey/heads/captain(aq_alert_radio)
		aq_alert_radio.recalculateChannels()
		aq_alert_radio.listening = FALSE
		aq_alert_radio.canhear_range = 0
	if(aq_radio_channel == RADIO_CHANNEL_COMMON)
		aq_alert_radio.talk_into(src, aq_death_message(victim))
	else
		aq_alert_radio.talk_into(src, aq_death_message(victim), aq_radio_channel)

/// Wersja dla załogi z protolathe: od razu ustawiona na kanał medyczny
/obj/item/implant/deathrattle/aq_medical
	aq_radio_channel = RADIO_CHANNEL_MEDICAL

/obj/item/implantcase/deathrattle/aq_medical
	name = "etui na implant – „Agonalny” (kanał medyczny)"
	desc = "Szklane etui z implantem agonalnym, który zgłasza śmierć nosiciela na kanale medycznym. Działa też w cyborgach."
	imp_type = /obj/item/implant/deathrattle/aq_medical

/datum/design/aq_deathrattle
	name = "Etui z implantem agonalnym"
	desc = "Po śmierci nosiciela zgłasza ją na wybranym kanale radia, domyślnie medycznym. Działa też w cyborgach."
	id = "aq_implant_deathrattle"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/deathrattle/aq_medical
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

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
	design_ids += list("aq_ci_bracing", "aq_implant_deathrattle")

/datum/techweb_node/adv_cyber_implants/New()
	. = ..()
	design_ids += "aq_ci_jumpboots"
