#define AQUARIUM_COMPANY "Aquatech Ltd."

// Fish feed can
/obj/item/fish_feed
	name = "puszka karmy dla ryb"
	desc = "Sama wytwarza pożywną karmę dla ryb na podstawie próbki w środku."
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "fish_feed"
	w_class = WEIGHT_CLASS_TINY

/obj/item/fish_feed/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 1) //Default fish diet

// Stasis fish case container for moving fish between aquariums safely.
/obj/item/storage/fish_case
	name = "pojemnik stazy na ryby"
	desc = "Mały pojemnik, który utrzymuje rybę w środku w stazie."
	icon_state = "fishbox"

	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	component_type = /datum/component/storage/concrete/fish_case

/obj/item/storage/fish_case/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FISH_SAFE_STORAGE, TRAIT_GENERIC)

/// Fish case with single random fish inside.
/obj/item/storage/fish_case/random/PopulateContents()
	. = ..()
	generate_fish(src, select_fish_type())

/obj/item/storage/fish_case/random/proc/select_fish_type()
	return random_fish_type()

/obj/item/storage/fish_case/random/freshwater/select_fish_type()
	return random_fish_type(required_fluid=AQUARIUM_FLUID_FRESHWATER)

/// Book detailing where to get the fish and their properties.
/obj/item/book/fish_catalog
	name = "Encyklopedia ryb"
	desc = "Spis wszystkich ryb znanych ludzkości (i pokrewnym gatunkom)."
	icon_state = "fishbook"
	dat = "Mnóstwo rybich spraw" //book wrappers could use cleaning so this is not necessary

/obj/item/book/fish_catalog/on_read(mob/user)
	ui_interact(user)

/obj/item/book/fish_catalog/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishCatalog", name)
		ui.open()

/obj/item/book/fish_catalog/ui_static_data(mob/user)
	. = ..()
	var/static/fish_info
	if(!fish_info)
		fish_info = list()
		for(var/_fish_behaviour in subtypesof(/datum/aquarium_behaviour/fish))
			var/datum/aquarium_behaviour/fish/fish_behaviour = _fish_behaviour
			var/list/fish_data = list()
			if(!initial(fish_behaviour.show_in_catalog))
				continue
			fish_data["name"] = initial(fish_behaviour.name)
			fish_data["desc"] = initial(fish_behaviour.desc)
			fish_data["fluid"] = initial(fish_behaviour.required_fluid_type)
			fish_data["temp_min"] = initial(fish_behaviour.required_temperature_min)
			fish_data["temp_max"] = initial(fish_behaviour.required_temperature_max)
			fish_data["icon"] = sanitize_css_class_name("[initial(fish_behaviour.icon)][initial(fish_behaviour.icon_state)]")
			fish_data["color"] = initial(fish_behaviour.color)
			fish_data["source"] = initial(fish_behaviour.availible_in_random_cases) ? "Paczki ryb [AQUARIUM_COMPANY]" : "Nieznane"
			var/datum/reagent/food_type = initial(fish_behaviour.food)
			if(food_type != /datum/reagent/consumable/nutriment)
				fish_data["feed"] = initial(food_type.name)
			else
				fish_data["feed"] = "Karma dla ryb [AQUARIUM_COMPANY]"
			fish_info += list(fish_data)

	.["fish_info"] = fish_info
	.["sponsored_by"] = AQUARIUM_COMPANY

/obj/item/book/fish_catalog/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/fish)
	)

/obj/item/aquarium_kit
	name = "zestaw do samodzielnej budowy akwarium"
	desc = "Wszystko, czego potrzebujesz do zbudowania własnego akwarium. (Surowce sprzedawane osobno)"
	icon = 'icons/obj/aquarium.dmi'
	icon_state = "construction_kit"
	w_class = WEIGHT_CLASS_TINY

/obj/item/aquarium_kit/attack_self(mob/user)
	. = ..()
	to_chat(user,"<span class='notice'>W środku są instrukcje i narzędzia potrzebne do zbudowania akwarium. Wystarczy zacząć tworzyć.</span>")


/obj/item/aquarium_prop
	name = "zwykła dekoracja akwarium"
	desc = "bardzo nudna"
	w_class = WEIGHT_CLASS_TINY

/obj/item/storage/box/aquarium_props
	name = "pudełko dekoracji akwarium"
	desc = "Wszystko, czego potrzeba, żeby akwarium ładnie wyglądało."

/obj/item/storage/box/aquarium_props/PopulateContents()
	for(var/prop_type in subtypesof(/datum/aquarium_behaviour/prop))
		generate_fish(src, prop_type, /obj/item/aquarium_prop)

/obj/item/storage/box/fish_debug
	name = "pudełko pełne ryb"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/datum/aquarium_behaviour/fish))
		generate_fish(src,fish_type)

#undef AQUARIUM_COMPANY
