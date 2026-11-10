// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/dog/_dog.dm (bee/master 0adf0fe9ae)
// Polish lines from our simple animal dogs and their old AI. No pet cult (decision D10), no jumbo dog bone.

// Dog versions of the pet commands: more Polish (and Bee's English and German) words
/datum/pet_command/follow/dog
	speech_commands = list("do nogi", "za mną", "za mna", "chodź", "chodz", "na spacer", "heel", "follow", "walkies", "come", "komm", "fuss")

/datum/pet_command/good_boy/dog
	speech_commands = list("dobry pies", "dobry piesek", "grzeczny piesek", "dobra suczka", "good dog", "good boy", "brav")

// Set correct attack behaviour
/datum/pet_command/attack/dog
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/dog
	speech_commands = list("atakuj", "bierz go", "bierz ją", "zagryź", "attack", "sic", "kill", "fass")

/datum/pet_command/attack/dog/set_command_active(mob/living/parent, mob/living/commander)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_DOG_HARASS_HARM, TRUE)

/datum/pet_command/fetch/dog
	speech_commands = list("aport", "przynieś", "przynies", "fetch", "apport", "bring")

/datum/pet_command/play_dead/dog
	speech_commands = list("udawaj trupa", "padnij", "play dead", "tot stellen")

/mob/living/basic/pet/dog
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "pstryka"
	response_harm_continuous = "kopie"
	speak_emote = list("szczeka", "hauka")
	faction = list(FACTION_NEUTRAL)
	see_in_dark = 5
	can_be_held = TRUE
	chat_color = "#ECDA88"
	mobchatspan = "corgi"
	speech_sound = "dog"
	ai_controller = /datum/ai_controller/basic_controller/dog
	// The dog attack pet command can raise melee attack above 0
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	/// Instructions you can give to dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/move,
		/datum/pet_command/good_boy/dog,
		/datum/pet_command/follow/dog,
		/datum/pet_command/attack/dog,
		/datum/pet_command/fetch/dog,
		/datum/pet_command/play_dead/dog,
	)
	///icon state of the collar we can wear
	var/collar_icon_state

/mob/living/basic/pet/dog/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state)
	AddElement(/datum/element/pet_bonus, "radośnie ujada!")
	AddElement(/datum/element/unfriend_attacker, untamed_reaction = "%SOURCE% patrzy na %TARGET% z wyrzutem.")
	var/static/list/food_types = list(
		/obj/item/food/meat/slab/human/mutant/skeleton,
		/obj/item/stack/sheet/bone,
	)
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 30, bonus_tame_chance = 15, unique = FALSE)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(D.update_owner(src)) //No muscling in on my turf you fucking parrot
			break

/// Lines the dog speech subtree says for this dog (Bee: speech lives in the AI, not on the mob)
/mob/living/basic/pet/dog/proc/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("YAP", "Hau!", "Hau hau!", "AUUUUUU"))
	speech.emote_hear = string_list(list("szczeka!", "hauka!", "ujada.", "dyszy."))
	speech.emote_see = string_list(list("potrząsa głową.", "goni swój ogon.", "drży."))

///Proc to run on a successful taming attempt
/mob/living/basic/pet/dog/tamed(mob/living/tamer, atom/food)
	visible_message(span_notice("[src] przyjaźnie liże [tamer]!")) // Line of our old dog AI

/datum/ai_planning_subtree/random_speech/dog
	speech_chance = 1
	sound = list('aquila/sound/misc/bark.ogg') // AQUILA: the bark our simple animal dogs played

/datum/ai_planning_subtree/random_speech/dog/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!isdog(controller.pawn))
		return

	// Stay in sync with dog fashion.
	var/mob/living/basic/pet/dog/dog_pawn = controller.pawn
	dog_pawn.update_dog_speech(src)

	return ..()

/// W Bee przez sygnał z kontrolera AI psa; u nas bezpośrednio (screentipy)
/mob/living/basic/pet/dog/add_context_self(datum/screentip_context/context, mob/user)
	if (!isnull(context.held_item) || !ishuman(user))
		return
	context.add_left_click_action(user.combat_mode ? "Uderz" : "Pogłaszcz")
