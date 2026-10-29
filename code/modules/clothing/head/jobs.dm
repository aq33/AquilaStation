//defines the drill hat's yelling setting
#define DRILL_DEFAULT	"default"
#define DRILL_SHOUTING	"shouting"
#define DRILL_YELLING	"yelling"
#define DRILL_CANADIAN	"canadian"

//Chef
/obj/item/clothing/head/chefhat
	name = "czapka kucharska"
	item_state = "chef"
	icon_state = "chef"
	desc = "Nakrycie głowy naczelnego dowódcy kuchni."
	strip_delay = 10
	equip_delay_other = 10
	dynamic_hair_suffix = ""
	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/chefhat/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zakłada [src]! Wygląda na to, że próbuje zostać kucharzem.</span>")
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(20)
	user.visible_message("<span class='suicide'>[user] wchodzi do wyimaginowanego piekarnika!</span>")
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, 1)
	return(FIRELOSS)

//Captain
/obj/item/clothing/head/caphat
	name = "czapka kapitana"
	desc = "Dobrze jest być królem."
	icon_state = "captain"
	item_state = "that"
	flags_inv = 0
	armor = list("melee" = 25, "bullet" = 25, "laser" = 15, "energy" = 20, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30, "bleed" = 30) //NSV13
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

//Captain: This is no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "czapka galowa kapitana"
	desc = "Noszona tylko przez kapitanów z wyjątkową klasą."
	icon_state = "capcap"

	dog_fashion = null

//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "czapka starszego oficera"
	icon_state = "hopcap"
	desc = "Symbol prawdziwego biurokratycznego mikrozarządzania."
	armor = list("melee" = 25, "bullet" = 25, "laser" = 15, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30, "bleed" = 15) //NSV13
	dog_fashion = /datum/dog_fashion/head/hop

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "kaptur zakonnicy"
	desc = "Najwyższa pobożność w tym układzie gwiezdnym."
	icon_state = "nun_hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/bishopmitre
	name = "mitra biskupia"
	desc = "Okazałe nakrycie głowy, które działa jak radio do Boga. Albo jak piorunochron, zależy, kogo zapytać."
	icon_state = "bishopmitre"

/obj/item/clothing/head/bishopmitre/black
	icon_state = "blackbishopmitre"

//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "fedora detektywa"
	desc = "Tylko jeden człowiek potrafi wywęszyć brudny smród zbrodni i pewnie nosi właśnie ten kapelusz."
	armor = list("melee" = 25, "bullet" = 25, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50, "stamina" = 25, "bleed" = 20) //NSV13
	icon_state = "detective"
	var/candy_cooldown = 0
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/detective
	dog_fashion = /datum/dog_fashion/head/detective

/obj/item/clothing/head/fedora/det_hat/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/food/drinks/flask/det(src)

/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-klik, by wziąć cukierka kukurydzianego.</span>"

/obj/item/clothing/head/fedora/det_hat/AltClick(mob/user)
	. = ..()
	if(loc != user || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	if(candy_cooldown < world.time)
		var/obj/item/food/candy_corn/CC = new /obj/item/food/candy_corn(src)
		user.put_in_hands(CC)
		to_chat(user, "Wyciągasz z kapelusza cukierka kukurydzianego.")
		candy_cooldown = world.time+1200
	else
		to_chat(user, "Właśnie wziąłeś cukierka kukurydzianego! Poczekaj kilka minut, żeby nie wyczerpać zapasu.")


//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "Beret, ulubione nakrycie głowy mimów."
	icon_state = "beret"
	dog_fashion = /datum/dog_fashion/head/beret
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/head/beret/vintage
	name = "beret w stylu vintage"
	desc = "Mocno znoszony beret."
	icon_state = "vintageberet"
	dog_fashion = null

/obj/item/clothing/head/beret/navy
	name = "granatowy beret"
	icon_state = "beret_blue"
	dog_fashion = null

/obj/item/clothing/head/beret/archaic
	name = "archaiczny beret"
	desc = "Absolutnie prastary beret, który podobno nosił pierwszy mim, jaki postawił stopę na stacji Nanotrasen."
	icon_state = "archaicberet"
	dog_fashion = null

/obj/item/clothing/head/beret/black
	name = "czarny beret"
	desc = "Czarny beret, idealny dla weteranów wojennych i mrocznych, posępnych mimów-antybohaterów."
	icon_state = "beretblack"

/obj/item/clothing/head/beret/highlander
	desc = "To był biały materiał. <i>Był.</i>"
	dog_fashion = null //THIS IS FOR SLAUGHTER, NOT PUPPIES

/obj/item/clothing/head/beret/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/head/beret/durathread
	name = "beret z duranici"
	desc =  "Beret z duranici. Jego wytrzymałe włókna zapewniają noszącemu pewną ochronę."
	icon_state = "beretdurathread"
	armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5, "stamina" = 20, "bleed" = 45) //NSV13

//Security

/obj/item/clothing/head/HoS
	name = "czapka komendanta"
	desc = "Solidna regulaminowa czapka Komendanta. Pokazuje policjantom, kto tu rządzi."
	icon_state = "hoscap"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 15, "energy" = 10, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60, "stamina" = 30) //NSV13
	strip_delay = 80
	dynamic_hair_suffix = ""

/obj/item/clothing/head/HoS/syndicate
	name = "czapka Syndykatu"
	desc = "Czarna czapka godna wysokiego rangą oficera Syndykatu."

/obj/item/clothing/head/HoS/beret
	name = "beret komendanta"
	desc = "Solidny beret dla Komendanta. Pozwala wyglądać stylowo bez rezygnacji z ochrony."
	icon_state = "hosberetblack"

/obj/item/clothing/head/HoS/beret/syndicate
	name = "beret Syndykatu"
	desc = "Czarny beret z grubą wyściółką pancerną w środku. Stylowy i wytrzymały."

/obj/item/clothing/head/warden
	name = "czapka policyjna naczelnika"
	desc = "Specjalna opancerzona czapka wydawana Naczelnikowi policji. Chroni głowę przed uderzeniami."
	icon_state = "policehelm"
	armor = list("melee" = 40, "bullet" = 45, "laser" = 10, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 60, "stamina" = 30, "bleed" = 25) //NSV13
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/warden/drill
	name = "kapelusz musztrowy naczelnika"
	desc = "Specjalny opancerzony kapelusz musztrowy z insygniami policji. Wzmocniony materiał zapewnia wystarczającą ochronę."
	icon_state = "wardendrill"
	item_state = "wardendrill"
	dog_fashion = null
	var/mode = DRILL_DEFAULT

/obj/item/clothing/head/warden/drill/screwdriver_act(mob/living/carbon/human/user, obj/item/I)
	if(..())
		return TRUE
	switch(mode)
		if(DRILL_DEFAULT)
			to_chat(user, "<span class='notice'>Ustawiasz obwód głosowy w środkowej pozycji.</span>")
			mode = DRILL_SHOUTING
		if(DRILL_SHOUTING)
			to_chat(user, "<span class='notice'>Ustawiasz obwód głosowy w ostatniej pozycji.</span>")
			mode = DRILL_YELLING
		if(DRILL_YELLING)
			to_chat(user, "<span class='notice'>Ustawiasz obwód głosowy w pierwszej pozycji.</span>")
			mode = DRILL_DEFAULT
		if(DRILL_CANADIAN)
			to_chat(user, "<span class='danger'>Regulujesz obwód głosowy, ale nic się nie dzieje, pewnie dlatego, że jest zepsuty.</span>")
	return TRUE

/obj/item/clothing/head/warden/drill/wirecutter_act(mob/living/user, obj/item/I)
	if(mode != DRILL_CANADIAN)
		to_chat(user, "<span class='danger'>Psujesz obwód głosowy!</span>")
		mode = DRILL_CANADIAN
	return TRUE

/obj/item/clothing/head/warden/drill/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/warden/drill/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/warden/drill/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		switch(mode)
			if(DRILL_SHOUTING)
				message = replacetextEx(message, ".", "!", length(message))
			if(DRILL_YELLING)
				message = replacetextEx(message, ".", "!!", length(message))
			if(DRILL_CANADIAN)
				message = "[message]"
				var/list/canadian_words = strings(CANADIAN_TALK_FILE, "canadian")

				for(var/key in canadian_words)
					var/value = canadian_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")

				if(prob(30))
					message = replacetextEx(message, ".", pick(", eh?", ", EH?"), length(message))
		speech_args[SPEECH_MESSAGE] = message

/obj/item/clothing/head/beret/corpwarden
	name = "korporacyjny beret naczelnika"
	desc = "Specjalny czarny beret z insygniami Naczelnika pośrodku. Zwykle noszą go korporacyjni naczelnicy."
	icon_state = "beret_corporate_warden"
	armor = list("melee" = 40, "bullet" = 45, "laser" = 20, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 60, "stamina" = 30, "bleed" = 25) //NSV13
	strip_delay = 60

/obj/item/clothing/head/beret/sec
	name = "beret policyjny"
	desc = "Solidny beret z insygniami policji. Wzmocniony materiał zapewnia wystarczającą ochronę."
	icon_state = "beret_badge"
	armor = list("melee" = 30, "bullet" = 40, "laser" = 20,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30, "bleed" = 25) //NSV13
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/beret/corpsec
	name = "korporacyjny beret policyjny"
	desc = "Specjalny czarny beret na przyziemne życie korporacyjnego policjanta."
	icon_state = "beret_corporate_officer"
	armor = list("melee" = 35, "bullet" = 40, "laser" = 20, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50, "stamina" = 30, "bleed" = 25) //NSV13
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyhos
	name = "beret komendanta"
	desc = "Specjalny beret z insygniami Komendanta. Symbol doskonałości, odznaka odwagi, znak wyróżnienia."
	icon_state = "hosberet"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 20,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 40) //NSV13

/obj/item/clothing/head/beret/sec/navywarden
	name = "beret naczelnika"
	desc = "Specjalny beret z insygniami Naczelnika. Dla naczelników z klasą."
	icon_state = "wardenberet"
	armor = list("melee" = 40, "bullet" = 45, "laser" = 10, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50, "stamina" = 30, "bleed" = 25) //NSV13
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "Specjalny beret z insygniami policji. Dla policjantów z klasą."
	icon_state = "officerberet"

//Curator
/obj/item/clothing/head/fedora/curator
	name = "fedora poszukiwacza skarbów"
	desc = "Dostałeś dziś czerwony tekst, młody, ale to nie znaczy, że musi ci się to podobać."
	icon_state = "curator"

/obj/item/clothing/head/beret/eng
	name = "beret inżynieryjny"
	desc = "Beret z insygniami inżynierii. Dla inżynierów, którzy bardziej cenią styl niż bezpieczeństwo."
	icon_state = "beret_engineering"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 10, "acid" = 0, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

/obj/item/clothing/head/beret/atmos
	name = "beret atmosferyki"
	desc = "Beret dla tych, którzy wykazali się nienaganną biegłością w kładzeniu rur. Albo w hydraulice."
	icon_state = "beret_atmospherics"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 10, "acid" = 0, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

/obj/item/clothing/head/beret/ce
	name = "beret głównego inżyniera"
	desc = "Biały beret z insygniami inżynierii. Jego właściciel wie, co robi. Chyba."
	icon_state = "beret_ce"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 0, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

/obj/item/clothing/head/beret/sci
	name = "beret naukowy"
	desc = "Fioletowy beret z insygniami nauki. Ma ten autentyczny zapach płonącej plazmy."
	icon_state = "beret_sci"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 5, "bio" = 5, "rad" = 0, "fire" = 5, "acid" = 10, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

/obj/item/clothing/head/beret/supply
	name = "beret zaopatrzenia"
	desc = "Brązowy beret z insygniami zaopatrzenia. Nie możesz przestać się zastanawiać, za ile dałoby się go sprzedać."
	icon_state = "beret_supply"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 10, "fire" = 10, "acid" = 0, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

//Medical
/obj/item/clothing/head/beret/med
	name = "beret medyczny"
	desc = "Biały beret z precyzyjnie wyszytym niebieskim krzyżem. Ma w sobie ten sterylny zapach."
	icon_state = "beret_med"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 20, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

/obj/item/clothing/head/beret/cmo
	name = "beret ordynatora"
	desc = "Błękitny beret z insygniami Medistanu. Pachnie bardzo sterylnie."
	icon_state = "beret_cmo"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 30, "rad" = 10, "fire" = 0, "acid" = 20, "stamina" = 0, "bleed" = 0)
	strip_delay = 60

//CentCom
/obj/item/clothing/head/beret/cccaptain
	name = "beret kapitana Centrali"
	desc = "Śnieżnobiały beret z insygniami kapitana Centrali."
	icon_state = "beret_centcom_captain"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80, stamina = 80, "bleed" = 80)
	strip_delay = 120

/obj/item/clothing/head/beret/ccofficer
	name = "beret oficera Centrali"
	desc = "Czarny beret oficera Centrali z pasującymi insygniami."
	icon_state = "beret_centcom_officer"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80, stamina = 80, "bleed" = 80)
	strip_delay = 120

/obj/item/clothing/head/beret/ccofficernavy
	name = "beret oficera marynarki Centrali"
	desc = "Granatowy beret, który zwykle noszą oficerowie marynarki Centrali."
	icon_state = "beret_centcom_officer_navy"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80, stamina = 80, "bleed" = 80)
	strip_delay = 120

//For blueshields, but those aren't in so I renamed them to centcom guards
/obj/item/clothing/head/beret/ccguard
	name = "beret oficera"
	desc = "Czarny beret strażnika Centrali."
	icon_state = "beret_centcom_officer"
	armor = list(melee = 40, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 5, rad = 5, fire = 5, acid = 30, stamina = 30, "bleed" = 20)
	strip_delay = 60

/obj/item/clothing/head/beret/ccguardnavy
	name = "granatowy beret oficera"
	desc = "Granatowy beret strażnika Centrali."
	icon_state = "beret_centcom_officer_navy"
	armor = list(melee = 40, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 5, rad = 5, fire = 5, acid = 30, stamina = 30, "bleed" = 20)
	strip_delay = 60

/obj/item/clothing/head/beret/captain
	name = "beret kapitana"
	desc = "Uroczy niebieski beret kapitana ze złoto-białymi insygniami."
	icon_state = "beret_captain"
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 30, bomb = 15, bio = 10, rad = 10, fire = 10, acid = 60, stamina = 40, "bleed" = 20)
	strip_delay = 90

#undef DRILL_DEFAULT
#undef DRILL_SHOUTING
#undef DRILL_YELLING
#undef DRILL_CANADIAN
