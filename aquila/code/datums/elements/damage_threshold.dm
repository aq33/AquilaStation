// AQUILA: port of tgstation code/datums/elements/damage_threshold.dm (tg 926bf40c5a), smallest version: our core sends
// COMSIG_LIVING_CHECK_BLOCK only for humans, so the element stops weak weapon hits before the attack (COMSIG_PARENT_ATTACKBY)
// and weak animal and basic mob hits through the basic mob's force_threshold (attack_threshold_check()).
/// Applied to living mobs.
/// Adds a force threshold for which attacks will be blocked entirely.
/// IE, if they are hit with an attack that deals less than X damage, the attack does nothing.
/datum/element/damage_threshold
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Incoming attacks beneath this threshold, inclusive, will be blocked entirely
	var/force_threshold = -1

/datum/element/damage_threshold/Attach(datum/target, threshold)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!isnum(threshold) || threshold <= 0)
		return ELEMENT_INCOMPATIBLE
	force_threshold = threshold
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(check_block))
	if(isbasicmob(target))
		var/mob/living/basic/basic_target = target
		basic_target.force_threshold = max(basic_target.force_threshold, threshold)

/datum/element/damage_threshold/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_PARENT_ATTACKBY)
	if(isbasicmob(source))
		var/mob/living/basic/basic_source = source
		basic_source.force_threshold = initial(basic_source.force_threshold)

/datum/element/damage_threshold/proc/check_block(mob/living/source, obj/item/hitby, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(hitby) || (hitby.item_flags & NOBLUDGEON) || hitby.force <= 0 || hitby.force > force_threshold)
		return NONE
	if(isliving(user))
		user.do_attack_animation(source)
		user.changeNext_move(hitby.attack_speed)
	source.visible_message(
		span_warning("[source] wygląda na nietkniętego."),
		span_warning("[hitby] nie robi ci krzywdy!"),
	)
	playsound(source, 'sound/weapons/tap.ogg', hitby.get_clamped_volume(), TRUE, -1)
	return COMPONENT_NO_AFTERATTACK
