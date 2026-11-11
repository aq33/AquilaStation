// AQUILA: taming synced with BeeStation/BeeStation-Hornet code/game/objects/items/carp_lasso.dm (bee/master 0adf0fe9ae),
// see "AI core sync" in aquila/LEGACY_OVERRIDES.md. A tamed mob gets the dog AI and pet commands (obeys_commands) instead of
// our old tamed AI and its radial. Our names, unlimited uses and riding component (riding/tamed) stay; the space lasso whitelist
// is Bee's (root paths only: no magicarp, chaos carp, Cayenne, holocarp, moonicorn or wisdom cow).
/obj/item/mob_lasso
	name = "kosmiczne lasso"
	desc = "Standardowe wyposażenie każdego kosmicznego kowboja.\nPozwala oswajać kosmiczne karpie."
	icon = 'icons/obj/carp_lasso.dmi'
	icon_state = "lasso"
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/mob_target
	///Range we can lasso things at
	var/range = 9
	///Whitelist of allowed animals
	var/list/whitelist_mobs
	///blacklist of disallowed animals
	var/list/blacklist_mobs
	///Typecache caches
	var/static/list/whitelist_mob_cache = list()
	var/static/list/blacklist_mob_cache = list()
	/// Instructions you can give to tamed targets - stolen from dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
	)

/obj/item/mob_lasso/Initialize(mapload)
	. = ..()
	if(!whitelist_mob_cache[type] && !blacklist_mob_cache[type])
		init_whitelists()
	whitelist_mobs = whitelist_mob_cache[type]
	blacklist_mobs = blacklist_mob_cache[type]

/obj/item/mob_lasso/proc/init_whitelists()
	whitelist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/carp/megacarp,
		/mob/living/simple_animal/hostile/carp/lia,
		/mob/living/basic/cow, // AQ EDIT - basic moby
		/mob/living/simple_animal/hostile/retaliate/dolphin,
	), only_root_path = TRUE)

/obj/item/mob_lasso/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target) || iscarbon(target) || issilicon(target) || !check_allowed(target))
		if(ismob(target))
			to_chat(user, span_notice("[target] wydaje się trochę za duży..."))
		return
	if(!(locate(target) in oview(range, get_turf(src))))
		return
	var/mob/living/C = target
	if(IS_DEAD_OR_INCAP(C))
		to_chat(user, span_warning("[target] nie żyje."))
		return
	if(!user.combat_mode && C == mob_target) //if trying to tie up previous target
		to_chat(user, span_notice("Zaczynasz rozwiązywać [C]"))
		if(proximity_flag && do_after(user, 2 SECONDS, FALSE, target))
			tame_target(C, user)
		return
	else if(timer) //if trying to add new target while old target is still flipped
		to_chat(user, span_warning("Nie możesz teraz tego zrobić!"))
		return
	//Do lasso/beam for style points
	user.Beam(C, icon_state = "carp_lasso", icon = 'icons/effects/beam.dmi', time = 1 SECONDS)
	C.unbuckle_all_mobs()
	mob_target = C
	C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
	C.transform = C.transform.Turn(180)
	set_target_ai(C, FALSE)
	RegisterSignal(C, COMSIG_PARENT_QDELETING, PROC_REF(handle_hard_del), override = TRUE)
	to_chat(user, span_notice("Łapiesz [C] na lasso!"))
	timer = addtimer(CALLBACK(src, PROC_REF(fail_ally)), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back

/// Bee: the tamed mob acts like a dog and takes pet commands (Alt+click or speech) from its friends
/obj/item/mob_lasso/proc/tame_target(mob/living/C, mob/living/user)
	C.transform = C.transform.Turn(-180)
	set_target_ai(C, TRUE, tamed = TRUE)
	//Riding and Tamed
	C.tamed(user)
	C.setup_tamed_riding() // our riding/tamed component with the old offsets
	if(C.ai_controller)
		QDEL_NULL(C.ai_controller)
	C.ai_controller = new /datum/ai_controller/basic_controller/dog(C) //This should be fine, we want them to act like dogs anyway
	C.AddComponent(/datum/component/obeys_commands, pet_commands)
	// AQUILA: a mob tamed again is already a friend (faction), so befriend() stops early and the new controller had no friends
	if(!C.befriend(user))
		C.ai_controller.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, user)
	//Faction - overwrites the faction code from befriend()
	user.faction |= "carpboy_[user]"
	C.faction = list(FACTION_NEUTRAL) //So the mob doesn't go back to mauling everyone
	C.faction |= "carpboy_[user]"
	C.faction |= user.faction
	C.faction |= REF(user) // AQUILA: keep the befriend() faction, unfriend() looks for it
	//Housekeeping
	to_chat(user, span_notice("[C] łasi się do ciebie."))
	UnregisterSignal(C, COMSIG_PARENT_QDELETING)
	mob_target = null
	if(timer)
		deltimer(timer)
		timer = null

/// Lassoed mobs stop thinking until they are tamed or break free
/obj/item/mob_lasso/proc/set_target_ai(mob/living/C, on, tamed = FALSE)
	if(isanimal(C))
		var/mob/living/simple_animal/simple_target = C
		// AQUILA: a tamed simple animal is driven by the dog controller only; its own wandering and hunting stay off for good
		if(tamed)
			simple_target.toggle_ai(AI_OFF)
			simple_target.can_have_ai = FALSE
		else
			simple_target.toggle_ai(on ? AI_ON : AI_OFF)
	if(on)
		REMOVE_TRAIT(C, TRAIT_AI_PAUSED, REF(src))
	else
		ADD_TRAIT(C, TRAIT_AI_PAUSED, REF(src))

/obj/item/mob_lasso/proc/check_allowed(atom/target)
	return ((!whitelist_mobs || is_type_in_typecache(target, whitelist_mobs)) && (!blacklist_mobs || !is_type_in_typecache(target, blacklist_mobs)))

/obj/item/mob_lasso/proc/fail_ally()
	if(!mob_target)
		return
	visible_message(span_warning("[mob_target] się uwalnia!"))
	mob_target.transform = mob_target.transform.Turn(-180)
	set_target_ai(mob_target, TRUE)
	UnregisterSignal(mob_target, COMSIG_PARENT_QDELETING)
	mob_target = null
	timer = null

/obj/item/mob_lasso/proc/handle_hard_del()
	SIGNAL_HANDLER
	mob_target = null
	deltimer(timer) // AQUILA: the old timer freed the next lassoed mob early
	timer = null

///Primal version, allows lavaland goobers to tame goliaths
/obj/item/mob_lasso/primal
	name = "pierwotne lasso"
	desc = "Spotykane wśród narzędzi popielnych wędrowców.\nPozwala oswajać goliaty."

/obj/item/mob_lasso/primal/init_whitelists()
	whitelist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/asteroid/goldgrub,
	))

/obj/item/mob_lasso/antag
	name = "lasso bluespace"
	desc = "Standardowe wyposażenie każdego złego kosmicznego kowboja!\nPozwala oswoić niemal wszystko."

/obj/item/mob_lasso/antag/init_whitelists()
	blacklist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/syndicate,
		/mob/living/basic/trooper/syndicate, // AQ EDIT - basic moby
	))

/obj/item/mob_lasso/antag/debug
	name = "lasso debugowe"
	desc = "Standardowe wyposażenie każdego kosmicznego kowboja-administratora!\nPozwala oswoić wszystko."

/obj/item/mob_lasso/antag/debug/init_whitelists()
	blacklist_mob_cache[type] = list() // An empty list so we know this got initialized
