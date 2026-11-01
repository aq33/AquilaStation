/obj/structure/closet/athletic_mixed
	name = "szafa na odzież sportową"
	desc = "Szafa na odzież sportową."
	icon_door = "mixed"

/obj/structure/closet/athletic_mixed/PopulateContents()
	..()
	new /obj/item/clothing/under/shorts/purple(src)
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)
	new /obj/item/clothing/under/costume/jabroni(src)


/obj/structure/closet/boxinggloves
	name = "rękawice bokserskie"
	desc = "Szafa na rękawice do używania na ringu bokserskim."

/obj/structure/closet/boxinggloves/PopulateContents()
	..()
	new /obj/item/clothing/gloves/boxing/blue(src)
	new /obj/item/clothing/gloves/boxing/green(src)
	new /obj/item/clothing/gloves/boxing/yellow(src)
	new /obj/item/clothing/gloves/boxing(src)


/obj/structure/closet/masks
	name = "szafa z maskami"
	desc = "TO SZAFA NA MASKI ZAPAŚNIKÓW, OLE!"

/obj/structure/closet/masks/PopulateContents()
	..()
	new /obj/item/clothing/mask/luchador(src)
	new /obj/item/clothing/mask/luchador/rudos(src)
	new /obj/item/clothing/mask/luchador/tecnicos(src)


/obj/structure/closet/lasertag/red
	name = "czerwony sprzęt do laser taga"
	desc = "Szafa na sprzęt do laser taga."
	icon_door = "red"

/obj/structure/closet/lasertag/red/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser/redtag(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/head/helmet/redtaghelm(src)


/obj/structure/closet/lasertag/blue
	name = "niebieski sprzęt do laser taga"
	desc = "Szafa na sprzęt do laser taga."
	icon_door = "blue"

/obj/structure/closet/lasertag/blue/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser/bluetag(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/head/helmet/bluetaghelm(src)
