/datum/test_chamber_kit/pr_470
	name = "PR 470: błysk z lufy, chrono, weighted"
	pr = "aq33/AquilaStation#470"
	description = "Strzelaj w ciemności z lasera, e-guna (przełącz tryb), disablera, tasera i pistoletu: z lufy ma błysnąć światło w kolorze amunicji. Załóż tłumik na pistolet, błysku ma nie być. \
	Admin: Trigger Event -> Spawn Chrono Legionnaire, na liście mają być wszyscy żywi gracze, legionista ma ścigać wybranego. \
	W lobby: Server -> Wagi trybu weighted (ręczne wagi, wymuszona pula), w panelu statystyk szanse pul i Możliwa obsada po kliknięciu Gotowy."
	items = list(
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/gun/energy/taser = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 2,
		/obj/item/suppressor = 1,
	)
