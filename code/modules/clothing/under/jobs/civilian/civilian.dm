//Alphabetical order of civilian jobs.

/obj/item/clothing/under/rank/civilian/bartender
	desc = "Przydałoby mu się trochę więcej polotu."
	name = "mundur barmana"
	icon_state = "barman"
	item_state = "bar_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/bartender/skirt
	name = "spódnica barmana"
	desc = "Przydałoby jej się trochę więcej polotu."
	icon_state = "barman_skirt"
	item_state = "bar_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/bartender/purple
	desc = "Ma mnóstwo polotu!"
	name = "fioletowa spódnica barmana"
	icon_state = "purplebartender"
	item_state = "purplebartender"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/chaplain
	desc = "Czarny kombinezon, często noszony przez osoby religijne."
	name = "kombinezon kapłana"
	icon_state = "chaplain"
	item_state = "bl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/chaplain/skirt
	name = "spódnica kapłana"
	desc = "Czarna spódnica, często noszona przez osoby religijne."
	icon_state = "chapblack_skirt"
	item_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/chef
	name = "strój kucharza"
	desc = "Strój, który dostają tylko najbardziej <b>hardkorowi</b> kucharze w kosmosie."
	icon_state = "chef"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/chef/skirt
	name = "spódnica kucharza"
	desc = "Spódnica, którą dostają tylko najbardziej <b>hardkorowi</b> kucharze w kosmosie."
	icon_state = "chef_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/altchef
	name = "czerwony strój kucharza"
	desc = "Bardziej efektowny strój kucharza, choć mniej praktyczny."
	icon_state = "altchef"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/head_of_personnel
	desc = "Kombinezon noszony przez kogoś na stanowisku starszego oficera."
	name = "kombinezon starszego oficera"
	icon_state = "hop"
	item_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt
	name = "spódnica starszego oficera"
	desc = "Spódnica noszona przez kogoś na stanowisku starszego oficera."
	icon_state = "hop_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/head_of_personnel/alt
	name = "morski kombinezon starszego oficera"
	desc = "Morski garnitur i żółty krawat. Zestaw budzący respekt, choć tandetny."
	icon_state = "teal_suit"
	item_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/alt/skirt
	name = "morska spódnica starszego oficera"
	desc = "Morska spódnica i żółty krawat. Zestaw budzący respekt, choć tandetny."
	icon_state = "teal_suit_skirt"
	item_state = "g_suit"
	can_adjust = FALSE
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/hydroponics
	desc = "Kombinezon chroniący przed drobnymi zagrożeniami ze strony roślin."
	name = "kombinezon botanika"
	icon_state = "hydroponics"
	item_state = "g_suit"
	permeability_coefficient = 0.5

/obj/item/clothing/under/rank/civilian/hydroponics/skirt
	name = "spódnica botanika"
	desc = "Spódnica chroniąca przed drobnymi zagrożeniami ze strony roślin."
	icon_state = "hydroponics_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/janitor
	desc = "Oficjalny mundur woźnego statku. Daje słabą ochronę przed zagrożeniami biologicznymi."
	name = "kombinezon woźnego"
	icon_state = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/civilian/janitor/skirt
	name = "spódnica woźnego"
	desc = "Oficjalna spódnica woźnego statku. Daje słabą ochronę przed zagrożeniami biologicznymi."
	icon_state = "janitor_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/janitor/maid
	name = "mundurek pokojówki"
	desc = "Prosty mundurek pokojówki do sprzątania."
	icon_state = "janimaid"
	item_state = "janimaid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer
	desc = "Szykowne ciuchy."
	name = "garnitur prawnika"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer/black
	name = "czarny garnitur prawnika"
	icon_state = "lawyer_black"
	item_state = "lawyer_black"

/obj/item/clothing/under/rank/civilian/lawyer/black/skirt
	name = "czarna garsonka prawnika"
	icon_state = "lawyer_black_skirt"
	item_state = "lawyer_black"
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/female
	name = "czarny damski garnitur"
	icon_state = "black_suit_fem"
	item_state = "bl_suit"

/obj/item/clothing/under/rank/civilian/lawyer/female/skirt
	name = "czarna damska garsonka"
	icon_state = "black_suit_fem_skirt"
	item_state = "bl_suit"
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/lawyer/red
	name = "czerwony garnitur prawnika"
	icon_state = "lawyer_red"
	item_state = "lawyer_red"

/obj/item/clothing/under/rank/civilian/lawyer/red/skirt
	name = "czerwona garsonka prawnika"
	icon_state = "lawyer_red_skirt"
	item_state = "lawyer_red"
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/blue
	name = "niebieski garnitur prawnika"
	icon_state = "lawyer_blue"
	item_state = "lawyer_blue"

/obj/item/clothing/under/rank/civilian/lawyer/blue/skirt
	name = "niebieska garsonka prawnika"
	icon_state = "lawyer_blue_skirt"
	item_state = "lawyer_blue"
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	name = "niebieskie spodnie"
	desc = "Wygodne, świeżo wyprasowane spodnie i równie elegancka koszula. Krawat i marynarka nie wchodzą w zestaw."
	icon_state = "blueslacks"
	item_state = "blueslacks"
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt
	name = "niebieska garsonka"
	desc = "Elegancka garsonka z krawatem."
	icon_state = "bluesuit_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit
	name = "fioletowy garnitur"
	icon_state = "lawyer_purp"
	item_state = "p_suit"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt
	name = "fioletowa garsonka"
	icon_state = "lawyer_purp_skirt"
	item_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
