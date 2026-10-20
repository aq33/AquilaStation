/datum/test_chamber_kit/pr_474
	name = "Resprite cz. 3"
	pr = "aq33/AquilaStation#474"
	description = "Przedmioty, meble i stworzenia z nowymi sprite'ami: łóżko operacyjne i stojak IV, slime'y, małpa, golem, \
		PDA, materiały, skrzynie i szafki (zamknij, otwórz, zemaguj), kosz, zlewki z płynem, strzykawka, narzędzia, \
		krzesło, komoda, regały, zbiorniki, MULEbot. Stoły stoją w rzędzie, żeby było widać łączenie."
	items = list(
		/obj/structure/table/optable = 1,
		/obj/machinery/iv_drip = 1,
		/mob/living/simple_animal/slime = 1,
		/obj/item/slime_extract/grey = 1,
		/mob/living/carbon/monkey = 1,
		/obj/item/storage/box/monkeycubes = 1,
		/mob/living/carbon/human/species/golem = 1,
		/obj/item/modular_computer/tablet/pda = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/ore/gold = 1,
		/obj/structure/closet/secure_closet/freezer/kitchen = 1,
		/obj/structure/closet/secure_closet/personal = 1,
		/obj/structure/closet/crate/secure/weapon = 1,
		/obj/structure/closet/crate = 1,
		/obj/structure/closet/crate/bin = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wirecutters = 1,
		/obj/item/weldingtool = 1,
		/obj/structure/chair/office = 1,
		/obj/structure/dresser = 1,
		/obj/structure/bookcase = 1,
		/obj/structure/rack = 1,
		/obj/structure/reagent_dispensers/fueltank = 1,
		/obj/structure/reagent_dispensers/watertank = 1,
		/mob/living/simple_animal/bot/mulebot = 1
	)

// Stoły stoją przed zrzuceniem items i ich pola wypadają z listy, żeby nie zasłaniały przedmiotów
/datum/test_chamber_kit/pr_474/spawn_kit(list/turfs, turf/center, mob/user)
	turfs = turfs.Copy()
	for(var/i in -2 to 2)
		var/turf/table_spot = locate(center.x + i, center.y - 2, center.z)
		if(table_spot && (table_spot in turfs))
			turfs -= table_spot
			new /obj/structure/table(table_spot)
		var/turf/wood_spot = locate(center.x + i, center.y - 3, center.z)
		if(wood_spot && (wood_spot in turfs))
			turfs -= wood_spot
			new /obj/structure/table/wood(wood_spot)
	return ..(turfs, center, user)

/datum/test_chamber_kit/pr_474/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/item/reagent_containers/glass/beaker/large/beaker = locate() in spawned
	beaker?.reagents.add_reagent(/datum/reagent/water, 60)
