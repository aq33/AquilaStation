// AQUILA - Cenzura treści fizjologicznych: jeden przełącznik w ustawieniach gry (strona Rozgrywka).
// Włączony: bez komunikatów i dźwięków wypróżniania i oddawania moczu (cudzych, a własne łagodnie),
// bez obrzydzenia od cudzych, kupa i plamy moczu widziane jako czarny brud, mocz w kałuży i skanerach jako amoniak.

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
/mob/living/proc/bodily_visible_message(message, self_message)
	var/list/censored = list()
	for(var/mob/M in get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src))
		if(M != src && M.censors_bodily_functions())
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

/// Dźwięk wypróżnienia tylko dla niecenzurujących
/proc/bodily_playsound(atom/source, soundin, vol)
	var/turf/T = get_turf(source)
	if(!T)
		return
	for(var/mob/M in get_hearers_in_view(world.view, T))
		if(!M.client || M.censors_bodily_functions())
			continue
		M.playsound_local(T, soundin, vol, TRUE)

/datum/atom_hud/alternate_appearance/basic/bodily_censor

/datum/atom_hud/alternate_appearance/basic/bodily_censor/New()
	..()
	for(var/mob/M as anything in GLOB.player_list)
		if(mobShouldSee(M))
			add_hud_to(M)

/datum/atom_hud/alternate_appearance/basic/bodily_censor/mobShouldSee(mob/M)
	return M.censors_bodily_functions()

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
			censor.add_hud_to(src)
		else
			censor.remove_hud_from(src)

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
