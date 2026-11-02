// AQUILA - human body sprites from tgstation (icons/mob/human/bodyparts_greyscale.dmi, CC-BY-SA 3.0).
// Same 32x32 layout and state names as our human states in icons/mob/human_parts_greyscale.dmi, so clothes, hair, eyes
// and underwear fit as before. Only the human limb states are swapped, other species keep the shared icon.

/// tg human body sprites (human_head_m, human_chest_f, human_r_arm...)
#define AQ_HUMAN_BODYPARTS_ICON 'aquila/icons/mob/human/human_bodyparts_greyscale.dmi'

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(limb_id != SPECIES_HUMAN)
		return
	for(var/image/part in .)
		if(part.icon == DEFAULT_BODYPART_ICON_ORGANIC)
			part.icon = AQ_HUMAN_BODYPARTS_ICON

/// Preference previews use the same sprites as the mob
/proc/aq_body_preview_icon(icon_file, state)
	if(icon_file == DEFAULT_BODYPART_ICON_ORGANIC && findtext(state, "[SPECIES_HUMAN]_") == 1)
		return AQ_HUMAN_BODYPARTS_ICON
	return icon_file

#undef AQ_HUMAN_BODYPARTS_ICON
