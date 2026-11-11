/datum/test_chamber_kit/pr_618
	name = "Smycz drużyny: oznaczenia i IFF"
	pr = "aq33/AquilaStation#618"
	description = "Zestaw: pistolet z zapasowym magazynkiem, dwie smycze twojej drużyny i jedna innej drużyny (setup dopisuje cię do pierwszej drużyny). Do drugiej osoby użyj zestawu z obiektami testowymi. \
	1) Bez smyczy: nad tobą nie ma ramki z funkcją i nie widzisz ramek innych. \
	2) Załóż smycz swojej drużyny: nad tobą (lewy górny róg) pojawia się ramka w kolorze drużyny z symbolem twojej funkcji; na postaci nie ma drugiego znaczka ze smyczy. Zdejmij smycz → ramka znika. \
	3) Załóż smycz innej drużyny: ramka w kolorze tamtej drużyny z symbolem żołnierza. Konsola drużyn: przemaluj tamtą drużynę → ramka od razu zmienia kolor. \
	4) Widok: ramki innych osób w smyczach widzisz tylko, gdy sam masz smycz na szyi. \
	5) Chodzenie w smyczy: ręce i nogi ruszają się przy krokach (animacja chodu). \
	6) IFF: ty w smyczy swojej drużyny, obiekt testowy w drugiej smyczy tej drużyny między tobą a celem → kula go omija; kliknij prosto w niego → dostaje. Zdejmij swoją smycz → kula trafia osobę stojącą na drodze (negatyw)."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
	)

/datum/test_chamber_kit/pr_618/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/tester = user
	var/list/squads = GLOB.squad_manager?.squads
	if(!istype(tester) || length(squads) < 2)
		return
	var/datum/squad/own_squad = squads[1]
	if(tester.squad != own_squad)
		if(tester.squad)
			tester.squad.remove_member(tester)
		own_squad.add_member(tester)
	for(var/i in 1 to 2)
		spawned += new /obj/item/clothing/neck/squad(center, own_squad)
	spawned += new /obj/item/clothing/neck/squad(center, squads[2])
	for(var/obj/item/gun/gun in spawned)
		gun.unlock()
