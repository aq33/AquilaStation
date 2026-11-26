/// AQUILA - efekty walki na overmapie, dokończenie etapu „efekty wizualne” (plan walki na overmapie, E9):
/// - flary i chaff jako cząsteczki (rozżarzone kule z iskrami, srebrna mieniąca się chmura), bez sprite'ów przedmiotów;
/// - skok FTL: kadłub rozciąga się wzdłuż kursu i znika w błysku, a przy przylocie wyłania się z błysku;
/// - dysze manewrowe na dziobie przy obrocie okrętu;
/// - dym przy odpaleniu torpedy i rakiety;
/// - osobne dźwięki trafienia w tarczę, w pancerz i w moduł, słyszalne dla strzelca i pilota okrętu, który strzelał.

#define SHIP_RCS_MIN_TURN 3
#define SHIP_HIT_SOUND_COOLDOWN (0.4 SECONDS)

// --- Skok FTL ---

/obj/effect/temp_visual/overmap_ftl_streak
	duration = 8
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE

/obj/effect/temp_visual/overmap_ftl_flash
	icon = 'aquila/icons/effects/particles/misc.dmi'
	icon_state = "circle_1"
	color = "#cfe6ff"
	blend_mode = BLEND_ADD
	duration = 7
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/overmap_ftl_flash/Initialize(mapload)
	. = ..()
	add_filter("ftl_glow", 1, list("type" = "drop_shadow", "x" = 0, "y" = 0, "size" = 8, "color" = "#8ec8ff"))
	transform = matrix() * 0.5
	animate(src, transform = matrix() * 7, alpha = 0, time = duration, easing = CUBIC_EASING | EASE_OUT)

/// Odlot (arriving FALSE): kadłub rozciąga się wzdłuż kursu i znika; przylot: wyłania się z rozciągniętej smugi
/obj/structure/overmap/proc/ftl_vfx(arriving)
	if(!z || !SSmapping.level_trait(z, ZTRAIT_OVERMAP) || !icon)
		return
	var/turf/T = get_turf(src)
	var/obj/effect/temp_visual/overmap_ftl_streak/streak = new(T)
	streak.icon = icon
	streak.icon_state = icon_state
	streak.pixel_x = pixel_x
	streak.pixel_y = pixel_y
	streak.layer = layer
	streak.plane = plane
	streak.color = "#bfe2ff"
	var/matrix/normal = matrix(transform)
	var/matrix/stretched = matrix(transform)
	stretched.Turn(-angle)
	stretched.Scale(0.5, 8)
	stretched.Turn(angle)
	stretched.Translate(sin(angle) * 96, cos(angle) * 96)
	if(arriving)
		streak.transform = stretched
		streak.alpha = 0
		animate(streak, transform = normal, alpha = 200, time = 5, easing = CUBIC_EASING | EASE_OUT)
		animate(alpha = 0, time = 3)
	else
		streak.transform = normal
		animate(streak, transform = stretched, alpha = 0, time = 7, easing = CUBIC_EASING | EASE_IN)
	var/turf/center = get_center() || T
	new /obj/effect/temp_visual/overmap_ftl_flash(center)

/datum/star_system/remove_ship(obj/structure/overmap/OM, turf/new_location, is_ftl_jump = TRUE)
	if(is_ftl_jump && istype(OM) && !QDELETED(OM))
		OM.ftl_vfx(FALSE)
	return ..()

/datum/star_system/add_ship(obj/structure/overmap/OM, turf/target_turf)
	. = ..()
	if(istype(OM) && !QDELETED(OM) && SSticker.HasRoundStarted())
		OM.ftl_vfx(TRUE)

// --- Dysze manewrowe ---

/particles/ship_rcs
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_3" = 1)
	width = 200
	height = 200
	count = 30
	spawning = 0
	lifespan = 5
	fade = 4
	velocity = list(3, 0)
	position = generator("box", list(-1, -1), list(1, 1))
	drift = generator("vector", list(0, -0.3), list(0, 0.3))
	scale = list(0.25, 0.25)
	grow = list(0.08, 0.08)
	color = "#e8f4ff"

/obj/structure/overmap
	/// AQUILA - kąt okrętu przy poprzednim tiku efektów (dysze manewrowe)
	var/vfx_last_angle

/obj/structure/overmap/update_vfx()
	. = ..()
	if(QDELETED(src) || isasteroid(src) || !z || !SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		return
	var/turn = isnull(vfx_last_angle) ? 0 : ((angle - vfx_last_angle) % 360 + 540) % 360 - 180
	vfx_last_angle = angle
	var/spawn_rate = abs(turn) >= SHIP_RCS_MIN_TURN ? clamp(abs(turn) / 6, 1, 4) : 0
	// obrót w prawo popycha dziób dyszą z lewej burty, w lewo dyszą z prawej
	for(var/side in list(-1, 1))
		var/key = side < 0 ? "rcs_l" : "rcs_r"
		var/active = spawn_rate && ((turn > 0) == (side < 0))
		var/obj/effect/ship_vfx_emitter/rcs = active ? vfx_emitter(key, /particles/ship_rcs, vfx_sprite_point(0.8, side)) : LAZYACCESS(vfx_emitters, key)
		if(rcs?.particles)
			rcs.particles.velocity = list(3 * side, 0)
			rcs.particles.spawning = active ? spawn_rate : 0

// --- Odpalenie torpedy i rakiety ---

/particles/ship_launch_smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 1)
	width = 300
	height = 300
	count = 40
	spawning = 20
	lifespan = generator("num", 12, 22)
	fade = 14
	velocity = generator("circle", 0.2, 0.9)
	friction = 0.05
	scale = generator("num", 0.3, 0.5)
	grow = list(0.03, 0.03)
	color = "#b8b8b8"

/obj/effect/temp_visual/overmap_launch_smoke
	duration = 25
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/overmap_launch_smoke/Initialize(mapload)
	. = ..()
	particles = new /particles/ship_launch_smoke
	addtimer(CALLBACK(src, PROC_REF(stop_smoke)), 2)

/obj/effect/temp_visual/overmap_launch_smoke/proc/stop_smoke()
	if(particles)
		particles.spawning = 0

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	. = ..()
	if(ispath(proj_type, /obj/item/projectile/guided_munition) && z && SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		new /obj/effect/temp_visual/overmap_launch_smoke(get_center() || get_turf(src))

// --- Dźwięki trafień ---

/obj/structure/overmap
	/// AQUILA - kiedy można znowu zagrać dźwięk trafienia w ten okręt
	var/next_hit_sound = 0

/// Trafienie w tarczę, w pancerz albo w moduł: strzelec i pilot okrętu, który strzelał, słyszą, w co weszło
/obj/structure/overmap/proc/play_hit_sound(obj/structure/overmap/firer, kind)
	if(!firer || QDELETED(firer) || world.time < next_hit_sound)
		return
	next_hit_sound = world.time + SHIP_HIT_SOUND_COOLDOWN
	var/sound_file
	switch(kind)
		if("shield")
			sound_file = pick('nsv13/sound/effects/ship/damage/shield_hit.ogg', 'nsv13/sound/effects/ship/damage/shield_hit2.ogg')
		if("module")
			sound_file = pick('nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav', 'nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav', 'nsv13/sound/effects/ship/damage/explosionfar_3.ogg')
		else
			sound_file = pick('nsv13/sound/effects/ship/freespace2/impacts/hit_1.wav', 'nsv13/sound/effects/ship/freespace2/impacts/subhit.wav', 'nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav')
	for(var/mob/listener in list(firer.gunner, firer.pilot))
		if(listener?.client && listener.can_hear())
			SEND_SOUND(listener, sound(sound_file, volume = 45))
		if(firer.gunner == firer.pilot)
			break

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/firer = P?.overmap_firer
	var/old_modules_hp = ship_modules ? ship_modules.total_integrity() : 0
	. = ..()
	if(QDELETED(src) || !istype(firer) || firer == src)
		return
	if(. == BULLET_ACT_FORCE_PIERCE || (!isnull(.) && !.))
		play_hit_sound(firer, "shield")
	else if(ship_modules && ship_modules.total_integrity() < old_modules_hp)
		play_hit_sound(firer, "module")
	else
		play_hit_sound(firer, "armour")

/// Suma wytrzymałości modułów (do rozpoznania, czy trafienie weszło w moduł)
/datum/ship_modules/proc/total_integrity()
	. = 0
	for(var/datum/ship_module/module as anything in modules)
		. += module.integrity

#undef SHIP_RCS_MIN_TURN
#undef SHIP_HIT_SOUND_COOLDOWN
