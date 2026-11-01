// AQUILA - blood feedback from shiptest-ss13/Shiptest#3239: splatters that stick to windows and walls, bone breaking sound.
// The falling drop particles were dropped for the tg bleed overlays on the body, the trails left by a flying splatter for tg blood trails.

/// Blood that hit a full tile window from the side, shown in the window's vis_contents
/obj/effect/decal/cleanable/blood/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	turf_loc_check = FALSE
	alpha = 180
	vis_flags = VIS_INHERIT_PLANE
	is_slippery = FALSE
	leaves_trace = FALSE

/// Blood that hit a wall: lies on the floor next to it, shifted onto the wall and drawn above it
/obj/effect/decal/cleanable/blood/splatter/on_wall
	name = "krew na ścianie"
	layer = ABOVE_WINDOW_LAYER
	alpha = 200
	is_slippery = FALSE

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
