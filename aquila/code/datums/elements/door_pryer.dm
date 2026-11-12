// AQUILA: port of tgstation/tgstation code/datums/elements/door_pryer.dm (tg 926bf40c5a)
// Our airlocks open with open(forced) (0 normal, 1 without power, 2 past the emag lock) instead of tg's door check
// defines, and have no `seal`. The AI hits obstacles with melee_attack() directly, so like in tg it smashes doors;
// prying is for a player-controlled mob outside combat mode (on the help intent in the old controls).
/// Damage dealt to an airlock forced open by a mob
#define AIRLOCK_PRY_DAMAGE 35

/**
 * Attached to a basic mob.
 * Causes attacks on doors to attempt to open them.
 */
/datum/element/door_pryer
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Time it takes to open a door with force
	var/pry_time

/datum/element/door_pryer/Attach(datum/target, pry_time = 10 SECONDS)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.pry_time = pry_time
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack))

/datum/element/door_pryer/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)

/// If we're targeting an airlock, open it
/datum/element/door_pryer/proc/on_attack(mob/living/basic/attacker, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if(!proximity_flag || !istype(target, /obj/machinery/door/airlock))
		return NONE
	var/obj/machinery/door/airlock/airlock_target = target
	if (!airlock_target.density)
		return NONE // It's already open numbnuts

	if(target in attacker.do_afters) // AQUILA: our do_afters list holds targets, no interaction keys
		attacker.balloon_alert(attacker, "zajęty!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (attacker.combat_mode)
		return NONE // Attack the door

	if (airlock_target.locked || airlock_target.welded)
		airlock_target.balloon_alert(attacker, "jest zablokowana!")
		attacker.log_message("Tried to pry open [airlock_target], located at [loc_name(airlock_target)], but failed due to the airlock being sealed.", LOG_GAME)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(open_door), attacker, airlock_target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Try opening the door, and if we can't then try forcing it
/datum/element/door_pryer/proc/open_door(mob/living/basic/attacker, obj/machinery/door/airlock/airlock_target)
	if (!airlock_target.hasPower())
		attacker.visible_message(span_warning("[attacker] siłą otwiera [airlock_target]."))
		attacker.log_message("Pried open [airlock_target], located at [loc_name(airlock_target)].", LOG_GAME)
		airlock_target.open(1)
		return

	if (airlock_target.allowed(attacker))
		airlock_target.open()
		return

	attacker.visible_message(\
		message = span_warning("[attacker] zaczyna wyważać [airlock_target]!"),
		blind_message = span_hear("Słyszysz zgrzyt metalu."),
	)
	attacker.log_message("Started prying open [airlock_target], located at [loc_name(airlock_target)].", LOG_GAME)

	playsound(airlock_target, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
	airlock_target.balloon_alert(attacker, "wyważanie...")
	if(!do_after(attacker, pry_time, target = airlock_target))
		airlock_target.balloon_alert(attacker, "przerwano!")
		attacker.log_message("Tried and failed to pry open [airlock_target], located at [loc_name(airlock_target)], due to getting interrupted.", LOG_GAME)
		return
	if(airlock_target.locked)
		attacker.log_message("Tried and failed to pry open [airlock_target], located at [loc_name(airlock_target)], due to the airlock getting bolted during the do_after.", LOG_GAME)
		return
	attacker.visible_message(span_warning("[attacker] siłą otwiera [airlock_target]."))
	attacker.log_message("Successfully pried open [airlock_target], located at [loc_name(airlock_target)].", LOG_GAME)
	airlock_target.open(2)
	airlock_target.take_damage(AIRLOCK_PRY_DAMAGE, BRUTE, sound_effect = FALSE)

#undef AIRLOCK_PRY_DAMAGE
