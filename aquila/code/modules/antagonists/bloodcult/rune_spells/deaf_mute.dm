
/datum/rune_spell/deafmute
	name = "Głuchoniemota"
	desc = "Ogłusza pobliskich wrogów. Także roboty."
	desc_talisman = "Ogłusza pobliskich wrogów. Także roboty. Działa krócej niż z runy."
	invocation = "Sti' kaliedir!"
	word1 = /datum/rune_word/hide
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/see
	page = "Ta runa sprawia, że każdy spoza kultu (ludzie i roboty) w promieniu 7 pól przestaje słyszeć na 50 sekund. \
		Z talizmanu czasy są krótsze, chyba że przyłożysz go bezpośrednio do kogoś, wtedy efekt dotyczy tylko jego.\
		<br><br>Runa świetnie sieje zamęt i opóźnia przybycie ochrony, może też dobrze współgrać z talizmanem Ogłuszenia użytym na obszar. Jedyny minus: nie usłyszysz, jak krzyczą, skoro są niemi."
	var/deaf_rune_duration= 50 SECONDS//times are in seconds
	var/deaf_talisman_duration = 30 SECONDS
	var/mute_rune_duration = 25 SECONDS
	var/mute_talisman_duration = 15 SECONDS
	var/effect_range = 7
	touch_cast = 1

/datum/rune_spell/deafmute/cast_touch(mob/living/M)
	invoke(activator, invocation, 1)

	var/deaf_duration = deaf_rune_duration
	var/mute_duration = mute_rune_duration
	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	if (!IS_CULTIST(M) && M.mind && M.stat != DEAD)
		cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "deafmute_papered", M)
	deafmute(M, deaf_duration, mute_duration)

	qdel(src)

/datum/rune_spell/deafmute/cast(deaf_duration = deaf_rune_duration, mute_duration = mute_rune_duration)
	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	for(var/mob/living/M in range(effect_range, get_turf(spell_holder)))
		if (IS_CULTIST(M))
			continue
		if (M.stat != DEAD)
			cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "deafmute", M)
		deafmute(M, deaf_duration, mute_duration)
	qdel(spell_holder)

/// Wspólny efekt runy i talizmanu (w drafcie zdublowany w obu procach)
/datum/rune_spell/deafmute/proc/deafmute(mob/living/M, deaf_duration, mute_duration)
	M.overlay_fullscreen("deafborder", /atom/movable/screen/fullscreen/deafmute_border)//victims see a red overlay fade in-out for a second
	M.update_fullscreen_alpha("deafborder", 100, 5)
	if (!(HAS_TRAIT(M, TRAIT_DEAF)))
		to_chat(M, span_notice("Świat wokół ciebie nagle cichnie.") )
	if (!(HAS_TRAIT(M, TRAIT_MUTE)))
		if (iscarbon(M))
			to_chat(M, span_warning("Przeszywa cię straszny chłód! Nie jesteś w stanie wydusić słowa...") )
		else if (issilicon(M))
			to_chat(M, span_warning("Wygląda na to, że zwarcie tymczasowo wyłączyło twój głośnik!") )

	ADD_TRAIT(M, TRAIT_MUTE, "rune")
	ADD_TRAIT(M, TRAIT_DEAF, "rune")

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_deaf), M), deaf_duration)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_mute), M), mute_duration)
	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, update_fullscreen_alpha), "deafborder", 0, 5), 8)
	addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, clear_fullscreen), "deafborder", FALSE), 16)

/datum/rune_spell/deafmute/cast_talisman()
	cast(deaf_talisman_duration, mute_talisman_duration)

/proc/remove_deaf(mob/remover) //fuicking why does this not work on server if its not a global
	REMOVE_TRAIT(remover, TRAIT_DEAF, "rune")

/proc/remove_mute(mob/remover)
	REMOVE_TRAIT(remover, TRAIT_MUTE, "rune")
