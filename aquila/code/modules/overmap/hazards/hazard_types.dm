/// AQUILA - rodzaje stref zagrożeń na overmapie (baza: hazards/hazard_zone.dm).
/// Prędkości w polach overmapy na sekundę (velocity.ln()); pełna prędkość okrętu gracza to ~1,75 pola/s na wprost
/// (speed_limit 3,5 × skala overmapy 0,5), myśliwca ~4.

/// Odstęp między ostrzeżeniami o zbyt dużej prędkości w polu
#define HAZARD_SPEED_WARNING_COOLDOWN (30 SECONDS)
/// Część prędkości bezpiecznej (na oś), do której zwalnia AI w polu; po przekątnej wychodzi ~0,85 prędkości bezpiecznej
#define HAZARD_AI_SAFE_FRACTION 0.6

// ---- Pola zależne od prędkości (Shiptest: meteor / debris) ----

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

/obj/effect/overmap_anomaly/hazard/speed/asteroid_field
	name = "Pole asteroid"
	desc = "Obszar gęsto usiany skałami. Przelot z dużą prędkością kończy się dziurami w kadłubie."
	enter_message = "Wchodzimy w pole asteroid."
	exit_message = "Opuściliśmy pole asteroid."
	radius_range = list(8, 13)
	zone_color = "#a08444"
	zone_alpha = 70
	interference = 5

/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor
	name = "Rzadkie pole asteroid"
	safe_speed = 1.2
	meteor_types = list(/obj/effect/meteor/dust = 12, /obj/effect/meteor/medium = 4)
	hull_damage = 0.02
	detail_count = 5
	interference = 0

/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/major
	name = "Gęste pole asteroid"
	safe_speed = 0.6
	radius_range = list(10, 15)
	meteor_types = list(/obj/effect/meteor/medium = 50, /obj/effect/meteor/big = 25, /obj/effect/meteor/flaming = 10)
	hull_damage = 0.07
	detail_count = 12
	zone_alpha = 90
	interference = 10

/// Pole szczątków: to samo co asteroidy, a do tego zasłania czujniki (Shiptest: opacity żetonu)
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

// ---- Mgławica (Shiptest: nebula) ----

/obj/effect/overmap_anomaly/hazard/nebula
	name = "Mgławica"
	desc = "Obłok zjonizowanego gazu. Okręt w środku trudno wykryć, ale czujniki i radio działają słabiej, a światła na pokładzie migają."
	enter_message = "Wchodzimy w mgławicę. Trudniej nas wykryć, ale czujniki i łączność będą zakłócone."
	exit_message = "Opuściliśmy mgławicę."
	radius_range = list(12, 18)
	zone_color = "#9a5fe0"
	zone_alpha = 90
	chance_to_affect = 40
	signature_mult = 0.5
	sensor_mult = 0.7
	interference = 40

/obj/effect/overmap_anomaly/hazard/nebula/add_hazard_details()
	for(var/i in 1 to 6)
		add_scattered_detail('icons/effects/particles/smoke.dmi', pick("smoke_1", "smoke_2", "smoke_3"), 32, rand(40, 70) / 10, 90, "#b98cf0", 0.6)

/// Migają światła w losowym pomieszczeniu (Shiptest migał całym poziomem przy wejściu; u nas po trochu przez cały pobyt)
/obj/effect/overmap_anomaly/hazard/nebula/affect_ship(obj/structure/overmap/OM)
	if(!OM.has_hazard_interior())
		return
	var/turf/T = OM.get_hazard_hull_turf()
	var/area/A = get_area(T)
	if(!A)
		return
	for(var/obj/machinery/light/L in A)
		L.flicker(rand(3, 8))

// ---- Burza jonowa (Shiptest: electrical storm + EMP storm) ----

/obj/effect/overmap_anomaly/hazard/ion_storm
	name = "Burza jonowa"
	desc = "Naładowany obłok plazmy. Wyładowania trafiają w kadłub, zrywają maskowanie i wywołują impulsy elektromagnetyczne na pokładzie."
	enter_message = "Wchodzimy w burzę jonową. Spodziewajcie się wyładowań i impulsów EMP."
	exit_message = "Opuściliśmy burzę jonową."
	enter_sound = 'sound/magic/lightning_chargeup.ogg'
	radius_range = list(9, 14)
	zone_color = "#6fa8ff"
	zone_alpha = 85
	chance_to_affect = 20
	sensor_mult = 0.85
	interference = 30
	/// Moc wyładowania (tesla_zap) z krawędzi statku
	var/min_zap_power = 1500
	var/max_zap_power = 5000
	/// Zasięg wyładowania od miejsca za kadłubem
	var/zap_range = 8
	/// Szansa (%), że uderzenie to zapowiedziany impuls EMP zamiast wyładowania
	var/emp_chance = 30
	/// Zasięgi impulsu EMP w losowym pomieszczeniu
	var/emp_heavy = 2
	var/emp_light = 5
	/// Ułamek wytrzymałości, który traci okręt bez wnętrza
	var/hull_damage = 0.02

/obj/effect/overmap_anomaly/hazard/ion_storm/add_hazard_details()
	for(var/i in 1 to 3)
		add_scattered_detail('nsv13/goonstation/icons/effects/explosions/electricity.dmi', "thundercloud", 160, rand(6, 10) / 10, 170, null, 0.5)

/obj/effect/overmap_anomaly/hazard/ion_storm/affect_ship(obj/structure/overmap/OM)
	// Wyładowanie zrywa maskowanie każdemu, z wnętrzem czy bez
	OM.handle_cloak(CLOAK_TEMPORARY_LOSS)
	if(!OM.has_hazard_interior())
		hull_hit(OM, hull_damage, "Wyładowanie jonowe przeskakuje po kadłubie!")
		return
	if(prob(emp_chance))
		telegraph_strike(OM, "UWAGA: Przygotować się na impuls elektromagnetyczny!")
		return
	zap_ship(OM)

/// Piorun z kosmosu tuż za kadłubem w losowym miejscu statku (Shiptest: z losowej krawędzi poziomu statku)
/obj/effect/overmap_anomaly/hazard/ion_storm/proc/zap_ship(obj/structure/overmap/OM)
	var/turf/hull = OM.get_hazard_hull_turf()
	if(!hull)
		return
	var/turf/source = OM.get_hazard_edge_turf(hull, pick(GLOB.cardinals))
	if(!source)
		return
	OM.relay('sound/magic/lightningbolt.ogg')
	tesla_zap(source, zap_range, rand(min_zap_power, max_zap_power), TESLA_FUSION_FLAGS)

/obj/effect/overmap_anomaly/hazard/ion_storm/strike(obj/structure/overmap/OM)
	var/turf/T = OM.get_hazard_hull_turf()
	if(!T)
		return
	OM.relay('sound/magic/lightningshock.ogg')
	empulse(T, emp_heavy, emp_light)

// ---- Rozbłysk słoneczny (Shiptest: solar flare) ----

/obj/effect/overmap_anomaly/hazard/solar_flare
	name = "Strefa rozbłysków słonecznych"
	desc = "Obszar, w który gwiazda wyrzuca strumienie gorącej plazmy. Rozbłysk potrafi wzniecić pożar na pokładzie."
	enter_message = "Wchodzimy w strefę rozbłysków słonecznych. Grozi nam pożar na pokładzie."
	exit_message = "Opuściliśmy strefę rozbłysków słonecznych."
	enter_sound = 'nsv13/sound/effects/ship/pdsr_warning.ogg'
	radius_range = list(10, 15)
	zone_color = "#ff8c1a"
	zone_alpha = 90
	chance_to_affect = 15
	interference = 30
	/// Plazma (mol) na każdym kafelku w promieniu pożaru, w 1000 K
	var/fire_plasma = 4
	var/fire_radius = 1
	/// Promień oślepienia wokół miejsca rozbłysku
	var/flash_range = 4
	/// Ułamek wytrzymałości, który traci okręt bez wnętrza
	var/hull_damage = 0.03

/obj/effect/overmap_anomaly/hazard/solar_flare/add_hazard_details()
	add_scattered_detail('icons/effects/light_overlays/light_352.dmi', "light", 352, radius * world.icon_size / 352, 120, "#ffd27a", 0)

/obj/effect/overmap_anomaly/hazard/solar_flare/affect_ship(obj/structure/overmap/OM)
	if(!OM.has_hazard_interior())
		hull_hit(OM, hull_damage, "Rozbłysk słoneczny przypieka kadłub!")
		return
	telegraph_strike(OM, "UWAGA: Przygotować się na rozbłysk słoneczny!")

/obj/effect/overmap_anomaly/hazard/solar_flare/strike(obj/structure/overmap/OM)
	var/turf/T = OM.get_hazard_hull_turf()
	if(!T)
		return
	OM.relay('sound/magic/lightningshock.ogg')
	for(var/turf/open/F in range(fire_radius, T))
		if(isspaceturf(F))
			continue
		F.atmos_spawn_air("plasma=[fire_plasma];TEMP=1000")
	for(var/mob/living/L in viewers(flash_range, T))
		L.flash_act(1, 1)

#undef HAZARD_SPEED_WARNING_COOLDOWN
#undef HAZARD_AI_SAFE_FRACTION
