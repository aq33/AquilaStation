/obj/item/ship_weapon/parts/missile
	var/target_state = 0
	var/fits_type = null

/obj/item/ship_weapon/parts/missile/warhead
	name = "standardowa głowica rakiety NTP-2"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "warhead_highvelocity"
	desc = "Ciężka głowica do zamontowania w rakiecie. Obecnie jest nieaktywna."
	w_class = WEIGHT_CLASS_HUGE
	target_state = 6
	var/build_path = /obj/item/ship_weapon/ammunition/missile
	fits_type = /obj/item/ship_weapon/ammunition/missile/missile_casing //Used for warheads, missiles are different from torp.


/obj/item/ship_weapon/parts/missile/guidance_system
	name = "układ naprowadzania pocisku"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "guidance"
	desc = "Moduł naprowadzania dla przyszłych pocisków kierowanych, który pozwala im namierzyć cel w zasięgu działania. Mikrokomputer w środku wykonuje tysiące obliczeń na sekundę."
	w_class = WEIGHT_CLASS_NORMAL
	target_state = 2
	var/accuracy = null

/obj/item/ship_weapon/parts/missile/propulsion_system
	name = "układ napędowy pocisku kierowanego"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "propulsion"
	desc = "Silnik na przegubie kardana z dyszą montażową, przeznaczony do pocisków kierowanych."
	w_class = WEIGHT_CLASS_BULKY
	target_state = 0
	var/speed = 1

/obj/item/ship_weapon/parts/missile/iff_card //This should be abuseable via emag
	name = "karta IFF pocisku kierowanego"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff"
	desc = "Układ IFF, dzięki któremu pocisk kierowany odróżnia swoich od wrogów. Elektronika w środku jest dość prosta, ale mimo to kluczowa."
	w_class = WEIGHT_CLASS_SMALL
	target_state = 4
	var/calibrated = FALSE

/obj/item/ship_weapon/parts/missile/iff_card/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user.visible_message("<span class='warning'>[user] zwiera [src]!</span>",
						"<span class='notice'>Zwierasz protokoły IFF [src].</span>",
						"Bzzzt.")
	icon_state = "iff_hacked"
