// AQUILA: edytor utworów w TGUI (okno InstrumentEditor z tg) zamiast starego HTML
/datum/song/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InstrumentEditor", parent?.name || "instrument")
		ui.open()

/datum/song/ui_host(mob/user)
	return parent

/datum/song/ui_state(mob/user)
	if(ispAI(user))
		return GLOB.always_state
	return ..()

/datum/song/ui_data(mob/user)
	var/list/data = list()
	data["using_instrument"] = using_instrument?.name
	data["can_noteshift"] = can_noteshift
	data["note_shift"] = note_shift
	data["octaves"] = round(note_shift / 12, 0.01)
	data["sustain_mode"] = sustain_mode
	switch(sustain_mode)
		if(SUSTAIN_LINEAR)
			data["sustain_mode_duration"] = sustain_linear_duration / 10
			data["sustain_mode_min"] = 0.1
			data["sustain_mode_max"] = INSTRUMENT_MAX_TOTAL_SUSTAIN / 10
			data["sustain_mode_step"] = 0.1
		if(SUSTAIN_EXPONENTIAL)
			data["sustain_mode_duration"] = sustain_exponential_dropoff
			data["sustain_mode_min"] = INSTRUMENT_EXP_FALLOFF_MIN
			data["sustain_mode_max"] = INSTRUMENT_EXP_FALLOFF_MAX
			data["sustain_mode_step"] = 0.005
	data["instrument_ready"] = !!using_instrument?.ready()
	data["legacy"] = legacy
	data["volume"] = volume
	data["volume_dropoff_threshold"] = sustain_dropoff_volume
	data["sustain_indefinitely"] = full_sustain_held_note
	data["playing"] = playing
	data["repeat"] = repeat
	data["bpm"] = round(600 / tempo)
	data["lines"] = list()
	var/linecount = 0
	for(var/line in lines)
		linecount++
		data["lines"] += list(list(
			"line_count" = linecount,
			"line_text" = line,
		))
	return data

/datum/song/ui_static_data(mob/user)
	var/list/data = list()
	data["can_switch_instrument"] = (length(allowed_instrument_ids) > 1)
	data["possible_instruments"] = list()
	for(var/instrument_id in allowed_instrument_ids)
		var/datum/instrument/I = SSinstruments.get_instrument(instrument_id)
		if(!I)
			continue
		data["possible_instruments"] += list(list("name" = I.name, "id" = I.id, "category" = I.category))
	data["max_repeats"] = max_repeats
	data["min_volume"] = min_volume
	data["max_volume"] = max_volume
	data["note_shift_min"] = note_shift_min
	data["note_shift_max"] = note_shift_max
	data["max_line_chars"] = MUSIC_MAXLINECHARS
	data["max_lines"] = MUSIC_MAXLINES
	return data

/datum/song/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!istype(user) || !user.canUseTopic(parent, TRUE, FALSE, FALSE, FALSE))
		return
	parent.add_fingerprint(user)

	switch(action)
		//SETTINGS
		if("play_music")
			if(!playing)
				INVOKE_ASYNC(src, PROC_REF(start_playing), user)
			else
				stop_playing()
			return TRUE
		if("change_instrument")
			var/new_instrument = params["new_instrument"]
			if(!length(allowed_instrument_ids) || !(new_instrument in allowed_instrument_ids))
				return
			set_instrument(new_instrument)
			return TRUE
		if("tempo")
			var/tempo_diff = (params["tempo_change"] == "increase_speed") ? -world.tick_lag : world.tick_lag
			tempo = sanitize_tempo(tempo + tempo_diff)
			return TRUE

		//SONG MAKING
		if("import_song")
			var/song_text = ""
			do
				song_text = tgui_input_text(user, "Wklej cały utwór:", name, song_text, MUSIC_MAXLINES * MUSIC_MAXLINECHARS, TRUE)
				if(isnull(song_text) || !in_range(parent, user))
					return
				if(length_char(song_text) >= MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
					var/should_continue = tgui_alert(user, "Utwór jest za długi! Czy chcesz kontynuować edycję?", "Uwaga", list("Tak", "Nie"))
					if(should_continue != "Tak")
						break
			while(length_char(song_text) > MUSIC_MAXLINES * MUSIC_MAXLINECHARS)
			ParseSong(song_text)
			return TRUE
		if("start_new_song")
			name = ""
			lines = new()
			tempo = sanitize_tempo(5) // default 120 BPM
			return TRUE
		if("add_new_line")
			var/newline = tgui_input_text(user, "Wpisz swoją linię:", parent.name, null, MUSIC_MAXLINECHARS)
			if(!newline || !in_range(parent, user))
				return
			if(length(lines) >= MUSIC_MAXLINES)
				return
			if(length(newline) > MUSIC_MAXLINECHARS)
				newline = copytext(newline, 1, MUSIC_MAXLINECHARS)
			lines.Add(newline)
			return TRUE
		if("delete_line")
			var/line_to_delete = round(text2num(params["line_deleted"]))
			if(line_to_delete > length(lines) || line_to_delete < 1)
				return
			lines.Cut(line_to_delete, line_to_delete + 1)
			return TRUE
		if("modify_line")
			var/line_to_edit = round(text2num(params["line_editing"]))
			if(line_to_edit > length(lines) || line_to_edit < 1)
				return
			var/new_line_text = tgui_input_text(user, "Wpisz swoją linię:", parent.name, lines[line_to_edit], MUSIC_MAXLINECHARS)
			if(isnull(new_line_text) || !in_range(parent, user))
				return
			if(line_to_edit > length(lines))
				return
			lines[line_to_edit] = new_line_text
			return TRUE

		//MODE STUFF
		if("set_sustain_mode")
			var/new_mode = text2num(params["new_mode"])
			if(new_mode != SUSTAIN_LINEAR && new_mode != SUSTAIN_EXPONENTIAL)
				return
			sustain_mode = new_mode
			return TRUE
		if("set_note_shift")
			if(!can_noteshift)
				return
			var/amount = text2num(params["amount"])
			if(isnull(amount))
				return
			note_shift = clamp(round(amount), note_shift_min, note_shift_max)
			return TRUE
		if("set_volume")
			var/new_volume = text2num(params["amount"])
			if(isnull(new_volume))
				return
			set_volume(round(new_volume, 1))
			return TRUE
		if("set_dropoff_volume")
			var/dropoff_threshold = text2num(params["amount"])
			if(isnull(dropoff_threshold))
				return
			set_dropoff_volume(round(dropoff_threshold, 0.01))
			return TRUE
		if("toggle_sustain_hold_indefinitely")
			full_sustain_held_note = !full_sustain_held_note
			return TRUE
		if("set_repeat_amount")
			if(playing)
				return //So that people cant keep adding to repeat. If the do it intentionally, it could result in the server crashing.
			var/repeat_amount = text2num(params["amount"])
			if(isnull(repeat_amount))
				return
			repeat = clamp(round(repeat_amount), 0, max_repeats)
			return TRUE
		if("edit_sustain_mode")
			var/sustain_amount = text2num(params["amount"])
			if(isnull(sustain_amount))
				return
			switch(sustain_mode)
				if(SUSTAIN_LINEAR)
					set_linear_falloff_duration(round(sustain_amount * 10, world.tick_lag))
				if(SUSTAIN_EXPONENTIAL)
					set_exponential_drop_rate(round(sustain_amount, 0.00001))
			return TRUE

/**
  * Parses a song the user has input into lines and stores them.
  */
/datum/song/proc/ParseSong(text)
	set waitfor = FALSE
	//split into lines
	lines = splittext(text, "\n")
	if(lines.len)
		var/bpm_string = "BPM: "
		if(findtext(lines[1], bpm_string, 1, length(bpm_string) + 1))
			var/divisor = text2num(copytext(lines[1], length(bpm_string) + 1)) || 120 // default
			tempo = sanitize_tempo(600 / round(divisor, 1))
			lines.Cut(1, 2)
		else
			tempo = sanitize_tempo(5) // default 120 BPM
		if(lines.len > MUSIC_MAXLINES)
			to_chat(usr, "Za dużo linii!")
			lines.Cut(MUSIC_MAXLINES + 1)
		var/linenum = 1
		for(var/l in lines)
			if(length_char(l) > MUSIC_MAXLINECHARS)
				to_chat(usr, "Linia [linenum] jest za długa!")
				lines.Remove(l)
			else
				linenum++
		SStgui.update_uis(src)		// make sure updates when complete
