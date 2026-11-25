// AQUILA - skull wounds. A fracture or a compound fracture on the head is a cracked or a caved-in skull: the head shows
// the dent overlay (aquila/icons/mob/effects/denthead.dmi, front and back), like the split skull. Like tgstation bones.dm
// on the head, the wound keeps giving brain traumas until the bone is fixed.

/mob/living/carbon
	/// The dent overlay on the head while a skull wound is on it
	var/mutable_appearance/aq_skull_dent

/// Is any skull wound on the head: a cracked or caved-in skull, or a split one
/mob/living/carbon/proc/aq_has_skull_wound()
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	for(var/datum/wound/wound as anything in head?.wounds)
		if(QDELETED(wound))
			continue
		if(wound.wound_type == WOUND_CRANIAL || (wound.wound_type == WOUND_BLUNT && wound.severity >= WOUND_SEVERITY_SEVERE))
			return TRUE
	return FALSE

/// The head shows the dent while a skull wound is on it. The sprite has only the front and the back of the head,
/// so from the side nothing is drawn.
/mob/living/carbon/proc/aq_update_skull_filter()
	if(!aq_has_skull_wound())
		UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
		aq_show_skull_dent(null)
		return
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(aq_skull_dir_changed), override = TRUE)
	// Odcięta głowa zabiera ranę ze sobą: bez tego wgniecenie zostawało nad szyją
	RegisterSignal(get_bodypart(BODY_ZONE_HEAD), COMSIG_BODYPART_DROPPED, PROC_REF(aq_skull_head_dropped), override = TRUE)
	aq_show_skull_dent(dir)

/mob/living/carbon/proc/aq_skull_dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!aq_has_skull_wound())
		UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
		aq_show_skull_dent(null)
		return
	aq_show_skull_dent(new_dir)

/// Przyłączona z powrotem głowa z raną czaszki znowu pokazuje wgniecenie
/obj/item/bodypart/head/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(length(wounds) && owner == C && !QDELETED(C))
		C.aq_update_skull_filter()

/// Głowa odpada (sygnał przed odłączeniem): ciało bez głowy nie ma wgniecenia
/mob/living/carbon/proc/aq_skull_head_dropped(obj/item/bodypart/head, mob/living/carbon/old_owner, special)
	SIGNAL_HANDLER
	UnregisterSignal(head, COMSIG_BODYPART_DROPPED)
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	aq_show_skull_dent(null)

/// Draws the dent for the facing, just above the hair and under masks and headgear; null or a side removes it
/mob/living/carbon/proc/aq_show_skull_dent(facing)
	var/state
	switch(facing)
		if(SOUTH)
			state = "denthead-mob-front"
		if(NORTH)
			state = "denthead-mob-back"
	if(aq_skull_dent?.icon_state == state)
		return
	if(aq_skull_dent)
		cut_overlay(aq_skull_dent)
		aq_skull_dent = null
	if(!state)
		return
	aq_skull_dent = mutable_appearance('aquila/icons/mob/effects/denthead.dmi', state, -(HAIR_LAYER - 0.5))
	// Głowa gatunku bywa przesunięta (małpy): wgniecenie idzie tam, gdzie nakrycie głowy. Rozmiar ciała skaluje cały mob.
	var/list/head_offset = dna?.species?.offset_features?[OFFSET_HEAD]
	if(length(head_offset))
		aq_skull_dent.pixel_x += head_offset[1]
		aq_skull_dent.pixel_y += head_offset[2]
	add_overlay(aq_skull_dent)

/datum/wound/blunt
	/// Head texts, used instead of the limb ones when the bone breaks on the head
	var/skull_name
	var/skull_desc
	var/skull_examine_desc
	/// Brain traumas the broken skull keeps giving (tgstation brain_trauma_group), null for none
	var/skull_trauma_group
	/// How long one trauma lasts and how long the pause after it is, +/- 20%
	var/skull_trauma_cooldown = 0
	var/datum/brain_trauma/skull_trauma
	var/next_skull_trauma = 0

/datum/wound/blunt/apply_wound(obj/item/bodypart/new_limb, silent = FALSE)
	if(new_limb.body_zone == BODY_ZONE_HEAD && skull_name)
		name = skull_name
		desc = skull_desc
		examine_desc = skull_examine_desc
	. = ..()
	if(is_skull())
		victim.aq_update_skull_filter()
		cycle_skull_trauma()

/datum/wound/blunt/Destroy()
	var/mob/living/carbon/old_victim = victim
	var/was_skull = is_skull()
	QDEL_NULL(skull_trauma)
	. = ..()
	if(was_skull && !QDELETED(old_victim))
		old_victim.aq_update_skull_filter()

/datum/wound/blunt/proc/is_skull()
	return limb?.body_zone == BODY_ZONE_HEAD && skull_trauma_group

/datum/wound/blunt/wound_effects(delta_time)
	. = ..()
	if(skull_trauma && QDELETED(skull_trauma)) // cured by brain surgery
		skull_trauma = null
	if(is_skull() && world.time >= next_skull_trauma)
		cycle_skull_trauma()

/// tgstation: the trauma comes, goes away for a while, and another one comes
/datum/wound/blunt/proc/cycle_skull_trauma()
	if(skull_trauma)
		QDEL_NULL(skull_trauma)
	else
		skull_trauma = roll_skull_trauma()
	next_skull_trauma = world.time + rand(80, 120) * 0.01 * skull_trauma_cooldown

/// A random trauma of the group; gain_trauma_type() does not return the trauma, so the type is picked here
/datum/wound/blunt/proc/roll_skull_trauma()
	var/obj/item/organ/brain/brain = victim.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return null
	var/list/possible = list()
	for(var/datum/brain_trauma/trauma_type as anything in subtypesof(skull_trauma_group))
		if(initial(trauma_type.random_gain) && brain.can_gain_trauma(trauma_type, TRAUMA_RESILIENCE_SURGERY))
			possible += trauma_type
	if(!length(possible))
		return null
	return brain.gain_trauma(pick(possible), TRAUMA_RESILIENCE_SURGERY)

/datum/wound/blunt/get_scan_text()
	. = ..()
	if(is_skull())
		. += " Dopóki kość się nie zrośnie, pacjent będzie miewał [severity >= WOUND_SEVERITY_CRITICAL ? "ciężkie" : "lekkie"] urazy mózgu."

/datum/wound/blunt/fracture
	skull_name = "Pęknięta czaszka"
	skull_desc = "Słyszysz trzask pękającej czaszki"
	skull_examine_desc = "pękniętą, zniekształconą czaszkę"
	skull_trauma_group = BRAIN_TRAUMA_MILD
	skull_trauma_cooldown = 1.5 MINUTES

/datum/wound/blunt/compound
	skull_name = "Wgnieciona czaszka"
	skull_desc = "Twoja czaszka zapada się z chrzęstem"
	skull_examine_desc = "wgniecioną czaszkę z wystającymi odłamkami kości"
	skull_trauma_group = BRAIN_TRAUMA_SEVERE
	skull_trauma_cooldown = 2.5 MINUTES
