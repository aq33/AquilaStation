// AQUILA - anomalie planetarne: port z Shiptesta (code/game/objects/effects/anomalies/_anomalies.dm i podtypy
// /planetary z anomalies_*.dm, licencja AGPLv3). Anomalia planetarna nie wygasa (immortal, zmienna jest u nas w core),
// nie przemieszcza się (immobile) i sama nie wybucha, ale dalej działa jak zwykła i da się ją zneutralizować
// sygnalizatorem z częstotliwością i kodem jej rdzenia.

/obj/effect/anomaly
	/// Anomalia stoi w miejscu (bez losowych kroków w anomalyEffect)
	var/immobile = FALSE
	/// Typ anomalii zapisywany w rdzeniu zamiast własnego typu. Podtyp planetarny podaje tu rodzica, żeby rdzeń
	/// działał tak samo jak rdzeń zwykłej anomalii (np. zbroja reaktywna szuka dokładnego typu).
	var/core_anomaly_type

/obj/effect/anomaly/Initialize(mapload, new_lifespan)
	. = ..()
	if(core_anomaly_type && aSignal)
		aSignal.anomaly_type = core_anomaly_type

// Bazowa procka robi tylko losowy krok, więc anomalia nieruchoma jej nie woła
/obj/effect/anomaly/anomalyEffect(delta_time)
	if(immobile)
		return
	return ..()

/obj/effect/anomaly/bluespace/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/bluespace

/obj/effect/anomaly/flux/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/flux

/obj/effect/anomaly/grav/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/grav

/obj/effect/anomaly/hallucination/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/hallucination

/obj/effect/anomaly/pyro/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/pyro
