/datum/test_chamber_kit/pr_618
	name = "Smycz drużyny: IFF"
	pr = "aq33/AquilaStation#618"
	description = "Zestaw: pistolet z zapasowym magazynkiem i dwie smycze twojej drużyny (setup dopisuje cię do pierwszej drużyny). Do drugiej osoby użyj zestawu z obiektami testowymi. \
	1) Bez smyczy na szyi: obiekt testowy w smyczy twojej drużyny stoi między tobą a celem → kula go trafia (samo członkostwo w drużynie nie daje IFF). \
	2) Załóż smycz: ta sama sytuacja → kula go omija; kliknij prosto w niego → dostaje. \
	3) Zdejmij smycz z obiektu testowego → kula go trafia (negatyw). \
	4) Chodzenie: ręce i nogi ruszają się przy krokach także po wejściu na serwer w trakcie jego startu; wybór języka i profesji działa po takim wejściu."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
	)

/datum/test_chamber_kit/pr_618/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/tester = user
	var/datum/squad/squad = GLOB.squad_manager?.squads?[1]
	if(!istype(tester) || !squad)
		return
	if(tester.squad != squad)
		if(tester.squad)
			tester.squad.remove_member(tester)
		squad.add_member(tester)
	for(var/i in 1 to 2)
		spawned += new /obj/item/clothing/neck/squad(center, squad)
	for(var/obj/item/gun/gun in spawned)
		gun.unlock()
