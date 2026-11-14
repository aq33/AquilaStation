// AQUILA - ogon komety: statek przelatuje przez cienki ogon, ogon albo jądro komety i zbiera falę lodowych meteorów (port z CEV-Eris code/modules/overmap/events/event.dm)
// Lodowe meteory są w comet_expulsion.dm.

/datum/round_event_control/aquila_hex_comet_tail
	name = "Comet Tail"
	typepath = /datum/round_event/aquila_hex_comet_tail
	weight = 10
	min_players = 5
	max_occurrences = 3
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_comet_tail
	announceWhen = 1
	startWhen = 15 // około 30 s od ostrzeżenia
	endWhen = 35
	/// Część komety: "thin" (cienki ogon), "tail" (ogon) albo "core" (jądro)
	var/zone = "tail"
	/// Najwięcej meteorów w jednej porcji
	var/strength = 5
	/// Tick, w którym leci kolejna porcja
	var/next_meteor = 0
	/// Meteory tej części komety (wagi z Eris)
	var/list/wave
	var/static/list/thin_tail_meteors = list(
		/obj/effect/meteor/aquila_ice = 10,
		/obj/effect/meteor/aquila_ice/big = 5,
		/obj/effect/meteor/aquila_ice/dust = 40,
	)
	var/static/list/tail_meteors = list(
		/obj/effect/meteor/aquila_ice = 40,
		/obj/effect/meteor/aquila_ice/big = 10,
		/obj/effect/meteor/aquila_ice/dust = 20,
	)
	var/static/list/core_meteors = list(
		/obj/effect/meteor/aquila_ice/big = 40,
		/obj/effect/meteor/aquila_ice = 20,
		/obj/effect/meteor/aquila_ice/dust = 10,
	)

/datum/round_event/aquila_hex_comet_tail/setup()
	zone = pickweight(list("thin" = 50, "tail" = 35, "core" = 15))
	var/duration
	switch(zone)
		if("thin")
			strength = 2
			duration = 20
			wave = thin_tail_meteors
		if("core")
			strength = 7
			duration = 60
			wave = core_meteors
		else
			strength = 5
			duration = 30
			wave = tail_meteors
	endWhen = startWhen + duration
	next_meteor = startWhen + 1

/datum/round_event/aquila_hex_comet_tail/announce(fake)
	switch(zone)
		if("thin")
			priority_announce("Statek wlatuje w cienki ogon komety. Spodziewane drobne uderzenia lodowych odłamków w kadłub.", "Alarm meteorytowy", ANNOUNCER_METEORS)
		if("core")
			priority_announce("Statek wlatuje w pobliże jądra komety! Spodziewane silne uderzenia lodowych brył. Zespoły kontroli uszkodzeń w gotowości.", "Alarm meteorytowy", ANNOUNCER_METEORS)
		else
			priority_announce("Statek wlatuje w ogon komety. Spodziewane uderzenia lodowych odłamków, trzymajcie się z dala od zewnętrznego kadłuba.", "Alarm meteorytowy", ANNOUNCER_METEORS)

/datum/round_event/aquila_hex_comet_tail/tick()
	if(activeFor < next_meteor)
		return
	next_meteor += rand(3, 10)
	var/list/levels = aquila_hex_ship_zlevels()
	if(length(levels))
		spawn_meteors(rand(0, strength), wave, pick(levels))

/datum/round_event/aquila_hex_comet_tail/end()
	priority_announce("Statek opuścił ogon komety.", "Alarm meteorytowy")
