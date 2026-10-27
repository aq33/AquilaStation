/obj/item/talisman
	name = "talizman"
	desc = "Postrzępiony pergamin. Czujesz, jak bije od niego mroczna energia."
	gender = NEUTER
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "talisman"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 1
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/linked_ui
	var/blood_text = ""
	var/obj/effect/new_rune/attuned_rune = null
	var/spell_type = null
	var/uses = 1

/obj/item/talisman/New()
	..()
	pixel_x = 0
	pixel_y = 0


/obj/item/talisman/salt_act()
	if (attuned_rune && attuned_rune.active_spell)
		attuned_rune.active_spell.salt_act(get_turf(src))
	fire_act(1000, 200)


/obj/item/talisman/proc/talisman_name()
	var/datum/rune_spell/instance = spell_type
	if (blood_text)
		return "\[krwawa wiadomość\]"
	if (instance)
		return initial(instance.name)
	else
		return "\[pusty\]"

/obj/item/talisman/suicide_act(mob/living/user)
	user.visible_message(span_danger("[user] połyka [src] i zaczyna się nim dławić! Wygląda na to, że próbuje popełnić samobójstwo.") )

/obj/item/talisman/examine(mob/user)
	. = ..()
	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window=cult_talisman")
		onclose(user, "[name]")
		return

	if (!spell_type)
		. += span_info("Ten jednak wydaje się zupełnie zwyczajny.")
		return

	var/datum/rune_spell/instance = spell_type

	if (IS_CULTIST(user) || isobserver(user))
		if (attuned_rune)
			. += span_info("Ten został dostrojony do runy <b>[initial(instance.name)]</b>. [initial(instance.desc_talisman)]")
		else
			. += span_info("Ten nasycono mocą runy <b>[initial(instance.name)]</b>. [initial(instance.desc_talisman)]")
		if (uses > 1)
			. += span_info("Pozostało użyć: <b>[uses]</b>.")
	else
		. += span_info("Ten ma na sobie tajemne rysunki. Nie potrafisz ich odczytać.")

/obj/item/talisman/attack_self(mob/living/user)
	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window=cult_talisman")
		onclose(user, "[name]")
		onclose(user, "[name]")
		return

	if (IS_CULTIST(user))
		trigger(user)

/obj/item/talisman/attack(mob/living/target, mob/living/user)
	if(IS_CULTIST(user) && spell_type)
		var/datum/rune_spell/instance = spell_type
		if (initial(instance.touch_cast))
			new spell_type(user, src, "touch", target)
			qdel(src)
			return
	..()

/obj/item/talisman/proc/trigger(mob/user)
	if (!user)
		return

	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window=cult_talisman")
		onclose(user, "[name]")
		return

	if (!spell_type)
		if (!(src in user.held_items))//triggering an empty rune from a tome removes it.
			if (istype(loc, /obj/item/tome))
				var/obj/item/tome/T = loc
				T.talismans.Remove(src)
				user << browse(T.tome_text(), "window=arcanetome;size=900x600")
				user.put_in_hands(src)
		return

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if (C.occult_muted())
			to_chat(user, span_danger("Nie jesteś w stanie skupić umysłu na tajemnych słowach talizmanu.") )
			return

	if (attuned_rune)
		if (attuned_rune.loc)
			attuned_rune.trigger(user, 1)
		else//darn, the rune got destroyed one way or another
			attuned_rune = null
			to_chat(user, span_warning("Talizman rozsypuje się w pył. Runa, do której był dostrojony, chyba już nie istnieje.") )
	else
		new spell_type(user, src)

	uses--
	if (uses > 0)
		return

	if (istype(loc, /obj/item/tome))
		var/obj/item/tome/T = loc
		T.talismans.Remove(src)
	if (linked_ui)
		linked_ui.talisman = null
	qdel(src)

/obj/item/talisman/proc/imbue(mob/user, obj/effect/new_rune/R)
	if (!user || !R)
		return

	if (blood_text)
		to_chat(user, span_warning("Nie możesz nasycić talizmanu, na którym już coś napisano.") )
		return

	var/datum/rune_spell/spell = get_rune_spell(user, null, "examine", R.word1, R.word2, R.word3)
	if(initial(spell.talisman_absorb) == RUNE_CANNOT)//placing a talisman on a Conjure Talisman rune to try and fax it
		user.dropItemToGround(src)
		src.forceMove(get_turf(R))
		R.attack_hand(user)
	else
		if (attuned_rune)
			to_chat(user, span_warning("[capitalize(src.name)] jest już nasycony mocą runy.") )
			return

		if (!spell)
			to_chat(user, span_warning("W tych runach nie ma mocy. [capitalize(src.name)] nie reaguje.") )
			return

		//blood markings
		overlays += image(icon, "talisman-[R.word1.icon_state]a")
		overlays += image(icon, "talisman-[R.word2.icon_state]a")
		overlays += image(icon, "talisman-[R.word3.icon_state]a")
		//black markings
		overlays += image(icon, "talisman-[R.word1.icon_state]")
		overlays += image(icon, "talisman-[R.word2.icon_state]")
		overlays += image(icon, "talisman-[R.word3.icon_state]")

		spell_type = spell
		uses = initial(spell.talisman_uses)

		var/talisman_interaction = initial(spell.talisman_absorb)
		var/datum/rune_spell/active_spell = R.active_spell
		if(!istype(R))
			return
		name = "talizman: [active_spell.name]"
		if (active_spell)//some runes may change their interaction type dynamically (ie: Path Exit runes)
			talisman_interaction = active_spell.talisman_absorb
			if (istype(active_spell, /datum/rune_spell/portalentrance))
				var/datum/rune_spell/portalentrance/entrance = active_spell
				if (entrance.network)
					word_pulse(GLOB.rune_words[entrance.network])
			else if (istype(active_spell, /datum/rune_spell/portalexit))
				var/datum/rune_spell/portalentrance/exit = active_spell
				if (exit.network)
					word_pulse(GLOB.rune_words[exit.network])

		switch(talisman_interaction)
			if (RUNE_CAN_ATTUNE)
				playsound(src, 'aquila/sound/bloodcult/talisman_attune.ogg', 50, 0, -5)
				to_chat(user, span_notice("[capitalize(src.name)] może teraz zdalnie uruchomić runę [initial(spell.name)].") )
				attuned_rune = R
			if (RUNE_CAN_IMBUE)
				playsound(src, 'aquila/sound/bloodcult/talisman_imbue.ogg', 50, 0, -5)
				to_chat(user, span_notice("[capitalize(src.name)] wchłania moc runy [initial(spell.name)].") )
				qdel(R)
			if (RUNE_CANNOT)//like, that shouldn't even be possible because of the earlier if() check, but just in case.
				message_admins("Error! ([key_name(user)]) managed to imbue a Conjure Talisman rune. That shouldn't be possible!")
				return

/obj/item/talisman/proc/word_pulse(datum/rune_word/W)
	var/image/I1 = image(icon, "talisman-[W.icon_state]a")
	animate(I1, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5, loop = -1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	overlays += I1
	var/image/I2 = image(icon, "talisman-[W.icon_state]")
	animate(I2, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5, loop = -1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	overlays += I2
