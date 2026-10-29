// Used for translating channels to tokens on examination
GLOBAL_LIST_INIT(channel_tokens, list(
	RADIO_CHANNEL_COMMON = RADIO_KEY_COMMON,
	RADIO_CHANNEL_SCIENCE = RADIO_TOKEN_SCIENCE,
	RADIO_CHANNEL_COMMAND = RADIO_TOKEN_COMMAND,
	RADIO_CHANNEL_MEDICAL = RADIO_TOKEN_MEDICAL,
	RADIO_CHANNEL_ENGINEERING = RADIO_TOKEN_ENGINEERING,
	RADIO_CHANNEL_SECURITY = RADIO_TOKEN_SECURITY,
	RADIO_CHANNEL_CENTCOM = RADIO_TOKEN_CENTCOM,
	RADIO_CHANNEL_SYNDICATE = RADIO_TOKEN_SYNDICATE,
	RADIO_CHANNEL_UPLINK = RADIO_TOKEN_UPLINK,  // shouldnt show up in game
	RADIO_CHANNEL_SUPPLY = RADIO_TOKEN_SUPPLY,
//	RADIO_CHANNEL_EXPLORATION = RADIO_TOKEN_EXPLORATION,
	RADIO_CHANNEL_SERVICE = RADIO_TOKEN_SERVICE,
	RADIO_CHANNEL_ATC = RADIO_TOKEN_ATC,
	RADIO_CHANNEL_MUNITIONS = RADIO_TOKEN_MUNITIONS,
	RADIO_CHANNEL_PIRATE = RADIO_CHANNEL_PIRATE,
	MODE_BINARY = MODE_TOKEN_BINARY,
	RADIO_CHANNEL_AI_PRIVATE = RADIO_TOKEN_AI_PRIVATE
)) //Nsv13 - Atc chat & munitions & space pirates. Removed exploration

/obj/item/radio/headset
	name = "słuchawki radiowe"
	desc = "Unowocześniony, modułowy interkom zakładany na głowę. Przyjmuje klucze szyfrujące."
	icon_state = "headset"
	item_state = "headset"
	materials = list(/datum/material/iron=75)
	subspace_transmission = TRUE
	headset = TRUE
	canhear_range = 0 // can't hear headsets from very far away
	var/bang_protect = 0 //this isn't technically clothing so it needs its own bang_protect var

	slot_flags = ITEM_SLOT_EARS
	var/obj/item/encryptionkey/keyslot2 = null
	dog_fashion = null

/obj/item/radio/headset/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna wpychać sobie antenę [src] do nosa! Wygląda na to, że próbuje nabawić się raka!</span>")
	return TOXLOSS

/obj/item/radio/headset/examine(mob/user)
	. = ..()

	if(item_flags & PICKED_UP && loc == user)
		// construction of frequency description
		var/list/avail_chans = list("użyj [RADIO_KEY_COMMON], by mówić na bieżącej częstotliwości")
		if(translate_binary)
			avail_chans += "użyj [MODE_TOKEN_BINARY], by mówić na kanale [MODE_BINARY]"
		if(length(channels))
			for(var/i in 1 to length(channels))
				if(i == 1)
					avail_chans += "użyj [MODE_TOKEN_DEPARTMENT] lub [GLOB.channel_tokens[channels[i]]], by mówić na kanale [lowertext(channels[i])]"
				else
					avail_chans += "użyj [GLOB.channel_tokens[channels[i]]], by mówić na kanale [lowertext(channels[i])]"
		. += "<span class='notice'>Mały ekranik na słuchawkach wyświetla dostępne częstotliwości:\n[english_list(avail_chans)].</span>"

		if(command)
			. += "<span class='info'>Alt-kliknij, by przełączyć tryb wysokiej głośności.</span>"
	else
		. += "<span class='notice'>Mały ekranik na słuchawkach miga, ale jest za mały, by go odczytać bez trzymania lub noszenia słuchawek.</span>"

/obj/item/radio/headset/Initialize(mapload)
	. = ..()
	recalculateChannels()

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot2)
	return ..()

/obj/item/radio/headset/talk_into(mob/living/M, message, channel, list/spans, datum/language/language, list/message_mods)
	if (!listening)
		return ITALICS | REDUCE_RANGE
	return ..()

/obj/item/radio/headset/can_receive(freq, level, AIuser)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		if(H.ears == src)
			return ..(freq, level)
	else if(AIuser)
		return ..(freq, level)
	return FALSE

/obj/item/radio/headset/ui_data(mob/user)
	. = ..()
	.["headset"] = TRUE

/obj/item/radio/headset/syndicate //disguised to look like a normal headset for stealth ops

/obj/item/radio/headset/syndicate/alt //undisguised bowman with flash protection
	name = "słuchawki Syndykatu"
	desc = "Słuchawki Syndykatu, przez które słychać częstotliwości Syndykatu. Chronią uszy przed granatami hukowo-błyskowymi."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"
	bang_protect = 1

/obj/item/radio/headset/syndicate/alt/leader
	name = "słuchawki dowódcy drużyny"
	command = TRUE

/obj/item/radio/headset/syndicate/Initialize(mapload)
	. = ..()
	make_syndie()

/obj/item/radio/headset/binary
/obj/item/radio/headset/binary/Initialize(mapload)
	. = ..()
	qdel(keyslot)
	keyslot = new /obj/item/encryptionkey/binary
	recalculateChannels()

/obj/item/radio/headset/headset_sec
	name = "słuchawki radiowe Policji"
	desc = "Używane przez twoje elitarne siły policyjne."
	icon_state = "sec_headset"
	keyslot = new /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_medsec
	name = "słuchawki radiowe medyczne i Policji"
	desc = "Służą do słuchania, ilu policjantów trzeba będzie pozszywać."
	icon_state = "medsec_headset"
	keyslot = new /obj/item/encryptionkey/headset_medsec

/obj/item/radio/headset/headset_sec/alt
	name = "policyjne słuchawki nauszne"
	desc = "Używane przez twoje elitarne siły policyjne. Chronią uszy przed granatami hukowo-błyskowymi."
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"
	bang_protect = 1

/obj/item/radio/headset/headset_eng
	name = "słuchawki radiowe Inżynierii"
	desc = "Na wypadek, gdyby inżynierowie chcieli poplotkować jak licealistki."
	icon_state = "eng_headset"
	keyslot = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "słuchawki radiowe robotyki"
	desc = "Zrobione specjalnie dla robotyków, którzy nie mogą się zdecydować, do którego działu należą."
	icon_state = "rob_headset"
	keyslot = new /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "słuchawki radiowe medyczne"
	desc = "Słuchawki dla wyszkolonego personelu ambulatorium."
	icon_state = "med_headset"
	keyslot = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sci
	name = "słuchawki radiowe naukowe"
	desc = "Naukowe słuchawki. Jak zwykle."
	icon_state = "sci_headset"
	keyslot = new /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "słuchawki radiowe badań medycznych"
	desc = "Słuchawki będące owocem krzyżówki działu medycznego z naukowym."
	icon_state = "medsci_headset"
	keyslot = new /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_srvsec
	name = "słuchawki prawa i porządku"
	desc = "W słuchawkach wymiaru sprawiedliwości klucz szyfrujący reprezentuje dwie odrębne, ale równie ważne grupy: Policję, która ściga przestępstwa, i Służbę, która świadczy usługi. Oto ich łączność."
	icon_state = "srvsec_headset"
	keyslot = new /obj/item/encryptionkey/headset_srvsec

/obj/item/radio/headset/headset_com
	name = "słuchawki radiowe Dowództwa"
	desc = "Słuchawki z kanałem dowodzenia."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads
	command = TRUE

/obj/item/radio/headset/heads/captain
	name = "\proper słuchawki Kapitana"
	desc = "Słuchawki króla."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "\proper słuchawki nauszne Kapitana"
	desc = "Słuchawki szefa. Chronią uszy przed granatami hukowo-błyskowymi."
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	bang_protect = 1

/obj/item/radio/headset/heads/research_director
	name = "\proper słuchawki Dyrektora Naukowego"
	desc = "Słuchawki gościa, który pcha społeczeństwo ku osobliwości technologicznej."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "\proper słuchawki Komendanta"
	desc = "Słuchawki osoby odpowiedzialnej za utrzymanie porządku i ochronę stacji."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "\proper słuchawki nauszne Komendanta"
	desc = "Słuchawki osoby odpowiedzialnej za utrzymanie porządku i ochronę stacji. Chronią uszy przed granatami hukowo-błyskowymi."
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	bang_protect = 1

/obj/item/radio/headset/heads/chief_engineer
	name = "\proper słuchawki Głównego Inżyniera"
	desc = "Słuchawki gościa odpowiedzialnego za to, by stacja miała zasilanie i była cała."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "\proper słuchawki Ordynatora"
	desc = "Słuchawki znakomicie wyszkolonego szefa medycyny."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/xo //nsv13 - changed HoP to XO
	name = "\proper słuchawki Starszego Oficera"
	desc = "Słuchawki gościa, który pewnego dnia zostanie kapitanem."
	icon_state = "com_headset"
	keyslot = new /obj/item/encryptionkey/heads/captain //NSV13 - inserted captain key for better communication facilitation

/obj/item/radio/headset/headset_cargo
	name = "słuchawki radiowe Zaopatrzenia"
	desc = "Słuchawki używane przez niewolników Kwatermistrza."
	icon_state = "cargo_headset"
	keyslot = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_quartermaster
	name = "słuchawki radiowe Kwatermistrza"
	desc = "Słuchawki używane przez Kwatermistrza."
	icon_state = "cargo_headset"
	keyslot = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_exploration
	name = "słuchawki radiowe odkrywców"
	desc = "Słuchawki używane przez zespoły odkrywców."
	icon_state = "exploration_headset"
	keyslot = new /obj/item/encryptionkey/headset_expteam

/obj/item/radio/headset/headset_cargo/shaft_miner
	name = "słuchawki radiowe górników"
	desc = "Słuchawki używane przez górników."
	icon_state = "mine_headset"
	keyslot = new /obj/item/encryptionkey/headset_mining

/obj/item/radio/headset/headset_srv
	name = "słuchawki radiowe Służby"
	desc = "Słuchawki personelu Służby, którego zadaniem jest dbać, by stacja była syta, szczęśliwa i czysta."
	icon_state = "srv_headset"
	keyslot = new /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/headset_curator
	name = "słuchawki radiowe Bibliotekarza"
	desc = "Słuchawki Bibliotekarza, które pozwalają na łączność z zespołem odkrywców."
	icon_state = "srv_headset"
	keyslot = new /obj/item/encryptionkey/headset_curator

/obj/item/radio/headset/headset_cent
	name = "\improper słuchawki Centrali"
	desc = "Słuchawki używane przez najwyższe szczeble Nanotrasen."
	icon_state = "cent_headset"
	keyslot = new /obj/item/encryptionkey/headset_com
	keyslot2 = new /obj/item/encryptionkey/headset_cent

/obj/item/radio/headset/headset_cent/empty
	keyslot = null
	keyslot2 = null

/obj/item/radio/headset/headset_cent/commander
	keyslot = new /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/headset_cent/alt
	name = "\improper słuchawki nauszne Centrali"
	desc = "Słuchawki przeznaczone specjalnie dla zespołów reagowania kryzysowego. Chronią uszy przed granatami hukowo-błyskowymi."
	icon_state = "cent_headset_alt"
	item_state = "cent_headset_alt"
	keyslot = null
	bang_protect = 1

/obj/item/radio/headset/silicon/pai
	name = "\proper mini zintegrowany nadajnik-odbiornik podprzestrzenny "
	subspace_transmission = FALSE


/obj/item/radio/headset/silicon/ai
	name = "\proper zintegrowany nadajnik-odbiornik podprzestrzenny "
	keyslot2 = new /obj/item/encryptionkey/ai
	command = TRUE

/obj/item/radio/headset/silicon/can_receive(freq, level)
	return ..(freq, level, TRUE)

/obj/item/radio/headset/attackby(obj/item/W, mob/user, params)
	user.set_machine(src)

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(keyslot || keyslot2)
			for(var/ch_name in channels)
				SSradio.remove_object(src, GLOB.radiochannels[ch_name])
				secure_radio_connections[ch_name] = null

			if(keyslot)
				user.put_in_hands(keyslot)
				keyslot = null
			if(keyslot2)
				user.put_in_hands(keyslot2)
				keyslot2 = null

			recalculateChannels()
			ui_update()
			to_chat(user, "<span class='notice'>Wyjmujesz klucze szyfrujące ze słuchawek.</span>")

		else
			to_chat(user, "<span class='warning'>Te słuchawki nie mają żadnych unikalnych kluczy szyfrujących! Ale bezużyteczne...</span>")

	else if(istype(W, /obj/item/encryptionkey))
		if(keyslot && keyslot2)
			to_chat(user, "<span class='warning'>Słuchawki nie pomieszczą kolejnego klucza!</span>")
			return

		if(!keyslot)
			if(!user.transferItemToLoc(W, src))
				return
			keyslot = W

		else
			if(!user.transferItemToLoc(W, src))
				return
			keyslot2 = W


		recalculateChannels()
		ui_update()
	else
		return ..()


/obj/item/radio/headset/recalculateChannels()
	..()
	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(!(ch_name in src.channels))
				channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			translate_binary = TRUE
		if(keyslot2.hearall)
			hearall = TRUE
		if(keyslot2.syndie)
			syndie = TRUE
		if (keyslot2.independent)
			independent = TRUE
		if (keyslot2.amplification)
			command = TRUE

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

/obj/item/radio/headset/AltClick(mob/living/user)
	if(!istype(user) || !Adjacent(user) || user.incapacitated())
		return
	if (command)
		use_command = !use_command
		to_chat(user, "<span class='notice'>[use_command ? "Włączasz" : "Wyłączasz"] tryb wysokiej głośności.</span>")
