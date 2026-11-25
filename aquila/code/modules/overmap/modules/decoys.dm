/// AQUILA - wabiki i zagłuszanie (plan walki na overmapie, etap „chaff, flary, jammer”).
/// Flary odciągają pociski z głowicą na podczerwień, chaff zrywa pociski z głowicą radarową, według naprowadzania z projektu
/// pocisku (missile_design.dm, decoy_kind()); pocisk bez projektu: torpeda na ciepło, rakieta na radar. Torpeda-wabik NSV
/// (DCY) zwodzi głowice radarowe osobno. Wabik działa na pociski kierowane, które już lecą w okręt (torpedoes_to_target). Zagłuszacz wydłuża namierzanie okrętu i co jakiś czas zrywa
/// dalekie namiary, ale podnosi jego sygnaturę. Gracz używa ich w konsoli taktycznej, AI odpowiada wabikiem na pocisk.

#define DECOY_RANGE 14
#define DECOY_SEDUCE_CHANCE 55
#define DECOY_COOLDOWN (4 SECONDS)
#define DECOY_REGEN_TIME (60 SECONDS)
#define JAMMER_TICK (10 SECONDS)
#define JAMMER_SIGNATURE 50
#define JAMMER_MIN_DIST 10

/obj/effect/overmap_decoy
	name = "wabik"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/lifetime = 8 SECONDS

/obj/effect/overmap_decoy/Initialize(mapload)
	. = ..()
	QDEL_IN(src, lifetime)

/particles/overmap_flare_sparks
	icon = 'aquila/icons/effects/particles/misc.dmi'
	icon_state = list("sparkle_1" = 2, "sparkle_2" = 1, "circle_2" = 1)
	width = 256
	height = 256
	count = 60
	spawning = 4
	lifespan = generator("num", 6, 12)
	fade = 6
	velocity = generator("circle", 0.4, 1.4)
	friction = 0.06
	scale = generator("num", 0.3, 0.7)
	grow = list(-0.02, -0.02)
	gradient = list(0, "#ffffff", 0.35, "#fff0a0", 0.7, "#ff9030", 1, "#ff302000")
	color_change = 0.1
	color = 0

/particles/overmap_chaff
	icon = 'aquila/icons/effects/particles/misc.dmi'
	icon_state = list("sparkle_1" = 2, "sparkle_2" = 2, "shard" = 1)
	width = 400
	height = 400
	count = 160
	spawning = 40
	lifespan = generator("num", 60, 140)
	fade = 50
	fadein = 3
	velocity = generator("circle", 0.3, 1.6)
	friction = 0.04
	drift = generator("vector", list(-0.05, -0.05), list(0.05, 0.05))
	spin = generator("num", -15, 15)
	scale = generator("num", 0.3, 0.8)
	gradient = list(0, "#ffffff", 0.2, "#9aa8b8", 0.4, "#e8f0ff", 0.6, "#7d8896", 0.8, "#f4f8ff", 1, "#8a96a4")
	color_change = generator("num", 0.05, 0.2)
	color = generator("num", 0, 1)

/// Flara: rozżarzona kula (biały rdzeń w pomarańczowej poświacie), która sypie iskrami, pulsuje i odpływa za rufę
/obj/effect/overmap_decoy/flare
	name = "flara"
	icon = 'aquila/icons/effects/particles/misc.dmi'
	icon_state = "circle_1"
	color = "#fff6d8"
	blend_mode = BLEND_ADD
	appearance_flags = PIXEL_SCALE
	light_range = 3
	light_power = 2
	light_color = "#ffb060"

/obj/effect/overmap_decoy/flare/Initialize(mapload)
	. = ..()
	particles = new /particles/overmap_flare_sparks
	add_filter("flare_glow", 1, list("type" = "drop_shadow", "x" = 0, "y" = 0, "size" = 6, "color" = "#ff9a3080"))
	transform = matrix() * 0.6
	animate(src, transform = matrix() * 1.1, time = 3, easing = SINE_EASING, loop = -1)
	animate(transform = matrix() * 0.8, time = 3, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(burn_out)), lifetime - 2 SECONDS)

/obj/effect/overmap_decoy/flare/proc/burn_out()
	if(particles)
		particles.spawning = 0
	animate(src, alpha = 0, transform = matrix() * 0.3, time = 2 SECONDS)

/// Odpływa od okrętu przeciwnie do kursu, z odchyleniem spread; przesuwa się tylko obraz, cel pocisków zostaje na polu
/obj/effect/overmap_decoy/flare/proc/drift_from(obj/structure/overmap/ship, spread)
	var/heading = ship.angle + 180 + spread
	animate(src, pixel_x = sin(heading) * 40, pixel_y = cos(heading) * 40, time = lifetime, easing = QUAD_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)

/// Dodatkowa flara tylko na obraz (wachlarz za rufą); pociski jej nie biorą za cel
/obj/effect/overmap_decoy/flare/visual

/// Chaff: chmura pasków folii, która mieni się srebrem i powoli gaśnie
/obj/effect/overmap_decoy/chaff
	name = "chmura chaffu"
	icon = null
	icon_state = null
	lifetime = 15 SECONDS

/obj/effect/overmap_decoy/chaff/Initialize(mapload)
	. = ..()
	particles = new /particles/overmap_chaff
	addtimer(CALLBACK(src, PROC_REF(stop_spawning)), 1 SECONDS)

/obj/effect/overmap_decoy/chaff/proc/stop_spawning()
	if(particles)
		particles.spawning = 0

/obj/structure/overmap
	/// AQUILA - wabiki na pokładzie i ich maksimum (odnawiają się co DECOY_REGEN_TIME)
	var/flares = 6
	var/max_flares = 6
	var/chaff = 4
	var/max_chaff = 4
	var/next_decoy = 0
	var/decoy_regen_timer
	/// AQUILA - zagłuszacz włączony
	var/jammer_active = FALSE
	var/jammer_timer

/// Wypuszcza wabik; flara działa na głowice na podczerwień, chaff na radarowe. Zwraca liczbę zwiedzionych pocisków albo FALSE.
/obj/structure/overmap/proc/deploy_decoy(kind, seduce_chance = DECOY_SEDUCE_CHANCE)
	if(world.time < next_decoy || QDELETED(src))
		return FALSE
	if(kind == "flare" ? flares <= 0 : chaff <= 0)
		return FALSE
	next_decoy = world.time + DECOY_COOLDOWN
	if(kind == "flare")
		flares--
	else
		chaff--
	var/turf/T = get_center() || get_turf(src)
	var/obj/effect/overmap_decoy/decoy = (kind == "flare") ? new /obj/effect/overmap_decoy/flare(T) : new /obj/effect/overmap_decoy/chaff(T)
	if(kind == "flare")
		var/obj/effect/overmap_decoy/flare/main_flare = decoy
		main_flare.drift_from(src, 0)
		for(var/spread in list(-35, 35))
			var/obj/effect/overmap_decoy/flare/visual/extra = new(T)
			extra.drift_from(src, spread)
	. = 0
	for(var/obj/item/projectile/guided_munition/proj as anything in torpedoes_to_target)
		if(QDELETED(proj) || proj.homing_target != src)
			continue
		if(proj.decoy_kind() != kind)
			continue
		if(overmap_dist(src, proj) > DECOY_RANGE || !prob(seduce_chance))
			continue
		proj.set_homing_target(decoy)
		.++
	relay('sound/weapons/flash.ogg', "<span class='notice'>[kind == "flare" ? "Wystrzelono flary." : "Wystrzelono chaff."]</span>")
	start_decoy_regen()

/obj/structure/overmap/proc/start_decoy_regen()
	if(decoy_regen_timer || (flares >= max_flares && chaff >= max_chaff))
		return
	decoy_regen_timer = addtimer(CALLBACK(src, PROC_REF(regen_decoys)), DECOY_REGEN_TIME, TIMER_STOPPABLE)

/obj/structure/overmap/proc/regen_decoys()
	decoy_regen_timer = null
	flares = min(max_flares, flares + 1)
	chaff = min(max_chaff, chaff + 1)
	start_decoy_regen()

/obj/structure/overmap/proc/toggle_jammer()
	jammer_active = !jammer_active
	sensor_profile += jammer_active ? JAMMER_SIGNATURE : -JAMMER_SIGNATURE
	if(jammer_active)
		jammer_timer = addtimer(CALLBACK(src, PROC_REF(jammer_tick)), JAMMER_TICK, TIMER_STOPPABLE | TIMER_LOOP)
	else
		deltimer(jammer_timer)
		jammer_timer = null
	return jammer_active

/// Zagłuszacz zrywa namiary okrętów, które trzymają nas z daleka
/obj/structure/overmap/proc/jammer_tick()
	if(!jammer_active || QDELETED(src))
		return
	for(var/obj/structure/overmap/enemy as anything in current_system?.system_contents)
		if(!istype(enemy) || enemy == src || enemy.faction == faction || !LAZYFIND(enemy.target_painted, src))
			continue
		if(overmap_dist(src, enemy) > JAMMER_MIN_DIST && prob(30))
			enemy.dump_lock(src)

// Namierzanie zagłuszanego okrętu z daleka trwa dwa razy dłużej
/obj/structure/overmap/start_lockon(obj/structure/overmap/target)
	if(!istype(target) || !target.jammer_active || overmap_dist(src, target) <= JAMMER_MIN_DIST)
		return ..()
	var/old_time = lockon_time
	lockon_time *= 2
	. = ..()
	lockon_time = old_time

// AI odpowiada wabikiem na pocisk kierowany
/obj/structure/overmap/on_missile_lock(obj/structure/overmap/firer, obj/item/projectile/proj)
	. = ..()
	if(!ai_controlled || !prob(60))
		return
	var/obj/item/projectile/guided_munition/guided = proj
	var/kind = istype(guided) ? guided.decoy_kind() : null
	if(!kind)
		return
	addtimer(CALLBACK(src, PROC_REF(deploy_decoy), kind), rand(2, 5) SECONDS)

/obj/structure/overmap/Destroy()
	deltimer(decoy_regen_timer)
	deltimer(jammer_timer)
	return ..()

#undef DECOY_RANGE
#undef DECOY_SEDUCE_CHANCE
#undef DECOY_COOLDOWN
#undef DECOY_REGEN_TIME
#undef JAMMER_TICK
#undef JAMMER_SIGNATURE
#undef JAMMER_MIN_DIST
