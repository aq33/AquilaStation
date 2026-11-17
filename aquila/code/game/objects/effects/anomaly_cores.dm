// AQUILA - rdzenie anomalii swojego typu. Anomalia tworzyła zawsze ogólny „rdzeń anomalii” (new() bez typu w core,
// poprawione hookiem w code/game/objects/effects/anomalies.dm), a anomalie strumienia, grawitacyjna, bluespace i wirowa
// nie miały nawet przypisanego rdzenia. Sprite'y rdzeni piroklastycznego, grawitacyjnego, strumienia i wirowego z tg
// (tgstation/tgstation, icons/obj/devices/new_assemblies.dmi, CC BY-SA 3.0); bluespace zostaje przy ogólnym sprite'cie.

/obj/effect/anomaly/flux
	aSignal = /obj/item/assembly/signaler/anomaly/flux

/obj/effect/anomaly/grav
	aSignal = /obj/item/assembly/signaler/anomaly/grav

/obj/effect/anomaly/bluespace
	aSignal = /obj/item/assembly/signaler/anomaly/bluespace

/obj/effect/anomaly/bhole
	aSignal = /obj/item/assembly/signaler/anomaly/vortex

/obj/item/assembly/signaler/anomaly/pyro
	icon = 'aquila/icons/obj/anomaly_cores.dmi'

/obj/item/assembly/signaler/anomaly/grav
	icon = 'aquila/icons/obj/anomaly_cores.dmi'

/obj/item/assembly/signaler/anomaly/flux
	icon = 'aquila/icons/obj/anomaly_cores.dmi'

/obj/item/assembly/signaler/anomaly/vortex
	icon = 'aquila/icons/obj/anomaly_cores.dmi'

// Punkty badań są przypisane do dokładnego typu przedmiotu: każdy rdzeń wart tyle co ogólny (wcześniej i tak
// wszystkie anomalie zostawiały ogólny)
/datum/controller/subsystem/research/Initialize()
	var/list/core_points = techweb_point_items[/obj/item/assembly/signaler/anomaly]
	for(var/core_type in subtypesof(/obj/item/assembly/signaler/anomaly))
		if(!techweb_point_items[core_type])
			techweb_point_items[core_type] = core_points.Copy()
	return ..()
