/*
	AQUILA - skorupiaki z akwakultury Baya (/datum/seed/shellfish) i Nebuli (/datum/seed/mollusc)
	Każdy gatunek: cecha owocu, preset larw (korzenie wodne + ławica), plon.
	Zamknięte skorupy otwiera się nożem (jak w oryginałach); kraby dają od razu nasze surowe mięso kraba.
	Grafiki: Bay (food_shellfish.dmi) i Nebula (molluscs.dmi), CC-BY-SA 3.0; aquila/icons/obj/hydroponics/ported_akwa_*.dmi.
*/

/datum/plant_feature/fruit/shellfish
	species_name = "conchae"
	name = "skorupiaki"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_fruit.dmi'
	icon_state = "clam"
	seed_icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	seed_icon_state = "seed-clam"
	abstract_type = /datum/plant_feature/fruit/shellfish
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	fast_reagents = list(/datum/reagent/consumable/nutriment/protein = PLANT_REAGENT_MEDIUM)

/// Zamknięta skorupa: plon z ławicy, otwiera się nożem
/obj/item/food/grown/shellfish
	abstract_type = /obj/item/food/grown/shellfish
	name = "skorupiak"
	desc = "Świeży skorupiak. Przed jedzeniem trzeba go otworzyć nożem."
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_harvest.dmi'
	w_class = WEIGHT_CLASS_TINY
	foodtypes = MEAT | RAW
	can_distill = FALSE
	///Co zostaje po otwarciu nożem
	var/meat_type

/obj/item/food/grown/shellfish/make_processable()
	if(meat_type)
		AddElement(/datum/element/processable, TOOL_KNIFE, meat_type, 1, 2 SECONDS, screentip_verb = "Otwórz")

/// Mięso skorupiaka po otwarciu - składnik do kuchni
/obj/item/food/shellfish_meat
	name = "surowe mięso skorupiaka"
	desc = "Mięso ze skorupiaka, gotowe do użycia."
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_harvest.dmi'
	w_class = WEIGHT_CLASS_TINY
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	foodtypes = MEAT | RAW

/*
	Małże (Bay: clam, Nebula: clam)
*/
/datum/plant_feature/fruit/shellfish/clam
	species_name = "mercenaria mercenaria"
	name = "małże"
	icon_state = "clam"
	seed_icon_state = "seed-clam"
	fruit_product = /obj/item/food/grown/shellfish/clam
	plant_traits = list(/datum/plant_trait/reagent/fruit/vitamin)

/obj/item/plant_seeds/preset/clam
	name = "larwy: małże (woda)"
	name_override = "małże"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-clam"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/clam)

/obj/item/food/grown/shellfish/clam
	seed = /obj/item/plant_seeds/preset/clam
	name = "małż"
	desc = "Świeży małż. Przed jedzeniem trzeba go otworzyć nożem."
	icon_state = "clam"
	tastes = list("małż" = 1)
	meat_type = /obj/item/food/shellfish_meat/clam

/obj/item/food/shellfish_meat/clam
	name = "surowy małż"
	desc = "Smaczny małż, gotowy do użycia."
	icon_state = "clam_open"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5)
	tastes = list("małż" = 1)

/*
	Ostrygi (Bay: oyster)
*/
/datum/plant_feature/fruit/shellfish/oyster
	species_name = "crassostrea gigas"
	name = "ostrygi"
	icon_state = "oyster"
	seed_icon_state = "seed-oyster"
	fruit_product = /obj/item/food/grown/shellfish/oyster
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	plant_traits = list(/datum/plant_trait/reagent/fruit/vitamin/large)

/obj/item/plant_seeds/preset/oyster
	name = "larwy: ostrygi (woda)"
	name_override = "ostrygi"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-oyster"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/oyster)

/obj/item/food/grown/shellfish/oyster
	seed = /obj/item/plant_seeds/preset/oyster
	name = "ostryga"
	desc = "Świeża ostryga. Przed jedzeniem trzeba ją otworzyć nożem."
	icon_state = "oyster"
	tastes = list("ostryga" = 1)
	meat_type = /obj/item/food/shellfish_meat/oyster

/obj/item/food/shellfish_meat/oyster
	name = "surowa ostryga"
	desc = "Smaczna ostryga, gotowa do użycia. Ma dość ostrą skorupę."
	icon_state = "oyster_open"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 4)
	tastes = list("ostryga" = 1)

/*
	Omułki (Bay: mussel)
*/
/datum/plant_feature/fruit/shellfish/mussel
	species_name = "mytilus edulis"
	name = "omułki"
	icon_state = "mussel"
	seed_icon_state = "seed-mussel"
	fruit_product = /obj/item/food/grown/shellfish/mussel
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/mussel
	name = "larwy: omułki (woda)"
	name_override = "omułki"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-mussel"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/mussel)

/obj/item/food/grown/shellfish/mussel
	seed = /obj/item/plant_seeds/preset/mussel
	name = "omułek"
	desc = "Świeży omułek. Przed jedzeniem trzeba go otworzyć nożem."
	icon_state = "mussel"
	tastes = list("omułek" = 1)
	meat_type = /obj/item/food/shellfish_meat/mussel

/obj/item/food/shellfish_meat/mussel
	name = "surowy omułek"
	desc = "Smaczny omułek, gotowy do użycia. Pasuje do białego wina."
	icon_state = "mussel_open"
	tastes = list("omułek" = 1)

/*
	Krewetki (Bay: shrimp)
*/
/datum/plant_feature/fruit/shellfish/shrimp
	species_name = "penaeus vannamei"
	name = "krewetki"
	icon_state = "shrimp"
	seed_icon_state = "seed-shrimp"
	fruit_product = /obj/item/food/grown/shellfish/shrimp
	growth_time = PLANT_FRUIT_GROWTH_FAST

/obj/item/plant_seeds/preset/shrimp
	name = "larwy: krewetki (woda)"
	name_override = "krewetki"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-shrimp"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/shrimp)

/obj/item/food/grown/shellfish/shrimp
	seed = /obj/item/plant_seeds/preset/shrimp
	name = "krewetka"
	desc = "Świeża krewetka. Przed jedzeniem trzeba ją obrać nożem."
	icon_state = "shrimp"
	tastes = list("krewetka" = 1)
	meat_type = /obj/item/food/shellfish_meat/shrimp

/obj/item/food/shellfish_meat/shrimp
	name = "surowa krewetka"
	desc = "Smaczna krewetka, gotowa do użycia. Zjedzona w nadmiarze szkodzi."
	icon_state = "shrimp_meat"
	tastes = list("krewetka" = 1)

/*
	Kraby (Bay: crab) - plon to nasze surowe mięso kraba
*/
/datum/plant_feature/fruit/shellfish/crab
	species_name = "cancer pagurus"
	name = "kraby"
	icon_state = "crab"
	seed_icon_state = "seed-crab"
	fruit_product = /obj/item/food/meat/rawcrab
	total_volume = PLANT_FRUIT_VOLUME_MEDIUM
	growth_time = PLANT_FRUIT_GROWTH_SLOW
	fast_reagents = list(/datum/reagent/consumable/nutriment/protein = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/nutriment/fat = PLANT_REAGENT_SMALL)

/obj/item/plant_seeds/preset/crab
	name = "larwy: kraby (woda)"
	name_override = "kraby"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-crab"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/crab)

/*
	Pąkle (Nebula: barnacle) - tylko z planet, bez paczki w automacie
*/
/datum/plant_feature/fruit/shellfish/barnacle
	species_name = "semibalanus balanoides"
	name = "pąkle"
	icon_state = "barnacle"
	seed_icon_state = "seed-barnacle"
	fruit_product = /obj/item/food/grown/shellfish/barnacle
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	plant_traits = list(/datum/plant_trait/reagent/fruit/nutriment)

/obj/item/plant_seeds/preset/barnacle
	name = "larwy: pąkle (woda)"
	name_override = "pąkle"
	icon = 'aquila/icons/obj/hydroponics/ported_akwa_seeds.dmi'
	icon_state = "seed-barnacle"
	plant_features = list(/datum/plant_feature/roots/water, /datum/plant_feature/body/shoal, /datum/plant_feature/fruit/shellfish/barnacle)

/obj/item/food/grown/shellfish/barnacle
	seed = /obj/item/plant_seeds/preset/barnacle
	name = "pąkla"
	desc = "Przysadzista pąkla, jakimś cudem oderwana od podłoża. Przed jedzeniem trzeba ją rozłupać nożem."
	icon_state = "barnacle"
	tastes = list("pąkla" = 1)
	meat_type = /obj/item/food/shellfish_meat/barnacle

/obj/item/food/shellfish_meat/barnacle
	name = "surowa pąkla"
	desc = "Rozłupana pąkla z kawałkiem mięsa w środku."
	icon_state = "barnacle_open"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("pąkla" = 1)

/obj/machinery/vending/hydroseeds/Initialize(mapload)
	products[/obj/item/plant_seeds/preset/clam] = 3
	products[/obj/item/plant_seeds/preset/oyster] = 3
	products[/obj/item/plant_seeds/preset/mussel] = 3
	products[/obj/item/plant_seeds/preset/shrimp] = 3
	contraband[/obj/item/plant_seeds/preset/crab] = 2
	return ..()
