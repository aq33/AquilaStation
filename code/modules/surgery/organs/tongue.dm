/obj/item/organ/tongue
	name = "język"
	desc = "Mięsisty mięsień używany głównie do kłamania."
	icon_state = "tonguenormal"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_TONGUE
	attack_verb = list("liże", "śliniąc się, liże", "policzkuje", "całuje z języczkiem", "liże")
	var/list/languages_possible
	var/say_mod = "mówi"
	var/ask_mod = "pyta"
	var/yell_mod = "krzyczy"
	var/exclaim_mod = "woła"
	var/liked_food = JUNKFOOD | FRIED
	var/disliked_food = GROSS | RAW | CLOTH | GORE
	var/toxic_food = TOXIC
	var/taste_sensitivity = 15 // lower is more sensitive.
	var/modifies_speech = FALSE
	var/static/list/languages_possible_base = typecacheof(list(
		/datum/language/aphasia,
		/datum/language/apidite,
		/datum/language/beachbum,
		/datum/language/buzzwords,
		/datum/language/calcic,
		/datum/language/codespeak,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/moffic,
		/datum/language/monkey,
		/datum/language/narsie,
		/datum/language/piratespeak,
		/datum/language/ratvar,
		/datum/language/shadowtongue,
		/datum/language/slime,
		/datum/language/sylvan,
		/datum/language/terrum,
		/datum/language/uncommon))

/obj/item/organ/tongue/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base

/obj/item/organ/tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

/obj/item/organ/tongue/Insert(mob/living/carbon/M, special = 0)
	if(modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.UnregisterSignal(M, COMSIG_MOB_SAY)
	return ..()

/obj/item/organ/tongue/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	M.RegisterSignal(M, COMSIG_MOB_SAY, TYPE_PROC_REF(/mob/living/carbon, handle_tongueless_speech))
	return ..()

/obj/item/organ/tongue/could_speak_language(datum/language/dt)
	return is_type_in_typecache(dt, languages_possible)

/obj/item/organ/tongue/lizard
	name = "rozwidlony język"
	desc = "Cienki i długi mięsień typowy dla ras gadzich. Podobno dorabia też jako nos."
	icon_state = "tonguelizard"
	say_mod = "syczy"
	taste_sensitivity = 10 // combined nose + tongue, extra sensitive
	modifies_speech = TRUE
	disliked_food = GRAIN | DAIRY | CLOTH | GROSS
	liked_food = GORE | MEAT

/obj/item/organ/tongue/lizard/handle_speech(datum/source, list/speech_args)
	var/static/regex/lizard_hiss = new("s+", "g")
	var/static/regex/lizard_hiSS = new("S+", "g")
	var/static/regex/lizard_kss = new(@"(\w)x", "g")
	var/static/regex/lizard_kSS = new(@"(\w)X", "g")
	var/static/regex/lizard_ecks = new(@"\bx([-rR]|\b)", "g")
	var/static/regex/lizard_eckS = new(@"\bX([-rR]|\b)", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "sss")
		message = lizard_hiSS.Replace(message, "SSS")
		if(owner?.client?.prefs.active_character?.lizard_hiss_style != LIZARD_HISS_LEGACY)
			message = lizard_kss.Replace(message, "$1kss")
			message = lizard_kSS.Replace(message, "$1KSS")
			message = lizard_ecks.Replace(message, "ecks$1")
			message = lizard_eckS.Replace(message, "ECKS$1")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/fly
	name = "trąbka"
	desc = "Dziwacznie wyglądająca mięsna rurka, która podobno potrafi wciągać płyny."
	icon_state = "tonguefly"
	say_mod = "brzęczy"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE
	liked_food = GROSS | RAW | GORE // Limit how much food they actually like. They already have carte blanche on like 90% of food
	disliked_food = NONE
	toxic_food = NONE

/obj/item/organ/tongue/fly/handle_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/tongue/abductor
	name = "matryca nadjęzykowa"
	desc = "Tajemnicza struktura, która pozwala na natychmiastową łączność między użytkownikami. Robi wrażenie, dopóki nie trzeba czegoś zjeść."
	icon_state = "tongueayylmao"
	say_mod = "bełkocze"
	taste_sensitivity = 101 // ayys cannot taste anything.
	modifies_speech = TRUE
	var/mothership

/obj/item/organ/tongue/abductor/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return

	var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	if(!istype(T))
		return

	if(T.mothership == mothership)
		to_chat(H, "<span class='notice'>[src] jest już dostrojony do tego samego kanału co twój.</span>")

	H.visible_message("<span class='notice'>[H] trzyma [src] w dłoniach i przez chwilę się koncentruje.</span>", "<span class='notice'>Próbujesz zmienić dostrojenie [src].</span>")
	if(do_after(H, delay=15, target=src))
		to_chat(H, "<span class='notice'>Dostrajasz [src] do swojego kanału.</span>")
		mothership = T.mothership

/obj/item/organ/tongue/abductor/examine(mob/M)
	. = ..()
	if(HAS_TRAIT(M, TRAIT_ABDUCTOR_TRAINING) || HAS_TRAIT(M.mind, TRAIT_ABDUCTOR_TRAINING) || isobserver(M))
		if(!mothership)
			. += "<span class='notice'>Nie jest dostrojony do żadnego konkretnego statku-matki.</span>"
		else
			. += "<span class='notice'>Jest dostrojony do: [mothership].</span>"

/obj/item/organ/tongue/abductor/handle_speech(datum/source, list/speech_args)
	//Hacks
	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = usr
	var/rendered = "<span class='abductor'><b>[user.real_name]:</b> [message]</span>"
	user.log_talk(message, LOG_SAY, tag="abductor")
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		var/obj/item/organ/tongue/abductor/T = H.getorganslot(ORGAN_SLOT_TONGUE)
		if(!istype(T))
			continue
		if(mothership == T.mothership)
			to_chat(H, rendered)

	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/tongue/zombie
	name = "gnijący język"
	desc = "Rozkład i to, że po prostu tak sobie leży, sprawiają, że wątpisz, by jakikolwiek język wyglądał kiedyś mniej seksownie."
	icon_state = "tonguezombie"
	say_mod = "jęczy"
	modifies_speech = TRUE
	taste_sensitivity = 32
	liked_food = GROSS | MEAT | RAW | GORE

/obj/item/organ/tongue/zombie/handle_speech(datum/source, list/speech_args)
	var/list/message_list = splittext(speech_args[SPEECH_MESSAGE], " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, -3) == "..."))//3 == length("...")
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("MÓZGI", "Mózgi", "Móóózgiii", "MÓÓÓZGIII")]...")

	speech_args[SPEECH_MESSAGE] = jointext(message_list, " ")

/obj/item/organ/tongue/alien
	name = "język obcego"
	desc = "Według czołowych ksenobiologów ewolucyjna korzyść z posiadania drugich ust w ustach polega na tym, że „wygląda to zajebiście”."
	icon_state = "tonguexeno"
	say_mod = "syczy"
	taste_sensitivity = 10 // LIZARDS ARE ALIENS CONFIRMED
	modifies_speech = TRUE // not really, they just hiss
	var/static/list/languages_possible_alien = typecacheof(list(
		/datum/language/xenocommon,
		/datum/language/common,
		/datum/language/draconic,
		/datum/language/ratvar,
		/datum/language/monkey))

/obj/item/organ/tongue/alien/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_alien

/* // AQ EDIT START
/obj/item/organ/tongue/alien/handle_speech(datum/source, list/speech_args)
	playsound(owner, "hiss", 25, 1, 1)
*/ // AQ EDIT END

/obj/item/organ/tongue/bee
	name = "trąbka"
	desc = "Dziwacznie wyglądająca mięsna rurka, która podobno potrafi wciągać płyny. Ta pachnie lekko kwiatami."
	icon_state = "tonguefly"
	say_mod = "brzęczy"
	taste_sensitivity = 5
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | DAIRY
	toxic_food = MEAT | RAW

/obj/item/organ/tongue/bone
	name = "kostny „język”"
	desc = "Podobno szkielety modulują wydawane dźwięki drganiami zębów, stąd ich charakterystyczne grzechotanie."
	icon_state = "tonguebone"
	say_mod = "grzechocze"
	attack_verb = list("gryzie", "szczęka na", "chrupie", "emaliuje", "kościeje")
	taste_sensitivity = 101 // skeletons cannot taste anything
	modifies_speech = TRUE
	liked_food = GROSS | MEAT | RAW | GORE
	disliked_food = NONE // why would they care
	toxic_food = NONE
	var/chattering = FALSE
	var/phomeme_type = "sans"
	var/list/phomeme_types = list("sans", "papyrus")

/obj/item/organ/tongue/bone/Initialize(mapload)
	. = ..()
	phomeme_type = pick(phomeme_types)

/obj/item/organ/tongue/bone/handle_speech(datum/source, list/speech_args)
	if(chattering)
		chatter(speech_args[SPEECH_MESSAGE], phomeme_type, source)
	switch(phomeme_type)
		if("sans")
			speech_args[SPEECH_SPANS] |= SPAN_SANS
		if("papyrus")
			speech_args[SPEECH_SPANS] |= SPAN_PAPYRUS

/obj/item/organ/tongue/bone/plasmaman
	name = "plazmowy kostny „język”"
	desc = "Podobnie jak ożywione szkielety, plazmaludzie mówią, wprawiając zęby w drgania."
	icon_state = "tongueplasma"
	modifies_speech = FALSE
	disliked_food = FRUIT | CLOTH
	liked_food = VEGETABLES

/obj/item/organ/tongue/robot
	name = "robotyczny syntezator mowy"
	desc = "Syntezator głosu, który potrafi porozumiewać się z organicznymi formami życia."
	status = ORGAN_ROBOTIC
	organ_flags = NONE
	icon_state = "tonguerobot"
	say_mod = "stwierdza"
	attack_verb = list("pika na", "pstryka w nos")
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue

/obj/item/organ/tongue/robot/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/machine) + typecacheof(/datum/language/voltaic)

/obj/item/organ/tongue/robot/emp_act(severity)
	owner.emote("scream")
	owner.apply_status_effect(STATUS_EFFECT_SPANISH)
	owner.apply_status_effect(STATUS_EFFECT_IPC_EMP)

/obj/item/organ/tongue/robot/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/obj/item/organ/tongue/snail
	name = "ślimaczy język"
	modifies_speech = TRUE
	say_mod = "bełkocze"

/obj/item/organ/tongue/snail/handle_speech(datum/source, list/speech_args)
	var/new_message
	var/message = speech_args[SPEECH_MESSAGE]
	for(var/i in 1 to length(message))
		if(findtext("ABCDEFGHIJKLMNOPWRSTUVWXYZabcdefghijklmnopqrstuvwxyz", message[i])) //Im open to suggestions
			new_message += message[i] + message[i] + message[i] //aaalllsssooo ooopppeeennn tttooo sssuuuggggggeeessstttiiiooonsss
		else
			new_message += message[i]
	speech_args[SPEECH_MESSAGE] = new_message

/obj/item/organ/tongue/ethereal
	name = "wyładowywacz elektryczny"
	desc = "Wyrafinowany organ eteryków, który syntetyzuje mowę za pomocą wyładowań elektrycznych."
	icon_state = "electrotongue"
	say_mod = "trzeszczy"
	attack_verb = list("razi prądem", "wstrząsa", "razi")
	taste_sensitivity = 101 // Not a tongue, they can't taste shit
	toxic_food = NONE

/obj/item/organ/tongue/ethereal/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/voltaic)

/obj/item/organ/tongue/golem
	name = "mineralny język"
	desc = "Dziwny język z jakiegoś minerału. Jest gładki, ale giętki."
	say_mod = "dudni"
	taste_sensitivity = 101 //They don't eat.
	icon_state = "adamantine_cords"

/obj/item/organ/tongue/golem/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/terrum)

/obj/item/organ/tongue/golem/bananium
	name = "bananiumowy język"
	desc = "To język z czystego bananium."
	say_mod = "trąbi"

/obj/item/organ/tongue/golem/clockwork
	name = "mechaniczny język"
	desc = "To język z wielu maleńkich trybików. Słychać, jak bardzo cicho z niego klika."
	say_mod = "klika"

/obj/item/organ/tongue/cat
	name = "koci język"
	desc = "Szorstki język pokryty na całej powierzchni drobnymi, kostnymi kolcami."
	say_mod = "mówi" //NSV13
	disliked_food = GROSS | VEGETABLES | SUGAR | CLOTH
	liked_food = DAIRY | MEAT | GORE

/obj/item/organ/tongue/slime
	name = "szlamowaty język"
	desc = "To kawałek szlamu w kształcie języka."
	say_mod = list("bulgocze", "bąbelkuje")
	ask_mod = "bulgocze pytająco"
	yell_mod = "bulgocze piskliwie"
	exclaim_mod = "bulgocze głośno"
	liked_food = MEAT | BUGS //cause slimes are mostly carnivores, however the ability to consume RAW or GORE was lost when spliced with humans
	toxic_food = NONE
	disliked_food = NONE

/obj/item/organ/tongue/slime/Initialize(mapload)
	. = ..()
	languages_possible = languages_possible_base += typecacheof(/datum/language/slime)

/obj/item/organ/tongue/moth
	name = "język ćmy"
	desc = "Jest długi i makaronowaty."
	say_mod = "trzepocze"
	icon_state = "tonguemoth"
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS | GORE
	toxic_food = MEAT | RAW

/obj/item/organ/tongue/teratoma
	name = "zdeformowany język"
	desc = "Ten język wygląda dziwnie... Musi pochodzić od stworzenia, które nie powinno istnieć."
	say_mod = "mamrocze"
	icon_state = "tonguefly"
	disliked_food = CLOTH
	liked_food = JUNKFOOD | FRIED | GROSS | RAW | GORE

/obj/item/organ/tongue/podperson
	name = "roślinny język"
	desc = "Dziwny język, z pozoru zrobiony z materii roślinnej."
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN | CLOTH //cannibals apparently
