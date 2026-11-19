// AQUILA - projekty robotyki w drzewku badań (reszta węzłów jest przy swoich projektach: implanty w robotics_implants.dm,
// serce w anomalock_heart.dm, psychoskop w neuromods.dm).

/// Od startu rundy: klucz resetu syntetyka (IPC nie wstaje sam po naprawie)
/datum/techweb_node/base/New()
	. = ..()
	design_ids += list("aq_synth_reset_key")

/// Zaawansowane protezy po zaawansowanej robotyce
/datum/techweb_node/adv_robotics/New()
	. = ..()
	design_ids += list("aq_adv_l_arm", "aq_adv_r_arm", "aq_adv_l_leg", "aq_adv_r_leg")
