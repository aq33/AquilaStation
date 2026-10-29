/obj/item/clothing/suit/hooded/cultrobes
	name = "starożytne szaty kultysty"
	desc = "Postrzępione, zakurzone szaty. Od środka wyścielają je dziwne litery."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade)
	armor = list("melee" = 40, "bullet" = 30, "laser" = 40, "energy" = 40, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 10, "acid" = 10, "stamina" = 40, "bleed" = 20)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie
	/// Whether the hood is flipped up (czytają to szaty heretyka, które dziedziczą po szatach kultu)
	var/hood_up = FALSE

/obj/item/clothing/head/hooded/cult_hoodie/alt
	name = "kaptur kultysty"
	desc = "Opancerzony kaptur noszony przez wyznawców Nar'Sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/hooded/cultrobes/alt
	name = "szaty kultysty"
	desc = "Opancerzone szaty noszone przez wyznawców Nar'Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/alt

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	item_flags = DROPDEL

/obj/item/clothing/suit/hooded/cultrobes/alt/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)
