// AQUILA - anomalia „dusza plazmy”: port z Shiptesta (code/game/objects/effects/anomalies/anomalies_plasmasoul.dm,
// rdzeń z code/modules/assembly/anomalies.dm, licencja AGPLv3; sprite'y z Shiptesta, CC BY-SA 3.0, rdzeń przebarwiony).
// Co ok. 6 s wstrzykuje plazmę organicznym ludziom w promieniu 3 pól (syntetycy dostają oparzenia), po potrąceniu
// wypuszcza obłok plazmy na losowym polu obok, a na koniec życia wybucha plazmą i ogniem.
// Różnice względem Shiptesta:
// - u nas bazowa anomalia nie ma pulse_cooldown/pulse_delay, więc są tu, z tym samym losowaniem opóźnienia;
// - w detonate() Shiptest pomijał ludzi z ochroną bio <= 40 (odwrócony warunek), tu pomija tych z ochroną > 40;
// - bazowa anomalia tworzy zawsze ogólny rdzeń (new() bez typu bierze zadeklarowany typ zmiennej), więc Initialize()
//   podmienia go na rdzeń duszy plazmy z tą samą częstotliwością i kodem;
// - pominięte: drugi kod rdzenia (code_b, wybuch rdzenia na sygnał) i mielenie rdzenia na „Mother-Of-Plasma” z jej
//   reakcjami (u nas nie ma code_b ani odczynników wittel, panacea, fervor, vitfro).

/obj/effect/anomaly/plasmasoul
	name = "dusza plazmy"
	desc = "Plazmowa sadzawka, wokół której rosną drobne kryształy, wrastające w grunt."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "plasmasoul"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/plasmasoul
	/// Zasięg wstrzykiwania plazmy i obłoku po potrąceniu (wybuch ma podwójny)
	var/effectrange = 3
	/// Ile plazmy dostaje organiczny człowiek przy każdym pulsie (przy wybuchu trzy razy tyle)
	var/reagent_amount = 5
	/// Odstęp między pulsami, losowany w Initialize() z przedziału 50-150%
	var/pulse_delay = 6 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/effect/anomaly/plasmasoul/Initialize(mapload, new_lifespan)
	. = ..()
	pulse_delay = rand(pulse_delay * 0.5, pulse_delay * 1.5)

/obj/effect/anomaly/plasmasoul/anomalyEffect(delta_time)
	..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	harm_surrounding_mobs()

/obj/effect/anomaly/plasmasoul/Bumped(atom/movable/AM)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	var/turf/open/spot = locate(rand(x - effectrange, x + effectrange), rand(y - effectrange, y + effectrange), z)
	harm_surrounding_mobs()
	if(istype(spot))
		spot.atmos_spawn_air("plasma=300;TEMP=200")

/obj/effect/anomaly/plasmasoul/proc/harm_surrounding_mobs()
	for(var/mob/living/carbon/human/victim in range(effectrange, src))
		if(!(victim.dna?.species.reagent_tag & PROCESS_ORGANIC))
			victim.adjustFireLoss(20)
			to_chat(victim, "<span class='warning'>Coś bulgocze i syczy pod twoim poszyciem...</span>")
			playsound(victim, 'sound/items/welder.ogg', 150)
			continue
		victim.reagents?.add_reagent(/datum/reagent/toxin/plasma, reagent_amount)
		to_chat(victim, "<span class='warning'>Twoja krew gęstnieje...</span>")
		playsound(victim, 'sound/effects/bubbles.ogg', 50)

/obj/effect/anomaly/plasmasoul/detonate()
	for(var/mob/living/carbon/human/victim in range(effectrange * 2, src))
		if(victim.getarmor(null, "bio") > 40)
			continue
		if(!(victim.dna?.species.reagent_tag & PROCESS_ORGANIC))
			victim.adjustFireLoss(60)
			to_chat(victim, "<span class='warning'>Plazma rozbłyska i zapala się wewnątrz twojej obudowy!</span>")
			playsound(victim, 'sound/items/welder.ogg', 150)
			continue
		victim.reagents?.add_reagent(/datum/reagent/toxin/plasma, reagent_amount * 3)
		to_chat(victim, "<span class='warning'>Krew gęstnieje i bulgocze w twoich żyłach!</span>")
		playsound(victim, 'sound/effects/bubbles.ogg', 50)

	var/turf/open/tile = get_turf(src)
	if(istype(tile))
		tile.atmos_spawn_air("o2=600;plasma=3000;TEMP=2000")
	return ..()

/obj/effect/anomaly/plasmasoul/planetary
	immortal = TRUE
	immobile = TRUE
	core_anomaly_type = /obj/effect/anomaly/plasmasoul

/obj/item/assembly/signaler/anomaly/plasmasoul
	name = "\improper rdzeń anomalii duszy plazmy"
	desc = "Zneutralizowany rdzeń anomalii duszy plazmy. Powietrze wokół niego syczy. Pewnie przydałby się do badań."
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "plasmasoul core"
	anomaly_type = /obj/effect/anomaly/plasmasoul
