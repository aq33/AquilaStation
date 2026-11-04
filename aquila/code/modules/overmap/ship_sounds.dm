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
/// Co ile sprawdzamy, czy stan krytyczny już minął.
#define AQUILA_HULL_CREAK_CHECK (10 SECONDS)

/obj/structure/overmap
	/// Pętla skrzypienia kadłuba gra, dopóki superstruktura jest w stanie krytycznym.
	var/aquila_hull_creaking = FALSE

/obj/structure/overmap/handle_crit(damage_amount)
	. = ..()
	if(structure_crit && !aquila_hull_creaking)
		aquila_hull_creaking = TRUE
		aquila_hull_creak_play(TRUE)
		addtimer(CALLBACK(src, PROC_REF(aquila_hull_creak_check)), AQUILA_HULL_CREAK_CHECK)

/// Pętla gra ciszej niż alarmy (relay gra na 100), tylko dla osób z włączonymi dźwiękami otoczenia.
/obj/structure/overmap/proc/aquila_hull_creak_play(start)
	for(var/mob/M as anything in mobs_in_ship)
		if(!M.client)
			continue
		if(!start)
			M.stop_sound_channel(AQUILA_CHANNEL_HULL_CREAK)
			continue
		if(!(M.client.prefs.toggles & PREFTOGGLE_SOUND_AMBIENCE) || !M.can_hear())
			continue
		SEND_SOUND(M, sound('nsv13/sound/ambience/creaking_ambience.ogg', repeat = TRUE, wait = 0, volume = 35, channel = AQUILA_CHANNEL_HULL_CREAK))

/// Stan krytyczny kończy się w kilku miejscach (naprawa pancerza, pompa nanitów), więc zamiast haków w każdym z nich sprawdzamy go co jakiś czas.
/obj/structure/overmap/proc/aquila_hull_creak_check()
	if(QDELETED(src))
		return
	if(structure_crit)
		addtimer(CALLBACK(src, PROC_REF(aquila_hull_creak_check)), AQUILA_HULL_CREAK_CHECK)
		return
	aquila_hull_creaking = FALSE
	aquila_hull_creak_play(FALSE)

#undef AQUILA_CHANNEL_HULL_CREAK
#undef AQUILA_HULL_CREAK_CHECK
