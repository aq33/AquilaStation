
/obj/item/melee/sickly_blade
	name = "\improper sickly blade"
	desc = "Chorobliwie zielone, sierpowate ostrze zdobione ozdobnym okiem. Masz wrażenie, że ktoś cię obserwuje..."
	icon = 'aquila/icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"
	item_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	throwforce = 10
	// AQUILA - tg: wound_bonus 5 / exposed_wound_bonus 15; u nas zamiast ran jest krwawienie
	bleed_force = BLEED_CUT
	toolspeed = 0.375
	hitsound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 35
	attack_verb = list("atakuje", "ciacha", "kroi", "rozdziera", "szarpie", "rozrywa", "sieka", "rozpruwa")
	var/after_use_message = ""
	/// Tracks how many times attack_self() is called so that breaking a blade while in an arena has to be intentional
	var/escape_attempts = 0
	/// Timer that resets your escape_attempts back to 0
	var/escape_timer

/obj/item/melee/sickly_blade/examine(mob/user)
	. = ..()
	if(!check_usability(user))
		return

	. += span_notice("Możesz rozbić ostrze, <b>aktywując je w dłoni</b>, by teleportować się w losowe, (w miarę) bezpieczne miejsce.")

/// Checks if the passed mob can use this blade without being stunned
/obj/item/melee/sickly_blade/proc/check_usability(mob/living/user)
	return IS_HERETIC_OR_MONSTER(user)

// AQUILA - u nas pre_attack zwraca TRUE, żeby kontynuować atak (odwrotnie niż w tg)
/obj/item/melee/sickly_blade/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(!.)
		return FALSE
	if(!check_usability(user))
		to_chat(user, span_danger("Czujesz, jak puls obcego intelektu uderza w twój umysł!"))
		user.AdjustParalyzed(5 SECONDS)
		return FALSE
	if(SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_PREATTACK, target, src) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	return TRUE

/obj/item/melee/sickly_blade/attack_self(mob/user)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(heretic_datum?.unlimited_blades)
		return
	if(HAS_TRAIT(user, TRAIT_ELDRITCH_ARENA_PARTICIPANT))
		user.balloon_alert(user, "nie ma ucieczki!")
		if(escape_attempts > 2)
			to_chat(user, span_hypnophrase(span_big("Tchórzliwe owce zostaną zarżnięte!")))
			playsound(src, SFX_SHATTER, 70, TRUE)
			var/obj/item/bodypart/to_remove = user.get_active_hand()
			to_remove?.dismember()
			deltimer(escape_timer)
			qdel(src)
			return
		escape_attempts++
		escape_timer = addtimer(CALLBACK(src, PROC_REF(reset_attempts)), 2 SECONDS, TIMER_STOPPABLE)
		return
	if(HAS_TRAIT(user, TRAIT_NO_TELEPORT))
		user.balloon_alert(user, "nie da się rozbić!")
		return
	seek_safety(user)

/obj/item/melee/sickly_blade/proc/reset_attempts()
	escape_attempts = 0
	deltimer(escape_timer)

/// Attempts to teleport the passed mob to somewhere safe on the station, if they can use the blade.
/obj/item/melee/sickly_blade/proc/seek_safety(mob/user, secondary_attack = FALSE)
	var/turf/safe_turf = find_safe_turf(zlevels = z, extended_safety_checks = TRUE)
	if(check_usability(user))
		if(safe_turf && do_teleport(user, safe_turf, channel = TELEPORT_CHANNEL_MAGIC))
			to_chat(user, span_warning("Gdy rozbijasz [src], przez twoje ciało przepływa podmuch energii. [after_use_message]"))
		else
			to_chat(user, span_warning("Rozbijasz [src], ale twoja prośba pozostaje bez odpowiedzi."))
	else
		to_chat(user, span_warning("Rozbijasz [src]."))
	playsound(src, SFX_SHATTER, 70, TRUE) //copied from the code for smashing a glass sheet onto the ground to turn it into a shard
	qdel(src)
	return TRUE

// AQUILA - tg: afterattack (z bliska) i ranged_interact_with_atom (z dystansu) - u nas jedno afterattack z proximity_flag
/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag)
		SEND_SIGNAL(user, COMSIG_HERETIC_BLADE_ATTACK, target, src)
	else
		SEND_SIGNAL(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, target, src)

// Path of Rust's blade
/obj/item/melee/sickly_blade/rust
	name = "\improper rusted blade"
	desc = "To sierpowate ostrze jest zniszczone i trawione przez rdzę. \
		A jednak wciąż kąsa, rozrywając ciało i kości poszarpanymi, zgniłymi zębami."
	icon_state = "rust_blade"
	item_state = "rust_blade"
	after_use_message = "Rdzawe Wzgórza słyszą twoje wołanie..."

// Path of Ash's blade
/obj/item/melee/sickly_blade/ash
	name = "\improper ashen blade"
	desc = "Stopiony i niewykuty kawał metalu, wypaczony w żużel i popiół. \
		Nieukończony, pragnie być czymś więcej i tępą krawędzią zadaje rany pełne sadzy."
	icon_state = "ash_blade"
	item_state = "ash_blade"
	after_use_message = "Nocny Strażnik słyszy twoje wołanie..."
	resistance_flags = FIRE_PROOF

// Path of Flesh's blade
/obj/item/melee/sickly_blade/flesh
	name = "\improper bloody blade"
	desc = "Sierpowate ostrze zrodzone z wypaczonego stworzenia z ciała. \
		W pełni świadome, pragnie dzielić z innymi cierpienie, jakie znosiło od swych strasznych początków."
	icon_state = "flesh_blade"
	item_state = "flesh_blade"
	after_use_message = "Marszałek słyszy twoje wołanie..."

/obj/item/melee/sickly_blade/flesh/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/blood_walk,\
		blood_type = /obj/effect/decal/cleanable/blood,\
		blood_spawn_chance = 66.6,\
		max_blood = INFINITY,\
	)

// AQUILA - tg: bloody_spreader; u nas ostrze brudzi trafione cele obcą krwią
/obj/item/melee/sickly_blade/flesh/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && !QDELETED(target))
		target.add_blood_DNA(list("Alien DNA" = "X*"))

// Path of Void's blade
/obj/item/melee/sickly_blade/void
	name = "\improper void blade"
	desc = "Pozbawione jakiejkolwiek substancji, to ostrze odbija nicość. \
		Jest prawdziwym obrazem czystości i chaosu, jaki następuje po jej wprowadzeniu."
	icon_state = "void_blade"
	item_state = "void_blade"
	after_use_message = "Arystokrata słyszy twoje wołanie..."

// Path of the Blade's... blade.
// Opting for /dark instead of /blade to avoid "sickly_blade/blade".
/obj/item/melee/sickly_blade/dark
	name = "\improper sundered blade"
	desc = "Dzielne ostrze, strzaskane i rozdarte. \
		Tnie z furią. Srebrne blizny na zawsze wiążą je z jego mrocznym celem."
	icon_state = "dark_blade"
	base_icon_state = "dark_blade"
	item_state = "dark_blade"
	after_use_message = "Rozdarty Czempion słyszy twoje wołanie..."
	///If our blade is currently infused with the mansus grasp
	var/infused = FALSE

/obj/item/melee/sickly_blade/dark/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !infused || target == user || !isliving(target) || QDELETED(target))
		return
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/mob/living/living_target = target
	if(!heretic_datum)
		return

	// Apply our heretic mark
	var/datum/heretic_knowledge/limited_amount/starting/base_blade/mark_to_apply = heretic_datum.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_blade)
	if(!mark_to_apply)
		return
	mark_to_apply.create_mark(user, living_target)
	infused = FALSE
	update_appearance(UPDATE_ICON)
	if(ismob(user))
		user.update_inv_hands()

	if(!check_behind(user, living_target))
		return
	// We're officially behind them, apply effects
	living_target.AdjustParalyzed(1.5 SECONDS)
	living_target.apply_damage(10, BRUTE)
	living_target.balloon_alert(user, "cios w plecy!")
	playsound(living_target, 'aquila/sound/items/weapons/guillotine.ogg', 100, TRUE)

/obj/item/melee/sickly_blade/dark/dropped(mob/user, silent)
	. = ..()
	if(infused)
		infused = FALSE
		update_appearance(UPDATE_ICON)

/obj/item/melee/sickly_blade/dark/update_icon_state()
	. = ..()
	if(infused)
		icon_state = base_icon_state + "_infused"
		item_state = base_icon_state + "_infused"
	else
		icon_state = base_icon_state
		item_state = base_icon_state

// Path of Cosmos's blade
/obj/item/melee/sickly_blade/cosmic
	name = "\improper cosmic blade"
	desc = "Okruch niebiańskiego rezonansu ukształtowany w ostrze utkane z gwiazd. \
		Opalizujący wygnaniec, który żłobi promienne smugi, desperacko szukając zjednoczenia."
	icon_state = "cosmic_blade"
	item_state = "cosmic_blade"
	after_use_message = "Gwiezdny Obserwator słyszy twoje wołanie..."

// Path of Knock's blade
/obj/item/melee/sickly_blade/lock
	name = "\improper key blade"
	desc = "Ostrze i klucz zarazem. Klucz do czego? \
		Jakie wielkie bramy otwiera?"
	icon_state = "key_blade"
	item_state = "key_blade"
	after_use_message = "Zarządcy słyszą twoje wołanie..."
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1.3

// Path of Moon's blade
/obj/item/melee/sickly_blade/moon
	name = "\improper moon blade"
	desc = "Żelazne ostrze, odbijające prawdę o ziemi: każdy kiedyś dołączy do trupy. \
		Trupy, która niesie radość, rzeźbiąc uśmiechy na twarzach - czy tego chcą, czy nie."
	icon_state = "moon_blade"
	item_state = "moon_blade"
	after_use_message = "Księżyc słyszy twoje wołanie..."

// Path of Nar'Sie's blade
// What!? This blade is given to cultists as an altar item when they sacrifice a heretic.
// It is also given to the heretic themself if they sacrifice a cultist.
/obj/item/melee/sickly_blade/cursed
	name = "\improper cursed blade"
	desc = "Mroczne ostrze, przeklęte, by krwawić na wieki. Rozdarte w nieustannej walce między pozaświatowym a mrokiem, musi przyjąć każdego właściciela jako pana. \
		Rogówka jego oka bez końca sączy krew na ziemię, a przeszywające spojrzenie wciąż spoczywa na tobie."
	force = 25
	throwforce = 15
	// AQUILA - tg: block_chance 35; u nas blokowanie z przodu (i lepiej przy chodzeniu)
	block_level = 1
	block_upgrade_walk = 1
	block_power = 35
	bleed_force = BLEED_DEEP_WOUND
	armour_penetration = 35
	icon_state = "cursed_blade"
	item_state = "cursed_blade"

/obj/item/melee/sickly_blade/cursed/Initialize(mapload)
	. = ..()

	var/examine_text = {"Pozwala kreślić krwawe runy kultu Nar'Sie.
	Połączenie pozaświatowej mocy i potęgi Nar'Sie pozwala rysować runy znacznie szybciej,
	a samo ostrze jest groźniejsze niż zwykle.\n
	<b>Kultyści mogą je też rozbić w dłoni (prawym przyciskiem albo na intencji rozbrajania), by teleportować się w miarę bezpieczne miejsce.</b>"}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text), turfs_that_boost_us = /turf) // Always fast to draw!

/obj/item/melee/sickly_blade/cursed/attack_self_secondary(mob/user, modifiers)
	seek_safety(user, TRUE)
	return TRUE

/obj/item/melee/sickly_blade/cursed/seek_safety(mob/user, secondary_attack = FALSE)
	if(IS_CULTIST(user) && !secondary_attack)
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/cursed/check_usability(mob/living/user)
	if(IS_HERETIC_OR_MONSTER(user) || IS_CULTIST(user))
		return TRUE
	if(prob(15))
		to_chat(user, span_cult_large(pick("\"Nietknięty umysł? Zabawne.\"", "\"Chyba nie warto cię powstrzymywać.\"", "\"Śmiało. Nie obchodzi mnie to.\"", "\"Wkrótce będziesz mój.\"")))
		user.apply_damage(5, BURN, user.get_active_hand())
		playsound(src, 'sound/weapons/sear.ogg', 25, TRUE)
		to_chat(user, span_danger("Twoja dłoń skwierczy.")) // Nar nar might not care but their essence still doesn't like you
	else if(prob(15))
		to_chat(user, span_big(span_hypnophrase("LW'NAFH'NAHOR UH'ENAH'YMG EPGOKA AH NAFL MGEMPGAH'EHYE")))
		to_chat(user, span_danger("Okropne, niezrozumiałe słowa zalewają twój umysł!"))
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15) // This can kill you if you ignore it
	return TRUE

/obj/item/melee/sickly_blade/cursed/equipped(mob/user, slot)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(user))
		after_use_message = "Mansus słyszy twoje wołanie..."
	else if(IS_CULTIST(user))
		after_use_message = "Nar'Sie słyszy twoje wołanie..."
	else
		after_use_message = null

// AQUILA - tg: interact_with_atom; u nas rysowanie run w pre_attack (TRUE = kontynuuj atak)
/obj/item/melee/sickly_blade/cursed/pre_attack(atom/target, mob/living/user, params)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	// Can only carve runes with it if off combat mode.
	if(heretic_datum && isopenturf(target) && !user.combat_mode)
		INVOKE_ASYNC(heretic_datum, TYPE_PROC_REF(/datum/antagonist/heretic, try_draw_rune), user, target, 14 SECONDS) // Faster than pen, slower than cicatrix
		return FALSE
	return ..()

/obj/item/melee/sickly_blade/cursed/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == OVERWHELMING_ATTACK)
		return FALSE
	return ..()

// Weaker blade variant given to people so they can participate in the heretic arena spell
/obj/item/melee/sickly_blade/training
	name = "\improper imperfect blade"
	desc = "Ostrze dane z litości tym, którzy nie potrafią przyjąć prawdy. \
		Niech będzie błogosławieństwem w tym krótkim czasie, gdy pozostaje przy tobie."
	force = 17
	armour_penetration = 0

/obj/item/melee/sickly_blade/training/check_usability(mob/living/user)
	return TRUE // If you can hold this, you can use it
