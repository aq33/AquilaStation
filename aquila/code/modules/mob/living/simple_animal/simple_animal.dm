// AQUILA - zwierzęta, które duch może przejąć (attack_ghost -> give_to_ghost) i milczące zwierzęta.
// Na /mob/living, żeby działało i dla simple animali, i dla basic mobów (decyzja D14 portu basic mobów).
/mob/living
	var/should_talk = TRUE //Should it be able to talk?

/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	if(!should_talk)
		return
	return ..()

/mob/living/proc/find_candidates()
	if(!mind && level == 2)
		notify_ghosts("Można sterować: [src]", null, enter_link="<a href=byond://?src=[REF(src)];activate=1>(Kliknij, by zagrać)</a>", source=src, action=NOTIFY_ATTACK, ignore_key = POLL_IGNORE_SPIDER)

/mob/living/proc/give_to_ghost(mob/dead/observer/user, bypass_level = FALSE)
	if(QDELETED(src) || QDELETED(user) || !src.playable || level != 2)
		if(!bypass_level)
			return
	if(!SSticker.mode)
		to_chat(user, "Nie możesz zostać [src] przed rozpoczęciem gry.")
		return
	var/be_mob = alert("Zostać [src]? (Uwaga: nie będzie można cię sklonować!)",,"Tak","Nie")
	if(be_mob == "Nie" || QDELETED(src) || !isobserver(user) || src.mind)
		return

	src.should_talk = FALSE
	src.playable = FALSE
	src.key = user.key
	on_ghost_possession() // prevent weirdness such as AI still doing its thing

	message_admins("[ADMIN_LOOKUPFLW(user)] przejmuje: [src] w [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")

/// Duch właśnie przejął moba: wyłączamy jego własną SI
/mob/living/proc/on_ghost_possession()
	ai_controller?.set_ai_status(AI_STATUS_OFF)

/mob/living/simple_animal/on_ghost_possession()
	. = ..()
	sentience_act()
	stop_automated_movement = TRUE // bo sie borowik rusza

/mob/living/basic/on_ghost_possession()
	. = ..()
	sentience_act()
