
/datum/rune_spell/reveal
	name = "Odsłonięcie"
	desc = "Odsłania to, co wcześniej ukryłeś, przerażając przy tym wrogów."
	desc_talisman = "Odsłania to, co wcześniej ukryłeś, przerażając przy tym wrogów. Działa krócej niż z runy."
	invocation = "Nikt'o barada kla'atu!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/hide
	page = "Ta runa (której słowa to słowa runy Ukrycia w odwrotnej kolejności) odsłania wszystkie runy i budowle w okręgu o promieniu 7 pól wokół niej.\
		<br><br>Każda odsłonięta runa ogłusza osoby spoza kultu w promieniu 3 pól, unieruchamiając je i odbierając mowę na 2 sekundy, łącznie do 10 sekund. Działa przez ściany. Ogłuszenie mija, jeśli ofiara zostanie odsunięta z miejsca, w którym stoi, chyba że wcześniej ją powalono, więc warto poprawić talizmanem Ogłuszenia."

	walk_effect = TRUE

	var/effect_range = 7
	var/shock_range = 3
	var/shock_per_obj = 2
	var/max_shock = 10
	var/last_threshold = -1
	var/total_uses = 5

/datum/rune_spell/reveal/cast()
	var/turf/T = get_turf(spell_holder)
	var/list/shocked = list()
	to_chat(activator, span_notice("Wszystkie ukryte runy i budowle kultu w zasięgu wracają do rzeczywistości, ogłuszając pobliskich wrogów.") )
	playsound(T, 'aquila/sound/bloodcult/reveal.ogg', 50, 0, -3)
	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)

	for(var/obj/structure/cult/concealed/S in range(effect_range, T))//only concealed structures trigger the effect
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		if (dist <= effect_range+0.5)
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "reveal_structure", S)
			anim(target = S, a_icon = 'aquila/icons/bloodcult/224x224.dmi', flick_anim = "rune_reveal", offX = -32*shock_range, offY = -32*shock_range, plane = ABOVE_LIGHTING_PLANE)
			reveal_shock(S, shocked)
			S.reveal()

	for(var/obj/machinery/door/airlock/cult/S in range(effect_range, T))//only concealed structures trigger the effect
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		// AQUILA - tylko ukryte drzwi (stealthy), jak w komentarzu wyżej
		if (S.stealthy && dist <= effect_range+0.5)
			cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "reveal_structure", S)
			anim(target = S, a_icon = 'aquila/icons/bloodcult/224x224.dmi', flick_anim = "rune_reveal", offX = -32*shock_range, offY = -32*shock_range, plane = ABOVE_LIGHTING_PLANE)
			reveal_shock(S, shocked)
			S.reveal()

	for(var/obj/effect/new_rune/R in range(effect_range, T))
		var/dist = cheap_pythag(R.x - T.x, R.y - T.y)
		if (dist <= effect_range+0.5)
			if (R.reveal())//only hidden runes trigger the effect
				cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "reveal_rune", R)
				anim(target = R, a_icon = 'aquila/icons/bloodcult/224x224.dmi', flick_anim = "rune_reveal", offX = -32*shock_range, offY = -32*shock_range, plane = ABOVE_LIGHTING_PLANE)
				reveal_shock(R, shocked)

	for(var/mob/living/L in shocked)
		if (L.stat != DEAD)
			cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "reveal_stun", L)
		new /obj/effect/cult_ritual/reveal(L.loc, L, shocked[L])
		to_chat(L, span_danger("Czujesz, jak przerażający wstrząs rozchodzi się po twoim ciele, gdy ukryte runy zostają odsłonięte!") )
		L.update_fullscreen_alpha("shockborder", 100, 5)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob, update_fullscreen_alpha), "shockborder", 0, 5), 8)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob, clear_fullscreen), "shockborder", FALSE), 16)

	qdel(spell_holder)

/// Zbiera osoby spoza kultu w zasięgu odsłoniętej rzeczy (w drafcie ta pętla była trzy razy)
/datum/rune_spell/reveal/proc/reveal_shock(atom/source, list/shocked)
	for(var/mob/living/L in viewers(source))
		if (IS_CULTIST(L))
			continue
		var/dist2 = cheap_pythag(L.x - source.x, L.y - source.y)
		if (dist2 > shock_range+0.5)
			continue
		shadow(L, get_turf(source), "rune_reveal")
		if (L in shocked)
			shocked[L] = min(shocked[L]+shock_per_obj, max_shock)
		else
			shocked[L] = 2

/datum/rune_spell/reveal/Added(mob/mover)
	if (total_uses <= 0)
		return
	if (!isliving(mover))
		return
	var/mob/living/L = mover
	if (last_threshold + 20 SECONDS > world.time)
		return
	if (!IS_CULTIST(L))
		total_uses--
		last_threshold = world.time
		var/list/seers = list()
		for (var/mob/living/seer in range(7, get_turf(spell_holder)))
			if (IS_CULTIST(seer) && seer.client)
				seers += seer

		cast_image(mover, seers, 10)

/datum/rune_spell/reveal/proc/cast_image(mob/mover, list/seers, count)
	if(count <= 0 || QDELETED(mover))
		return
	var/mob/living/L = mover
	// AQUILA - w drafcie /image/reveal z sygnałami (obraz to nie datum), u nas zwykły obraz na polu intruza
	var/image/image_intruder = image(loc = get_turf(L))
	image_intruder.appearance = L.appearance
	image_intruder.loc = get_turf(L)
	image_intruder.dir = L.dir
	image_intruder.plane = ABOVE_LIGHTING_PLANE
	image_intruder.alpha = 200
	image_intruder.color = COLOR_BLOOD
	for (var/mob/living/seer in seers)
		if (QDELETED(seer) || !seer.client)
			seers -= seer
			continue
		add_client_image(image_intruder, seer.client) // see the mover for a set period of time
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_client_image), image_intruder, seer.client), 4)
	animate(image_intruder, alpha = 0, time = 3)

	count--
	addtimer(CALLBACK(src, PROC_REF(cast_image), mover, seers, count), 1 SECONDS)

/datum/rune_spell/reveal/cast_talisman()
	shock_per_obj = 1.5
	max_shock = 8
	cast()


/obj/effect/cult_ritual/reveal
	anchored = 1
	icon_state = "rune_reveal"
	plane = ABOVE_LIGHTING_PLANE
	var/mob/living/victim = null
	var/duration = 2
	/// AQUILA - w vg flaga PROXMOVE, u nas monitor zbliżeń
	var/datum/proximity_monitor/proximity_monitor

/obj/effect/cult_ritual/reveal/Destroy()
	victim = null
	QDEL_NULL(proximity_monitor)
	if (loc)
		anim(target = loc, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "rune_reveal-stop", plane = ABOVE_LIGHTING_PLANE)
	return ..()

/obj/effect/cult_ritual/reveal/New(turf/loc, mob/living/vic = null, dur = 2)
	..()
	if (!vic)
		vic = locate() in loc
		if (!vic)
			qdel(src)
			return
	playsound(loc, 'aquila/sound/bloodcult/shock.ogg', 20, 0, 0)
	victim = vic
	duration = dur
	proximity_monitor = new(src, 1)
	// AQUILA - czasy w vg były w sekundach, u nas w decysekundach
	victim.Stun(duration SECONDS)
	if (isalien(victim))
		victim.Paralyze(duration SECONDS)
	addtimer(CALLBACK(src, PROC_REF(wear_off)), duration SECONDS)

/obj/effect/cult_ritual/reveal/proc/wear_off()
	if (loc && victim && victim.loc == loc && !victim.IsKnockdown())
		to_chat(victim, span_warning("Dochodzisz do siebie.") )
		victim.AdjustStun(-duration SECONDS)
		if (isalien(victim))
			victim.AdjustParalyzed(-duration SECONDS)
		victim = null
	qdel(src)

/obj/effect/cult_ritual/reveal/HasProximity(atom/movable/AM)//Pulling victims will immediately dispel the effects
	if (!victim)
		qdel(src)
		return

	if (victim.loc != loc)
		if (!victim.IsKnockdown())//if knockdown (by any cause), moving away doesn't purge you from the remaining stun.
			if (victim.pulledby)
				to_chat(victim, span_warning("Dochodzisz do siebie, gdy [victim.pulledby] cię odciąga.") )
			victim.AdjustStun(-duration SECONDS)
			if (isalien(victim))
				victim.AdjustParalyzed(-duration SECONDS)
			victim = null
		qdel(src)
