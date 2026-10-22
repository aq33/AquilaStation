// AQUILA - kasety w jukeboxie (zamiast stacji DJ z Monkestation).
// Włożona kaseta zastępuje playlistę: jukebox gra utwory z bieżącej strony, a po wyjęciu wraca do zwykłej playlisty.
// Głośność, amp stacki i nadawanie na cały statek działają jak przy playliście.

/obj/machinery/jukebox
	/// Włożona kaseta - jej bieżąca strona to lista utworów
	var/obj/item/cassette_tape/inserted_tape

/obj/machinery/jukebox/AltClick(mob/user)
	if(inserted_tape && user.canUseTopic(src, !issilicon(user)))
		eject_tape(user)
		return
	return ..()

/// Czy gracz może zmieniać kasetę (te same uprawnienia co do obsługi jukeboxa)
/obj/machinery/jukebox/proc/can_change_tape(mob/user)
	if(!allowed(user) && verify)
		to_chat(user, "<span class='warning'>Nie masz uprawnień, aby korzystać z tego urządzenia.</span>")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, TRUE)
		return FALSE
	if(yt_busy)
		balloon_alert(user, "zajęty, chwilę!")
		return FALSE
	return TRUE

/obj/machinery/jukebox/proc/insert_tape(obj/item/cassette_tape/tape, mob/user)
	if(!can_change_tape(user))
		return FALSE
	var/obj/item/cassette_tape/old_tape = inserted_tape
	if(!user.transferItemToLoc(tape, src))
		return FALSE
	if(old_tape)
		inserted_tape = null
		user.put_in_hands(old_tape)
	inserted_tape = tape
	playsound(src, pick(GLOB.cassette_insert_sounds), 60, FALSE)
	balloon_alert(user, "włożono kasetę")
	log_game("[key_name(user)] inserted cassette [tape.name] ([tape.cassette_data.id || "no id"]) into [src] at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] włożył(a) kasetę \"[tape.name]\" do jukeboxa [ADMIN_JMP(src)]")
	load_tape_tracks()
	return TRUE

/obj/machinery/jukebox/proc/eject_tape(mob/user)
	if(!inserted_tape || !can_change_tape(user))
		return FALSE
	var/obj/item/cassette_tape/tape = inserted_tape
	inserted_tape = null
	if(yt_active)
		yt_stop()
	yt_tracks = list() // "Graj" wczyta znowu zwykłą playlistę
	yt_index = 0
	playsound(src, pick(GLOB.cassette_eject_sounds), 60, FALSE)
	tape.forceMove(drop_location())
	user?.put_in_hands(tape)
	updateUsrDialog()
	return TRUE

/obj/machinery/jukebox/proc/flip_tape(mob/user)
	if(!inserted_tape || !can_change_tape(user))
		return
	inserted_tape.flipped = !inserted_tape.flipped
	inserted_tape.update_cassette_appearance()
	playsound(src, pick(GLOB.cassette_asmr_sounds), 50, FALSE)
	load_tape_tracks()

/// Utwory z bieżącej strony kasety jako playlista jukeboxa
/obj/machinery/jukebox/proc/load_tape_tracks()
	var/was_active = yt_active
	if(yt_active)
		yt_stop()
	yt_tracks = list()
	yt_index = 0
	yt_prefetched = null
	for(var/datum/cassette_song/song as anything in inserted_tape?.get_current_side()?.songs)
		if(!findtext(song.url, GLOB.is_http_protocol))
			continue
		yt_tracks += list(list("id" = song.url, "url" = song.url, "title" = song.name || song.url, "duration" = song.duration))
	updateUsrDialog()
	if(was_active && yt_tracks.len)
		INVOKE_ASYNC(src, PROC_REF(yt_next))

/// Ramka kasety w oknie jukeboxa
/obj/machinery/jukebox/proc/tape_ui()
	if(!inserted_tape)
		return "<div class='jb-row jb-muted'>Możesz włożyć kasetę - zagra zamiast playlisty.</div>"
	var/list/dat = list()
	dat += "<div class='jb-label'>Kaseta</div>"
	dat += "<div class='jb-title'>[inserted_tape.name]</div>"
	dat += "<div class='jb-muted'>Strona [inserted_tape.flipped ? "B" : "A"] &middot; [yt_tracks.len] utworów</div>"
	dat += "<div class='jb-row'>[yt_link("yt_tape_flip", "Odwróć")][yt_link("yt_tape_eject", "Wyjmij")]</div>"
	return dat.Join()
