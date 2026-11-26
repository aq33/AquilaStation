/*
	AQUILA - rośliny przeniesione z Goona, Baya, Paradise, Monke i Nebuli (partia „inne”)
	Rośliny są w plikach inne_*.dm, tu wspólne rzeczy: odczynniki, dopiski mutacji do istniejących roślin i automat z nasionami.
	Grafiki: plony i kwiaty na głowie z Goona (CC-BY-NC-SA 3.0), mango z Paradise, melon miodowy z Monkestation,
	torebki nasion z Paradise, tg i Monke albo złożone z szablonu torebki tg i plonu.
*/

/*
	Mutacje z roślin, które już mamy (dopiski, bez nadpisywania ich list)
*/
/datum/plant_mutation_set/inne
	mutations = list(
		/datum/plant_feature/fruit/berry = list(/datum/plant_feature/fruit/berry/blueberry = 3),
		/datum/plant_feature/fruit/watermelon = list(/datum/plant_feature/fruit/watermelon/honeydew = 3),
		/datum/plant_feature/fruit/tea = list(/datum/plant_feature/fruit/tea/catnip = 3),
		/datum/plant_feature/fruit/tomato/blue = list(/datum/plant_feature/fruit/tomato/quantum = 8),
	)
	reagent_mutations = list(
		/datum/plant_feature/fruit/orange = list(
			/datum/plant_feature/fruit/orange/blood = list(/datum/reagent/blood = 10),
			/datum/plant_feature/fruit/orange/clockwork = list(/datum/reagent/iron = 10),
		),
		/datum/plant_feature/fruit/tomato = list(
			/datum/plant_feature/fruit/tomato/seething = list(/datum/reagent/phlogiston = 5),
		),
		/datum/plant_feature/fruit/pumpkin = list(/datum/plant_feature/fruit/pumpkin/spice = list(/datum/reagent/consumable/capsaicin = 10)),
	)

/*
	Automat z nasionami: podstawowe uprawy, trucizny i cuchnące kwiaty tylko po zhakowaniu
*/
/obj/machinery/vending/hydroseeds/Initialize(mapload)
	for(var/seed_type in list(
		/obj/item/plant_seeds/preset/peach, /obj/item/plant_seeds/preset/strawberry,
		/obj/item/plant_seeds/preset/avocado, /obj/item/plant_seeds/preset/mango,
		/obj/item/plant_seeds/preset/lavender, /obj/item/plant_seeds/preset/mint, /obj/item/plant_seeds/preset/lettuce,
		/obj/item/plant_seeds/preset/flax, /obj/item/plant_seeds/preset/hydrangea,
		/obj/item/plant_seeds/preset/gardenia))
		products[seed_type] = 3
	for(var/seed_type in list(
		/obj/item/plant_seeds/preset/asomna, /obj/item/plant_seeds/preset/commol, /obj/item/plant_seeds/preset/contusine,
		/obj/item/plant_seeds/preset/nureous, /obj/item/plant_seeds/preset/ipecacuanha))
		products[seed_type] = 2
	contraband[/obj/item/plant_seeds/preset/aconite] = 2
	return ..()
