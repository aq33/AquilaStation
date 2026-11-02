//*******************Contains everything related to the flora on lavaland.*******************************
//This includes: The structures, their produce, their seeds and the crafting recipe for the mushroom bowl

/obj/structure/flora/ash
	name = "duże grzyby"
	desc = "Kilka dużych grzybów pokrytych cienką warstwą popiołu i czegoś, co może być tylko zarodnikami."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "l_mushroom1"
	base_icon_state = "l_mushroom"
	// What kinda of flora does this helper plant
	var/obj/item/plant_seeds/seed_type = /obj/item/plant_seeds/preset/inocybe

/obj/structure/flora/ash/Initialize(mapload)
	. = ..()
// Setup our visuals
	base_icon_state = "[base_icon_state][rand(1, 4)]"
	icon_state = base_icon_state
// Make ourselves a real plant
	seed_type = new seed_type(src)
	var/datum/component/plant/plant_component = AddComponent(/datum/component/plant, src, seed_type.plant_features, _use_body_appearance = FALSE)
	// Add some bonus traits to it
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		// Remove possible duplicates - kind of a fucked up way of doing it tbh
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			if(trait.allow_multiple)
				continue
			// Essentially just remove ourselves from the pool of possible random traits - Don't worry, this gets refilled!
			if(!SSbotany.unused_random_traits["[feature.trait_type_shortcut]"]) //For nectar, and any other weirdo future traits
				continue
			SSbotany.unused_random_traits["[feature.trait_type_shortcut]"] -= trait.type
		var/datum/plant_trait/trait = SSbotany.get_random_trait("[feature.trait_type_shortcut]")
		trait = new trait(feature)
		if(!QDELING(trait))
			feature.plant_traits += trait
	// Update species ID to reflect new traits
	plant_component.compile_species_id()


/obj/structure/flora/ash/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/datum/component/plant/plant_component = GetComponent(/datum/component/plant)
	if(!plant_component)
		return
	var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_component.plant_features
	if(!length(fruit_feature?.fruits))
		to_chat(user, span_warning("[src] nie nadaje się jeszcze do zbioru!"))

/obj/structure/flora/ash/tall_shroom //exists only so that the spawning check doesn't allow these spawning near other things - Joan Lung. Circa 2016 Sept 9th

/obj/structure/flora/ash/leaf_shroom
	name = "liściaste grzyby"
	desc = "Kilka grzybów, z których każdy otacza zielonkawy zarodnik liściopodobnymi strukturami."
	icon_state = "s_mushroom1"
	base_icon_state = "s_mushroom"
	seed_type = /obj/item/plant_seeds/preset/porcini

/obj/structure/flora/ash/cap_shroom
	name = "wysokie grzyby"
	desc = "Kilka grzybów; większe mają w połowie trzonów pierścień hub."
	icon_state = "r_mushroom1"
	base_icon_state = "r_mushroom"
	seed_type = /obj/item/plant_seeds/preset/inocybe

/obj/structure/flora/ash/stem_shroom
	name = "liczne grzyby"
	desc = "Mnóstwo grzybów, niektóre z długimi, mięsistymi trzonami. Świecą!"
	icon_state = "t_mushroom1"
	base_icon_state = "t_mushroom"
	seed_type = /obj/item/plant_seeds/preset/embershroom


/obj/structure/flora/ash/cacti
	name = "owocujące kaktusy"
	desc = "Kilka kłujących kaktusów pełnych dojrzałych owoców i pokrytych cienką warstwą popiołu."
	icon_state = "cactus1"
	base_icon_state = "cactus"
	seed_type = /obj/item/plant_seeds/preset/cactus

/obj/structure/flora/ash/cacti/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 3, max_damage = 6, probability = 70)

//SNACKS

/obj/item/food/grown/ash_flora
	name = "wiórki grzybowe"
	desc = "Wiórki z wysokiego grzyba. Z odpowiedniej ilości można zrobić miskę."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_shavings"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 100
	seed = /obj/item/plant_seeds/preset/polypore
	wine_power = 20

/obj/item/food/grown/ash_flora/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4, 4)
	pixel_y = rand(-4, 4)

/obj/item/food/grown/ash_flora/shavings //So we can't craft bowls from everything.

/obj/item/food/grown/ash_flora/mushroom_leaf
	name = "liść grzyba"
	desc = "Liść, z grzyba."
	icon_state = "mushroom_leaf"
	seed = /obj/item/plant_seeds/preset/porcini
	wine_power = 40

/obj/item/food/grown/ash_flora/mushroom_cap
	name = "kapelusz grzyba"
	desc = "Kapelusz dużego grzyba."
	icon_state = "mushroom_cap"
	seed = /obj/item/plant_seeds/preset/inocybe
	wine_power = 70

/obj/item/food/grown/ash_flora/mushroom_stem
	name = "trzon grzyba"
	desc = "Długi trzon grzyba. Lekko świeci."
	icon_state = "mushroom_stem"
	seed = /obj/item/plant_seeds/preset/embershroom
	wine_power = 60

/obj/item/food/grown/ash_flora/cactus_fruit
	name = "owoc kaktusa"
	desc = "Owoc kaktusa pokryty grubą, czerwonawą skórką. I trochę popiołu."
	icon_state = "cactus_fruit"
	seed = /obj/item/plant_seeds/preset/cactus
	wine_power = 50

//CRAFTING

/datum/crafting_recipe/mushroom_bowl
	name = "Miska z grzybów"
	result = /obj/item/reagent_containers/glass/bowl/mushroom_bowl
	reqs = list(/obj/item/food/grown/ash_flora/shavings = 5)
	time = 30
	category = CAT_PRIMAL

/obj/item/reagent_containers/glass/bowl/mushroom_bowl
	name = "miska z grzybów"
	desc = "Miska zrobiona z grzybów. To nie jedzenie, choć kiedyś mogło w niej coś być."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"

/obj/item/reagent_containers/glass/bowl/mushroom_bowl/update_icon()
	cut_overlays()
	if(reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/lavaland/ash_flora.dmi', "fullbowl")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	else
		icon_state = "mushroom_bowl"
