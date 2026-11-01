// 7.62x38mmR (Nagant Revolver)

/obj/item/projectile/bullet/n762
	name = "pocisk 7.62x38mmR"
	damage = 60

// .50AE (Desert Eagle)

/obj/item/projectile/bullet/a50AE
	name = "pocisk .50AE"
	damage = 60

// .38 (Detective's Gun)

/obj/item/projectile/bullet/c38
	name = "pocisk .38"
	damage = 25
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3

/obj/item/projectile/bullet/c38/match
	name = "pocisk .38 wyczynowy"
	ricochets_max = 4
	ricochet_chance = 100
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 5
	ricochet_incidence_leeway = 50
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1

/obj/item/projectile/bullet/c38/match/bouncy
	bleed_force = BLEED_SCRATCH
	name = "gumowy odbijający się pocisk .38"
	damage = 10
	stamina = 30
	armour_penetration = -30
	ricochets_max = 6
	ricochet_incidence_leeway = 70
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = NONE

/obj/item/projectile/bullet/c38/dumdum
	name = "pocisk .38 dum-dum"
	damage = 15
	armour_penetration = -30
	ricochets_max = 0
	shrapnel_type = /obj/item/shrapnel/bullet/c38/dumdum

/obj/item/projectile/bullet/c38/trac
	name = "pocisk .38 TRAC"
	damage = 10
	ricochets_max = 0

/obj/item/projectile/bullet/c38/trac/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/M = target
	if(!istype(M))
		return
	if(locate(/obj/item/implant/tracking/c38) in M.implants) //checks if the target already contains a tracking implant
		return

	var/obj/item/implant/tracking/c38/imp = new (M)
	imp.implant(M)

/obj/item/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = "pocisk .38 Hot Shot"
	damage = 20
	ricochets_max = 0

/obj/item/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(6)
		M.IgniteMob()

/obj/item/projectile/bullet/c38/iceblox //see /obj/item/projectile/temp for the original code
	name = "pocisk .38 Iceblox"
	damage = 20
	var/temperature = 100
	ricochets_max = 0

/obj/item/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

/obj/item/projectile/bullet/c38/mime
	bleed_force = 0
	name = "niewidzialny pocisk .38"
	icon_state = null
	damage = 0
	nodamage = TRUE
	martial_arts_no_deflect = TRUE

/obj/item/projectile/bullet/c38/mime/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/carbon/human/M = target
		if(M.job == JOB_NAME_MIME)
			var/defense = M.getarmor(CHEST, "bullet")
			M.apply_damage(5, BRUTE, CHEST, defense)
			M.visible_message("<span class='danger'>Na klatce piersiowej [M] pojawia się rana postrzałowa!</span>", \
							"<span class='userdanger'>Trafia cię kula .38 z palca-pistoletu! Ale to boli!...</span>")
		else
			to_chat(M, "<span class='userdanger'>Trafia cię strzał z palca-pistoletu!</span>")

/obj/item/projectile/bullet/c38/mime_lethal
	name = "niewidzialny pocisk .38"
	icon_state = null
	damage = 20

/obj/item/projectile/bullet/c38/mime_lethal/on_hit(atom/target, blocked)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)
// .357 (Syndie Revolver)

/obj/item/projectile/bullet/a357
	name = "pocisk .357"
	damage = 60

// admin only really, for ocelot memes
/obj/item/projectile/bullet/a357/match
	name = "pocisk .357 wyczynowy"
	ricochets_max = 5
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1
