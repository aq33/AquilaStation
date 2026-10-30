

/obj/item/clothing/head/centhat
	name = "\improper kapelusz Centrali"
	icon_state = "centcom"
	desc = "Dobrze jest być cesarzem."
	item_state = "that"
	flags_inv = NONE
	armor = list("melee" = 30, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30)
	strip_delay = 80
	clothing_flags = SNUG_FIT // prevents bypassing the strip delay

/obj/item/clothing/head/powdered_wig
	name = "pudrowana peruka"
	desc = "Pudrowana peruka."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "cylinder"
	desc = "Kapelusz wyglądający jak u amiszów."
	icon_state = "tophat"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1

/obj/item/clothing/head/canada
	name = "cylinder w czerwone paski"
	desc = "Pachnie jak świeże dziurki od pączków. / <i>Il sent comme des trous de beignets frais.</i>"
	icon_state = "canada"
	item_state = "canada"

/obj/item/clothing/head/redcoat
	name = "kapelusz czerwonego kubraka"
	icon_state = "redcoat"
	desc = "<i>„Chyba jest rudy.”</i>"

/obj/item/clothing/head/mailman
	name = "czapka listonosza"
	icon_state = "mailman"
	desc = "Nakrycie głowy poczty <i>„Zawsze na czas”</i>."

/obj/item/clothing/head/plaguedoctorhat
	name = "kapelusz doktora plagi"
	desc = "Kiedyś nosili je doktorzy plagi. Są właściwie bezużyteczne."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

/obj/item/clothing/head/nursehat
	name = "czepek pielęgniarski"
	desc = "Pozwala szybko rozpoznać przeszkolony personel medyczny."
	icon_state = "nursehat"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/syndicatefake
	name = "replika czarnego hełmu kosmicznego"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"
	desc = "Plastikowa replika hełmu kosmicznego agenta Syndykatu. Wyglądasz w niej jak prawdziwy morderczy agent Syndykatu! To zabawka, nie nadaje się do użytku w kosmosie!"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/cueball
	name = "hełm bila"
	desc = "Duża, gładka biała kula do noszenia na głowie. Jak ty w ogóle przez to coś widzisz?"
	icon_state = "cueball"
	item_state="cueball"
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/snowman
	name = "głowa bałwana"
	desc = "Kula z białego styropianu. Jak świątecznie."
	icon_state = "snowman_h"
	item_state = "snowman_h"
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/justice
	name = "kapelusz sprawiedliwości"
	desc = "Walcz o to, co słuszne!"
	icon_state = "justicered"
	item_state = "justicered"
	flags_inv = HIDEHAIR|HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/flatcap
	name = "kaszkiet"
	desc = "Czapka człowieka pracy."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/pirate
	name = "kapelusz piracki"
	desc = "Jarr."
	icon_state = "pirate"
	item_state = "pirate"
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/pirate
	var/datum/language/piratespeak/L = new

/obj/item/clothing/head/pirate/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_HEAD)
		user.grant_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "Nagle wiesz, jak mówić jak pirat!")

/obj/item/clothing/head/pirate/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_HEAD) == src && !QDELETED(src)) //This can be called as a part of destroy
		user.remove_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "Już nie potrafisz mówić jak pirat.")

/obj/item/clothing/head/pirate/captain
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/head/bandana
	name = "piracka bandana"
	desc = "Jarr."
	icon_state = "bandana"
	item_state = "bandana"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/bowler
	name = "melonik"
	desc = "Dżentelmeni, elita na pokładzie!"
	icon_state = "bowler"
	item_state = "bowler"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/witchwig
	name = "peruka do przebrania czarownicy"
	desc = "Iiiii~hihihihihihih!"
	icon_state = "witch"
	item_state = "witch"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/chicken
	name = "głowa przebrania kurczaka"
	desc = "Ko-ko!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/griffin
	name = "głowa gryfa"
	desc = "Czemu nie „głowa orła”? Kto to wie."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/bearpelt
	name = "czapka z niedźwiedziej skóry"
	desc = "Puchata."
	icon_state = "bearpelt"
	item_state = "bearpelt"

/obj/item/clothing/head/xenos
	name = "hełm ksenomorfa"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "Hełm z chitynowej skóry obcego."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "Naprawdę fajny kapelusz, jeśli jesteś mafiozem. Naprawdę żałosny, jeśli nie jesteś."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/fedora/suicide_act(mob/user)
	if(user.gender == FEMALE)
		return 0
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] zakłada [src]! Wygląda na to, że próbuje być miły dla dziewczyn.</span>")
	user.say("M'lady.", forced = "fedora suicide")
	sleep(10)
	H.facial_hair_style = "Neckbeard"
	return(BRUTELOSS)

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "Niemal czujesz smak fiesty."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

/obj/item/clothing/head/sombrero/green
	name = "zielone sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "Elegancki jak tańczący kaktus."
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero
	name = "wstydbrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Raz założone, nigdy nie schodzi."
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/head/flatcap
	name = "kaszkiet"
	desc = "Czapka człowieka pracy."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/hunter
	name = "kapelusz łowcy nagród"
	desc = "W moim mieście nikt nie wykiwa kata."
	icon_state = "hunter"
	item_state = "hunter"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 20)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/cone
	desc = "Ten pachołek próbuje cię przed czymś ostrzec!"
	name = "pachołek ostrzegawczy"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("ostrzega", "upomina", "rozbija")
	resistance_flags = NONE
	dynamic_hair_suffix = ""

/obj/item/clothing/head/santa
	name = "czapka Mikołaja"
	desc = "W pierwszy dzień świąt dał mi pracodawca!"
	icon_state = "santahatnorm"
	item_state = "that"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/head/jester
	name = "czapka błazna"
	desc = "Czapka z dzwoneczkami, która dodaje strojowi wesołości."
	icon_state = "jester_hat"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/rice_hat
	name = "kapelusz ryżowy"
	desc = "Witaj na polach ryżowych, skurwielu."
	icon_state = "rice_hat"

/obj/item/clothing/head/lizard
	name = "kapelusz cloche z jaszczurczej skóry"
	desc = "Ile jaszczurów zginęło, żeby powstał ten kapelusz? Za mało."
	icon_state = "lizard"

/obj/item/clothing/head/papersack
	name = "papierowa torba na głowę"
	desc = "Papierowa torba z niezgrabnie wyciętymi otworami na oczy. Przydaje się do ukrycia tożsamości albo brzydoty."
	icon_state = "papersack"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/papersack/smiley
	name = "papierowa torba na głowę"
	desc = "Papierowa torba z niezgrabnie wyciętymi otworami na oczy i koślawym uśmiechem narysowanym z przodu. Wcale nie jest straszna."
	icon_state = "papersack_smile"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT

/obj/item/clothing/head/crown
	name = "korona"
	desc = "Korona godna króla. No, może królika."
	icon_state = "crown"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0,"energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 40)
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = ""

/obj/item/clothing/head/crown/fancy
	name = "wspaniała korona"
	desc = "Korona noszona tylko przez najwyższych cesarzy <s>ziemi</s> kosmosu."
	icon_state = "fancycrown"

/obj/item/clothing/head/scarecrow_hat
	name = "kapelusz stracha na wróble"
	desc = "Prosty słomkowy kapelusz."
	icon_state = "scarecrow_hat"

/obj/item/clothing/head/lobsterhat
	name = "piankowa głowa homara"
	desc = "Gdy wszystko idzie do raka, najlepiej chronić głowę."
	icon_state = "lobster_hat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/drfreezehat
	name = "peruka doktora Freeze'a"
	desc = "Chłodna peruka dla fajnych ludzi."
	icon_state = "drfreeze_hat"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/pharaoh
	name = "nakrycie głowy faraona"
	desc = "Chodź jak Egipcjanin."
	icon_state = "pharoah_hat"
	icon_state = "pharoah_hat"

/obj/item/clothing/head/jester/alt
	name = "czapka błazna"
	desc = "Czapka z dzwoneczkami, która dodaje strojowi wesołości."
	icon_state = "jester_hat2"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/nemes
	name = "chusta nemes"
	desc = "Wystawny kosmiczny grobowiec nie jest dołączony."
	icon_state = "nemes_headdress"
	icon_state = "nemes_headdress"

/obj/item/clothing/head/delinquent
	name = "czapka chuligana"
	desc = "Dobry Boże."
	icon_state = "delinquent"

/obj/item/clothing/head/frenchberet
	name = "francuski beret"
	desc = "Porządny beret przesiąknięty aromatem paryżan, którzy palą jednego za drugim i chleją wino. Z jakiegoś powodu masz mniejszą ochotę na udział w konfliktach zbrojnych."
	icon_state = "beret"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/frenchberet/equipped(mob/M, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/french_words = strings(FRENCH_TALK_FILE, "french")

		for(var/key in french_words)
			var/value = french_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Honh honh honh!"," Honh!"," Zut Alors!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/head/clownmitre
	name = "Kapelusz Matki Honku"
	desc = "Wiernym trudno dostrzec skórkę od banana na podłodze, gdy wpatrują się w twój wspaniały kapelusz."
	icon_state = "clownmitre"

/obj/item/clothing/head/kippah
	name = "kipa"
	desc = "Pokazuje, że przestrzegasz żydowskiej halachy. Zakrywa głowę i czyni duszę wyjątkowo ortodoksyjną."
	icon_state = "kippah"

/obj/item/clothing/head/medievaljewhat
	name = "średniowieczny kapelusz żydowski"
	desc = "Głupio wyglądający kapelusz przeznaczony dla uciskanych mniejszości religijnych na stacji."
	icon_state = "medievaljewhat"

/obj/item/clothing/head/taqiyahwhite
	name = "biała takijja"
	desc = "Wyjątkowo mustahabb sposób okazania oddania Allahowi."
	icon_state = "taqiyahwhite"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/taqiyahred
	name = "czerwona takijja"
	desc = "Wyjątkowo mustahabb sposób okazania oddania Allahowi."
	icon_state = "taqiyahred"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/intern
	name = "\improper czapko-czapeczka starszego stażysty Centrali"
	desc = "Przerażające skrzyżowanie czapki zimowej z bejsbolówką w zieleni Centrali. Trzeba naprawdę rozpaczliwie pragnąć władzy nad kolegami, żeby zgodzić się to nosić."
	icon_state = "intern_hat"
	item_state = "intern_hat"

/obj/item/clothing/head/rainbowbunchcrown
	name = "tęczowy wianek"
	desc = "Wianek z kwiatów tęczowej kiści."
	dynamic_hair_suffix = ""
	attack_verb = list("koronuje")

/obj/item/clothing/head/rainbowbunchcrown/Initialize(mapload)
	. = ..()
	var/crown_type = rand(1,4)
	switch(crown_type)
		if(1)
			desc += " Ten ma czerwone, żółte i białe kwiaty."
			icon_state = "rainbow_bunch_crown_1"
		if(2)
			desc += " Ten ma niebieskie, żółte, zielone i białe kwiaty."
			icon_state = "rainbow_bunch_crown_2"
		if(3)
			desc += " Ten ma czerwone, niebieskie, fioletowe i różowe kwiaty."
			icon_state = "rainbow_bunch_crown_3"
		if(4)
			desc += " Ten ma żółte, zielone i białe kwiaty."
			icon_state = "rainbow_bunch_crown_4"

/obj/item/clothing/head/sunflowercrown
	name = "wianek ze słoneczników"
	desc = "Jasny wianek ze słoneczników, który na pewno rozjaśni każdemu dzień!"
	icon_state = "sunflower_crown"
	dynamic_hair_suffix = ""
	attack_verb = list("koronuje")

/obj/item/clothing/head/poppycrown
	name = "wianek z maków"
	desc = "Wianek ze sznura jaskrawoczerwonych maków."
	icon_state = "poppy_crown"
	dynamic_hair_suffix = ""
	attack_verb = list("koronuje")

/obj/item/clothing/head/lilycrown
	name = "wianek z lilii"
	desc = "Liściasty wianek z kiścią dużych białych lilii z przodu."
	icon_state = "lily_crown"
	dynamic_hair_suffix = ""
	attack_verb = list("koronuje")

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/head/gangsterwig
	name = "peruka gangstera"
	desc = "Jaki ojciec, taki syn."
	icon_state = "gangster_wig"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/oldhat
	name = "kapelusz staruszka"
	desc = "O MÓJ BOŻE."
	icon_state = "oldmanhat"

/obj/item/clothing/head/marine
	name = "czapka marynarza"
	desc = "Nie ma to jak poranna bryza od oceanu."
	icon_state = "marine"

/obj/item/clothing/head/chicken_head_retro
	name = "głowa kurczaka"
	desc = "Wygląda zupełnie jak prawdziwa."
	icon_state = "chicken"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/maidheadband
	name = "opaska pokojówki"
	desc = "Zupełnie jak z tych chińskich kreskówek!"
	icon_state = "maid_headband"
