//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "zwykły instrument"
	resistance_flags = FLAMMABLE
	force = 10
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	/// Our song datum.
	var/datum/song/handheld/song
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids
	/// How far away our song datum can be heard.
	var/instrument_range = 15

/obj/item/instrument/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	allowed_instrument_ids = null			//We don't need this clogging memory after it's used.

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/proc/should_stop_playing(mob/user)
	return user.incapacitated() || !((loc == user) || (isturf(loc) && Adjacent(user)))		// sorry, no more TK playing.

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zaczyna grać „Gloomy Sunday”! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS)

/obj/item/instrument/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Nie masz dość zręczności, by to zrobić!</span>")
		return TRUE
	interact(user)

/obj/item/instrument/interact(mob/user)
	ui_interact(user)

/obj/item/instrument/ui_interact(mob/living/user)
	if(!isliving(user) || user.stat || (user.restrained() && !ispAI(user)))
		return

	user.set_machine(src)
	song.ui_interact(user)

/obj/item/instrument/violin
	name = "kosmiczne skrzypce"
	desc = "Drewniany instrument z czterema strunami i smyczkiem. „Diabeł zszedł w kosmos, szukał asystenta do griefowania.”"
	icon_state = "violin"
	item_state = "violin"
	hitsound = "swing_hit"
	allowed_instrument_ids = "violin"

/obj/item/instrument/violin/golden
	name = "złote skrzypce"
	desc = "Złoty instrument z czterema strunami i smyczkiem. „Diabeł zszedł w kosmos, szukał asystenta do griefowania.”"
	icon_state = "golden_violin"
	item_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/piano_synth
	name = "syntezator"
	desc = "Zaawansowany syntezator elektroniczny, który może udawać różne instrumenty."
	icon_state = "synth"
	item_state = "synth"
	allowed_instrument_ids = "piano"

/obj/item/instrument/piano_synth/Initialize(mapload)
	. = ..()
	song.allowed_instrument_ids = SSinstruments.synthesizer_instrument_ids

/obj/item/instrument/banjo
	name = "banjo"
	desc = "Banjo marki „Mura”. W zasadzie to bęben z gryfem i strunami."
	icon_state = "banjo"
	item_state = "banjo"
	attack_verb = list("gra bluegrassa", "hum-diggituje", "kopie w goleń", "wali młotkiem")
	hitsound = 'sound/weapons/banjoslap.ogg'
	allowed_instrument_ids = "banjo"

/obj/item/instrument/guitar
	name = "gitara"
	desc = "Jest z drewna i ma brązowe struny."
	icon_state = "guitar"
	item_state = "guitar"
	attack_verb = list("gra metal na", "śpiewa serenadę", "wbija się w", "rozbija")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("guitar","csteelgt","cnylongt", "ccleangt", "cmutedgt")

/obj/item/instrument/eguitar
	name = "gitara elektryczna"
	desc = "Spełnia wszystkie twoje potrzeby szybkiego grania."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("gra metal na", "szatkuje", "wbija się w", "rozbija")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = "eguitar"

/obj/item/instrument/glockenspiel
	name = "dzwonki"
	desc = "Gładkie metalowe sztabki, idealne dla każdej orkiestry marszowej."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	allowed_instrument_ids = list("glockenspiel","crvibr", "sgmmbox", "r3celeste")

/obj/item/instrument/accordion
	name = "akordeon"
	desc = "Pun-Pun nie jest w zestawie."
	icon_state = "accordion"
	item_state = "accordion"
	allowed_instrument_ids = list("crack", "crtango", "accordion")

/obj/item/instrument/trumpet
	name = "trąbka"
	desc = "Do ogłaszania przybycia króla!"
	icon_state = "trumpet"
	item_state = "trombone"
	allowed_instrument_ids = "crtrumpet"

/obj/item/instrument/trumpet/spectral
	name = "widmowa trąbka"
	desc = "Zaraz zrobi się strasznie!"
	icon_state = "trumpet"
	item_state = "trombone"
	force = 0
	attack_verb = list("gra na","jazzuje","trąbi na","opłakuje","dudni na","straszy")

/obj/item/instrument/trumpet/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trumpet/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/En4.mid', 100,1,-1)
	..()

/obj/item/instrument/saxophone
	name = "saksofon"
	desc = "Ten kojący dźwięk na pewno doprowadzi publiczność do łez."
	icon_state = "saxophone"
	item_state = "saxophone"
	allowed_instrument_ids = "saxophone"

/obj/item/instrument/saxophone/spectral
	name = "widmowy saksofon"
	desc = "Ten straszny dźwięk na pewno zostawi z śmiertelników same kości."
	icon_state = "saxophone"
	item_state = "saxophone"
	allowed_instrument_ids = "saxophone"
	force = 0
	attack_verb = list("gra na","jazzuje","saksofonuje","opłakuje","dudni na","straszy")

/obj/item/instrument/saxophone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/saxophone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/saxophone/En4.mid', 100,1,-1)
	..()

/obj/item/instrument/trombone
	name = "puzon"
	desc = "Jak jakikolwiek stół bilardowy mógłby z tym konkurować?"
	icon_state = "trombone"
	item_state = "trombone"
	allowed_instrument_ids = list("crtrombone", "crbrass", "trombone")

/obj/item/instrument/trombone/spectral
	name = "widmowy puzon"
	desc = "Ulubiony instrument szkieletów. Stosować bezpośrednio na śmiertelnikach."
	icon_state = "trombone"
	item_state = "trombone"
	force = 0
	attack_verb = list("gra na","jazzuje","puzonuje","opłakuje","dudni na","straszy")

/obj/item/instrument/trombone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trombone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/Cn4.mid', 100,1,-1)
	..()

/obj/item/instrument/recorder
	name = "flet prosty"
	desc = "Zupełnie jak w szkole, łącznie z umiejętnościami gry."
	force = 5
	icon_state = "recorder"
	item_state = "recorder"
	allowed_instrument_ids = "recorder"

/obj/item/instrument/harmonica
	name = "harmonijka"
	desc = "Na wypadek ciężkiego ataku kosmicznego bluesa."
	icon_state = "harmonica"
	item_state = "harmonica"
	allowed_instrument_ids = list("harmonica", "crharmony")
	slot_flags = ITEM_SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/instrument/harmonica/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(song.playing && ismob(loc))
		to_chat(loc, "<span class='warning'>Przestajesz grać na harmonijce, by coś powiedzieć...</span>")
		song.playing = FALSE

/obj/item/instrument/harmonica/equipped(mob/M, slot)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/instrument/harmonica/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/instrument/bikehorn
	name = "pozłacana trąbka"
	desc = "Wyszukanie zdobiona trąbka rowerowa, która trąbi w wielu różnych tonacjach."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	attack_verb = list("pięknie trąbi na")
	allowed_instrument_ids = list("bikehorn", "honk")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'

///

/obj/item/choice_beacon/music
	name = "nadajnik dostawy instrumentu"
	desc = "Przywołaj swoje narzędzie sztuki."
	icon_state = "gangtool-red"

/obj/item/choice_beacon/music/generate_display_names()
	var/static/list/instruments
	if(!instruments)
		instruments = list()
		var/list/templist = list(/obj/item/instrument/violin,
							/obj/item/instrument/piano_synth,
							/obj/item/instrument/banjo,
							/obj/item/instrument/guitar,
							/obj/item/instrument/eguitar,
							/obj/item/instrument/glockenspiel,
							/obj/item/instrument/accordion,
							/obj/item/instrument/trumpet,
							/obj/item/instrument/saxophone,
							/obj/item/instrument/trombone,
							/obj/item/instrument/recorder,
							/obj/item/instrument/harmonica
							)
		for(var/V in templist)
			var/atom/A = V
			instruments[initial(A.name)] = A
	return instruments

/obj/item/instrument/musicalmoth
	name = "muzyczna ćma"
	desc = "Mimo popularności ta kontrowersyjna muzyczna zabawka została w końcu zakazana z powodu nieetycznie nagranych odgłosów ciem krzyczących w agonii."
	icon_state = "mothsician"
	allowed_instrument_ids = "mothscream"
	attack_verb = list("trzepocze na", "klapie")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	hitsound = 'sound/voice/moth/scream_moth.ogg'
	custom_price = 237
	custom_premium_price = 237
