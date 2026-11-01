/obj/item/computer_hardware/identifier
	name = "identyfikator urządzenia"
	desc = "Służy do automatycznego aktualizowania nazw urządzeń modułowych."
	power_usage = 0
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_IDENTIFY
	expansion_hw = FALSE

/obj/item/computer_hardware/identifier/proc/UpdateDisplay()
	var/name = holder.saved_identification
	var/job = holder.saved_job

	holder.name = "PDA-[name] ([job])"
