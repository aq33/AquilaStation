// AQUILA - przepisy z Monkestation2.0 (code/datums/mutations/_combined.dm)
// Pominięte: weaker_xray (thermal + radioactive to u nas już X Ray), laser_eyes/unstable i firebreath/unstable (brak pyrokinesis).

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
