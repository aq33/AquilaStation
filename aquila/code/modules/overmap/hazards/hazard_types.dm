/// AQUILA - rodzaje stref zagrożeń na overmapie (baza: hazards/hazard_zone.dm).
/// Prędkości w polach overmapy na sekundę (velocity.ln()); pełna prędkość okrętu gracza to ~1,75 pola/s na wprost
/// (speed_limit 3,5 × skala overmapy 0,5), myśliwca ~4.

/// Odstęp między ostrzeżeniami o zbyt dużej prędkości w polu
#define HAZARD_SPEED_WARNING_COOLDOWN (30 SECONDS)
/// Część prędkości bezpiecznej (na oś), do której zwalnia AI w polu; po przekątnej wychodzi ~0,85 prędkości bezpiecznej
#define HAZARD_AI_SAFE_FRACTION 0.6

// ---- Pole zależne od prędkości (Shiptest: debris) ----

/obj/effect/overmap_anomaly/hazard/speed
	name = "pole odłamków"
	enter_sound = 'sound/effects/meteorimpact.ogg'
	/// Do tej prędkości (pola/s) przelot jest bezpieczny
	var/safe_speed = 0.9
	/// Ile punktów procentowych szansy dokłada każde pole/s ponad prędkość bezpieczną (Shiptest: 15% + nadwyżka)
	var/excess_chance_mult = 30
	/// Meteory z eventu meteorów, którymi pole sypie w okręt z wnętrzem (wagi)
	var/list/meteor_types = list(/obj/effect/meteor/dust = 3, /obj/effect/meteor/medium = 8, /obj/effect/meteor/big = 1)
	/// Ułamek wytrzymałości, który traci okręt bez wnętrza przy uderzeniu
	var/hull_damage = 0.04
	/// Komunikat dla okrętu bez wnętrza przy uderzeniu
	var/hit_message = "Odłamek skalny uderza w kadłub!"
	/// Nakładki: ikona okruchów, stany, kolor, ile ich
	var/detail_icon = 'nsv13/icons/overmap/stellarbodies/asteroidfield/icefield/asteroid_ice_32x.dmi'
	var/list/detail_states = list("harmless-1", "harmless-2", "harmless-3", "harmless-4")
	var/detail_color = "#b49a7a"
	var/detail_count = 8

/obj/effect/overmap_anomaly/hazard/speed/Initialize(mapload, system)
	ai_speed_cap = safe_speed * HAZARD_AI_SAFE_FRACTION
	return ..()

/obj/effect/overmap_anomaly/hazard/speed/add_hazard_details()
	for(var/i in 1 to detail_count)
		add_scattered_detail(detail_icon, pick(detail_states), 32, rand(8, 14) / 10, 220, detail_color)

/obj/effect/overmap_anomaly/hazard/speed/get_enter_message(obj/structure/overmap/OM)
	var/top_speed = OM.speed_limit * OM.get_overmap_speed_mult()
	if(top_speed <= 0)
		return "[enter_message] Zwolnijcie, szybki przelot grozi zderzeniami."
	var/percent = clamp(round(100 * safe_speed / top_speed, 5), 5, 100)
	return "[enter_message] Bezpieczna prędkość to około [percent]% prędkości maksymalnej okrętu."

/obj/effect/overmap_anomaly/hazard/speed/get_affect_chance(obj/structure/overmap/OM)
	var/speed = OM.velocity ? OM.velocity.ln() : 0
	if(speed <= safe_speed)
		return 0
	return chance_to_affect + (speed - safe_speed) * excess_chance_mult

/obj/effect/overmap_anomaly/hazard/speed/hazard_tick(obj/structure/overmap/OM)
	var/chance = get_affect_chance(OM)
	if(chance <= 0)
		return
	if(world.time >= OM.next_hazard_speed_warning)
		OM.next_hazard_speed_warning = world.time + HAZARD_SPEED_WARNING_COOLDOWN
		OM.relay(null, "<span class='warning'>[name]: za duża prędkość, grożą nam zderzenia z odłamkami!</span>")
	if(prob(chance))
		affect_ship(OM)

/obj/effect/overmap_anomaly/hazard/speed/affect_ship(obj/structure/overmap/OM)
	if(OM.has_hazard_interior() && OM.launch_hazard_meteor(meteor_types))
		return
	hull_hit(OM, hull_damage, hit_message)

/// Pole szczątków: szybki przelot dziurawi kadłub, a pole zasłania czujniki (Shiptest: debris, opacity żetonu)
/obj/effect/overmap_anomaly/hazard/speed/debris_field
	name = "Pole szczątków"
	desc = "Chmura odłamków po dawnych okrętach. Utrudnia namiar czujnikom, a szybki przelot kończy się dziurami w kadłubie."
	enter_message = "Wchodzimy w pole szczątków. Czujniki widzą słabiej."
	exit_message = "Opuściliśmy pole szczątków."
	hit_message = "Odłamek wraku uderza w kadłub!"
	radius_range = list(7, 12)
	zone_color = "#8a8f99"
	zone_alpha = 70
	safe_speed = 1
	meteor_types = list(/obj/effect/meteor/dust = 6, /obj/effect/meteor/medium = 3)
	hull_damage = 0.03
	signature_mult = 0.75
	sensor_mult = 0.75
	interference = 15
	detail_states = list("particle-1", "particle-2", "particle-3", "particle-4", "particle-5")
	detail_color = "#9aa0aa"
	detail_count = 10

/obj/effect/overmap_anomaly/hazard/speed/debris_field/dense
	name = "Gęste pole szczątków"
	safe_speed = 0.7
	radius_range = list(9, 14)
	meteor_types = list(/obj/effect/meteor/dust = 3, /obj/effect/meteor/medium = 6, /obj/effect/meteor/big = 1)
	hull_damage = 0.05
	signature_mult = 0.6
	sensor_mult = 0.6
	interference = 30
	zone_alpha = 90
	detail_count = 14

// ---- Pole przyciągania (kafel „Anomalia grawitacyjna”) ----

/obj/effect/overmap_anomaly/hazard/gravity_well
	name = "Pole przyciągania"
	desc = "Zagłębienie czasoprzestrzeni wokół zapadniętej masy. Ściąga okręty do środka: z pracującymi silnikami da się uciec, bez nich nie."
	enter_message = "Wchodzimy w pole przyciągania. Silniki muszą pracować, inaczej ściągnie nas do środka."
	exit_message = "Wyrwaliśmy się z pola przyciągania."
	enter_sound = 'sound/effects/empulse.ogg'
	radius_range = list(10, 14)
	zone_color = "#d0d0ff"
	zone_alpha = 45
	chance_to_affect = 0
	sensor_mult = 0.85
	/// Przyspieszenie w stronę środka (prędkość overmapy na sekundę): na brzegu i w samym środku
	var/edge_pull = 0.04
	var/core_pull = 0.14
	/// W samym środku (do core_radius pól) okręt traci core_damage wytrzymałości kadłuba na sekundę
	var/core_radius = 2
	var/core_damage = 0.004

/obj/effect/overmap_anomaly/hazard/gravity_well/add_hazard_details()
	for(var/i in 1 to 3)
		add_scattered_detail('icons/effects/light_overlays/light_352.dmi', "light", 352, radius * world.icon_size / 352 * (0.35 + i * 0.2), 35, "#e8e8ff", 0)

/obj/effect/overmap_anomaly/hazard/gravity_well/process(delta_time)
	. = ..()
	if(!GLOB.overmap_hazards_enabled)
		return
	for(var/obj/structure/overmap/OM as anything in affecting)
		if(!QDELETED(OM))
			pull_ship(OM, delta_time)

/// Przyspiesza okręt w stronę środka pola: słabo na brzegu, mocniej w środku; w samym środku kruszy kadłub
/obj/effect/overmap_anomaly/hazard/gravity_well/proc/pull_ship(obj/structure/overmap/OM, delta_time = 1)
	var/dx = x - OM.x
	var/dy = y - OM.y
	var/dist = sqrt(dx * dx + dy * dy)
	if(dist <= core_radius && OM.max_integrity)
		OM.take_damage(OM.max_integrity * core_damage * delta_time, BRUTE, "overmap_heavy", nsv_damagesound = FALSE)
	if(dist < 0.5 || !OM.velocity)
		return
	var/pull = edge_pull + (core_pull - edge_pull) * clamp(1 - dist / max(radius, 1), 0, 1)
	OM.velocity.a += dx / dist * pull * delta_time
	OM.velocity.e += dy / dist * pull * delta_time

#undef HAZARD_SPEED_WARNING_COOLDOWN
#undef HAZARD_AI_SAFE_FRACTION
