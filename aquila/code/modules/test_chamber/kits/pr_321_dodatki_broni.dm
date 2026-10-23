// aq33/AquilaStation#321 - naprawy: prom traitora, edytor postaci, menu spawnerów, dodatki broni (zestaw tylko do dodatków broni)

/datum/test_chamber_kit/pr_321
	name = "PR 321: latarka i bagnet na broniach"
	pr = "aq33/AquilaStation#321"
	description = "Załóż latarkę i nóż bojowy na PKA, nóż na Peacekeepera, latarkę na e-gun i disabler. Postrzelaj/przeładuj: nakładki latarki i bagnetu mają zostać widoczne, \
	bagnet nie może się dublować i ma zniknąć po zdjęciu (śrubokręt). Zainstaluj w PKA super/hyper chassis i wystrzel - pusta ikona przeładowania ma być domyślna, bez błędów. \
	Reszta PR (prom traitora, edytor postaci, menu spawnerów) nie da się sprawdzić w komorze."
	items = list(
		/obj/item/gun/energy/kinetic_accelerator = 2,
		/obj/item/borg/upgrade/modkit/chassis_mod = 1,
		/obj/item/borg/upgrade/modkit/chassis_mod/orange = 1,
		/obj/item/gun/ballistic/automatic/peacekeeper = 1,
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/flashlight/seclite = 4,
		/obj/item/kitchen/knife/combat = 2,
		/obj/item/screwdriver = 1,
	)
