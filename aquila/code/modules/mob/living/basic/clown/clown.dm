// AQUILA: port of tgstation code/modules/mob/living/basic/clown/ (clown.dm, clown_ai.dm; tg 926bf40c5a) in place of our simple animal
// retaliate/clown.dm. Polish names, lines, health, damage and loot of our simple animal clowns.
// Changes against tg:
// - faction "hostile" like our retaliating clowns (tg FACTION_CLOWN), cold/heat damage as our handle_temperature_damage() (10/15);
// - speech through random_speech/blackboard with our lines (emotes without a final dot, as before);
// - the honkling, honkmunculus and glutton inject our attack reagents (laughter, confusion, mindbreaker; 5 units) through venomous;
// - the clownana keeps dropping peels on its own: its AI uses the rustle ability (tg gives it to players only); no exquisite
//   bunch (we have no banana bunch);
// - the glutton is our "coś, co kiedyś było klaunem" (mutant/blob) with tg's fat (damage_threshold 10), without eating,
//   the prank pouch, taming or riding;
// - the fleshclown loses its hands (dextrous; basic mobs have none); no swabbing, no bloodtype override, no footstep element
//   (our footstep component, do_footstep).
/mob/living/basic/clown
	name = JOB_NAME_CLOWN
	desc = "Mieszkaniec planety klaunów."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	response_help_continuous = "szturcha"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "robustuje"
	combat_mode = TRUE
	maxHealth = 75
	health = 75
	speed = 1
	melee_damage = 10
	attack_verb_continuous = "atakuje"
	attack_sound = 'sound/items/bikehorn.ogg'
	attacked_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	basic_mob_flags = DEL_ON_DEATH
	mobchatspan = "clown"
	faction = list(FACTION_HOSTILE)
	gold_core_spawnable = HOSTILE_SPAWN
	do_footstep = TRUE
	habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	minimum_survivable_temperature = 270
	maximum_survivable_temperature = 370
	unsuitable_cold_damage = 10
	unsuitable_heat_damage = 15
	ai_controller = /datum/ai_controller/basic_controller/clown
	///list of stuff we drop on death
	var/list/loot = list(/obj/effect/mob_spawn/human/clown/corpse)
	///blackboard emote list
	var/list/emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "Witaj na planecie klaunów!"),
		BB_EMOTE_SEE = list("trąbi", "piszczy"),
		BB_SPEAK_CHANCE = 1,
	)
	///do we waddle (honk)
	var/waddles = TRUE
	/// Reagent our hits inject (our simple clowns' attack_reagent), 5 units
	var/attack_reagent

/mob/living/basic/clown/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NAIVE, INNATE_TRAIT)
	AddComponent(/datum/component/ai_retaliate_advanced, CALLBACK(src, PROC_REF(retaliate_callback)))
	ai_controller?.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, emotes)
	if(waddles)
		AddComponent(/datum/component/waddling)
	if(length(loot))
		AddElement(/datum/element/death_drops, string_list(loot))
	if(attack_reagent)
		AddElement(/datum/element/venomous, attack_reagent, 5, TRUE)

/// Every clown around joins the fight against whoever hit one of them
/mob/living/basic/clown/proc/retaliate_callback(mob/living/attacker)
	if (!istype(attacker))
		return
	for (var/mob/living/basic/clown/harbringer in oview(src, 7))
		harbringer.ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/datum/ai_controller/basic_controller/clown
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/blackboard,
	)

/// The Destroyer keeps hitting the unconscious (our stat_attack = UNCONSCIOUS)
/datum/ai_controller/basic_controller/clown/murder
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

/// The clownana drops banana peels around itself now and then
/datum/ai_controller/basic_controller/clown/banana
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/use_mob_ability/rustle,
		/datum/ai_planning_subtree/random_speech/blackboard,
	)

/datum/ai_planning_subtree/use_mob_ability/rustle
	ability_key = BB_GENERIC_ACTION

/mob/living/basic/clown/lube
	name = "żywy smar"
	desc = "Kałuża smaru ożywiona przez Honkmatkę."
	icon_state = "lube"
	icon_living = "lube"
	response_help_continuous = "zanurza palec w"
	response_disarm_continuous = "delikatnie zgarnia i odlewa na bok"
	emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "Witaj na planecie klaunów!"),
		BB_EMOTE_SEE = list("bąbelkuje", "sączy się"),
		BB_SPEAK_CHANCE = 1,
	)
	waddles = FALSE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/particle_effect/foam)

/mob/living/basic/clown/lube/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lube_walking, TURF_WET_LUBE, 10 SECONDS)

/mob/living/basic/clown/banana
	name = "klaunan"
	desc = "Połączenie DNA klauna i banana, zrodzone z nieudanego eksperymentu botanicznego."
	icon_state = "banana tree"
	icon_living = "banana tree"
	response_help_continuous = "szturcha"
	response_disarm_continuous = "obiera"
	response_harm_continuous = "obiera"
	emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "JA-HONK!!!"),
		BB_EMOTE_SEE = list("trąbi", "wgryza się w banana", "zrywa banana ze swojej głowy", "fotosyntetyzuje"),
		BB_EMOTE_SOUND = list('sound/items/bikehorn.ogg'),
		BB_SPEAK_CHANCE = 1,
	)
	maxHealth = 120
	health = 120
	speed = -10
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/plant_seeds/preset/banana)
	ai_controller = /datum/ai_controller/basic_controller/clown/banana

/mob/living/basic/clown/banana/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/rustle = BB_GENERIC_ACTION,
	)
	grant_actions_by_list(innate_actions)

///drops peels around the mob when activated
/datum/action/cooldown/mob_cooldown/rustle
	name = "Szelest"
	desc = "Strząśnij z siebie kilka skórek od banana."
	cooldown_time = 8 SECONDS
	melee_cooldown_time = 0
	click_to_activate = FALSE
	icon_icon = 'icons/obj/hydroponics/harvest.dmi'
	button_icon_state = "banana_peel"
	///which type of peel to spawn
	var/banana_type = /obj/item/grown/bananapeel
	///How many peels to spawn
	var/peel_amount = 3

/datum/action/cooldown/mob_cooldown/rustle/Activate(atom/target)
	var/list/reachable_turfs = list()
	for(var/turf/adjacent_turf in RANGE_TURFS(1, owner.loc))
		if(adjacent_turf == owner.loc || !adjacent_turf.IsReachableBy(owner) || !isopenturf(adjacent_turf))
			continue
		reachable_turfs += adjacent_turf

	var/peels_to_spawn = min(peel_amount, reachable_turfs.len)
	for(var/i in 1 to peels_to_spawn)
		new banana_type(pick_n_take(reachable_turfs))
	playsound(owner, 'sound/items/bikehorn.ogg', 60)
	StartCooldown()
	return TRUE

/mob/living/basic/clown/honkling
	name = "honkuś"
	desc = "Boska istota zesłana przez Honkmatkę, by szerzyć radość. Nie jest groźna, ale bywa uciążliwa."
	icon_state = "honkling"
	icon_living = "honkling"
	speed = -10
	melee_damage = 1
	attack_verb_continuous = "pociesza"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap, /obj/item/plant_seeds/preset/bs_banana)
	attack_reagent = /datum/reagent/consumable/laughter

/mob/living/basic/clown/fleshclown
	name = "mięsoklaun"
	desc = "Istota wykuta z czystej esencji psikusów, powołana do istnienia klątwą okrutnego stwórcy."
	icon_state = "fleshclown"
	icon_living = "fleshclown"
	response_help_continuous = "niechętnie szturcha"
	response_disarm_continuous = "zanurza dłonie w gąbczastym ciele"
	response_harm_continuous = "oczyszcza świat z"
	emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "Nie prosiłem się o to", "Czuję ciągły, straszny ból", "JA-HONK!!!", "to ciało to bezlitosne i nieprzebaczające więzienie", "zrodziłem się z radosnych psot, ale żyję w cierpieniu"),
		BB_EMOTE_SEE = list("trąbi", "poci się", "trzęsie się", "rozmyśla nad swoim istnieniem"),
		BB_SPEAK_CHANCE = 5,
	)
	ventcrawler = VENTCRAWLER_ALWAYS
	maxHealth = 140
	health = 140
	speed = -5
	melee_damage = 15
	attack_verb_continuous = "bezwładnie klepie"
	obj_damage = 5
	loot = list(/obj/item/clothing/suit/hooded/bloated_human, /obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/basic/clown/longface
	name = "Ponurak"
	desc = "Często spotykany, gdy wchodzi do baru."
	icon_state = "long face"
	icon_living = "long face"
	move_resist = INFINITY
	response_help_continuous = "niezgrabnie próbuje przytulić"
	response_disarm_continuous = "popycha nieporęczną konstrukcję"
	response_harm_continuous = "próbuje uciszyć"
	emotes = list(
		BB_EMOTE_SAY = list("JA-HONK!!!"),
		BB_EMOTE_SEE = list("trąbi", "piszczy"),
		BB_SPEAK_CHANCE = 60,
	)
	maxHealth = 150
	health = 150
	pixel_x = -16
	base_pixel_x = -16
	speed = 10
	melee_damage = 5
	attack_verb_continuous = "JA-HONKUJE na"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/basic/clown/clownhulk
	name = "Honk Hulk"
	desc = "Okrutny i przerażający klaun. Nie denerwuj go."
	icon_state = "honkhulk"
	icon_living = "honkhulk"
	move_resist = INFINITY
	response_help_continuous = "desperacko próbuje udobruchać"
	response_disarm_continuous = "głupio popycha"
	response_harm_continuous = "rozwściecza"
	emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "HAUAUANK!!!", "GUUURRRRAAAHHH!!!"),
		BB_EMOTE_SEE = list("trąbi", "poci się", "chrząka"),
		BB_SPEAK_CHANCE = 5,
	)
	maxHealth = 400
	health = 400
	pixel_x = -16
	base_pixel_x = -16
	speed = 2
	melee_damage = 17
	attack_verb_continuous = "okłada pięściami"
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/basic/clown/clownhulk/chlown
	name = "Chlaun"
	desc = "Prawdziwy tępak, który jakimś cudem ma powodzenie u wszystkich dziewczyn."
	icon_state = "chlown"
	icon_living = "chlown"
	response_help_continuous = "poddaje się"
	response_disarm_continuous = "próbuje zdominować"
	response_harm_continuous = "wykonuje słaby, betowy atak na"
	emotes = list(
		BB_EMOTE_SAY = list("HONK", "Honk!", "Bruh", "cheeaaaahhh?"),
		BB_EMOTE_SEE = list("pokazuje, kto tu rządzi", "po cichu odbiera wszystkim męskość"),
		BB_SPEAK_CHANCE = 5,
	)
	maxHealth = 500
	health = 500
	speed = -2
	armour_penetration = 20
	attack_verb_continuous = "kradnie dziewczynę"
	attack_sound = 'sound/items/airhorn2.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/basic/clown/clownhulk/honkmunculus
	name = "Honkmunkulus"
	desc = "Smukła, żylasta postać alchemicznego pochodzenia."
	icon_state = "honkmunculus"
	icon_living = "honkmunculus"
	response_help_continuous = "sceptycznie szturcha"
	response_disarm_continuous = "popycha nieporęczną konstrukcję"
	emotes = list(
		BB_EMOTE_SAY = list("honk"),
		BB_EMOTE_SEE = list("wije się", "skręca się"),
		BB_SPEAK_CHANCE = 1,
	)
	maxHealth = 200
	health = 200
	speed = -5
	melee_damage = 10
	attack_verb_continuous = "zajadle szarpie"
	environment_smash = ENVIRONMENT_SMASH_NONE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap)
	attack_reagent = /datum/reagent/peaceborg/confuse

/mob/living/basic/clown/clownhulk/destroyer
	name = "Niszczyciel"
	desc = "Pradawna istota zrodzona z tajemnego trąbienia."
	icon_state = "destroyer"
	icon_living = "destroyer"
	response_disarm_continuous = "odbija się od"
	response_harm_continuous = "odbija się od"
	emotes = list(
		BB_EMOTE_SAY = list("HONK!!!", "Honkmatka jest miłosierna, więc to ja muszę wymierzyć jej gniew.", "parce mihi ad beatus honkmother placet mihi ut peccata committere,", "GIŃ!!!"),
		BB_EMOTE_SEE = list("trąbi", "poci się", "chrząka"),
		BB_SPEAK_CHANCE = 5,
	)
	maxHealth = 400
	health = 400
	speed = 5
	melee_damage = 30
	armour_penetration = 30
	attack_verb_continuous = "wymierza boską zemstę"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	ai_controller = /datum/ai_controller/basic_controller/clown/murder
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/basic/clown/mutant
	name = "Unknown"
	desc = "Zabij to dla jego własnego dobra."
	icon_state = "mutant"
	icon_living = "mutant"
	move_resist = INFINITY
	response_help_continuous = "niechętnie wbija palec w"
	response_disarm_continuous = "wciska się w"
	response_harm_continuous = "wciska się w"
	emotes = list(
		BB_EMOTE_SAY = list("aaaaaahhhhuuhhhuhhhaaaaa", "AAAaaauuuaaAAAaauuhhh", "huuuuuh... hhhhuuuooooonnnnkk", "HuaUAAAnKKKK"),
		BB_EMOTE_SEE = list("wije się", "skręca się", "pulsuje", "pieni się", "sączy się"),
		BB_SPEAK_CHANCE = 10,
	)
	maxHealth = 130
	health = 130
	pixel_x = -16
	base_pixel_x = -16
	speed = -5
	melee_damage = 15
	attack_verb_continuous = "niezgrabnie macha na"
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)

/// Our "coś, co kiedyś było klaunem" (mutant/blob); tg's banana glutton
/mob/living/basic/clown/mutant/glutton
	name = "coś, co kiedyś było klaunem"
	desc = "Groteskowa, napęczniała postać, daleko zmutowana od swojego pierwotnego stanu."
	icon_state = "blob"
	icon_living = "blob"
	emotes = list(
		BB_EMOTE_SAY = list("hej, kolego", "HONK!!!", "H-h-h-H-HOOOOONK!!!!", "HONKHONKHONK!!!", "HEJ, KOLEŻKO, WRACAJ TU!!!", "HOOOOOOOONK!!!"),
		BB_EMOTE_SEE = list("trzęsie się", "chybocze się"),
		BB_SPEAK_CHANCE = 10,
	)
	health = 130
	mob_size = MOB_SIZE_LARGE
	speed = 20
	attack_verb_continuous = "odbija się od"
	waddles = FALSE
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)
	attack_reagent = /datum/reagent/toxin/mindbreaker

/mob/living/basic/clown/mutant/glutton/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/damage_threshold, 10) //lots of fat to cushion blows.
