/// AQUILA - overmap scale: one system is the whole battlefield, so everything on the overmap moves slower and guns reach
/// only half as far. Missiles and torpedoes keep their range and become the long range weapons, for us and for the AI.
/// Core hooks: physics.dm process() (speed cap and thrust) and collide() (ram force). Design: raport/sensory_03_ustalenia.md

/// Admin switch (Debug > Toggle overmap scale)
GLOBAL_VAR_INIT(overmap_scale_enabled, TRUE)

/// Speed cap and thrust multiplier for everything on an overmap level (ships, fighters, boost included)
#define OVERMAP_SPEED_MULT 0.5
/// Range multiplier for unguided overmap projectiles (guns, PDC, phasers)
#define OVERMAP_GUN_RANGE_MULT 0.5
/// Projectiles with a range this big are relays or special rounds, leave them alone
#define OVERMAP_GUN_RANGE_SPECIAL 255
/// The AI does not fire unguided weapons beyond this (default projectile range 50 * OVERMAP_GUN_RANGE_MULT)
#define OVERMAP_AI_GUN_RANGE 25
/// AI carriers keep about this far from their target and let the fighters do the work
#define AI_CARRIER_STANDOFF 40
/// Torpedo ships stand off at most this far, but close enough to keep the target on their sensors
#define AI_TORPEDO_STANDOFF 40
/// Dead band around the standoff distance in which the AI orbits instead of closing or opening the range
#define AI_STANDOFF_BAND 5

/// Speed multiplier for this ship right now; 1 off the overmap (fighters in a hangar, ships on station levels)
/obj/structure/overmap/proc/get_overmap_speed_mult()
	if(!GLOB.overmap_scale_enabled || !z || !SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		return 1
	return OVERMAP_SPEED_MULT

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	. = ..()
	var/obj/item/projectile/proj = .
	// The projectile is fired in a spawn() inside ..(), so its range can still be changed here
	if(!istype(proj) || istype(proj, /obj/item/projectile/guided_munition) || proj.range >= OVERMAP_GUN_RANGE_SPECIAL)
		return
	if(get_overmap_speed_mult() == 1)
		return
	proj.range = round(proj.range * OVERMAP_GUN_RANGE_MULT)

/// AI fleets shredded each other in under a minute, before fear, retreat or flanking could matter.
/// Hits between two AI ships do less damage; anything a player ship fires or takes is unchanged.
/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/shooter = P?.overmap_firer
	if(!GLOB.overmap_scale_enabled || !ai_controlled || !istype(shooter) || !shooter.ai_controlled)
		return ..()
	var/full_damage = P.damage
	P.damage *= GLOB.ai_vs_ai_damage_mult // ai_tuning.dm
	. = ..()
	// A round that pierces or bounces off a shield goes on at full damage, it may hit a player ship next
	if(!QDELETED(P))
		P.damage = full_damage

/// TRUE for weapons that fire missiles or torpedoes
/datum/overmap_ship_weapon/proc/is_guided_weapon()
	return used_nonphysical_ammo == OSW_AMMO_MISSILE || used_nonphysical_ammo == OSW_AMMO_TORPEDO || ispath(standard_projectile_type, /obj/item/projectile/guided_munition)

/datum/overmap_ship_weapon/is_valid_ai_target(obj/structure/overmap/target)
	. = ..()
	if(!. || !GLOB.overmap_scale_enabled || is_guided_weapon())
		return
	// Guns would not reach anyway, so the AI saves them and picks missiles at long range
	if(overmap_dist(linked_overmap, target) > OVERMAP_AI_GUN_RANGE)
		return FALSE

/// AI carrier: launches fighters and is not a battleship (Fist of Sol and the like still brawl)
/obj/structure/overmap/proc/is_ai_carrier()
	return length(ai_fighter_type) && !CHECK_BITFIELD(ai_flags, AI_FLAG_BATTLESHIP)

/// Torpedoes left and a launcher to fire them
/obj/structure/overmap/proc/has_ai_torpedoes()
	if(torpedoes <= 0 || mass <= MASS_TINY) // Bombers and fighters keep diving in
		return FALSE
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if(weapon.used_nonphysical_ammo == OSW_AMMO_TORPEDO && (weapon.weapon_control_flags & OSW_CONTROL_AI))
			return TRUE
	return FALSE

/// Distance this AI ship wants to keep from target, 0 to close in as usual
/obj/structure/overmap/proc/get_ai_standoff_range(atom/target)
	var/obj/structure/overmap/enemy = target
	if(!GLOB.overmap_scale_enabled || !ai_controlled || !istype(enemy) || QDELETED(enemy) || enemy.faction == faction || enemy == defense_target || CHECK_BITFIELD(ai_flags, AI_FLAG_BOARDER))
		return 0
	if(is_ai_carrier())
		return AI_CARRIER_STANDOFF
	// Przewaga wroga: zanim zejdziemy na zasięg dział, czekamy na resztę floty (ai_formation.dm)
	if(ai_waits_for_support(enemy))
		return OVERMAP_AI_GUN_RANGE + AI_STANDOFF_BAND * 2
	// Torpedo launchers only fire at MASS_SMALL and up; once the torpedoes run out the ship closes in with its guns
	if(enemy.mass >= MASS_SMALL && has_ai_torpedoes())
		// Stay inside our own detection range of the target, or the torpedo ship loses it and wanders off.
		// From the base tracking range: our own radar pulses double it for 5 s and the ship would move in and out every pulse
		var/tracking = base_tracking_range || max_tracking_range
		var/sensor_limit = max(tracking * enemy.sensor_signature, SENSOR_MIN_DETECTION) - AI_STANDOFF_BAND
		return clamp(sensor_limit, OVERMAP_AI_GUN_RANGE + AI_STANDOFF_BAND, AI_TORPEDO_STANDOFF)
	return 0

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	// Engines off, coasting away from someone who cannot see us (ai_sensor_use.dm)
	if(!ram_target && ai_coasting_silent(target))
		return
	// Przekierowania poniżej podają bazowemu move_toward() kafelek zamiast okrętu, a ono przy
	// omijaniu przeszkód czyta current_system.system_contents bez zabezpieczenia (ai-skynet.dm).
	// Okręt poza systemem gwiezdnym zachowuje się więc jak dotąd.
	if(!ram_target && current_system)
		// Cold ambush: the fleet waits instead of flying around (ai_fleet_picture.dm)
		if(is_ai_lying_in_wait())
			return
		// Przewaga wroga: wracamy do swoich zamiast lecieć w nich samemu (ai_formation.dm)
		var/turf/zbiorka = get_ai_regroup_point()
		if(zbiorka)
			return ..(zbiorka, FALSE, ignore_all_collisions)
		// We hold this target only through the fleet's report: fly at the reported picture, not at the real ship
		var/turf/blind = get_ai_blind_point(target)
		if(blind)
			return ..(blind, FALSE, ignore_all_collisions)
	var/standoff = ram_target ? 0 : get_ai_standoff_range(target)
	if(!standoff)
		return ..()
	var/dist = overmap_dist(src, target)
	// Okrąg dystansu: lecimy do punktu na nim, zamiast hamować tłumikami i wisieć (ai_formation.dm).
	// Stary kod zatrzymywał okręt w miejscu - na nagraniach lotniskowce stały nawet 68% czasu.
	if(dist <= standoff + AI_STANDOFF_BAND && current_system)
		var/turf/spot = get_ai_standoff_point(target, standoff)
		if(spot)
			return ..(spot, FALSE, ignore_all_collisions)
	if(dist < standoff - AI_STANDOFF_BAND)
		move_away_from(target)
		enable_dampeners()
		return
	if(dist <= standoff + AI_STANDOFF_BAND)
		circle_around(target) // Orbit at range while the missiles and fighters do their job
		enable_dampeners()
		return
	return ..()

/datum/ai_goal/retreat/action(obj/structure/overmap/OM)
	// Carriers hold at standoff range instead of running away for good; other supply ships still run
	if(!OM.is_ai_carrier() || !OM.get_ai_standoff_range(OM.last_target))
		return ..()
	OM.current_goal = src
	OM.move_toward(OM.last_target)

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_overmap_scale

/client/proc/toggle_overmap_scale()
	set category = "Debug"
	set name = "Przełącz skalę overmapy"
	set desc = "Włącza lub wyłącza spowolnienie okrętów i krótszy zasięg dział na overmapie."
	if(!check_rights(R_DEBUG))
		return
	GLOB.overmap_scale_enabled = !GLOB.overmap_scale_enabled
	var/state = GLOB.overmap_scale_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] skalę overmapy (wolniejsze okręty, krótsze działa).")
	log_admin("[key_name(usr)] toggled overmap scale to [GLOB.overmap_scale_enabled].")

#undef OVERMAP_SPEED_MULT
#undef OVERMAP_GUN_RANGE_MULT
#undef OVERMAP_GUN_RANGE_SPECIAL
#undef OVERMAP_AI_GUN_RANGE
#undef AI_CARRIER_STANDOFF
#undef AI_TORPEDO_STANDOFF
#undef AI_STANDOFF_BAND
