// Port Monkestation (monkestation/code/modules/visual_changes/debris.dm): odłamki i dymek przy trafieniu pociskiem.
// Różnica: w Monke to element /datum/element/debris dopinany w Initialize do każdej ściany i wielu obiektów
// (sygnał na każdym atomie). U nas trafienie obsługuje nadpisanie bullet_act wybranych typów
// (debris_additions.dm), więc ściany nie płacą nic przy ładowaniu mapy.

#define DEBRIS_SPARKS "spark"
#define DEBRIS_WOOD "wood"
#define DEBRIS_ROCK "rock"
#define DEBRIS_GLASS "glass"
#define DEBRIS_LEAF "leaf"
#define DEBRIS_SNOW "snow"

/// Czy trafienia pocisków i strzały robią cząsteczki (odłamki, dym z lufy). Admin może przełączyć przez VV.
GLOBAL_VAR_INIT(impact_particles_enabled, TRUE)
/// Ile efektów trafienia / dymu z lufy może trwać naraz; nadmiarowe trafienia są bez cząsteczek
GLOBAL_VAR_INIT(impact_particles_max, 30)
/// Ile efektów trafienia / dymu z lufy trwa teraz
GLOBAL_VAR_INIT(impact_particles_active, 0)

/particles/debris
	icon = 'aquila/icons/effects/particles/debris.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	drift = generator("circle", 0, 7)
	scale = 0.7
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.15)
	spin = generator("num", -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator("num", -20, 20)
	velocity = list(50, 0)
	friction = generator("num", 0.1, 0.5)

/// Czy można teraz zacząć nowy efekt trafienia (przełącznik + limit jednoczesnych efektów)
/proc/can_spawn_impact_particles()
	return GLOB.impact_particles_enabled && GLOB.impact_particles_active < GLOB.impact_particles_max

/**
 * Dymek i odłamki w miejscu trafienia pociskiem.
 *
 * * hit - trafiony atom (turf albo obiekt)
 * * P - pocisk
 * * debris - stan ikony odłamków (DEBRIS_*), null = sam dymek
 * * debris_velocity, debris_amount, debris_scale - jak w elemencie z Monke
 */
/proc/spawn_impact_debris(atom/hit, obj/item/projectile/P, debris, debris_velocity = -15, debris_amount = 8, debris_scale = 0.7)
	if(!hit || !P || !can_spawn_impact_particles())
		return
	var/turf/hit_turf = get_turf(hit)
	if(!hit_turf)
		return
	var/angle = isnull(P.Angle) ? round(get_angle(P.starting, hit), 1) : P.Angle
	var/x_component = sin(angle) * debris_velocity
	var/y_component = cos(angle) * debris_velocity
	var/x_component_smoke = sin(angle) * -15
	var/y_component_smoke = cos(angle) * -15
	var/position_offset = rand(-6, 6)
	// Obiekt w pojemniku albo mobie nie pokaże cząsteczek, wtedy wieszamy je na turfie
	var/atom/attach_to = (isturf(hit) || isturf(hit.loc)) ? hit : hit_turf

	var/obj/effect/abstract/particle_holder/smoke_visuals = new(attach_to, /particles/impact_smoke)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01

	var/obj/effect/abstract/particle_holder/debris_visuals
	if(debris && P.flag != "energy" && P.flag != "bio")
		debris_visuals = new(attach_to, /particles/debris)
		debris_visuals.particles.position = generator("circle", position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale

	GLOB.impact_particles_active++
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_impact_particles), smoke_visuals, debris_visuals), 0.7 SECONDS)

/// Sprząta nośniki efektu trafienia lub dymu z lufy i zwalnia miejsce w limicie
/proc/remove_impact_particles(obj/effect/abstract/particle_holder/first, obj/effect/abstract/particle_holder/second)
	GLOB.impact_particles_active = max(GLOB.impact_particles_active - 1, 0)
	if(!QDELETED(first))
		qdel(first)
	if(!QDELETED(second))
		qdel(second)
