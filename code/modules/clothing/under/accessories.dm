/obj/item/clothing/accessory //Ties moved to neck slot items, but as there are still things like medals and armbands, this accessory system is being kept as-is
	name = "Dodatek"
	desc = "Coś poszło nie tak!"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "plasma"
	item_state = ""	//no inhands
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	var/above_suit = FALSE
	var/minimize_when_attached = TRUE // TRUE if shown as a small icon in corner, FALSE if overlayed
	var/datum/component/storage/detached_pockets
	var/attachment_slot = CHEST

/obj/item/clothing/accessory/Destroy()
	set_detached_pockets(null)
	return ..()

/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/U, mob/user)
	if(!attachment_slot || (U && U.body_parts_covered & attachment_slot))
		return TRUE
	if(user)
		to_chat(user, "<span class='warning'>Wygląda na to, że nie ma gdzie przypiąć [src]...</span>")

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/U, user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		if(SEND_SIGNAL(U, COMSIG_CONTAINS_STORAGE))
			return FALSE
		U.TakeComponent(storage)
		set_detached_pockets(storage)
	U.attached_accessory = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	if(minimize_when_attached)
		transform *= 0.5	//halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= 8
	U.add_overlay(src)

	if (islist(U.armor) || isnull(U.armor)) 										// This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)

	if(isliving(user))
		on_uniform_equip(U, user)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/U, user)
	if(detached_pockets && detached_pockets.parent == U)
		TakeComponent(detached_pockets)

	U.armor = U.armor.detachArmor(armor)

	if(isliving(user))
		on_uniform_dropped(U, user)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += 8
	layer = initial(layer)
	plane = initial(plane)
	U.cut_overlays()
	U.attached_accessory = null
	U.accessory_overlay = null

/obj/item/clothing/accessory/proc/set_detached_pockets(new_pocket)
	if(detached_pockets)
		UnregisterSignal(detached_pockets, COMSIG_PARENT_QDELETING)
	detached_pockets = new_pocket
	if(detached_pockets)
		RegisterSignal(detached_pockets, COMSIG_PARENT_QDELETING, PROC_REF(handle_pockets_del))

/obj/item/clothing/accessory/proc/handle_pockets_del(datum/source)
	SIGNAL_HANDLER
	set_detached_pockets(null)

/obj/item/clothing/accessory/proc/on_uniform_equip(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/proc/on_uniform_dropped(obj/item/clothing/under/U, user)
	return

/obj/item/clothing/accessory/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		if(initial(above_suit))
			above_suit = !above_suit
			to_chat(user, "[src] będzie noszony [above_suit ? "na" : "pod"] okryciem wierzchnim.")

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] można przypiąć do munduru. Po przypięciu Alt-klik, by zdjąć.</span>"
	if(initial(above_suit))
		. += "<span class='notice'>[src] można nosić na lub pod okryciem wierzchnim. Alt-klik, by przełączyć.</span>"

/obj/item/clothing/accessory/waistcoat
	name = "kamizelka garniturowa"
	desc = "Do eleganckiej, morderczej zabawy."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/maidapron
	name = "fartuszek pokojówki"
	desc = "Najlepsza część stroju pokojówki."
	icon_state = "maidapron"
	item_state = "maidapron"
	minimize_when_attached = FALSE
	attachment_slot = null

//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "brązowy medal"
	desc = "Brązowy medal."
	icon_state = "bronze"
	materials = list(/datum/material/iron=1000)
	resistance_flags = FIRE_PROOF
	var/medaltype = "medal" //Sprite used for medalbox
	var/commended = FALSE

//Pinning medals on people
/obj/item/clothing/accessory/medal/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && !user.combat_mode)

		if(M.wear_suit)
			if((M.wear_suit.flags_inv & HIDEJUMPSUIT)) //Check if the jumpsuit is covered
				to_chat(user, "<span class='warning'>Medale można przypinać tylko do kombinezonów.</span>")
				return

		if(M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			var/delay = 20
			if(user == M)
				delay = 0
			else
				user.visible_message("[user] próbuje przypiąć [src] do piersi [M].", \
									 "<span class='notice'>Próbujesz przypiąć [src] do piersi [M].</span>")
			var/input
			if(!commended && user != M)
				input = stripped_input(user,"Podaj uzasadnienie tego wyróżnienia; zostanie zarejestrowane przez Nanotrasen.", ,"", 140)
			if(do_after(user, delay, target = M))
				if(U.attach_accessory(src, user, 0)) //Attach it, do not notify the user of the attachment
					if(user == M)
						to_chat(user, "<span class='notice'>Przypinasz [src] do [U].</span>")
					else
						user.visible_message("[user] przypina [src] do piersi [M].", \
											 "<span class='notice'>Przypinasz [src] do piersi [M].</span>")
						if(input)
							SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[user.real_name]", "commendee" = "[M.real_name]", "medal" = "[src]", "reason" = input))
							GLOB.commendations += "[user.real_name] przyznaje <b>[M.real_name]</b> odznaczenie <span class='medaltext'>[name]</span>! \n- [input]"
							commended = TRUE
							desc += "<br>Napis głosi: [input] - [user.real_name]"
							log_game("<b>[key_name(M)]</b> was given the following commendation by <b>[key_name(user)]</b>: [input]")
							message_admins("<b>[key_name_admin(M)]</b> otrzymuje od <b>[key_name_admin(user)]</b> następujące odznaczenie: [input]")

		else
			to_chat(user, "<span class='warning'>Medale można przypinać tylko do kombinezonów!</span>")
	else
		..()

/obj/item/clothing/accessory/medal/conduct
	name = "medal za wzorową służbę"
	desc = "Brązowy medal przyznawany za wzorową służbę. Choć to wielki zaszczyt, jest to najbardziej podstawowe odznaczenie przyznawane przez Nanotrasen. Często wręcza go kapitan członkowi swojej załogi."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "medal Brązowego Serca"
	desc = "Brązowy medal w kształcie serca przyznawany za poświęcenie. Często wręcza się go pośmiertnie albo za ciężkie rany odniesione na służbie."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/ribbon
	name = "wstęga"
	desc = "Wstęga."
	icon_state = "cargo"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "wyróżnienie „technik zaopatrzenia zmiany”"
	desc = "Wyróżnienie przyznawane tylko tym technikom zaopatrzenia, którzy wykazali się oddaniem obowiązkom zgodnym z najwyższymi tradycjami Cargonii."

/obj/item/clothing/accessory/medal/silver
	name = "srebrny medal"
	desc = "Srebrny medal."
	icon_state = "silver"
	medaltype = "medal-silver"
	materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal za męstwo"
	desc = "Srebrny medal przyznawany za czyny wyjątkowego męstwa."

/obj/item/clothing/accessory/medal/silver/security
	name = "wyróżnienie za krzepką ochronę"
	desc = "Wyróżnienie za wybitną walkę i poświęcenie w obronie interesów handlowych Nanotrasen. Często przyznawane funkcjonariuszom ochrony."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "nagroda starszego oficera za wybitne osiągnięcia w dziedzinie doskonałości"
	desc = "Słownik Nanotrasen definiuje doskonałość jako „cechę lub stan bycia doskonałym”. Nagrodę otrzymują ci nieliczni członkowie załogi, którzy pasują do tej definicji."

/obj/item/clothing/accessory/medal/gold
	name = "złoty medal"
	desc = "Prestiżowy złoty medal."
	icon_state = "gold"
	medaltype = "medal-gold"
	materials = list(/datum/material/gold=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal kapitański"
	desc = "Złoty medal przyznawany wyłącznie awansowanym do stopnia kapitana. Symbolizuje skodyfikowane obowiązki kapitana wobec Nanotrasen i jego niepodważalną władzę nad załogą."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal za wyjątkowe bohaterstwo"
	desc = "Niezwykle rzadki złoty medal przyznawany wyłącznie przez Centralę. Otrzymanie go to najwyższy zaszczyt, dlatego istnieje ich bardzo niewiele. Prawie nigdy nie dostaje go nikt poza dowódcami."

/obj/item/clothing/accessory/medal/plasma
	name = "plazmowy medal"
	desc = "Ekscentryczny medal wykonany z plazmy."
	icon_state = "plasma"
	medaltype = "medal-plasma"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = -10, "acid" = 0, "stamina" = 0, "bleed" = 0) //It's made of plasma. Of course it's flammable.
	materials = list(/datum/material/plasma=1000)

/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
		visible_message("<span class='danger'> [src] staje w płomieniach!</span>","<span class='userdanger'>Twój [src] staje w płomieniach!</span>")
		qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nagroda Nobla w dziedzinie nauki"
	desc = "Plazmowy medal symbolizujący znaczący wkład w dziedzinę nauki lub inżynierii."

/obj/item/clothing/accessory/medal/med_medal
	name = "medal za wzorową pracę"
	desc = "Medal przyznawany tym, którzy wykazali się wzorową postawą, wynikami i inicjatywą w dziale medycznym."
	icon_state = "med_medal"
	above_suit = TRUE

/obj/item/clothing/accessory/medal/med_medal2
	name = "medal za doskonałość w medycynie"
	desc = "Medal przyznawany tym, którzy w dziale medycznym wykazali się legendarnymi wynikami, kompetencją i inicjatywą przekraczającą wszelkie oczekiwania."
	icon_state = "med_medal2"
	above_suit = TRUE

////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "czerwona opaska"
	desc = "Elegancka czerwona opaska na ramię!"
	icon_state = "redband"
	attachment_slot = null

/obj/item/clothing/accessory/armband/blue
	name = "niebieska opaska"
	desc = "Elegancka niebieska opaska na ramię!"
	color = list(0,0,1, 0,1,0, 1,0,0)

/obj/item/clothing/accessory/armband/green
	name = "zielona opaska"
	desc = "Elegancka zielona opaska na ramię!"
	color = list(0,1,0, 1,0,0, 0,0,1)

/obj/item/clothing/accessory/armband/deputy
	name = "opaska zastępcy ochrony"
	desc = "Opaska noszona przez personel upoważniony do działania jako zastępca ochrony stacji."

/obj/item/clothing/accessory/armband/cargo
	name = "opaska strażnika zaopatrzenia"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest brązowa."
	icon_state = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "opaska strażnika inżynierii"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest pomarańczowa z odblaskowym paskiem!"
	icon_state = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "opaska strażnika nauki"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest fioletowa."
	icon_state = "rndband"

/obj/item/clothing/accessory/armband/hydro
	name = "opaska strażnika hydroponiki"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest zielono-niebieska."
	icon_state = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "opaska strażnika medycyny"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest biała."
	icon_state = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "opaska strażnika medycyny"
	desc = "Opaska noszona przez siły ochrony stacji, by pokazać, do którego działu są przydzielone. Ta jest biało-niebieska."
	icon_state = "medblueband"

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "odznaka adwokata"
	desc = "Napełnia cię przekonaniem o SPRAWIEDLIWOŚCI. Prawnicy lubią pokazywać ją każdemu, kogo spotkają."
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("Zeznanie przeczy dowodom!", forced = "attorney's badge")
	user.visible_message("[user] pokazuje swoją odznakę adwokata.", "<span class='notice'>Pokazujesz swoją odznakę adwokata.</span>")

/obj/item/clothing/accessory/lawyers_badge/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L)
		L.bubble_icon = initial(L.bubble_icon)

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "osłonka kieszeni"
	desc = "Chroni ubranie przed plamami z atramentu, ale wyglądasz w niej jak kujon."
	icon_state = "pocketprotector"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/pocketprotector

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "kościany talizman"
	desc = "Talizman łowcy. Niektórzy mówią, że starzy bogowie uśmiechają się do tych, którzy go noszą."
	icon_state = "talisman"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25, "stamina" = 10, "bleed" = 10)
	attachment_slot = null

/obj/item/clothing/accessory/skullcodpiece
	name = "czaszkowy ochraniacz krocza"
	desc = "Ozdoba w kształcie czaszki, która ma chronić najważniejsze rzeczy w życiu."
	icon_state = "skull"
	above_suit = TRUE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 20, "bio" = 20, "rad" = 5, "fire" = 0, "acid" = 25, "stamina" = 10, "bleed" = 10)
	attachment_slot = GROIN

/obj/item/clothing/accessory/holster
	name = "kabura naramienna"
	desc = "Kabura do noszenia pistoletu i amunicji. OSTRZEŻENIE: tylko dla twardzieli."
	icon_state = "holster"
	item_state = "holster"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/holster

/obj/item/clothing/accessory/holster/detective
	name = "kabura naramienna detektywa"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/holster/detective

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	new /obj/item/gun/ballistic/revolver/detective(src)
	new /obj/item/ammo_box/c38/match/bouncy(src)
	new /obj/item/ammo_box/c38/match/bouncy(src)

//Poppy Pin
/obj/item/clothing/accessory/poppy_pin
	name = "przypinka z makiem"
	desc = "Przypinka z maku, noszona dla upamiętnienia poległych na wojnie."
	icon_state = "poppy_pin"

/obj/item/clothing/accessory/poppy_pin/on_uniform_equip(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L && L.mind)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "poppy_pin", /datum/mood_event/poppy_pin)

/obj/item/clothing/accessory/poppy_pin/on_uniform_dropped(obj/item/clothing/under/U, user)
	var/mob/living/L = user
	if(L && L.mind)
		SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "poppy_pin")
