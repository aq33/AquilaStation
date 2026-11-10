// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/pet.dm (bee/master 0adf0fe9ae)
/mob/living/basic/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	blood_volume = BLOOD_VOLUME_NORMAL
	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE

/// Rolled newspaper on the nose, as for simple animal pets
/mob/living/basic/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/newspaper) && !stat && !user.combat_mode)
		user.visible_message("[user] pstryka [name] w nos zwiniętym [O].")
		INVOKE_ASYNC(src, PROC_REF(newspaper_spin))
		return
	return ..()

/mob/living/basic/pet/proc/newspaper_spin()
	for(var/i in list(1,2,4,8,4,2,1,2))
		setDir(i)
		sleep(1)

/mob/living/basic/pet/machine_wash(obj/machinery/washing_machine/WM)
	WM.bloody_mess = TRUE
	gib()
