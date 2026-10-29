// AQUILA - stan chirurgiczny kończyny z tg (code/modules/surgery/bodyparts/_bodyparts.dm, tgstation#93697)

/obj/item/bodypart
	/// Flagi SURGERY_* - co chirurg już zrobił z tą kończyną (nacięcie, rozwarcie, piłowanie...)
	VAR_FINAL/surgery_state = NONE

/// Dodaje jeden albo kilka stanów chirurgicznych
/obj/item/bodypart/proc/add_surgical_state(new_states)
	if(!new_states)
		CRASH("add_surgical_state called with no new states to add")
	var/old_states = surgery_state
	surgery_state |= new_states
	update_surgical_state(old_states, new_states)

/// Usuwa jeden albo kilka stanów chirurgicznych
/obj/item/bodypart/proc/remove_surgical_state(removing_states)
	if(!removing_states)
		CRASH("remove_surgical_state called with no states to remove")
	if(!(surgery_state & removing_states))
		return

	// stany wynikające z budowy kończyny zostają
	if(!LIMB_HAS_SKIN(src))
		removing_states &= ~SKINLESS_SURGERY_STATES
	if(!LIMB_HAS_BONES(src))
		removing_states &= ~BONELESS_SURGERY_STATES
	if(!LIMB_HAS_VESSELS(src))
		removing_states &= ~VESSELLESS_SURGERY_STATES
	if(!removing_states)
		return

	var/old_states = surgery_state
	surgery_state &= ~removing_states
	update_surgical_state(old_states, removing_states)

/// Po zmianie stanu: sygnały dla komputera operacyjnego, monitorów itd.
/obj/item/bodypart/proc/update_surgical_state(old_state, changed_states)
	SEND_SIGNAL(src, COMSIG_BODYPART_UPDATING_SURGERY_STATE, old_state, surgery_state, changed_states)
	if(isnull(owner))
		return
	SEND_SIGNAL(owner, COMSIG_LIVING_UPDATING_SURGERY_STATE, old_state, surgery_state, changed_states)
	// odsłonięte organy wypadają przy bieganiu (aquila/code/modules/surgery/exposed_organs.dm)
	owner.update_exposed_organs()

/// Stan do pokazania (bez stanów wynikających z budowy kończyny)
/obj/item/bodypart/proc/get_reported_surgery_state()
	var/reported_state = surgery_state
	if(!LIMB_HAS_SKIN(src))
		reported_state &= ~SKINLESS_SURGERY_STATES
	if(!LIMB_HAS_BONES(src))
		reported_state &= ~BONELESS_SURGERY_STATES
	if(!LIMB_HAS_VESSELS(src))
		reported_state &= ~VESSELLESS_SURGERY_STATES
	return reported_state

/obj/item/bodypart/vv_edit_var(vname, vval)
	if(vname != NAMEOF(src, surgery_state))
		return ..()

	var/old_state = surgery_state
	. = ..()
	update_surgical_state(old_state, surgery_state ^ old_state)

// Przygotowanie do operacji idzie za kończyną: odcięta traci cechę, przyszyta w przygotowaną strefę ją dostaje
/obj/item/bodypart/drop_limb(special)
	REMOVE_TRAIT(src, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(SURGERY_PREPPED_ID))
	return ..()

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(QDELETED(C) || owner != C)
		return
	var/datum/status_effect/surgery_prepped/prep = C.has_status_effect(/datum/status_effect/surgery_prepped) || null // u nas FALSE, gdy brak statusu
	if(prep && (body_zone in prep.zones))
		ADD_TRAIT(src, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(SURGERY_PREPPED_ID))

// --- Hooki w core pytające o otwartą kończynę (AQ EDIT, LEGACY_OVERRIDES.md) ---

/// Zarodek obcego (alien_embryo.dm): otwarta klatka to operacja w toku, larwa wychodzi bez zabijania (tg: skóra + kość)
/mob/living/proc/is_chest_open_for_surgery()
	return LIMB_HAS_SURGERY_STATE(get_bodypart(BODY_ZONE_CHEST), SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)

/// Moduł MOD wystrzeliwujący organy (modules_medical.dm): organ wchodzi do otwartej kończyny (tg: skóra, organy, kość)
/mob/living/proc/can_receive_shot_organ(obj/item/organ/organ)
	return LIMB_HAS_SURGERY_STATE(get_bodypart(check_zone(organ.zone)), SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED)
