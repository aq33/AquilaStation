// AQUILA: radio rozrywkowe (port Monkestation). Mikrofony kamer nadają na FREQ_ENTERTAINMENT,
// a głośniki telewizorów i Spess.tv to odbierają. Transmisja idzie przez superspace (jak kanał Centrali),
// więc słychać ją na każdym z-levelu i nie zależy od telekomunikacji statku.

/obj/item/radio/entertainment
	desc = "Nie powinieneś tego trzymać."
	canhear_range = 7
	freerange = TRUE
	freqlock = TRUE
	frequency = FREQ_ENTERTAINMENT
	/// Odbiera transmisje superspace (patrz can_receive niżej, inne kanały są zablokowane)
	independent = TRUE
	radio_silent = TRUE

/obj/item/radio/entertainment/Initialize(mapload)
	. = ..()
	// Nazwa i kolor kanału w czacie; bez tego wiadomość pokazałaby się jako „141.5”
	GLOB.reverseradiochannels["[FREQ_ENTERTAINMENT]"] = RADIO_CHANNEL_ENTERTAINMENT
	GLOB.freqtospan["[FREQ_ENTERTAINMENT]"] = "explradio"

/// Radio rozrywkowe słyszy tylko kanał rozrywkowy (independent dawałby mu też Centralę i kontrolę lotów)
/obj/item/radio/entertainment/can_receive(freq, level)
	if(freq != FREQ_ENTERTAINMENT)
		return FALSE
	return ..()

/// Nadaje od razu do wszystkich radiów rozrywkowych, bez telekomunikacji
/obj/item/radio/entertainment/talk_into_impl(atom/movable/M, message, channel, list/spans, datum/language/language, list/message_mods)
	if(!on || !M || !message)
		return
	if(wires.is_cut(WIRE_TX))
		return
	if(!M.IsVocal())
		return
	if(use_command)
		spans |= SPAN_COMMAND
	if(is_jammed())
		return
	var/atom/movable/virtualspeaker/speaker = new(null, M, src)
	var/datum/signal/subspace/vocal/signal = new(src, FREQ_ENTERTAINMENT, speaker, language, message, spans, message_mods)
	signal.data["compression"] = 0
	signal.transmission_method = TRANSMISSION_SUPERSPACE
	signal.levels = list(0) // wszystkie z-levele, także domeny bitrunnerów
	signal.broadcast()

/// Głośniki: tylko odbierają (w telewizorach rozrywkowych, nie do trzymania)
/obj/item/radio/entertainment/speakers
	broadcasting = FALSE
	listening = TRUE

/obj/item/radio/entertainment/speakers/Initialize(mapload)
	. = ..()
	broadcasting = FALSE
	listening = TRUE
	wires?.cut(WIRE_TX)

/// Wycisza albo włącza głośniki
/obj/item/radio/entertainment/speakers/proc/toggle_mute()
	listening = !listening
	return listening

/// Głośnik Spess.tv w PDA: słychać go tylko z bliska
/obj/item/radio/entertainment/speakers/pda
	canhear_range = 0

/obj/item/radio/entertainment/speakers/pda/emp_act(severity)
	return

/// Przenośny odbiornik kanału rozrywkowego
/obj/item/radio/entertainment/speakers/physical
	name = "entertainment radio"
	desc = "Przenośne radio jednokierunkowe, na stałe nastrojone na kanał rozrywkowy."

/// Mikrofon: tylko nadaje (wbudowany w kamery reporterskie)
/obj/item/radio/entertainment/microphone
	broadcasting = TRUE
	listening = FALSE

/obj/item/radio/entertainment/microphone/Initialize(mapload)
	. = ..()
	broadcasting = TRUE
	listening = FALSE
	wires?.cut(WIRE_RX)

/// Ręczny mikrofon na kanał rozrywkowy
/obj/item/radio/entertainment/microphone/physical
	name = "microphone"
	desc = "Bez komentarza."
	icon = 'aquila/icons/obj/broadcast.dmi'
	icon_state = "microphone"
	item_state = "microphone"
	lefthand_file = 'aquila/icons/mob/inhands/broadcast_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/broadcast_righthand.dmi'
	canhear_range = 3
