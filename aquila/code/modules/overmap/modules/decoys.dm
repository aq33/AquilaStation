/// AQUILA - wabiki i zagłuszanie (plan walki na overmapie, etap „chaff, flary, jammer”).
/// Flary odciągają torpedy (naprowadzanie na ciepło), chaff zrywa rakiety (naprowadzanie radarowe). Wabik działa na pociski
/// kierowane, które już lecą w okręt (torpedoes_to_target). Zagłuszacz wydłuża namierzanie okrętu i co jakiś czas zrywa
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

/obj/effect/overmap_decoy/flare
	name = "flara"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flare-on"
	light_range = 3
	light_power = 2
	light_color = "#ffb060"

/obj/effect/overmap_decoy/chaff
	name = "chmura chaffu"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	color = "#c8d0d8"
	alpha = 170
	pixel_x = -32
	pixel_y = -32
	lifetime = 15 SECONDS

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

/// Wypuszcza wabik; flara działa na torpedy, chaff na rakiety. Zwraca liczbę zwiedzionych pocisków albo FALSE.
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
	. = 0
	for(var/obj/item/projectile/guided_munition/proj as anything in torpedoes_to_target)
		if(QDELETED(proj) || proj.homing_target != src)
			continue
		var/is_torpedo = istype(proj, /obj/item/projectile/guided_munition/torpedo)
		if((kind == "flare") != is_torpedo)
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
	var/kind = istype(proj, /obj/item/projectile/guided_munition/torpedo) ? "flare" : "chaff"
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
