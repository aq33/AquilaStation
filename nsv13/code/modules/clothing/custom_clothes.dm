/obj/item/clothing/under/ship
	name = "zastępczy"
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/uniform.dmi'
	icon_state = "nothing" //References uniforms.dmi
	worn_icon_state = "nothing" //Icon state for its worn icon, references uniform.dmi
	item_state = "bl_suit"
	can_adjust = FALSE //Can you roll its sleeves down? Default to no to avoid missing icons

/obj/item/clothing/under/ship/officer
	name = "mundur oficera"
	desc = "Dość wygodne ubranie z materiałów pochłaniających pot. Zapewnia chłód nawet wtedy, gdy godzinami siedzisz na stanowisku."
	icon_state = "officer"
	worn_icon_state = "officer"
	item_state = "bl_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = TRUE

/obj/item/clothing/under/ship/peacekeeper
	name = "mundur kosmicznego gliny"
	desc = "Elegancki zestaw koszuli i spodni z naszytymi odznakami: „Chronić i służyć”."
	icon_state = "peacekeeper"
	worn_icon_state = "peacekeeper"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 10)
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = TRUE

/obj/item/clothing/under/ship/engineer
	name = "kombinezon inżyniera"
	desc = "Gruby kombinezon z materiałów izolacyjnych, noszony przez korpus inżynieryjny NT. Rzadko widuje się taki, który nie jest pokryty warstwami smaru silnikowego."
	icon_state = "engine"
	worn_icon_state = "engine"
	item_state = "bl_suit"
	can_adjust = TRUE

/obj/item/clothing/under/ship/medical
	name = "kombinezon lekarza"
	desc = "Wytrzymały kombinezon z materiałów hydrofobowych, po których krew powinna spływać."
	icon_state = "medical"
	worn_icon_state = "medical"
	item_state = "bl_suit"

/obj/item/clothing/under/ship/assistant
	name = "użytkowy kombinezon roboczy"
	desc = "Nieco sfatygowany, ale niezawodny kombinezon z wyściółką i kilkoma małymi kieszeniami, zaprojektowany z myślą o oszczędności."
	icon_state = "assistant"
	worn_icon_state = "assistant"
	item_state = "bl_suit"

/obj/item/clothing/under/ship/kiryujumpsuit
	name = "kombinezon Kiryu"
	desc = "Kombinezon dla detektywów, którzy chcą wyglądać bardziej mafijnie. Zapach cygar jest jednak wyraźny."
	icon_state = "kiryujumpsuit"
	worn_icon_state = "kiryujumpsuit"
	item_state = "bl_suit"
	can_adjust = TRUE

/obj/item/clothing/suit/ship
	name = "zastępczy"
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/suit.dmi'

/obj/item/clothing/suit/ship/assistant_jacket
	name = "kurtka robocza"
	icon_state = "assistant_jacket"
	worn_icon_state = "assistant_jacket"
	desc = "Stylowa, ale ciężka kurtka, chroniąca noszącego przed typowymi zagrożeniami podczas służby na statku."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 10, "fire" = 10, "acid" = 10, "bleed" = 5)

/obj/item/clothing/suit/ship/peacekeeper
	name = "kamizelka sił pokojowych"
	icon_state = "peacekeeper_vest"
	item_state = "peacekeeper_vest"
	desc = "Kamizelka z nanowłókna, zatrzymująca większość pocisków z broni ręcznej i broń improwizowaną. Nosi logo sił pokojowych Gwiazdy Północnej"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 15, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90, "stamina" = 30, "bleed" = 5)

/obj/item/clothing/suit/ship/peacekeeper/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/ship/peacekeeper/jacket
	name = "kurtka sił pokojowych"
	icon_state = "peacekeeper_jacket"
	item_state = "peacekeeper_jacket"
	desc = "Wygodna szara skórzana kurtka. Mimo ciężkiego opancerzenia nosi się ją niezwykle wygodnie."
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list("melee" = 30, "bullet" = 60, "laser" = 15, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90, "stamina" = 40, "bleed" = 50)

/obj/item/clothing/suit/ship/peacekeeper/detective
	name = "kurtka DET"
	desc = "Elegancka niebieska kurtka, która oznacza noszącego jako eksperta kryminalistyki."
	icon_state = "det"
	item_state = "det"
	armor = list("melee" = 30, "bullet" = 40, "laser" = 10, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 50, "bleed" = 50)
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/ship/peacekeeper/marine
	name = "kamizelka piechoty morskiej NT-4"
	icon_state = "marine"
	item_state = "marine"
	desc = "Masywna kamizelka noszona przez kolonialne siły pokojowe. Tkanina z siatki nanowęglowej na pewno zatrzyma prawie każdy pocisk."
	armor = list("melee" = 30, "bullet" = 45, "laser" = 10, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 60, "bleed" = 50)

/obj/item/clothing/suit/ship/officer
	name = "kurtka galowa oficera"
	desc = "Dość ciężka kurtka przyzwoitej jakości. Nie jest najwygodniejszą rzeczą, jaką możesz założyć, ale od dawna należy do munduru oficera."
	icon_state = "officer_jacket"

/obj/item/clothing/suit/ship/engineer
	name = "oporządzenie inżynieryjne"
	desc = "Prosta kamizelka z kieszeniami na kilka małych narzędzi."
	icon_state = "engineer_vest"
	allowed = list(/obj/item/wrench, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/screwdriver, /obj/item/extinguisher, /obj/item/crowbar, /obj/item/analyzer, /obj/item/multitool, /obj/item/modular_computer/tablet)

/obj/item/clothing/suit/ship/kiryujacket
	name = "kurtka Kiryu"
	desc = "Kurtka dla detektywa, który chce wyglądać bardziej mafijnie. Już patrząc na nią, czujesz cygara, które w niej wypalono."
	icon_state = "kiryujacket"
	item_state = "kiryujacket"

/obj/item/clothing/suit/ship/engineer
	name = "oporządzenie inżynieryjne"
	desc = "Prosta kamizelka z kieszeniami na kilka małych narzędzi."
	icon_state = "engineer_vest"
	allowed = list(/obj/item/wrench, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/screwdriver, /obj/item/extinguisher, /obj/item/crowbar, /obj/item/analyzer, /obj/item/multitool, /obj/item/modular_computer/tablet)

/obj/item/clothing/head/ship
	name = "zastępczy"
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "beret"
	worn_icon_state = null

/obj/item/clothing/head/soft/assistant_soft
	name = "czapka robocza"
	desc = "Szorstka i niewygodna czapka noszona przez niedomyte masy marynarki Nanotrasen."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "assistantsoft"
	worn_icon_state = "assistant"

/obj/item/clothing/head/ship/marine
	name = "hełm piechoty morskiej NT-4"
	desc = "Duży hełm z materiałów odpornych na uszkodzenia."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "marine"
	worn_icon_state = null
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10,"energy" = 5, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "bleed" = 50)

/obj/item/clothing/head/beret/ship
	name = "beret"
	desc = "Beret, ulubione nakrycie głowy mima."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "beret"
	worn_icon_state = null

/obj/item/clothing/head/beret/ship/captain
	name = "beret kapitana"
	desc = "Niezwykle wygodny bawełniany beret. Zdobi go insygnium Nanotrasen i noszą go tylko ci, którzy się wykazali."
	icon_state = "captain"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/xo
	name = "beret Starszego Oficera"
	desc = "Bardzo wygodny beret noszony przez zastępcę dowódcy okrętu. Jeśli go widzisz, chyba wypada zasalutować."
	icon_state = "xo"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/flight_leader
	name = "beret dowódcy klucza"
	desc = "Solidny beret noszony przez dowódców grup lotniczych. Ten olśniewający beret ma sprawić, że dowódcy kluczy pewnie czują się w swojej roli."
	icon_state = "xo"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/engineer
	name = "beret inżyniera"
	desc = "Po części modny dodatek, po części kask. Ten beret jest specjalnie wzmocniony, by chronić noszącego przed wypadkami przy pracy."
	icon_state = "engineer"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 5, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/radiation //CREDIT TO GOON FOR THE SPRITE!
	name = "kaptur ochronny"
	desc = "Kaptur wyłożony ołowiem, który gwarantuje ochronę przed szkodliwym promieniowaniem jądrowym. Polecany przez 9 na 10 inżynierów jądrowych."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/head.dmi'

/obj/item/clothing/suit/radiation //CREDIT TO GOON FOR THE SPRITE!
	name = "kombinezon ochronny"
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/suit.dmi'

	//Hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/pilot
	name = "hełm pilota myśliwca"
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-pilot"
	item_state = "hardsuit0-pilot"
	hardsuit_type = "pilot"
	desc = "Lekki hełm kosmiczny chroniący pilotów myśliwców w walce."
	armor = list("melee" = 20, "bullet" = 12, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 75, "bleed" = 70)

/obj/item/clothing/suit/space/hardsuit/pilot
	name = "kombinezon lotniczy pilota myśliwca"
	desc = "Szczelny kombinezon lotniczy noszony przez pilotów myśliwców marynarki Nanotrasen. Jest specjalnie wzmocniony, by chronić noszącego przed większością zagrożeń."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "pilot"
	item_state = "pilot"
	worn_icon_state = "pilot"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/pilot
	armor = list("melee" = 20, "bullet" = 12, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 90, "acid" = 75, "bleed" = 70)

/obj/item/clothing/under/ship/pilot
	name = "bojowy kombinezon pilota"
	desc = "Lekki kombinezon z punktami mocowania uprzęży i karabińczykami, przeznaczony do noszenia z kombinezonem lotniczym pilota."
	icon_state = "pilot"
	worn_icon_state = "pilot"
	item_state = "bl_suit"

/obj/item/clothing/under/ship/pilot/transport
	name = "transportowy kombinezon pilota"
	desc = "Wygodny, lekki kombinezon na niebojowe stanowiska."
	icon_state = "transport_pilot"
	worn_icon_state = "transport_pilot"
	item_state = "transport_pilot"

/obj/item/clothing/head/beret/ship/pilot
	name = "beret pilota"
	desc = "Po części modny dodatek, po części kask. Ten beret jest specjalnie wzmocniony, by chronić noszącego przed wypadkami przy pracy."
	icon_state = "pilot"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 5, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/ship/rising_sun
	name = "opaska wschodzącego słońca"
	desc = "ŚMIERĆ PRZED HAŃBĄ! BANZAAAAAI!"
	icon_state = "sun"
	item_state = "sun"
	dynamic_hair_suffix = ""

/obj/item/clothing/accessory/bomber_jacket_accessory
	name = "cienka kurtka bomberka"
	desc = "Tania, cienka jak opłatek replika bomberki. Zmieści się na większości ubrań."
	icon = 'nsv13/icons/obj/clothing/accessories.dmi'
	icon_state = "bomberthin"
	worn_icon_state = "bomberthin"
	item_state = "bomberthin"
	above_suit = TRUE

/obj/item/clothing/head/helmet/transport_pilot
	name = "hełm pilota transportowego"
	desc = "Duży hełm chroniący głowę i uszy."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "transport_pilot"
	worn_icon_state = null
	flags_inv = HIDEEARS|HIDEHAIR
	bang_protect = 1
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10,"energy" = 5, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "bleed" = 50)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/peacekeeper //Ironic type path. We're inheriting the "dual mode" behaviour from the syndie hardsuit.
	name = "hełm SG-1 Mjolnir"
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit1-peacekeeper_space"
	item_state = "peacekeeper_space"
	hardsuit_type = "peacekeeper_space"
	desc = "Hełm hardsuitu z wysoce eksperymentalnymi blokadami magnetycznymi, które tworzą wokół użytkownika szczelne uszczelnienie, pozwalając na pracę w próżni. Jest w trybie EVA."
	alt_desc = "Hełm skafandra wyposażony w wysoce eksperymentalne blokady magnetyczne, które tworzą próżniowe uszczelnienie wokół użytkownika, pozwalając używać go w próżni. Jest obecnie w trybie IVA."
	armor = list("melee" = 40, "bullet" = 50, "laser" = 15,"energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "stamina" = 50, "bleed" = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT //we want to see the mask

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper
	name = "pancerz SG-1 Mjolnir"
	desc = "Niezwykle masywny pancerz z wysoce eksperymentalnymi blokadami magnetycznymi, które tworzą wokół użytkownika szczelne uszczelnienie, pozwalając na pracę w próżni. Jest w trybie EVA."
	alt_desc = "Niezwykle masywny pancerz wyposażony w wysoce eksperymentalne blokady magnetyczne, które tworzą próżniowe uszczelnienie wokół użytkownika, pozwalając używać go w próżni. Jest obecnie w trybie IVA."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "hardsuit1-peacekeeper_space"
	item_state = "peacekeeper_space"
	hardsuit_type = "peacekeeper_space"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/peacekeeper
	armor = list("melee" = 40, "bullet" = 50, "laser" = 15, "energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "stamina" = 50, "bleed" = 70)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/stomp_cooldown_time = 0.5 SECONDS
	var/current_cooldown = 0
	w_class = WEIGHT_CLASS_BULKY
	supports_variations = NO_VARIATION
	item_flags = NONE
	cm_slowdown = 0.2 //up for debate

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper/artifact_immunity()
    return

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(current_cooldown <= world.time) //Deliberately not using a timer here as that would spam create tonnes of timer objects, hogging memory.
		current_cooldown = world.time + stomp_cooldown_time
		var/list/sounds = list('nsv13/sound/effects/footstep/heavy1.ogg','nsv13/sound/effects/footstep/heavy2.ogg','nsv13/sound/effects/footstep/heavy3.ogg')
		playsound(src, pick(sounds), 40, 1)

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_OCLOTHING)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		return
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	listeningTo = user

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)

/obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper/Destroy()
	listeningTo = null
	return ..()

/obj/machinery/suit_storage_unit/peacekeeper
	suit_type = /obj/item/clothing/suit/space/hardsuit/syndi/peacekeeper
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/internals/oxygen

/obj/item/clothing/suit/space/syndicate/odst
	name = "skafander desantowca"
	desc = "Masywny i dość prymitywny skafander z przykręconymi płytami pancerza. Mimo prymitywnej, prowizorycznej konstrukcji noszą je oddziały szturmowe Syndykatu podczas abordaży w walce wręcz."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "syndicate-space"
	item_state = "syndicate-space"
	worn_icon_state = "syndicate-space"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	slowdown = 1
	resistance_flags = ACID_PROOF
	strip_delay = 12

/obj/item/clothing/head/helmet/space/syndicate/odst
	name = "hełm desantowca"
	desc = "Złowieszczy hełm kosmiczny pokryty krwistoczerwonymi naklejkami i motywami. Noszących takie hełmy nie wolno lekceważyć."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "syndicate-space"
	item_state = "syndicate-space"
	worn_icon_state = "syndicate-space"

//Subytype which spawns with a camera for boarders
/obj/item/clothing/head/helmet/space/syndicate/odst/camera/Initialize()
	. = ..()
	install_camera(faction = "Syndicate")

/obj/item/storage/belt/utility/syndicate
	name = "pas na narzędzia Syndykatu"
	desc = "Duży czarny pas ułatwiający noszenie narzędzi."
	icon_state = "assaultbelt"
	item_state = "security"

/obj/item/storage/belt/utility/syndicate/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/belt/utility/syndicate/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool(src)

/obj/item/clothing/shoes/ship
	name = "zastępczy"
	icon = 'nsv13/icons/obj/clothing/shoes.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/feet.dmi'

/obj/item/clothing/shoes/ship/kiryushoes
	name = "buty Kiryu"
	desc = "Para butów dla detektywów, którzy chcą wyglądać jak mafia. Na podeszwie zebrała się lepka substancja z różnych miejsc zbrodni."
	icon_state = "kiryushoes"
	item_state = "kiryushoes"

/obj/item/clothing/shoes/clown_shoes/delinquent
	name = "buty chuligana"
	icon = 'nsv13/icons/obj/clothing/shoes.dmi'
	icon_state = "clown_shoes"
	worn_icon = 'nsv13/icons/mob/feet.dmi'
	desc = "Para nieskazitelnie białych trampek. Yare yare daze."

/obj/item/clothing/suit/ship/delinquent
	name = "kurtka chuligana"
	desc = "Przerobiona i pewnie skradziona kurtka akademii Nanotrasen, ozdobiona niezliczonymi naszywkami i nawiązaniami. Yare yare daze."
	icon_state = "clown_suit"
	actions_types = list(/datum/action/item_action/menacing_pose)

/datum/action/item_action/menacing_pose
	name = "Przyjmij groźną pozę"
	button_icon_state = "menacing"
	icon_icon = 'nsv13/icons/mob/actions/actions.dmi'
	var/cooldown = FALSE

/datum/action/item_action/menacing_pose/Trigger()
	if(!IsAvailable())
		return
	pose(owner)
	return TRUE

/datum/action/item_action/menacing_pose/proc/pose(mob/user)
	if(cooldown)
		return
	cooldown = TRUE
	UpdateButtonIcon()
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 10 SECONDS)
	var/message = pick("[user] przyjmuje groźną pozę", "[user] groźnie pozuje", "[user] wygląda groźnie")
	user.visible_message("<span class='game deadsay'>[message]</span>")
	user.shake_animation()
	for(var/I = 0, I<rand(3,5), I++)
		new /obj/effect/temp_visual/menacing(get_turf(user))

/datum/action/item_action/menacing_pose/proc/reset_cooldown()
	cooldown = FALSE
	UpdateButtonIcon()

/datum/action/item_action/menacing_pose/IsAvailable()
	if(cooldown)
		return FALSE
	return ..()

/obj/item/clothing/suit/ship/delinquent/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 7 SECONDS, NO_SLIP_WHEN_WALKING)

/obj/item/clothing/under/ship/delinquent
	name = "mundurek chuligana"
	desc = "Niezwykle elegancki mundurek z koszuli, swetra i spodni. Yare yare daze."
	icon_state = "clown_uniform"
	worn_icon_state = "clown_uniform"
	item_state = "bl_suit"

/obj/effect/temp_visual/menacing
	name = "Groźnie..."
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "menacing"
	randomdir = TRUE
	duration = 2 SECONDS

/obj/item/clothing/under/rank/munitions_tech
	name = "mundur maskujący"
	desc = "Zielony wojskowy mundur maskujący noszony przez specjalistów."
	icon_state = "camogreen"
	item_state = "g_suit"
	worn_icon_state = "camogreen"
	can_adjust = FALSE

/obj/item/clothing/under/rank/master_at_arms
	name = "kombinezon Mistrza Broni"
	desc = "Kombinezon noszony przez tych, którzy mają doświadczenie godne Mistrza Broni. Zapewnia niewielką ochronę przed ogniem."
	icon_state = "tactifool" //PLACEHOLDER
	item_state = "bl_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 0, "bleed" = 10)

/obj/item/clothing/under/ship/decktech
	name = "ogrodniczki Technika Amunicyjnego"
	desc = "Mocno znoszone ogrodniczki tych, którzy odpowiadają za strzelanie z dział okrętu. Nie byłyby kompletne bez grubej warstwy smaru."
	icon_state = "deck_tech"
	item_state = "bl_suit"
	worn_icon_state = "deck_tech"
	can_adjust = TRUE

/obj/item/clothing/head/helmet/decktech
	name = "hełm Technika Amunicyjnego"
	desc = "Przyłbica spawalnicza chroniąca techników w niebezpiecznym otoczeniu."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "decktech_helmet"
	item_state = "decktech_helmet"
	actions_types = list(/datum/action/item_action/toggle)
	tint = 2
	flash_protect = 2
	flags_inv = HIDEHAIR|HIDEEYES
	flags_cover = HEADCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT

/obj/item/clothing/head/helmet/decktech/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/suit/ship/munitions_jacket
	name = "kurtka Technika Amunicyjnego"
	desc = "Standardowy mundur Technika Amunicyjnego. Odblaskowy pomarańcz, a jednak wciąż czerń."
	icon_state = "munitions_jacket"
	item_state = "munitions_jacket"

/obj/item/clothing/suit/ship/maa_jacket
	name = "kurtka galowa Mistrza Broni"
	desc = "Galowy mundur Mistrza Broni. Żywy odblaskowy pomarańcz i elegancka czerń."
	icon_state = "maa_jacket"
	item_state = "maa_jacket"

/obj/item/clothing/head/ship/maa_hat
	name = "czapka Mistrza Broni"
	desc = "Władcza czapka Mistrza Broni."
	icon_state = "maa_hat"
	item_state = "maa_hat"

/obj/item/clothing/head/helmet/space/hardsuit/master_at_arms
	name = "hełm saperski Mistrza Broni"
	desc = "Użyj w razie bomby."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-maa"
	hardsuit_type = "maa"
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 100, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 65, "stamina" = 10, "bleed" = 70)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/master_at_arms
	name = "kombinezon saperski Mistrza Broni"
	desc = "Zaawansowany kombinezon zapewniający bezpieczeństwo przy pracy z materiałami wybuchowymi."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "maa_bombsuit"
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 100, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 65, "stamina" = 10, "bleed" = 70)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	slowdown = 1.5
	permeability_coefficient = 0.01
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/master_at_arms




/obj/item/clothing/under/ship/syndicate_tech
	name = "kombinezon technika Syndykatu"
	desc = "Kombinezon noszony przez techników Syndykatu, opancerzony, by chronić noszącego w walce."
	icon_state = "syndicate_tech"
	worn_icon_state = "syndicate_tech"
	item_state = "bl_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "bleed" = 10)
	can_adjust = TRUE

/obj/item/clothing/suit/ship/syndicate_crew
	name = "kurtka Syndykatu"
	desc = "Wygodna, ale wyściełana kurtka elitarnych oficerów floty Syndykatu. Tam, gdzie jej odpowiednik z Nanotrasen ma medale, ta ma miejsce na zaznaczanie zabitych."
	icon_state = "syndicate_officer"
	worn_icon_state = "syndicate_officer"

/obj/item/clothing/under/ship/pilot/syndicate
	name = "bojowy kombinezon Syndykatu"
	desc = "Komplet mundurów maskujących, należący do umundurowania Syndykatu."

/obj/item/clothing/neck/cloak/ship
	name = "zastępczy"
	icon = 'nsv13/icons/obj/clothing/neck.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/neck.dmi'
	icon_state = "nothing" //References uniforms.dmi
	worn_icon_state = "nothing" //Icon state for its worn icon, references uniform.dmi
	item_state = ""	//no inhands

//Admiral kit. Credit to Idinuum from Yogstation for most of this!


/obj/item/clothing/head/ship/fleet_admiral
	name = "czapka admirała"
	desc = "Imponująca czapka noszona przez najwyższych rangą w marynarce Nanotrasen."
	icon_state = "fleet_admiral"
	worn_icon_state = "fleet_admiral"

/obj/item/clothing/head/beret/ship/admiral
	name = "beret admirała"
	desc = "Solidny beret noszony przez tych, którzy mają stopień admirała."
	icon_state = "beret_admiral"
	item_state = "beret_admiral"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/neck/cloak/ship/admiral
	name = "peleryna wielkiego admirała"
	desc = "Powłóczysta peleryna admirałów floty. Noszą ją absolutne elity marynarki Nanotrasen. Spotkanie kogoś o takim stopniu to jednocześnie ogromny zaszczyt i zły omen."
	icon_state = "fleet_admiral"
	worn_icon_state = "fleet_admiral"

/obj/item/clothing/suit/ship/officer/admiral
	name = "kurtka galowa admirała"
	desc = "Ciężka, wysokiej jakości kurtka noszona przez wszystkich w stopniu admirała. Zdobią ją niezliczone medale i pieczęcie."
	icon_state = "jacket_admiral"

/obj/item/clothing/suit/ship/officer/admiral/fleet
	name = "kurtka galowa admirała floty"
	icon_state = "jacket_fleet_admiral"

/obj/item/clothing/suit/ship/officer/admiral/grand
	name = "kurtka galowa wielkiego admirała"
	icon_state = "jacket_grand_admiral"

/obj/item/clothing/under/ship/officer/admiral
	name = "mundur admirała"
	icon_state = "admiral"
	worn_icon_state = "admiral"

/obj/item/clothing/under/ship/officer/admiral/fleet
	name = "mundur admirała floty"
	icon_state = "fleet_admiral"
	worn_icon_state = "fleet_admiral"

/obj/item/clothing/under/ship/officer/admiral/grand
	name = "mundur wielkiego admirała"
	icon_state = "grand_admiral"
	worn_icon_state = "grand_admiral"

//Solgov uniforms.
/obj/item/clothing/under/ship/solgov
	name = "mundur kadeta SolGov"
	desc = "Wygodny mundur oficerów korpusu badawczego SolGov."
	icon_state = "solgov_cadet"
	worn_icon_state = "solgov_cadet"

/obj/item/clothing/under/ship/solgov/command
	name = "mundur dowództwa SolGov"
	icon_state = "solgov_command"
	worn_icon_state = "solgov_command"

/obj/item/clothing/under/ship/solgov/engsec
	name = "mundur inżynierii i ochrony SolGov"
	icon_state = "solgov_engsec"
	worn_icon_state = "solgov_engsec"

/obj/item/clothing/under/ship/solgov/medsci
	name = "mundur medycyny i nauki SolGov"
	icon_state = "solgov_medsci"
	worn_icon_state = "solgov_medsci"

/obj/item/clothing/under/ship/solgov/pilot
	name = "mundur pilota SolGov"
	icon_state = "solgov_pilot"
	worn_icon_state = "solgov_pilot"

/obj/item/clothing/under/ship/solgov/admiral
	name = "mundur admirała SolGov"
	icon_state = "solgov_admiral"
	worn_icon_state = "solgov_admiral"

/obj/item/clothing/accessory/solgov_jacket
	name = "kurtka mundurowa"
	desc = "Niezwykle wygodna kurtka z kilkoma kieszeniami na narzędzia."
	icon = 'nsv13/icons/obj/clothing/accessories.dmi'
//	worn_icon = 'nsv13/icons/mob/accessories.dmi' For some reason this doesn't just work :(
	icon_state = "trekjacket"
	worn_icon_state = "trekjacket"
	item_state = "trekjacket"
	actions_types = list(/datum/action/item_action/nsv13_jacket_swap)
	var/toggled = TRUE //Starts by displaying your departmental colours

/obj/item/clothing/accessory/solgov_jacket/command
	name = "kurtka mundurowa"
	desc = "Niezwykle wygodna kurtka z kilkoma kieszeniami na narzędzia."
	icon_state = "trekjacket_command"
	worn_icon_state = "trekjacket_command"
	item_state = "trekjacket_command"

/obj/item/clothing/accessory/solgov_jacket/engsec
	name = "kurtka mundurowa"
	desc = "Niezwykle wygodna kurtka z kilkoma kieszeniami na narzędzia."
	icon_state = "trekjacket_engsec"
	worn_icon_state = "trekjacket_engsec"
	item_state = "trekjacket_engsec"

/obj/item/clothing/accessory/solgov_jacket/medsci
	name = "kurtka mundurowa"
	desc = "Niezwykle wygodna kurtka z kilkoma kieszeniami na narzędzia."
	icon_state = "trekjacket_medsci"
	worn_icon_state = "trekjacket_medsci"
	item_state = "trekjacket_medsci"

/obj/item/clothing/accessory/solgov_jacket/formal
	name = "kurtka galowa Starszego Oficera"
	desc = "Niezwykle wygodna kurtka przetykana złotym jedwabiem. Taki strój zwykle zakłada się na okazje dyplomatyczne."
	icon_state = "trekjacket_captain"
	worn_icon_state = "trekjacket_captain"
	item_state = "trekjacket_captain"

/obj/item/clothing/accessory/solgov_jacket/formal/captain
	name = "kurtka galowa kapitana"
	desc = "Niezwykle wygodna kurtka przetykana złotym jedwabiem. Zarezerwowana dla kapitanów statków kosmicznych i wyższych rangą, zdobi ją herb SolGov i oznacza dostojeństwo."
	icon_state = "trekjacket_formal"
	worn_icon_state = "trekjacket_formal"
	item_state = "trekjacket_formal"

/datum/action/item_action/nsv13_jacket_swap
	name = "Zmień styl kurtki"
	desc = "Pokaż albo ukryj barwy działu na kurtce, odwracając jej naramienniki."
	button_icon_state = "jacketswap"
	icon_icon = 'nsv13/icons/mob/actions/actions_spells.dmi'

/obj/item/clothing/accessory/solgov_jacket/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/nsv13_jacket_swap))
		toggle(user)
		return TRUE

/obj/item/clothing/accessory/solgov_jacket/proc/toggle(mob/user)
	if(toggled)
		to_chat(user, "<span class='notice'>Zasłaniasz barwy działu na [src].</span>")
		icon_state = "trekjacket"
		worn_icon_state = "trekjacket"
		item_state = "trekjacket"
		toggled = FALSE
	else
		to_chat(user, "<span class='notice'>Pokazujesz barwy działu na [src].</span>")
		icon_state = initial(icon_state)
		worn_icon_state = initial(worn_icon_state)
		item_state = initial(item_state)
		toggled = TRUE

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate/admiral
	name = "kamizelka admirała Syndykatu"
	desc = "Złowrogo wyglądająca kamizelka z zaawansowanego pancerza, noszona na czarno-czerwonej ognioodpornej kurtce. Złoty kołnierz i naramienniki oznaczają, że należy do wysokiego rangą oficera Syndykatu. Ta jest przerobiona tak, by była szczelna w kosmosie i bardzo odporna na laserową broń Nanotrasen."
	icon_state = "syndievest_space"
	worn_icon = 'icons/mob/suit.dmi'
	armor = list("melee" = 60, "bullet" = 70, "laser" = 40, "energy" = 80, "bomb" = 60, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "bleed" = 60)
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/skinsuit
	name = "hełm skafandra obcisłego"
	icon = 'icons/obj/clothing/hats.dmi'
	w_class = WEIGHT_CLASS_SMALL //Don't question it. We want it to fit back in the box
	worn_icon = 'icons/mob/head.dmi'
	icon_state = "skinsuit_helmet"
	item_state = "skinsuit_helmet"
	desc = "Szczelny hełm chroniący noszącego w sytuacjach awaryjnych."
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 20, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 50)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = 0
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	max_heat_protection_temperature = 100

/obj/item/clothing/suit/space/skinsuit
	name = "skafander obcisły"
	desc = "Smukły skafander uciskowy chroniący użytkownika w sytuacjach awaryjnych. Jest tylko trochę cieplejszy niż twój mundur."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/suit.dmi'
	icon_state = "skinsuit_rolled"
	slowdown = 3 //Higher is slower
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = STOPSPRESSUREDAMAGE
	gas_transfer_coefficient = 0.5
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 50)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100
	var/rolled_up = TRUE

/obj/item/clothing/suit/space/skinsuit/mob_can_equip(mob/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(rolled_up && slot == ITEM_SLOT_OCLOTHING)
		if(equipper)
			to_chat(equipper, "<span class='warning'>Najpierw musisz rozwinąć [src], głuptasie.</span>")
		else
			to_chat(M, "<span class='warning'>Najpierw musisz rozwinąć [src], głuptasie.</span>")
		return FALSE
	return ..()

/obj/item/clothing/suit/space/skinsuit/examine(mob/user)
	. = ..()
	if(rolled_up)
		. += "<span class='notice'>Jest obecnie zwinięty.</span>"
	else
		. += "<span class='notice'>Można go zwinąć, by zmieścił się w pudełku.</span>"


/obj/item/clothing/suit/space/skinsuit/attack_self(mob/user)
	if(rolled_up)
		to_chat(user, "<span class='notice'>Rozwijasz [src].</span>")
		icon_state = "skinsuit"
		update_icon()
		w_class = WEIGHT_CLASS_NORMAL
	else
		to_chat(user, "<span class='notice'>Zwijasz [src].</span>")
		icon_state = "skinsuit_rolled"
		update_icon()
		w_class = WEIGHT_CLASS_SMALL

	rolled_up = !rolled_up

/obj/item/clothing/head/maidheadband/syndicate
	name = "taktyczna opaska pokojówki"
	desc = "Taktyuroczo."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "syndieheadband"
	item_state = "syndieheadband"

/obj/item/clothing/under/syndicate/maid
	name = "taktyczny strój pokojówki"
	desc = "„Taktyczny” golf uszyty na podobieństwo stroju pokojówki. Po co Syndykatowi coś takiego, nigdy się nie dowiesz."
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'nsv13/icons/mob/uniform.dmi'
	icon_state = "syndimaid"
	item_state = "syndimaid"
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/skirt/maid/Initialize()
	. = ..()
	var/obj/item/clothing/accessory/maidapron/syndicate/A = new (src)
	attach_accessory(A)

/obj/item/clothing/gloves/combat/maid
	name = "bojowe rękawy pokojówki"
	desc = "Te „taktyczne” rękawiczki z rękawami są ognioodporne i izolują elektrycznie. Do tego grzeją."
	icon = 'nsv13/icons/obj/clothing/gloves.dmi'
	worn_icon = 'nsv13/icons/mob/hands.dmi'
	icon_state = "syndimaid_arms"
	worn_icon_state = "syndimaid_arms"
	item_state = "syndimaid_arms"

/obj/item/clothing/accessory/maidapron/syndicate
	name = "fartuch pokojówki Syndykatu"
	desc = "Praktyczny? Nie. Taktyczny? Też nie. Uroczy? Zdecydowanie tak."
	icon = 'nsv13/icons/mob/accessories.dmi'
	icon_state = "maidapronsynd"
	item_state = "maidapronsynd"
