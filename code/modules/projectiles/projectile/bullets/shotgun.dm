/obj/item/projectile/bullet/shotgun_slug
	name = "breneka 12g"
	damage = 60
	armour_penetration = -20

/obj/item/projectile/bullet/shotgun_beanbag
	bleed_force = BLEED_TINY
	name = "woreczek z nabojem"
	damage = 5
	stamina = 55
	paralyze = 10 //NSV13 - added paralyze

/obj/item/projectile/bullet/incendiary/shotgun
	name = "breneka zapalająca"
	damage = 20

/obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "śrucina smoczego oddechu"
	damage = 5

/obj/item/projectile/bullet/shotgun_stunslug
	name = "breneka ogłuszająca"
	damage = 5
	paralyze = 100
	stutter = 5
	jitter = 20
	range = 7
	icon_state = "spark"
	color = "#FFFF00"

/obj/item/projectile/bullet/shotgun_meteorslug
	name = "breneka meteorytowa"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 20
	paralyze = 20
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/item/projectile/bullet/shotgun_meteorslug/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovableatom(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 3, 2)

/obj/item/projectile/bullet/shotgun_meteorslug/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/item/projectile/bullet/shotgun_frag12
	name ="breneka FRAG-12"
	damage = 25
	paralyze = 10

/obj/item/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, -1, 0, 1)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/pellet
	bleed_force = BLEED_SCRATCH
	var/tile_dropoff = 0.75
	var/tile_dropoff_s = 0.5
	ricochets_max = 1
	ricochet_chance = 50
	ricochet_decay_chance = 0.9

/obj/item/projectile/bullet/pellet/shotgun_buckshot
	name = "śrucina"
	damage = 9
	tile_dropoff = 0.5

/obj/item/projectile/bullet/pellet/shotgun_rubbershot
	bleed_force = BLEED_TINY
	name = "gumowa śrucina"
	damage = 3
	stamina = 9

/obj/item/projectile/bullet/pellet/shotgun_incapacitate
	name = "obezwładniająca śrucina"
	damage = 1
	stamina = 5

/obj/item/projectile/bullet/pellet/Range()
	..()
	if(damage > 0)
		damage -= tile_dropoff
	if(stamina > 0)
		stamina -= tile_dropoff_s
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/item/projectile/bullet/pellet/shotgun_improvised
	tile_dropoff = 0.55		//Come on it does 6 damage don't be like that.
	damage = 6

/obj/item/projectile/bullet/pellet/shotgun_improvised/Initialize(mapload)
	. = ..()
	range = rand(1, 8)

/obj/item/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Mech Scattershot

/obj/item/projectile/bullet/scattershot
	bleed_force = BLEED_SURFACE
	damage = 18

//Breaching Ammo

/obj/item/projectile/bullet/shotgun_breaching
	bleed_force = BLEED_SURFACE
	name = "nabój wyważający 12g"
	desc = "Nabój wyważający, który kilkoma strzałami niszczy śluzy i okna, ale na inne cele nie działa."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 10 //does shit damage to everything except doors and windows

/obj/item/projectile/bullet/shotgun_breaching/on_hit(atom/target)
	if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille) || istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		damage = 500 //one shot to break a window or grille, or 3 shots to breach an airlock door
	..()
