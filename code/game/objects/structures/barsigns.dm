/obj/structure/sign/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "szyld baru"
	desc = "Szyld baru, który jakimś cudem się nie zainicjował. Poskarż się koderowi!"
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 250
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 0, "bleed" = 0)
	buildable_sign = 0

	var/panel_open = FALSE
	var/datum/barsign/chosen_sign

/obj/structure/sign/barsign/Initialize(mapload)
	. = ..()
	set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/structure/sign/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return

	icon_state = sign.icon

	if(sign.name)
		name = "[initial(name)] ([sign.name])"
	else
		name = "[initial(name)]"

	if(sign.desc)
		desc = sign.desc

	if(sign.rename_area && sign.name)
		rename_area(src, sign.name)

	return sign

/obj/structure/sign/barsign/proc/set_sign_by_name(sign_name)
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) == sign_name)
			var/new_sign = new D
			return set_sign(new_sign)

/obj/structure/sign/barsign/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = TRUE

/obj/structure/sign/barsign/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 2)
	new /obj/item/stack/cable_coil(drop_location(), 2)
	qdel(src)

/obj/structure/sign/barsign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/sign/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/barsign/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		to_chat(user, "<span class='info'>Odmowa dostępu.</span>")
		return
	if(broken)
		to_chat(user, "<span class ='danger'>Sterowanie wydaje się nie reagować.</span>")
		return
	pick_sign(user)

/obj/structure/sign/barsign/attackby(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!panel_open)
			to_chat(user, "<span class='notice'>Otwierasz panel serwisowy.</span>")
			set_sign(new /datum/barsign/hiddensigns/signoff)
			panel_open = TRUE
		else
			to_chat(user, "<span class='notice'>Zamykasz panel serwisowy.</span>")
			if(!broken)
				if(!chosen_sign)
					set_sign(new /datum/barsign/hiddensigns/signoff)
				else
					set_sign(chosen_sign)
			else
				set_sign(new /datum/barsign/hiddensigns/empbarsign)
			panel_open = FALSE

	else if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/C = I
		if(!broken)
			to_chat(user, "<span class='warning'>Ten szyld działa prawidłowo!</span>")
			return

		if(C.use(2))
			to_chat(user, "<span class='notice'>Wymieniasz spalone okablowanie.</span>")
			broken = FALSE
		else
			to_chat(user, "<span class='warning'>Potrzebujesz przynajmniej dwóch odcinków kabla!</span>")
	else
		return ..()


/obj/structure/sign/barsign/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_sign(new /datum/barsign/hiddensigns/empbarsign)
	broken = TRUE

/obj/structure/sign/barsign/emag_act(mob/user)
	if(broken)
		to_chat(user, "<span class='warning'>Nie dzieje się nic ciekawego!</span>")
		return
	to_chat(user, "<span class='notice'>Wczytujesz nielegalny szyld do bufora pamięci...</span>")
	sleep(10 SECONDS)
	chosen_sign = set_sign(new /datum/barsign/hiddensigns/syndibarsign)


/obj/structure/sign/barsign/proc/pick_sign(mob/user)
	var/picked_name = input(user, "Dostępne szyldy", "Szyld baru", name) as null|anything in sortList(get_bar_names())
	if(!picked_name)
		return
	chosen_sign = set_sign_by_name(picked_name)
	SSblackbox.record_feedback("tally", "barsign_picked", 1, chosen_sign.type)

/proc/get_bar_names()
	var/list/names = list()
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) && !initial(D.hidden))
			names += initial(D.name)
	. = names

/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"
	var/hidden = FALSE
	var/rename_area = TRUE

/datum/barsign/New()
	if(!desc)
		desc = "Wyświetla napis „[name]”."

// Specific bar signs.

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Falcon, kosmiczny bar i grill."

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ulubiony bar Iana."

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "Świetne doznania kulinarne zarówno dla ochrony, jak i majtków."

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "Tu przychodzą ci, którzy woleliby, żeby nie wołano ich po imieniu."

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Nie pij, kiedy pływasz."

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy naprawdę awansował z klauna na barmana."

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Kurde balans, te drinki są świetne."

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = "Dobre drinki przy dobrej muzyce."

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "Ten bar wcale nie leży w otwartym kosmosie."

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = "Nasze szoty to równia pochyła do pijaństwa!"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = "Porzuć okładanie ludzi skrzynką i wypij leniwe piwko!"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = "Honk."

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = "Dobre miejsce, żeby wpaść na drinka po długiej nocy walki z przestępczością."

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = "Bardzo kontrowersyjny bar znany z ogromnego wyboru ciągle zmieniających się drinków."

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = "Lokal odwiedzany głównie przez kosmicznych sędziów. Wysadzają go znacznie rzadziej niż rozprawy sądowe."

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = "Coś w tym szyldzie napawa cię rozpaczą."

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = "Prawnie zobowiązany do przypominania, żeby przed wypiciem sprawdzić, czy w drinku nie ma kwasu."

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = "Od 5 lat niezagrożony rekordzista w kategorii „Najbardziej Śmiercionośne Bójki w Barze”."

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = "Niedawno odzyskał licencję po długim zamknięciu."

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = "Słynny w całym układzie ze swoich kompletnie nietwórczych połączeń drinków."

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = "Pod nowym zarządem. Vlad zawsze trochę za chętnie sięgał po tę strzelbę."

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = "Ten lokal nie serwuje mieszanych drinków."

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = "Dobra, kolego. Chyba masz już EI NATH. Czas na taksówkę."

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = "Gustowny, nikogo nieobrażający szyld baru tiki."

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = "Jakoś tak wciąga cię na całe godziny."

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon = "maidcafe"
	desc = "Witaj z powrotem, panie!"

/datum/barsign/the_lightbulb
	name = "The Lightbulb"
	icon = "the_lightbulb"
	desc = "Kawiarnia popularna wśród ciem i ćmoków. Kiedyś zamknięta na tydzień, bo barmanka zabezpieczyła zapasowe mundurki kulkami na mole."

/datum/barsign/goose
	name = "The Loose Goose"
	icon = "goose"
	desc = "Pij, aż zwymiotujesz i/lub złamiesz prawa rzeczywistości!"

/datum/barsign/hiddensigns
	hidden = TRUE


//Hidden signs list below this point



/datum/barsign/hiddensigns/empbarsign
	name = null
	icon = "empbarsign"
	desc = "Coś poszło bardzo nie tak."
	rename_area = FALSE

/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat"
	icon = "syndibarsign"
	desc = "Syndykat albo śmierć."

/datum/barsign/hiddensigns/signoff
	name = null
	icon = "empty"
	desc = "Ten szyld chyba nie jest włączony."
	rename_area = FALSE
