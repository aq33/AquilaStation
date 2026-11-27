// AQUILA - Anomalia: Dawczyni życia: przez pół minuty co drugi cykl wypuszcza na pokład zwierzę domowe albo drobne stworzenie (port z Monkestation monkestation/code/modules/events/anomaly/anomaly_lifebringer.dm + code/game/objects/effects/anomalies/anomalies_lifebringer.dm)
// Monke picks from every subtype of /mob/living/basic/pet minus a few broken ones; here the list is explicit, because our
// pet subtypes include unique named pets (Ian, Runtime, Renault...), test and ability pets and cult corgis.
// At most 10 animals per anomaly. The 1% "catsplosion" (a cat in a plasma fireball) is kept, it is Monke's joke.

/datum/round_event_control/aquila_hex_anomaly_lifebringer
	name = "Anomalia: Dawczyni życia"
	typepath = /datum/round_event/aquila_hex_anomaly/lifebringer
	weight = 15
	min_players = 0
	max_occurrences = 2

/datum/round_event/aquila_hex_anomaly/lifebringer
	startWhen = 1
	announceWhen = 1
	anomaly_path = /obj/effect/anomaly/aquila_hex_lifebringer
	announce_kind = "lifebringer"

/obj/effect/anomaly/aquila_hex_lifebringer
	name = "anomalia Dawczyni życia"
	desc = "Anomalna brama, która zdaje się tworzyć życie z niczego. Krasnoludy z Lavalandu nazywają ją „Zwierzęcym wybuchem”."
	icon_state = "bluestream_fade"
	color = "#ffd0a0"
	lifespan = 30 SECONDS
	/// Wypuszcza zwierzę co drugi cykl
	var/active = TRUE
	/// Ile zwierząt jeszcze wyjdzie
	var/pets_left = 10
	/// Jedno na sto: kot w kuli płonącej plazmy
	var/catsplosion = FALSE

/obj/effect/anomaly/aquila_hex_lifebringer/Initialize(mapload, new_lifespan)
	. = ..()
	catsplosion = prob(1)

/obj/effect/anomaly/aquila_hex_lifebringer/anomalyEffect(delta_time)
	..()
	if(!active)
		active = TRUE
		return
	active = FALSE
	spawn_pet()

/// Wypuszcza zwierzę na kafel anomalii. Zwraca zwierzę.
/obj/effect/anomaly/aquila_hex_lifebringer/proc/spawn_pet()
	var/static/list/pet_types = list(
		/mob/living/basic/pet/cat,
		/mob/living/basic/pet/cat/kitten,
		/mob/living/basic/pet/cat/tabby,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/corgi/puppy,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/dog/bullterrier,
		/mob/living/basic/pet/hamster,
		/mob/living/basic/pet/penguin/baby,
		/mob/living/basic/butterfly,
		/mob/living/basic/chicken,
		/mob/living/basic/cockroach,
		/mob/living/basic/crab,
		/mob/living/basic/frog,
		/mob/living/basic/lizard,
		/mob/living/basic/mothroach,
		/mob/living/basic/mouse/gray,
		/mob/living/basic/mouse/white,
		/mob/living/basic/rabbit,
		/mob/living/basic/sloth,
	)
	var/turf/open/location = get_turf(src)
	if(pets_left <= 0 || !istype(location) || isspaceturf(location))
		return null
	pets_left--
	if(catsplosion)
		pets_left = 0
		location.atmos_spawn_air("o2=45;plasma=15;TEMP=6000")
		return new /mob/living/basic/pet/cat(location)
	var/pet_type = pick(pet_types)
	return new pet_type(location)
