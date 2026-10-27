
/datum/rune_spell/conceal
	name = "Ukrycie"
	desc = "Ukrywa runy i budowle kultu. Niektórych run można używać w ukryciu, ale ich użycie może je odsłonić."
	desc_talisman = "Ukrywa runy i budowle kultu. Obejmuje mniejszy obszar niż z runy."
	invocation = "Kla'atu barada nikt'o!"
	word1 = /datum/rune_word/hide
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/blood
	page = "Ta runa ukrywa wszystkie runy i budowle w okręgu o promieniu 7 pól wokół niej. Nie da się ukryć runy ani budowli, którą odsłonięto mniej niż 10 sekund temu. Działa przez ściany.\
		<br><br>Wersja z talizmanu ma promień 5 pól."
	var/rune_effect_range = 7
	var/talisman_effect_range = 5

/datum/rune_spell/conceal/cast(effect_range = rune_effect_range, size = 'aquila/icons/bloodcult/480x480.dmi')
	var/turf/T = get_turf(spell_holder)
	var/obj/effect/abstract/animation = anim(target = T, a_icon = size, a_icon_state = "rune_conceal", offX = -32*effect_range, offY = -32*effect_range, plane = ABOVE_LIGHTING_PLANE)
	animation.alpha = 0
	animate(animation, alpha = 255, time = 2)
	animate(alpha = 0, time = 3)
	to_chat(activator, span_notice("Wszystkie runy i budowle kultu w zasięgu kryją się za cienką warstwą rzeczywistości."))
	playsound(T, 'aquila/sound/bloodcult/conceal.ogg', 50, 0, -5)
	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)

	for(var/obj/structure/cult/S in range(effect_range, T))
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		if (S.conceal_cooldown)
			continue
		if (dist <= effect_range+0.5)
			S.conceal()
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conceal_structure", S)


	for(var/obj/machinery/door/airlock/cult/S in range(effect_range, T))
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		// AQUILA - nasze drzwi kultu nie mają conceal_cooldown, pomijamy tylko już ukryte
		if (S.stealthy)
			continue
		if (dist <= effect_range+0.5)
			S.conceal()
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conceal_structure", S)

	for(var/obj/structure/destructible/cult/item_dispenser/dispenser in range(effect_range, T))
		var/dist = cheap_pythag(dispenser.x - T.x, dispenser.y - T.y)
		if (dist <= effect_range+0.5)
			dispenser.conceal()
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conceal_structure", dispenser)

	for(var/obj/effect/new_rune/R in range(effect_range, T))
		if (R == spell_holder)
			continue
		if (R.conceal_cooldown)
			continue
		var/dist = cheap_pythag(R.x - T.x, R.y - T.y)
		if (dist <= effect_range+0.5)
			R.conceal()
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "conceal_rune", R)
			var/obj/effect/abstract/trail = shadow(R, T, "rune_conceal")
			trail.alpha = 0
			animate(trail, alpha = 200, time = 2)
			animate(alpha = 0, time = 3)
	qdel(spell_holder)

/datum/rune_spell/conceal/cast_talisman()
	cast(talisman_effect_range, 'aquila/icons/bloodcult/352x352.dmi')
