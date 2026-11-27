// AQUILA - Zbuntowane drony techniczne: drony techniczne z wraków na złomowisku dostają się na okręt i w kilku grupach zajmują tunele techniczne (port z Baystation12 code/modules/events/maint_drones.dm)
// Bay spawns 3-8 groups of rogue maintenance drones (2*severity-1+1 each, 10% big drones above mundane) on free
// breathable turfs of random maintenance areas, announced only sometimes (70-20*severity % stealth). We have no rogue
// drone mob, so ours is a small variant of our ranged hivebot with the hacked repair drone sprite; 2-4 groups of 2-3
// drones, every tenth a sturdier one, announced half of the time. Unlike our "Rój zbuntowanych dronów" (combat drones
// shooting the hull from space), these are inside the ship, in maintenance.

/datum/round_event_control/aquila_hex_rogue_maint_drones
	name = "Zbuntowane drony techniczne"
	typepath = /datum/round_event/aquila_hex_rogue_maint_drones
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_rogue_maint_drones
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	announceChance = 50
	/// Ile dronów się pojawiło
	var/spawned = 0

/datum/round_event/aquila_hex_rogue_maint_drones/start()
	for(var/group in 1 to rand(2, 4))
		spawned += length(spawn_group(aquila_hex_maint_turf(), rand(2, 3)))
	if(!spawned)
		log_game("Rogue Maintenance Drones: no free maintenance turf found, cancelling the event.")
		return kill()
	message_admins("Zbuntowane drony techniczne: [spawned] dronów w tunelach technicznych.")
	log_game("Rogue Maintenance Drones: [spawned] rogue drones spawned in maintenance.")

/datum/round_event/aquila_hex_rogue_maint_drones/announce(fake)
	if(!spawned && !fake)
		return
	priority_announce("Wykryto bunt dronów technicznych przechwyconych z pobliskich wraków. Drony nie odpowiadają na polecenia i atakują wszystko, co się rusza. Zachowajcie ostrożność w tunelach technicznych.", "Kontrola Zachowania Dronów")

/// Grupa dronów na wolnych polach wokół center; zwraca listę dronów
/datum/round_event/aquila_hex_rogue_maint_drones/proc/spawn_group(turf/center, amount)
	. = list()
	if(!isturf(center))
		return
	for(var/turf/spot as anything in aquila_hex_free_turfs_near(center, amount, 2))
		var/drone_type = prob(10) ? /mob/living/basic/hivebot/range/aquila_hex_maint_drone/big : /mob/living/basic/hivebot/range/aquila_hex_maint_drone
		. += new drone_type(spot)

/// Zbuntowany dron techniczny: mały, słaby dron strzelający w tunelach
/mob/living/basic/hivebot/range/aquila_hex_maint_drone
	name = "zbuntowany dron techniczny"
	desc = "Dron techniczny z przegrzanym rdzeniem logicznym. Zamiast łatać rury, celuje w ludzi."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_repair_hacked"
	icon_living = "drone_repair_hacked"
	icon_dead = "drone_repair_hacked_dead"
	faction = list("rogue_drone")
	health = 20
	maxHealth = 20
	gold_core_spawnable = NO_SPAWN
	playable = FALSE
	do_footstep = FALSE
	ranged_attack_cooldown = 4 SECONDS

/// Większy, wytrzymalszy dron techniczny (Bay: big rogue drone)
/mob/living/basic/hivebot/range/aquila_hex_maint_drone/big
	name = "duży zbuntowany dron techniczny"
	desc = "Ciężki dron remontowy z oderwanym ogranicznikiem bezpieczeństwa. Nie wygląda na przyjaźnie nastawiony."
	health = 45
	maxHealth = 45
	melee_damage = 8
	ranged_attack_cooldown = 3 SECONDS

/mob/living/basic/hivebot/range/aquila_hex_maint_drone/big/Initialize(mapload)
	. = ..()
	var/matrix/bigger = matrix(transform)
	bigger.Scale(1.25)
	transform = bigger
