// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/bear/ (_bear.dm, bear_ai_subtree.dm) from the last revision before
// behaviour trees (tg 926bf40c5a, decision D15), on the Bee AI core. Polish names and lines of our simple animal bears.
// Changes against tg:
// - no hive raiding (our beebox and honeycomb are botany types tg's AI does not know), no swabbing, no snowstorm/fence traits;
// - riding a player bear is not added (our riding component is the old one, used only for tamed mobs);
// - the butter bear regenerates in Life() like our simple animal (no regenerator component / consumable_mob element here)
//   and keeps our Cak-style crafting (CheckParts) and the slipping slap;
// - the arena bear of the Russian shuttle (shuttle/special.dm) and the starving xenoarch bear stay our subtypes;
// - bear armour from the combat bear works on basic bears; melee damage values as our simple animals (tg lowered them).
/mob/living/basic/bear
	name = "kosmiczny niedźwiedź"
	desc = "Nie musisz być szybszy od kosmicznego niedźwiedzia, wystarczy, że prześcigniesz kolegów z załogi."
	icon_state = "bear"
	icon_living = "bear"
	icon_dead = "bear_dead"
	icon_gib = "bear_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/bearpelt = 1)
	speak_emote = list("warczy", "ryczy")
	see_in_dark = 6

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "uderza"

	maxHealth = 60
	health = 60
	speed = 0
	spacewalk = TRUE

	obj_damage = 60
	melee_damage = 25
	sharpness = SHARP_EDGED
	attack_verb_continuous = "drapie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	friendly_verb_continuous = "miażdży w niedźwiedzim uścisku"
	chat_color = "#CAA25B"

	faction = list("russian")
	gold_core_spawnable = HOSTILE_SPAWN
	do_footstep = TRUE

	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	ai_controller = /datum/ai_controller/basic_controller/bear
	/// is the bear wearing a armor?
	var/armored = FALSE

/mob/living/basic/bear/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/tree_climber, climbing_distance = 15)
	if(armored)
		update_icon(UPDATE_OVERLAYS)

/mob/living/basic/bear/update_overlays()
	. = ..()
	if(armored)
		. += "armor_bear"

/// Puts the combat armour on the bear (bear armour item)
/mob/living/basic/bear/proc/put_on_armor()
	armored = TRUE
	maxHealth += 60
	health += 60
	armour_penetration += 20
	melee_damage += 5
	update_icon(UPDATE_OVERLAYS)

/datum/ai_controller/basic_controller/bear
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/random_speech/bear,
	)

/datum/ai_planning_subtree/random_speech/bear
	speech_chance = 1
	speak = list("RAWR!", "Rawr!", "GRR!", "Grrr!")
	emote_hear = list("ryczy.", "burczy.", "warczy.")
	emote_see = list("patrzy groźnie.", "tupie.")

//SPACE BEARS! SQUEEEEEEEE~     OW! FUCK! IT BIT MY HAND OFF!!
/mob/living/basic/bear/hudson
	name = "Hudson"
	gender = MALE
	desc = "Budzący postrach wyjęty spod prawa. Z tym misiem lepiej nie zadzierać." //I'm sorry...

/mob/living/basic/bear/snow
	name = "kosmiczny niedźwiedź polarny"
	icon_state = "snowbear"
	icon_living = "snowbear"
	icon_dead = "snowbear_dead"
	desc = "To niedźwiedź polarny w kosmosie, choć niezupełnie w kosmosie."
	weather_immunities = list("snow")

/mob/living/basic/bear/russian
	name = "bojowy niedźwiedź"
	desc = "Groźny niedźwiedź brunatny obwieszony płytami pancerza. Na naramiennikach widnieje czerwona gwiazda z żółtym obramowaniem."
	icon_state = "combatbear"
	icon_living = "combatbear"
	icon_dead = "combatbear_dead"
	faction = list("russian")
	butcher_results = list(/obj/item/food/meat/slab/bear = 5, /obj/item/clothing/head/bearpelt = 1, /obj/item/bear_armor = 1)
	melee_damage = 30
	armour_penetration = 20
	health = 120
	maxHealth = 120
	armored = TRUE

/obj/item/bear_armor
	name = "sterta pancerza dla niedźwiedzia"
	desc = "Rozrzucona sterta różnych kawałków pancerza dopasowanych do niedźwiedzia, trochę taśmy klejącej i pilnik do paznokci. Na odwrocie jednej z płyt \
		ktoś nabazgrał po rosyjsku prymitywną instrukcję. To chyba okropny pomysł."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bear_armor_upgrade"

/obj/item/bear_armor/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!istype(target, /mob/living/basic/bear) || !proximity_flag)
		return
	var/mob/living/basic/bear/bear = target
	if(bear.armored)
		to_chat(user, span_warning("[bear] ma już pancerz!"))
		return
	bear.put_on_armor()
	to_chat(user, span_info("Przypinasz [bear] płyty pancerza i ostrzysz mu pazury pilniczkiem do paznokci. To był świetny pomysł."))
	qdel(src)

/mob/living/basic/bear/butter //The mighty companion to Cak. Several functions used from it.
	name = "Terrygold"
	icon_state = "butterbear"
	icon_living = "butterbear"
	icon_dead = "butterbear_dead"
	desc = "Nie mogę uwierzyć, że to nie niedźwiedź!"
	faction = list(FACTION_NEUTRAL, "russian")
	obj_damage = 11
	melee_damage = 1
	melee_attack_cooldown = CLICK_CD_MELEE
	sharpness = NONE //it's made of butter
	armour_penetration = 0
	response_harm_continuous = "odgryza kawałek"
	attacked_sound = 'sound/items/eatfood.ogg'
	death_message = "traci swoje fałszywe życie i pada!"
	butcher_results = list(/obj/item/food/butter = 6, /obj/item/food/meat/slab = 3, /obj/item/organ/brain = 1, /obj/item/organ/heart = 1)
	attack_sound = 'sound/weapons/slap.ogg'
	attack_vis_effect = ATTACK_EFFECT_DISARM
	attack_verb_continuous = "policzkuje"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/bear/butter/Life(delta_time = SSMOBS_DT, times_fired) //Heals butter bear really fast when he takes damage.
	. = ..()
	if(stat)
		return
	if(health < maxHealth)
		heal_overall_damage(10, 10) //Fast life regen, makes it hard for you to get eaten to death.

/mob/living/basic/bear/butter/attack_hand(mob/living/user, list/modifiers) //Borrowed code from Cak, feeds people if they hit you. More nutriment but less vitamin to represent BUTTER.
	. = ..()
	if(user.combat_mode && user.reagents && !stat)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		user.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.1)

/mob/living/basic/bear/butter/CheckParts(list/parts_list, datum/crafting_recipe/R) //Borrowed code from Cak, allows the brain used to actually control the bear.
	..()
	var/obj/item/organ/brain/candidate = locate(/obj/item/organ/brain) in contents
	if(!candidate || !candidate.brainmob || !candidate.brainmob.mind)
		return
	candidate.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>Jesteś maślanym niedźwiedziem!</span><b> Jesteś w większości nieszkodliwą hybrydą niedźwiedzia i masła, którą wszyscy kochają. Głodni mogą odgryzać z ciebie kawałki, ale regenerujesz zdrowie tak szybko, że zwykle nie ma to znaczenia. Jesteś niezwykle odporny na wszelkie inne obrażenia i naprawdę trudno cię zabić. Chodź po stacji i rozdawaj szczęście oraz darmowe masło!</b>")
	INVOKE_ASYNC(src, PROC_REF(ask_for_name))

/mob/living/basic/bear/butter/proc/ask_for_name()
	var/new_name = stripped_input(src, "Podaj swoje imię lub naciśnij \"Cancel\", by zostać przy imieniu Terrygold.", "Zmiana imienia")
	if(new_name)
		to_chat(src, span_notice("Twoje imię to teraz <b>[new_name]</b>!"))
		fully_replace_character_name(null, new_name)

/mob/living/basic/bear/butter/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE) //Makes the butter bear's attacks slip those who dare cross its path.
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/victim = target
	if(!(victim.mobility_flags & MOBILITY_STAND))
		return
	victim.Knockdown(20)
	playsound(loc, 'sound/misc/slip.ogg', 15)
	victim.visible_message(span_danger("[victim] poślizguje się na maśle!"))
