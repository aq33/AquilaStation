// Port Monkestation (gun_smoke.dm + fragment code/modules/projectiles/gun.dm): dymek z lufy broni palnej.
// W Monke to flaga GUN_SMOKE_PARTICLES w gun_flags; u nas osobna zmienna, bo gun_flags nie mamy.
// Dym liczy się do tego samego limitu co odłamki z trafień (GLOB.impact_particles_max).

/particles/firing_smoke
	icon = 'aquila/icons/effects/explosion_particles.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 5
	spawning = 15
	lifespan = 0.5 SECONDS
	fade = 2.4 SECONDS
	grow = 0.12
	drift = generator("circle", 8, 8)
	scale = 0.1
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.3, 0.6)

/obj/item/gun
	/// Czy przy strzale z lufy leci dymek
	var/gun_smoke_particles = FALSE
	/// Ile dymu (zanieczyszczenia) zostaje na kafelku po strzale; 0 = broń bez prochu
	var/gun_smoke_pollution = 0

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	if(gun_smoke_particles)
		spawn_gun_smoke(user, pbtarget)
	if(gun_smoke_pollution)
		pollute_gun_smoke()

/// Dym prochowy zostaje w powietrzu jak dym z pożaru (aquila/code/modules/pollution/): seria w zamkniętym pomieszczeniu robi gęstą mgłę
/obj/item/gun/proc/pollute_gun_smoke()
	var/turf/open/gun_turf = get_turf(src)
	if(!istype(gun_turf) || gun_turf.planetary_atmos)
		return
	gun_turf.pollute_turf(/datum/pollutant/smoke, gun_smoke_pollution, POLLUTION_PASSIVE_EMITTER_CAP)

/obj/item/gun/proc/spawn_gun_smoke(mob/living/user, atom/target)
	var/turf/gun_turf = get_turf(src)
	if(!gun_turf || !can_spawn_impact_particles())
		return
	var/angle = target ? get_angle(user || gun_turf, target) : dir2angle(user?.dir || dir)
	var/obj/effect/abstract/particle_holder/gun_smoke = new(gun_turf, /particles/firing_smoke)
	gun_smoke.particles.velocity = list(sin(angle) * 40, cos(angle) * 40)
	GLOB.impact_particles_active++
	addtimer(CALLBACK(src, PROC_REF(stop_gun_smoke), gun_smoke, TRUE), 0.3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(stop_gun_smoke), gun_smoke, FALSE), 0.5 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_impact_particles), gun_smoke, null), 0.6 SECONDS)

/// Wygaszanie dymu jak w Monke: najpierw bez dryfu, potem bez nowych cząsteczek
/obj/item/gun/proc/stop_gun_smoke(obj/effect/abstract/particle_holder/gun_smoke, only_drift)
	if(QDELETED(gun_smoke) || !gun_smoke.particles)
		return
	if(only_drift)
		gun_smoke.particles.drift = 0
	else
		gun_smoke.particles.count = 0

// Te same typy co w Monke (bazowe klasy broni palnej i granatniki)
/obj/item/gun/ballistic/automatic
	gun_smoke_particles = TRUE

/obj/item/gun/ballistic/revolver/grenadelauncher
	gun_smoke_particles = TRUE

/obj/item/gun/ballistic/rocketlauncher
	gun_smoke_particles = TRUE

/obj/item/gun/ballistic/rifle
	gun_smoke_particles = TRUE

/obj/item/gun/ballistic/shotgun
	gun_smoke_particles = TRUE

// AQ: zabawki na piankę nie dymią (w Monke dziedziczyły po automatic)
/obj/item/gun/ballistic/automatic/toy
	gun_smoke_particles = FALSE

/obj/item/gun/ballistic/shotgun/toy
	gun_smoke_particles = FALSE

/obj/item/gun/ballistic/automatic/c20r/toy
	gun_smoke_particles = FALSE

/obj/item/gun/ballistic/automatic/l6_saw/toy
	gun_smoke_particles = FALSE

// Dym prochowy: cała broń palna, mocniej strzelby i wyrzutnie. Broń na piankę i łuki nie dymią.
/obj/item/gun/ballistic
	gun_smoke_pollution = 3

/obj/item/gun/ballistic/shotgun
	gun_smoke_pollution = 5

/obj/item/gun/ballistic/revolver/grenadelauncher
	gun_smoke_pollution = 10

/obj/item/gun/ballistic/rocketlauncher
	gun_smoke_pollution = 15

/obj/item/gun/ballistic/automatic/toy
	gun_smoke_pollution = 0

/obj/item/gun/ballistic/shotgun/toy
	gun_smoke_pollution = 0

/obj/item/gun/ballistic/bow
	gun_smoke_pollution = 0
