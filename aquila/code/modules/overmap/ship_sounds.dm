// Podpięcie dźwięków, które leżały w repo bez użycia (myśliwiec, turbowinda, skrzypienie kadłuba).

/// Działko myśliwca rozkręca się przy wybraniu (zamiast ogólnego pdc_start).
/datum/overmap_ship_weapon/fighter/primary
	overmap_select_sound = 'nsv13/sound/effects/fighters/autocannon_start.ogg'

/// Drzwi turbowindy mają własny dźwięk otwierania i zamykania.
/obj/machinery/door/airlock/ship/public/glass/turbolift
	doorOpen = 'nsv13/sound/effects/lift/doorsopening.ogg'
	doorClose = 'nsv13/sound/effects/lift/doorsclosing.ogg'

/// Kanał pętli skrzypienia kadłuba (1016 był wolny między CHANNEL_BUZZ a CHANNEL_SHIP_ALERT).
#define AQUILA_CHANNEL_HULL_CREAK 1016
/// Co ile sprawdzamy, czy stan krytyczny już minął, i uzgadniamy słuchaczy.
#define AQUILA_HULL_CREAK_CHECK (10 SECONDS)

/obj/structure/overmap
	/// Pętla skrzypienia kadłuba gra, dopóki superstruktura jest w stanie krytycznym.
	var/aquila_hull_creaking = FALSE
	/// Komu wysłaliśmy pętlę: zatrzymujemy ją też tym, którzy w międzyczasie opuścili statek albo zostali duchem.
	var/list/aquila_hull_creak_listeners

/obj/structure/overmap/handle_crit(damage_amount)
	. = ..()
	if(structure_crit && !aquila_hull_creaking)
		aquila_hull_creaking = TRUE
		aquila_hull_creak_play(TRUE)
		addtimer(CALLBACK(src, PROC_REF(aquila_hull_creak_check)), AQUILA_HULL_CREAK_CHECK)

/// Klienci, którzy powinni teraz słyszeć skrzypienie: załoga okrętu i jednostek w nim (myśliwce w hangarze),
/// zbierana tak samo jak w relay(); tylko z włączonymi dźwiękami otoczenia.
/obj/structure/overmap/proc/aquila_hull_creak_hearers(list/hearers = list())
	for(var/mob/M as anything in mobs_in_ship)
		if(M.client && (M.client.prefs.toggles & PREFTOGGLE_SOUND_AMBIENCE) && M.can_hear())
			hearers |= M.client
	for(var/obj/structure/overmap/O as anything in overmaps_in_ship)
		O.aquila_hull_creak_hearers(hearers)
	return hearers

/// Uzgadnia, kto słyszy pętlę: nowym słuchaczom ją puszcza, tym, którzy odlecieli, zginęli albo zostali duchem, ją ucina.
/// Pętla gra ciszej niż alarmy (relay gra na 100). Bez `start` ucina ją wszystkim.
/obj/structure/overmap/proc/aquila_hull_creak_play(start)
	var/list/hearers = start ? aquila_hull_creak_hearers() : list()
	// klient, nie mob: pętla zostaje u gracza także po wyjściu ze statku, śmierci czy duchu
	for(var/client/C as anything in aquila_hull_creak_listeners)
		if(C && !(C in hearers))
			SEND_SOUND(C, sound(null, channel = AQUILA_CHANNEL_HULL_CREAK))
	for(var/client/C as anything in hearers)
		if(!(C in aquila_hull_creak_listeners))
			SEND_SOUND(C, sound('nsv13/sound/ambience/creaking_ambience.ogg', repeat = TRUE, wait = 0, volume = 35, channel = AQUILA_CHANNEL_HULL_CREAK))
	aquila_hull_creak_listeners = length(hearers) ? hearers : null

/obj/structure/overmap/Destroy()
	if(aquila_hull_creaking)
		aquila_hull_creak_play(FALSE)
	return ..()

/// Stan krytyczny kończy się w kilku miejscach (naprawa pancerza, pompa nanitów), więc zamiast haków w każdym z nich
/// sprawdzamy go co jakiś czas; przy okazji uzgadniamy słuchaczy z obecną załogą.
/obj/structure/overmap/proc/aquila_hull_creak_check()
	if(QDELETED(src))
		return
	if(structure_crit)
		aquila_hull_creak_play(TRUE)
		addtimer(CALLBACK(src, PROC_REF(aquila_hull_creak_check)), AQUILA_HULL_CREAK_CHECK)
		return
	aquila_hull_creaking = FALSE
	aquila_hull_creak_play(FALSE)

#undef AQUILA_CHANNEL_HULL_CREAK
#undef AQUILA_HULL_CREAK_CHECK
