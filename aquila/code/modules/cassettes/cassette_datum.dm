// AQUILA - dane kasety z Monkestation (cassette_db/cassette_datum.dm). Format JSON zgodny z Monke, więc ich kasety da się wczytać.

/datum/cassette
	/// Unikalne ID zatwierdzonej kasety, np. "4c5d8d69e021a64_alice123456"; null dla niezatwierdzonej
	var/id
	var/name
	var/desc
	var/status = CASSETTE_STATUS_UNAPPROVED
	/// Czas zgłoszenia (unix)
	var/submitted_time
	/// ckey admina, który zatwierdził
	var/approved_ckey
	var/approved_time
	/// ckey admina, który odrzucił lub usunął
	var/deleted_ckey
	var/deleted_time
	var/datum/cassette_author/author
	var/datum/cassette_side/front
	var/datum/cassette_side/back

/datum/cassette/New()
	. = ..()
	author = new
	front = new
	back = new

/datum/cassette/Destroy(force)
	QDEL_NULL(author)
	QDEL_NULL(front)
	QDEL_NULL(back)
	return ..()

/// Niezależna kopia - każda fizyczna kaseta ma własne dane, które można zmieniać w decku
/datum/cassette/proc/copy()
	RETURN_TYPE(/datum/cassette)
	var/datum/cassette/cassette = new
	cassette.import(export())
	return cassette

/datum/cassette/proc/import(list/data)
	if("id" in data)
		id = data["id"]
	name = data["name"]
	desc = data["desc"]
	if("status" in data)
		status = data["status"]
	else
		status = data["approved"] ? CASSETTE_STATUS_APPROVED : CASSETTE_STATUS_UNAPPROVED
	submitted_time = data["submitted_time"]
	approved_ckey = data["approved_ckey"]
	approved_time = data["approved_time"]
	deleted_ckey = data["deleted_ckey"]
	deleted_time = data["deleted_time"]
	author.name = data["author_name"]
	author.ckey = data["author_ckey"]
	var/list/sides = data["songs"]
	if(!islist(sides))
		return
	for(var/side_name in sides)
		var/datum/cassette_side/side
		if(side_name == "side1")
			side = front
		else if(side_name == "side2")
			side = back
		else
			continue
		side.import(sides[side_name])

/datum/cassette/proc/export()
	. = list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"status" = status,
		"author_name" = author.name,
		"author_ckey" = author.ckey,
		"submitted_time" = submitted_time,
		"approved_ckey" = approved_ckey,
		"approved_time" = approved_time,
		"deleted_ckey" = deleted_ckey,
		"deleted_time" = deleted_time,
		"songs" = list(
			"side1" = front.export(),
			"side2" = back.export(),
		),
	)

/// Zapisuje kasetę w data/cassette_storage
/datum/cassette/proc/save_to_file()
	if(!id)
		CRASH("Attempted to save cassette without an ID to disk")
	log_game("Saving cassette [id] to [CASSETTE_FILE(id)]")
	rustg_file_write(json_encode(export()), CASSETTE_FILE(id))
	if(rustg_file_exists(CASSETTE_FILE(id)) != "true")
		CRASH("Failed to save cassette [id], check permissions of [CASSETTE_BASE_DIR]")

/// TRUE = przednia strona, FALSE = tylna
/datum/cassette/proc/get_side(front_side = TRUE)
	RETURN_TYPE(/datum/cassette_side)
	return front_side ? front : back

/datum/cassette/proc/is_blank()
	return !length(front.songs) && !length(back.songs)

/datum/cassette_author
	/// Imię postaci autora
	var/name
	var/ckey

/datum/cassette_side
	/// Naklejka (icon_state z walkman.dmi)
	var/design = "cassette_flip"
	var/list/datum/cassette_song/songs = list()

/datum/cassette_side/Destroy(force)
	QDEL_LIST(songs)
	return ..()

/datum/cassette_side/proc/import(list/data)
	if(!islist(data))
		return
	if(data["icon"])
		design = data["icon"]
	for(var/list/song_data in data["tracks"])
		var/datum/cassette_song/song = new
		song.import(song_data)
		songs += song

/datum/cassette_side/proc/export()
	. = list("icon" = design, "tracks" = list())
	for(var/datum/cassette_song/song as anything in songs)
		.["tracks"] += list(song.export())

/datum/cassette_song
	var/name
	/// Strona utworu (YouTube, SoundCloud, Bandcamp...) - link do pliku wyciąga z niej yt-dlp przy odtwarzaniu
	var/url
	/// Długość w sekundach
	var/duration = 0
	var/artist
	var/album

/datum/cassette_song/New(name, url, duration, artist, album)
	. = ..()
	src.name = name
	src.url = url
	src.duration = isnum(duration) ? max(duration, 0) : 0
	src.artist = artist
	src.album = album

/datum/cassette_song/proc/import(list/data)
	name = data["title"]
	url = data["url"]
	duration = isnum(data["duration"]) ? max(data["duration"], 0) : 0
	artist = data["artist"]
	album = data["album"]

/datum/cassette_song/proc/export()
	return list(
		"title" = name,
		"url" = url,
		"duration" = duration,
		"artist" = artist,
		"album" = album,
	)

/// Dane utworów strony do okien TGUI
/datum/cassette_side/proc/ui_songs()
	. = list()
	for(var/datum/cassette_song/song as anything in songs)
		. += list(list(
			"name" = song.name,
			"url" = song.url,
			"length" = song.duration,
			"artist" = song.artist,
			"album" = song.album,
		))
