/// AQUILA - efekty okrętów na overmapie (plan walki na overmapie, etap „efekty wizualne”): smuga za silnikami zależna od
/// prędkości, syczący gaz z wyłomów w modułach, płomienie pożarów modułów i dym nad wrakiem. Emitery cząsteczek siedzą
/// w vis_contents okrętu, więc obracają się i skalują razem z nim (skala wizualna). Pozycje w pikselach sprite'a
/// (dziób w górę), liczone z obrysu sprite'a (overmap_sprite_bounds).

#define SHIP_VFX_TICK (1 SECONDS)
#define SHIP_VFX_MAX_SPOTS 4

/particles/ship_engine_trail
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1)
	width = 600
	height = 600
	count = 200
	spawning = 0
	lifespan = 12
	fade = 10
	fadein = 1
	velocity = list(0, -3)
	position = generator("box", list(-6, 0), list(6, 2))
	drift = generator("vector", list(-0.2, 0), list(0.2, 0))
	grow = list(0.15, 0.15)
	scale = list(0.6, 0.6)
	color = "#a8d8ff"

/particles/ship_breach_gas
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_3" = 1)
	width = 400
	height = 400
	count = 80
	spawning = 2
	lifespan = 8
	fade = 6
	velocity = list(3, 0)
	position = generator("box", list(-2, -2), list(2, 2))
	drift = generator("vector", list(0, -0.4), list(0, 0.4))
	grow = list(0.2, 0.2)
	scale = list(0.4, 0.4)
	color = "#e8f0ff"

/particles/ship_module_fire
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1)
	width = 300
	height = 300
	count = 60
	spawning = 1
	lifespan = 10
	fade = 8
	velocity = list(0, 0.5)
	position = generator("box", list(-4, -4), list(4, 4))
	gradient = list(0, "#ffd060", 0.5, "#ff6020", 1, "#40302a")
	color_change = 0.15
	color = 0
	scale = list(0.4, 0.4)

/particles/wreck_smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_2" = 1, "smoke_3" = 1)
	width = 600
	height = 600
	count = 60
	spawning = 0.6
	lifespan = 25
	fade = 20
	velocity = list(0, 0.3)
	position = generator("box", list(-10, -10), list(10, 10))
	drift = generator("vector", list(-0.1, -0.1), list(0.1, 0.1))
	grow = list(0.05, 0.05)
	color = "#555555"

/// Emiter cząsteczek przypięty do okrętu (rysowany razem z nim)
/obj/effect/ship_vfx_emitter
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	invisibility = 0

/obj/effect/ship_vfx_emitter/Initialize(mapload, particle_type, px, py)
	. = ..()
	particles = new particle_type
	pixel_x = px
	pixel_y = py

/obj/structure/overmap
	/// AQUILA - emitery efektów: "engine", "wreck" i miejsca wyłomów/pożarów modułów
	var/list/obj/effect/ship_vfx_emitter/vfx_emitters
	var/vfx_timer

/// Punkt sprite'a w pikselach (od lewego dolnego rogu klatki) dla u (rufa -1..dziób 1) i v (lewa burta -1..prawa 1)
/obj/structure/overmap/proc/vfx_sprite_point(u, v)
	var/list/disp = overmap_display_bounds()
	if(!disp)
		return null
	return list(disp[1] / 2 + disp[5] + v * disp[3] / 2, disp[2] / 2 + disp[6] + u * disp[4] / 2)

/obj/structure/overmap/proc/vfx_emitter(key, particle_type, list/point)
	LAZYINITLIST(vfx_emitters)
	var/obj/effect/ship_vfx_emitter/emitter = vfx_emitters[key]
	if(emitter && !QDELETED(emitter))
		return emitter
	if(!point)
		return null
	emitter = new /obj/effect/ship_vfx_emitter(src, particle_type, point[1], point[2])
	vfx_emitters[key] = emitter
	vis_contents += emitter
	return emitter

/obj/structure/overmap/proc/remove_vfx(key)
	var/obj/effect/ship_vfx_emitter/emitter = LAZYACCESS(vfx_emitters, key)
	if(!emitter)
		return
	vis_contents -= emitter
	vfx_emitters -= key
	qdel(emitter)

/obj/structure/overmap/proc/start_vfx()
	if(vfx_timer || !overmap_display_bounds())
		return
	vfx_timer = addtimer(CALLBACK(src, PROC_REF(update_vfx)), SHIP_VFX_TICK, TIMER_STOPPABLE | TIMER_LOOP)

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	if(!istype(src, /obj/structure/overmap/asteroid) || istype(src, /obj/structure/overmap/asteroid/shipbreak_wreck))
		start_vfx()

/obj/structure/overmap/Destroy()
	deltimer(vfx_timer)
	vfx_timer = null
	for(var/key in vfx_emitters)
		qdel(vfx_emitters[key])
	vfx_emitters = null
	return ..()

/// Co sekundę: smuga za silnikami według prędkości, gaz z wyłomów i ogień modułów, dym nad wrakiem
/obj/structure/overmap/proc/update_vfx()
	if(QDELETED(src) || !z || !SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		return
	if(istype(src, /obj/structure/overmap/asteroid/shipbreak_wreck))
		vfx_emitter("wreck", /particles/wreck_smoke, vfx_sprite_point(0, 0))
		return
	var/obj/effect/ship_vfx_emitter/engine = vfx_emitter("engine", /particles/ship_engine_trail, vfx_sprite_point(-1, 0))
	if(engine?.particles)
		var/speed = velocity ? sqrt(velocity.a ** 2 + velocity.e ** 2) : 0
		engine.particles.spawning = clamp(speed * 1.5, 0, 5)
	var/list/wanted = list()
	var/list/modules = ship_modules?.modules
	for(var/i in 1 to length(modules))
		var/datum/ship_module/module = modules[i]
		if(!module.breached && !module.fire)
			continue
		if(length(wanted) >= SHIP_VFX_MAX_SPOTS)
			break
		var/u = ((module.x0 + module.x1) / 2 + 0.5) / ship_modules.length * 2 - 1
		var/v = ((module.y0 + module.y1) / 2 + 0.5) / ship_modules.width * 2 - 1
		if(module.breached)
			var/side = v < 0 ? -1 : 1
			var/key = "breach_[i]"
			wanted += key
			var/obj/effect/ship_vfx_emitter/gas = vfx_emitter(key, /particles/ship_breach_gas, vfx_sprite_point(u, side))
			if(gas?.particles)
				gas.particles.velocity = list(3 * side, 0)
		if(module.fire)
			var/key = "fire_[i]"
			wanted += key
			var/obj/effect/ship_vfx_emitter/fire = vfx_emitter(key, /particles/ship_module_fire, vfx_sprite_point(u, v))
			if(fire?.particles)
				fire.particles.spawning = module.fire
	for(var/key in vfx_emitters.Copy())
		if((findtext(key, "breach_") == 1 || findtext(key, "fire_") == 1) && !(key in wanted))
			remove_vfx(key)

#undef SHIP_VFX_TICK
#undef SHIP_VFX_MAX_SPOTS
