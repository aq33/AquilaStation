/obj/item/encryptionkey
	name = "standardowy klucz szyfrujący"
	desc = "Klucz szyfrujący do słuchawek radiowych."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	w_class = WEIGHT_CLASS_TINY
	var/translate_binary = FALSE
	var/syndie = FALSE
	var/hearall = FALSE
	var/independent = FALSE
	var/amplification = FALSE
	var/list/channels = list()

/obj/item/encryptionkey/Initialize(mapload)
	. = ..()
	if(!channels.len)
		desc = "Klucz szyfrujący do słuchawek radiowych. Nie ma w nim żadnych specjalnych kodów. Lepiej powiedz o tym koderowi!"

/obj/item/encryptionkey/examine(mob/user)
	. = ..()
	if(LAZYLEN(channels))
		var/list/examine_text_list = list()
		for(var/i in channels)
			examine_text_list += "[GLOB.channel_tokens[i]] - [lowertext(i)]"

		. += "<span class='notice'>Daje dostęp do następujących kanałów: [jointext(examine_text_list, ", ")].</span>"

/obj/item/encryptionkey/syndicate
	name = "klucz szyfrujący Syndykatu"
	icon_state = "syn_cypherkey"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	syndie = TRUE

/obj/item/encryptionkey/hearall
	name = "uniwersalny klucz deszyfrujący"
	icon_state = "universal_cypherkey"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	hearall = TRUE
	syndie = TRUE

/obj/item/encryptionkey/binary
	name = "klucz tłumacza binarnego"
	icon_state = "bin_cypherkey"
	translate_binary = TRUE

/obj/item/encryptionkey/amplification
	name = "klucz modułu wzmacniającego"
	amplification = TRUE

// Makes sure neither channel messages show up.
/obj/item/encryptionkey/amplification/Initialize()
	. = ..()
	desc = "Klucz modułu wzmacniającego do słuchawek radiowych. Włącza tryb głośny w każdych słuchawkach, do których zostanie włożony."

/obj/item/encryptionkey/headset_sec
	name = "klucz szyfrujący radia Policji"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_eng
	name = "klucz szyfrujący radia Inżynierii"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_rob
	name = "klucz szyfrujący radia robotyki"
	icon_state = "rob_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_med
	name = "klucz szyfrujący radia medycznego"
	icon_state = "med_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1)

/obj/item/encryptionkey/headset_sci
	name = "klucz szyfrujący radia naukowego"
	icon_state = "sci_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_medsci
	name = "klucz szyfrujący radia badań medycznych"
	icon_state = "medsci_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1)

/obj/item/encryptionkey/headset_medsec
	name = "klucz szyfrujący radia medycznego i Policji"
	icon_state = "medsec_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_srvsec
	name = "klucz szyfrujący radia prawa i porządku"
	icon_state = "srvsec_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_com
	name = "klucz szyfrujący radia Dowództwa"
	icon_state = "com_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/captain //NSV13 - added ATC & Munitions, removed exploration
	name = "\proper klucz szyfrujący Kapitana"
	icon_state = "cap_cypherkey"
	independent = TRUE
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 0, RADIO_CHANNEL_SCIENCE = 0, RADIO_CHANNEL_MEDICAL = 0, RADIO_CHANNEL_SUPPLY = 0, RADIO_CHANNEL_SERVICE = 0, RADIO_CHANNEL_MUNITIONS = 0, RADIO_CHANNEL_ATC = 0)

/obj/item/encryptionkey/heads/captain/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/rd
	name = "\proper klucz szyfrujący Dyrektora Naukowego"
	icon_state = "rd_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_COMMAND = 1)
	
/obj/item/encryptionkey/heads/rd/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/hos
	name = "\proper klucz szyfrujący Komendanta"
	icon_state = "hos_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hos/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/ce
	name = "\proper klucz szyfrujący Głównego Inżyniera"
	icon_state = "ce_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/ce/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/cmo
	name = "\proper klucz szyfrujący Ordynatora"
	icon_state = "cmo_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/cmo/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/xo //nsv13 - changed HoP to XO
	name = "\proper klucz szyfrujący Starszego Oficera"
	icon_state = "hop_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS=1, RADIO_CHANNEL_ENGINEERING=1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hop/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_cargo
	name = "klucz szyfrujący radia Zaopatrzenia"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1)

/obj/item/encryptionkey/headset_mining
	name = "klucz szyfrujący radia górników"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_exp
	name = "klucz szyfrujący odkrywców"
	icon_state = "exp_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_expteam
	name = "klucz szyfrujący zespołu odkrywców"
	icon_state = "expteam_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_service
	name = "klucz szyfrujący radia Służby"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_curator
	name = "klucz szyfrujący radia Bibliotekarza"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_cent
	name = "\improper klucz szyfrujący radia Centrali"
	icon_state = "cent_cypherkey"
	independent = TRUE
	channels = list(RADIO_CHANNEL_CENTCOM = 1)

/obj/item/encryptionkey/debug
	name = "\improper wszechobecny klucz szyfrujący"
	desc = "Boski klucz wszechobecności, dzięki któremu podsłuchasz wszystko, co zechcesz usłyszeć."
	icon_state = "cent_cypherkey"
	translate_binary = TRUE
	syndie = TRUE
	independent = TRUE
	amplification = TRUE

/obj/item/encryptionkey/debug/Initialize(mapload)
	. = ..()
	for(var/each in GLOB.radiochannels)
		channels |= list("[each]" = 1)

/obj/item/encryptionkey/ai //ported from NT, this goes 'inside' the AI. NSV13 - added munitions & ATC, removed exploration
	independent = TRUE
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_ATC = 1)

/obj/item/encryptionkey/secbot
	channels = list(RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_SECURITY = 1)


/obj/item/storage/box/command_keys // heads toys
	name = "pudełko kluczy wzmacniających"

/obj/item/storage/box/command_keys/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/encryptionkey/amplification(src)
