/datum/test_chamber_kit/pr_monke_wizualia
	name = "Efekty wizualne z Monkestation"
	pr = "aq33/AquilaStation#488"
	description = "Strzelaj z pistoletu i C-20r: z lufy ma lecieć dymek. Strzelaj w drewniany stół, okno, dźwigar i ścianę komory: \
		drzazgi, szkło, iskry i dymek w miejscu trafienia. Z lasera: sam dymek, bez odłamków. \
		Rzuć minibombę i granat odłamkowy daleko od siebie: wybuch ma mieć falę dymu, kłęby, gruz i iskry. \
		Przełączniki w VV (GLOB): explosion_particles_enabled, explosion_particles_max, impact_particles_enabled, impact_particles_max."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/gun/ballistic/automatic/c20r/unrestricted = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/grenade/frag = 1,
		/obj/structure/table/wood = 1,
		/obj/structure/window/reinforced/fulltile = 1,
		/obj/structure/girder = 1,
	)
