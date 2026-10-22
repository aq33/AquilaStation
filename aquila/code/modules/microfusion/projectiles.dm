/obj/item/ammo_casing/energy/laser/microfusion
	name = "soczewka energetyczna microfusion"
	projectile_type = /obj/item/projectile/beam/laser/microfusion
	e_cost = 100
	select_name = "laser"
	fire_sound = 'aquila/sound/microfusion/laser_1.ogg'
	///What volume should the sound play at?
	var/fire_sound_volume = 100

/obj/item/projectile/beam/laser/microfusion
	name = "laser microfusion"
	icon = 'aquila/icons/microfusion/projectiles.dmi'
	damage = 22

/obj/item/projectile/beam/laser/microfusion/superheated
	name = "przegrzany laser microfusion"
	icon_state = "laser_greyscale"
	damage = 20 //Trading damage for fire stacks
	color = LIGHT_COLOR_FIRE
	light_color = LIGHT_COLOR_FIRE

/obj/item/projectile/beam/laser/microfusion/superheated/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living = target
		living.adjust_fire_stacks(2)
		living.IgniteMob()

/obj/item/projectile/beam/laser/microfusion/hellfire
	name = "piekielny laser microfusion"
	icon_state = "laser_greyscale"
	damage = 20 // You are trading damage for speed
	speed = 0.6
	color = LIGHT_COLOR_FLARE
	light_color = LIGHT_COLOR_FLARE

// Monkestation divided the first pellet's damage by the pellet count, but the other pellets
// came out at full damage. Here every pellet carries its share of the base 22 damage.
/obj/item/projectile/beam/laser/microfusion/scatter
	name = "rozproszony laser microfusion"
	damage = 7.5

/obj/item/projectile/beam/laser/microfusion/scatter/max
	damage = 3.2

/obj/item/projectile/beam/laser/microfusion/repeater
	damage = 12.5

/obj/item/projectile/beam/laser/microfusion/penetrator
	name = "skupiony laser microfusion"
	damage = 20
	armour_penetration = 75

/obj/item/projectile/beam/laser/microfusion/lance
	name = "laser lancy microfusion"
	damage = 50 // We're turning the gun into a heavylaser
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	speed = 0.4

/obj/item/projectile/beam/laser/microfusion/xray
	name = "rentgenowski laser microfusion"
	icon_state = "laser_greyscale"
	color = COLOR_GREEN
	light_color = COLOR_GREEN
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

/obj/item/projectile/beam/laser/microfusion/honk
	name = "zabawny laser microfusion"
	icon_state = "laser_greyscale"
	color = COLOR_VIVID_YELLOW
	light_color = COLOR_VIVID_YELLOW
	damage_type = STAMINA
	damage = 22
	flag = "energy"
	hitsound = 'sound/misc/slip.ogg'
	impact_type = /obj/effect/projectile/impact/disabler

// Monkestation put a slippery component on the projectile. Ours only slips things that walk onto it,
// which a flying beam never meets, so the hit itself does the slipping.
/obj/item/projectile/beam/laser/microfusion/honk/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.slip(20, src)
