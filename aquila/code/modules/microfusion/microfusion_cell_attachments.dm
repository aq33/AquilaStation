/*
MICROFUSION CELL UPGRADE ATTACHMENTS

For adding unique abilities to microfusion cells. These cannot directly interact with the gun.
*/

/obj/item/microfusion_cell_attachment
	name = "microfusion cell attachment"
	desc = "Zepsute."
	icon = 'aquila/icons/microfusion/microfusion_cells.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	/// The overlay that will be automatically added, must be in the cells icon.
	var/attachment_overlay_icon_state

/obj/item/microfusion_cell_attachment/proc/add_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	SHOULD_CALL_PARENT(TRUE)
	return

/obj/item/microfusion_cell_attachment/proc/process_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell, delta_time)
	return

/obj/item/microfusion_cell_attachment/proc/remove_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	SHOULD_CALL_PARENT(TRUE)
	return

/*
OVERCAPACITY ATTACHMENT

Increases the cell capacity by a set percentage.
*/

/obj/item/microfusion_cell_attachment/overcapacity
	name = "dodatek nadpojemnościowy do ogniwa microfusion"
	desc = "Dodatek zwiększający pojemność ogniwa microfusion. To dodatkowy, mniejszy kondensator: gdy ogniwo się wyczerpuje, układ automatycznie przełącza zasilanie na kondensator i wyciska z broni więcej strzałów."
	icon_state = "attachment_overcapacity"
	attachment_overlay_icon_state = "microfusion_overcapacity"
	/// How much the attachment increases the cell's capacity by, as a percentage
	var/capacity_increase = 20
	/// The initial capacity of the cell before this upgrade is added!
	var/initial_charge_capacity = 0

/obj/item/microfusion_cell_attachment/overcapacity/add_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	initial_charge_capacity = microfusion_cell.maxcharge
	var/capacity_to_add = microfusion_cell.maxcharge / 100 * capacity_increase
	microfusion_cell.maxcharge += capacity_to_add

/obj/item/microfusion_cell_attachment/overcapacity/remove_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	microfusion_cell.charge = min(microfusion_cell.charge, initial_charge_capacity)
	microfusion_cell.maxcharge = initial_charge_capacity
	initial_charge_capacity = 0

/*
STABILISER ATTACHMENT

The cell is stable and will not emit sparks when firing.
*/

/obj/item/microfusion_cell_attachment/stabiliser
	name = "dodatek stabilizujący do ogniwa microfusion"
	desc = "Stabilizator łączący uziemienie z dodatkowymi cewkami zabezpieczającymi do samoładowania. Ogniwo z nim nie iskrzy i nie przecieka."
	icon_state = "attachment_stabiliser"
	attachment_overlay_icon_state = "microfusion_stabiliser"

/obj/item/microfusion_cell_attachment/stabiliser/add_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	microfusion_cell.stabilised = TRUE

/obj/item/microfusion_cell_attachment/stabiliser/remove_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	microfusion_cell.stabilised = FALSE

/*
SELFCHARGE ATTACHMENT

The cell will charge itself.
If the cell isn't stabilised by a stabiliser, it may emit a radiation pulse.
*/

/obj/item/microfusion_cell_attachment/selfcharging
	name = "dodatek samoładujący do ogniwa microfusion"
	desc = "Ogniwa microfusion wysyła się zwykle bez paliwa, ale ten dodatek ma w sobie piętnaście gramów wodoru, który podtrzymuje małą reakcję i ładuje ogniwo. W dobrych warunkach starcza na tygodnie, a nawet miesiące, czyli na większość kampanii z zapasem."
	icon_state = "attachment_selfcharge"
	attachment_overlay_icon_state = "microfusion_selfcharge"
	/// The amount of charge this cell will passively gain!
	var/self_charge_amount = 20

/obj/item/microfusion_cell_attachment/selfcharging/examine(mob/user)
	. = ..()
	. += "<span class='warning'>UWAGA: bez zalecanego dodatku stabilizującego może powodować oparzenia popromienne i niestabilność broni!</span>"

/obj/item/microfusion_cell_attachment/selfcharging/add_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	microfusion_cell.self_charging = TRUE

/obj/item/microfusion_cell_attachment/selfcharging/remove_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell)
	. = ..()
	microfusion_cell.self_charging = FALSE

/obj/item/microfusion_cell_attachment/selfcharging/process_attachment(obj/item/stock_parts/cell/microfusion/microfusion_cell, delta_time)
	if(!microfusion_cell.parent_gun)
		return
	if(microfusion_cell.charge < microfusion_cell.maxcharge)
		microfusion_cell.give(self_charge_amount * delta_time)
		microfusion_cell.parent_gun.update_appearance()
	if(!microfusion_cell.stabilised && DT_PROB(1, delta_time))
		radiation_pulse(microfusion_cell, 50)
