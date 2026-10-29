/obj/item/pai_cable
	desc = "Giętki kabel w osłonie z uniwersalną wtyczką na jednym końcu."
	name = "kabel danych"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	var/obj/machinery/machine

/obj/item/pai_cable/proc/plugin(obj/machinery/M, mob/living/user)
	if(!user.transferItemToLoc(src, M))
		return
	user.visible_message("[user] wkłada [src] do portu danych [M].", "<span class='notice'>Wkładasz [src] do portu danych [M].</span>", "<span class='italics'>Słyszysz satysfakcjonujące kliknięcie wtyku zatrzaskującego się na miejscu.</span>")
	machine = M
