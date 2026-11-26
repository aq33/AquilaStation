// AQUILA - Anomalia burzowa: przez pół minuty co drugi cykl razi piorunem kuli tesli i wypuszcza gorącą parę, a wchodzącego poraża prądem (port z Monkestation monkestation/code/modules/events/anomaly/anomaly_storm.dm + code/game/objects/effects/anomalies/anomalies_storm.dm)
// The zap uses the mini energy ball flags (no exploding machines): Monke's default flags made every zap blow up machinery,
// which on a ship means engines and consoles. Monke's 40 player minimum is lowered to 20, our rounds are smaller.
// No detonation, like in Monke ("strong enough as it is"). Monke's sprite is our flux state recoloured, as in Monke.

#define AQUILA_HEX_STORM_MIN_RANGE 2
#define AQUILA_HEX_STORM_MAX_RANGE 5
#define AQUILA_HEX_STORM_POWER 1500

/datum/round_event_control/aquila_hex_anomaly_storm
	name = "Anomalia burzowa"
	typepath = /datum/round_event/aquila_hex_anomaly/storm
	weight = 5
	min_players = 20
	max_occurrences = 2

/datum/round_event/aquila_hex_anomaly/storm
	startWhen = 1
	announceWhen = 1
	anomaly_path = /obj/effect/anomaly/aquila_hex_storm
	announce_kind = "storm"

/obj/effect/anomaly/aquila_hex_storm
	name = "anomalia burzowa"
	desc = "Pan piorunów zagląda zza zasłony."
	icon_state = "electricity2"
	color = "#fbff00"
	light_color = LIGHT_COLOR_YELLOW
	lifespan = 30 SECONDS // za silna na pełne półtorej minuty
	/// Razi wchodzącego i co drugi cykl wyładowuje się piorunem
	var/active = TRUE

/obj/effect/anomaly/aquila_hex_storm/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/aquila_hex_storm/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!active || !iscarbon(arrived))
		return
	var/mob/living/carbon/target = arrived
	active = FALSE
	if(target.electrocute_act(23, src, 1) > 0) // izolowane rękawice i odporność chronią także przed oparzeniem
		target.adjustFireLoss(10)

/obj/effect/anomaly/aquila_hex_storm/anomalyEffect(delta_time)
	..()
	if(!active) // tylko co drugi cykl
		active = TRUE
		return
	active = FALSE
	discharge()

/// Piorun w najbliższy cel i gorąca para na kaflu anomalii
/obj/effect/anomaly/aquila_hex_storm/proc/discharge()
	tesla_zap(src, rand(AQUILA_HEX_STORM_MIN_RANGE, AQUILA_HEX_STORM_MAX_RANGE), AQUILA_HEX_STORM_POWER, TESLA_ENERGY_MINI_BALL_FLAGS)
	playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE)
	var/turf/open/location = get_turf(src)
	if(istype(location) && !isspaceturf(location))
		location.atmos_spawn_air("water_vapor=10;TEMP=350")

#undef AQUILA_HEX_STORM_MIN_RANGE
#undef AQUILA_HEX_STORM_MAX_RANGE
#undef AQUILA_HEX_STORM_POWER
