// Ambrosia - base type
/obj/item/food/grown/ambrosia
	seed = /obj/item/plant_seeds/preset/ambrosia
	name = "gałązka ambrozji"
	desc = "To jest roślina."
	icon_state = "ambrosiavulgaris"
	slot_flags = ITEM_SLOT_HEAD
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	tastes = list("ambrozja" = 1)

/obj/item/food/grown/ambrosia/vulgaris
	name = "ambrozja pospolita"
	desc = "Roślina zawierająca różne lecznicze substancje."
	wine_power = 30

// Ambrosia Deus
/obj/item/food/grown/ambrosia/deus
	name = "ambrozja boska"
	desc = "Po zjedzeniu czujesz się nieśmiertelny!"
	icon_state = "ambrosiadeus"
	wine_power = 50
	discovery_points = 300

//Ambrosia Gaia
/obj/item/food/grown/ambrosia/gaia
	name = "ambrozja Gai"
	desc = "Po zjedzeniu <i>stajesz się</i> nieśmiertelny."
	icon_state = "ambrosia_gaia"
	light_system = MOVABLE_LIGHT
	light_range = 3
	wine_power = 70
	wine_flavor = "błogosławieństwo Matki Ziemi"
	discovery_points = 300
