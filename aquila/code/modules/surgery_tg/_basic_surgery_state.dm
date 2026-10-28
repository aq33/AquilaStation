// AQUILA - tg code/modules/surgery/operations/_basic_surgery_state.dm
/// Stan chirurgiczny moba bez kończyn (zwierzęta, szlamy). Moby z kończynami trzymają stan na kończynach.
/datum/status_effect/basic_surgery_state
	id = "surgery_state"

	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH

	var/surgery_state = NONE

/datum/status_effect/basic_surgery_state/on_creation(mob/living/new_owner, added_state = NONE, removed_state = NONE)
	. = ..()
	if(QDELETED(src) || isnull(owner))
		return
	surgery_state = (added_state & ~removed_state)
	SEND_SIGNAL(owner, COMSIG_LIVING_UPDATING_SURGERY_STATE, NONE, surgery_state, added_state)

/datum/status_effect/basic_surgery_state/on_apply()
	. = ..()
	if(owner.has_limbs)
		stack_trace("Applied a basic surgery state to [owner], which has limbs. This status effect is intended for limbless mobs.")

/datum/status_effect/basic_surgery_state/get_examine_text(mob/examiner)
	if(HAS_SURGERY_STATE(surgery_state, SURGERY_SKIN_OPEN))
		return "Ma rozciętą skórę[HAS_SURGERY_STATE(surgery_state, SURGERY_BONE_SAWED) ? " i przepiłowane kości" : ""]."
	// innych stanów moby bez kończyn jeszcze nie mają
	stack_trace("Surgery state holder had unsupported state(s): [jointext(bitfield_to_list(surgery_state, SURGERY_STATE_READABLE), ", ")]")
	return null

/datum/status_effect/basic_surgery_state/refresh(mob/living/old_owner, added_state = NONE, removed_state = NONE)
	var/old_state = surgery_state
	surgery_state |= added_state
	surgery_state &= ~removed_state
	SEND_SIGNAL(owner, COMSIG_LIVING_UPDATING_SURGERY_STATE, old_state, surgery_state, added_state | removed_state)
	if(!surgery_state)
		qdel(src)
