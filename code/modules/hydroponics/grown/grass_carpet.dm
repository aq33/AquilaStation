/obj/item/food/grown/grass
	seed = /obj/item/plant_seeds/preset/grass
	name = "trawa"
	desc = "Zielona i bujna."
	icon_state = "grassclump"
	bite_consumption_mod = 0.5 // Grazing on grass
	var/stacktype = /obj/item/stack/tile/grass
	var/tile_coefficient = 0.02 // 1/50
	wine_power = 15

/obj/item/food/grown/grass/attack_self(mob/user)
	to_chat(user, "<span class='notice'>Przygotowujesz sztuczną trawę.</span>")
	var/potency = get_fruit_trait_power(src) * 50
	var/grassAmt = 1 + round(potency * tile_coefficient) // The grass we're holding
	for(var/obj/item/food/grown/grass/G in user.loc) // The grass on the floor
		if(G.type != type)
			continue
		grassAmt += 1 + round(potency * tile_coefficient)
		qdel(G)
	new stacktype(user.drop_location(), grassAmt)
	qdel(src)

//Fairygrass
/obj/item/food/grown/grass/fairy
	name = "trawa wróżek"
	desc = "Świeci i lekko pachnie grzybami."
	icon_state = "fairygrassclump"
	bite_consumption_mod = 1
	stacktype = /obj/item/stack/tile/fairygrass
	discovery_points = 300

/obj/item/food/grown/grass/fairy/attack_self(mob/user)
	var/list/genes = list()
	SEND_SIGNAL(src, COMSIG_PLANT_GET_GENES, genes)
	genes = genes[PLANT_GENE_INDEX_FEATURES]
	if(!length(genes))
		return ..()
	var/datum/plant_trait/fruit/biolight/light = locate(/datum/plant_trait/fruit/biolight) in genes
	if(!light)
		return ..()
	switch(light.type)
		if(/datum/plant_trait/fruit/biolight/yellow)
			stacktype = /obj/item/stack/tile/fairygrass/yellow
		if(/datum/plant_trait/fruit/biolight/white)
			stacktype = /obj/item/stack/tile/fairygrass/white
		if(/datum/plant_trait/fruit/biolight/red)
			stacktype = /obj/item/stack/tile/fairygrass/red
		if(/datum/plant_trait/fruit/biolight/green)
			stacktype = /obj/item/stack/tile/fairygrass/green
		if(/datum/plant_trait/fruit/biolight/blue)
			stacktype = /obj/item/stack/tile/fairygrass/blue
		if(/datum/plant_trait/fruit/biolight/purple)
			stacktype = /obj/item/stack/tile/fairygrass/purple
		if(/datum/plant_trait/fruit/biolight/pink)
			stacktype = /obj/item/stack/tile/fairygrass/pink
		if(/datum/plant_trait/fruit/biolight/dark)
			stacktype = /obj/item/stack/tile/fairygrass/dark
		else
			stacktype = initial(stacktype)
	return ..()

// Carpet
/obj/item/food/grown/grass/carpet
	name = "dywan"
	desc = "Mroczny sekret przemysłu tekstylnego."
	icon_state = "carpetclump"
	stacktype = /obj/item/stack/tile/carpet
	can_distill = FALSE

/obj/item/food/grown/grass/shamrock/Initialize(mapload)
	. = ..()
	if(prob(0.001)) // 0.001% chance to be a clover
		name = "czterolistna koniczyna"
		desc = "Rzadki, poszukiwany drobiazg, który podobno przynosi szczęście właścicielowi."
		icon_state = "clover"
