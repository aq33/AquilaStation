//miscellaneous spacesuits
/*
Contains:
 - Captain's spacesuit
 - Death squad's hardsuit
 - SWAT suit
 - Officer's beret/spacesuit
 - NASA Voidsuit
 - Father Christmas' magical clothes
 - Pirate's spacesuit
 - ERT hardsuit: command, sec, engi, med, janitor
 - EVA spacesuit
 - Freedom's spacesuit (freedom from vacuum's oppression)
 - Carp hardsuit
 - Bounty hunter hardsuit
 - Emergency skinsuit
*/

	//Death squad armored space suits, not hardsuits!
/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "hełm SWAT MK.III"
	desc = "Zaawansowany taktyczny hełm kosmiczny."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "skafander SWAT MK.III"
	desc = "Prototyp, który ma zastąpić starzejący się skafander SWAT MK.II. Bazuje na opływowym modelu MK.II, ale tradycyjne płyty z ceramiki i grafenu zastąpiono plastalą, co daje lepszą ochronę przed większością zagrożeń. Na plecach jest miejsce na jakiś projektor energii."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 100, "bleed" = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	dog_fashion = /datum/dog_fashion/back/deathsquad
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "skafander SWAT MK.I"
	desc = "Taktyczny skafander kosmiczny opracowany w 20XX roku wspólnie przez nieistniejące już IS-ERI i Nanotrasen na potrzeby wojskowych operacji w kosmosie. Sprawdzony wół roboczy – bardzo trudno się w nim ruszać, ale solidnie chroni przed każdym zagrożeniem!"
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list("melee" = 40, "bullet" = 50, "laser" = 15,"energy" = 10, "bomb" = 50, "bio" = 90, "rad" = 20, "fire" = 100, "acid" = 100, "stamina" = 60) //NSV13
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/head/helmet/space/beret
	name = "beret oficera"
	desc = "Opancerzony beret, jaki zwykle noszą oficerowie sił specjalnych. Chroni głowę przed próżnią dzięki zaawansowanej technologii pola siłowego."
	icon_state = "dsberet"
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"
	flags_inv = 0
	armor = list("melee" = 70, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 60, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 90, "bleed" = 100) //NSV13
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/officer
	name = "kurtka oficera"
	desc = "Opancerzona, odporna na próżnię kurtka używana w operacjach specjalnych."
	icon_state = "specops"
	item_state = "specops"
	blood_overlay_type = "coat"
	slowdown = 0
	flags_inv = 0
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 70, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 60, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 90, "bleed" = 100) //NSV13
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "próżniowy hełm NASA"
	desc = "Stary, ciemnoczerwony hełm kosmiczny zaprojektowany przez oddział NASA Centrali."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "skafander próżniowy NASA"
	icon_state = "void"
	item_state = "void"
	desc = "Stary, ciemnoczerwony skafander kosmiczny zaprojektowany przez oddział NASA Centrali."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "inżynieryjny hełm próżniowy"
	desc = "Ciemnoczerwony inżynieryjny hełm kosmiczny Centrali. Stary i zakurzony, ale wciąż daje radę."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "inżynieryjny skafander próżniowy"
	icon_state = "void"
	item_state = "void"
	desc = "Ciemnoczerwony inżynieryjny skafander kosmiczny Centrali. Z wiekiem się zużył, więc trudno się w nim ruszać."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "czapka Mikołaja"
	desc = "Ho, ho, ho. Wesołych Świąt!"
	icon_state = "santahat"
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/suit/space/santa
	name = "strój Mikołaja"
	desc = "Świątecznie!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents


	//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "kapelusz piracki"
	desc = "Jarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75, "stamina" = 20, "bleed" = 20)
	flags_inv = HIDEHAIR
	strip_delay = 40
	equip_delay_other = 20
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/pirate/bandana
	name = "piracka bandana"
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/suit/space/pirate
	name = "płaszcz piracki"
	desc = "Jarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = 0
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)
	slowdown = 0
	armor = list("melee" = 30, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 60, "acid" = 75, "stamina" = 20, "bleed" = 20)
	strip_delay = 40
	equip_delay_other = 20

	//Emergency Response Team suits
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "hełm dowódcy ZRK"
	desc = "Zintegrowany hełm hardsuitu ZRK, ten ma niebieskie akcenty."
	icon_state = "hardsuit0-ert_commander"
	item_state = "hardsuit0-ert_commander"
	armor = list("melee" = 65, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 70, "bleed" = 70)
	strip_delay = 130
	light_range = 7
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud
	)
	var/beacon_colour = "#4b48ec"

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)
	//Link
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/ert))
		var/obj/linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "cent", null, null, TRUE, beacon_colour)
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor, "cent", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor, "cent", null)

/obj/item/clothing/head/helmet/space/hardsuit/ert/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet_light)
			toggle_helmlight()
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)

/obj/item/clothing/head/helmet/space/hardsuit/ert/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/monitor = GetComponent(/datum/component/team_monitor)
	if(!monitor)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, "<span class='notice'>Przełączasz wyświetlacz HUD swojego kombinezonu.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz wyświetlacz HUD swojego kombinezonu.</span>")

/obj/item/clothing/suit/space/hardsuit/ert
	name = "hardsuit dowódcy ZRK"
	desc = "Standardowy hardsuit ZRK, ten ma niebieskie akcenty. Doskonale chroni przed zagrożeniami środowiskowymi."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 65, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 70, "bleed" = 70)
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

/obj/item/clothing/suit/space/hardsuit/ert/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)

/obj/item/clothing/suit/space/hardsuit/ert/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, "<span class='notice'>Włączasz nadajnik lokalizacyjny w [src]. Każdy na tej samej częstotliwości może teraz śledzić twoje położenie.</span>")
	else
		to_chat(user, "<span class='warning'>Wyłączasz nadajnik lokalizacyjny w [src].</span>")

/obj/item/clothing/suit/space/hardsuit/ert/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>Kombinezon nie jest wyposażony w nadajnik lokalizacyjny.</span>")
		return
	beacon.change_frequency(user)

	//ERT Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	name = "hełm operatora ZRK"
	desc = "Zintegrowany hełm hardsuitu ZRK, ten ma czerwone akcenty."
	icon_state = "hardsuit0-ert_security"
	item_state = "hardsuit0-ert_security"
	beacon_colour = "#ec4848"

/obj/item/clothing/suit/space/hardsuit/ert/sec
	name = "hardsuit operatora ZRK"
	desc = "Standardowy hardsuit ZRK, ten ma czerwone akcenty. Doskonale chroni przed zagrożeniami środowiskowymi."
	icon_state = "ert_security"
	item_state = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Engineering
/obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	name = "hełm inżyniera ZRK"
	desc = "Zintegrowany hełm hardsuitu ZRK, ten ma pomarańczowe akcenty."
	icon_state = "hardsuit0-ert_engineer"
	item_state = "hardsuit0-ert_engineer"
	beacon_colour = "#ecaa48"

/obj/item/clothing/suit/space/hardsuit/ert/engi
	name = "hardsuit inżyniera ZRK"
	desc = "Standardowy hardsuit ZRK, ten ma pomarańczowe akcenty. Doskonale chroni przed zagrożeniami środowiskowymi."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/med
	name = "hełm sanitariusza ZRK"
	desc = "Zintegrowany hełm hardsuitu ZRK, ten ma białe akcenty."
	icon_state = "hardsuit0-ert_medical"
	item_state = "hardsuit0-ert_medical"
	beacon_colour = "#88ecec"

/obj/item/clothing/suit/space/hardsuit/ert/med
	name = "hardsuit sanitariusza ZRK"
	desc = "Standardowy hardsuit ZRK, ten ma białe akcenty. Doskonale chroni przed zagrożeniami środowiskowymi."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/med
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	name = "hełm woźnego ZRK"
	desc = "Zintegrowany hełm hardsuitu ZRK, ten ma fioletowe akcenty."
	icon_state = "hardsuit0-ert_janitor"
	item_state = "hardsuit0-ert_janitor"
	beacon_colour = "#be43ce"

/obj/item/clothing/suit/space/hardsuit/ert/jani
	name = "hardsuit woźnego ZRK"
	desc = "Standardowy hardsuit ZRK, ten ma fioletowe akcenty. Doskonale chroni przed zagrożeniami środowiskowymi. Ma dodatkowe uchwyty na różne narzędzia do sprzątania."
	icon_state = "ert_janitor"
	item_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	allowed = list(/obj/item/storage/bag/trash, /obj/item/melee/flyswatter, /obj/item/mop, /obj/item/holosign_creator/janibarrier, /obj/item/reagent_containers/glass/bucket, /obj/item/reagent_containers/spray/chemsprayer/janitor)

/obj/item/clothing/suit/space/eva
	name = "skafander EVA"
	icon_state = "space"
	item_state = "eva_suit"
	desc = "Lekki skafander kosmiczny, który w nagłych wypadkach zapewnia podstawową ochronę przed próżnią."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 20, "fire" = 50, "acid" = 65, "stamina" = 0, "bleed" = 30)

/obj/item/clothing/head/helmet/space/eva
	name = "hełm EVA"
	icon_state = "space"
	item_state = "eva_helmet"
	desc = "Lekki hełm kosmiczny, który w nagłych wypadkach zapewnia podstawową ochronę przed próżnią."
	flash_protect = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 20, "fire" = 50, "acid" = 65, "stamina" = 0, "bleed" = 30)

/obj/item/clothing/head/helmet/space/freedom
	name = "orli hełm"
	desc = "Zaawansowany hełm odporny na próżnię. Wygląda na wzorowany na ziemskim orle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	armor = list("melee" = 20, "bullet" = 40, "laser" = 30, "energy" = 25, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 10, "bleed" = 30)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF

/obj/item/clothing/suit/space/freedom
	name = "orli skafander"
	desc = "Zaawansowany, lekki skafander z mieszanki syntetycznych piór i materiału odpornego na próżnię. Ma wbudowaną kaburę, a skrzydła chyba zacięły się w trybie „wolność”."
	icon_state = "freedom"
	item_state = "freedom"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list("melee" = 20, "bullet" = 40, "laser" = 30,"energy" = 25, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 80, "stamina" = 10, "bleed" = 30)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF
	slowdown = 0

//Carpsuit, bestsuit, lovesuit
/obj/item/clothing/head/helmet/space/hardsuit/carp
	name = "hełm karpia"
	desc = "Nadaje się do kosmosu i wygląda jak głowa kosmicznego karpia. Pachnie zresztą tak samo."
	icon_state = "carp_helm"
	item_state = "syndicate"
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 75, "stamina" = 40)
	light_system = NO_LIGHT_SUPPORT
	light_range = 0 //luminosity when on
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/carp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/carp
	name = "skafander kosmiczny karpia"
	desc = "Wyszczuplający wytwór wątpliwej technologii kosmicznych karpi."
	icon_state = "carp_suit"
	item_state = "space_suit_syndicate"
	slowdown = 0	//Space carp magic, never stop believing
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20, "energy" = 20, "bomb" = 30, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 75, "stamina" = 40)
	allowed = list(/obj/item/tank/internals, /obj/item/pneumatic_cannon/speargun, /obj/item/toy/plush/carpplushie/dehy_carp, /obj/item/toy/plush/carpplushie, /obj/item/food/fishmeat/carp)	//I'm giving you a hint here
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp

/obj/item/clothing/head/helmet/space/hardsuit/carp/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/old
	name = "poobijany hełm karpia"
	desc = "Jest pokryty śladami ugryzień i zadrapaniami, ale wciąż wydaje się w pełni sprawny."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)

/obj/item/clothing/suit/space/hardsuit/carp/old
	name = "poobijany skafander kosmiczny karpia"
	desc = "Jest pokryty śladami ugryzień i zadrapaniami, ale wciąż wydaje się w pełni sprawny."
	slowdown = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 70, "stamina" = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp/old

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "hełm zespołu reagowania paranormalnego"
	desc = "Hełm noszony przez tych, którzy zawodowo zajmują się zagrożeniami paranormalnymi."
	icon_state = "hardsuit0-prt"
	item_state = "hardsuit0-prt"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF
	beacon_colour = "#9ddb56"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "hardsuit zespołu reagowania paranormalnego"
	desc = "W ten hardsuit wbudowano potężne zabezpieczenia, które chronią przed wszelkimi zagrożeniami paranormalnymi."
	icon_state = "knight_grey"
	item_state = "knight_grey"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE)

//Lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland
	desc = "W ten hardsuit wbudowano potężne zabezpieczenia, które chronią przed wszelkimi zagrożeniami paranormalnymi, a pancerz zaprojektowano specjalnie z myślą o niskim ciśnieniu."
	high_pressure_multiplier = 0.4

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland
	high_pressure_multiplier = 0.4

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "hardsuit czempiona"
	desc = "Z hardsuitu dobiegają głosy, które doprowadzają noszącego do szaleństwa."
	icon_state = "hardsuit-beserker"
	item_state = "hardsuit-beserker"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "hełm czempiona"
	desc = "Wystarczy spojrzeć w oczy tego hełmu, by przypieczętować swoje potępienie."
	icon_state = "hardsuit0-beserker"
	item_state = "hardsuit0-beserker"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "hardsuit inkwizytora"
	icon_state = "hardsuit-inq"
	item_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "hełm inkwizytora"
	icon_state = "hardsuit0-inq"
	item_state = "hardsuit0-inq"

//End lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "hardsuit inkwizytora"
	icon_state = "hardsuit-inq"
	item_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "hełm inkwizytora"
	icon_state = "hardsuit0-inq"
	item_state = "hardsuit0-inq"

/obj/item/clothing/head/helmet/space/fragile
	name = "awaryjny hełm kosmiczny"
	desc = "Nieporęczny, szczelny hełm do ochrony w sytuacjach awaryjnych. Nie wygląda na zbyt wytrzymały."
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 5)
	strip_delay = 65
	flash_protect = 0

/obj/item/clothing/suit/space/fragile
	name = "awaryjny skafander kosmiczny"
	desc = "Nieporęczny, szczelny skafander do ochrony w sytuacjach awaryjnych. Nie wygląda na zbyt wytrzymały."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	slowdown = 2
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 5)
	strip_delay = 65
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "atak", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, "<span class='warning'>[src] rozdziera się od obrażeń, tracąc szczelność!</span>")
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "[src] (rozdarcie)"
		desc = "Nieporęczny skafander do ochrony w sytuacjach awaryjnych – przynajmniej dopóki ktoś nie zrobił w nim dziury."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)

/obj/item/clothing/suit/space/hunter
	name = "skafander łowcy nagród"
	desc = "Zmodyfikowana wersja skafandra SWAT MK.II, przerobiona tak, by wyglądała surowo i groźnie. Działa jako skafander kosmiczny, jeśli znajdziesz do niego hełm."
	icon_state = "hunter"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(melee = 60, bullet = 50, laser = 15, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, stamina = 70, "bleed" = 70) //NSV13
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit
	name = "hełm skafandra obcisłego"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "skinsuit_helmet"
	item_state = "skinsuit_helmet"
	max_integrity = 200
	desc = "Szczelny hełm do ochrony w sytuacjach awaryjnych."
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 20, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = 0
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = STOPSPRESSUREDAMAGE | SHOWEROKAY | SNUG_FIT //NSV13 - kept SHOWEROKAY
	max_heat_protection_temperature = 100
	actions_types = null

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/attack_self(mob/user)
	return

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/emp_act(severity)
	return

/obj/item/clothing/suit/space/hardsuit/skinsuit
	name = "skafander obcisły"
	desc = "Smukły skafander uciskowy do ochrony w sytuacjach awaryjnych. Jest tylko trochę cieplejszy od twojego munduru."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "skinsuit"
	item_state = "s_suit"
	max_integrity = 200
	slowdown = 3 //Higher is slower
	clothing_flags = STOPSPRESSUREDAMAGE | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	gas_transfer_coefficient = 0.5
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/skinsuit

/obj/item/clothing/suit/space/hardsuit/skinsuit/attackby(obj/item/I, mob/user, params)
	return
