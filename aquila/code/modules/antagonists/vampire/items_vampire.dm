// AQUILA - przedmioty i trumny wampira, które w BeeStation leżą poza modułem wampira:
// kołki (melee/misc.dm, wood.dm, weapons.dm), rękawice Exactitude (gloves/miscellaneous.dm),
// Archiwum Kindred (lib_codex_gigas.dm), picie z worków krwi (blood_pack.dm) i trumny (coffins.dm, crates.dm).

// Kołki

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'aquila/icons/vampires/stakes.dmi'
	icon_state = "wood"
	item_state = "wood"
	lefthand_file = 'aquila/icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'aquila/icons/vampires/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_POCKETS
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("staked", "stabbed", "tore into")
	sharpness = IS_SHARP
	force = 6
	throwforce = 10
	max_integrity = 30
	embedding = list(
		"embed_chance" = 100,
		"fall_chance" = 0,
		"rip_time" = 2.5 SECONDS, // this is actually 5 seconds because it gets multiplied by the w_class
	)

	///Time it takes to embed the stake into someone's chest.
	var/staketime = 4 SECONDS

/obj/item/stake/attack(mob/living/target, mob/living/user, params)
	// Cannot target yourself, must be in combat mode and targeting the chest
	if(target == user || !user.combat_mode || check_zone(user.zone_selected) != BODY_ZONE_CHEST || !iscarbon(target))
		return ..()

	if(HAS_TRAIT(target, TRAIT_BEINGSTAKED))
		to_chat(user, span_notice("[target] is already having a stake driven into [target.p_their()] chest!"))
		return

	// lol, cry about it
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_notice("[target]'s chest is too thick! [src] won't go in!"))
		return

	// Cannot have something in your chest
	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/chest = carbon_target.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/obj/item/embedded_object in chest.embedded_objects)
		to_chat(user, span_boldannounce("[target]'s chest already has [embedded_object] inside of it!"))
		return

	playsound(target, 'sound/magic/demon_consume.ogg', 50, 1)
	to_chat(target, span_userdanger("[user] is driving a stake into your chest!"))
	to_chat(user, span_notice("You put all your weight into embedding [src] into [target]'s chest..."))

	ADD_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
	if(!vampire_do_after(user, staketime, target))
		REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
		return

	REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)

	// Actually embed the stake and apply damage
	if(!tryEmbed(chest, TRUE, TRUE))
		return

	target.apply_damage(force * 2, BRUTE, BODY_ZONE_CHEST)

	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	user.visible_message(
		span_danger("[user] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)

	if(IS_VAMPIRE(target))
		to_chat(target, span_userdanger("You have been staked! Your powers are useless while it's in your chest!"))
		target.balloon_alert(target, "you have been staked!")

/obj/item/stake/examine(mob/user)
	. = ..()
	. += span_notice("To stake someone: Target the chest, activate combat mode, and hit them.")
	. += span_notice("* Hunter Tip: Remember that they can just pull it out if they are awake. Cuff them or kill them. A stake will stop them from reviving, not from regenerating. It will also stop all of their abilities.")

///Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/obj/item/stake/proc/can_be_staked(mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(!CHECK_BITFIELD(target.mobility_flags, MOBILITY_MOVE))
		return TRUE
	return FALSE

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A wooden stake carved to a sharp point and hardened by fire."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	staketime = 3 SECONDS

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	item_state = "silver"
	siemens_coefficient = 1
	force = 9
	armour_penetration = 25
	staketime = 2 SECONDS

/datum/crafting_recipe/stake
	name = "Stake"
	result = /obj/item/stake
	reqs = list(/obj/item/stack/sheet/mineral/wood = 3)
	time = 8 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/hardened_stake
	name = "Hardened Stake"
	result = /obj/item/stake/hardened
	tools = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/rods = 1)
	time = 6 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE
	always_available = FALSE

/datum/crafting_recipe/silver_stake
	name = "Silver Stake"
	result = /obj/item/stake/hardened/silver
	tools = list(TOOL_WELDER)
	reqs = list(
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/stake/hardened = 1,
	)
	time = 8 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE
	always_available = FALSE

/// Bee: ostrym przedmiotem można wystrugać kołek z drewna
/obj/item/stack/sheet/mineral/wood/attackby(obj/item/item, mob/user, params)
	if(!item.is_sharp() || user.combat_mode)
		return ..()
	user.visible_message(
		span_notice("[user] begins whittling [src] into a pointy object."),
		span_notice("You begin whittling [src] into a sharp point at one end."),
		span_hear("You hear wood carving."),
	)
	if(!vampire_do_after(user, 5 SECONDS, src))
		return
	var/obj/item/stake/new_item = new(user.loc)
	user.visible_message(
		span_notice("[user] finishes carving a stake out of [src]."),
		span_notice("You finish carving a stake out of [src]."),
	)
	var/replace = (user.get_inactive_held_item() == src)
	use(1)
	if(QDELETED(src) && replace)
		user.put_in_hands(new_item)

// Rękawice z mocy Exactitude (Celerity)

/obj/item/clothing/gloves/rapid/vampire
	name = "Strange Blur"
	desc = "There is a strange, subtle blur surrounding the hands."
	icon = 'aquila/icons/vampires/gloves_vampire.dmi'
	worn_icon = 'aquila/icons/vampires/gloves_vampire_worn.dmi'
	icon_state = "exactitude"
	item_state = null
	worn_icon_state = null
	transfer_prints = FALSE // Bee: TRAIT_FINGERPRINT_PASSTHROUGH
	warcry = null // We are not so silly.

/obj/item/clothing/gloves/rapid/vampire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/gloves/rapid/vampire/attack_self(mob/user)
	return

// Archiwum Kindred kuratora

/**
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators.
 *	When used on a player, after a short timer, will reveal if the player is a Vampire, including their real name and Clan.
 *	This book should not work on Vampires using the Masquerade ability.
 *	If it reveals a Vampire, the Curator will then be able to tell they are a Vampire on examine (Like a vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 */
/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	title = "the Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	lefthand_file = 'aquila/icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'aquila/icons/vampires/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	item_state = "kindred_book"
	author = "dozens of generations of Curators"
	unique = TRUE
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	///Boolean on whether the book is currently being used, so you can only use it on one person at a time.
	var/in_use = FALSE

/obj/item/book/kindred/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

///Attacking someone with the book.
/obj/item/book/kindred/afterattack(mob/living/target, mob/living/user, proximity_flag, params)
	. = ..()
	if(!proximity_flag || !user.can_read(src) || in_use || (target == user) || !ismob(target))
		return
	if(!is_curator_job(user?.mind?.assigned_role))
		if(IS_VAMPIRE(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
			return
		to_chat(user, span_warning("[src] burns your hands as you try to use it!"))
		user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return

	in_use = TRUE
	to_chat(user, span_notice("You begin carefully examining [target] while consulting [src]..."))
	user.visible_message(span_notice("[user] looks at [target] while reading [src]."), ignored_mobs = list(user))
	if(!vampire_do_after(user, 3 SECONDS, target, timed_action_flags = NONE, progress = TRUE))
		to_chat(user, span_notice("You quickly close [src]."))
		in_use = FALSE
		return
	in_use = FALSE

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(target)
	// Are we a Vampire | Are we on Masquerade. If one is true, they will fail.
	if(vampiredatum && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(vampiredatum.broke_masquerade)
			to_chat(user, span_warning("[target], also known as '[vampiredatum.return_full_name()]', is indeed a Vampire, but you already knew this."))
			return
		to_chat(user, span_warning("[target], also known as '[vampiredatum.return_full_name()]', [vampiredatum.my_clan ? "is part of the [vampiredatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it."))
		vampiredatum.break_masquerade()
	else
		to_chat(user, span_notice("You fail to draw any conclusions to [target] being a Vampire."))

/obj/item/book/kindred/attack_self(mob/living/user)
	if(!is_curator_job(user?.mind?.assigned_role))
		if(IS_VAMPIRE(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
		else
			to_chat(user, span_warning("You feel your eyes unable to read the boring texts..."))
		return
	ui_interact(user)

/obj/item/book/kindred/ui_state(mob/user)
	return GLOB.default_state

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()

	for(var/datum/vampire_clan/clans as anything in subtypesof(/datum/vampire_clan))
		var/clan_data = list()
		clan_data["clan_name"] = initial(clans.name)
		clan_data["clan_desc"] = initial(clans.description)
		data["clans"] += list(clan_data)

	return data

// Picie z worków krwi

/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, params)
	if(!can_drink(victim, attacker))
		return ..()

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(victim)

	if(victim != attacker)
		attacker.visible_message(
			span_notice("[attacker] puts \the [src] up to [victim]'s mouth."),
			span_notice("You put \the [src] up to [victim]'s mouth."))
		if(!vampire_do_after(attacker, 5 SECONDS, victim))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from \the [src]."),
			span_notice("You force [victim] to drink from \the [src]."))

		var/fed = reagents.trans_to(victim, reagents.total_volume, transfered_by = attacker, method = INGEST)

		// I would add more flavor, but I don't want to make this an antag check
		if(vampiredatum?.my_clan?.blood_drink_type != VAMPIRE_DRINK_SNOBBY)
			vampiredatum?.adjust_vitae(fed / 4)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	if(vampiredatum?.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
		balloon_alert(victim, "Eugh. Not fresh!")
		return TRUE

	attacker.visible_message(
			span_notice("[victim] puts \the [src] up to [victim.p_their()] mouth."),
			span_notice("You put \the [src] up to your mouth."))

	if(!vampire_do_after(victim, 5 SECONDS, attacker, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker)))
		return

	victim.visible_message(
		span_notice("[victim] sucks the contents out of \the [src]!"),
		span_notice("You feed from \the [src]."))

	var/fed = reagents.trans_to(victim, reagents.total_volume, transfered_by = attacker, method = INGEST)
	vampiredatum?.adjust_vitae(fed / 4)
	playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)

	return TRUE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!IS_VAMPIRE(victim))
		return FALSE
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents?.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	return TRUE

// Flaszka czosnku (Bee: glassbottle.dm)

/obj/item/reagent_containers/food/drinks/bottle/garlic_extract
	name = "flask of garlic extract"
	desc = "A flask of concentrated, and sanctified garlic extract. Surely to ward off any vampires trying to bite you. Lucky for you, those don't exist... right?"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/consumable/garlic = 70, /datum/reagent/water/holywater = 30)
	foodtype = VEGETABLES
