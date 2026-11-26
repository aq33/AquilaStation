// AQUILA - Rój dziwnych meteorów: w okręt zamiast skał lecą krowy, klauni, ziemniaki i krasnale ogrodowe (port z space-wizards/space-station-14 Resources/Prototypes/GameRules/meteorswarms.yml, FunSwarm)
// SS14 throws 3 waves of 8–12 clown, cow, potato and Urist (dwarf) "meteors" that are the real entities. Ours are meteors
// of our meteor system wearing the looks of a cow, a clown, a potato or a garden gnome (we have no dwarves), 3 waves of 4–6.
// They never damage the ship: a hit only dents the wall and bruises whoever it strikes (no ex_act on walls, windows or
// floors), and they break on the first hit. They leave items only, nothing alive that would end up stranded in space:
// a beef slab and a milk carton, a horn and a banana peel, a few potatoes or a garden gnome figurine.
// Rare (hex_pool_chance 15), on the asteroid field only.

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
 * Niegroźny meteor w przebraniu: wygląda jak look_like, rozbija się po pierwszym uderzeniu i zostawia po jednym
 * przedmiocie z meteordrop. Ścianę tylko wgniata, a trafionemu zadaje lekkie obrażenia; kadłuba nie uszkadza.
 */
/obj/effect/meteor/aquila_fun
	name = "dziwny meteor"
	desc = "To na pewno nie jest skała."
	hits = 1
	hitpwr = 0
	threat = 1
	/// Typ, którego wygląd meteor przybiera
	var/atom/look_like
	/// Dźwięk przy rozbiciu
	var/splat_sound
	/// Obrażenia (obuchowe) dla trafionego
	var/impact_damage = 5

/obj/effect/meteor/aquila_fun/Initialize(mapload, target)
	if(look_like)
		icon = initial(look_like.icon)
		icon_state = initial(look_like.icon_state)
	return ..()

/obj/effect/meteor/aquila_fun/meteor_effect()
	..()
	if(splat_sound)
		playsound(src, splat_sound, 50, TRUE)

/// Pole, przez które leci: tylko obija ludzi, bez eksplozji
/obj/effect/meteor/aquila_fun/ram_turf(turf/T)
	for(var/mob/living/victim in T)
		strike(victim)

/// Zderzenie: ściana dostaje wgniecenie, trafiony lekkie obrażenia, a meteor się rozbija
/obj/effect/meteor/aquila_fun/Bump(atom/A)
	if(!A)
		return
	if(iswallturf(A))
		var/turf/closed/wall/wall = A
		wall.add_dent(WALL_DENT_HIT)
	else if(isliving(A))
		strike(A)
	playsound(src, meteorsound, 40, TRUE)
	get_hit()

/// Lekkie obrażenia dla trafionego
/obj/effect/meteor/aquila_fun/proc/strike(mob/living/victim)
	victim.visible_message("<span class='warning'>[src] uderza w [victim].</span>", "<span class='userdanger'>[src] uderza w ciebie!</span>")
	victim.apply_damage(impact_damage, BRUTE)

/// Po jednym przedmiocie z meteordrop
/obj/effect/meteor/aquila_fun/make_debris()
	var/turf/drop_turf = get_turf(src)
	for(var/drop in meteordrop)
		new drop(drop_turf)

/obj/effect/meteor/aquila_fun/cow
	name = "rozpędzona krowa"
	desc = "Krowa w locie z prędkością orbitalną. Muu."
	look_like = /mob/living/basic/cow
	meteordrop = list(/obj/item/food/meat/slab, /obj/item/reagent_containers/food/condiment/milk)
	splat_sound = 'sound/effects/splat.ogg'

/obj/effect/meteor/aquila_fun/clown
	name = "wystrzelony klaun"
	desc = "Ktoś wystrzelił klauna z armaty. W twoją stronę."
	look_like = /mob/living/basic/clown
	meteordrop = list(/obj/item/bikehorn, /obj/item/grown/bananapeel)
	splat_sound = 'sound/items/bikehorn.ogg'

/obj/effect/meteor/aquila_fun/potato
	name = "kosmiczny ziemniak"
	desc = "Ziemniak. W kosmosie. Pędzi prosto na kadłub."
	look_like = /obj/item/food/grown/potato
	meteordrop = list(/obj/item/food/grown/potato, /obj/item/food/grown/potato, /obj/item/food/grown/potato)

/obj/effect/meteor/aquila_fun/gnome
	name = "krasnal-pocisk"
	desc = "Krasnal ogrodowy, który postanowił zwiedzić galaktykę. Na skróty."
	look_like = /mob/living/basic/garden_gnome
	meteordrop = list(/obj/item/aquila_gnome_figurine)

/// Ceramiczny krasnal ogrodowy, który przyleciał z rojem dziwnych meteorów
/obj/item/aquila_gnome_figurine
	name = "figurka krasnala ogrodowego"
	desc = "Ceramiczny krasnal ogrodowy, lekko poobijany po locie przez kosmos. Wygląda na bardzo zadowolonego z siebie."
	icon = 'aquila/icons/mob/garden_gnome.dmi'
	icon_state = "gnome"
	greyscale_config = /datum/greyscale_config/garden_gnome
	greyscale_colors = "#f10b0b#2e8ff7#874e2a#e8e8e8"
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 8
