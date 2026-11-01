/obj/item/ammo_casing/energy
	name = "soczewka broni energetycznej"
	desc = "Ta część broni, dzięki której laser robi „piu”."
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	heavy_metal = FALSE
