// AQUILA - walkman z Monkestation (walkman/_walkmen.dm). Zamiast Floxy link do utworu daje yt-dlp (aquila_ytdl_resolve),
// a muzykę wysyła SSjukeboxes: słuchający walkmana słyszy tylko go, jukeboxy i nagłośnienie są dla niego wyciszone.

/obj/item/walkman
	name = "walkman"
	desc = "Przenośny odtwarzacz kaset. Pierwszy trafił do sklepów ponad 200 lat temu i jakoś nie wychodzi z mody."
	icon = 'aquila/icons/obj/cassettes/walkman.dmi'
	icon_state = "walkman"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	custom_price = 150
	actions_types = list(/datum/action/item_action/walkman/play_pause, /datum/action/item_action/walkman/next_song, /datum/action/item_action/walkman/restart_song)
	var/obj/item/cassette_tape/inserted_tape
	/// Numer utworu na bieżącej stronie kasety
	var/track_index = 0
	var/playing = FALSE
	/// Bezpośredni link do pliku z yt-dlp
	var/stream_url
	var/list/extra_data
	/// world.time startu utworu - zmiana oznacza nowy utwór dla SSjukeboxes
	var/track_started = 0
	var/track_end = 0
	/// Trwa zapytanie do yt-dlp
	var/busy = FALSE
	/// Wygląd obudowy (1-5)
	var/design = 1
	/// Kto słucha (trzyma walkmana przy sobie)
	var/mob/living/current_listener

/obj/item/walkman/Initialize(mapload)
	. = ..()
	design = rand(1, 5)
	update_icon()

/obj/item/walkman/Destroy()
	stop_listening()
	if(inserted_tape)
		inserted_tape.forceMove(drop_location())
		inserted_tape = null
	return ..()

/obj/item/walkman/update_overlays()
	. = ..()
	. += "+[design]"
	if(!inserted_tape)
		. += "+empty"
	else if(playing)
		. += "+playing"

/obj/item/walkman/examine(mob/user)
	. = ..()
	if(!inserted_tape)
		. += "<span class='info'>Nie ma w nim kasety.</span>"
		return
	. += "<span class='info'>W środku jest kaseta „<b>[inserted_tape.name]</b>” (strona [inserted_tape.flipped ? "B" : "A"]).</span>"
	var/datum/cassette_song/song = current_song()
	if(song)
		. += "<span class='info'>Utwór „<b>[html_encode(song.name)]</b>” [playing ? "gra" : "jest wybrany"].</span>"
	. += "<span class='notice'><b>Alt-klik</b>, żeby wyjąć kasetę.</span>"

/obj/item/walkman/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/cassette_tape))
		return ..()
	if(busy)
		balloon_alert(user, "chwilę, ładuje!")
		return TRUE
	if(inserted_tape)
		balloon_alert(user, "już jest kaseta!")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	inserted_tape = I
	track_index = 0
	playsound(src, pick(GLOB.cassette_put_in_sounds), 40, FALSE)
	balloon_alert(user, "włożono kasetę")
	update_icon()
	return TRUE

/obj/item/walkman/AltClick(mob/user)
	if(!inserted_tape || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return ..()
	if(busy)
		balloon_alert(user, "chwilę, ładuje!")
		return
	stop_listening()
	playsound(src, pick(GLOB.cassette_take_out_sounds), 40, FALSE)
	inserted_tape.forceMove(drop_location())
	user.put_in_hands(inserted_tape)
	inserted_tape = null
	track_index = 0
	balloon_alert(user, "wyjęto kasetę")
	update_icon()

/obj/item/walkman/attack_self(mob/user)
	if(!can_use(user))
		return
	if(playing)
		stop_listening()
		balloon_alert(user, "pauza")
	else
		INVOKE_ASYNC(src, PROC_REF(play_track), user, max(track_index, 1))

/obj/item/walkman/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/walkman/next_song))
		if(can_use(user))
			INVOKE_ASYNC(src, PROC_REF(play_track), user, track_index + 1)
	else if(istype(action, /datum/action/item_action/walkman/restart_song))
		if(can_use(user))
			INVOKE_ASYNC(src, PROC_REF(play_track), user, max(track_index, 1))
	else
		attack_self(user)

/obj/item/walkman/proc/can_use(mob/user)
	if(busy)
		balloon_alert(user, "chwilę, ładuje!")
		return FALSE
	if(!inserted_tape)
		balloon_alert(user, "brak kasety!")
		return FALSE
	if(!length(inserted_tape.get_current_side()?.songs))
		balloon_alert(user, "ta strona jest pusta!")
		return FALSE
	return TRUE

/obj/item/walkman/proc/current_song()
	RETURN_TYPE(/datum/cassette_song)
	var/list/songs = inserted_tape?.get_current_side()?.songs
	if(track_index < 1 || track_index > length(songs))
		return null
	return songs[track_index]

/// Pobiera link do utworu (z zawinięciem do pierwszego po ostatnim) i puszcza go słuchaczowi
/obj/item/walkman/proc/play_track(mob/living/user, index)
	var/list/songs = inserted_tape?.get_current_side()?.songs
	if(busy || !length(songs))
		return
	index = ((index - 1) % length(songs)) + 1
	var/datum/cassette_song/song = songs[index]
	busy = TRUE
	var/obj/item/cassette_tape/tape = inserted_tape
	var/list/result = aquila_ytdl_resolve(song.url, song.duration)
	busy = FALSE
	if(QDELETED(src) || inserted_tape != tape)
		return
	if(!result)
		balloon_alert(user, "nie da się odtworzyć utworu [index]!")
		if(playing && world.time >= track_end) // automatyczne przejście po końcu utworu - nie ponawiamy w kółko
			stop_listening()
		return
	track_index = index
	stream_url = result["stream"]
	var/list/data = result["data"]
	extra_data = list("title" = song.name || data["title"], "link" = song.url)
	track_started = world.time
	track_end = world.time + result["duration"] * 10 + 1 SECONDS
	playing = TRUE
	playsound(src, pick(GLOB.cassette_play_sounds), 30, FALSE)
	start_listening(user)
	to_chat(user, "<span class='notice'>Gra utwór [index]: <b>[html_encode(extra_data["title"])]</b>.</span>")

/obj/item/walkman/proc/start_listening(mob/living/listener)
	if(current_listener && current_listener != listener)
		SSjukeboxes.walkman_listeners -= current_listener
	current_listener = listener
	SSjukeboxes.walkman_listeners[listener] = src
	START_PROCESSING(SSobj, src)
	update_icon()
	SSjukeboxes.update_client(listener.client)

/obj/item/walkman/proc/stop_listening()
	playing = FALSE
	stream_url = null
	extra_data = null
	STOP_PROCESSING(SSobj, src)
	if(current_listener && SSjukeboxes.walkman_listeners[current_listener] == src)
		SSjukeboxes.walkman_listeners -= current_listener
	current_listener = null
	SSjukeboxes.release_walkman(src)
	update_icon()

/// Czy ten mob może teraz słuchać walkmana: ma go przy sobie i coś gra
/obj/item/walkman/proc/can_play_for(mob/M)
	return playing && stream_url && M == current_listener && get(src, /mob) == M

/// Dane do odtworzenia od bieżącego miejsca (np. po ponownym wejściu na serwer)
/obj/item/walkman/proc/play_data()
	var/list/extra = extra_data.Copy()
	extra["start"] = round((world.time - track_started) / 10)
	return extra

/obj/item/walkman/process()
	if(!playing)
		return PROCESS_KILL
	if(!current_listener || get(src, /mob) != current_listener)
		stop_listening()
		return PROCESS_KILL
	if(world.time >= track_end && !busy)
		INVOKE_ASYNC(src, PROC_REF(play_track), current_listener, track_index + 1)

/datum/action/item_action/walkman
	icon_icon = 'aquila/icons/obj/cassettes/walkman.dmi'

/datum/action/item_action/walkman/play_pause
	name = "Graj/pauza"
	button_icon_state = "walkman_playpause"

/datum/action/item_action/walkman/next_song
	name = "Następny utwór"
	button_icon_state = "walkman_next"

/datum/action/item_action/walkman/restart_song
	name = "Od początku"
	button_icon_state = "walkman_restart"
