// AQUILA - wślizgiwanie się pod drzwi (port z tgstation#93787)
// Mob klika drzwi prawym przyciskiem, po chwili siedzi pod nimi. Ruch w dowolną stronę go wypuszcza,
// a otwarcie drzwi wyrzuca go spod nich.

/datum/component/slide_under_doors
	can_transfer = TRUE
	/// Ile trwa wślizgiwanie się pod drzwi
	var/slide_in_delay = 0
	/// Ile trwa wyślizgiwanie się spod drzwi
	var/slide_out_delay = 0
	/// Drzwi, pod którymi siedzi mob
	var/obj/machinery/door/current_door = null
	/// Czy właśnie wychodzimy spod drzwi
	var/sliding_out = FALSE

/datum/component/slide_under_doors/Initialize(slide_in_delay = 5 SECONDS, slide_out_delay = 1 SECONDS)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.slide_in_delay = slide_in_delay
	src.slide_out_delay = slide_out_delay

/datum/component/slide_under_doors/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_user_unarmed_attack))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))

/datum/component/slide_under_doors/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_MOVABLE_MOVED))
	if(current_door && !QDELETED(parent))
		slide_out_from_under_door()
	else
		unregister_door()

/datum/component/slide_under_doors/Destroy(force, silent)
	unregister_door()
	return ..()

/datum/component/slide_under_doors/proc/on_user_unarmed_attack(mob/living/user, atom/target, proximity_flag, list/modifiers)
	SIGNAL_HANDLER
	if(!modifiers?[RIGHT_CLICK] || !istype(target, /obj/machinery/door))
		return
	INVOKE_ASYNC(src, PROC_REF(try_slide_under_door), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/slide_under_doors/proc/try_slide_under_door(mob/living/user, obj/machinery/door/door)
	if(!can_slide_under_door(user, door))
		return
	user.visible_message("<span class='danger'>[user] zaczyna wślizgiwać się pod [door]!</span>", \
		"<span class='notice'>Zaczynasz wślizgiwać się pod [door].</span>", "<span class='italics'>Słyszysz przeciskanie się.</span>")
	playsound(user, 'sound/effects/gib_step.ogg', 50, TRUE)
	if(!do_after(user, slide_in_delay, FALSE, door, TRUE, CALLBACK(src, PROC_REF(can_slide_under_door), user, door)))
		return
	slide_under_door(user, door)

/datum/component/slide_under_doors/proc/can_slide_under_door(mob/living/user, obj/machinery/door/door)
	if(QDELETED(door) || !user.Adjacent(door) || user.loc == door)
		return FALSE
	if(!isturf(user.loc))
		user.balloon_alert(user, "nie na podłodze!")
		return FALSE
	if(user.incapacitated())
		user.balloon_alert(user, "nie możesz!")
		return FALSE
	if(!(door.pass_flags_self & PASSDOORS))
		door.balloon_alert(user, "nie ma szpary!")
		return FALSE
	if(!door.density)
		door.balloon_alert(user, "już otwarte!")
		return FALSE
	return TRUE

/datum/component/slide_under_doors/proc/slide_under_door(mob/living/user, obj/machinery/door/door)
	user.visible_message("<span class='danger'>[user] z mlaśnięciem wślizguje się pod [door]!</span>", \
		"<span class='notice'>Z mlaśnięciem wślizgujesz się pod [door]!</span>", "<span class='italics'>Słyszysz mlaśnięcie.</span>")
	playsound(user, 'aquila/sound/blood_worm/meatslap.ogg', 50, TRUE)
	user.forceMove(door)
	current_door = door
	RegisterSignal(door, COMSIG_PARENT_QDELETING, PROC_REF(on_door_qdeleting))
	RegisterSignal(door, COMSIG_AIRLOCK_OPEN, PROC_REF(on_door_opened))
	addtimer(CALLBACK(src, PROC_REF(check_door)), 0.5 SECONDS)

/// Nie każde drzwi wysyłają sygnał otwarcia, więc co chwilę sprawdzamy
/datum/component/slide_under_doors/proc/check_door()
	if(!current_door)
		return
	if(!current_door.density)
		slide_out_from_under_door()
		return
	addtimer(CALLBACK(src, PROC_REF(check_door)), 0.5 SECONDS)

/// Ruch spod drzwi (wywoływane przez relaymove drzwi)
/datum/component/slide_under_doors/proc/try_slide_out_from_under_door(move_dir)
	var/mob/living/user = parent
	if(sliding_out || !current_door || user.loc != current_door)
		return
	sliding_out = TRUE
	var/turf/visible_turf = get_step(current_door, move_dir)
	visible_turf?.visible_message("<span class='danger'>Coś zaczyna wyślizgiwać się spod [current_door]!</span>", \
		blind_message = "<span class='italics'>Słyszysz przeciskanie się.</span>", ignored_mobs = list(user))
	if(visible_turf)
		playsound(visible_turf, 'sound/effects/gib_step.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Zaczynasz wyślizgiwać się spod [current_door].</span>")
	var/success = blood_worm_do_after(user, slide_out_delay, current_door, CALLBACK(src, PROC_REF(still_under_door), user))
	sliding_out = FALSE
	if(success && still_under_door(user))
		slide_out_from_under_door(move_dir)

/datum/component/slide_under_doors/proc/still_under_door(mob/living/user)
	return current_door && user.loc == current_door

/datum/component/slide_under_doors/proc/slide_out_from_under_door(move_dir)
	var/mob/living/user = parent
	var/obj/machinery/door/door = current_door
	unregister_door()
	if(!door || user.loc != door)
		return
	user.forceMove(door.drop_location())
	if(move_dir)
		var/turf/next = get_step(user, move_dir)
		if(next)
			user.Move(next, move_dir)
	user.visible_message("<span class='danger'>[user] z mlaśnięciem wyślizguje się spod [door]!</span>", \
		"<span class='notice'>Z mlaśnięciem wyślizgujesz się spod [door]!</span>", "<span class='italics'>Słyszysz mlaśnięcie.</span>")
	playsound(user, 'aquila/sound/blood_worm/meatslap.ogg', 50, TRUE)

/datum/component/slide_under_doors/proc/unregister_door()
	if(current_door)
		UnregisterSignal(current_door, list(COMSIG_PARENT_QDELETING, COMSIG_AIRLOCK_OPEN))
	current_door = null

/datum/component/slide_under_doors/proc/on_user_moved(mob/living/user, atom/old_loc)
	SIGNAL_HANDLER
	if(current_door && user.loc != current_door)
		unregister_door()

/datum/component/slide_under_doors/proc/on_door_qdeleting(obj/machinery/door/door)
	SIGNAL_HANDLER
	var/mob/living/user = parent
	unregister_door()
	if(user.loc == door)
		user.forceMove(door.drop_location())

/datum/component/slide_under_doors/proc/on_door_opened(obj/machinery/door/door)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(slide_out_from_under_door))

// Mob pod drzwiami rusza się, żeby spod nich wyjść
/obj/machinery/door/relaymove(mob/living/user, direction)
	var/datum/component/slide_under_doors/sliding = user?.GetComponent(/datum/component/slide_under_doors)
	if(sliding?.current_door == src)
		INVOKE_ASYNC(sliding, TYPE_PROC_REF(/datum/component/slide_under_doors, try_slide_out_from_under_door), direction)
		return
	return ..()
