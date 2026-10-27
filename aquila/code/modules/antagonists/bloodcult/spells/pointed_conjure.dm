/datum/action/cooldown/spell/pointed/conjure
	sound = 'sound/items/welder.ogg'
	school = SCHOOL_CONJURATION

	/// A list of types that will be created on summon.
	/// The type is picked from this list, not all provided are guaranteed.
	var/list/summon_type = list()
	/// How long before the summons will be despawned. Set to 0 for permanent.
	var/summon_lifespan = 0
	/// Amount of summons to create.
	var/summon_amount = 1
	/// If TRUE, summoned objects will not be spawned in dense turfs.
	var/summon_respects_density = FALSE
	/// If TRUE, no two summons can be spawned in the same turf.
	var/summon_respects_prev_spawn_points = TRUE

	var/cast_duration = 0
	var/cast_delay = 0

/datum/action/cooldown/spell/pointed/conjure/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/conjure/cast(atom/cast_on)
	. = ..()
	if(cast_delay && !do_after(owner, cast_delay, target = owner))
		return

	for(var/i in 1 to summon_amount)
		var/atom/summoned_object_type = pick(summon_type)
		var/turf/spawn_place = get_turf(cast_on)

		if(ispath(summoned_object_type, /turf))
			// AQUILA - u nas nie ma overfloor_placed ani replace_floor, zostaje ChangeTurf/PlaceOnTop
			if(isclosedturf(spawn_place) || !ispath(summoned_object_type, /turf/closed))
				spawn_place.ChangeTurf(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
			else
				spawn_place.PlaceOnTop(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
			return

		addtimer(CALLBACK(src, PROC_REF(summon_object), summoned_object_type, spawn_place, cast_on), max(cast_duration, 0))

		var/obj/effect/abstract/animation = new /obj/effect/abstract(spawn_place)
		animation.name = "conjure"
		animation.density = FALSE
		animation.anchored = 1
		animation.icon = 'aquila/icons/bloodcult/effects.dmi'

		conjure_animation(animation, spawn_place)

/// Tworzy przywołaną rzecz (w drafcie spawn(cast_duration))
/datum/action/cooldown/spell/pointed/conjure/proc/summon_object(summoned_object_type, turf/spawn_place, atom/cast_on)
	var/atom/summoned_object = new summoned_object_type(spawn_place)

	summoned_object.flags_1 |= ADMIN_SPAWNED_1
	if(summon_lifespan > 0)
		QDEL_IN(summoned_object, summon_lifespan)

	post_summon(summoned_object, cast_on)

/// Called on atoms summoned after they are created, allows extra variable editing and such of created objects
/datum/action/cooldown/spell/pointed/conjure/proc/post_summon(atom/summoned_object, atom/cast_on)
	return

/datum/action/cooldown/spell/pointed/conjure/proc/conjure_animation(obj/effect/abstract/animation, turf/target)
	QDEL_NULL(animation)
