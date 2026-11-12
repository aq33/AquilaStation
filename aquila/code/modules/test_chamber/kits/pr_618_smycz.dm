/datum/test_chamber_kit/pr_618
	name = "Smycz drużyny: IFF"
	pr = "aq33/AquilaStation#618"
	description = "Zestaw: pistolet z zapasowym magazynkiem i dwie smycze tej samej drużyny (zestaw nie zmienia twojej drużyny: IFF zależy tylko od smyczy). Do drugiej osoby użyj zestawu z obiektami testowymi. \
	1) Bez smyczy na szyi: obiekt testowy w jednej ze smyczy stoi między tobą a celem → kula go trafia (samo członkostwo w drużynie nie daje IFF). \
	2) Załóż drugą smycz: ta sama sytuacja → kula go omija; kliknij prosto w niego → dostaje. \
	3) Zdejmij smycz z obiektu testowego → kula go trafia (negatyw). \
	Osobno, poza komorą: zrestartuj serwer i połącz się, zanim skończy start (przed „Initializations complete”) → wybór języka i profesji reaguje na kliknięcia, a w grze ręce i nogi ruszają się przy krokach."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
	)

/datum/test_chamber_kit/pr_618/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/datum/squad/squad = GLOB.squad_manager?.squads?[1]
	if(!squad)
		return
	for(var/i in 1 to 2)
		var/obj/item/clothing/neck/squad/lanyard = new(center)
		// IFF czyta tylko drużynę smyczy; bez apply_squad(), bo malowanie paskami usypia (CHECK_TICK) i zatrzymywało zestaw
		lanyard.squad = squad
		lanyard.name = "[initial(lanyard.name)] drużyny [squad]"
		spawned += lanyard
	for(var/obj/item/gun/gun in spawned)
		gun.unlock()
