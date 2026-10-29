
/obj/item/clothing/under/rank/civilian/mime
	name = "strój mima"
	desc = "Niezbyt kolorowy."
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "spódnica mima"
	icon_state = "mime_skirt"
	item_state = "mime"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON


/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "spódnica mima"
	icon_state = "mime_skirt"
	item_state = "mime"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP


/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "seksowny strój mima"
	desc = "Jedyny raz, kiedy NIE cieszy cię widok czyjegoś biustu."
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = CHEST|GROIN|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown
	name = "strój klauna"
	desc = "<i>„HONK!”</i>"
	icon_state = "clown"
	item_state = "clown"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/blue
	name = "niebieski strój klauna"
	desc = "<i>„NIEBIESKI HONK!”</i>"
	icon_state = "blueclown"
	item_state = "blueclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/green
	name = "zielony strój klauna"
	desc = "<i>„ZIELONY HONK!”</i>"
	icon_state = "greenclown"
	item_state = "greenclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/yellow
	name = "żółty strój klauna"
	desc = "<i>„ŻÓŁTY HONK!”</i>"
	icon_state = "yellowclown"
	item_state = "yellowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/purple
	name = "fioletowy strój klauna"
	desc = "<i>„FIOLETOWY HONK!”</i>"
	icon_state = "purpleclown"
	item_state = "purpleclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/orange
	name = "pomarańczowy strój klauna"
	desc = "<i>„POMARAŃCZOWY HONK!”</i>"
	icon_state = "orangeclown"
	item_state = "orangeclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/rainbow
	name = "tęczowy strój klauna"
	desc = "<i>„T Ę C Z O W Y HONK!”</i>"
	icon_state = "rainbowclown"
	item_state = "rainbowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/jester
	name = "strój błazna"
	desc = "Wesoły strój, w sam raz, by zabawiać swego pana, wujaszku."
	icon_state = "jester"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/jester/alt
	icon_state = "jester2"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "seksowny strój klauna"
	desc = "Wyglądasz w nim na kogoś do HONKnięcia!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
