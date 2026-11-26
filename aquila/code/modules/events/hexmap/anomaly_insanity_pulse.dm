// AQUILA - Anomalia: zakłócacz psychiki: co 7 s wysyła falę grozy, która przewraca, oślepia na chwilę, wywołuje drgawki i omamy, także za ścianami i w szafkach (port z BeeStation code/modules/events/anomaly_insanitypulse.dm + code/game/objects/effects/anomalies/anomaly_insanitypulse.dm)
// Bee's wave grows one ring of turfs per 0.1 s through a sleeping proc and the turf enumerator, and its detonation reaches
// 150 tiles with a sound for the whole world. Here a pulse hits every living mob in range at once (no sleep, no per turf
// effects), range 8 and 15 when it collapses; Bee's fake pierced realities on detonation are left out (no such system).
// Anti-artifact protection still only blurs the eyes, like in Bee. Jitter is 30 s instead of 100 s and hallucinations
// stack up to 90 s at most, so standing next to it for the whole lifespan does not leave hours of them.

/datum/round_event_control/aquila_hex_anomaly_insanity_pulse
	name = "Anomalia: zakłócacz psychiki"
	typepath = /datum/round_event/aquila_hex_anomaly/insanity_pulse
	weight = 10
	min_players = 15
	max_occurrences = 2

/datum/round_event/aquila_hex_anomaly/insanity_pulse
	startWhen = 3
	announceWhen = 10
	anomaly_path = /obj/effect/anomaly/aquila_hex_insanity_pulse
	announce_kind = "insanity"

/obj/effect/anomaly/aquila_hex_insanity_pulse
	name = "anomalia zakłócająca psychikę"
	desc = "Wiruje, szepcze i patrzy. Samo patrzenie na nią przyprawia o gęsią skórkę."
	icon_state = "hallucination_anomaly"
	color = "#9040c0"
	light_color = LIGHT_COLOR_PURPLE
	COOLDOWN_DECLARE(pulse_cooldown)
	/// Czas między falami
	var/pulse_interval = 7 SECONDS
	/// Zasięg zwykłej fali
	var/weak_pulse_range = 8
	/// Zasięg fali przy zapadnięciu się anomalii
	var/strong_pulse_range = 15

/obj/effect/anomaly/aquila_hex_insanity_pulse/anomalyEffect(delta_time)
	. = ..()
	var/turf/our_turf = get_turf(src)
	if(!our_turf || !COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)
	aquila_hex_insanity_pulse(our_turf, weak_pulse_range)

/obj/effect/anomaly/aquila_hex_insanity_pulse/detonate()
	var/turf/our_turf = get_turf(src)
	if(our_turf)
		playsound(our_turf, 'sound/magic/repulse.ogg', 100, TRUE)
		aquila_hex_insanity_pulse(our_turf, strong_pulse_range)

/// Fala grozy w zasięgu (przez ściany i schowki). Zwraca listę trafionych mobów.
/proc/aquila_hex_insanity_pulse(turf/center, range)
	. = list()
	for(var/mob/living/victim as anything in GLOB.mob_living_list)
		var/turf/victim_turf = get_turf(victim) // także w szafkach i pojemnikach
		if(victim.stat == DEAD || !victim_turf || victim_turf.z != center.z || get_dist(victim_turf, center) > range)
			continue
		if(victim.anti_artifact_check())
			to_chat(victim, "<span class='notice'>Dziwna energia wokół ciebie zatrzymuje falę.</span>")
			victim.adjust_eye_blur(5 SECONDS)
			continue
		to_chat(victim, "<span class='warning'>Zalewa cię fala grozy...</span>")
		victim.adjust_temp_blindness(3 SECONDS)
		victim.Knockdown(1 SECONDS)
		victim.emote("scream")
		victim.set_jitter_if_lower(30 SECONDS)
		victim.adjust_hallucinations_up_to(40 SECONDS, 90 SECONDS)
		. += victim
