// AQUILA - blood feedback from shiptest-ss13/Shiptest#3239: drops of blood falling from a bleeding mob,
// blood trails left by a flying hit splatter, splatters that stick to windows. Our bleeding is one status
// effect per mob (Bee), not per limb like Shiptest, so the drops follow the status effect.

/particles/droplets
	icon = 'aquila/icons/effects/particles/blood_drops.dmi'
	icon_state = list("dot" = 2, "drop" = 1)
	width = 32
	height = 36
	count = 5
	spawning = 0.2
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	color = "#549EFF"
	position = generator("box", list(-9, -9, 0), list(9, 18, 0), NORMAL_RAND)
	scale = generator("vector", list(0.9, 0.9), list(1.1, 1.1), NORMAL_RAND)
	gravity = list(0, -0.9)

/particles/droplets/blood
	color = COLOR_BLOOD

/datum/status_effect/bleeding
	/// Drops of blood falling from the owner
	var/obj/effect/abstract/particle_holder/blood_drops

/datum/status_effect/bleeding/tick()
	. = ..()
	if(!QDELETED(src))
		update_blood_drops()

/datum/status_effect/bleeding/on_remove()
	QDEL_NULL(blood_drops)
	return ..()

/datum/status_effect/bleeding/Destroy()
	QDEL_NULL(blood_drops)
	return ..()

/datum/status_effect/bleeding/proc/update_blood_drops()
	var/mob/living/carbon/carbon_owner = owner
	var/rate = min(bleed_rate, MAX_BLEED_RATE)
	if(!istype(carbon_owner) || !carbon_owner.is_bleeding() || !isturf(owner.loc) || HAS_TRAIT(owner, TRAIT_FAKEDEATH) || HAS_TRAIT(owner, TRAIT_NO_BLEEDING) || IS_IN_STASIS(owner))
		rate = 0
	if(rate <= 0)
		QDEL_NULL(blood_drops)
		return
	if(!blood_drops)
		blood_drops = new(owner, /particles/droplets/blood)
	blood_drops.particles.color = owner.get_blood_color()
	blood_drops.particles.spawning = rate / 2
	blood_drops.particles.count = max(1, round(rate * 2))

/// Thin trail left where the hit splatter flew, soaked up by bigger blood on the same turf
/obj/effect/decal/cleanable/blood/squirt
	name = "smuga krwi"
	desc = "Krew rozprysła się tu w jednym kierunku."
	icon = 'aquila/icons/effects/blood_squirt.dmi'
	icon_state = "squirt"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/hitsplatter/proc/leave_squirt(direction)
	var/turf/here = loc
	if(!isturf(here) || isgroundlessturf(here) || QDELETED(blood_source))
		return
	for(var/obj/effect/decal/cleanable/blood/existing in here)
		if(existing != src)
			return
	var/obj/effect/decal/cleanable/blood/squirt/trail = new(here)
	if(QDELETED(trail))
		return
	trail.setDir(direction)
	trail.add_mob_blood(blood_source)

/// Blood that hit a full tile window from the side, shown in the window's vis_contents
/obj/effect/decal/cleanable/blood/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	turf_loc_check = FALSE
	alpha = 180
	vis_flags = VIS_INHERIT_PLANE
	is_slippery = FALSE
	leaves_trace = FALSE

/// Returns TRUE if the splatter stuck to the window
/obj/effect/decal/cleanable/blood/hitsplatter/proc/land_on_window(obj/structure/window/window)
	if(!window.fulltile || QDELETED(blood_source))
		return FALSE
	if(locate(/obj/effect/decal/cleanable/blood/splatter/over_window) in window.vis_contents)
		return TRUE
	var/obj/effect/decal/cleanable/blood/splatter/over_window/stain = new(window)
	stain.add_mob_blood(blood_source)
	window.vis_contents += stain
	window.RegisterSignal(window, COMSIG_COMPONENT_CLEAN_ACT, TYPE_PROC_REF(/obj/structure/window, clean_blood_stain), override = TRUE)
	return TRUE

/obj/structure/window/proc/clean_blood_stain(datum/source, strength)
	SIGNAL_HANDLER
	for(var/obj/effect/decal/cleanable/blood/splatter/over_window/stain in vis_contents)
		vis_contents -= stain
		qdel(stain)
	UnregisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT)

/// Bone breaking sound (TGMC, via Shiptest#3239)
/mob/living/carbon/proc/play_bone_break()
	playsound(src, pick('aquila/sound/effects/bone/bone_break1.ogg', 'aquila/sound/effects/bone/bone_break2.ogg', 'aquila/sound/effects/bone/bone_break3.ogg', \
		'aquila/sound/effects/bone/bone_break4.ogg', 'aquila/sound/effects/bone/bone_break5.ogg', 'aquila/sound/effects/bone/bone_break6.ogg'), 100, FALSE, -1)
