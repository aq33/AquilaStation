/// AQUILA - zwiad myśliwców i łącze danych dla okrętów rakietowych AI.
///
/// Rakiety i torpedy sięgają 250 pól, ale AI strzelało nimi tylko do celu, który samo widzi, i nie dalej niż
/// na 50 pól (ai_fire w ai-skynet.dm). W piaskownicy: torpedy średnio z 23 pól, działa 95% strzałów,
/// zero strzałów do celu, którego strzelający nie widział. Tu, jak w prawdziwej flocie:
/// - jeden myśliwiec na lotniskowiec leci na zwiad: krąży na granicy, z której widzi wroga, sam zimny i cichy;
/// - gdy okręt rakietowy z jego floty jest gotowy do salwy, zwiadowca namierza cel radarem frontalnym
///   (cel musi być przed nosem). Namierzanie to emisja: cel dostaje namiar na zwiadowcę;
/// - okręt rakietowy strzela na przekazany namiar. Torpeda trzyma cel, dopóki trwa namierzanie; potem
///   leci prosto, chyba że jest już na tyle blisko, że łapie cel własną głowicą;
/// - zwiad się kończy, gdy flota wchodzi w zasięg dział, zwiadowca zostanie wykryty, nie ma już komu
///   celować albo minie czas służby. Wtedy myśliwiec wraca do zwykłych zadań, czyli do ataku.
/// Na razie tylko myśliwce mają radar frontalny; duże okręty namierzają dookoła (radar operatora przyjdzie później).

/// Debug > Toggle AI scouting
GLOBAL_VAR_INIT(ai_scouting_enabled, TRUE)

/// Jak długo myśliwiec jest na zwiadzie, zanim zastąpi go inny
#define AI_SCOUT_DUTY (90 SECONDS)
/// Po zakończeniu zwiadu ten sam myśliwiec przez chwilę nie wraca na zwiad
#define AI_SCOUT_COOLDOWN (40 SECONDS)
/// Zasięg namierzania radarem frontalnym myśliwca i połowa jego stożka
#define AI_SCOUT_LOCK_RANGE 35
#define AI_SCOUT_LOCK_CONE 60
/// Przy namierzaniu myśliwiec leci skosem, z celem tuż w stożku, żeby nie pchać się prosto na niego
#define AI_SCOUT_CRANK 50
/// Bliżej celu zwiad nie ma sensu: myśliwiec jest już w walce
#define AI_SCOUT_MIN_RANGE 12
/// Okręt floty tak blisko celu: czas na działa, zwiadowca dołącza do ataku
#define AI_SCOUT_RELEASE_RANGE 25
/// Jak daleko okręt rakietowy strzela na namiar ze zwiadu (pocisk sięga 250, ale tyle leci długo)
#define AI_DATALINK_RANGE 120
/// Bez namierzania torpeda trzyma cel tylko z tej odległości (własna głowica)
#define AI_SEEKER_RANGE 15

/obj/structure/overmap
	/// AQUILA - wróg, którego ten myśliwiec śledzi na zwiadzie
	var/obj/structure/overmap/ai_scout_target
	/// AQUILA - world.time, do którego trwa zwiad
	var/ai_scout_until = 0
	/// AQUILA - world.time, od którego myśliwiec może znów pójść na zwiad
	var/ai_scout_ready_at = 0
	/// AQUILA - world.time ostatniego rozpoczęcia namierzania
	var/ai_scout_lock_started = 0
	/// AQUILA - 1 albo -1: w którą stronę zwiadowca leci skosem przy namierzaniu
	var/ai_scout_side = 0
	/// AQUILA - zwiadowca, na którego namiar ten okręt właśnie strzela
	var/obj/structure/overmap/ai_datalink_firing
	/// AQUILA - lazy list: pocisk => zwiadowca, którego namierzanie go prowadzi
	var/list/ai_datalink_shots

/datum/fleet
	/// AQUILA - lazy list myśliwców na zwiadzie
	var/list/ai_scouts

// ---------------------------------------------------------------- kto i na kogo

/// Okręt (nie myśliwiec) z bronią kierowaną, której AI może użyć, i z amunicją do niej
/obj/structure/overmap/proc/is_ai_missile_ship()
	if(mass <= MASS_TINY)
		return FALSE
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if((weapon.weapon_control_flags & OSW_CONTROL_AI) && weapon.is_guided_weapon() && weapon.get_ammo())
			return TRUE
	return FALSE

/// Broń kierowana gotowa do strzału w target, albo null
/obj/structure/overmap/proc/get_ai_guided_weapon(obj/structure/overmap/target)
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if((weapon.weapon_control_flags & OSW_CONTROL_AI) && weapon.is_guided_weapon() && weapon.can_fire(target))
			return weapon
	return null

/// Ilu zwiadowców potrzebuje flota: jeden na lotniskowiec, ale tylko gdy ma dla kogo celować
/datum/fleet/proc/ai_scout_slots()
	if(!GLOB.ai_scouting_enabled)
		return 0
	var/strzelcy = FALSE
	for(var/obj/structure/overmap/ship as anything in all_ships)
		if(!QDELETED(ship) && ship.ai_controlled && ship.is_ai_missile_ship())
			strzelcy = TRUE
			break
	if(!strzelcy)
		return 0
	var/lotniskowce = 0
	for(var/obj/structure/overmap/supply as anything in taskforces["supply"])
		if(!QDELETED(supply))
			lotniskowce++
	return max(lotniskowce, 1)

/datum/fleet/proc/prune_ai_scouts()
	for(var/obj/structure/overmap/scout as anything in ai_scouts?.Copy())
		if(QDELETED(scout) || !scout.ai_scout_target)
			LAZYREMOVE(ai_scouts, scout)

/// Cel dla zwiadowcy: najbliższy mu duży wróg z obrazu sytuacji floty albo z jego własnego celu
/datum/fleet/proc/get_ai_scout_target(obj/structure/overmap/scout)
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	var/list/kandydaci = list()
	for(var/obj/structure/overmap/contact as anything in ai_contact_picture)
		kandydaci += contact
	if(istype(scout.last_target, /obj/structure/overmap))
		kandydaci += scout.last_target
	for(var/obj/structure/overmap/contact as anything in kandydaci)
		if(QDELETED(contact) || contact.z != scout.z || contact.mass <= MASS_TINY || !scout.is_ai_hostile(contact))
			continue
		var/dist = overmap_dist(scout, contact)
		if(dist < best_dist)
			best_dist = dist
			best = contact
	return best

// ---------------------------------------------------------------- zwiadowca

/obj/structure/overmap/proc/start_ai_scout(obj/structure/overmap/target)
	ai_scout_target = target
	ai_scout_until = world.time + AI_SCOUT_DUTY
	ai_scout_side = pick(1, -1)
	LAZYOR(fleet.ai_scouts, src)

/obj/structure/overmap/proc/stop_ai_scout()
	if(ai_scout_target && (ai_scout_target in target_painted))
		dump_lock(ai_scout_target)
	ai_scout_target = null
	ai_scout_ready_at = world.time + AI_SCOUT_COOLDOWN
	LAZYREMOVE(fleet?.ai_scouts, src)

/// Czy któryś okręt rakietowy floty mógłby teraz strzelić w target na namiar ze zwiadu
/obj/structure/overmap/proc/has_ai_datalink_shooter(obj/structure/overmap/target)
	for(var/obj/structure/overmap/ship as anything in fleet?.all_ships)
		if(QDELETED(ship) || ship == src || !ship.ai_controlled || ship.z != z)
			continue
		if(overmap_dist(ship, target) <= AI_DATALINK_RANGE && ship.get_ai_guided_weapon(target))
			return TRUE
	return FALSE

/// Czy cel jest w stożku i zasięgu radaru frontalnego (sama geometria)
/obj/structure/overmap/proc/ai_lock_geometry_ok(obj/structure/overmap/target)
	if(QDELETED(target) || target.z != z || overmap_dist(src, target) > AI_SCOUT_LOCK_RANGE)
		return FALSE
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return TRUE
	return abs(closer_angle_difference(angle, bearing)) <= AI_SCOUT_LOCK_CONE

/// Powód, dla którego zwiad ma się skończyć, albo null
/obj/structure/overmap/proc/get_ai_scout_end_reason()
	var/obj/structure/overmap/target = ai_scout_target
	if(QDELETED(target) || target.z != z)
		return "cel zniknął"
	if(world.time >= ai_scout_until)
		return "koniec służby"
	if(ai_fleeing)
		return "ucieka"
	if(overmap_dist(src, target) < AI_SCOUT_MIN_RANGE)
		return "za blisko, walka"
	if(!fleet?.ai_scout_slots())
		return "nie ma dla kogo celować"
	for(var/obj/structure/overmap/ship as anything in fleet.all_ships)
		if(!QDELETED(ship) && ship != src && ship.mass > MASS_TINY && ship.z == z && overmap_dist(ship, target) <= AI_SCOUT_RELEASE_RANGE)
			return "flota w zasięgu dział"
	// Wykryty bez własnego namierzania: zwiad przestał być cichy
	if(!(target in target_painted) && is_detected_by(target))
		return "wykryty"
	return null

/// Co tik AI myśliwca: zacząć, prowadzić albo skończyć zwiad
/obj/structure/overmap/proc/update_ai_scout()
	if(!fleet)
		return
	fleet.prune_ai_scouts()
	if(ai_scout_target)
		if(get_ai_scout_end_reason())
			stop_ai_scout()
			return
		update_ai_scout_lock()
		return
	if(world.time < ai_scout_ready_at || ai_fleeing || LAZYLEN(fleet.ai_scouts) >= fleet.ai_scout_slots())
		return
	var/obj/structure/overmap/target = fleet.get_ai_scout_target(src)
	if(target && overmap_dist(src, target) >= AI_SCOUT_MIN_RANGE)
		start_ai_scout(target)

/// Namierzanie radarem frontalnym tylko wtedy, gdy ktoś czeka z salwą; namierzanie to emisja, cel ją słyszy
/obj/structure/overmap/proc/update_ai_scout_lock()
	var/obj/structure/overmap/target = ai_scout_target
	var/trzyma = (target in target_painted)
	if(!has_ai_datalink_shooter(target))
		if(trzyma)
			dump_lock(target) // nikt nie strzela: nie świecimy po próżnicy
		return
	var/widzi = target.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE
	if(trzyma)
		if(!widzi || !ai_lock_geometry_ok(target))
			dump_lock(target)
			return
		target.hear_radar_emission(src)
		return
	if(widzi && ai_lock_geometry_ok(target) && world.time >= ai_scout_lock_started + lockon_time + 1 SECONDS)
		ai_scout_lock_started = world.time
		start_lockon(target)
		target.hear_radar_emission(src)

/// Dokąd leci zwiadowca: krąży na granicy, z której widzi cel, a przy namierzaniu leci skosem z celem w stożku
/obj/structure/overmap/proc/get_ai_scout_point()
	var/obj/structure/overmap/target = ai_scout_target
	if(QDELETED(target))
		return null
	var/list/best = get_best_suite(target)
	var/promien = clamp(best[2] * 0.8, AI_SCOUT_MIN_RANGE + 2, AI_SCOUT_LOCK_RANGE)
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return null
	var/namierza = has_ai_datalink_shooter(target)
	if(!namierza)
		var/turf/orbita = get_ai_standoff_point(target, promien)
		if(orbita)
			return orbita
	// Skos: cel w stożku radaru, ale bez lotu prosto na niego
	var/kurs = bearing + ai_scout_side * (overmap_dist(src, target) > promien ? AI_SCOUT_CRANK * 0.5 : AI_SCOUT_CRANK)
	return locate(clamp(round(x + sin(kurs) * 16), 1, world.maxx), clamp(round(y + cos(kurs) * 16), 1, world.maxy), z)

// ---------------------------------------------------------------- strzał przez łącze danych

/// Pierwszy cel, na który zwiadowca floty trzyma namierzanie w zasięgu łącza, jako list(zwiadowca, cel), albo null
/obj/structure/overmap/proc/get_ai_datalink_target()
	for(var/obj/structure/overmap/scout as anything in fleet?.ai_scouts)
		var/obj/structure/overmap/target = scout?.ai_scout_target
		if(QDELETED(scout) || QDELETED(target) || !(target in scout.target_painted))
			continue
		if(target.z != z || overmap_dist(src, target) > AI_DATALINK_RANGE)
			continue
		return list(scout, target)
	return null

/// Czy pocisk ma dalej trzymać cel: tak, dopóki zwiadowca go namierza albo pocisk jest dość blisko dla własnej głowicy
/proc/ai_datalink_keeps_homing(obj/structure/overmap/scout, obj/structure/overmap/target, dist_to_target)
	if(QDELETED(target))
		return FALSE
	if(!QDELETED(scout) && (target in scout.target_painted))
		return TRUE
	return dist_to_target <= AI_SEEKER_RANGE

/obj/structure/overmap/proc/update_ai_datalink_fire()
	for(var/obj/item/projectile/shot as anything in ai_datalink_shots?.Copy())
		if(QDELETED(shot) || !shot.homing)
			LAZYREMOVE(ai_datalink_shots, shot)
			continue
		var/obj/structure/overmap/target = shot.homing_target
		var/dist = istype(target) ? get_dist(shot, target) : INFINITY
		if(!ai_datalink_keeps_homing(ai_datalink_shots[shot], target, dist))
			shot.homing_target = null // jak przy tarczy w damage.dm: dalej leci prosto
			shot.homing = FALSE
			LAZYREMOVE(ai_datalink_shots, shot)
	if(mass <= MASS_TINY || ai_fleeing)
		return
	var/list/namiar = get_ai_datalink_target()
	if(!namiar)
		return
	var/obj/structure/overmap/target = namiar[2]
	var/datum/overmap_ship_weapon/weapon = get_ai_guided_weapon(target)
	if(!weapon)
		return
	ai_datalink_firing = namiar[1]
	fire_weapon(target, firing_weapon = weapon, ai_aim = TRUE)
	ai_datalink_firing = null

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	. = ..()
	if(ai_datalink_firing && istype(., /obj/item/projectile/guided_munition))
		LAZYSET(ai_datalink_shots, ., ai_datalink_firing)

// ---------------------------------------------------------------- wpięcie

/obj/structure/overmap/update_ai_sensor_use()
	. = ..()
	if(!GLOB.ai_scouting_enabled || !ai_controlled || QDELETED(src))
		return
	if(mass <= MASS_TINY)
		update_ai_scout()
	update_ai_datalink_fire()

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	if(ai_scout_target && !ram_target && GLOB.ai_scouting_enabled)
		var/turf/punkt = get_ai_scout_point()
		if(punkt)
			return ..(punkt, FALSE, ignore_all_collisions)
	return ..()

/// Zwiadowca nie strzela: strzał to ciepło i błysk, a jego robotą jest widzieć, nie walczyć
/obj/structure/overmap/ai_fire(obj/structure/overmap/target)
	if(ai_scout_target && GLOB.ai_scouting_enabled)
		return
	return ..()

/obj/structure/overmap/ai_elite_fire(obj/structure/overmap/target)
	if(ai_scout_target && GLOB.ai_scouting_enabled)
		return
	return ..()

/obj/structure/overmap/get_ai_tactic()
	if(ai_scout_target && !ai_fleeing)
		return (ai_scout_target in target_painted) ? "naprowadza" : "zwiad"
	return ..()

/obj/structure/overmap/Destroy()
	if(fleet)
		LAZYREMOVE(fleet.ai_scouts, src)
	ai_scout_target = null
	ai_datalink_firing = null
	ai_datalink_shots = null
	return ..()

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_scouting

/client/proc/toggle_ai_scouting()
	set category = "Debug"
	set name = "Toggle AI scouting"
	set desc = "Włącza lub wyłącza zwiad myśliwców AI z namierzaniem radarem i strzał okrętów rakietowych na ich namiar."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_scouting_enabled = !GLOB.ai_scouting_enabled
	var/state = GLOB.ai_scouting_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] zwiad myśliwców i łącze danych u AI.")
	log_admin("[key_name(usr)] toggled AI scouting to [GLOB.ai_scouting_enabled].")

#undef AI_SCOUT_DUTY
#undef AI_SCOUT_COOLDOWN
#undef AI_SCOUT_LOCK_RANGE
#undef AI_SCOUT_LOCK_CONE
#undef AI_SCOUT_CRANK
#undef AI_SCOUT_MIN_RANGE
#undef AI_SCOUT_RELEASE_RANGE
#undef AI_DATALINK_RANGE
#undef AI_SEEKER_RANGE
