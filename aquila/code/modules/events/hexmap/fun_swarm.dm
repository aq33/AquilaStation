// AQUILA - Rój dziwnych meteorów: w okręt zamiast skał lecą krowy, klauni, ziemniaki i krasnale ogrodowe (port z space-wizards/space-station-14 Resources/Prototypes/GameRules/meteorswarms.yml, FunSwarm)
// SS14 throws 3 waves of 8–12 clown, cow, potato and Urist (dwarf) "meteors" that are the real entities. Ours are weak
// meteors of our meteor system (one light hit, like space dust) wearing the looks of a cow, a clown, a potato or a garden
// gnome (we have no dwarves), 3 waves of 4–6; when they break they leave a live cow, a horn and a banana peel, a few
// potatoes or a live garden gnome. Rare (hex_pool_chance 15), on the asteroid field only.

/datum/round_event_control/aquila_hex_fun_swarm
	name = "Rój dziwnych meteorów"
	typepath = /datum/round_event/aquila_hex_fun_swarm
	weight = 3
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES
	hex_pool_chance = 15

/datum/round_event/aquila_hex_fun_swarm
	announceWhen = 1
	startWhen = 10
	endWhen = 40
	/// Ile fal
	var/waves = 3
	/// Ile fal już poleciało
	var/waves_sent = 0
	/// Tick następnej fali
	var/next_wave = 0
	var/static/list/fun_meteors = list(
		/obj/effect/meteor/aquila_fun/cow = 1,
		/obj/effect/meteor/aquila_fun/clown = 1,
		/obj/effect/meteor/aquila_fun/potato = 1,
		/obj/effect/meteor/aquila_fun/gnome = 1,
	)

/datum/round_event/aquila_hex_fun_swarm/announce(fake)
	priority_announce("Sensory wykrywają rój obiektów na kursie kolizyjnym z [station_name()]. Analiza spektralna wskazuje na... krowy? Klaunów? Ziemniaki? Wydział Nauki prosi o niezadawanie pytań. Trzymajcie się z dala od zewnętrznych ścian.", "Alarm meteorytowy", ANNOUNCER_METEORS)

/datum/round_event/aquila_hex_fun_swarm/start()
	next_wave = activeFor

/datum/round_event/aquila_hex_fun_swarm/tick()
	if(waves_sent >= waves || activeFor < next_wave)
		return
	waves_sent++
	next_wave = activeFor + rand(4, 7)
	var/list/levels = aquila_hex_ship_zlevels()
	if(length(levels))
		spawn_meteors(rand(4, 6), fun_meteors, pick(levels))

/**
 * Słaby meteor w przebraniu: wygląda jak look_like, rozbija się po jednym uderzeniu (lekka eksplozja jak pył kosmiczny)
 * i zostawia meteordrop.
 */
/obj/effect/meteor/aquila_fun
	name = "dziwny meteor"
	desc = "To na pewno nie jest skała."
	hits = 1
	hitpwr = EXPLODE_LIGHT
	dropamt = 1
	threat = 1
	/// Typ, którego wygląd meteor przybiera
	var/atom/look_like
	/// Dźwięk przy rozbiciu
	var/splat_sound

/obj/effect/meteor/aquila_fun/Initialize(mapload, target)
	if(look_like)
		icon = initial(look_like.icon)
		icon_state = initial(look_like.icon_state)
	return ..()

/obj/effect/meteor/aquila_fun/meteor_effect()
	..()
	if(splat_sound)
		playsound(src, splat_sound, 50, TRUE)

/obj/effect/meteor/aquila_fun/cow
	name = "rozpędzona krowa"
	desc = "Krowa w locie z prędkością orbitalną. Muu."
	look_like = /mob/living/basic/cow
	meteordrop = list(/mob/living/basic/cow)
	splat_sound = 'sound/effects/splat.ogg'

/obj/effect/meteor/aquila_fun/clown
	name = "wystrzelony klaun"
	desc = "Ktoś wystrzelił klauna z armaty. W twoją stronę."
	look_like = /mob/living/basic/clown
	meteordrop = list(/obj/item/bikehorn, /obj/item/grown/bananapeel)
	dropamt = 2
	splat_sound = 'sound/items/bikehorn.ogg'

/obj/effect/meteor/aquila_fun/potato
	name = "kosmiczny ziemniak"
	desc = "Ziemniak. W kosmosie. Pędzi prosto na kadłub."
	look_like = /obj/item/food/grown/potato
	meteordrop = list(/obj/item/food/grown/potato)
	dropamt = 3

/obj/effect/meteor/aquila_fun/gnome
	name = "krasnal-pocisk"
	desc = "Krasnal ogrodowy, który postanowił zwiedzić galaktykę. Na skróty."
	look_like = /mob/living/basic/garden_gnome
	meteordrop = list(/mob/living/basic/garden_gnome)

/obj/effect/meteor/aquila_fun/clown/make_debris()
	for(var/drop in meteordrop)
		new drop(get_turf(src))
