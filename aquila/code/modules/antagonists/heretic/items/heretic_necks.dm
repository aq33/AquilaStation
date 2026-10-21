/obj/item/clothing/neck/heretic_focus
	name = "amber focus"
	desc = "Bursztynowe szkło skupiające, które łączy ze światem za zasłoną. \
		Naszyjnik zdaje się drgać, ale tylko kiedy patrzysz na niego kątem oka."
	icon = 'aquila/icons/obj/clothing/neck.dmi'
	worn_icon = 'aquila/icons/mob/clothing/neck.dmi'
	icon_state = "eldritch_necklace"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	/// Cooldown between attempts to recharge spells
	var/cooldown_period = 3 MINUTES
	COOLDOWN_DECLARE(spell_recharge_cd)

/obj/item/clothing/neck/heretic_focus/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK) || !IS_HERETIC(user))
		return
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, spell_recharge_cd, cooldown_period)

/obj/item/clothing/neck/heretic_focus/dropped(mob/living/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/neck/heretic_focus/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, spell_recharge_cd))
		return

	var/mob/living/wearer = loc
	if(!istype(wearer) || !IS_HERETIC(wearer))
		return PROCESS_KILL

	var/datum/antagonist/heretic/our_heretic = GET_HERETIC(wearer)
	for(var/datum/heretic_knowledge/spell/spell in our_heretic?.get_researched_knowledge())
		spell.add_charges(CEILING(spell.max_charges * spell.focus_recharge_amount, 1))

	COOLDOWN_START(src, spell_recharge_cd, cooldown_period)

/obj/item/clothing/neck/heretic_focus/crimson_medallion
	name = "crimson medallion"
	desc = "Krwistoczerwone szkło skupiające, które łączy ze światem za zasłoną - i z czymś gorszym. \
		Jego oko ciągle drga i rozgląda się na wszystkie strony. Wygląda, jakby bezgłośnie krzyczało..."
	icon_state = "crimson_medallion"
	cooldown_period = 1 MINUTES
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/component
	/// If active or not, used to add and remove its cult and heretic buffs.
	var/active = FALSE

/obj/item/clothing/neck/heretic_focus/crimson_medallion/equipped(mob/living/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return

	var/team_color = COLOR_ADMIN_PINK
	if(IS_CULTIST(user))
		// AQUILA - tg: dodatkowe zaklęcie krwi i szybsze wzmacnianie; nasza magia krwi tego nie obsługuje, zostaje aura leczenia
		team_color = COLOR_CULT_RED
	else if(IS_HERETIC_OR_MONSTER(user) && !active)
		for(var/datum/action/cooldown/spell/spell_action in user.actions)
			spell_action.cooldown_time *= 0.5
			active = TRUE
		team_color = COLOR_GREEN
	else
		team_color = pick(COLOR_CULT_RED, COLOR_GREEN)

	user.add_traits(list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOOD_FOUNTAIN), REF(src))
	to_chat(user, span_alert("Twoje serce przyjmuje dziwny, a zarazem kojący, nieregularny rytm, a krew wydaje się znacznie rzadsza niż wcześniej. Nie wiesz, czy to dobrze."))
	QDEL_NULL(component)
	component = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 3, \
		brute_heal = 1, \
		burn_heal = 1, \
		blood_heal = 2, \
		suffocation_heal = 5, \
		simple_heal = 0.6, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_MANSUS_TOUCHED, \
		healing_color = team_color, \
	)

/obj/item/clothing/neck/heretic_focus/crimson_medallion/dropped(mob/living/user)
	. = ..()

	if(!istype(user))
		return

	if(HAS_TRAIT_FROM(user, TRAIT_MANSUS_TOUCHED, REF(src)))
		to_chat(user, span_notice("Twoje serce i krew wracają do dawnego rytmu."))

	if(IS_HERETIC_OR_MONSTER(user) && active)
		for(var/datum/action/cooldown/spell/spell_action in user.actions)
			spell_action.cooldown_time *= 2
			active = FALSE
	QDEL_NULL(component)
	user.remove_traits(list(TRAIT_MANSUS_TOUCHED, TRAIT_BLOOD_FOUNTAIN), REF(src))

/obj/item/clothing/neck/heretic_focus/crimson_medallion/attack_self(mob/living/user, modifiers)
	. = ..()
	to_chat(user, span_danger("Zaczynasz mocno ściskać [src]..."))
	if(!do_after(user, 1.25 SECONDS, target = src))
		return
	to_chat(user, span_danger("[src] eksploduje deszczem krwi i flaków, zalewając ci rękę. Czujesz, jak krew wsiąka w skórę. Od razu czujesz się lepiej, ale wkrótce to uczucie staje się puste, a żyły zaczynają swędzieć."))
	new /obj/effect/gibspawner/generic(get_turf(src))
	var/heal_amt = user.adjustBruteLoss(-50)
	user.adjustFireLoss( -(50 - abs(heal_amt)) ) // no double dipping

	// I want it to poison the user but I also think it'd be neat if they got their juice as well. But that cancels most of the damage out. So I dunno.
	user.reagents?.add_reagent(/datum/reagent/fuel/unholywater, rand(6, 10))
	user.reagents?.add_reagent(/datum/reagent/eldritch, rand(6, 10))
	qdel(src)

/obj/item/clothing/neck/heretic_focus/crimson_medallion/examine(mob/user)
	. = ..()

	var/magic_dude
	if(IS_CULTIST(user))
		. += span_cultbold("Ten fokus zapewnia też słabe leczenie w pobliżu.")
		magic_dude = TRUE
	if(IS_HERETIC_OR_MONSTER(user))
		magic_dude = TRUE

	if(magic_dude)
		. += span_red("Możesz go też ścisnąć, by szybko odzyskać sporo zdrowia, ale nie za darmo...")

/obj/item/clothing/neck/eldritch_amulet
	name = "warm eldritch medallion"
	desc = "Dziwny medalion. Gdy patrzysz przez jego krystaliczną powierzchnię, świat wokół się rozpływa. \
		Widzisz własne bijące serce i pulsowanie tysiąca innych."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	worn_icon = 'aquila/icons/mob/clothing/neck.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// A secondary clothing trait only applied to heretics.
	var/heretic_only_trait = TRAIT_THERMAL_VISION

/obj/item/clothing/neck/eldritch_amulet/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	if(!ishuman(user) || !IS_HERETIC_OR_MONSTER(user))
		return

	ADD_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, heretic_only_trait, "[CLOTHING_TRAIT]_[REF(src)]")
	user.update_sight()

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "piercing eldritch medallion"
	desc = "Dziwny medalion. Gdy patrzysz przez jego krystaliczną powierzchnię, światło rozszczepia się w nowe, przerażające spektra barw. \
		Widzisz siebie odbitego w kaskadzie luster, wykrzywionego w niemożliwe kształty."
	heretic_only_trait = TRAIT_XRAY_VISION

// Cosmetic-only version
/obj/item/clothing/neck/fake_heretic_amulet
	name = "religious icon"
	desc = "Dziwny medalion, przez który noszący wygląda jak członek jakiegoś kultu."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	worn_icon = 'aquila/icons/mob/clothing/neck.dmi'
	icon_state = "eye_medalion"
	w_class = WEIGHT_CLASS_SMALL

// The amulet conversion tool used by moon heretics
/obj/item/clothing/neck/moon_amulet
	name = "moonlight amulet"
	desc = "Kawałek umysłu, duszy i księżyca. Patrzenie w niego przyprawia o zawrót głowy i sprawia, że słyszysz szepty śmiechu i radości."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	worn_icon = 'aquila/icons/mob/clothing/neck.dmi'
	icon_state = "moon_amulette"
	w_class = WEIGHT_CLASS_SMALL
	/// How much damage does this item do to the targets sanity?
	var/sanity_damage = 20
	var/list/possible_sounds = list(
		'aquila/sound/items/sitcom_laugh/SitcomLaugh1.ogg',
		'aquila/sound/items/sitcom_laugh/SitcomLaugh2.ogg',
		'aquila/sound/items/sitcom_laugh/SitcomLaugh3.ogg',
	)
	var/valid_weapon_type = /obj/item/melee/sickly_blade
	var/sanity_threshold = SANITY_LEVEL_INSANE

/obj/item/clothing/neck/moon_amulet/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user))
		. += span_notice("Noszenie tego amuletu przyspiesza twoje leczenie o 50%.")

/obj/item/clothing/neck/moon_amulet/equipped(mob/living/user, slot)
	. = ..()
	if(!IS_HERETIC(user) && (slot_flags & slot))
		channel_amulet(user)
		return // Equipping the amulet as a non-heretic will give you a fat mood debuff and nothing else
	if(!(slot_flags & slot))
		on_amulet_deactivate(user)
		return
	on_amulet_activate(user)

/// Modifies any blades you hold/pickup/drop when the amulet is enabled
/obj/item/clothing/neck/moon_amulet/proc/on_amulet_activate(mob/living/user)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(blade_channel), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip_item), override = TRUE)
	RegisterSignal(user, COMSIG_MOB_DROPPED_ITEM, PROC_REF(on_dropped_item), override = TRUE)
	// Just make sure we pacify blades potentially in our hands when we put on the amulet
	on_equip_item(user, user.get_active_held_item(), ITEM_SLOT_HANDS)
	on_equip_item(user, user.get_inactive_held_item(), ITEM_SLOT_HANDS)
	ADD_TRAIT(user, TRAIT_THERMAL_VISION, REF(src))
	user.update_sight()
	// If the equipper is a moon heretic, we buff their passive
	var/datum/status_effect/heretic_passive/moon/moon_passive = user.has_status_effect(/datum/status_effect/heretic_passive/moon)
	moon_passive?.amulet_equipped = TRUE

/// Modifies any blades you hold/pickup/drop when the amulet is disabled
/obj/item/clothing/neck/moon_amulet/proc/on_amulet_deactivate(mob/living/user)
	// Make sure to restore the values of any blades we might be holding when our amulet is deactivated
	on_dropped_item(user, user.get_active_held_item())
	on_dropped_item(user, user.get_inactive_held_item())
	UnregisterSignal(user, list(COMSIG_HERETIC_BLADE_ATTACK, COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_DROPPED_ITEM))
	REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, REF(src))
	user.update_sight()
	var/datum/status_effect/heretic_passive/moon/moon_passive = user.has_status_effect(/datum/status_effect/heretic_passive/moon)
	moon_passive?.amulet_equipped = FALSE

/obj/item/clothing/neck/moon_amulet/dropped(mob/living/user)
	if(istype(user))
		on_amulet_deactivate(user)
	return ..()

/obj/item/clothing/neck/moon_amulet/attack(mob/living/target, mob/living/user, params)
	if(channel_amulet(user, target))
		return
	return ..()

/obj/item/clothing/neck/moon_amulet/proc/blade_channel(mob/living/attacker, mob/living/victim)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(channel_amulet), attacker, victim)

/// Makes whoever the target is a bit more insane. If they are insane enough, they will be zombified into a moon zombie
/obj/item/clothing/neck/moon_amulet/proc/channel_amulet(mob/user, atom/target)

	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	if(!IS_HERETIC_OR_MONSTER(living_user))
		living_user.balloon_alert(living_user, "czujesz na sobie czyjś wzrok")
		living_user.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		living_user.adjust_sanity(-50)
		return FALSE
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target

	if(!ishuman(target))
		living_target.adjustFireLoss(30)
		return TRUE
	var/mob/living/carbon/human/human_target = target
	if(IS_HERETIC_OR_MONSTER(human_target))
		living_user.balloon_alert(living_user, "opiera się efektom!")
		return FALSE
	if(human_target.has_status_effect(/datum/status_effect/moon_slept) || human_target.has_status_effect(/datum/status_effect/moon_converted))
		human_target.balloon_alert(living_user, "zadaje obrażenia!")
		human_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
		return FALSE
	if(human_target.can_block_magic(MAGIC_RESISTANCE_MOON))
		return FALSE
	var/datum/component/mood/target_mood = human_target.get_mood()
	if(!target_mood)
		return FALSE
	if(target_mood.sanity_level < sanity_threshold)
		human_target.balloon_alert(living_user, "ich umysł jest zbyt silny!")
		human_target.add_mood_event("Moon Amulet Insanity", /datum/mood_event/amulet_insanity)
		human_target.adjust_sanity(-sanity_damage)
	else
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			human_target.balloon_alert(living_user, "ich umysł prawie się ugina, ale coś go chroni!")
			human_target.apply_status_effect(/datum/status_effect/moon_slept)
			return TRUE
		SEND_SIGNAL(user, COMSIG_MOB_APPLIED_MOONLIGHT_AMULET, target)
		human_target.balloon_alert(living_user, "ich umysł ugina się, by ujrzeć prawdę!")
		human_target.apply_status_effect(/datum/status_effect/moon_converted)
		living_user.log_message("made [human_target] insane.", LOG_GAME)
		human_target.log_message("was driven insane by [living_user]", LOG_GAME)
	return TRUE

/// Modifies any blades that we equip while wearing the amulet
/obj/item/clothing/neck/moon_amulet/proc/on_equip_item(mob/user, obj/item/blade, slot)
	SIGNAL_HANDLER
	if(!istype(blade, valid_weapon_type))
		return // We only care about modifying blades
	if(slot & ITEM_SLOT_HANDS)
		blade.force = 0
		blade.bleed_force = 0
		blade.armour_penetration = 200
		RegisterSignal(blade, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT, PROC_REF(modify_attack_message), override = TRUE)
		return
	blade.force = initial(blade.force)
	blade.bleed_force = initial(blade.bleed_force)
	blade.armour_penetration = initial(blade.armour_penetration)
	UnregisterSignal(blade, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT)

/obj/item/clothing/neck/moon_amulet/proc/modify_attack_message(obj/item/weapon, mob/living/victim, mob/living/attacker)
	SIGNAL_HANDLER

	var/list/attack_list = list(
		"Zamachujesz się [weapon] na [victim], rozcinając [victim.p_their()] obraz na dwoje.",
		"Uderzasz [victim] za pomocą [weapon], wylewając kaskadę ze środka. Nieskazitelnie.",
		"Wgryzając się głęboko, [weapon] uwalnia [victim] od zbędnych myśli.",
	)
	to_chat(attacker, span_danger(pick(attack_list)))

	var/list/victim_list = list(
		"[attacker] cię uderza, ale [weapon] wyrywa coś więcej niż kawałki ciała.",
		"Widzisz łuk światła, gdy [weapon] w dłoni [attacker] skręca ku tobie, i na chwilę widzisz świat w czterech barwach.",
		"Gdy [attacker] wcina się w ciebie za pomocą [weapon], tracisz coś głęboko w sobie. Ten ból jest gorszy niż jakakolwiek rana.",
	)
	to_chat(victim, span_userdanger(pick(victim_list)))
	playsound(attacker, pick(possible_sounds), 40, TRUE)
	return SIGNAL_MESSAGE_MODIFIED

/// Modifies any blades that we drop while wearing the amulet
/obj/item/clothing/neck/moon_amulet/proc/on_dropped_item(mob/user, obj/item/dropped_item)
	SIGNAL_HANDLER
	if(!istype(dropped_item, valid_weapon_type))
		return // We only care about modifying blades
	dropped_item.force = initial(dropped_item.force)
	dropped_item.bleed_force = initial(dropped_item.bleed_force)
	dropped_item.armour_penetration = initial(dropped_item.armour_penetration)
	UnregisterSignal(dropped_item, COMSIG_SEND_ITEM_ATTACK_MESSAGE_OBJECT)

/datum/mood_event/amulet_insanity
	description = "<span class='boldwarning'>WiDzĘ śWiAtŁo, tRzEbA jE pOwStRzYmAć!</span>\n"
	mood_change = -6
	timeout = 5 MINUTES
