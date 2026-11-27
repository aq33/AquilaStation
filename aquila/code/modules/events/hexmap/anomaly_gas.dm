// AQUILA - Anomalia gazowa: fazująca chmura, która przenika przez stoły i kraty, a co 15 s wypuszcza dym z losową substancją (port z TauCetiClassic code/modules/events/anomaly_gas.dm + obiekt /obj/effect/anomaly/gas z code/game/objects/effects/anomalies.dm)
// TauCeti releases 900 units in a range 10 cloud, which in our smoke code would fill whole decks, so a puff is 30 units
// in range 3 (a bigger one when it collapses). The reagents are our equivalents of TauCeti's list: condensed capsaicin,
// fluorosulfuric acid (their polytrinic), space drugs, zombie powder, lexorin, impedrezene, itching powder and nitrous
// oxide; TauCeti's healing reagents and adminordrazine are left out. It drifts with our anomaly step chance.

/datum/round_event_control/aquila_hex_anomaly_gas
	name = "Anomalia gazowa"
	typepath = /datum/round_event/aquila_hex_anomaly/gas
	weight = 10
	min_players = 5
	max_occurrences = 3

/datum/round_event/aquila_hex_anomaly/gas
	anomaly_path = /obj/effect/anomaly/aquila_hex_gas
	announce_kind = "gas"

/obj/effect/anomaly/aquila_hex_gas
	name = "fazująca anomalia gazowa"
	desc = "Kłąb mieniącego się gazu, który przenika przez meble. Lepiej nie wdychać."
	icon_state = "bluestream"
	color = "#a0d080"
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	COOLDOWN_DECLARE(release_cooldown)
	/// Czas między chmurami
	var/release_time = 15 SECONDS
	/// Ile jednostek substancji idzie w jedną chmurę
	var/release_amount = 30

/obj/effect/anomaly/aquila_hex_gas/Initialize(mapload, new_lifespan)
	. = ..()
	COOLDOWN_START(src, release_cooldown, release_time)

/obj/effect/anomaly/aquila_hex_gas/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, release_cooldown))
		return
	COOLDOWN_START(src, release_cooldown, release_time)
	release_gas(release_amount, 3)

/// Wypuszcza chmurę dymu z losową substancją z listy. Zwraca typ substancji.
/obj/effect/anomaly/aquila_hex_gas/proc/release_gas(amount, smoke_range)
	var/static/list/gas_reagents = list(
		/datum/reagent/consumable/condensedcapsaicin,
		/datum/reagent/toxin/acid/fluacid,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin/zombiepowder,
		/datum/reagent/toxin/lexorin,
		/datum/reagent/impedrezene,
		/datum/reagent/toxin/itching_powder,
		/datum/reagent/nitrous_oxide,
	)
	var/turf/open/smoke_turf = get_turf(src)
	if(!istype(smoke_turf) || isspaceturf(smoke_turf))
		return null
	var/reagent_type = pick(gas_reagents)
	var/datum/reagents/smoke_reagents = new(amount)
	smoke_reagents.add_reagent(reagent_type, amount)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(smoke_reagents, smoke_range, smoke_turf, silent = TRUE)
	smoke.start()
	qdel(smoke_reagents)
	playsound(smoke_turf, 'sound/effects/smoke.ogg', 50, TRUE)
	return reagent_type

/obj/effect/anomaly/aquila_hex_gas/detonate()
	release_gas(release_amount * 3, 5)
