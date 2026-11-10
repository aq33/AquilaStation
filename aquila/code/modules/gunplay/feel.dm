// AQUILA - odczucie strzału: smugi za kulami, rykoszety, świst i drżenie przy przelocie kuli, dźwięki trafień zależne
// od materiału, grzechot ostatnich naboi, odjazd krzesła na kółkach od odrzutu, przechył i obrót broni przy strzale,
// spadek siły ran śrutu z odległością i statystyki broni w opisie.
// Wzory: Shiptest (świst bullet_miss i shake_animation() przy przelocie, dźwięki trafień wg materiału, rykoszety kul),
// CM (fire_rattle), /vg/ (krzesło odjeżdża od odrzutu), Goon i Yogstation (przechył broni przy strzale), tg (wound_falloff_tile śrutu).

/// Kule z broni palnej: tyle odbić maks.
#define AQ_BULLET_RICOCHETS 2
/// Od jakiego kąta do ściany (stopnie od prostopadłej) kula może się odbić
#define AQ_RICOCHET_MIN_ANGLE 45
#define AQ_RICOCHET_MIN_CHANCE 10
#define AQ_RICOCHET_MAX_CHANCE 75
/// Co który nabój w karabinach maszynowych jest smugowy
#define AQ_MG_TRACER_INTERVAL 5

GLOBAL_LIST_INIT(aq_bullet_hit_sounds, list(
	"metal" = list('aquila/sound/weapons/gun_hit/bullet_metal_01.ogg', 'aquila/sound/weapons/gun_hit/bullet_metal_02.ogg', 'aquila/sound/weapons/gun_hit/bullet_metal_03.ogg', 'aquila/sound/weapons/gun_hit/bullet_metal_04.ogg', 'aquila/sound/weapons/gun_hit/bullet_metal_05.ogg', 'aquila/sound/weapons/gun_hit/bullet_metal_06.ogg'),
	"wood" = list('aquila/sound/weapons/gun_hit/bullet_wood_01.ogg', 'aquila/sound/weapons/gun_hit/bullet_wood_02.ogg', 'aquila/sound/weapons/gun_hit/bullet_wood_03.ogg', 'aquila/sound/weapons/gun_hit/bullet_wood_04.ogg', 'aquila/sound/weapons/gun_hit/bullet_wood_05.ogg', 'aquila/sound/weapons/gun_hit/bullet_wood_06.ogg'),
	"glass" = list('aquila/sound/weapons/gun_hit/bullet_glass_01.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_02.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_03.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_04.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_05.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_06.ogg', 'aquila/sound/weapons/gun_hit/bullet_glass_07.ogg'),
	"stone" = list('aquila/sound/weapons/gun_hit/bullet_masonry_01.ogg', 'aquila/sound/weapons/gun_hit/bullet_masonry_02.ogg', 'aquila/sound/weapons/gun_hit/bullet_masonry_03.ogg', 'aquila/sound/weapons/gun_hit/bullet_masonry_04.ogg', 'aquila/sound/weapons/gun_hit/bullet_masonry_05.ogg', 'aquila/sound/weapons/gun_hit/bullet_masonry_06.ogg'),
	"ricochet" = list('aquila/sound/weapons/gun_hit/bullet_ricochet1.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet2.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet3.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet4.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet5.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet6.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet7.ogg', 'aquila/sound/weapons/gun_hit/bullet_ricochet8.ogg'),
	"flyby" = list('aquila/sound/weapons/gun_hit/bullet_miss1.ogg', 'aquila/sound/weapons/gun_hit/bullet_miss2.ogg', 'aquila/sound/weapons/gun_hit/bullet_miss3.ogg', 'aquila/sound/weapons/gun_hit/bullet_miss4.ogg', 'sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'),
))

/// Materiał, w który trafia kula: "metal", "wood", "glass", "stone" albo null (bez dźwięku)
/atom/proc/get_bullet_hit_material()
	return null

/turf/closed/get_bullet_hit_material()
	return "metal"

/turf/closed/wall/mineral/wood/get_bullet_hit_material()
	return "wood"

/turf/closed/wall/mineral/sandstone/get_bullet_hit_material()
	return "stone"

/turf/closed/mineral/get_bullet_hit_material()
	return "stone"

/turf/closed/indestructible/rock/get_bullet_hit_material()
	return "stone"

/obj/get_bullet_hit_material()
	return (flags_1 & CONDUCT_1) ? "metal" : null

/obj/structure/window/get_bullet_hit_material()
	return "glass"

/obj/machinery/door/window/get_bullet_hit_material()
	return "glass"

/obj/structure/table/glass/get_bullet_hit_material()
	return "glass"

/obj/structure/table/wood/get_bullet_hit_material()
	return "wood"

/obj/structure/barricade/wooden/get_bullet_hit_material()
	return "wood"

/obj/structure/barricade/sandbags/get_bullet_hit_material()
	return "stone"

/obj/structure/chair/wood/get_bullet_hit_material()
	return "wood"

/obj/structure/closet/crate/wooden/get_bullet_hit_material()
	return "wood"

/obj/structure/closet/cabinet/get_bullet_hit_material()
	return "wood"

/obj/structure/closet/crate/large/get_bullet_hit_material()
	return "wood"

/obj/structure/mineral_door/wood/get_bullet_hit_material()
	return "wood"

/obj/structure/flora/tree/get_bullet_hit_material()
	return "wood"

/turf/closed/wall/mineral/snow/get_bullet_hit_material()
	return "stone"

/turf/closed/wall/ice/get_bullet_hit_material()
	return "glass"

/obj/item/gun
	/// Kiedy i gdzie ostatnio zagrał dźwięk trafienia kuli z tej broni (śrut: jeden dźwięk na strzał, nie na śrucinę)
	var/aq_hit_sound_time = 0
	var/turf/aq_hit_sound_turf

/obj/item/projectile/bullet/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isliving(target) || !aq_from_gun)
		return
	var/material = target.get_bullet_hit_material()
	if(!material)
		return
	var/turf/hit_turf = get_turf(target)
	var/obj/item/gun/gun = fired_from
	if(istype(gun))
		if(gun.aq_hit_sound_time == world.time && gun.aq_hit_sound_turf == hit_turf)
			return // reszta śrucin tego samego strzału w ten sam kafel
		gun.aq_hit_sound_time = world.time
		gun.aq_hit_sound_turf = hit_turf
	playsound(hit_turf, pick(GLOB.aq_bullet_hit_sounds[material]), suppressed ? 20 : 55, TRUE, -1)

// --- Rykoszety ---

/obj/item/projectile/on_ricochet(atom/A)
	. = ..()
	if(!aq_from_gun)
		return
	playsound(get_turf(src), pick(GLOB.aq_bullet_hit_sounds["ricochet"]), 50, TRUE, -1)
	do_sparks(1, FALSE, get_turf(A))

/// Pod jakim kątem do ściany leci pocisk: 0 = prosto w nią, 90 = równolegle; null = odlatuje od niej
/obj/item/projectile/proc/get_grazing_angle(atom/A)
	var/turf/projectile_turf = get_turf(src)
	var/face_direction = get_dir(A, projectile_turf)
	if(!face_direction)
		return null
	var/incidence = abs(GET_ANGLE_OF_INCIDENCE(dir2angle(face_direction), (Angle + 180)))
	if(incidence > 90 && incidence < 270)
		return null
	if(incidence >= 270)
		incidence = 360 - incidence
	return incidence

// Kula z broni ręcznej odbija się od twardej powierzchni tylko pod ostrym kątem, i to losowo:
// od AQ_RICOCHET_MIN_ANGLE szansa rośnie liniowo od AQ_RICOCHET_MIN_CHANCE do AQ_RICOCHET_MAX_CHANCE przy strzale prawie równoległym.
// Przeciwpancerne i wiązki odbijają się rzadziej, amunicja wyczynowa (.38/.357 match) zawsze i pod większym kątem.
/obj/item/projectile/check_ricochet(atom/A)
	if(!aq_angle_ricochet || !A)
		return ..()
	var/grazing = get_grazing_angle(A)
	if(isnull(grazing))
		return FALSE
	var/trick_shot = initial(ricochet_chance) >= 100
	var/min_angle = trick_shot ? 25 : AQ_RICOCHET_MIN_ANGLE
	if(grazing < min_angle)
		return FALSE
	if(trick_shot)
		return TRUE
	var/chance = AQ_RICOCHET_MIN_CHANCE + (grazing - min_angle) / (90 - min_angle) * (AQ_RICOCHET_MAX_CHANCE - AQ_RICOCHET_MIN_CHANCE)
	if(armour_penetration >= 20)
		chance *= 0.4
	if(flag != "bullet")
		chance *= 0.5
	chance *= ricochet_decay_chance ** ricochets
	return prob(chance)

/obj/item/projectile/check_ricochet_flag(atom/A)
	if(aq_angle_ricochet)
		return (A.flags_ricochet & RICOCHET_HARD) // kula odbija się od twardego, a nie od luster (to robią wiązki w rdzeniu)
	return ..()

/// Zwykła kula z broni ręcznej: przyspieszenie, smuga, świst, rykoszet pod kątem, dźwięk materiału.
/// Macka, hak, plazma, KA czy strzałki mają domyślną flagę "bullet", ale kulami nie są.
/obj/item/projectile/proc/is_gun_bullet()
	return FALSE

/obj/item/projectile/bullet/is_gun_bullet()
	return flag == "bullet" && !hitscan

/obj/item/projectile/bullet/dart/is_gun_bullet()
	return FALSE

/obj/item/projectile/bullet
	/// Odbija się pod ostrym kątem; rakiety, granaty i amunicja, która w rdzeniu ma wyłączone rykoszety, nie
	var/aq_ricochets = TRUE

/obj/item/projectile/bullet/gyro
	aq_ricochets = FALSE
/obj/item/projectile/bullet/a84mm
	aq_ricochets = FALSE
/obj/item/projectile/bullet/a84mm_he
	aq_ricochets = FALSE
/obj/item/projectile/bullet/a40mm
	aq_ricochets = FALSE
/obj/item/projectile/bullet/dart
	aq_ricochets = FALSE
/obj/item/projectile/bullet/c38/dumdum
	aq_ricochets = FALSE
/obj/item/projectile/bullet/c38/trac
	aq_ricochets = FALSE
/obj/item/projectile/bullet/c38/hotshot
	aq_ricochets = FALSE
/obj/item/projectile/bullet/c38/iceblox
	aq_ricochets = FALSE

// --- Wspólna konfiguracja pocisku z broni ręcznej ---

/obj/item/projectile
	/// Wystrzelony z broni ręcznej (nie z działa okrętowego ani wieżyczki)
	var/aq_from_gun = FALSE
	/// Rykoszet liczony z kąta (tylko kule z broni ręcznej, zob. check_ricochet())
	var/aq_angle_ricochet = FALSE
	/// Smuga dołożona po pierwszym kafelku lotu ("trail" albo "trail_bright")
	var/aq_tail_state
	/// Mobom, które już usłyszały świst tej kuli
	var/list/aq_flyby_heard
	/// Nabój smugowy niezależnie od broni
	var/tracer_round = FALSE
	/// Spadek siły ran na kafelek (tg wound_falloff_tile)
	var/wound_falloff_tile = 0

/obj/item/gun
	/// Co który strzał jest smugowy (0 = żaden poza amunicją smugową)
	var/tracer_interval = 0
	/// Licznik strzałów do smugowego
	var/shots_since_tracer = 0

/obj/item/gun/ballistic/automatic/l6_saw
	tracer_interval = AQ_MG_TRACER_INTERVAL

/// Pocisk wylatuje z tej broni: smuga, rykoszety, świst
/obj/item/gun/proc/setup_fired_projectile(obj/item/projectile/projectile)
	projectile.aq_from_gun = TRUE
	if(!projectile.is_gun_bullet())
		return
	// Rykoszety kul z każdej broni: kąt i szansę liczy check_ricochet(), więc handle_ricochet() nie odrzuca już kątów
	var/obj/item/projectile/bullet/bullet = projectile
	if(bullet.aq_ricochets)
		bullet.aq_angle_ricochet = TRUE
		bullet.ricochets_max = max(bullet.ricochets_max, AQ_BULLET_RICOCHETS)
		bullet.ricochet_incidence_leeway = 0
	// Dźwięk trafienia w ścianę daje materiał (on_hit()), a nie rdzeniowy „ricochet” przy każdym trafieniu
	bullet.hitsound_wall = null
	var/bright = projectile.tracer_round
	if(tracer_interval)
		shots_since_tracer++
		if(shots_since_tracer >= tracer_interval)
			shots_since_tracer = 0
			bright = TRUE
	projectile.aq_tail_state = bright ? "trail_bright" : "trail"

/obj/item/projectile/Range()
	if(wound_falloff_tile && wound_bonus != CANT_WOUND)
		wound_bonus += wound_falloff_tile
		bare_wound_bonus = max(0, bare_wound_bonus + wound_falloff_tile)
	. = ..()
	if(aq_tail_state && !QDELETED(src))
		// Smuga dopiero od drugiego kafelka, żeby nie wyrastała strzelcowi z pleców
		var/mutable_appearance/tail = mutable_appearance('aquila/icons/obj/projectile_tracers.dmi', aq_tail_state)
		tail.pixel_y = -32 // ikona 32x96: środek pocisku na środku kafla
		tail.appearance_flags = RESET_COLOR | KEEP_APART
		add_overlay(tail)
		aq_tail_state = null

// Śrut: siła ran spada z odległością (tg buckshot: wound_falloff_tile = -1)
/obj/item/projectile/bullet/pellet
	wound_falloff_tile = -1

// --- Świst i drżenie przy przelocie kuli ---

/mob/living
	/// Kiedy postać może znowu drgnąć od przelatującej kuli
	var/aq_next_flinch = 0

/obj/item/projectile/Moved(atom/OldLoc, Dir)
	. = ..()
	if(aq_from_gun && fired && !deletion_queued && !QDELETED(src) && isturf(loc) && is_gun_bullet())
		projectile_flyby()

/obj/item/projectile/proc/projectile_flyby()
	for(var/mob/living/nearby in range(1, loc))
		if(nearby == firer || nearby.loc == loc || nearby.stat == DEAD || LAZYACCESS(aq_flyby_heard, nearby))
			continue
		LAZYSET(aq_flyby_heard, nearby, TRUE)
		if(nearby.client && !suppressed)
			nearby.playsound_local(loc, pick(GLOB.aq_bullet_hit_sounds["flyby"]), 40, TRUE)
		if(world.time >= nearby.aq_next_flinch && nearby.stat == CONSCIOUS)
			nearby.aq_next_flinch = world.time + 0.6 SECONDS
			var/flinch_x = rand(-1, 1)
			var/flinch_y = rand(-1, 1)
			animate(nearby, pixel_x = flinch_x, pixel_y = flinch_y, time = 0.5, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			animate(pixel_x = -flinch_x, pixel_y = -flinch_y, time = 0.5, flags = ANIMATION_RELATIVE)

/obj/item/projectile/Destroy()
	aq_flyby_heard = null
	return ..()

// --- Grzechot ostatnich naboi, odjazd krzesła, przechył i obrót broni ---

/obj/item/gun
	/// Do kiedy broń w ręku jest wyprostowana po strzale
	var/aq_aim_pose_until = 0
	/// Odchylenie broni w ręku przy ostatnim strzale (stopnie)
	var/aq_aim_pose_kick = 0
	/// Timer powrotu broni do zwykłej pozycji w ręku
	var/aq_aim_pose_timer

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	if(!istype(user) || tk_firing(user))
		return
	var/shot_recoil = get_shot_recoil(chambered, user)
	play_low_ammo_rattle()
	roll_buckled_from_recoil(user, pbtarget, shot_recoil)
	tilt_gun_sprite(shot_recoil)
	start_aim_pose(user, shot_recoil)

/// Ostatnie naboje w magazynku grzechoczą (CM fire_rattle)
/obj/item/gun/proc/play_low_ammo_rattle()
	return

/obj/item/gun/ballistic/play_low_ammo_rattle()
	if(!magazine || magazine.max_ammo < 5)
		return
	var/left = get_ammo(FALSE)
	if(left > 0 && left <= 3)
		playsound(src, 'sound/weapons/gun_magazine_insert_empty_1.ogg', 15, TRUE, -4, frequency = 1.3)

/// Krzesło na kółkach i wózek odjeżdżają od odrzutu (/vg/)
/obj/item/gun/proc/roll_buckled_from_recoil(mob/living/user, atom/target, shot_recoil)
	var/atom/movable/seat = user.buckled
	if(!seat || !target || !(istype(seat, /obj/structure/chair/office) || istype(seat, /obj/vehicle/ridden/wheelchair)))
		return
	if(seat.anchored)
		return
	var/push_dir = get_dir(target, user)
	if(!push_dir)
		return
	var/steps = clamp(round(shot_recoil / 3), 1, 4)
	for(var/i in 1 to steps)
		addtimer(CALLBACK(src, PROC_REF(roll_seat_step), seat, push_dir), (i - 1) * (i + 1))

/obj/item/gun/proc/roll_seat_step(atom/movable/seat, push_dir)
	if(QDELETED(seat) || !isturf(seat.loc))
		return
	var/old_dir = seat.dir
	step(seat, push_dir)
	seat.setDir(old_dir)

/// Sprite broni podskakuje od odrzutu (Goon do_icon_recoil, Yog DabAnimation): widać w ręce na HUD-zie i na ziemi
/obj/item/gun/proc/tilt_gun_sprite(shot_recoil)
	var/kick = clamp(shot_recoil * 2, 4, 25)
	var/matrix/tilted = matrix()
	tilted.Turn(-kick)
	animate(src, transform = tilted, time = 0.5, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(), time = 2.5, easing = SINE_EASING | EASE_OUT)

/// Po strzale broń w ręku na chwilę unosi się w stronę strzału (zamiast wisieć w dół)
/obj/item/gun/proc/start_aim_pose(mob/living/user, shot_recoil)
	aq_aim_pose_until = world.time + 0.6 SECONDS
	aq_aim_pose_kick = clamp(shot_recoil * 1.5, 0, 15)
	if(aq_aim_pose_timer)
		deltimer(aq_aim_pose_timer)
	aq_aim_pose_timer = addtimer(CALLBACK(src, PROC_REF(end_aim_pose), user), 0.65 SECONDS, TIMER_STOPPABLE)
	// Pojedynczy strzał i ogień ciągły odświeża process_fire() (gun.dm) zaraz po strzale; process_burst() tego nie robi
	if(firing_burst)
		user.update_inv_hands()

/obj/item/gun/proc/end_aim_pose(mob/living/user)
	aq_aim_pose_timer = null
	aq_aim_pose_kick = 0
	if(!QDELETED(user) && user.is_holding(src))
		user.update_inv_hands()

/// Czy broń w ręku jest teraz trzymana „w gotowości” (chwilę po strzale)
/obj/item/gun/proc/is_aim_posed(mob/living/holder)
	return world.time < aq_aim_pose_until

// Po strzale w ręku jest pomniejszony sprite samej broni, wyprostowany w stronę, w którą patrzy postać,
// zamiast zwykłego sprite'a broni wiszącej w dół. Odrzut lekko podbija lufę.
/obj/item/gun/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	. = ..()
	if(!isinhands || !isliving(loc))
		return
	var/mob/living/holder = loc
	if(!is_aim_posed(holder))
		return
	var/mutable_appearance/inhand = .
	if(!istype(inhand))
		return
	var/mutable_appearance/mini = mutable_appearance(icon, icon_state)
	mini.layer = inhand.layer
	mini.plane = inhand.plane
	mini.appearance_flags = inhand.appearance_flags | PIXEL_SCALE
	var/left_hand = (holder.get_held_index_of_item(src) % 2) == 1
	var/center_shift = -(get_cached_width() - world.icon_size) / 2 // karabiny bywają 64x32
	var/matrix/pose = matrix()
	switch(holder.dir)
		if(EAST)
			pose.Scale(0.6, 0.6)
			pose.Turn(-aq_aim_pose_kick)
			pose.Translate(center_shift + 8, -3)
		if(WEST)
			pose.Scale(-0.6, 0.6)
			pose.Turn(aq_aim_pose_kick)
			pose.Translate(center_shift - 8, -3)
		if(SOUTH)
			pose.Scale(0.55, 0.55)
			pose.Turn(90)
			pose.Translate(center_shift + (left_hand ? 7 : -7), -6)
		else
			pose.Scale(0.55, 0.55)
			pose.Turn(-90)
			pose.Translate(center_shift + (left_hand ? -7 : 7), 0)
	mini.transform = pose
	return mini

// --- Statystyki broni w opisie ---

/obj/item/gun/examine(mob/user)
	. = ..()
	var/obj/item/projectile/shown = get_examine_projectile()
	if(!shown || shown.nodamage)
		return
	var/integrity_mult = 0.5 + 0.5 * get_condition() / 100
	var/shot_damage = round(shown.damage * projectile_damage_multiplier * integrity_mult, 0.1)
	var/pellets = 1
	if(chambered?.pellets > 1)
		pellets = chambered.pellets
	var/list/stats = list()
	if(shot_damage > 0)
		if(pellets > 1)
			stats += "obrażenia: <b>[shot_damage] × [pellets] śrucin</b>"
		else
			stats += "obrażenia: <b>[shot_damage]</b>"
		var/to_crit = CEILING(100 / max(shot_damage * pellets, 0.1), 1)
		stats += "trafień do krytycznego stanu (bez pancerza): <b>[to_crit]</b>"
	if(shown.stamina > 0)
		stats += "zmęczenie: <b>[round(shown.stamina * integrity_mult, 0.1)]</b>"
	if(shown.armour_penetration)
		stats += "przebicie pancerza: <b>[shown.armour_penetration]</b>"
	var/shown_spread = max(spread - aq_attachment_accuracy, 0)
	var/spread_degrees = round(shown_spread * 0.55, 0.1)
	if(requires_wielding)
		stats += "rozrzut: <b>[spread_degrees]°</b> (z jednej ręki [round((shown_spread + spread_unwielded) * 0.55, 0.1)]°)"
	else
		stats += "rozrzut: <b>[spread_degrees]°</b>"
	var/single_rate = round(fire_rate ? fire_rate : 10 / CLICK_CD_RANGE, 0.1)
	if(full_auto)
		stats += "szybkostrzelność: <b>[single_rate] strz./s</b> (ogień ciągły [round(10 / max(get_autofire_delay(), 0.1), 0.1)] strz./s)"
	else
		stats += "szybkostrzelność: <b>[single_rate] strz./s</b>"
	. += "<span class='notice'>[jointext(stats, ", ")].</span>"

/// Pocisk do pokazania w opisie: z komory albo z typu amunicji
/obj/item/gun/proc/get_examine_projectile()
	return chambered?.BB

#undef AQ_BULLET_RICOCHETS
#undef AQ_MG_TRACER_INTERVAL
#undef AQ_RICOCHET_MIN_ANGLE
#undef AQ_RICOCHET_MIN_CHANCE
#undef AQ_RICOCHET_MAX_CHANCE

// Dziury po kulach w ścianach: fabryczny „bullet_hole” to ciemna plamka 4×4 px, niewidoczna na ciemnych ścianach Paradise.
// Nasze trzy warianty mają jasny, odpryśnięty brzeg i osmalenie. Cios (WALL_DENT_HIT) zostaje po staremu.
/turf/closed/wall/add_dent(denttype, x = rand(-8, 8), y = rand(-8, 8))
	if(denttype != WALL_DENT_SHOT)
		return ..()
	if(LAZYLEN(dent_decals) >= 15) // MAX_DENT_DECALS z walls.dm (#undef na końcu pliku)
		return
	var/mutable_appearance/decal = mutable_appearance('aquila/icons/effects/bullet_holes.dmi', "bullet_hole[rand(1, 3)]", BULLET_HOLE_LAYER)
	decal.pixel_x = x
	decal.pixel_y = y
	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)
	add_overlay(dent_decals)

// Dziura leży kawałek w głębi ściany, a nie na samej krawędzi, w którą weszła kula. Ściany 3/4 z Paradise (32x40) mają
// u podstawy jasną listwę (5 px nad dołem kafla), a front ściany ciągnie się od niej do górnej krawędzi kafla i wyżej,
// więc tam dziura nie schodzi poniżej frontu.
/obj/item/projectile/proc/get_wall_hole_offset(turf/wall)
	var/depth = 9
	var/hole_x = entry_x + (movement_vector ? movement_vector.pixel_x * depth : 0)
	var/hole_y = entry_y + (movement_vector ? movement_vector.pixel_y * depth : 0)
	var/lowest = -12
	var/highest = 12
	if(wall && findtext("[wall.icon]", "32x40"))
		lowest = -6
		highest = 14
	return list(clamp(round(hole_x), -12, 12), clamp(round(hole_y), lowest, highest))

// Kule odbijają się od każdej ściany i zostawiają w niej dziury, nie tylko w /turf/closed/wall: także w nieniszczalnych
// (komora testowa, ruiny, statki ERT) i w skale. Zwykłe ściany mają własne dent_decals (add_dent wyżej).
/turf/closed
	flags_ricochet = RICOCHET_HARD
	/// Dziury po kulach na ścianach spoza /turf/closed/wall
	var/list/aq_bullet_holes

/turf/closed/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	. = ..()
	// Po ..() kafel mógł się zmienić (skała rozbita kulą kinetyczną), więc typ sprawdzamy dopiero teraz
	if(!isclosedturf(src) || iswallturf(src) || !istype(P) || P.nodamage || !P.movement_vector)
		return
	if((P.damage_type != BRUTE && P.damage_type != BURN) || !prob(75)) // jak dla ścian w on_hit()
		return
	var/list/hole = P.get_wall_hole_offset(src)
	add_bullet_hole(hole[1], hole[2])

/turf/closed/proc/add_bullet_hole(x, y)
	if(LAZYLEN(aq_bullet_holes) >= 15)
		return
	var/mutable_appearance/decal = mutable_appearance('aquila/icons/effects/bullet_holes.dmi', "bullet_hole[rand(1, 3)]", BULLET_HOLE_LAYER)
	decal.pixel_x = x
	decal.pixel_y = y
	if(LAZYLEN(aq_bullet_holes))
		cut_overlay(aq_bullet_holes)
	LAZYADD(aq_bullet_holes, decal)
	add_overlay(aq_bullet_holes)
