// Port Monkestation (monkestation/code/modules/visual_changes/explosions.dm): eksplozje z cząsteczkami
// (fala dymu, kłęby, wyrzucony gruz, iskry, słup ziemi) i nowym, dłuższym sprite'em wybuchu.
//
// Różnice względem Monke (wydajność, bo NSV13 ma walkę statków i dużo trafień w kadłub):
// * stare wywołania new /obj/effect/temp_visual/explosion(turf) bez promienia dalej dają starą animację bez cząsteczek;
// * GLOB.explosion_particles_enabled wyłącza całość (SSexplosions wraca wtedy do stanu sprzed portu);
// * naraz trwa najwyżej GLOB.explosion_particles_max eksplozji z cząsteczkami, nadmiarowe mają tylko stary sprite;
// * mniej cząsteczek w najgęstszych emiterach i krótszy zasięg światła;
// * iskry z generic_particles ("spark"), bo stanu "flare" z 64x64.dmi nie ma nawet w Monke.

/// Czy eksplozje z SSexplosions dostają efekt z cząsteczkami. Admin może przełączyć przez VV.
GLOBAL_VAR_INIT(explosion_particles_enabled, TRUE)
/// Ile eksplozji z cząsteczkami może trwać naraz
GLOBAL_VAR_INIT(explosion_particles_max, 6)
/// Ile eksplozji z cząsteczkami trwa teraz
GLOBAL_VAR_INIT(explosion_particles_active, 0)
/// Górna granica zasięgu światła błysku (w Monke = promień wybuchu, czyli nawet 14 kratek przez 2,5 s)
#define EXPLOSION_PARTICLES_MAX_LIGHT 5

/particles/explosion_smoke
	icon = 'aquila/icons/effects/explosion_particles.dmi'
	icon_state = "smoke3"
	width = 1000
	height = 1000
	count = 50 // Monke: 75
	spawning = 50
	gradient = list("#FA9632", "#C3630C", "#333333", "#808080", "#FFFFFF")
	lifespan = 20
	fade = 60
	color = generator("num", 0, 0.25)
	color_change = generator("num", 0.04, 0.05)
	velocity = generator("circle", 15, 15)
	drift = generator("circle", 0, 1, NORMAL_RAND)
	spin = generator("num", -20, 20)
	friction = generator("num", 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.25
	grow = 0.05

/particles/explosion_smoke/deva
	scale = 0.5
	velocity = generator("circle", 23, 23)

/particles/explosion_smoke/small
	count = 25
	spawning = 25
	scale = 0.25
	velocity = generator("circle", 10, 10)

/particles/explosion_water
	icon = 'aquila/icons/effects/explosion_particles.dmi'
	icon_state = list("smoke4" = 1, "smoke5" = 1)
	width = 1000
	height = 1000
	count = 50 // Monke: 75
	spawning = 50
	lifespan = 20
	fade = 80
	velocity = generator("circle", 15, 15)
	drift = generator("circle", 0, 1, NORMAL_RAND)
	spin = generator("num", -20, 20)
	friction = generator("num", 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.15
	grow = 0.02

/particles/smoke_wave
	icon = 'aquila/icons/effects/explosion_particles.dmi'
	icon_state = "smoke3"
	width = 750
	height = 750
	count = 50 // Monke: 75
	spawning = 50
	lifespan = 15
	fade = 70
	gradient = list("#BA9F6D", "#808080", "#FFFFFF")
	color = generator("num", 0, 0.25)
	color_change = generator("num", 0.08, 0.07)
	velocity = generator("circle", 25, 25)
	rotation = generator("num", -45, 45)
	scale = 0.25
	grow = 0.05
	friction = 0.05

/particles/smoke_wave/small
	count = 30 // Monke: 45
	spawning = 30
	scale = 0.1

/particles/wave_water
	icon = 'aquila/icons/effects/explosion_particles.dmi'
	icon_state = "smoke5"
	width = 750
	height = 750
	count = 50 // Monke: 75
	spawning = 50
	lifespan = 15
	fade = 25
	color_change = generator("num", 0.08, 0.07)
	velocity = generator("circle", 25, 25)
	rotation = generator("num", -45, 45)
	scale = 0.45
	grow = 0.05
	friction = 0.05

/particles/dirt_kickup
	icon = 'aquila/icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 80
	spawning = 10
	lifespan = 15
	fade = 10
	fadein = 3
	scale = generator("num", 0.18, 0.15)
	position = generator("sphere", 150, 150)
	color = COLOR_BROWN
	velocity = list(0, 12)
	grow = list(0, 0.01)
	gravity = list(0, -1.25)

/particles/water_splash
	icon = 'aquila/icons/effects/96x157.dmi'
	icon_state = "smoke2"
	width = 500
	height = 500
	count = 80
	spawning = 10
	lifespan = 15
	fade = 10
	fadein = 3
	scale = generator("num", 0.18, 0.15)
	position = generator("sphere", 150, 150)
	velocity = list(0, 12)
	grow = list(0, 0.01)
	gravity = list(0, -1.25)

/particles/dirt_kickup_large
	icon = 'aquila/icons/effects/96x157.dmi'
	icon_state = "smoke"
	width = 750
	height = 750
	gradient = list("#FA9632", "#C3630C", "#333333", "#808080", "#FFFFFF")
	count = 3
	spawning = 3
	lifespan = 20
	fade = 10
	fadein = 3
	scale = generator("num", 0.5, 1)
	position = generator("box", list(-12, 32), list(12, 48), NORMAL_RAND)
	color = generator("num", 0, 0.25)
	color_change = generator("num", 0.04, 0.05)
	velocity = list(0, 12)
	grow = list(0, 0.025)
	gravity = list(0, -1)

/particles/dirt_kickup_large/deva
	velocity = list(0, 25)
	scale = generator("num", 1, 1.25)
	grow = list(0, 0.03)
	gravity = list(0, -2)
	fade = 10

/particles/water_splash_large
	icon = 'aquila/icons/effects/96x157.dmi'
	icon_state = "smoke2"
	width = 750
	height = 750
	count = 3
	spawning = 3
	lifespan = 20
	fade = 10
	fadein = 3
	scale = generator("num", 1, 1.25)
	position = generator("box", list(-12, 32), list(12, 48), NORMAL_RAND)
	velocity = list(0, 12)
	grow = list(0, 0.05)
	gravity = list(0, -1)

/particles/falling_debris
	icon = 'aquila/icons/effects/particles/debris.dmi'
	icon_state = "rock"
	width = 750
	height = 750
	count = 40 // Monke: 75
	spawning = 40
	lifespan = 20
	fade = 5
	position = generator("sphere", 16, 16)
	color = COLOR_DARK_BROWN
	velocity = list(0, 26)
	scale = generator("num", 1, 2)
	gravity = list(0, -3)
	friction = 0.02
	drift = generator("circle", 0, 1.5)

/particles/falling_debris/small
	count = 25 // Monke: 40
	spawning = 25

/particles/water_falling
	icon = 'aquila/icons/effects/particles/debris.dmi'
	icon_state = "cross"
	width = 750
	height = 750
	count = 40 // Monke: 75
	spawning = 40
	lifespan = 20
	fade = 5
	position = generator("sphere", 16, 16)
	velocity = list(0, 26)
	scale = generator("num", 1, 2)
	gravity = list(0, -3)
	friction = 0.02
	drift = generator("circle", 0, 1.5)

/particles/sparks_outwards
	icon = 'aquila/icons/effects/particles/debris.dmi'
	icon_state = "spark" // Monke: 64x64.dmi "flare", którego stanu nie ma
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 15
	fade = 15
	position = generator("sphere", 8, 8)
	velocity = generator("circle", 30, 30)
	scale = 1
	friction = 0.1

/particles/water_outwards
	icon = 'aquila/icons/effects/particles/debris.dmi'
	icon_state = "cross"
	width = 750
	height = 750
	count = 40
	spawning = 20
	lifespan = 15
	fade = 15
	position = generator("sphere", 8, 8)
	velocity = generator("circle", 30, 30)
	scale = 1.25
	friction = 0.1

/**
 * Efekt wybuchu dla SSexplosions (hook w code/controllers/subsystem/explosion.dm).
 * Wyłączony przełącznikiem nie robi nic, czyli tak jak przed portem.
 */
/proc/explosion_particles_visual(turf/epicenter, max_range, devastation_range, heavy_impact_range, light_impact_range)
	if(!GLOB.explosion_particles_enabled || !epicenter)
		return
	if(devastation_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, COLOR_WHITE, FALSE, TRUE)
	else if(heavy_impact_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, COLOR_WHITE, FALSE, FALSE)
	else if(light_impact_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, COLOR_WHITE, TRUE, FALSE)

/obj/effect/temp_visual/explosion
	/// Czy ta eksplozja zajmuje miejsce w limicie GLOB.explosion_particles_max
	var/has_particles = FALSE
	/// Nośniki cząsteczek: fala dymu, kłęby, słup ziemi, gruz, iskry, duży słup
	var/obj/effect/abstract/particle_holder/smoke_wave
	var/obj/effect/abstract/particle_holder/explosion_smoke
	var/obj/effect/abstract/particle_holder/dirt_kickup
	var/obj/effect/abstract/particle_holder/falling_debris
	var/obj/effect/abstract/particle_holder/sparks
	var/obj/effect/abstract/particle_holder/large_kickup

/**
 * radius - promień wybuchu; bez niego (stare wywołania) zostaje dawna animacja bez cząsteczek
 * color - kolor błysku światła
 * small, large - mniejszy (light) lub większy (devastation) zestaw cząsteczek
 */
/obj/effect/temp_visual/explosion/Initialize(mapload, radius, color, small = FALSE, large = FALSE)
	if(isnull(radius) || type != /obj/effect/temp_visual/explosion || !can_spawn_explosion_particles())
		return ..()
	// Czas trwania musi być ustawiony przed ..(), bo tam startuje QDEL_IN
	has_particles = TRUE
	GLOB.explosion_particles_active++
	duration = 25
	pixel_x = 0
	pixel_y = -32
	. = ..()
	set_light(min(radius, EXPLOSION_PARTICLES_MAX_LIGHT), min(radius, EXPLOSION_PARTICLES_MAX_LIGHT), color)
	var/is_water = istype(get_turf(src), /turf/open/water)
	generate_particles(radius, small, large, is_water)
	icon_state = null
	if(is_water)
		return
	// Sprite jako overlay, żeby obracał się sam wybuch, a nie cząsteczki
	var/image/boom = image('aquila/icons/effects/explosion_particles.dmi', icon_state = "explosion", layer = layer + 0.2)
	boom.pixel_x = -32
	var/matrix/rotate = matrix()
	rotate.Turn(rand(0, 359))
	boom.transform = rotate
	overlays += boom

/obj/effect/temp_visual/explosion/Destroy()
	if(has_particles)
		has_particles = FALSE
		GLOB.explosion_particles_active = max(GLOB.explosion_particles_active - 1, 0)
	QDEL_NULL(smoke_wave)
	QDEL_NULL(explosion_smoke)
	QDEL_NULL(sparks)
	QDEL_NULL(large_kickup)
	QDEL_NULL(falling_debris)
	QDEL_NULL(dirt_kickup)
	return ..()

/// Czy można teraz zacząć nową eksplozję z cząsteczkami (przełącznik + limit)
/proc/can_spawn_explosion_particles()
	return GLOB.explosion_particles_enabled && GLOB.explosion_particles_active < GLOB.explosion_particles_max

/obj/effect/temp_visual/explosion/proc/generate_particles(radius, small = FALSE, large = FALSE, is_water = FALSE)
	if(is_water)
		smoke_wave = new(src, /particles/wave_water)
		explosion_smoke = new(src, /particles/explosion_water)
		dirt_kickup = new(src, /particles/water_splash)
		falling_debris = new(src, /particles/water_falling)
		sparks = new(src, /particles/water_outwards)
		large_kickup = new(src, /particles/water_splash_large)
	else
		smoke_wave = new(src, small ? /particles/smoke_wave/small : /particles/smoke_wave)
		if(large)
			explosion_smoke = new(src, /particles/explosion_smoke/deva)
		else if(small)
			explosion_smoke = new(src, /particles/explosion_smoke/small)
		else
			explosion_smoke = new(src, /particles/explosion_smoke)
		dirt_kickup = new(src, /particles/dirt_kickup)
		falling_debris = new(src, small ? /particles/falling_debris/small : /particles/falling_debris)
		sparks = new(src, /particles/sparks_outwards)
		large_kickup = new(src, large ? /particles/dirt_kickup_large/deva : /particles/dirt_kickup_large)

	if(large)
		smoke_wave.particles.velocity = generator("circle", 6 * radius, 6 * radius)
	else if(small)
		smoke_wave.particles.velocity = generator("circle", 3 * radius, 3 * radius)
	else
		smoke_wave.particles.velocity = generator("circle", 5 * radius, 5 * radius)
	explosion_smoke.layer = layer + 0.1
	sparks.particles.velocity = generator("circle", 8 * radius, 8 * radius)
	addtimer(CALLBACK(src, PROC_REF(set_count_short)), 5)
	addtimer(CALLBACK(src, PROC_REF(set_count_long)), 10)

/// Po 0,5 s przestajemy dosypywać cząsteczek (te w powietrzu dogasają same)
/obj/effect/temp_visual/explosion/proc/set_count_short()
	for(var/obj/effect/abstract/particle_holder/holder as anything in list(smoke_wave, explosion_smoke, sparks, large_kickup, falling_debris))
		holder?.particles?.spawning = 0

/obj/effect/temp_visual/explosion/proc/set_count_long()
	dirt_kickup?.particles?.spawning = 0

#undef EXPLOSION_PARTICLES_MAX_LIGHT
