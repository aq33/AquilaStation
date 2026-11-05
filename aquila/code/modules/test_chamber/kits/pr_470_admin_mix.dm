/datum/test_chamber_kit/pr_470
	name = "PR 470: błysk z lufy, chrono, weighted"
	pr = "aq33/AquilaStation#470"
	description = "Zestaw spala lampy w arenie (jest ciemno; po teście zresetuj komorę, żeby wróciło światło) i daje kartę górnika z 3000 punktów. W komorze da się sprawdzić błysk z lufy i cenę kredytów; chrono i weighted tylko częściowo, resztę trzeba w lobby. \
		1) Strzelaj w ciemności z lasera, e-guna (przełącz tryb), disablera, tasera i pistoletu → oczekiwane: z lufy błyska krótkie kierunkowe światło w kolorze amunicji (laser czerwony, disabler cyjan, taser żółty). \
		2) Negatyw: załóż tłumik na pistolet i strzel → oczekiwane: błysku nie ma. \
		3) Kup w automacie górniczym 1000 kosmicznych kredytów kartą z zestawu → oczekiwane: kosztuje 2400 punktów (zostaje 600). \
		4) Chrono legionista (wymaga ducha do roli i ciebie jako żywego człowieka z kontem gracza): Trigger Event → Spawn Chrono Legionnaire → oczekiwane: na liście wyboru jest każdy żywy gracz, nie tylko imiona z listy; legionista ściga wybranego. Manekin bez gracza w komorze na liście się nie pojawi. \
		5) Poza komorą, w lobby: Server → Wagi trybu weighted (ręczne wagi, wymuszona pula), w panelu statystyk szanse pul i „Możliwa obsada” po kliknięciu Gotowy; emblemat „G” na ekranie tytułowym."
	items = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/gun/energy/taser = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 2,
		/obj/item/suppressor = 1,
		/obj/machinery/vendor/mining = 1,
		/obj/item/card/id/mining = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_470/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Błysk z lufy widać dopiero w ciemności, więc gasimy lampy areny
	for(var/obj/machinery/light/lamp in get_area(center))
		lamp.burn_out()
	// Punkty na zakup 1000 kredytów (2400 pkt)
	for(var/obj/item/card/id/mining/card in spawned)
		card.mining_points = 3000
