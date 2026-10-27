
/datum/rune_spell/stun
	name = "Ogłuszenie"
	desc = "Przeciąża zmysły wszystkich wokół falą czystej, chaotycznej energii. Kultyści dochodzą do siebie trochę szybciej."
	desc_talisman = "Użyj, by wywołać wybuch o mniejszym zasięgu, albo dotknij kogoś talizmanem, by skupić całą moc zaklęcia na nim."
	invocation = "Fuu ma'jin!"
	touch_cast = TRUE
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/hide
	word3 = /datum/rune_word/technology
	page = "Skupione chaotyczne energie, gwałtownie uwolnione, na chwilę osłabiają każdego w dużym promieniu, nawet kultystów, choć ci dochodzą do siebie sekundę szybciej.\
		<br><br>Rzucona z talizmanu energia działa w mniejszym promieniu i krócej, co wciąż może się przydać w ciasnym pomieszczeniu.\
		<br><br>Prawdziwe przeznaczenie tej runy w talizmanie objawia się jednak, gdy dotkniesz nim kogoś bezpośrednio: cała energia skupia się na jego ciele, \
		paraliżując go i odbierając mowę na dłużej. Stworzono to, by kultyści mogli łatwo porywać członków załogi do konwersji albo na tortury."


/datum/rune_spell/stun/pre_cast()
	var/mob/living/user = activator

	if (istype (spell_holder, /obj/effect/new_rune))
		invoke(user, invocation)
		cast()
	else if (istype (spell_holder, /obj/item/talisman))
		invoke(user, invocation, 1)
		cast_talisman()

/datum/rune_spell/stun/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	new/obj/effect/cult_ritual/stun(R.loc, 1, activator)

	qdel(R)

/datum/rune_spell/stun/cast_talisman()
	var/turf/T = get_turf(spell_holder)
	new/obj/effect/cult_ritual/stun(T, 2, activator)
	qdel(src)

/datum/rune_spell/stun/cast_touch(mob/living/M)
	anim(target = M, a_icon = 'aquila/icons/bloodcult/64x64.dmi', flick_anim = "touch_stun", offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)

	playsound(spell_holder, 'aquila/sound/bloodcult/stun_talisman.ogg', 25, 0, -5)
	// AQUILA - nie mamy stroju kapłanki świątyni (shrine maiden), zostaje sama szansa
	if (prob(15))//for old times' sake
		invoke(activator, "Dream sign ''Evil sealing talisman''!", 1)
	else
		invoke(activator, invocation, 1)

	if (M.stat != DEAD)
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
		cult_datum?.gain_devotion(100, DEVOTION_TIER_2, "stun_papered", M)

	if(issilicon(M))
		to_chat(M, span_danger("UWAGA: wykryto zwarcia, ponowne uruchamianie...") )
		M.Knockdown(9 SECONDS)

	else if(iscarbon(M))
		to_chat(M, span_danger("Mroczne energie chwytają twoje kończyny. Sztywniejesz i padasz.") )
		var/mob/living/carbon/C = M
		C.Knockdown(5 SECONDS)//used to be 25
		C.Stun(5 SECONDS)//used to be 25
		if (isalien(C))
			C.Paralyze(5 SECONDS)

	if (!(locate(/obj/effect/stun_indicator) in M))
		new /obj/effect/stun_indicator(M)

	qdel(src)

/obj/effect/cult_ritual/stun
	icon_state = null
	color = "black"
	anchored = 1
	alpha = 0
	mouse_opacity = 0
	var/stun_duration = 10 SECONDS
	var/stun_type = 1
	var/mob/living/carbon/caster

/obj/effect/cult_ritual/stun/New(turf/loc, stun_type = 1, mob/living/carbon/caster)
	..()
	src.stun_type = stun_type
	src.caster = caster

	switch (stun_type)
		if (1)
			stun_duration = 10 SECONDS
			anim(target = loc, a_icon = 'aquila/icons/bloodcult/64x64.dmi', flick_anim = "rune_stun", sleeptime = 20, offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'aquila/icons/bloodcult/480x480.dmi'
			pixel_x = -224
			pixel_y = -224
			animate(src, alpha = 255, time = 10)
		if (2)
			stun_duration = 5 SECONDS
			anim(target = loc, a_icon = 'aquila/icons/bloodcult/64x64.dmi', flick_anim = "talisman_stun", sleeptime = 20, offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'aquila/icons/bloodcult/224x224.dmi'
			pixel_x = -96
			pixel_y = -96
			animate(src, alpha = 255, time = 10)

	playsound(src, 'aquila/sound/bloodcult/stun_rune_charge.ogg', 75, 0, 0)
	addtimer(CALLBACK(src, PROC_REF(explode)), 2 SECONDS)

/obj/effect/cult_ritual/stun/Destroy()
	caster = null
	return ..()

/obj/effect/cult_ritual/stun/proc/explode()
	playsound(src, 'aquila/sound/bloodcult/stun_rune.ogg', 75, 0, 0)
	visible_message(span_warning("Runa eksploduje jasnym błyskiem chaotycznej energii.") )

	for(var/mob/living/L in dview(7, get_turf(src)))
		var/duration = stun_duration
		var/dist = cheap_pythag(L.x - src.x, L.y - src.y)
		if (stun_type == 1 && dist >= 8)
			continue
		if (stun_type == 2 && dist >= 4)//talismans have a reduced range
			continue
		shadow(L, loc, "rune_stun")
		if (IS_CULTIST(L))
			duration = 1 SECONDS
		else if (caster)
			if (L.stat != DEAD)
				var/datum/antagonist/cult/cult_datum = IS_CULTIST(caster)
				cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "stun_rune", L)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.Knockdown(duration)
			C.Stun(duration)
			if (isalien(C))
				C.Paralyze(duration)

		else if(issilicon(L))
			var/mob/living/silicon/S = L
			S.Knockdown(duration)
	qdel(src)
