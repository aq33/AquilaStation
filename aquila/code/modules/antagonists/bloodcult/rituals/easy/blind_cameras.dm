
/datum/bloodcult_ritual/blind_cameras_multi
	name = "Oślep wiele kamer"
	desc = "runy i talizmany zamętu...<br>zaćmij ich soczewki..."

	ritual_type = "confusion"
	difficulty = "easy"
	reward_faction = 200

	keys = list("confusion_camera")

	var/target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/init_ritual()
	target_cameras = 20

/datum/bloodcult_ritual/blind_cameras_multi/update_desc()
	desc = "runy i talizmany zamętu...<br>zaćmij ich soczewki...<br>zostało jeszcze [target_cameras]..."

/datum/bloodcult_ritual/blind_cameras_multi/key_found(extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE
