// AQUILA - automaty z Shiptesta (shiptest-ss13/Shiptest, AGPLv3: code/modules/mob/living/simple_animal/hostile/automatons.dm;
// ikony icons/mob/aibots.dmi i icons/obj/landmine.dmi, CC BY-SA 3.0, w aquila/icons/planets/fauna/automatons.dmi) na naszych
// basic mobach, dla planety-śmietniska i jej ruin. AI na drzewie planowania jak hivebot: strzelające trzymają dystans
// (maintain_distance), walczące wręcz idą prosto na cel.
// Zmiany względem Shiptesta:
// - zamiast amunicji i broni Shiptesta (5,7×39, 4,6×30, plazma Sharplite, „chaff”) nasze pociski: 10 mm, 9 mm, 5,56,
//   słabe i zwykłe lasery, śrut; serie przez burst_shots komponentu ranged_attacks;
// - bez pancerza (armor) i penetracji: wytrzymalsze automaty mają po prostu więcej zdrowia;
// - trójnóg nie ostrzega celu wykrzyknikiem przed strzałem z daleka (strzela z dłuższą przerwą), skaczący „Hopper” nie kołysze
//   się w chodzie (element waddling), zapalająca mina krocząca podpala wybuchem zamiast linii ognia z miotacza;
// - frakcje: „waste” = hivebot (nie walczą z hivebotami wysypiska), koalicja i Klika Ramziego = Syndykat (jak nasi żołnierze
//   w ruinach), Vigilitas/Makosso = nanotrasenprivate (jak żołnierze NT), reszta = hostile.

/mob/living/basic/automaton
	name = "automat"
	desc = "Mały, nieuzbrojony łazik."
	icon = 'aquila/icons/planets/fauna/automatons.dmi'
	icon_state = "quadrotor_indie"
	icon_living = "quadrotor_indie"
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	basic_mob_flags = DEL_ON_DEATH
	health = 20
	maxHealth = 20
	healable = FALSE
	melee_damage = 5
	attack_verb_continuous = "uderza"
	attack_sound = 'sound/weapons/genhit1.ogg'
	speak_emote = list("stwierdza")
	faction = list("hostile")
	death_message = "pada na ziemię, sypiąc iskrami."
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	ai_controller = /datum/ai_controller/basic_controller/automaton
	/// Pocisk albo łuska strzelającego automatu (jedno z dwóch)
	var/projectile_type
	var/casing_type
	var/projectile_sound = 'sound/weapons/gunshot.ogg'
	/// Strzały w serii i przerwa między seriami
	var/burst_shots = 1
	var/ranged_cooldown = 2 SECONDS
	/// Latający (drony): nie wpada w przepaści ani do wody
	var/flying = FALSE
	/// Kwestie przy wykryciu celu i szansa na nie
	var/list/aggro_lines
	var/aggro_line_chance = 0

/mob/living/basic/automaton/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/decal/cleanable/robot_debris)
	AddElement(/datum/element/death_drops, death_loot)
	if(flying)
		AddElement(/datum/element/simple_flying)
	if(projectile_type || casing_type)
		AddComponent(/datum/component/ranged_attacks, casing_type = casing_type, projectile_type = projectile_type, projectile_sound = projectile_sound, burst_shots = burst_shots, cooldown_time = ranged_cooldown)
	if(length(aggro_lines))
		RegisterSignal(src, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_new_target))

/mob/living/basic/automaton/death(gibbed)
	do_sparks(3, TRUE, src)
	return ..()

/mob/living/basic/automaton/proc/on_new_target(datum/source)
	SIGNAL_HANDLER
	if(prob(aggro_line_chance))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), pick(aggro_lines))

// Drony czterowirnikowe: strzelają z dystansu i się cofają

/mob/living/basic/automaton/quadrotor
	name = "dron czterowirnikowy"
	desc = "Dziwnie wyglądający dron z zamontowanym pistoletem 10 mm."
	health = 45
	maxHealth = 45
	speed = 1
	flying = TRUE
	projectile_type = /obj/item/projectile/bullet/c10mm
	death_message = "spada na ziemię, sypiąc iskrami, a wirniki z chrzęstem stają."
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged

/mob/living/basic/automaton/quadrotor/cybersun
	name = "uszkodzony dron Y-09-CS"
	desc = "Kanciasty dron Cybersun z czasów Wojny Międzykorporacyjnej. Słynął z tego, że strzelał do własnych żołnierzy. Ten krąży bez celu, odkąd ktoś go porzucił."
	icon_state = "quadrotor_coalition"
	icon_living = "quadrotor_coalition"
	health = 60
	maxHealth = 60
	projectile_type = /obj/item/projectile/bullet/c9mm

/mob/living/basic/automaton/quadrotor/cybersun/waste
	faction = list("hivebot")

/mob/living/basic/automaton/quadrotor/makosso
	name = "wadliwy dron „Szerszeń” Vigilitas"
	desc = "Dron ochrony Vigilitas Interstellar. Zamiast pocisków sypie gradem słabych wiązek laserowych."
	icon_state = "quadrotor_warra"
	icon_living = "quadrotor_warra"
	health = 60
	maxHealth = 60
	projectile_type = /obj/item/projectile/beam/weak
	projectile_sound = 'sound/weapons/laser.ogg'
	burst_shots = 4
	ranged_cooldown = 3 SECONDS
	faction = list("nanotrasenprivate")

/mob/living/basic/automaton/quadrotor/makosso/waste
	faction = list("hivebot")

// Grawitacyjne amunicje krążące: szybkie, walczą wręcz

/mob/living/basic/automaton/agrav
	name = "dron grawitacyjny „Verefasa”"
	desc = "Zaawansowana amunicja krążąca Cybersun z końca Wojny Międzykorporacyjnej. Ten egzemplarz przerobiono na zwykłego drona roboczego."
	icon_state = "independent_agrav"
	icon_living = "independent_agrav"
	health = 150
	maxHealth = 150
	melee_damage = 10
	attack_verb_continuous = "szturcha"
	speed = 0.5
	flying = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.4
	light_color = COLOR_BLUE_LIGHT
	faction = list("neutral")

/mob/living/basic/automaton/agrav/cybersun
	name = "amunicja bojowa „Verefasa”"
	desc = "Amunicja krążąca Cybersun z prawie świadomym SI bojowym, napędem grawitacyjnym i sercem z mikrofuzji. Kosmonauci opowiadają straszne historie o gniazdach takich dronów na porzuconych złożach."
	icon_state = "cybersun_agrav"
	icon_living = "cybersun_agrav"
	light_color = LIGHT_COLOR_FLARE
	melee_damage = 35
	melee_damage_type = BURN
	melee_attack_cooldown = 1 SECONDS
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/blade1.ogg'
	faction = list("hostile")
	aggro_lines = list("Wykryto niezarejestrowany obiekt. Usuwam.", "Nie powinno cię tu być.", "Kod 5-11-7. Ten teren jest zajęty. Natychmiast odejdź.")
	aggro_line_chance = 70

/mob/living/basic/automaton/agrav/cybersun/waste
	faction = list("hivebot")

// Łaziki obronne: seria z karabinu z dystansu

/mob/living/basic/automaton/rover
	name = "łazik obronny „Tropiciel” Vigilitas"
	desc = "Gąsienicowy łazik obronny Vigilitas Interstellar z karabinkiem na wieżyczce."
	icon_state = "warratread"
	icon_living = "warratread"
	health = 100
	maxHealth = 100
	speed = 1.5
	projectile_type = /obj/item/projectile/bullet/c9mm
	burst_shots = 3
	ranged_cooldown = 3 SECONDS
	faction = list("nanotrasenprivate")
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/close

/mob/living/basic/automaton/rover/coalition
	name = "łazik bojowy „Teemeres”"
	desc = "Gąsienicowy łazik bojowy w barwach koalicji Syndykatu."
	icon_state = "coalitiontread"
	icon_living = "coalitiontread"
	faction = list(FACTION_SYNDICATE)

/// Wersja z karabinem wyborowym: dwa celne strzały z dużej odległości
/mob/living/basic/automaton/rover/coalition/dmr
	name = "łazik bojowy „Temere-Lito”"
	icon_state = "coalitiontread_range"
	icon_living = "coalitiontread_range"
	projectile_type = /obj/item/projectile/bullet/a556
	burst_shots = 2
	ranged_cooldown = 4 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/far

// Dwunożne platformy szturmowe: powolne, wytrzymałe, z bliska odrzucają cel

/mob/living/basic/automaton/bipedal
	name = "dwunożna platforma szturmowa"
	desc = "Ociężały automat w barwach koalicji ze strzelbą zamiast lewego ramienia. Prosty program wykrywania zagrożeń kieruje lufę w twoją stronę."
	icon_state = "coalition_bipedal"
	icon_living = "coalition_bipedal"
	mob_size = MOB_SIZE_LARGE
	health = 250
	maxHealth = 250
	speed = 4
	melee_damage = 35
	attack_verb_continuous = "miażdży"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	casing_type = /obj/item/ammo_casing/shotgun/buckshot
	projectile_sound = 'sound/weapons/gunshot.ogg'
	ranged_cooldown = 3 SECONDS
	death_message = "pada, a jego wizjer gaśnie."
	faction = list(FACTION_SYNDICATE)
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/close

/mob/living/basic/automaton/bipedal/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(. && isliving(target))
		var/mob/living/bonk = target
		if(!bonk.anchored)
			bonk.throw_at(get_edge_target_turf(bonk, dir), rand(1, 3), 2, src)

/mob/living/basic/automaton/bipedal/makosso
	desc = "Ociężały automat z tytanu Tri-Corp z karabinem laserowym zamiast lewego ramienia."
	icon_state = "makosso_bipedal"
	icon_living = "makosso_bipedal"
	casing_type = null
	projectile_type = /obj/item/projectile/beam/laser
	projectile_sound = 'sound/weapons/laser.ogg'
	burst_shots = 2
	faction = list("nanotrasenprivate")

/// Tańsza wersja platformy do walki wręcz, z miotaczem słabych wiązek
/mob/living/basic/automaton/bipedal/boxer
	name = "platforma B.A.P. II „Bokser”"
	desc = "Tańsza wersja dwunożnej platformy szturmowej, zrobiona do zwarcia: lżejsza konstrukcja, słabsza broń, dużo agresji."
	icon_state = "boxer"
	icon_living = "boxer"
	health = 200
	maxHealth = 200
	speed = 1.5
	melee_damage = 40
	casing_type = null
	projectile_type = /obj/item/projectile/beam/weak
	projectile_sound = 'sound/weapons/laser.ogg'
	burst_shots = 6
	faction = list("nanotrasenprivate")
	aggro_lines = list("Wykryto intruza. Tłumię.", "Napastnik nie współpracuje. Atakuję.", "Przestań się opierać.")
	aggro_line_chance = 60
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/close

/mob/living/basic/automaton/bipedal/boxer/crap
	name = "zużyty „Bokser” B.A.P. II"
	desc = "Tańsza wersja dwunożnej platformy szturmowej. Ta jest w opłakanym stanie."
	health = 60
	maxHealth = 60

// Szybkie drony do walki z bliska

/mob/living/basic/automaton/hopper
	name = "dron CQB „Skoczek” Al'sa"
	desc = "Specjalistyczny dron Gildii Al'sa do szybkich potyczek z bliska, nazwany od skaczącego chodu. Strzela laserowym śrutem."
	icon_state = "hopper"
	icon_living = "hopper"
	health = 100
	maxHealth = 100
	speed = 0.5
	melee_damage = 12
	attack_verb_continuous = "kopie"
	projectile_type = /obj/item/projectile/beam/weak
	projectile_sound = 'sound/weapons/laser.ogg'
	burst_shots = 3
	ranged_cooldown = 2 SECONDS
	faction = list("neutral")
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/close

/mob/living/basic/automaton/hopper/warra
	icon_state = "hopper_warra"
	icon_living = "hopper_warra"
	faction = list("nanotrasenprivate")

/mob/living/basic/automaton/hopper/coalition
	icon_state = "hopper_coalition"
	icon_living = "hopper_coalition"
	faction = list(FACTION_SYNDICATE)

// Trójnogi: dron domowy przerobiony na snajpera

/mob/living/basic/automaton/tripod
	name = "„Pomocnik” Sav'cla"
	desc = "Dron Gildii Al'Sa pierwotnie zrobiony do pomocy w domu. Doskonałe czujniki optyczne, które czyniły go świetnym pomocnikiem, czynią go też świetną maszyną wojenną."
	icon_state = "tripod"
	icon_living = "tripod"
	health = 100
	maxHealth = 100
	speed = 2
	melee_damage = 10
	attack_verb_continuous = "drapie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("neutral")

/mob/living/basic/automaton/tripod/ramzi
	name = "dron strzelecki „Sav'sha'syn”"
	desc = "Przerobiony trójnóg Sav'cla. Poszycie zardzewiałe, czujniki migoczą, a ciężki karabin obraca się w twoją stronę."
	icon_state = "tripod_clique"
	icon_living = "tripod_clique"
	health = 150
	maxHealth = 150
	projectile_type = /obj/item/projectile/bullet/a762
	ranged_cooldown = 4 SECONDS
	faction = list(FACTION_SYNDICATE)
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/far

/mob/living/basic/automaton/tripod/warra
	name = "dron plazmowy „Sav'sha'kosso”"
	desc = "Przerobiony trójnóg Sav'cla w barwach Vigilitas z ciężkim karabinem laserowym."
	icon_state = "tripod_warra"
	icon_living = "tripod_warra"
	health = 150
	maxHealth = 150
	projectile_type = /obj/item/projectile/beam/laser/heavylaser
	projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	ranged_cooldown = 4 SECONDS
	faction = list("nanotrasenprivate")
	ai_controller = /datum/ai_controller/basic_controller/automaton/ranged/far

// Mina krocząca: podchodzi do celu i wybucha

/mob/living/basic/automaton/walkmine
	name = "mina krocząca G-80W"
	desc = "Niekonwencjonalna przeróbka miny skaczącej G-80P. Po Wojnie Międzykorporacyjnej zakazana w większości jurysdykcji."
	icon_state = "mine_walker"
	icon_living = "mine_walker"
	health = 45
	maxHealth = 45
	speed = 0.5
	melee_damage = 0
	attack_verb_continuous = "dotyka"
	basic_mob_flags = NONE
	light_system = MOVABLE_LIGHT
	light_range = 0
	light_color = "#D74722"
	death_message = ""
	/// Opóźnienie wybuchu po uzbrojeniu
	var/blast_delay = 1.5 SECONDS
	/// Zasięg wybuchu
	var/mine_heavy = 1
	var/mine_light = 3
	var/mine_flame = 1
	/// Czy już tyka
	var/armed = FALSE

/mob/living/basic/automaton/walkmine/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(!client)
		arm()
		return FALSE
	return ..()

/// Mina staje, świeci i po chwili wybucha
/mob/living/basic/automaton/walkmine/proc/arm()
	if(armed)
		return
	armed = TRUE
	playsound(src, 'sound/machines/triple_beep.ogg', 70, FALSE)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, REF(src))
	ai_controller?.set_ai_status(AI_STATUS_OFF)
	icon_state = "mine_walker_explode"
	set_light_range(3)
	addtimer(CALLBACK(src, PROC_REF(detonate)), blast_delay)

/mob/living/basic/automaton/walkmine/proc/detonate()
	if(QDELETED(src))
		return
	var/turf/blast_turf = get_turf(src)
	visible_message(span_warning("[src] wybucha!"))
	qdel(src)
	explosion(blast_turf, 0, mine_heavy, mine_light, flame_range = mine_flame, adminlog = FALSE)

/mob/living/basic/automaton/walkmine/death(gibbed)
	. = ..()
	if(!QDELETED(src))
		detonate()

/mob/living/basic/automaton/walkmine/waste
	faction = list("hivebot")

/mob/living/basic/automaton/walkmine/ramzi
	faction = list(FACTION_SYNDICATE)

/mob/living/basic/automaton/walkmine/incendiary
	name = "zapalająca mina krocząca G-82"
	desc = "Krocząca amunicja z miotaczem ognia, miną zapalającą G-82 i workiem mieszanki benzyny, plazmy i napalmu."
	icon_state = "mine_walker-incendiary"
	icon_living = "mine_walker-incendiary"
	light_color = "#f89421"
	mine_heavy = 0
	mine_light = 2
	mine_flame = 4

// AI

/datum/ai_controller/basic_controller/automaton
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/// Strzela z 4-6 pól
/datum/ai_controller/basic_controller/automaton/ranged
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 4,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/automaton,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
	)

/// Strzela z bliska (2-4 pola), a przyparty do muru bije wręcz
/datum/ai_controller/basic_controller/automaton/ranged/close
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4,
	)

/// Strzela z daleka (7-9 pól)
/datum/ai_controller/basic_controller/automaton/ranged/far
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 7,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 9,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/automaton
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/automaton

/datum/ai_behavior/basic_ranged_attack/automaton
	avoid_friendly_fire = TRUE
	required_distance = 9
