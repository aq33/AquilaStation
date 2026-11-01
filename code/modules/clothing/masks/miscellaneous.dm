/obj/item/clothing/mask/muzzle
	name = "kaganiec"
	desc = "Żeby uciszyć ten okropny hałas."
	icon_state = "muzzle"
	item_state = "blindfold"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.9
	equip_delay_other = 20

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			to_chat(user, "<span class='warning'>Potrzebujesz pomocy, żeby to zdjąć!</span>")
			return
	..()

/obj/item/clothing/mask/surgical
	name = "maseczka chirurgiczna"
	desc = "Sterylna maseczka, która pomaga zapobiegać rozprzestrzenianiu się chorób."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE|HIDESNOUT
	visor_flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 25, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "sztuczny wąs"
	desc = "Uwaga: wąs jest sztuczny."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/fakemoustache/italian
	name = "włoski wąs"
	desc = "Zrobiony z autentycznych włosów włoskich wąsów. Budzi w noszącym nieodpartą chęć dzikiego gestykulowania."
	clothing_flags = SHOWEROKAY //NSV13 - kept SHOWEROKAY
	modifies_speech = TRUE

/obj/item/clothing/mask/fakemoustache/italian/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/italian_words = strings(ITALIAN_TALK_FILE, "italian")

		for(var/key in italian_words)
			var/value = italian_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Ravioli, ravioli, give me the formuoli!"," Mamma-mia!"," Mamma-mia! That's a spicy meat-ball!", " La la la la la funiculi funicula!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/mask/joy
	name = "maska emocji"
	desc = "Wyraź radość albo ukryj smutki za tą kulturalną wycinanką."
	icon_state = "joy"
	item_state = "joy"
	flags_inv = HIDESNOUT
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/joy/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Radość"] = "joy"
	options["Rumieniec"] = "flushed"
	options["Zaduma"] = "pensive"
	options["Złość"] = "angry"
	options["Błaganie"] ="pleading"

	var/choice = input(user,"W jaką formę chcesz przemienić tę maskę?","Przemiana maski") in sortList(options)

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "<span class='notice'>Twoja maska emocji przemieniła się w [choice]!</span>")
		return 1


/obj/item/clothing/mask/pig
	name = "maska świni"
	desc = "Gumowa maska świni z wbudowanym modulatorem głosu."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = VOICEBOX_TOGGLABLE
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/pig/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("Chrum!","Kwiiiiiiiii!","Chrum chrum!")

/obj/item/clothing/mask/pig/cursed
	name = "świński ryj"
	desc = "Wygląda jak maska, ale z bliska widać, że zrosła się z twarzą tej osoby!"
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/pig/cursed/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/pighead_curse.ogg', 50, 1)

///frog mask - reeee!!
/obj/item/clothing/mask/frog
	name = "maska żaby"
	desc = "Starożytna maska wyrzeźbiona w kształcie żaby.<br> Zdrowy rozsądek jest jak grawitacja, wystarczy go lekko popchnąć."
	icon_state = "frog"
	item_state = "frog"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE
	modifies_speech = TRUE

/obj/item/clothing/mask/frog/handle_speech(datum/source, list/speech_args) //whenever you speak
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		if(prob(5)) //sometimes, the angry spirit finds others words to speak.
			speech_args[SPEECH_MESSAGE] = pick("HUUUUU!!","SMOOOOOKIN'!!","Hello my baby, hello my honey, hello my rag-time gal.", "Smutno mi, stary.", "ZDEJMIJCIE ZE MNIE TEGO GOŚCIA!!" ,"NIECH KTOŚ MNIE POWSTRZYMA!!", "NORMIKI, WYNOCHA!!")
		else
			speech_args[SPEECH_MESSAGE] = pick("Ree!!", "Reee!!","REEE!!","REEEEE!!") //but its usually just angry gibberish,

/obj/item/clothing/mask/frog/cursed
	clothing_flags = NONE

/obj/item/clothing/mask/frog/cursed/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)

/obj/item/clothing/mask/frog/cursed/equipped(mob/user, slot)
	var/mob/living/carbon/C = user
	if(C.wear_mask == src && HAS_TRAIT_FROM(src, TRAIT_NODROP, CURSED_MASK_TRAIT))
		to_chat(user, "<span class='userdanger'>[src] jest przeklęta! Ree!!</span>")
	return ..()

/obj/item/clothing/mask/cowmask
	name = "maska krowy"
	icon_state = "cowmask"
	item_state = "cowmask"
	clothing_flags = VOICEBOX_TOGGLABLE
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/cowmask/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("Muuuuuuu!","Muu!","Muuuu!")

/obj/item/clothing/mask/cowmask/cursed
	name = "krowi pysk"
	desc = "Wygląda jak maska krowy, ale z bliska widać, że zrosła się z twarzą tej osoby!"
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/cowmask/cursed/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/cowhead_curse.ogg', 50, 1)

/obj/item/clothing/mask/horsehead
	name = "maska końskiej głowy"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę konia."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEYES|HIDEEARS|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE
	modifies_speech = TRUE

/obj/item/clothing/mask/horsehead/handle_speech(datum/source, list/speech_args)
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		speech_args[SPEECH_MESSAGE] = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")

/obj/item/clothing/mask/horsehead/cursed
	name = "koński pysk"
	desc = "Na pierwszy rzut oka wygląda jak maska, ale zrosła się z twarzą tego biedaka."
	clothing_flags = NONE
	flags_inv = HIDEFACIALHAIR

/obj/item/clothing/mask/horsehead/cursed/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/horsehead_curse.ogg', 50, 1)

/obj/item/clothing/mask/rat
	name = "maska szczura"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę szczura."
	icon_state = "rat"
	item_state = "rat"
	flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/rat/fox
	name = "maska lisa"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę lisa."
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/rat/bee
	name = "maska pszczoły"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę pszczoły."
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/rat/bear
	name = "maska niedźwiedzia"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę niedźwiedzia."
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/rat/bat
	name = "maska nietoperza"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę nietoperza."
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/rat/raven
	name = "maska kruka"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę kruka."
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/rat/jackal
	name = "maska szakala"
	desc = "Maska z miękkiego winylu i lateksu przedstawiająca głowę szakala."
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/rat/tribal
	name = "maska plemienna"
	desc = "Maska wyrzeźbiona w drewnie, starannie wykończona ręcznie."
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/bandana
	name = "bandana botanika"
	desc = "Porządna bandana z nanotechnologiczną podszewką i wzorem hydroponicznym."
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK
	adjusted_flags = ITEM_SLOT_HEAD
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/AltClick(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.get_item_by_slot(ITEM_SLOT_HEAD == src)) || (C.get_item_by_slot(ITEM_SLOT_MASK) == src))
			to_chat(user, "<span class='warning'>Nie możesz zawiązać [src], gdy ją nosisz!</span>")
			return
	if(slot_flags & ITEM_SLOT_HEAD)
		to_chat(user, "<span class='warning'>Musisz rozwiązać [src], zanim zawiążesz ją w apaszkę!</span>")
	else
		if(user.is_holding(src))
			var/obj/item/clothing/neck/neckerchief/nk = new(src)
			nk.name = "[name] (apaszka)"
			nk.desc = "[desc] Jest zawiązana jak apaszka."
			nk.icon_state = icon_state
			nk.sourceBandanaType = src.type
			var/currentHandIndex = user.get_held_index_of_item(src)
			user.transferItemToLoc(src, null)
			user.put_in_hand(nk, currentHandIndex)
			user.visible_message("<span class='notice'>[user] zawiązuje [src] w apaszkę.</span>", "<span class='notice'>Zawiązujesz [src] w apaszkę.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Musisz trzymać [src], by ją zawiązać!")

/obj/item/clothing/mask/bandana/red
	name = "czerwona bandana"
	desc = "Porządna czerwona bandana z nanotechnologiczną podszewką."
	icon_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "niebieska bandana"
	desc = "Porządna niebieska bandana z nanotechnologiczną podszewką."
	icon_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "zielona bandana"
	desc = "Porządna zielona bandana z nanotechnologiczną podszewką."
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "złota bandana"
	desc = "Porządna złota bandana z nanotechnologiczną podszewką."
	icon_state = "bandgold"

/obj/item/clothing/mask/bandana/black
	name = "czarna bandana"
	desc = "Porządna czarna bandana z nanotechnologiczną podszewką."
	icon_state = "bandblack"

/obj/item/clothing/mask/bandana/skull
	name = "bandana z czaszką"
	desc = "Porządna czarna bandana z nanotechnologiczną podszewką i emblematem czaszki."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/durathread
	name = "bandana z duranici"
	desc =  "Bandana z duranici. Chciałoby się, żeby dawała noszącemu jakąś ochronę, ale jest o wiele za cienka..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/mummy
	name = "maska mumii"
	desc = "Starożytne bandaże."
	icon_state = "mummy_mask"
	item_state = "mummy_mask"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/scarecrow
	name = "maska z worka"
	desc = "Worek z juty z otworami na oczy."
	icon_state = "scarecrow_sack"
	item_state = "scarecrow_sack"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/gondola
	name = "maska gondoli"
	desc = "Prawdziwe futro gondoli."
	icon_state = "gondola"
	item_state = "gondola"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	modifies_speech = TRUE

/obj/item/clothing/mask/gondola/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/spurdo_words = strings(GONGOLA_TALK_FILE, "spurdo")
		for(var/key in spurdo_words)
			var/value = spurdo_words[key]
			if(islist(value))
				value = pick(value)
			message = replacetextEx(message,regex(uppertext(key),"g"), "[uppertext(value)]")
			message = replacetextEx(message,regex(capitalize(key),"g"), "[capitalize(value)]")
			message = replacetextEx(message,regex(key,"g"), "[value]")
	speech_args[SPEECH_MESSAGE] = trim(message)
