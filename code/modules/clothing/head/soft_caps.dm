/obj/item/clothing/head/soft
	name = "biała czapka"
	desc = "Czapka bejsbolówka w bezgustownym białym kolorze."
	icon_state = "mimesoft"

	///Is the hat flipped?
	var/flipped = FALSE
	///The color of the hat. Another knockoff item_color. Nice. Make this into GAGS sprites at some point, please.
	var/soft_color = "mime"

/obj/item/clothing/head/soft/AltClick(mob/user)
	..()
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		flip(user)

/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(!user.incapacitated())
		flipped = !flipped
		if(flipped)
			icon_state = "[soft_color]soft_flipped"
			to_chat(user, "<span class='notice'>Odwracasz czapkę daszkiem do tyłu.</span>")
		else
			icon_state = "[soft_color]soft"
			to_chat(user, "<span class='notice'>Odwracasz czapkę z powrotem do normalnej pozycji.</span>")
		user.update_inv_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-klik na czapkę, by obrócić ją daszkiem [flipped ? "do przodu" : "do tyłu"].</span>"

/obj/item/clothing/head/soft/red
	name = "czerwona czapka"
	desc = "Czapka bejsbolówka w bezgustownym czerwonym kolorze."
	icon_state = "redsoft"
	soft_color = "red"

/obj/item/clothing/head/soft/blue
	name = "niebieska czapka"
	desc = "Czapka bejsbolówka w bezgustownym niebieskim kolorze."
	icon_state = "bluesoft"
	soft_color = "blue"

/obj/item/clothing/head/soft/green
	name = "zielona czapka"
	desc = "Czapka bejsbolówka w bezgustownym zielonym kolorze."
	icon_state = "greensoft"
	soft_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "żółta czapka"
	desc = "Czapka bejsbolówka w bezgustownym żółtym kolorze."
	icon_state = "yellowsoft"
	soft_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "szara czapka"
	desc = "Czapka bejsbolówka w gustownym szarym kolorze."
	icon_state = "greysoft"
	soft_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "pomarańczowa czapka"
	desc = "Czapka bejsbolówka w bezgustownym pomarańczowym kolorze."
	icon_state = "orangesoft"
	soft_color = "orange"

/obj/item/clothing/head/soft/purple
	name = "fioletowa czapka"
	desc = "Czapka bejsbolówka w bezgustownym fioletowym kolorze."
	icon_state = "purplesoft"
	soft_color = "purple"

/obj/item/clothing/head/soft/black
	name = "czarna czapka"
	desc = "Czapka bejsbolówka w bezgustownym czarnym kolorze."
	icon_state = "blacksoft"
	soft_color = "black"

/obj/item/clothing/head/soft/rainbow
	name = "tęczowa czapka"
	desc = "Czapka bejsbolówka we wszystkich jaskrawych kolorach tęczy."
	icon_state = "rainbowsoft"
	soft_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "czapka policyjna"
	desc = "Solidna czapka bejsbolówka w gustownym czerwonym kolorze."
	icon_state = "secsoft"
	soft_color = "sec"
	armor = list("melee" = 30, "bullet" = 25, "laser" = 25, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50, "stamina" = 30, "bleed" = 10)
	strip_delay = 60

/obj/item/clothing/head/soft/sec/brig_physician
	name = "czapka lekarza więziennego"
	icon_state = "secmedsoft"
	soft_color = "secmed"

/obj/item/clothing/head/soft/paramedic
	name = "czapka ratownika medycznego"
	desc = "Ciemnoturkusowa czapka bejsbolówka z odblaskowym krzyżem na czubku."
	icon_state = "emtsoft"
	soft_color = "emt"

/obj/item/clothing/head/soft/cargo
	name = "czapka zaopatrzenia"
	desc = "Czapka bejsbolówka w bezgustownym żółtym kolorze."
	icon_state = "cargosoft"
	soft_color = "cargo"

	dog_fashion = /datum/dog_fashion/head/cargo_tech
