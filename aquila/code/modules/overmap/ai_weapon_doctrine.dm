/// AQUILA - działa jako ostateczność dla okrętów AI.
///
/// W piaskownicy działa i obrona punktowa dawały 95% strzałów AI, a rakiety i torpedy leciały średnio z 23-25 pól,
/// czyli z zasięgu dział: AI strzelało tym, co akurat było gotowe, a działa są gotowe zawsze. Teraz okręt AI,
/// który ma amunicję kierowaną pasującą do celu, strzela do niego dalej niż AI_GUNS_CLOSE_RANGE tylko nią;
/// gdy wyrzutnia się przeładowuje albo czeka na salwę floty (ai_torpedo_tactics.dm), nie strzela wcale.
/// Działa wracają z bliska, po wyczerpaniu rakiet i torped albo gdy cel nie pasuje do żadnej amunicji kierowanej
/// (torpedy tylko na cele od MASS_SMALL, rakiety tylko na mniejsze). Przy skończonych zapasach na lotniskowcach
/// (ai_supply.dm) bitwa zaczyna się salwami z dystansu, a kończy działami z bliska.

/// Debug > Toggle AI guns last resort
GLOBAL_VAR_INIT(ai_guns_last_resort_enabled, TRUE)
/// Debug > Toggle AI long range guided fire
GLOBAL_VAR_INIT(ai_long_range_guided_enabled, TRUE)

/// Bliżej działa wolno zawsze
#define AI_GUNS_CLOSE_RANGE 12
/// Do tej odległości okręt strzela torpedą (albo rakietą w mały cel), jeśli jego sensory widzą cel.
/// Bazowe ai_fire() strzela najdalej na max_weapon_range (50), "żeby nikt nie był ścigany spoza zasięgu wzroku";
/// u nas o tym, co okręt widzi, decydują sensory (ai_sensor_suites.dm), więc limit idzie za nimi.
#define AI_GUIDED_MAX_RANGE 120

/// Broń kierowana z amunicją, która pasuje do celu (przeładowanie i salwa nie mają tu znaczenia)
/obj/structure/overmap/proc/has_ai_guided_option(obj/structure/overmap/target)
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if(!(weapon.weapon_control_flags & OSW_CONTROL_AI) || !weapon.is_guided_weapon() || !weapon.get_ammo())
			continue
		if(weapon.is_target_size_valid(target))
			return TRUE
	return FALSE

/// TRUE, gdy okręt AI ma trzymać działa i strzelać do target tylko bronią kierowaną
/obj/structure/overmap/proc/ai_holds_guns_for(obj/structure/overmap/target)
	if(!GLOB.ai_guns_last_resort_enabled || !ai_controlled || !istype(target) || QDELETED(target))
		return FALSE
	if(target.z != z || overmap_dist(src, target) <= AI_GUNS_CLOSE_RANGE)
		return FALSE
	return has_ai_guided_option(target) && can_ai_guided_reach(target)

/// Czy broń kierowana może w target strzelić z obecnego ustawienia: wyrzutnia dziobowa nie sięgnie celu z boku,
/// a wtedy wstrzymane działa oznaczałyby, że okręt nie strzela wcale
/obj/structure/overmap/proc/can_ai_guided_reach(obj/structure/overmap/target)
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if(!(weapon.weapon_control_flags & OSW_CONTROL_AI) || !weapon.is_guided_weapon() || !weapon.get_ammo())
			continue
		if(weapon.is_target_size_valid(target) && weapon.check_valid_fire_angle(target))
			return TRUE
	return FALSE

/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	// Tylko na cel, z którym okręt walczy: flak i działa automatyczne dalej bronią przed innymi (np. myśliwcami)
	if(linked_overmap?.ai_controlled && isovermap(target) && target == linked_overmap.last_target && !is_guided_weapon() && linked_overmap.ai_holds_guns_for(target))
		return FALSE
	return ..()

/// add_enemy() bez zmiany celu walki: strzał z daleka albo na namiar ma tylko zaalarmować cel (i flotę gracza),
/// a nie odciągnąć okręt od tego, z kim walczy
/obj/structure/overmap/proc/ai_mark_enemy(obj/structure/overmap/target)
	var/obj/structure/overmap/fighting = last_target
	if(!istype(fighting) || QDELETED(fighting) || fighting == target)
		add_enemy(target)
		return
	var/hold = ai_hold_fire_until
	var/datum/weakref/hesitated = ai_hesitated_target
	var/next_hesitation = ai_next_hesitation
	add_enemy(target)
	last_target = fighting
	ai_hold_fire_until = hold
	ai_hesitated_target = hesitated
	ai_next_hesitation = next_hesitation

/// Najbliższy wróg dalej niż bazowy zasięg ognia AI i nie dalej niż AI_GUIDED_MAX_RANGE, którego nasze sensory
/// teraz widzą, albo null. contents podawane, żeby dało się testować bez systemu gwiezdnego.
/obj/structure/overmap/proc/get_ai_long_range_target(list/contents)
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/other as anything in contents)
		if(!istype(other) || QDELETED(other) || other == src || other.z != z || other.mass <= MASS_TINY)
			continue
		if(istype(other, /obj/structure/overmap/asteroid) || !is_ai_hostile(other))
			continue
		var/dist = overmap_dist(src, other)
		if(dist <= max_weapon_range || dist > AI_GUIDED_MAX_RANGE || dist >= best_dist)
			continue
		if(dist > other.get_detection_range(src)) // nasze sensory go nie sięgają
			continue
		best_dist = dist
		best = other
	return best

/// Torpeda (albo rakieta w mały cel) w kogoś, kogo widzimy dalej niż bazowe 50 pól
/obj/structure/overmap/proc/update_ai_long_range_fire()
	if(!GLOB.ai_long_range_guided_enabled || !ai_controlled || mass <= MASS_TINY || ai_fleeing || is_ai_scouting() || !current_system)
		return
	if(GLOB.ai_morale_enabled && world.time < ai_hold_fire_until)
		return
	if(!is_ai_missile_ship())
		return
	var/obj/structure/overmap/target = get_ai_long_range_target(current_system.system_contents)
	if(!target)
		return
	var/datum/overmap_ship_weapon/weapon = get_ai_guided_weapon(target)
	if(!weapon)
		return
	ai_mark_enemy(target) // jak w bazowym ai_fire(): gracz dostaje alarm, że jest namierzany
	ai_scout_event("[src] strzela z daleka ([overmap_dist(src, target)] pól, własne sensory: [get_contact_suite(target) || "?"]) w [target]")
	fire_weapon(target, firing_weapon = weapon, ai_aim = TRUE)

/obj/structure/overmap/update_ai_sensor_use()
	. = ..()
	update_ai_long_range_fire()

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_guns_last_resort
	. += /client/proc/toggle_ai_long_range_guided

/client/proc/toggle_ai_long_range_guided()
	set category = "Debug"
	set name = "Toggle AI long range guided fire"
	set desc = "Włącza lub wyłącza strzały AI torpedami i rakietami dalej niż 50 pól, do 120, gdy sensory widzą cel."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_long_range_guided_enabled = !GLOB.ai_long_range_guided_enabled
	var/state = GLOB.ai_long_range_guided_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] daleki ostrzał torpedami u AI.")
	log_admin("[key_name(usr)] toggled AI long range guided fire to [GLOB.ai_long_range_guided_enabled].")

/client/proc/toggle_ai_guns_last_resort()
	set category = "Debug"
	set name = "Toggle AI guns last resort"
	set desc = "Włącza lub wyłącza zasadę, że AI z amunicją kierowaną strzela z dystansu tylko rakietami i torpedami, a działami z bliska."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_guns_last_resort_enabled = !GLOB.ai_guns_last_resort_enabled
	var/state = GLOB.ai_guns_last_resort_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] działa jako ostateczność u AI.")
	log_admin("[key_name(usr)] toggled AI guns last resort to [GLOB.ai_guns_last_resort_enabled].")

#undef AI_GUNS_CLOSE_RANGE
#undef AI_GUIDED_MAX_RANGE
