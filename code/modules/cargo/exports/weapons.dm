// Weapon exports. Stun batons, disablers, etc.

/datum/export/weapon
	include_subtypes = FALSE

/datum/export/weapon/baton
	cost = 100
	message = "szt. – pałka ogłuszająca"
	export_types = list(/obj/item/melee/baton)
	exclude_types = list(/obj/item/melee/baton/cattleprod)
	include_subtypes = TRUE

/datum/export/weapon/knife
	cost = 100
	message = "szt. – nóż bojowy"
	export_types = list(/obj/item/kitchen/knife/combat)


/datum/export/weapon/taser
	cost = 200
	message = "szt. – zaawansowany paralizator"
	export_types = list(/obj/item/gun/energy/e_gun/advtaser)

/datum/export/weapon/laser
	cost = 200
	message = "szt. – karabin laserowy"
	export_types = list(/obj/item/gun/energy/laser)

/datum/export/weapon/disabler
	cost = 100
	message = "szt. – disabler"
	export_types = list(/obj/item/gun/energy/disabler)

/datum/export/weapon/energy_gun
	cost = 300
	message = "szt. – broń energetyczna"
	export_types = list(/obj/item/gun/energy/e_gun)

/datum/export/weapon/bow
	cost = 200
	message = "szt. – łuk"
	export_types = list(/obj/item/gun/ballistic/bow)
	include_subtypes = TRUE

/datum/export/weapon/wt550
	cost = 300
	message = "szt. – karabin automatyczny WT-550"
	export_types = list(/obj/item/gun/ballistic/automatic/wt550)

/datum/export/weapon/shotgun
	cost = 300
	message = "szt. – strzelba bojowa"
	export_types = list(/obj/item/gun/ballistic/shotgun/automatic/combat)


/datum/export/weapon/flashbang
	cost = 5
	message = "szt. – granat hukowo-błyskowy"
	export_types = list(/obj/item/grenade/flashbang)

/datum/export/weapon/teargas
	cost = 5
	message = "szt. – granat z gazem łzawiącym"
	export_types = list(/obj/item/grenade/chem_grenade/teargas)


/datum/export/weapon/flash
	cost = 5
	message = "szt. – ręczny flash"
	export_types = list(/obj/item/assembly/flash)
	include_subtypes = TRUE

/datum/export/weapon/handcuffs
	cost = 3
	message = "szt. – kajdanki"
	export_types = list(/obj/item/restraints/handcuffs)

/datum/export/weapon/arrows
	cost = 50
	message = "szt. – strzała"
	export_types = list(/obj/item/ammo_casing/caseless/arrow)
	include_subtypes = TRUE
