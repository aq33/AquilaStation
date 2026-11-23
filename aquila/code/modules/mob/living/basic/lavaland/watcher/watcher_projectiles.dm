// AQUILA: basilisk and watcher projectiles moved unchanged from code/modules/mob/living/simple_animal/hostile/mining_mobs/basilisk.dm
// (the simple animals became basic mobs); the crystal invasion event uses the frost blast too.

/obj/item/projectile/temp/basilisk
	name = "mroźny podmuch"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = "energy"
	temperature = 50

/obj/item/projectile/temp/basilisk/magmawing
	name = "palący podmuch"
	icon_state = "lava"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	temperature = 500 //Heats you up!

/obj/item/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if (istype(L))
			L.adjust_fire_stacks(0.1)
			L.IgniteMob()

/obj/item/projectile/temp/basilisk/icewing
	damage = 5
	damage_type = BURN
	nodamage = FALSE

/obj/item/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)
