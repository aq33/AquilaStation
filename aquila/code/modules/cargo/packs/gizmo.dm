/// Skrzynia z gizmami (tg, tgstation/tgstation#95857). tg: CARGO_CRATE_VALUE * 5, u nas ceny są mniej więcej dwa razy wyższe
/datum/supply_pack/science/gizmo
	name = "Gizmo Research Crate"
	desc = "Trzy dziwne naukowe gizma-dzyndzle? Nie wiemy, co robią. Do otwarcia wymagany jest dostęp naukowy."
	cost = 2000
	access = ACCESS_RESEARCH
	contains = list(
		/obj/machinery/gizmo,
		/obj/effect/spawner/lootdrop/gizmo,
		/obj/effect/spawner/lootdrop/gizmo,
	)
	crate_name = "gizmo research crate"
	crate_type = /obj/structure/closet/crate/secure/science
