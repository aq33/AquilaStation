/obj/item/tank/jetpack
	/// Dźwięk dysz przy każdym pchnięciu w próżni (odtwarza /datum/component/jetpack, dawniej Moved() tutaj i AQUILA EDIT w carbon/Move())
	var/thrust_sound = 'aquila/sound/vehicles/jetpack.ogg'

/// Port BeeStation/BeeStation-Hornet#14864: przycisk jetpacka tylko w slocie, w którym się go nosi.
/// Komponent lata z każdym, kto trzyma jetpack, a dawne get_jetpack() widziało tylko plecy, więc bez tego latało się z jetpackiem w ręce.
/obj/item/tank/jetpack/item_action_slot_check(slot, mob/user)
	if(slot & slot_flags)
		return TRUE
	return FALSE
