/obj/machinery/jukebox/shipwide
	name = "okrętowy system nagłośnienia Seegson SG-2000"
	desc = "Gigantyczny system głośników z wbudowanymi wzmacniaczami, który przekazuje komunikaty wszystkim na statku. Mocno go przerobiono, żeby mógł puszczać muzykę na cały statek. Relacje o jego powstaniu się różnią, ale najpopularniejsza mówi o kilku znudzonych inżynierach, którzy mieli dość słuchania zatwierdzonych przez firmę komunikatów motywacyjnych."
	icon = 'nsv13/icons/obj/large_computers.dmi'
	pixel_y = 26
	bound_x = 64
	req_access = list(ACCESS_MINING)
	anchored = TRUE
	density = FALSE
	flags_1 = NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

// AQUILA EDIT 
// /obj/machinery/jukebox/shipwide/process()
// 	if(world.time < stop && active)
// 		var/sound/song_played = sound(selection.song_path)
// 		var/obj/structure/overmap/linked = get_overmap()
// 		if(!linked) //Don't use this on things with no overmap dumbass
// 			return PROCESS_KILL
// 		for(var/mob/M as() in linked.mobs_in_ship)
// 			if(!M.client || !(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS))
// 				continue
// 			if(!(M in rangers))
// 				rangers[M] = TRUE
// 				SEND_SOUND(M, sound(song_played, repeat = 0, wait = 0, volume = 100, channel = CHANNEL_JUKEBOX))
// 			//	M.playsound_local(get_turf(M), null, 100, channel = CHANNEL_JUKEBOX, S = song_played)
// 		for(var/mob/L in rangers)
// 			if(!(L in linked.mobs_in_ship))
// 				rangers -= L
// 				if(!L || !L.client)
// 					continue
// 				L.stop_sound_channel(CHANNEL_JUKEBOX) //Handle em leaving our ship
// 	else if(active)
// 		active = FALSE
// 		STOP_PROCESSING(SSobj, src)
// 		dance_over()
// 		playsound(src,'sound/machines/terminal_off.ogg',50,1)
// 		update_icon()
// 		stop = world.time + 100
