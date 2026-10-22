// AQUILA - deck do nagrywania kaset z Monkestation (machines/stationary_mixer.dm).
// Metadane utworu daje yt-dlp (aquila_ytdl_resolve) zamiast Floxy: przy okazji sprawdzamy, czy utwór w ogóle da się zagrać.

/obj/machinery/cassette_deck
	name = "deck kasetowy"
	desc = "Stacjonarny magnetofon do nagrywania utworów z sieci na kasety i zmiany naklejek."
	icon = 'aquila/icons/obj/cassettes/adv_cassette_deck.dmi'
	icon_state = "cassette_deck"
	density = TRUE
	anchored = TRUE
	pass_flags = PASSTABLE
	idle_power_usage = 10
	var/obj/item/cassette_tape/tape
	/// Trwa pobieranie danych utworu
	var/busy = FALSE

/obj/machinery/cassette_deck/Destroy()
	if(tape)
		tape.forceMove(drop_location())
		tape = null
	return ..()

/obj/machinery/cassette_deck/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[tape ? "W środku jest kaseta. <b>Alt-klik</b>, żeby ją wyjąć." : "Włóż kasetę, żeby nagrać na nią utwory."]</span>"

/obj/machinery/cassette_deck/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/cassette_deck/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/cassette_tape))
		return ..()
	if(tape)
		balloon_alert(user, "najpierw wyjmij kasetę!")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	tape = I
	playsound(src, pick(GLOB.cassette_put_in_sounds), 50, FALSE)
	balloon_alert(user, "włożono kasetę")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/cassette_deck/AltClick(mob/user)
	if(!tape || !user.canUseTopic(src, !issilicon(user)))
		return ..()
	eject_tape(user)

/obj/machinery/cassette_deck/proc/eject_tape(mob/user)
	if(!tape)
		return FALSE
	if(busy)
		balloon_alert(user, "zajęty!")
		return FALSE
	playsound(src, pick(GLOB.cassette_take_out_sounds), 50, FALSE)
	tape.forceMove(drop_location())
	user?.put_in_hands(tape)
	tape = null
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/cassette_deck/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteDeck", name)
		ui.open()

/obj/machinery/cassette_deck/ui_static_data(mob/user)
	. = list("icon" = 'aquila/icons/obj/cassettes/walkman.dmi', "max_songs" = MAX_SONGS_PER_CASSETTE_SIDE)
	var/list/designs = list()
	for(var/design_name in GLOB.cassette_icons)
		designs += list(list("name" = design_name, "icon_state" = GLOB.cassette_icons[design_name]))
	.["designs"] = designs

/obj/machinery/cassette_deck/ui_data(mob/user)
	. = list("busy" = busy, "cassette" = null)
	var/datum/cassette/cassette = tape?.cassette_data
	if(!cassette)
		return
	var/datum/cassette_side/side = tape.get_current_side()
	.["cassette"] = list(
		"name" = html_decode(cassette.name || tape.name),
		"desc" = html_decode(cassette.desc),
		"status" = cassette.status,
		"author" = cassette.author.name,
		"side" = tape.flipped ? "B" : "A",
		"design" = side.design,
		"songs" = side.ui_songs(),
	)

/obj/machinery/cassette_deck/ui_act(action, list/params)
	. = ..()
	if(. || !tape)
		return
	var/mob/user = usr
	var/datum/cassette_side/side = tape.get_current_side()
	switch(action)
		if("eject")
			eject_tape(user)
			return TRUE
		if("flip")
			if(busy)
				return
			tape.flipped = !tape.flipped
			tape.update_cassette_appearance()
			playsound(src, pick(GLOB.cassette_asmr_sounds), 50, FALSE)
			return TRUE
		if("add")
			if(!can_edit(user))
				return
			INVOKE_ASYNC(src, .proc/add_track, user, trim("[params["url"]]"))
			return TRUE
		if("remove")
			if(!can_edit(user))
				return
			var/index = text2num("[params["index"]]")
			if(!index || index < 1 || index > length(side.songs))
				return
			var/datum/cassette_song/song = side.songs[index]
			side.songs.Cut(index, index + 1)
			qdel(song)
			tape.cassette_data.status = CASSETTE_STATUS_UNAPPROVED
			tape.cassette_data.id = null
			balloon_alert(user, "usunięto utwór")
			return TRUE
		if("set_design")
			var/new_design = params["design"]
			if(!(new_design in GLOB.cassette_icons))
				return
			side.design = GLOB.cassette_icons[new_design]
			tape.update_cassette_appearance()
			return TRUE

/// Zmiany utworów: zatwierdzonej kasety nie przerabiamy (wtedy straciłaby status), w trakcie recenzji też nie
/obj/machinery/cassette_deck/proc/can_edit(mob/user)
	if(busy)
		balloon_alert(user, "zajęty!")
		return FALSE
	var/status = tape.cassette_data.status
	if(status == CASSETTE_STATUS_REVIEWING)
		balloon_alert(user, "kaseta jest w recenzji!")
		return FALSE
	return TRUE

/obj/machinery/cassette_deck/proc/add_track(mob/user, url)
	var/datum/cassette_side/side = tape?.get_current_side()
	if(!side || busy)
		return FALSE
	if(length(side.songs) >= MAX_SONGS_PER_CASSETTE_SIDE)
		balloon_alert(user, "strona jest pełna!")
		return FALSE
	if(!findtext(url, GLOB.is_http_protocol))
		balloon_alert(user, "to nie jest link http(s)!")
		return FALSE
	if(findtext(url, "spotify.com") || findtext(url, "music.apple.com") || findtext(url, "deezer.com") || findtext(url, "tidal.com"))
		to_chat(user, "<span class='warning'>Ten serwis nie jest obsługiwany. Użyj linku z YouTube, SoundCloud albo Bandcamp.</span>")
		return FALSE
	if(!aquila_ytdl_command())
		to_chat(user, "<span class='warning'>Na serwerze nie ma yt-dlp, nie da się nagrywać utworów.</span>")
		return FALSE
	busy = TRUE
	SStgui.update_uis(src)
	var/obj/item/cassette_tape/working_tape = tape
	var/list/result = aquila_ytdl_resolve(url)
	busy = FALSE
	if(QDELETED(src))
		return FALSE
	SStgui.update_uis(src)
	if(tape != working_tape)
		return FALSE
	if(!result)
		to_chat(user, "<span class='warning'>Nie udało się nagrać utworu. Sprawdź link (YouTube, SoundCloud, Bandcamp) - utwór nie może być prywatny, transmisją na żywo ani dłuższy niż 15 minut.</span>")
		return FALSE
	var/list/data = result["data"]
	var/page_url = data["webpage_url"] || url
	var/datum/cassette_song/song = new(data["track"] || data["title"] || page_url, page_url, result["duration"], data["artist"] || data["uploader"], data["album"])
	side.songs += song
	tape.cassette_data.status = CASSETTE_STATUS_UNAPPROVED
	tape.cassette_data.id = null // zmieniona kaseta to już inne nagranie niż zatwierdzone
	playsound(src, pick(GLOB.cassette_put_in_sounds), 40, FALSE)
	to_chat(user, "<span class='notice'>Nagrano utwór „[song.name]” na [tape].</span>")
	SStgui.update_uis(src)
	return TRUE
