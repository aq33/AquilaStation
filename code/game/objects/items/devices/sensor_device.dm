/obj/item/sensor_device
	name = "ręczny monitor załogi" //Thanks to Gun Hog for the name!
	desc = "Miniaturowe urządzenie śledzące czujniki kombinezonów na całej stacji."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_price = 100

/obj/item/sensor_device/attack_self(mob/user)
	GLOB.crewmonitor.show(user,src) //Proc already exists, just had to call it
