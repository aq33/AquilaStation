// AQUILA: port of tgstation/tgstation code/datums/components/shrink.dm (AGPL-3.0), used by the abductor shrink ray.
// Differences: our human damage resistance lives in physiology (tg: mob/living damage_resistance), so only humans take
// the doubled damage; the small voice uses our existing "small" chat class.

/// Zmniejsza atom na określony czas: o połowę mniejszy, przezroczysty dla widoku i przejścia, mob jest wolniejszy i łatwo go rozdeptać
/datum/component/shrink
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/olddens
	var/oldopac
	/// Komponent rozdeptywania nałożony na zmniejszonego moba (zdejmowany razem z nami)
	var/datum/component/squashable/newsquash

/datum/component/shrink/Initialize(shrink_time)
	if(!isatom(parent) || isturf(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(0.5, 0.5)
	olddens = parent_atom.density
	oldopac = parent_atom.opacity

	parent_atom.set_opacity(FALSE)
	parent_atom.density = FALSE
	if(isliving(parent_atom))
		var/mob/living/living = parent_atom
		ADD_TRAIT(living, TRAIT_UNDENSE, "shrunken")
		RegisterSignal(living, COMSIG_MOB_SAY, PROC_REF(handle_shrunk_speech))
		living.add_movespeed_modifier_type(/datum/movespeed_modifier/shrink_ray)
		if(ishuman(living))
			var/mob/living/carbon/human/human = living
			human.physiology.damage_resistance -= 100
		if(iscarbon(living))
			var/mob/living/carbon/carbon = living
			carbon.unequip_everything()
			carbon.visible_message(span_warning("Rzeczy [carbon] spadają na ziemię, gdy się kurczy!"),
				span_userdanger("Twoje rzeczy spadają, a wszystko wokół rośnie!"))
		if(!living.GetComponent(/datum/component/squashable))
			newsquash = living.AddComponent(/datum/component/squashable, 75, 10)
	parent_atom.visible_message(span_warning("[parent_atom] kurczy się do maleńkich rozmiarów!"),
		span_userdanger("Wszystko wokół rośnie!"))
	if(shrink_time >= 0) // ujemny czas oznacza zmniejszenie na stałe
		QDEL_IN(src, shrink_time)

/datum/component/shrink/proc/handle_shrunk_speech(mob/living/little_guy, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= "small"

/datum/component/shrink/Destroy()
	if(newsquash)
		QDEL_NULL(newsquash)
	var/atom/parent_atom = parent
	parent_atom.transform = parent_atom.transform.Scale(2, 2)
	parent_atom.set_opacity(oldopac)
	if(isliving(parent_atom))
		var/mob/living/living = parent_atom
		living.remove_movespeed_modifier_type(/datum/movespeed_modifier/shrink_ray)
		REMOVE_TRAIT(living, TRAIT_UNDENSE, "shrunken")
		UnregisterSignal(living, COMSIG_MOB_SAY)
		if(ishuman(living))
			var/mob/living/carbon/human/human = living
			human.physiology.damage_resistance += 100
		living.update_mobility()
	else
		parent_atom.density = olddens
	return ..()

/datum/movespeed_modifier/shrink_ray
	movetypes = GROUND
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW
