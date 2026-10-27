/// Proteon - a very weak construct that only appears in NPC form in various ruins.
/mob/living/simple_animal/hostile/construct/proteon
	name = "Proteon"
	real_name = "Proteon"
	desc = "Słabszy konstrukt, stworzony do przeszukiwania ruin w poszukiwaniu przedmiotów miłych Nar'Sie. Z tymi zadziorami lepiej nie żartować."
	icon = 'aquila/icons/bloodcult/monke/mob/nonhuman-player/cult.dmi'
	icon_state = "proteon"
	icon_living = "proteon"
	maxHealth = 35
	health = 35
	melee_damage = 9
	attacktext = "szczypie"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch2.ogg'
	playstyle_string = "<b>Jesteś Proteonem. W walce ustępujesz większości bojowych konstruktów, ale wciąż jesteś szybki i zwinny. Noś metal i zapasy i współpracuj z innymi kultystami.</b>"

/mob/living/simple_animal/hostile/construct/proteon/Initialize(mapload)
	. = ..()
	add_overlay("glow_[icon_state]_cult")

/// Hostile NPC version. Atakuje i ucieka po trafieniu, po chwili wraca do walki (w drafcie ai_retaliate_advanced).
/mob/living/simple_animal/hostile/construct/proteon/hostile
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES

/mob/living/simple_animal/hostile/construct/proteon/hostile/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount <= 0 || stat == DEAD || client)
		return
	ai_retaliate_behaviour()

/// Po trafieniu ucieka na chwilę, potem czyści ucieczkę (losowy czas dla nieprzewidywalności)
/mob/living/simple_animal/hostile/construct/proteon/hostile/proc/ai_retaliate_behaviour()
	retreat_distance = 4
	minimum_distance = 4
	var/random_timer = rand(2 SECONDS, 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(clear_retaliate_list)), random_timer, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/hostile/construct/proteon/hostile/proc/clear_retaliate_list()
	retreat_distance = initial(retreat_distance)
	minimum_distance = initial(minimum_distance)
