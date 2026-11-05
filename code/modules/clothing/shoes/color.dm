/obj/item/clothing/shoes/sneakers
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn

/obj/item/clothing/shoes/sneakers/black
	name = "czarne buty"
	desc = "Para czarnych butów."
	custom_price = 20
	greyscale_colors = "#545454#ffffff"

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brązowe buty"
	desc = "Para brązowych butów."
	greyscale_colors = "#814112#ffffff"

/obj/item/clothing/shoes/sneakers/blue
	name = "niebieskie buty"
	greyscale_colors = "#16a9eb#ffffff"

/obj/item/clothing/shoes/sneakers/green
	name = "zielone buty"
	greyscale_colors = "#54eb16#ffffff"

/obj/item/clothing/shoes/sneakers/yellow
	name = "żółte buty"
	greyscale_colors = "#ebe216#ffffff"

/obj/item/clothing/shoes/sneakers/purple
	name = "fioletowe buty"
	greyscale_colors = "#ad16eb#ffffff"

/obj/item/clothing/shoes/sneakers/red
	name = "czerwone buty"
	desc = "Stylowe czerwone buty."
	greyscale_colors = "#ff2626#ffffff"

/obj/item/clothing/shoes/sneakers/white
	name = "białe buty"
	greyscale_colors = "#ffffff#ffffff"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/sneakers/rainbow
	name = "tęczowe buty"
	desc = "Bardzo gejowskie buty."
	icon_state = "rain_bow"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/sneakers/orange
	name = "pomarańczowe buty"
	greyscale_colors = "#eb7016#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_config_worn = /datum/greyscale_config/sneakers_orange_worn

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs( user.loc )
		src.icon_state = ""
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	// Note: not using istype here because we want to ignore all subtypes
	if (!chained && H.type == /obj/item/restraints/handcuffs)
		qdel(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "sneakers_chained"
	return

/obj/item/clothing/shoes/sneakers/orange/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/hummie = user
		if(hummie.shoes == src && chained)
			to_chat(hummie, "<span class='warning'>Zaczynasz zdejmować [src]!</span>")
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/hummie = m
		if(hummie.shoes == src && chained)
			to_chat(hummie, "<span class='warning'>Zaczynasz zdejmować [src]!</span>")
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()
