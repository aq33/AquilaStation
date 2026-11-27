// AQUILA - Anomalia radioaktywna: promieniuje, zostawia ślad szlamu jądrowego i odrzuca tych, którzy w nią wejdą (port z Monkestation monkestation/code/modules/events/anomaly/anomaly_radiation.dm + code/game/objects/effects/anomalies/anomalies_radiation.dm)
// The radiation numbers are rescaled to our Bee radiation (aquila/code/__HELPERS/radiation.dm: range, insulation threshold,
// intensity in %) instead of Monke's old power values. The sludge is the NSV plutonium sludge, but never its "epicenter"
// variant (that one irradiates forever; Monke drops it 15% of the time), so a shovel cleans the whole trail. The sludge
// drops on 30% of the cycles instead of every one, so the trail is patchy instead of a carpet.
// Monke's announcement sound pick is replaced with the usual anomaly announcer.

/datum/round_event_control/aquila_hex_anomaly_radiation
	name = "Anomalia radioaktywna"
	typepath = /datum/round_event/aquila_hex_anomaly/radiation
	weight = 5
	min_players = 15
	max_occurrences = 1

/datum/round_event/aquila_hex_anomaly/radiation
	anomaly_path = /obj/effect/anomaly/aquila_hex_radioactive
	announce_kind = "radiation"

/obj/effect/anomaly/aquila_hex_radioactive
	name = "anomalia radioaktywna"
	desc = "Wysoce niestabilna masa naładowanych cząstek, która zostawia za sobą odpady."
	icon_state = "shield-grey"
	color = "#9bff3c"
	light_color = LIGHT_COLOR_GREEN
	/// Odrzuca i napromieniowuje wchodzącego (raz na cykl anomalii)
	var/active = TRUE
	/// Szansa na szlam w każdym cyklu (inaczej zostawia go na każdym kaflu)
	var/sludge_chance = 30

/obj/effect/anomaly/aquila_hex_radioactive/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/aquila_hex_radioactive/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!active || !isliving(arrived))
		return
	var/mob/living/victim = arrived
	active = FALSE
	victim.Paralyze(1 SECONDS)
	var/atom/target = get_edge_target_turf(victim, get_dir(src, get_step_away(victim, src)))
	victim.throw_at(target, 3, 1)
	radiation_pulse(victim, max_range = 1, threshold = RAD_EXTREME_INSULATION, intensity = 40)
	to_chat(victim, "<span class='danger'>Zalewa cię obrzydliwa fala gorąca!</span>")

/obj/effect/anomaly/aquila_hex_radioactive/anomalyEffect(delta_time)
	..()
	active = TRUE
	var/turf/open/current = get_turf(src)
	if(!istype(current) || isspaceturf(current))
		return
	radiation_pulse(src, max_range = 3, threshold = RAD_MEDIUM_INSULATION, intensity = 10)
	if(prob(sludge_chance))
		leave_sludge(current)

/// Zostawia szlam jądrowy na kaflu, jeśli jeszcze go tam nie ma. Zwraca szlam.
/obj/effect/anomaly/aquila_hex_radioactive/proc/leave_sludge(turf/open/where)
	var/obj/effect/decal/nuclear_waste/sludge = locate() in where
	if(sludge)
		return sludge
	playsound(where, 'sound/effects/splat.ogg', 50, TRUE)
	return new /obj/effect/decal/nuclear_waste(where)

/obj/effect/anomaly/aquila_hex_radioactive/detonate()
	playsound(src, 'sound/effects/empulse.ogg', 100, TRUE)
	radiation_pulse(src, max_range = 7, threshold = RAD_HEAVY_INSULATION, intensity = 60)
