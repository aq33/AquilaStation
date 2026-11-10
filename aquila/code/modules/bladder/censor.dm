// AQUILA - Cenzura treści fizjologicznych: jeden przełącznik w ustawieniach gry (strona Rozgrywka).
// Włączony: bez komunikatów i dźwięków wypróżniania i oddawania moczu (cudzych, a własne łagodnie),
// bez obrzydzenia od cudzych, kupa i plamy moczu widziane jako czarny brud (także w menu prawego przycisku),
// mocz w kałuży jako amoniak (w zlewkach i skanerach zostaje nazwa reagentu).

/datum/preferences
	/// Ukrywa wypróżnianie i oddawanie moczu
	var/hide_bodily_functions = FALSE

/datum/preference/toggle/player/hide_bodily_functions
	db_key = "hide_bodily_functions"
	player_var = "hide_bodily_functions"

/datum/preference/toggle/player/hide_bodily_functions/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.mob?.refresh_bodily_censor()

/// Czy ten mob ma włączoną cenzurę
/mob/proc/censors_bodily_functions()
	return client?.prefs?.hide_bodily_functions

/// Wiadomość o wypróżnieniu: cenzurujący widzowie jej nie dostają, a sam załatwiający dostaje łagodną wersję
/// Odbiorców liczy jak /atom/visible_message: hearers() z duchami, oko SI i hologram holopadu (one dokładają SI i rozmówcę
/// dopiero po odjęciu ignored_mobs, więc na liście ląduje samo oko albo hologram)
/mob/living/proc/bodily_visible_message(message, self_message)
	var/list/censored = list()
	var/turf/T = get_turf(src)
	for(var/atom/movable/hearer in (T ? hearers(DEFAULT_MESSAGE_RANGE, T) : list()))
		if(hearer == src)
			continue
		if(istype(hearer, /mob/camera/ai_eye))
			var/mob/camera/ai_eye/eye = hearer
			if(eye.ai?.censors_bodily_functions())
				censored += eye
		else if(istype(hearer, /obj/effect/overlay/holo_pad_hologram))
			var/obj/effect/overlay/holo_pad_hologram/holo = hearer
			if(holo.Impersonation?.censors_bodily_functions())
				censored += holo
		else if(ismob(hearer))
			var/mob/M = hearer
			if(M.censors_bodily_functions())
				censored += M
	if(self_message && censors_bodily_functions())
		self_message = "<span class='notice'>Załatwiasz potrzebę.</span>"
	visible_message(message, self_message, ignored_mobs = censored)

/// Obrzydzenie widzów (cenzurujący nic nie widzieli)
/mob/living/proc/bodily_disgust(amount, include_self = FALSE)
	for(var/mob/living/L in viewers(7, get_turf(src)))
		if(L == src && !include_self)
			continue
		if(L != src && L.censors_bodily_functions())
			continue
		L.adjust_disgust(amount)

/// Dźwięk wypróżnienia tylko dla niecenzurujących: słuchacze, zasięg i zanik jak w playsound() (przez ściany, piętra, duchy)
/proc/bodily_playsound(atom/source, soundin, vol)
	var/turf/turf_source = get_turf(source)
	if(!turf_source)
		return
	var/maxdistance = SOUND_RANGE
	var/channel = SSsounds.random_available_channel()
	var/frequency = get_rand_frequency()
	var/sound/S = sound(get_sfx(soundin))
	var/list/listeners = list()
	for(var/z in get_zs_in_range(turf_source.z, maxdistance / (MULTI_Z_DISTANCE + 1)))
		listeners += SSmobs.clients_by_zlevel[z]
		listeners += SSmobs.dead_players_by_zlevel[z]
	for(var/mob/M as anything in listeners)
		if(get_dist(M, turf_source) > maxdistance || M.censors_bodily_functions())
			continue
		M.playsound_local(turf_source, soundin, vol, TRUE, frequency, SOUND_FALLOFF_EXPONENT, channel, TRUE, S, maxdistance, SOUND_DEFAULT_FALLOFF_DISTANCE)

/datum/atom_hud/alternate_appearance/basic/bodily_censor

/datum/atom_hud/alternate_appearance/basic/bodily_censor/New()
	..()
	for(var/mob/M as anything in GLOB.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/bodily_censor/mobShouldSee(mob/M)
	return M.censors_bodily_functions()

/// Login woła onNewMob za każdym razem (reconnect, powrót z ducha, przejęcie ciała), a add_hud_to dla obecnego widza
/// tylko zwiększa licznik. Tu najwyżej jeden wpis na widza, a kto nie cenzuruje, traci obrazki całkiem.
/datum/atom_hud/alternate_appearance/basic/bodily_censor/onNewMob(mob/M)
	if(!mobShouldSee(M))
		if(hudusers[M])
			remove_hud_from(M, TRUE)
		return
	if(!hudusers[M])
		add_hud_to(M)

/// Usunięty widz (np. mob z lobby po wejściu do gry) odpina się sam, a wygląd zostaje dla reszty.
/// Bazowe unregister_mob() woła remove_from_hud(), które w /basic kasuje cały wygląd.
/datum/atom_hud/alternate_appearance/basic/bodily_censor/unregister_mob(datum/source, force)
	remove_hud_from(source, TRUE)
	if(source == target)
		remove_from_hud(source)

/// Zamiast kupy i plam moczu cenzurujący widzą czarny brud
/atom/proc/add_bodily_censor_appearance()
	var/obj/effect/decal/cleanable/dirt/dirt_type = /obj/effect/decal/cleanable/dirt
	var/image/censored = image(initial(dirt_type.icon), src, initial(dirt_type.icon_state), layer)
	censored.color = "#1c1c1c"
	censored.override = TRUE
	censored.name = "brud" // obrazek z override i własną nazwą podmienia ją też w menu prawego przycisku i podpowiedzi
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/bodily_censor, "bodily_censor", censored)

/// Po zmianie przełącznika: przelicza, kto widzi zastępczy wygląd
/mob/proc/refresh_bodily_censor()
	var/should_see = censors_bodily_functions()
	for(var/datum/atom_hud/alternate_appearance/basic/bodily_censor/censor in GLOB.active_alternate_appearances)
		if(should_see)
			if(!censor.hudusers[src])
				censor.add_hud_to(src)
		else
			censor.remove_hud_from(src, TRUE)

/obj/effect/decal/cleanable/feces/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	add_bodily_censor_appearance()

/obj/effect/decal/cleanable/feces/get_examine_name(mob/user)
	if(user?.censors_bodily_functions())
		return "brud"
	return ..()

/obj/effect/decal/cleanable/feces/examine(mob/user)
	if(user?.censors_bodily_functions())
		return list("To jest brud.", "Ktoś powinien to posprzątać.")
	return ..()
