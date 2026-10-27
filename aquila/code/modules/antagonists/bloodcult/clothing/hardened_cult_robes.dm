/obj/item/clothing/suit/hooded/cultrobes/hardened
	name = "\improper utwardzony pancerz Nar'Sie"
	desc = "Ciężko opancerzony egzoszkielet noszony przez wojowników kultu Nar'Sie. Wytrzymuje próżnię."
	icon = 'aquila/icons/bloodcult/worn/suit.dmi'
	worn_icon = 'aquila/icons/bloodcult/worn/suit.dmi'
	icon_state = "cultarmor"

	item_state = null
	w_class = WEIGHT_CLASS_BULKY
	allowed = list(/obj/item/tome, /obj/item/melee/cultblade, /obj/item/melee/soulblade, /obj/item/tank, /obj/item/tome, /obj/item/talisman, /obj/item/weapon/blood_tesseract)
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 60, "bomb" = 50, "bio" = 100, "rad" = 30, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 50)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/hardened
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	flags_inv = HIDEGLOVES | HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/suit/hooded/cultrobes/hardened/get_cult_power()
	return 60

/obj/item/clothing/suit/hooded/cultrobes/hardened/salt_act()
	acid_melt()

/obj/item/clothing/head/hooded/cult_hoodie/hardened
	name = "\improper utwardzony hełm Nar'Sie"
	desc = "Ciężko opancerzony hełm noszony przez wojowników kultu Nar'Sie. Wytrzymuje próżnię."
	icon_state = "culthelmet"
	icon = 'aquila/icons/bloodcult/worn/head.dmi'
	worn_icon = 'aquila/icons/bloodcult/worn/head.dmi'

	item_state = null
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 60, "bomb" = 50, "bio" = 100, "rad" = 30, "fire" = 100, "acid" = 100, "stamina" = 60, "bleed" = 50)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE
