// AQUILA - projekty robotyki w drzewku badań (reszta węzłów jest przy swoich projektach: implanty w robotics_implants.dm,
// serce w anomalock_heart.dm, psychoskop w neuromods.dm).

/// Od startu rundy: klucz resetu syntetyka (IPC nie wstaje sam po naprawie), tanie protezy kinetyczne
/// i organy chłodzenia (IPC idące na abordaż w próżnię potrzebują chłodzenia cieczą od pierwszej minuty)
/datum/techweb_node/base/New()
	. = ..()
	design_ids += list("aq_synth_reset_key", "aq_kinetic_l_arm", "aq_kinetic_r_arm", "aq_kinetic_l_leg", "aq_kinetic_r_leg", \
		"aq_cooling_air", "aq_cooling_liquid", "aq_cooling_passive")

/// Zaawansowane protezy po zaawansowanej robotyce
/datum/techweb_node/adv_robotics/New()
	. = ..()
	design_ids += list("aq_adv_l_arm", "aq_adv_r_arm", "aq_adv_l_leg", "aq_adv_r_leg")
