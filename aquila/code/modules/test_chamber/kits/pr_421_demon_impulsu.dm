// aq33/AquilaStation#421 - demon impulsu z Paradise

/datum/test_chamber_kit/pr_421
	name = "PR 421: demon impulsu"
	pr = "aq33/AquilaStation#421"
	description = "Zestaw kładzie odcinek kabla zasilanego z RTG i stawia na nim demona. Wejście w demona: Aghost i kliknij powiadomienie „Można sterować” (albo Spawners) - po wejściu dostajesz antagonistę z celami. \
	Demon ma 10 punktów APC na test Menu zdolności: kup zdolność (przycisk pojawia się dopiero po zakupie), ulepsz ją i ulepsz ciało. \
	Sprawdź: ruch tylko po kablu (z samopodtrzymaniem także poza nim, z utratą zdrowia), leczenie na zasilonym kablu, widok kabli. Łomem zerwij płytki - na odsłoniętym kablu demon razi prądem człowieka, który na niego wejdzie (w izolowanych rękawicach też, jeśli kupisz silne wstrząsy). \
	Kule przez niego przelatują, granat EMP go rani i wstrzymuje leczenie. Po śmierci robi EMP i zostawia wieczny rozrusznik: zjedzony daje odporność na prąd i ładuje noszone ogniwa. \
	Przejmowanie APC, kamery, holopad, radio, ładowarki i boty sprawdź na statku - przenieś demona adminem na kabel w maintenance."
	items = list(
		/mob/living/carbon/human = 1,
		/obj/item/crowbar = 1,
		/obj/item/clothing/gloves/color/yellow = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/organ/heart/pulse_demon = 1,
		/obj/item/stock_parts/cell/high = 1,
	)

/datum/test_chamber_kit/pr_421/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Odcinek kabla na wschód od środka, z RTG na końcu
	var/list/cable_turfs = list()
	for(var/i in 0 to 5)
		var/turf/T = locate(center.x + i, center.y - 1, center.z)
		if(!(T in turfs))
			break
		cable_turfs += T
	if(!length(cable_turfs))
		cable_turfs += center
	var/obj/structure/cable/last_cable
	for(var/turf/T as anything in cable_turfs)
		last_cable = new /obj/structure/cable(T)
	last_cable.add_power_node()
	new /obj/machinery/power/rtg/advanced(cable_turfs[length(cable_turfs)])
	var/mob/living/simple_animal/pulse_demon/test_chamber/demon = new(cable_turfs[1])
	demon.apcs_remaining = 10

/// Demon z komory: do przejęcia przez duchy, z antagonistą po wejściu gracza
/mob/living/simple_animal/pulse_demon/test_chamber/Initialize(mapload)
	. = ..()
	set_playable(ROLE_PULSE_DEMON)

/mob/living/simple_animal/pulse_demon/test_chamber/Login()
	. = ..()
	if(mind && !mind.has_antag_datum(/datum/antagonist/pulse_demon))
		mind.add_antag_datum(/datum/antagonist/pulse_demon)
