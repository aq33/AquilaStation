GLOBAL_LIST_EMPTY(runes)
GLOBAL_LIST_EMPTY(rune_appearances_cache)

/obj/effect/new_rune //Abstract, currently only supports blood as a reagent without some serious overriding.
	name = "runa"
	desc = "Dziwny zbiór symboli wypisanych krwią."
	anchored = 1
	icon = 'aquila/icons/bloodcult/deityrunes.dmi'
	icon_state = ""
	layer = ABOVE_OPEN_TURF_LAYER
	plane = GAME_PLANE

	mouse_opacity = 1 //So we can actually click these

	//Whether the rune is pulsating
	var/animated = 0
	var/activated = 0 // how many times the rune was activated. goes back to 0 if a word is erased.

	//A rune is made of up to 3 words.
	var/datum/rune_word/word1
	var/datum/rune_word/word2
	var/datum/rune_word/word3

	//An image we'll show to the AI instead of the rune
	var/image/blood_image

	//When a rune is created, we see if there's any data to copy from the blood used (colour, DNA) for all 3 words
	var/datum/reagent/blood/blood1
	var/datum/reagent/blood/blood2
	var/datum/reagent/blood/blood3
	// AQUILA - bez virus2 i znaczników holomapy (tego u nas nie ma)

	// AQUILA - zamiast hovering_information z Monke: akolita stojący na runie widzi nad nią jej nazwę (mob => image)
	var/list/name_images

	//Used when a nullrod is preventing a rune's activation TODO: REWORK NULL ROD INTERACTIONS
	var/nullblock = 0

	//The spell currently triggered by the rune. Prevents a rune from being used by different cultists at the same time.
	var/datum/rune_spell/active_spell = null

	//Prevents the same rune from being concealed/revealed several times on a row.
	var/conceal_cooldown = 0

/obj/effect/new_rune/Initialize(mapload)
	. = ..()
	blood_image = image(src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited)
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	//AI cannot see runes, instead they see blood splatters.
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		AI.client?.images += blood_image

	LAZYADD(GLOB.runes, src)

/obj/effect/new_rune/Destroy()
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if (AI.client)
			AI.client.images -= blood_image
	QDEL_NULL(blood_image)

	for(var/mob/M as anything in name_images)
		hide_rune_name(M)
	name_images = null

	if (word1)
		erase_word(word1.english, blood1)
		word1 = null
	if (word2)
		erase_word(word2.english, blood2)
		word2 = null
	if (word3)
		erase_word(word3.english, blood3)
		word3 = null

	blood1 = null
	blood2 = null
	blood3 = null

	if (active_spell)
		active_spell.abort()
		active_spell = null

	LAZYREMOVE(GLOB.runes, src)

	return ..()

/obj/effect/new_rune/examine(mob/user)
	. = ..()
	if(can_read_rune(user) || isobserver(user))
		var/datum/rune_spell/rune_name = get_rune_spell(null, null, "examine", word1, word2, word3)
		. += span_info("Napis brzmi: <i>[word1 ? "[word1.rune]" : ""][word2 ? " [word2.rune]" : ""][word3 ? " [word3.rune]" : ""]</i>. [rune_name ? " To runa <b>[initial(rune_name.name)]</b>." : "Nie pasuje do żadnego zaklęcia run."]")
		if(rune_name)
			. += initial(rune_name.desc)
			if (istype(active_spell, /datum/rune_spell/portalentrance))
				var/datum/rune_spell/portalentrance/PE = active_spell
				if (PE.network)
					. += span_info("To wejście jest dostrojone do ścieżki <b>[rune_word_display_name(PE.network)]</b>.")
			if (istype(active_spell, /datum/rune_spell/portalexit))
				var/datum/rune_spell/portalexit/PE = active_spell
				if (PE.network)
					. += span_info("To wyjście jest dostrojone do ścieżki <b>[rune_word_display_name(PE.network)]</b>.")


	//"Cult" chaplains can read the words, but they have to figure out the spell themselves. Also has a chance to trigger a taunt from Nar-Sie.
	else if(ishuman(user) && (user.mind?.assigned_role == JOB_NAME_CHAPLAIN))
		. += span_info("Napis brzmi: <i>[word1?.rune] [word2?.rune] [word3?.rune]</i>. Co to było za zaklęcie?...")
		if (prob(25))
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), user, "<span class='game say'><span class='danger'>???-???</span> mruczy, <span class='cultlarge'>[pick(\
					"Twoje zabawki na wiele ci się już nie zdadzą", \
					"Zgorzkniały, że to nie ciebie wybrano?", \
					"Podoba mi się twój styl, ale łaknę twojej krwi.", \
					"Zagrajmy więc. Oczywiście jedyną przyjmowaną stawką jest krew")].</span></span>"), 5 SECONDS)


/obj/effect/new_rune/proc/can_read_rune(mob/user) //Overload for specific criteria.
	return IS_CULTIST(user)


/obj/effect/new_rune/get_cult_power()
	return 1

/obj/effect/new_rune/narsie_act()
	return



/obj/effect/new_rune/salt_act()
	var/turf/T = get_turf(src)
	anim(target = T, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "rune_break", plane = ABOVE_LIGHTING_PLANE)
	if (active_spell)
		active_spell.salt_act(T)
	qdel(src)


/obj/effect/new_rune/proc/write_word(word, datum/reagent/blood/blood)
	if (!word)
		return
	var/turf/T = get_turf(src)
	var/write_color = COLOR_BLOOD
	if (blood)
		write_color = rune_blood_color(blood)
	anim(target = T, a_icon = 'aquila/icons/bloodcult/deityrunes.dmi', flick_anim = "[word]-write", lay = layer+0.1, col = write_color, plane = plane)

/obj/effect/new_rune/proc/erase_word(word, datum/reagent/blood/blood)
	if (!word)
		return
	var/turf/T = get_turf(src)
	var/erase_color = COLOR_BLOOD
	if (blood)
		erase_color = rune_blood_color(blood)
	anim(target = T, a_icon = 'aquila/icons/bloodcult/deityrunes.dmi', flick_anim = "[word]-erase", lay = layer+0.1, col = erase_color, plane = plane)

/obj/effect/new_rune/proc/cast_word(word)
	if (!word)
		return
	var/obj/effect/abstract/A = anim(target = get_turf(src), a_icon = 'aquila/icons/bloodcult/deityrunes.dmi', a_icon_state = "[word]-tear", lay = layer+0.2, plane = plane)
	animate(A, alpha = 0, time = 5)

/obj/effect/new_rune/ex_act(severity)
	switch (severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(15))
				qdel(src)

/obj/effect/new_rune/emp_act()
	return

/obj/effect/new_rune/blob_act()
	return

/obj/effect/new_rune/update_icon(draw_up_to = 3)
	. = ..()
	var/datum/rune_spell/spell = get_rune_spell(null, null, "examine", word1, word2, word3)

	if (active_spell)
		return

	overlays.len = 0

	if(spell && activated)
		animated = 1
		draw_up_to = 3
	else
		animated = 0

	var/lookup = ""
	if (word1)
		lookup += "[word1.english]-[animated]-[rune_blood_color(blood1)]"
	if (word2 && draw_up_to >= 2)
		lookup += "-[word2.english]-[animated]-[rune_blood_color(blood2)]"
	if (word3 && draw_up_to >= 3)
		lookup += "-[word3.english]-[animated]-[rune_blood_color(blood3)]"

	var/image/rune_render
	if (lookup in GLOB.rune_appearances_cache)
		rune_render = image(GLOB.rune_appearances_cache[lookup])
	else
		var/image/I1 = image('aquila/icons/bloodcult/deityrunes.dmi', src, "")
		if (word1)
			I1.icon_state = word1.english
			if (blood1)
				I1.color = rune_blood_color(blood1)

		var/image/I2 = image('aquila/icons/bloodcult/deityrunes.dmi', src, "")
		if (word2 && draw_up_to >= 2)
			I2.icon_state = word2.english
			if (blood2)
				I2.color = rune_blood_color(blood2)
		var/image/I3 = image('aquila/icons/bloodcult/deityrunes.dmi', src, "")
		if (word3 && draw_up_to >= 3)
			I3.icon_state = word3.english
			if (blood3)
				I3.color = rune_blood_color(blood3)

		rune_render = image('aquila/icons/bloodcult/deityrunes.dmi', src, "")
		rune_render.overlays += I1
		rune_render.overlays += I2
		rune_render.overlays += I3

		if(animated)
			if (word1)
				var/image/I =  image('aquila/icons/bloodcult/deityrunes.dmi', src, "[word1.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I
			if (word2)
				var/image/I =  image('aquila/icons/bloodcult/deityrunes.dmi', src, "[word2.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I
			if (word3)
				var/image/I =  image('aquila/icons/bloodcult/deityrunes.dmi', src, "[word3.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I

		if(word1 && rune_blood_glows(blood1))
			rune_render.overlays += emissive_appearance('aquila/icons/bloodcult/deityrunes.dmi', word1.english)
		if(word2 && draw_up_to >= 2 && rune_blood_glows(blood2))
			rune_render.overlays += emissive_appearance('aquila/icons/bloodcult/deityrunes.dmi', word2.english)
		if(word3 && draw_up_to >= 3 && rune_blood_glows(blood3))
			rune_render.overlays += emissive_appearance('aquila/icons/bloodcult/deityrunes.dmi', word3.english)

		LAZYADDASSOC(GLOB.rune_appearances_cache, lookup, rune_render)
	overlays += rune_render

	if(animated)
		idle_pulse()
	else
		animate(src)

/obj/effect/proc/idle_pulse()
	//This masterpiece of a color matrix stack produces a nice animation no matter which color the rune is.
	animate(src, color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 10, loop = -1)//1
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)//2
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)//3
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)//4
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)//5
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//6
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//7
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//8
	animate(color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5)//9
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//8
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//7
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//6
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//5
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//4
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//3
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)//2


/obj/effect/new_rune/proc/one_pulse()
	animate(src, color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.75)
	animate(color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.75)
	animate(color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.5)
	animate(color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.5)
	animate(color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 0.25)
	animate(color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)

	addtimer(CALLBACK(src, PROC_REF(after_pulse)), 1 SECONDS)

/obj/effect/new_rune/proc/after_pulse()
	if(animated)
		idle_pulse()
	else
		animate(src)


/obj/effect/new_rune/proc/on_entered(turf/entered_turf, atom/movable/mover)
	SIGNAL_HANDLER
	if (ismob(mover))
		var/mob/user = mover
		show_rune_name(user)
		INVOKE_ASYNC(src, PROC_REF(walk_effect), user)

/obj/effect/new_rune/proc/walk_effect(mob/user)
	var/datum/rune_spell/rune_effect = get_rune_spell(user, src, "walk" , word1, word2, word3)
	if (rune_effect)
		rune_effect.Added(user)

/obj/effect/new_rune/proc/on_exited(turf/entered_turf, atom/movable/mover)
	SIGNAL_HANDLER
	if (!ismob(mover))
		return
	hide_rune_name(mover)
	if (active_spell)
		INVOKE_ASYNC(active_spell, TYPE_PROC_REF(/datum/rune_spell, Removed), mover)

/// AQUILA - podpis runy dla akolitów (w drafcie przez /datum/component/hovering_information z Monke)
/obj/effect/new_rune/proc/show_rune_name(mob/enterer)
	if(!enterer.client || (enterer in name_images))
		return
	var/datum/antagonist/cult/cultist = IS_CULTIST(enterer)
	if(!cultist || cultist.cultist_role != CULTIST_ROLE_ACOLYTE)
		return
	var/datum/rune_spell/rune_name = get_rune_spell(null, null, "examine", word1, word2, word3)
	var/image/new_image = image(loc = src)
	new_image.maptext_width = 128
	new_image.maptext_y = 32
	new_image.maptext_x = -48
	new_image.color = COLOR_BLOOD
	new_image.alpha = 180
	new_image.plane = ABOVE_LIGHTING_PLANE
	new_image.appearance_flags = RESET_COLOR
	new_image.maptext = MAPTEXT_YOU_MURDERER("<span style = 'text-align: center; -dm-text-outline: 1px black'> [youmurderer_safe_text(rune_name ? initial(rune_name.name) : "Nieznana runa")] </span>")
	LAZYSET(name_images, enterer, new_image)
	add_client_image(new_image, enterer.client)

/obj/effect/new_rune/proc/hide_rune_name(mob/leaver)
	var/image/old_image = LAZYACCESS(name_images, leaver)
	if(!old_image)
		return
	LAZYREMOVE(name_images, leaver)
	remove_client_image(old_image, leaver.client)

/obj/effect/new_rune/attack_animal(mob/living/simple_animal/user)
	if(istype(user, /mob/living/simple_animal/hostile/construct))
		trigger(user)
	if(istype(user, /mob/living/simple_animal/shade))
		trigger(user)

/obj/effect/new_rune/attack_paw(mob/living/user)
	if(ismonkey(user))
		trigger(user)

/obj/effect/new_rune/attack_alien(mob/living/user)
	if(isalien(user))
		trigger(user)

/obj/effect/new_rune/attack_hand(mob/living/user)
	trigger(user)

/obj/effect/new_rune/attack_robot(mob/living/user) //Allows for robots to remotely trigger runes, since attack_robot has infinite range.
	trigger(user)


/obj/effect/new_rune/attackby(obj/I, mob/user)
	..()
	// AQUILA - u nas biblia to /obj/item/storage/book/bible i nie ma bumerangu, więc nie isholyweapon()
	if(istype(I, /obj/item/storage/book/bible) || istype(I, /obj/item/nullrod))
		to_chat(user, span_notice("Rozpraszasz plugawą magię martwym polem [I]!") )
		qdel(src)
		return
	if(istype(I, /obj/item/tome) || istype(I, /obj/item/melee/cultblade) || istype(I, /obj/item/melee/soulblade) || istype(I, /obj/item/melee/blood_dagger))
		trigger(user)
	if(istype(I, /obj/item/talisman))
		var/obj/item/talisman/T = I
		T.imbue(user, src)
	return

/obj/effect/new_rune/proc/trigger(mob/living/user, talisman_trigger = 0)

	if(!IS_CULTIST(user))
		to_chat(user, span_danger("Plączesz się na tajemnych bazgrołach, nie potrafisz ich wymówić.") )
		return

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if (C.occult_muted())
			to_chat(user, span_danger("Nie potrafisz skupić myśli na tajemnych słowach runy.") )
			return

	if(!user.checkTattoo(TATTOO_SILENT))
		if(user.is_muzzled())
			to_chat(user, span_danger("Knebel nie pozwala ci wypowiedzieć słów runy.") )
			return

		if(HAS_TRAIT(user, TRAIT_MUTE))
			to_chat(user, span_danger("Nie potrafisz odprawiać rytuałów bez wypowiadania inkantacji, musi być na to jakiś sposób...") )
			return

	if(!word1 || !word2 || !word3 || prob(user.getOrganLoss(ORGAN_SLOT_BRAIN)))
		return fizzle(user)

	add_hiddenprint(user)

	if(active_spell)//rune is already channeling a spell? let's see if we can interact with it somehow.
		if(talisman_trigger)
			var/datum/rune_spell/active_spell_typecast = active_spell
			if(!istype(active_spell_typecast))
				return
			active_spell_typecast.midcast_talisman(user)
		else
			active_spell.midcast(user)
		return

	reveal()//concealed rune get automatically revealed upon use (either through using Seer or an attuned talisman). Placed after midcast: exception for Path talismans.

	// active_spell ustawia /datum/rune_spell/New przed pre_cast(), a Destroy() zaklęcia go czyści
	if (!get_rune_spell(user, src, "ritual", word1, word2, word3))
		return fizzle(user)

/obj/effect/new_rune/proc/fizzle(mob/living/user)
	var/silent = user.checkTattoo(TATTOO_SILENT)
	if(!silent)
		user.say(pick("B'ADMINES SP'WNIN SH'T", "IC'IN O'OC", "RO'SHA'M I'SA GRI'FF'N ME'AI", "TOX'IN'S O'NM FI'RAH", "IA BL'AME TOX'IN'S", "FIR'A NON'AN RE'SONA", "A'OI I'RS ROUA'GE", "LE'OAN JU'STA SP'A'C Z'EE SH'EF", "IA PT'WOBEA'RD, IA A'DMI'NEH'LP", "I'F ON'Y I 'AD 'TAB' E"))
	one_pulse()
	visible_message(span_warning("Znaki pulsują krótkim błyskiem światła, po czym gasną.") , \
	span_warning("Znaki pulsują krótkim błyskiem światła, po czym gasną.") , \
	span_warning("Słyszysz ciche syknięcie.") )

/obj/effect/new_rune/proc/conceal()
	if(active_spell && !active_spell.can_conceal)
		active_spell.abort(RITUALABORT_CONCEAL)
	alpha = 0
	if (word1)
		erase_word(word1.english, blood1)
	if (word2)
		erase_word(word2.english, blood2)
	if (word3)
		erase_word(word3.english, blood3)
	addtimer(CALLBACK(src, PROC_REF(finish_conceal)), 6)

/obj/effect/new_rune/proc/finish_conceal()
	invisibility = INVISIBILITY_OBSERVER
	alpha = 127

/obj/effect/new_rune/proc/reveal() //Returns 1 if rune was revealed from a invisible state.
	if(invisibility != 0)
		invisibility = 0
		if (!(active_spell?.custom_rune))
			overlays.len = 0
			if (word1)
				write_word(word1.english, blood1)
			if (word2)
				write_word(word2.english, blood2)
			if (word3)
				write_word(word3.english, blood3)
			addtimer(CALLBACK(src, PROC_REF(finish_reveal)), 8)
		else
			alpha = 255
		conceal_cooldown = 1
		addtimer(VARSET_CALLBACK(src, conceal_cooldown, 0), 10 SECONDS)
		return 1
	return 0

/obj/effect/new_rune/proc/finish_reveal()
	alpha = 255
	update_icon()

/proc/write_rune_word(turf/T, datum/rune_word/word = null, datum/reagent/blood/source, mob/caster = null)
	if (!word)
		return RUNE_WRITE_CANNOT

	if (!source)
		source = new

	source.color = rune_blood_color(source)
	//Add word to a rune if there is one, otherwise create one. However, there can be no more than 3 words.
	//Returns 0 if failure, 1 if finished a rune, 2 if success but rune still has room for words.

	var/newrune = FALSE
	var/obj/effect/new_rune/rune = locate() in T
	if(!rune)
		rune = new /obj/effect/new_rune(T)
		newrune = TRUE

	if (rune.word1 && rune.word2 && rune.word3)
		return RUNE_WRITE_CANNOT

	if (caster)
		if (newrune)
			log_admin("BLOODCULT: [key_name(caster)] has created a new rune at [T.loc] (@[T.x], [T.y], [T.z]).")
			message_admins("BLOODCULT: [key_name(caster)] tworzy nową runę w [ADMIN_JMP(T)].")
		rune.add_hiddenprint(caster)

	rune.write_word(word.english, source)

	if (!rune.word1)
		rune.word1 = word
		rune.blood1 = new()
		rune.blood1.data = source.data
		addtimer(CALLBACK(rune, TYPE_PROC_REF(/atom, update_icon), 1), 8)

	else if (!rune.word2)
		rune.word2 = word
		rune.blood2 = new()
		rune.blood2.data = source.data
		addtimer(CALLBACK(rune, TYPE_PROC_REF(/atom, update_icon), 2), 8)

	else if (!rune.word3)
		rune.word3 = word
		rune.blood3 = new()
		rune.blood3.data = source.data
		addtimer(CALLBACK(rune, TYPE_PROC_REF(/atom, update_icon), 3), 8)

	if (rune.blood3)
		return RUNE_WRITE_COMPLETE
	return RUNE_WRITE_CONTINUE

/proc/erase_rune_word(turf/T)
	var/obj/effect/new_rune/rune = locate() in T
	if(!rune)
		return null

	var/word_erased

	if(rune.word3)
		rune.erase_word(rune.word3.english, rune.blood3)
		word_erased = rune.word3.rune
		rune.word3 = null
		rune.blood3 = null
		if (rune.active_spell)
			rune.active_spell.abort(RITUALABORT_ERASED)
			rune.active_spell = null
			rune.overlays.len = 0
		rune.update_icon()
	else if(rune.word2)
		rune.erase_word(rune.word2.english, rune.blood2)
		word_erased = rune.word2.rune
		rune.word2 = null
		rune.blood2 = null
		rune.update_icon()
	else if(rune.word1)
		rune.erase_word(rune.word1.english, rune.blood1)
		word_erased = rune.word1.rune
		rune.word1 = null
		rune.blood1 = null
		qdel(rune)
	else
		message_admins("Błąd! Próba wymazania słowa z runy, która nie ma słów!")
		qdel(rune)
		return null
	rune.activated = 0
	return word_erased


/proc/write_full_rune(turf/T, spell_type, datum/reagent/blood/source, mob/caster = null)
	if (!spell_type)
		return

	var/datum/rune_spell/spell_instance = spell_type
	var/datum/rune_word/word1_instance = initial(spell_instance.word1)
	var/datum/rune_word/word2_instance = initial(spell_instance.word2)
	var/datum/rune_word/word3_instance = initial(spell_instance.word3)
	write_rune_word(T, GLOB.rune_words[initial(word1_instance.english)], source, caster)
	write_rune_word(T, GLOB.rune_words[initial(word2_instance.english)], source, caster)
	write_rune_word(T, GLOB.rune_words[initial(word3_instance.english)], source, caster)
