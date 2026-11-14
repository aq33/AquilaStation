// AQUILA - ostrzał planet z orbity (wzór: Aurora, pociski okrętu trafiają w powierzchnię planety). Ciężkie bronie
// okrętu (NAC, railgun, burty, działa fazowe, torpedy, rakiety) wycelowane w planetę spadają na jej powierzchnię:
// przy znaczniku z lornetki taktycznej w jego okolicy (rozrzut zależy od broni), bez znacznika w losowe miejsce.
// Przed uderzeniem na ziemi widać cel i słychać świst, potem wybuch zależny od siły pocisku. Torpedy wybuchają
// swoją głowicą (plazma, EMP, viscerators).

/// Ile pól od środka sprite'a planety pocisk musi przelecieć, żeby w nią trafić
#define PLANET_HIT_RADIUS 3
/// Opóźnienie uderzenia na powierzchni (cel widać na ziemi)
#define PLANET_STRIKE_DELAY (4 SECONDS)

GLOBAL_LIST_EMPTY(planet_laser_targets)

// Pocisk wycelowany w planetę trafia ją nad jej środkiem (planeta nie ma kolizji i ma duży sprite)
/obj/item/projectile/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(!istype(target, /obj/structure/overmap/planet))
		return ..()
	if(QDELETED(target) || target != original || deletion_queued || LAZYACCESS(impacted, target))
		return FALSE
	var/obj/structure/overmap/planet/planet = target
	return z && z == planet.z && get_dist(src, planet.center_turf()) <= PLANET_HIT_RADIUS

/obj/structure/overmap/planet/bullet_act(obj/item/projectile/P)
	if(P.flag == "overmap_light" || P.nodamage || !P.damage && !istype(P, /obj/item/projectile/guided_munition))
		return BULLET_ACT_HIT // Lekkie działka nie przebijają się przez atmosferę
	if(surface?.state != PLANET_SURFACE_READY)
		return BULLET_ACT_HIT // Nikogo tam nie ma: pocisk ginie w atmosferze
	var/turf/target_turf = pick_strike_turf(P)
	if(target_turf)
		new /obj/effect/temp_visual/planet_strike(target_turf, P.type, P.damage)
		log_game("[P] fired by [key_name(P.firer)] bombarded [src] at [AREACOORD(target_turf)]")
	return BULLET_ACT_HIT

/// Rozrzut w polach dla broni
/obj/structure/overmap/planet/proc/strike_spread(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/guided_munition))
		return 1
	if(P.flag == "overmap_heavy")
		return 2
	return 4

/// Pole uderzenia: przy najnowszym znaczniku na tej planecie, a bez znacznika losowe pole powierzchni
/obj/structure/overmap/planet/proc/pick_strike_turf(obj/item/projectile/P)
	var/obj/effect/planet_laser_target/laser
	for(var/obj/effect/planet_laser_target/candidate as anything in GLOB.planet_laser_targets)
		if(surface.contains(get_turf(candidate)) && (!laser || candidate.created_at > laser.created_at))
			laser = candidate
	if(laser)
		var/spread = strike_spread(P)
		var/turf/laser_turf = get_turf(laser)
		var/list/options = list()
		for(var/turf/T as anything in RANGE_TURFS(spread, laser_turf))
			if(surface.contains(T) && !isclosedturf(T))
				options += T
		return length(options) ? pick(options) : laser_turf
	var/list/inner = surface.inner_turfs()
	for(var/attempt in 1 to 10)
		var/turf/T = pick(inner)
		if(!isclosedturf(T))
			return T
	return pick(inner)

/// Cel ostrzału na ziemi: widać go chwilę przed uderzeniem
/obj/effect/temp_visual/planet_strike
	name = "nadlatujący pocisk"
	desc = "Coś spada z nieba prosto w to miejsce!"
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "target"
	duration = PLANET_STRIKE_DELAY
	randomdir = FALSE
	layer = ABOVE_MOB_LAYER
	light_color = LIGHT_COLOR_ORANGE
	var/projectile_type
	var/damage = 0

/obj/effect/temp_visual/planet_strike/Initialize(mapload, new_projectile_type, new_damage)
	projectile_type = new_projectile_type
	damage = new_damage
	. = ..()
	set_light(4)
	playsound(src, 'sound/weapons/mortar_whistle.ogg', 80, FALSE, 10)
	for(var/mob/living/M in range(7, src))
		to_chat(M, span_userdanger("Słyszysz narastający świst nad głową. Kryj się!"))

/obj/effect/temp_visual/planet_strike/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		strike(T)
	return ..()

/obj/effect/temp_visual/planet_strike/proc/strike(turf/T)
	if(!projectile_type && damage <= 0)
		return // Rozbrojony (testy, admin)
	if(ispath(projectile_type, /obj/item/projectile/guided_munition))
		// Głowica torpedy albo rakiety robi swoje (plazma, EMP, viscerators)
		var/obj/item/projectile/guided_munition/warhead = new projectile_type(T)
		warhead.detonate(T)
		if(!QDELETED(warhead))
			qdel(warhead)
		return
	if(damage >= 300)
		explosion(T, 1, 3, 5)
	else if(damage >= 150)
		explosion(T, 0, 2, 4)
	else
		explosion(T, 0, 1, 3)

/// Znacznik celu z lornetki taktycznej: widzą go wszyscy na ziemi, a pociski z orbity spadają w jego okolicy
/obj/effect/planet_laser_target
	name = "znacznik celu"
	desc = "Laserowy punkt naprowadzania dla ostrzału z orbity."
	icon = 'aquila/icons/squads/markers.dmi'
	icon_state = "marker_target"
	color = "#ff4040"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Kto i kiedy postawił
	var/placer_name
	var/created_at

/obj/effect/planet_laser_target/Initialize(mapload, new_placer_name)
	. = ..()
	placer_name = new_placer_name
	created_at = world.time
	GLOB.planet_laser_targets += src
	set_light(2, 1, "#ff4040")

/obj/effect/planet_laser_target/Destroy()
	GLOB.planet_laser_targets -= src
	return ..()

/obj/effect/planet_laser_target/ex_act(severity, target)
	return

#undef PLANET_HIT_RADIUS
#undef PLANET_STRIKE_DELAY
