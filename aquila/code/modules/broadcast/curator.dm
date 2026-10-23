// AQUILA: kurator zaczyna z kamerą reporterską (w Monkestation dostaje ją pierwszy kurator)

/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/broadcast_camera/camera = new(H)
	if(!H.equip_to_slot_if_possible(camera, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
		camera.forceMove(H.drop_location())
