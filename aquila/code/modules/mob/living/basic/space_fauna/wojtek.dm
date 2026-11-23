// AQUILA - niedźwiedź Wojtek, port z NovaSector/NovaSector (modular_nova/modules/mapping/voidraptor)
// Niedźwiedź z 22. Kompanii Zaopatrywania Artylerii II Korpusu Polskiego, który nosił skrzynie z pociskami.
// Spokojny, dopóki nikt go nie skrzywdzi; lubi piwo i papierosy, tak jak oryginał.
// Basic mob (mobabilities cz. 2): podtyp tg-niedźwiedzia. Odwet robi element ai_retaliate i poddrzewo target_retaliate,
// które pomija frakcję, więc oddaje też komuś z załogi; ręczne zapamiętywanie napastnika z simple_animala zniknęło.

/mob/living/basic/bear/wojtek
	name = "Wojtek"
	real_name = "Wojtek"
	desc = "Kapral Wojtek, weteran kompanii zaopatrzenia artylerii. Nosi pociski do dział bluespace i nigdy nie odmówi piwa ani papierosa."
	gender = MALE
	speak_emote = list("mruczy", "pomrukuje")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odpycha"
	response_harm_continuous = "uderza"
	maxHealth = 120
	health = 120
	speed = 1
	spacewalk = FALSE
	friendly_verb_continuous = "przytula po niedźwiedziemu"
	faction = list("neutral")
	death_sound = 'aquila/sound/creatures/wojtusiu.ogg'
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/bear/wojtek

/// Oddaje tylko temu, kto go skrzywdził: bez szukania ofiar, jak dawny retaliate
/datum/ai_controller/basic_controller/bear/wojtek
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/random_speech/wojtek,
	)

/datum/ai_planning_subtree/random_speech/wojtek
	speech_chance = 1
	speak = list("Mrrr...", "Rawr!", "Grrrm.")
	emote_hear = list("mruczy.", "sapie.", "drapie się po brzuchu.")
	emote_see = list("salutuje łapą.", "przeciąga się.", "rozgląda się za piwem.")

/mob/living/basic/bear/wojtek/attackby(obj/item/I, mob/living/user, params)
	if(stat != CONSCIOUS || user.combat_mode)
		return ..()
	if(istype(I, /obj/item/clothing/mask/cigarette))
		visible_message("<span class='notice'>[src] bierze [I] od [user] i ze smakiem go zjada, jak na weterana przystało.</span>")
		qdel(I)
		adjustBruteLoss(-10)
		return
	if(istype(I, /obj/item/reagent_containers) && I.reagents?.has_reagent(/datum/reagent/consumable/ethanol/beer))
		visible_message("<span class='notice'>[src] wyrywa [I] z rąk [user] i wypija wszystko duszkiem.</span>")
		I.reagents.clear_reagents()
		adjustBruteLoss(-20)
		playsound(src, 'sound/items/drink.ogg', 50, TRUE)
		return
	return ..()
