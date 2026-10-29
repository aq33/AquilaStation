///////Munitions Department Items///////

///////DEPARTMENT BUDGET CARD///////

/obj/item/card/id/departmental_budget/mun
	department_ID = ACCOUNT_MUN
	department_name = ACCOUNT_MUN_NAME
	icon_state = "budget_mun"

///////DEPARTMENT DOOR REMOTE//////

/obj/item/door_remote/master_at_arms
	name = "pilot drzwi działu amunicji"
	icon_state = "gangtool-red"
	region_access = 8

///////ENCRYPTION KEYS///////

/obj/item/encryptionkey/atc
	name = "klucz szyfrujący radia Kontroli Lotów"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_COMMAND = 1)
	independent = TRUE

/obj/item/encryptionkey/pilot
	name = "klucz szyfrujący radia pilotów myśliwców"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_ATC = 1, RADIO_CHANNEL_MUNITIONS = 1)
	independent = TRUE

/obj/item/encryptionkey/heads/master_at_arms
	name = "klucz szyfrujący radia Mistrza Broni"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_ATC = 1)
	independent = TRUE

/obj/item/encryptionkey/heads/master_at_arms/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)
	independent = FALSE

/obj/item/encryptionkey/munitions_tech
	name = "klucz szyfrujący działu amunicji"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_cypherkey"
	channels = list(RADIO_CHANNEL_MUNITIONS = 1, RADIO_CHANNEL_SUPPLY = 1)

///////RADIO HEADSETS//////

/obj/item/radio/headset/munitions
	name = "słuchawki radiowe działu amunicji"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "Podstawowy model wszystkich słuchawek działu amunicji, z ochroną słuchu w zestawie!"
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech
	bang_protect = 1

/obj/item/radio/headset/munitions/atc
	name = "słuchawki radiowe Kontrolera Lotów"
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	desc = "Słuchawki z dostępem do niebieskiego kanału Nanotrasen przez specjalne łącze satelitarne DRADIS, dzięki czemu piloci myśliwców mogą się porozumiewać z dowolnego miejsca w przestrzeni Nanotrasen. Użyj :q, by mówić na częstotliwości Kontroli Lotów. Użyj :w, by mówić na częstotliwości działu. Użyj :c, by mówić na częstotliwości dowództwa."
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/atc

/obj/item/radio/headset/munitions/pilot
	name = "słuchawki radiowe pilota"
	desc = "Słuchawki z dostępem do niebieskiego kanału Nanotrasen przez specjalne łącze satelitarne DRADIS, dzięki czemu piloci myśliwców mogą się porozumiewać z dowolnego miejsca w przestrzeni Nanotrasen. Użyj :q, by mówić na częstotliwości Kontroli Lotów. Użyj :w, by mówić na częstotliwości działu, gdy jesteś na okręcie."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/pilot

/obj/item/radio/headset/heads/master_at_arms
	name = "\proper słuchawki Mistrza Broni"
	desc = "Użyj :w, by mówić na częstotliwości działu. Użyj :u, by mówić na częstotliwości zaopatrzenia. Użyj :c, by mówić na częstotliwości dowództwa. Użyj :q, by mówić na częstotliwości Kontroli Lotów."
	icon = 'nsv13/icons/obj/custom_radio.dmi'
	icon_state = "mun_headset_alt"
	keyslot = new /obj/item/encryptionkey/heads/master_at_arms
	bang_protect = 1

/obj/item/radio/headset/munitions/munitions_tech
	name = "słuchawki radiowe Technika Amunicyjnego"
	desc = "Użyj :w, by mówić na częstotliwości działu. Użyj :u, by mówić na częstotliwości zaopatrzenia."
	icon_state = "mun_headset"
	keyslot = new /obj/item/encryptionkey/munitions_tech

/obj/item/radio/headset/munitions/munitions_tech/alt
	name = "słuchawki nauszne Technika Amunicyjnego"
	desc = "Użyj :w, by mówić na częstotliwości działu. Użyj :u, by mówić na częstotliwości zaopatrzenia."
	icon_state = "mun_headset_alt"

/obj/item/radio/headset/munitions/munitions_security_alt
	name = "słuchawki nauszne ochrony działu amunicji"
	desc = "Słuchawki twojego lokalnego ochroniarza z działu amunicji, ale z ochroną słuchu! Teraz nie ogłuchniesz!"
	icon_state = "munsec_headset_alt"
	keyslot2 = new /obj/item/encryptionkey/headset_sec
	bang_protect = 1

/obj/item/radio/headset/munitions/munitions_security
	name = "słuchawki radiowe ochrony działu amunicji"
	desc = "Słuchawki twojego lokalnego ochroniarza z działu amunicji."
	icon_state = "munsec_headset"
	keyslot2 = new /obj/item/encryptionkey/headset_sec

////////BACKPACKS////////

/obj/item/storage/backpack/duffelbag/munitions
	name = "torba podróżna działu amunicji"
	desc = "Duża torba podróżna na dodatkowe zapasy działu amunicji."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "duffel-mun"
	item_state = "duffel-mun"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'

/obj/item/storage/backpack/munitions
	name = "plecak działu amunicji"
	desc = "Wytrzymały, olejoodporny plecak do pracy w otoczeniu pełnym uzbrojenia."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "munitionspack"
	item_state = "munitionspack"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'

/obj/item/storage/backpack/satchel/munitions
	name = "torba na ramię działu amunicji"
	desc = "Wytrzymała torba na ramię z dodatkowymi kieszeniami."
	icon = 'nsv13/icons/obj/storage.dmi'
	icon_state = "satchel-mun"
	item_state = "satchel-mun"
	lefthand_file = 'nsv13/icons/mob/inhands/backpack_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/backpack_righthand.dmi'


//armband for midshipmen or security

/obj/item/clothing/accessory/armband/munitions
	name = "opaska ochrony działu amunicji"
	desc = "Opaska noszona przez ochronę, by pokazać, do którego działu jest przydzielona. Ta jest czarno-pomarańczowa."
	icon_state = "muniband"


///////ATC STICKS///////
/obj/item/flashlight/atc_wavy_sticks //I dont know what theyre actually called :)
	name = "pałki sygnalizacyjne dla statków"
	desc = "Duży zestaw fluorescencyjnych pałek do kierowania statkami w hangarze."
	icon = 'nsv13/icons/objects/lighting.dmi'
	icon_state = "wavystick"
	item_state = "glowstick"
	w_class = WEIGHT_CLASS_SMALL
	light_range = 6
	color = LIGHT_COLOR_GREEN
	color = COLOR_RED
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	actions_types = list(/datum/action/item_action/pick_color, /datum/action/item_action/toggle_light)
	var/turf/start_turf
	var/turf/end_turf

/datum/action/item_action/change_color
	name = "Przełącz światło"

/obj/item/flashlight/atc_wavy_sticks/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		if(!usr.stat)
			if(light_color == LIGHT_COLOR_GREEN)
				light_color = LIGHT_COLOR_RED
				color = COLOR_RED
			else
				light_color = LIGHT_COLOR_GREEN
				color = COLOR_GREEN
	else
		. = ..()

/obj/effect/temp_visual/dir_setting/wavystick
	icon = 'icons/mob/aibots.dmi'
	icon_state = "path_indicator"
	color = "#ccffcc" //Light green
	duration = 5 SECONDS

/obj/item/flashlight/atc_wavy_sticks/afterattack(atom/target, mob/user, proximity)
	if(!start_turf)
		start_turf = get_turf(target)
		to_chat(user, "<span class='warning'>Celujesz [src] w [target]. Wskaż inne pole, by utworzyć ścieżkę, albo alt-kliknij [src], by anulować.</span>")
		new /obj/effect/temp_visual/impact_effect/green_laser(start_turf)
		return
	if(!end_turf)
		var/testDir = get_dir(start_turf,target)
		if((testDir in GLOB.cardinals)) //Because otherwise the icon states glitch the hell out and look disgusting
			end_turf = get_turf(target)
			addtimer(VARSET_CALLBACK(src, start_turf, null), 5 SECONDS) //Clear the path after a while
			addtimer(VARSET_CALLBACK(src, end_turf, null), 5 SECONDS) //Clear the path after a while
			visible_message("<span class='warning'>[user] wymachuje [src] kontrolowanym ruchem.</span>")
			var/turf/last_turf = start_turf
			for(var/turf/T in getline(start_turf,end_turf))
				var/pdir = SOUTH
				if(T == start_turf)
					pdir = testDir
				else
					pdir  = get_dir(last_turf, T)
				new /obj/effect/temp_visual/dir_setting/wavystick(T, pdir)
				last_turf = T
			return
		else
			to_chat(user, "<span class='warning'>Możesz wskazywać tylko w liniach prostych, nie po przekątnej.</span>")
			return
	. = ..()

/obj/item/flashlight/atc_wavy_sticks/AltClick(mob/user)
	. = ..()
	if(start_turf)
		start_turf = null
		to_chat(user, "<span class='warning'>Wyczyszczono wybór celu</span>")
		add_fingerprint(user)
