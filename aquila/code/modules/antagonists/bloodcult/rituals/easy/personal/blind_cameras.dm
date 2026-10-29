
/datum/bloodcult_ritual/blind_cameras
	name = "Oślep kamery"
	desc = "runy i talizmany zamętu...<br>zaćmij ich soczewki..."

	ritual_type = "confusion"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("confusion_camera")

	var/target_cameras = 3

/datum/bloodcult_ritual/blind_cameras/init_ritual()
	target_cameras = 3

//Called when a cultist is about to hover the corresponding ritual UI button
/datum/bloodcult_ritual/blind_cameras/update_desc()
	desc = "runy i talizmany zamętu...<br>zaćmij ich soczewki...<br>zostało jeszcze [target_cameras]..."

/datum/bloodcult_ritual/blind_cameras/key_found(extra)
	target_cameras--
	if(target_cameras <= 0)
		return TRUE
	return FALSE
