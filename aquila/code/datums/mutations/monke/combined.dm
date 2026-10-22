// AQUILA - przepisy z Monkestation2.0 (code/datums/mutations/_combined.dm)
// weaker_xray: w Monke thermal + radioactive, ale to u nas zwykły X Ray - zamiast tego thermal + nearsight.

/datum/generecipe/monke_weaker_xray
	required = "/datum/mutation/thermal; /datum/mutation/nearsight"
	result = /datum/mutation/weaker_xray

/datum/generecipe/monke_unstable_lasereyes
	required = "/datum/mutation/thermal; /datum/mutation/cryokinesis/pyrokinesis"
	result = /datum/mutation/laser_eyes/unstable

/datum/generecipe/monke_unstable_firebreath
	required = "/datum/mutation/cryokinesis/pyrokinesis; /datum/mutation/cough"
	result = /datum/mutation/firebreath/unstable

/datum/generecipe/monke_flash_protection
	required = "/datum/mutation/thermal; /datum/mutation/void"
	result = /datum/mutation/flash_protection

// Clever pochodzi z tg - przepis zadziała, gdy ta mutacja się pojawi
/datum/generecipe/monke_meson_vision
	required = "/datum/mutation/thermal; /datum/mutation/clever"
	result = /datum/mutation/meson_vision

/datum/generecipe/monke_acid_hands
	required = "/datum/mutation/acidflesh; /datum/mutation/radioactive"
	result = /datum/mutation/acidooze/unstable
