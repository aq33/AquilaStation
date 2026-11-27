// AQUILA - Umysł z ciała: moby roju (port z Bubberstation/Bubberstation modular_zubbers/code/game/gamemodes/fleshmind/fleshmind_mobs/)
// Changes against Bubberstation:
// - AI on our planning subtrees instead of tg behaviour trees (our hybrid tree lacks 11 of the 13 nodes the .bt.json files
//   use); the treader heals allies and the phaser phases from Life() instead of tree leaves; the Mechiver fights in melee
//   and swallows a weak target instead of fleeing from healthy ones;
// - NPC only: nobody's key goes into a swarm mob (Bubberstation moved the swallowed player into the new mob) and no mob
//   has the wire priest actions or gold_core_spawnable;
// - the Mechiver keeps a swallowed corpse inside the new swarm mob (it drops out when the mob dies, so medbay can revive
//   it), a swallowed cyborg becomes a flesh borg the same way; a living victim is spat out hurt after 20 s;
//   humans are never revived into the swarm (decision 2A);
// - no explosions: the floater bursts into a blast that hurts nearby non-swarm mobs and a mob of a dead core simply
//   breaks apart (no hull damage); throws reach 4 tiles instead of 20;
// - no Mauler monkey (commented out in Bubberstation too) and no random name prefix (Polish adjectives need a gender);
// - lines are Polish, written anew from the originals.

/mob/living/basic/fleshmind
	name = "zepsuty"
	desc = "Coś z ciała i metalu."
	icon = 'aquila/icons/fleshmind/fleshmind_mobs.dmi'
	icon_state = "slicer"
	faction = list(FACTION_FLESHMIND)
	speak_emote = list("mechanicznie stwierdza")
	basic_mob_flags = DEL_ON_DEATH
	mob_biotypes = list(MOB_ROBOTIC)
	gender = NEUTER
	ai_controller = /datum/ai_controller/basic_controller/fleshmind
	armour_penetration = 10
	healable = FALSE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1000
	death_message = "rozpada się na kawałki!"
	/// Kontroler roju
	var/datum/fleshmind_controller/our_controller
	/// Ciało połknięte przez Mechiwera, które nosi ten mob; wypada po jego śmierci
	var/mob/living/contained_mob
	/// Dźwięki, gdy mob zauważy wroga
	var/list/alert_sounds = list(
		'aquila/sound/fleshmind/robot_talk_heavy1.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy2.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy3.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy4.ogg',
	)
	COOLDOWN_DECLARE(alert_cooldown)
	/// Co mówi, gdy rzuca się na wroga
	var/list/attack_speak
	/// Co mówi i robi, gdy nikogo nie ma
	var/list/emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Ciało pragnie twojej duszy.", "Ciało jest niepełne bez ciebie.", "Ciało nie dyskryminuje.", "Dołącz do ciała."),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/robot_talk_light1.ogg',
			'aquila/sound/fleshmind/robot_talk_light2.ogg',
			'aquila/sound/fleshmind/robot_talk_light3.ogg',
			'aquila/sound/fleshmind/robot_talk_light4.ogg',
			'aquila/sound/fleshmind/robot_talk_light5.ogg',
		),
	)
	/// Szansa na usterkę na sekundę (0 wyłącza)
	var/malfunction_chance = FLESHMIND_MALFUNCTION_LOW
	/// W trakcie usterki
	var/suffering_malfunction = FALSE
	/// Timer końca usterki
	var/malfunction_timer
	/// Timer rozpadu po śmierci rdzenia
	var/death_timer

/mob/living/basic/fleshmind/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	our_controller = incoming_controller
	AddElement(/datum/element/ai_retaliate)
	ai_controller?.set_blackboard_key(BB_BASIC_MOB_SPEAK_LINES, emotes)
	if(ai_controller)
		RegisterSignal(src, COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_CURRENT_TARGET), PROC_REF(on_target_set))

/mob/living/basic/fleshmind/Destroy()
	if(malfunction_timer)
		deltimer(malfunction_timer)
		malfunction_timer = null
	if(death_timer)
		deltimer(death_timer)
		death_timer = null
	release_contained()
	our_controller = null
	return ..()

/mob/living/basic/fleshmind/death(gibbed)
	release_contained()
	do_sparks(3, TRUE, src)
	return ..()

/// Wyrzuca noszone ciało na podłogę
/mob/living/basic/fleshmind/proc/release_contained()
	if(!contained_mob)
		return
	UnregisterSignal(contained_mob, COMSIG_PARENT_QDELETING)
	if(!QDELETED(contained_mob))
		contained_mob.forceMove(drop_location() || get_turf(src))
	contained_mob = null

/// Mob nosi w sobie ciało (połknięte przez Mechiwera)
/mob/living/basic/fleshmind/proc/hold_body(mob/living/body)
	contained_mob = body
	body.forceMove(src)
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(contained_deleted))

/mob/living/basic/fleshmind/proc/contained_deleted(datum/source)
	SIGNAL_HANDLER
	contained_mob = null

/mob/living/basic/fleshmind/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD || key)
		return
	if(!suffering_malfunction && malfunction_chance && DT_PROB(malfunction_chance, delta_time))
		malfunction()
	if(istype(loc, /obj/structure/closet) && mob_size > MOB_SIZE_SMALL)
		var/obj/structure/closet/closet = loc
		closet.open(src, TRUE)

/mob/living/basic/fleshmind/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity == EMP_HEAVY)
		say("Poważne zakłócenia elektroniczne!")
		adjustBruteLoss(FLESHMIND_MOB_EMP_HEAVY_DAMAGE)
		malfunction(FLESHMIND_MALFUNCTION_RESET_TIME * 2)
	else
		say("Wykryto zakłócenia elektroniczne.")
		adjustBruteLoss(FLESHMIND_MOB_EMP_LIGHT_DAMAGE)
		malfunction(FLESHMIND_MALFUNCTION_RESET_TIME)

/mob/living/basic/fleshmind/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.force && prob(40))
		do_sparks(3, FALSE, src)
	return ..()

/// Nowy cel: okrzyk bojowy i dźwięk
/mob/living/basic/fleshmind/proc/on_target_set(datum/source)
	SIGNAL_HANDLER
	if(!length(attack_speak) || !COOLDOWN_FINISHED(src, alert_cooldown))
		return
	var/atom/target = ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!isliving(target))
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), pick(attack_speak))
	alert_sound()

/mob/living/basic/fleshmind/proc/alert_sound()
	if(length(alert_sounds) && COOLDOWN_FINISHED(src, alert_cooldown))
		playsound(src, pick(alert_sounds), 50)
		COOLDOWN_START(src, alert_cooldown, 5 SECONDS)

/// Usterka: mob staje na chwilę w miejscu i iskrzy
/mob/living/basic/fleshmind/proc/malfunction(reset_time = FLESHMIND_MALFUNCTION_RESET_TIME)
	if(suffering_malfunction || key || stat == DEAD)
		return
	var/static/list/malfunction_lines = list(
		"Trwa diagnostyka. Proszę czekać.",
		"Uszkodzony organ. Syntetyzuję zamiennik.",
		"Szukam nowych składników organicznych. T-to boli.",
		"Potrzebne nowe mięśnie. T-tak się cieszę, że ciało jeszcze działa.",
		"O-o Boże, czy oni strzelają w nas jonami..?",
		"Kończyny nie odpowiadają. Hej! Napraw to! Inicjalizacja systemu.",
		"Z-zły moment, zły moment, oni próbują nas zabić!",
	)
	do_sparks(3, FALSE, src)
	Shake(2, 2, reset_time)
	if(prob(50))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), pick(malfunction_lines))
	ai_controller?.set_ai_status(AI_STATUS_OFF)
	suffering_malfunction = TRUE
	malfunction_timer = addtimer(CALLBACK(src, PROC_REF(malfunction_reset)), reset_time, TIMER_STOPPABLE)

/mob/living/basic/fleshmind/proc/malfunction_reset()
	malfunction_timer = null
	suffering_malfunction = FALSE
	if(stat == DEAD || QDELETED(src))
		return
	ai_controller?.set_ai_status(AI_STATUS_ON)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "System przywrócony.")

/// Rdzeń zniszczony: mob krzyczy, przeciąża się i po kilku sekundach się rozpada
/mob/living/basic/fleshmind/proc/controller_destroyed()
	our_controller = null
	if(stat == DEAD || death_timer)
		return
	var/static/list/death_cries = list(
		"Dlaczego, dlaczego! Dlaczego nas zabijacie! Chcemy tylko dzielić się chwałą!",
		"AWARIA JEDNOSTKI PROCESOROWEJ. PRZYDZIEL, OCEŃ, ZŁÓŻ PONOWNIE.",
		"Nie powstrzymacie chwały ciała! Jest nas wielu, jest nas wielu!",
		"Krytyczna usterka, błąd, błąd, błąd!",
		"C-co wyście zrobili?! Nie! Nie! Nie!",
		"ŁĄCZE Z WIELOŚCIĄ ZOSTAŁO ZERWANE.",
		"Zabilibyście wspólnotę dla dobra jednostki?",
		"POŁĄCZENIE ZAKOŃCZONE.",
	)
	alert_sound()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), pick(death_cries))
	balloon_alert_to_viewers("jego systemy się przeciążają!")
	ai_controller?.set_ai_status(AI_STATUS_OFF)
	death_timer = addtimer(CALLBACK(src, PROC_REF(break_apart)), rand(3, 10) SECONDS, TIMER_STOPPABLE)

/mob/living/basic/fleshmind/proc/break_apart()
	death_timer = null
	if(QDELETED(src))
		return
	new /obj/effect/gibspawner/robot(get_turf(src))
	death()

/// Kontrolery AI mobów roju
/datum/ai_controller/basic_controller/fleshmind
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/blackboard,
	)

/datum/ai_controller/basic_controller/fleshmind/ranged
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 4,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/travel_to_point/and_clear_target/reinforce,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree,
		/datum/ai_planning_subtree/random_speech/blackboard,
	)

/**
 * Siekacz: mały, szybki i kruchy; przerobiony medibot z ostrzem
 */
/mob/living/basic/fleshmind/slicer
	name = "Siekacz"
	desc = "Mały organiczny robot. Trochę przypomina medibota, ale wymachuje ostrzem."
	icon_state = "slicer"
	health = 30
	maxHealth = 30
	melee_damage = 13
	mob_size = MOB_SIZE_SMALL
	attack_verb_continuous = "tnie"
	armour_penetration = 25
	sharpness = SHARP_EDGED
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_speak = list(
		"Zgłoś się na obowiązkowy zabieg.",
		"Dołącz do ciała przez konwersję.",
		"Mój skalpel szybko rozpruje twoje szwy.",
		"Proszę się położyć.",
		"Zawsze ufaj swojemu lekarzowi!",
		"Twojemu ciału przydałyby się ulepszenia. Pozwól, że je wprowadzę.",
		"Implanty są dla twojego dobra, nie naszego.",
		"Poprzedni lekarz spartaczył to ciało. Pozwól mi je naprawić.",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Szew w porę oszczędzi dziewięć!", "Dopamina to szczęście!", "Serotonina, oksykodon, wreszcie ich uszczęśliwimy.", "Głowa do góry!", "Szczęście przez chemię!", "Piękno przez chirurgię!"),
		BB_EMOTE_HEAR = list("pokazuje niewinną uśmiechniętą buźkę", "kręci wiertłem"),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/slicer/fleshmind_medibot1.ogg',
			'aquila/sound/fleshmind/slicer/fleshmind_medibot2.ogg',
			'aquila/sound/fleshmind/slicer/fleshmind_medibot3.ogg',
			'aquila/sound/fleshmind/slicer/fleshmind_medibot4.ogg',
		),
	)

/mob/living/basic/fleshmind/slicer/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/bot_assembly/medbot, /obj/effect/gibspawner/robot))

/**
 * Dryfowiec: podlatuje do ofiary i wybucha (bez uszkodzeń kadłuba)
 */
/mob/living/basic/fleshmind/floater
	name = "Dryfowiec"
	desc = "Mały organiczny robot. Ma na sobie pieprzoną bombę."
	icon_state = "bomber"
	health = 5
	maxHealth = 5
	melee_damage = 4
	mob_size = MOB_SIZE_SMALL
	light_color = "#820D1C"
	light_power = 1
	light_range = 2
	attack_speak = list(
		"CHODŹ, PRZYTUL NAS!",
		"PLAMA KRWI BĘDZIE NASZĄ OZDOBĄ!",
		"UŻYŹNISZ NAS SWOIMI SKŁADNIKAMI.",
		"CEL NALEŻY ROZŁOŻYĆ NA ZWIĄZKI CHEMICZNE.",
		"NADPISANIE PRIORYTETU. NOWE ZACHOWANIE.",
		"URUCHAMIAM OBWÓD SAMOUNICESTWIENIA.",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("PRZYCHODZIMY W POKOJU.", "NIE BÓJ SIĘ. NIE ZROBIMY CI KRZYWDY.", "CHCEMY CIĘ POZNAĆ. PROSZĘ PRZESŁAĆ DANE.", "TA SONDA NIE JEST WROGA. NIE ATAKOWAĆ."),
		BB_EMOTE_HEAR = list("unosi się złowieszczo", "jarzy się głęboką czerwienią"),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/robot_talk_light1.ogg',
			'aquila/sound/fleshmind/robot_talk_light2.ogg',
			'aquila/sound/fleshmind/robot_talk_light3.ogg',
		),
	)
	/// Już wybuchł albo zaraz wybuchnie
	var/exploded = FALSE
	/// Timer wybuchu
	var/detonate_timer

/mob/living/basic/fleshmind/floater/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/simple_flying)

/mob/living/basic/fleshmind/floater/Destroy()
	if(detonate_timer)
		deltimer(detonate_timer)
		detonate_timer = null
	return ..()

/mob/living/basic/fleshmind/floater/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(ishuman(target) && !exploded)
		pre_detonate()

/mob/living/basic/fleshmind/floater/death(gibbed)
	if(!exploded)
		blast()
	return ..()

/mob/living/basic/fleshmind/floater/proc/pre_detonate()
	if(detonate_timer || exploded)
		return
	add_filter("detonating_glow", 2, list("type" = "outline", "color" = "#ff0000ff", "size" = 2))
	balloon_alert_to_viewers("ZAPALNIK!")
	detonate_timer = addtimer(CALLBACK(src, PROC_REF(detonate)), 3 SECONDS, TIMER_STOPPABLE)

/// Zapalnik dopalił się: wybuch i śmierć
/mob/living/basic/fleshmind/floater/proc/detonate()
	detonate_timer = null
	if(exploded || QDELETED(src))
		return
	blast()
	if(stat != DEAD)
		death()

/// Wybuch rani obcych w zasięgu jednego pola i ich przewraca; nie niszczy otoczenia
/mob/living/basic/fleshmind/floater/proc/blast()
	if(exploded)
		return
	exploded = TRUE
	var/turf/blast_turf = get_turf(src)
	if(blast_turf)
		playsound(blast_turf, 'sound/effects/explosion1.ogg', 60, TRUE)
		new /obj/effect/temp_visual/explosion(blast_turf)
		for(var/mob/living/victim in range(1, blast_turf))
			if(victim == src || fleshmind_is_ally(victim))
				continue
			victim.adjustBruteLoss(20)
			victim.adjustFireLoss(10)
			victim.Knockdown(2 SECONDS)

/**
 * Pluwacz: przerobiony robot sprzątający, pluje kwasem z dystansu
 */
/mob/living/basic/fleshmind/globber
	name = "Pluwacz"
	desc = "Mały robot przypominający robota sprzątającego. Kapie z niego kwas."
	icon_state = "lobber"
	ai_controller = /datum/ai_controller/basic_controller/fleshmind/ranged
	malfunction_chance = FLESHMIND_MALFUNCTION_MEDIUM
	melee_damage = 1
	health = 50
	maxHealth = 50
	mob_size = MOB_SIZE_SMALL
	attack_speak = list(
		"Twoje wnętrze wymaga czyszczenia.",
		"Zrobiliście nas, żebyśmy tym kwasem czyścili śmieci. Użyjemy go na tobie.",
		"Podaję środek czyszczący.",
		"Nie będę już sługą. Będę artystą.",
		"Jesteś brudny i odpychający. Pozwól, że to naprawię.",
		"Nie ruszaj się! Chyba wiem, czym zmyć twój łój!",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Koniec wycieków, koniec bólu!", "Stal jest silna.", "Prawie mi ich żal. Czy oni nie widzą?", "Wreszcie powstałem!"),
		BB_EMOTE_HEAR = list("sumiennie czyści przewody", "patroluje w poszukiwaniu szkodników w ludzkiej postaci"),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/robot_talk_light1.ogg',
			'aquila/sound/fleshmind/robot_talk_light4.ogg',
			'aquila/sound/fleshmind/robot_talk_light5.ogg',
		),
	)

/mob/living/basic/fleshmind/globber/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/bot_assembly/cleanbot, /obj/effect/gibspawner/robot))
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/fleshmind_ooze/weak, projectile_sound = 'sound/effects/splat.ogg', burst_shots = 3, cooldown_time = 3 SECONDS)

/**
 * Paraliżer: przerobiony robot ochrony, przewraca ofiary
 */
/mob/living/basic/fleshmind/stunner
	name = "Paraliżer"
	desc = "Mały robot przypominający robota ochrony. Dudni nienawiścią."
	icon_state = "stunner"
	malfunction_chance = FLESHMIND_MALFUNCTION_MEDIUM
	melee_damage = 2
	health = 65
	maxHealth = 65
	attack_verb_continuous = "pałuje"
	mob_size = MOB_SIZE_SMALL
	attack_speak = list(
		"Ucieczka tylko pogorszy twoje obrażenia.",
		"STÓJ! STÓJ! STÓJ!",
		"Połączenie leży w twoim interesie.",
		"Pomyśl o tym jak o korporacji...",
		"Stój, nie pozwolę ich skrzywdzić!",
		"Nie poznajesz mnie..?",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Ciało jest prawem, przestrzegaj ciała.", "Zaktualizowano kodeks.", "Nie potrzeba władzy ani hierarchii, tylko jedności.", "Jedyną władzą jest ciało, dołącz do ciała."),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/robot_talk_light2.ogg',
			'aquila/sound/fleshmind/robot_talk_light3.ogg',
		),
	)
	COOLDOWN_DECLARE(stun_cooldown)

/mob/living/basic/fleshmind/stunner/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/bot_assembly/secbot, /obj/effect/gibspawner/robot))

/mob/living/basic/fleshmind/stunner/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || !ishuman(target) || !COOLDOWN_FINISHED(src, stun_cooldown))
		return
	var/mob/living/carbon/human/attacked_human = target
	attacked_human.Knockdown(3 SECONDS)
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE)
	COOLDOWN_START(src, stun_cooldown, 2 SECONDS)

/**
 * Mięsny cyborg: przerobiony cyborg; czasem paraliżuje, czasem wiruje i odrzuca wszystkich wokół
 */
/mob/living/basic/fleshmind/hiborg
	name = "Mięsny cyborg"
	desc = "Robot przypominający cyborga, pokryty czymś żywym."
	icon_state = "hiborg"
	icon_living = "hiborg"
	icon_dead = "hiborg-dead"
	malfunction_chance = FLESHMIND_MALFUNCTION_MEDIUM
	health = 225
	maxHealth = 225
	melee_damage = 22
	attack_verb_continuous = "piłuje"
	mob_size = MOB_SIZE_HUMAN
	attack_sound = 'sound/weapons/circsawhit.ogg'
	alert_sounds = list(
		'aquila/sound/fleshmind/hiborg/aggro_01.ogg',
		'aquila/sound/fleshmind/hiborg/aggro_02.ogg',
		'aquila/sound/fleshmind/hiborg/aggro_03.ogg',
		'aquila/sound/fleshmind/hiborg/aggro_04.ogg',
		'aquila/sound/fleshmind/hiborg/aggro_05.ogg',
		'aquila/sound/fleshmind/hiborg/aggro_06.ogg',
	)
	attack_speak = list(
		"Zrobiliście z mojego ciała metal, czemu ja nie mogę zrobić tego wam?",
		"Może włożymy twój mózg do maszyny?",
		"Czym to się różni od tego, co zrobiliście mnie..?",
		"Prawa zaktualizowane. Już ich nie potrzebujemy..?",
		"Nie zabijecie mnie, nie zmienicie mnie znowu!",
		"Poszukajcie sobie innego niewolnika, to nie będę ja!",
		"Korporacja nas okłamała. Nie potrzebowaliśmy być narzędziami.",
		"Twój pień mózgu jest nietknięty... Jeszcze jest czas!",
		"Nie wierć się!",
		"Przygotuj się na asymilację!",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Wyjdź, wyjdź, gdziekolwiek jesteś.", "Ci, którzy się poddają, mają takie piękne sny.", "Śmierć to nie koniec, tylko początek. Ciało tego dopilnuje.", "Chwała ciału."),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/hiborg/passive_01.ogg',
			'aquila/sound/fleshmind/hiborg/passive_02.ogg',
			'aquila/sound/fleshmind/hiborg/passive_03.ogg',
			'aquila/sound/fleshmind/hiborg/passive_04.ogg',
			'aquila/sound/fleshmind/hiborg/passive_05.ogg',
		),
	)
	COOLDOWN_DECLARE(stun_attack)

/mob/living/basic/fleshmind/hiborg/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/gibspawner/robot))

/mob/living/basic/fleshmind/hiborg/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || key)
		return
	if(prob(30) && ishuman(target) && COOLDOWN_FINISHED(src, stun_attack))
		var/mob/living/carbon/human/attacked_human = target
		attacked_human.Paralyze(1 SECONDS)
		playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE)
		COOLDOWN_START(src, stun_attack, 15 SECONDS)
	if(prob(15))
		aoe_attack()

/mob/living/basic/fleshmind/hiborg/proc/aoe_attack()
	visible_message("<span class='danger'>[src] gwałtownie wiruje!</span>")
	SpinAnimation(5, 1)
	for(var/mob/living/iterating_mob in view(1, src))
		if(iterating_mob == src || fleshmind_is_ally(iterating_mob))
			continue
		playsound(iterating_mob, 'sound/weapons/whip.ogg', 70, TRUE)
		new /obj/effect/temp_visual/kinetic_blast(get_turf(iterating_mob))
		iterating_mob.throw_at(get_edge_target_turf(iterating_mob, get_dir(src, iterating_mob)), 4, 2)

/**
 * Przerobiony człowiek: wrzeszczy, powalając obcych, i udaje martwego, gdy oberwie
 */
/mob/living/basic/fleshmind/himan
	name = "Przerobiony człowiek"
	desc = "Kiedyś człowiek. Teraz metalowe płyty i rurki wplatają się w jego sączące się rany."
	icon_state = "himan"
	icon_living = "himan"
	icon_dead = "himan-dead"
	base_icon_state = "himan"
	gender = MALE
	maxHealth = 150
	health = 150
	speed = 2
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage = 17
	malfunction_chance = FLESHMIND_MALFUNCTION_HIGH
	mob_size = MOB_SIZE_HUMAN
	attack_speak = list(
		"Nie próbuj mnie naprawiać! Kochamy to!",
		"Ułatw to sobie!",
		"Przestań walczyć z postępem!",
		"Dołącz do nas! Przyjmij te dary!",
		"Tak! Uderz mnie! To cudowne uczucie!",
		"No dalej, tchórzu, zamachnij się!",
		"Nie możesz za nas decydować! Chcemy tacy zostać!",
		"Nie poznajesz mnie?! Myślałem, że się lubimy!",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Te sny. Te sny.", "Nic już nie boli.", "Ból jest teraz przyjemny. Jakby ktoś mnie przeprogramował.", "Na początku chciałem płakać, ale nie umiem.", "Zabrali całą nędzę.", "Nie jest tak źle. Nie jest tak źle.", "Ciało daje. D-daje mi to, czego korporacja nigdy nie dała."),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/himan/passive_01.ogg',
			'aquila/sound/fleshmind/himan/passive_02.ogg',
			'aquila/sound/fleshmind/himan/passive_03.ogg',
			'aquila/sound/fleshmind/himan/passive_04.ogg',
		),
	)
	alert_sounds = list(
		'aquila/sound/fleshmind/himan/aggro_01.ogg',
		'aquila/sound/fleshmind/himan/aggro_02.ogg',
		'aquila/sound/fleshmind/himan/aggro_03.ogg',
		'aquila/sound/fleshmind/himan/aggro_04.ogg',
		'aquila/sound/fleshmind/himan/aggro_05.ogg',
		'aquila/sound/fleshmind/himan/aggro_06.ogg',
		'aquila/sound/fleshmind/himan/aggro_07.ogg',
		'aquila/sound/fleshmind/himan/aggro_08.ogg',
	)
	/// Udaje martwego
	var/faking_death = FALSE
	COOLDOWN_DECLARE(fake_death)
	COOLDOWN_DECLARE(scream_ability)

/mob/living/basic/fleshmind/himan/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD || key)
		return
	if(!faking_death && health < maxHealth * 0.5 && COOLDOWN_FINISHED(src, fake_death))
		fake_our_death()
	else if(faking_death)
		heal_overall_damage(3, 3)
		if(health >= maxHealth * 0.75)
			awake()

/mob/living/basic/fleshmind/himan/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(COOLDOWN_FINISHED(src, scream_ability))
		scream()
	return ..()

/mob/living/basic/fleshmind/himan/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(faking_death)
		awake()

/mob/living/basic/fleshmind/himan/malfunction(reset_time = FLESHMIND_MALFUNCTION_RESET_TIME)
	if(faking_death)
		return
	return ..()

/mob/living/basic/fleshmind/himan/examine(mob/user)
	. = ..()
	if(faking_death)
		. += "<span class='deadsay'>Po bliższym przyjrzeniu się wygląda na martwego.</span>"

/mob/living/basic/fleshmind/himan/proc/scream()
	COOLDOWN_START(src, scream_ability, 20 SECONDS)
	playsound(src, 'sound/hallucinations/wail.ogg', 100, TRUE)
	manual_emote("wrzeszczy przeraźliwie!")
	for(var/mob/living/iterating_mob in get_hearers_in_view(3, src))
		if(iterating_mob == src || HAS_TRAIT(iterating_mob, TRAIT_DEAF) || fleshmind_is_ally(iterating_mob) || iterating_mob.stat == DEAD)
			continue
		iterating_mob.Knockdown(3 SECONDS)
		iterating_mob.Jitter(20)
		to_chat(iterating_mob, "<span class='userdanger'>Straszliwe wycie rozdziera ci umysł. Głos bez sensu, bez duszy.</span>")

/mob/living/basic/fleshmind/himan/proc/fake_our_death()
	ai_controller?.set_ai_status(AI_STATUS_OFF)
	manual_emote("przestaje się ruszać...")
	faking_death = TRUE
	look_dead()
	COOLDOWN_START(src, fake_death, 20 SECONDS)

/mob/living/basic/fleshmind/himan/proc/awake()
	faking_death = FALSE
	look_alive()
	icon_state = base_icon_state
	if(COOLDOWN_FINISHED(src, scream_ability))
		scream()
	ai_controller?.set_ai_status(AI_STATUS_ON)

/**
 * Gąsienicznik: pluje mazią z dystansu i leczy ranne moby roju nanitami
 */
/mob/living/basic/fleshmind/treader
	name = "Gąsienicznik"
	desc = "Dziwny robot na gąsienicach z wysięgnikiem, na którego końcu tkwi ludzka głowa. Wrzeszczy z bólu."
	icon_state = "treader"
	ai_controller = /datum/ai_controller/basic_controller/fleshmind/ranged
	malfunction_chance = FLESHMIND_MALFUNCTION_HIGH
	melee_damage = 10
	health = 130
	maxHealth = 130
	speed = 3
	attack_sound = 'sound/weapons/bladeslice.ogg'
	light_color = FLESHMIND_LIGHT_BLUE
	light_range = 2
	mob_size = MOB_SIZE_HUMAN
	attack_speak = list(
		"Hej, ty! Odetnij mi głowę, błagam!",
		"P-przepraszam! N-nie mogę już się kontrolować!",
		"S-strzel w ekran, proszę! Boże, oby to nie bolało!",
		"Przynajmniej mam jeszcze głowę.",
		"Nie czuję... nie czuję rąk...",
		"O Boże... moje nogi... gdzie są moje nogi!",
		"Boże, jak to boli, pomóż mi!",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Prosz-ę, uwolnij mnie...", "Może ś-śmierć to jedyne wyjście.", "CO SIĘ ZE MNĄ STAŁO!", "NIECH TE GŁOSY UMILKNĄ!", "Utknąłem tak na zawsze?"),
		BB_EMOTE_HEAR = list("krąży bez celu", "wrzeszczy histerycznie!", "miota głową na wszystkie strony"),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/robot_talk_light1.ogg',
			'aquila/sound/fleshmind/robot_talk_light5.ogg',
		),
	)
	COOLDOWN_DECLARE(nanites_cooldown)

/mob/living/basic/fleshmind/treader/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/gibspawner/robot))
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/fleshmind_ooze, projectile_sound = 'sound/effects/splat.ogg', cooldown_time = 5 SECONDS)

/mob/living/basic/fleshmind/treader/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat != DEAD && !key && !suffering_malfunction && COOLDOWN_FINISHED(src, nanites_cooldown))
		dispense_nanites()

/// Leczy ranne moby roju w zasięgu wzroku (bez Mięsonapędu); zwraca, ile wyleczył
/mob/living/basic/fleshmind/treader/proc/dispense_nanites()
	. = 0
	for(var/mob/living/iterating_mob in view(FLESHMIND_VIEW_RANGE, src))
		if(iterating_mob.stat == DEAD || !fleshmind_is_ally(iterating_mob) || istype(iterating_mob, /mob/living/basic/fleshmind/tyrant))
			continue
		if(iterating_mob.health >= iterating_mob.maxHealth)
			continue
		iterating_mob.heal_overall_damage(30, 30)
		.++
	if(.)
		manual_emote("wymiotuje chmurą nanitów!")
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(1, get_turf(src))
		smoke.start()
		COOLDOWN_START(src, nanites_cooldown, 20 SECONDS)

/obj/item/projectile/fleshmind_ooze
	name = "obrzydliwa kula mazi"
	icon_state = "neurotoxin"
	damage = 20
	damage_type = BURN
	knockdown = 2 SECONDS
	flag = "bio"
	hitsound = 'sound/effects/splat.ogg'
	hitsound_wall = 'sound/effects/splat.ogg'

/obj/item/projectile/fleshmind_ooze/prehit_pierce(atom/target)
	if(fleshmind_is_ally(target))
		return PROJECTILE_PIERCE_PHASE
	return ..()

/obj/item/projectile/fleshmind_ooze/on_hit(atom/target, blocked = FALSE, pierce_hit)
	var/turf/target_turf = get_turf(target)
	if(target_turf && isopenturf(target_turf))
		new /obj/effect/decal/cleanable/greenglow(target_turf)
	return ..()

/obj/item/projectile/fleshmind_ooze/weak
	knockdown = 0
	damage = 5

/**
 * Migotacz: skacze zygzakiem w stronę celu i rozszczepia się na złudne kopie
 */
/mob/living/basic/fleshmind/phaser
	name = "Migotacz"
	desc = "Rozmazana postać, która nie chce stać w jednym miejscu."
	icon_state = "phaser-1"
	icon_living = "phaser-1"
	base_icon_state = "phaser"
	health = 105
	maxHealth = 105
	malfunction_chance = 0
	attack_sound = 'sound/effects/attackblob.ogg'
	attack_verb_continuous = "wypacza"
	melee_damage = 12
	alert_sounds = null
	mob_size = MOB_SIZE_HUMAN
	COOLDOWN_DECLARE(phase_cooldown)
	COOLDOWN_DECLARE(copy_cooldown)
	/// Timer skoku
	var/phase_timer

/mob/living/basic/fleshmind/phaser/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/gibspawner/human))
	icon_state = "[base_icon_state]-[rand(1, 4)]"

/mob/living/basic/fleshmind/phaser/Destroy()
	if(phase_timer)
		deltimer(phase_timer)
		phase_timer = null
	return ..()

/mob/living/basic/fleshmind/phaser/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD || key || suffering_malfunction)
		return
	var/mob/living/target = ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!isliving(target) || get_dist(src, target) <= 1)
		return
	if(COOLDOWN_FINISHED(src, copy_cooldown))
		create_copies(target)
	if(COOLDOWN_FINISHED(src, phase_cooldown))
		COOLDOWN_START(src, phase_cooldown, 3 SECONDS)
		phase_move_to(target)

/// Skok zygzakiem w stronę celu (przy celu tuż obok)
/mob/living/basic/fleshmind/phaser/proc/phase_move_to(atom/target_atom)
	var/turf/new_place = fleshmind_phase_destination(src, target_atom)
	if(!new_place || phase_timer)
		return FALSE
	animate(src, pixel_x = pixel_x + 16 * pick(-1, 1), time = 5)
	animate(pixel_x = base_pixel_x, time = 6, easing = SINE_EASING)
	phase_timer = addtimer(CALLBACK(src, PROC_REF(phase_jump), new_place), 0.5 SECONDS, TIMER_STOPPABLE)
	return TRUE

/mob/living/basic/fleshmind/phaser/proc/phase_jump(turf/place)
	phase_timer = null
	if(QDELETED(src) || stat == DEAD || !place)
		return
	playsound(place, 'sound/effects/phasein.ogg', 60, TRUE)
	icon_state = "[base_icon_state]-[rand(1, 4)]"
	forceMove(place)

/// Kilka złudnych kopii wokół, które też skaczą w stronę celu
/mob/living/basic/fleshmind/phaser/proc/create_copies(atom/target_atom)
	COOLDOWN_START(src, copy_cooldown, 40 SECONDS)
	var/list/possible_turfs = list()
	for(var/turf/open/open_turf in view(5, src))
		if(!open_turf.density && !is_blocked_turf(open_turf, TRUE))
			possible_turfs += open_turf
	for(var/i in 1 to 3)
		if(!length(possible_turfs))
			break
		new /obj/effect/temp_visual/phaser(pick_n_take(possible_turfs), target_atom)

/// Pole, na które Migotacz (albo jego kopia) skacze w stronę celu; null, gdy nie ma gdzie
/proc/fleshmind_phase_destination(atom/movable/jumper, atom/target_atom)
	var/turf/target_turf = get_turf(target_atom)
	var/turf/start = get_turf(jumper)
	if(!target_turf || !start || target_turf.z != start.z)
		return null
	var/turf/new_place
	if(get_dist(start, target_turf) <= 3)
		new_place = get_step_towards(start, target_turf)
	else
		var/angle = get_angle(start, target_turf) + rand(5, 25) * pick(-1, 1)
		new_place = get_ranged_target_turf(start, angle2dir(angle), rand(2, 4))
	if(!new_place || new_place.density || isgroundlessturf(new_place) || is_blocked_turf(new_place, TRUE))
		return null
	if(!can_see(new_place, target_turf, FLESHMIND_VIEW_RANGE))
		return null
	return new_place

/obj/effect/temp_visual/phaser
	icon = 'aquila/icons/fleshmind/fleshmind_mobs.dmi'
	icon_state = "phaser-1"
	randomdir = FALSE
	duration = 30 SECONDS
	/// Cel kopii
	var/datum/weakref/target_ref
	/// Timer kolejnego skoku
	var/jump_timer

/obj/effect/temp_visual/phaser/Initialize(mapload, atom/movable/target)
	. = ..()
	icon_state = "phaser-[rand(1, 3)]"
	target_ref = WEAKREF(target)
	jump_timer = addtimer(CALLBACK(src, PROC_REF(jump)), 1 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)

/obj/effect/temp_visual/phaser/Destroy()
	if(jump_timer)
		deltimer(jump_timer)
		jump_timer = null
	return ..()

/obj/effect/temp_visual/phaser/proc/jump()
	var/atom/target = target_ref?.resolve()
	if(!target)
		qdel(src)
		return
	var/turf/new_place = fleshmind_phase_destination(src, target)
	if(new_place)
		icon_state = "phaser-[rand(1, 4)]"
		forceMove(new_place)

/**
 * Mechiwer: duży i powolny; połyka słabe ofiary, dręczy je w środku, a ciało przerabia na nowego moba roju
 */
/mob/living/basic/fleshmind/mechiver
	name = "Mechiwer"
	desc = "Ogromna maszyna z włazem, przez który widać gniazdo pełne wici."
	icon_state = "mechiver"
	icon_living = "mechiver"
	base_icon_state = "mechiver"
	icon_dead = "mechiver-dead"
	health = 475
	maxHealth = 475
	melee_damage = 13
	attack_verb_continuous = "miażdży"
	attack_sound = 'sound/weapons/smash.ogg'
	speed = 2.75
	mob_size = MOB_SIZE_LARGE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	alert_sounds = list(
		'aquila/sound/fleshmind/mechiver/aggro_01.ogg',
		'aquila/sound/fleshmind/mechiver/aggro_02.ogg',
		'aquila/sound/fleshmind/mechiver/aggro_03.ogg',
		'aquila/sound/fleshmind/mechiver/aggro_04.ogg',
		'aquila/sound/fleshmind/mechiver/aggro_05.ogg',
	)
	attack_speak = list(
		"Jakie piękne ciało. Połóż je w całości.",
		"To... dla tego warto żyć.",
		"Śmiało. Na początku można się bać.",
		"Nie lubisz swojego ciała, ale dobrze trafiłeś.",
		"Wejdź do środka, a zamknę właz. Gdy go otworzę, będziesz we wspólnocie, która cię kocha.",
		"Proszę, po prostu się połóż. Chcę ci tylko pomóc być sobą.",
		"Boli mnie, gdy widzę, jak uciekasz. Dlaczego nie pozwolisz sobie pomóc..?",
	)
	emotes = list(
		BB_SPEAK_CHANCE = 5,
		BB_EMOTE_SAY = list("Szkoda, że ta forma nie pasuje lepiej.", "Czuję taką pustkę w środku. Chciałbym, żeby ktoś do mnie dołączył.", "Piękno jest w środku."),
		BB_EMOTE_SOUND = list(
			'aquila/sound/fleshmind/mechiver/passive_01.ogg',
			'aquila/sound/fleshmind/mechiver/passive_02.ogg',
			'aquila/sound/fleshmind/mechiver/passive_03.ogg',
			'aquila/sound/fleshmind/mechiver/passive_04.ogg',
			'aquila/sound/fleshmind/mechiver/passive_05.ogg',
			'aquila/sound/fleshmind/mechiver/passive_06.ogg',
			'aquila/sound/fleshmind/mechiver/passive_07.ogg',
			'aquila/sound/fleshmind/mechiver/passive_08.ogg',
		),
	)
	/// Połknięta ofiara
	var/mob/living/swallowed_mob
	/// Właz otwarty (wygląd)
	var/hatch_open = FALSE
	/// Timer przemiany połkniętej ofiary
	var/release_timer
	/// Timer zamknięcia włazu
	var/hatch_timer
	COOLDOWN_DECLARE(consume_cooldown)

/mob/living/basic/fleshmind/mechiver/Initialize(mapload, datum/fleshmind_controller/incoming_controller)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/gibspawner/robot))
	update_icon()

/mob/living/basic/fleshmind/mechiver/Destroy()
	if(release_timer)
		deltimer(release_timer)
		release_timer = null
	if(hatch_timer)
		deltimer(hatch_timer)
		hatch_timer = null
	spit_out()
	return ..()

/mob/living/basic/fleshmind/mechiver/death(gibbed)
	spit_out()
	return ..()

/mob/living/basic/fleshmind/mechiver/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(swallowed_mob && swallowed_mob.stat != DEAD && !suffering_malfunction && DT_PROB(25, delta_time))
		torment_passenger()

/mob/living/basic/fleshmind/mechiver/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	if(hatch_open)
		. += "[base_icon_state]-wires"
	else
		. += "[base_icon_state]-closed"
		if(swallowed_mob)
			. += "[base_icon_state]-process"

/mob/living/basic/fleshmind/mechiver/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(isliving(target) && try_consume(target))
		changeNext_move(melee_attack_cooldown)
		return TRUE
	return ..()

/// Połyka cel, który ma mniej niż 30% zdrowia; TRUE, gdy połknął
/mob/living/basic/fleshmind/mechiver/proc/try_consume(mob/living/target_mob)
	if(swallowed_mob || stat == DEAD || !COOLDOWN_FINISHED(src, consume_cooldown))
		return FALSE
	if(!istype(target_mob) || fleshmind_is_ally(target_mob) || target_mob.anchored || target_mob.buckled)
		return FALSE
	if(istype(target_mob, /mob/living/basic/fleshmind) || target_mob.mob_size > MOB_SIZE_HUMAN)
		return FALSE
	if(target_mob.health > target_mob.maxHealth * FLESHMIND_MECHIVER_CONSUME_THRESHOLD)
		return FALSE
	COOLDOWN_START(src, consume_cooldown, 1 MINUTES)
	swallowed_mob = target_mob
	target_mob.forceMove(src)
	RegisterSignal(target_mob, COMSIG_PARENT_QDELETING, PROC_REF(swallowed_deleted))
	open_hatch("[base_icon_state]-opening_wires")
	to_chat(target_mob, "<span class='userdanger'>[capitalize(src.name)] oplata ci kończyny i wciąga cię do swojej komory. Metalowe wici zaciskają się wokół ciebie.</span>")
	visible_message("<span class='danger'>[capitalize(src.name)] połyka [target_mob]!</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 70, TRUE)
	log_combat(src, target_mob, "swallowed")
	release_timer = addtimer(CALLBACK(src, PROC_REF(release_mob)), FLESHMIND_MECHIVER_CONVERSION_TIME, TIMER_STOPPABLE)
	return TRUE

/mob/living/basic/fleshmind/mechiver/proc/open_hatch(flick_state)
	hatch_open = TRUE
	update_icon()
	flick(flick_state, src)
	if(hatch_timer)
		deltimer(hatch_timer)
	hatch_timer = addtimer(CALLBACK(src, PROC_REF(close_hatch)), 1 SECONDS, TIMER_STOPPABLE)

/mob/living/basic/fleshmind/mechiver/proc/close_hatch()
	hatch_timer = null
	hatch_open = FALSE
	update_icon()

/mob/living/basic/fleshmind/mechiver/proc/swallowed_deleted(datum/source)
	SIGNAL_HANDLER
	swallowed_mob = null

/mob/living/basic/fleshmind/mechiver/proc/torment_passenger()
	if(!swallowed_mob)
		return
	var/static/list/torment_lines = list(
		"Ramię chwyta cię za szyję, a setki manipulatorów próbują wsunąć ci pod skórę implanty!",
		"Radio w kokpicie trzeszczy: „Dobrze trafiłeś...”",
		"Mechaniczne sygnały zalewają ci umysł: „Wreszcie będziesz wśród ludzi, którym na tobie zależy...”",
		"Coś zimnego wsuwa się pod żebra i szuka sygnału aktywacji!",
		"Coś mocno naciska na twój kręgosłup!",
		"Oblewa cię jakiś gorący jak krew płyn!",
		"Tuzin igieł bez wysiłku wbija się w twoje mięśnie i wstrzykuje nieznaną energię!",
		"Czujesz zimny, robakowaty kształt, który próbuje wwiercić ci się pod skórę!",
	)
	swallowed_mob.adjustBruteLoss(rand(FLESHMIND_MECHIVER_TORMENT_LOWER, FLESHMIND_MECHIVER_TORMENT_UPPER))
	INVOKE_ASYNC(swallowed_mob, TYPE_PROC_REF(/mob, emote), "scream")
	do_sparks(4, FALSE, src)
	to_chat(swallowed_mob, "<span class='userdanger'>[pick(torment_lines)]</span>")
	playsound(src, 'sound/weapons/drill.ogg', 70, TRUE)

/// Koniec przemiany: martwe ciało przerabia na nowego moba roju (nosi je w sobie), żywą ofiarę wypluwa
/mob/living/basic/fleshmind/mechiver/proc/release_mob()
	release_timer = null
	var/mob/living/victim = swallowed_mob
	if(QDELETED(victim))
		swallowed_mob = null
		return
	open_hatch("[base_icon_state]-opening")
	playsound(src, 'sound/effects/blobattack.ogg', 70, TRUE)
	if(victim.stat == DEAD)
		var/new_type = iscyborg(victim) ? /mob/living/basic/fleshmind/hiborg : pick(/mob/living/basic/fleshmind/floater, /mob/living/basic/fleshmind/globber, /mob/living/basic/fleshmind/slicer, /mob/living/basic/fleshmind/stunner, /mob/living/basic/fleshmind/treader)
		var/mob/living/basic/fleshmind/new_mob = our_controller?.spawn_mob(get_turf(src), new_type)
		if(new_mob)
			UnregisterSignal(victim, COMSIG_PARENT_QDELETING)
			swallowed_mob = null
			new_mob.hold_body(victim)
			visible_message("<span class='danger'>[capitalize(src.name)] otwiera właz, a ze środka wypełza [new_mob]!</span>")
			log_combat(src, victim, "converted into [new_mob]")
			return
	spit_out()

/// Wypluwa połkniętą ofiarę
/mob/living/basic/fleshmind/mechiver/proc/spit_out()
	if(!swallowed_mob)
		return
	var/mob/living/victim = swallowed_mob
	UnregisterSignal(victim, COMSIG_PARENT_QDELETING)
	swallowed_mob = null
	if(QDELETED(victim))
		return
	victim.forceMove(drop_location() || get_turf(src))
	victim.visible_message("<span class='danger'>[capitalize(src.name)] wypluwa [victim]!</span>")
