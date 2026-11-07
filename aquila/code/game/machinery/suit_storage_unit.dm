/obj/machinery/suit_storage_unit/infiltrator
	suit_type = /obj/item/clothing/suit/space/hardsuit/infiltration
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/// Hum of the UV cycle and a ding once it is done
/datum/looping_sound/suit_storage_uv
	mid_sounds = list('aquila/sound/machines/thermal/thermal_mid.ogg' = 1)
	mid_length = 2
	volume = 25

/obj/machinery/suit_storage_unit
	var/datum/looping_sound/suit_storage_uv/uv_soundloop

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(uv_soundloop)
	return ..()

/obj/machinery/suit_storage_unit/cook()
	if(uv_cycles)
		if(!uv_soundloop)
			uv_soundloop = new(src, FALSE)
		uv_soundloop.start()
	else
		uv_soundloop?.stop()
		playsound(src, 'sound/machines/ding.ogg', 40, TRUE)
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
