// AQUILA - przedmioty i trumny wampira, które w BeeStation leżą poza modułem wampira:
// kołki (melee/misc.dm, wood.dm, weapons.dm), rękawice Exactitude (gloves/miscellaneous.dm),
// Archiwum Kindred (lib_codex_gigas.dm), picie z worków krwi (blood_pack.dm) i trumny (coffins.dm, crates.dm).

// Kołki

/obj/item/stake
	name = "drewniany kołek"
	desc = "Prosty drewniany kołek zaostrzony na końcu."
	icon = 'aquila/icons/vampires/stakes.dmi'
	icon_state = "wood"
	item_state = "wood"
	lefthand_file = 'aquila/icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'aquila/icons/vampires/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_POCKETS
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("przebija kołkiem", "dźga", "rozdziera")
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
		to_chat(user, span_notice("Ktoś już wbija kołek w pierś ofiary ([target])!"))
		return

	// lol, cry about it
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_notice("Klatka piersiowa ofiary ([target]) jest zbyt twarda! Kołek nie wejdzie!"))
		return

	// Cannot have something in your chest
	var/mob/living/carbon/carbon_target = target
	var/obj/item/bodypart/chest = carbon_target.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/obj/item/embedded_object in chest.embedded_objects)
		to_chat(user, span_boldannounce("W piersi ofiary ([target]) już tkwi [embedded_object]!"))
		return

	playsound(target, 'sound/magic/demon_consume.ogg', 50, 1)
	to_chat(target, span_userdanger("[user] wbija ci kołek w pierś!"))
	to_chat(user, span_notice("Napierasz całym ciężarem, wbijając kołek w pierś ofiary ([target])..."))

	ADD_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
	if(!vampire_do_after(user, staketime, target))
		REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
		to_chat(user, span_warning("Tracisz chwyt - kołek nie wchodzi! ([target])"))
		return

	REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)

	// Actually embed the stake and apply damage
	if(!tryEmbed(chest, TRUE, TRUE))
		// AQUILA - pancerz na klatce piersiowej może zablokować wbicie, wtedy mówimy to wprost
		to_chat(user, span_warning("Kołek nie przebija piersi ofiary ([target])! Może przeszkadza pancerz."))
		return

	target.apply_damage(force * 2, BRUTE, BODY_ZONE_CHEST)

	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	user.visible_message(
		span_danger("[user] wbija kołek w pierś ofiary ([target])!"),
		span_danger("Wbijasz kołek w pierś ofiary ([target])!"),
	)

	if(IS_VAMPIRE(target))
		to_chat(target, span_userdanger("Przebito cię kołkiem! Dopóki tkwi w twojej piersi, twoje moce są bezużyteczne!"))
		target.balloon_alert(target, "przebito cię kołkiem!")

/obj/item/stake/examine(mob/user)
	. = ..()
	. += span_notice("Aby przebić kogoś kołkiem: celuj w klatkę piersiową, włącz tryb walki i uderz.")
	. += span_notice("* Porada łowcy: pamiętaj, że przytomny cel może go po prostu wyciągnąć. Skuj go albo zabij. Kołek nie pozwala się ożywić, ale nie powstrzymuje regeneracji. Blokuje też wszystkie zdolności.")

///Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/obj/item/stake/proc/can_be_staked(mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(!CHECK_BITFIELD(target.mobility_flags, MOBILITY_MOVE))
		return TRUE
	return FALSE

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "utwardzany kołek"
	desc = "Drewniany kołek zaostrzony na końcu i utwardzony w ogniu."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	staketime = 3 SECONDS

/obj/item/stake/hardened/silver
	name = "srebrny kołek"
	desc = "Wypolerowany i ostry na końcu. Na tych drani, którzy zawsze próbują jeździć na łyżwach pod górę."
	icon_state = "silver"
	item_state = "silver"
	siemens_coefficient = 1
	force = 9
	armour_penetration = 25
	staketime = 2 SECONDS

/datum/crafting_recipe/stake
	name = "Kołek"
	result = /obj/item/stake
	reqs = list(/obj/item/stack/sheet/mineral/wood = 3)
	time = 8 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE

/datum/crafting_recipe/hardened_stake
	name = "Utwardzany kołek"
	result = /obj/item/stake/hardened
	tools = list(TOOL_WELDER)
	reqs = list(/obj/item/stack/rods = 1)
	time = 6 SECONDS
	category = CAT_WEAPON_MELEE
	dangerous_craft = TRUE
	always_available = FALSE

/datum/crafting_recipe/silver_stake
	name = "Srebrny kołek"
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
		span_notice("[user] zaczyna strugać z drewna coś ostrego."),
		span_notice("Zaczynasz strugać drewno, zaostrzając jeden koniec."),
		span_hear("Słyszysz strugane drewno."),
	)
	if(!vampire_do_after(user, 5 SECONDS, src))
		return
	var/obj/item/stake/new_item = new(user.loc)
	user.visible_message(
		span_notice("[user] kończy strugać kołek z drewna."),
		span_notice("Kończysz strugać kołek z drewna."),
	)
	var/replace = (user.get_inactive_held_item() == src)
	use(1)
	if(QDELETED(src) && replace)
		user.put_in_hands(new_item)

// Rękawice z mocy Exactitude (Celerity)

/obj/item/clothing/gloves/rapid/vampire
	name = "Dziwne rozmycie"
	desc = "Dłonie otacza dziwne, subtelne rozmycie."
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
	name = "\improper Archiwum Spokrewnionych"
	title = "Archiwum Spokrewnionych"
	desc = "Zagadkowe dokumenty wyjaśniające ukryte prawdy o istotach nieumarłych. Podobno tylko kuratorzy potrafią odczytać ich prawdziwe znaczenie."
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	lefthand_file = 'aquila/icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'aquila/icons/vampires/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	item_state = "kindred_book"
	author = "dziesiątki pokoleń kuratorów"
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
			to_chat(user, span_notice("To archiwum wydaje się dla ciebie zbyt skomplikowane. Najlepiej zostawić je komuś innemu."))
			return
		to_chat(user, span_warning("Archiwum parzy cię w dłonie, gdy próbujesz go użyć!"))
		user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return

	in_use = TRUE
	to_chat(user, span_notice("Zaczynasz uważnie przyglądać się celowi ([target]), wertując archiwum..."))
	user.visible_message(span_notice("[user] przygląda się komuś ([target]), czytając jakąś księgę."), ignored_mobs = list(user))
	if(!vampire_do_after(user, 3 SECONDS, target, timed_action_flags = NONE, progress = TRUE))
		to_chat(user, span_notice("Szybko zamykasz archiwum."))
		in_use = FALSE
		return
	in_use = FALSE

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(target)
	// Are we a Vampire | Are we on Masquerade. If one is true, they will fail.
	if(vampiredatum && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(vampiredatum.broke_masquerade)
			to_chat(user, span_warning("[target], znany też jako '[vampiredatum.return_full_name()]', to rzeczywiście wampir, ale już o tym wiedziałeś."))
			return
		to_chat(user, span_warning("[target], znany też jako '[vampiredatum.return_full_name()]', [vampiredatum.my_clan ? "należy do klanu - [vampiredatum.my_clan]!" : "nie należy do żadnego klanu."] Szybko notujesz tę informację i zapamiętujesz ją."))
		vampiredatum.break_masquerade()
	else
		to_chat(user, span_notice("Nie udaje ci się ustalić, czy [target] jest wampirem."))

/obj/item/book/kindred/attack_self(mob/living/user)
	if(!is_curator_job(user?.mind?.assigned_role))
		if(IS_VAMPIRE(user))
			to_chat(user, span_notice("To archiwum wydaje się dla ciebie zbyt skomplikowane. Najlepiej zostawić je komuś innemu."))
		else
			to_chat(user, span_warning("Twoje oczy nie są w stanie czytać tych nudnych tekstów..."))
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
			span_notice("[attacker] przykłada [src] do ust ofiary ([victim])."),
			span_notice("Przykładasz [src] do ust ofiary ([victim])."))
		if(!vampire_do_after(attacker, 5 SECONDS, victim))
			return
		attacker.visible_message(
			span_notice("[attacker] zmusza [victim] do picia z [src]."),
			span_notice("Zmuszasz [victim] do picia z [src]."))

		var/fed = reagents.trans_to(victim, reagents.total_volume, transfered_by = attacker, method = INGEST)

		// I would add more flavor, but I don't want to make this an antag check
		if(vampiredatum?.my_clan?.blood_drink_type != VAMPIRE_DRINK_SNOBBY)
			vampiredatum?.adjust_vitae(fed / 4)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	if(vampiredatum?.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
		balloon_alert(victim, "Fuj. Nieświeża!")
		return TRUE

	attacker.visible_message(
			span_notice("[victim] przykłada [src] do ust."),
			span_notice("Przykładasz [src] do ust."))

	if(!vampire_do_after(victim, 5 SECONDS, attacker, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker)))
		return

	victim.visible_message(
		span_notice("[victim] wysysa zawartość: [src]!"),
		span_notice("Pożywiasz się: [src]."))

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
		to_chat(victim, span_warning("[src] - pusto!"))
		return FALSE
	return TRUE

// Flaszka czosnku (Bee: glassbottle.dm)

/obj/item/reagent_containers/food/drinks/bottle/garlic_extract
	name = "flaszka ekstraktu czosnkowego"
	desc = "Flaszka stężonego, poświęconego ekstraktu czosnkowego. Na pewno odstraszy każdego wampira, który spróbuje cię ugryźć. Na szczęście one nie istnieją... prawda?"
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/consumable/garlic = 70, /datum/reagent/water/holywater = 30)
	foodtype = VEGETABLES
