// .45 (M1911 & C20r)

/obj/item/projectile/bullet/c45
	name = "pocisk .45"
	damage = 30

// 4.6x30mm (Autorifles)

/obj/item/projectile/bullet/c46x30mm
	name = "pocisk 4.6x30mm"
	damage = 20

/obj/item/projectile/bullet/c46x30mm_ap
	name = "pocisk 4.6x30mm przeciwpancerny"
	damage = 15
	armour_penetration = 40

/obj/item/projectile/bullet/incendiary/c46x30mm
	name = "pocisk 4.6x30mm zapalający"
	damage = 10
	fire_stacks = 1

//Slightly worse disabler, but fully automatic
/obj/item/projectile/bullet/c46x30mm_rubber
	bleed_force = BLEED_SCRATCH
	name = "gumowy pocisk 4.6x30mm"
	damage_type = STAMINA
	flag = "stamina"
	damage = 20
