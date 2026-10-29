/**
 * # Spider Charge
 *
 * A unique version of c4 possessed only by the space ninja. Has a stronger blast radius.
 * Can only be detonated by space ninjas with the bombing objective. Can only be set up where the objective says it can.
 * When it primes, the space ninja responsible will have their objective set to complete.
 *
 */
/obj/item/grenade/plastic/ninja
	name = "ładunek pajęczy"
	desc = "Zmodyfikowany ładunek C-4 od Klanu Pająka. Ma ogromną siłę wybuchu, ale działa tylko w jednym, określonym miejscu."
	icon_state = "ninja-explosive0"
	item_state = "ninja-explosive"
	boom_sizes = list(4, 8, 12)
	///Weakref to the mob that has planted the charge
	var/datum/weakref/detonator
	///The only area that the charge is allowed to be planted, and detonated in (defaulting to space)
	var/area/detonation_area = /area/space/nearstation

/obj/item/grenade/plastic/ninja/Destroy()
	detonator = null
	detonation_area = null
	return ..()

/obj/item/grenade/plastic/ninja/examine(mob/user)
	. = ..()
	if (!IS_SPACE_NINJA(user))
		return
	if (isnull(detonation_area))
		. += span_notice("Ten egzemplarz nie ma ustawionego celu i nie da się go użyć.")
	else
		. += span_notice("To urządzenie zadziała tylko w miejscu: [detonation_area].")

/obj/item/grenade/plastic/ninja/afterattack(atom/movable/target, mob/ninja, flag)
	if(!IS_SPACE_NINJA(ninja))
		say("Odmowa dostępu.")
		return
	if (!check_loc(ninja))
		return
	detonator = WEAKREF(ninja)
	return ..()

/obj/item/grenade/plastic/ninja/prime(mob/living/lanced_by)
	if(!check_loc(detonator.resolve())) // if its moved, deactivate the c4
		var/obj/item/grenade/plastic/ninja/new_c4 = new /obj/item/grenade/plastic/ninja(target.loc)
		new_c4.detonation_area = detonation_area
		new_c4.say("Nieprawidłowe miejsce!")
		target.cut_overlay(plastic_overlay, TRUE)
		qdel(src)
		return
	//Since we already did the checks in afterattack, the detonator must be a ninja with the bomb objective.
	if(isnull(detonator))
		return
	var/mob/ninja = detonator.resolve()
	. = ..()
	if(!.)
		return
	if (isnull(ninja))
		return

/**
 * check_loc
 *
 * Checks to see if the c4 is in the correct place when being planted.
 *
 * Arguments
 * * mob/user - The planter of the c4
 */
/obj/item/grenade/plastic/ninja/proc/check_loc(mob/user)
	if(isnull(detonation_area))
		balloon_alert(user, "brak ustawionego miejsca!")
		return FALSE
	if((get_area(target) != detonation_area) && (get_area(src) != detonation_area))
		if (!active)
			balloon_alert(user, "złe miejsce!")
		return FALSE
	return TRUE
