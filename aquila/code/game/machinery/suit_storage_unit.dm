/obj/machinery/suit_storage_unit/infiltrator
	suit_type = /obj/item/clothing/suit/space/hardsuit/infiltration
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/// Cykl dezynfekcji: opuszczenie lamp, skanowanie w pętli (dźwięki z Yogstation, aquila/sound/machines/decon)
/datum/looping_sound/suit_storage_uv
	start_sound = 'aquila/sound/machines/decon/decon-down.ogg'
	start_length = 10
	mid_sounds = list('aquila/sound/machines/decon/decon-scan1.ogg' = 1, 'aquila/sound/machines/decon/decon-scan2.ogg' = 1)
	mid_length = 18
	volume = 40

/// Przeładowane UV (uv_super albo emag) brzmi jak awaria
/datum/looping_sound/suit_storage_uv/overloaded
	mid_sounds = list('aquila/sound/machines/decon/decon-emagged1.ogg' = 10, 'aquila/sound/machines/decon/decon-emagged2.ogg' = 1)
	mid_length = 25

/obj/machinery/suit_storage_unit
	var/datum/looping_sound/suit_storage_uv/uv_soundloop

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(uv_soundloop)
	return ..()

/obj/machinery/suit_storage_unit/cook()
	if(uv_cycles)
		if(!uv_soundloop)
			var/loop_type = (uv_super || (obj_flags & EMAGGED)) ? /datum/looping_sound/suit_storage_uv/overloaded : /datum/looping_sound/suit_storage_uv
			uv_soundloop = new loop_type(src, TRUE)
	else
		QDEL_NULL(uv_soundloop)
		playsound(src, 'aquila/sound/machines/decon/decon-up.ogg', 60, TRUE)
	return ..()

/obj/machinery/suit_storage_unit/open_machine(drop = TRUE)
	if(!state_open)
		playsound(src, 'aquila/sound/machines/decon/decon-open.ogg', 50, TRUE)
	return ..()

/obj/machinery/suit_storage_unit/close_machine(atom/movable/target = null)
	if(state_open)
		playsound(src, 'aquila/sound/machines/decon/decon-close.ogg', 50, TRUE)
	return ..()

/// Zamknięta, zasilona szafa ładuje ogniwo hardsuitu w środku i uzupełnia tlen w jego wbudowanej butli
/obj/machinery/suit_storage_unit/process(delta_time)
	var/obj/item/clothing/suit/space/hardsuit/hardsuit = suit
	if(!istype(hardsuit) || state_open || uv || !is_operational)
		return
	var/obj/item/stock_parts/cell/cell = hardsuit.get_charge_source()
	if(istype(cell) && cell.charge < cell.maxcharge)
		use_power(charge_rate * delta_time)
		cell.give(charge_rate * delta_time)
	var/obj/item/tank/internals/hardsuit/tank = hardsuit.integrated_tank
	if(!tank)
		return
	var/datum/gas_mixture/air = tank.return_air()
	var/full_moles = tank.full_oxygen_moles()
	if(air.get_moles(GAS_O2) < full_moles)
		air.set_moles(GAS_O2, full_moles)
