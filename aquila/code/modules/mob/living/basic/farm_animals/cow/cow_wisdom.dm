// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/cow/cow_wisdom.dm (decision D11:
// only with Polish wisdoms, strings/wisdoms.txt translated line by line from Bee's file, English originals in the i18n dictionary).
// Changes against Bee: we have no skills, so petting gives only the whisper; our cow is tipped with the right mouse button (disarm
// intent in the old controls), which still works on the wisdom cow; no tip reaction subtree (our cow has none either).

GLOBAL_LIST_INIT(wisdoms, world.file2list("strings/wisdoms.txt") - "")

///Wisdom cow, speaks wisdoms
/mob/living/basic/cow/wisdom
	name = "krowa mądrości"
	desc = "Słynie z mądrości, którą dzieli się ze wszystkimi."
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/cow/wisdom

/mob/living/basic/cow/wisdom/setup_eating()
	return //cannot tame me! and I don't care about eatin' nothing, neither!

/datum/ai_controller/basic_controller/cow/wisdom
	//don't give a targeting datum
	blackboard = list()

	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cow/wisdom,
	)

///unlike normal cows, wisdom cows speak of wisdom and won't shut the fuck up
// AQUILA: 3% per second (about every 30 s) instead of Bee's 15% (every ~7 s), so the cow does not flood the chat
/datum/ai_planning_subtree/random_speech/cow/wisdom
	speech_chance = 3
	emote_hear = null
	emote_see = null

/datum/ai_planning_subtree/random_speech/cow/wisdom/New()
	speak = GLOB.wisdoms //Done here so it's setup properly
	return ..()

///Give intense wisdom to the attacker if they're being friendly about it
/mob/living/basic/cow/wisdom/attack_hand(mob/living/carbon/user, list/modifiers)
	if(!stat && !user.combat_mode && !LAZYACCESS(modifiers, RIGHT_CLICK))
		to_chat(user, span_nicegreen("[src] szepcze ci kilka głębokich mądrości i znika!"))
		do_smoke(1, location = get_turf(src))
		qdel(src)
		return TRUE
	return ..()
