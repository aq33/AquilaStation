// Licznik amunicji S.M.A.R.T. z Monkestation (monkestation/code/modules/cybernetics/augments/arm_augments/unsorted.dm).
// Różnice: odświeżanie przez COMSIG_ATOM_UPDATED_ICON broni (u nas nie ma COMSIG_MOB_FIRED_GUN ani COMSIG_CELL_CHANGE_POWER),
// więc licznik łapie też przeładowanie i ładowanie ogniwa; liczy nabój w komorze; zmiana ręki też go odświeża.

/obj/item/organ/cyberimp/arm/ammo_counter
	name = "system logistyki amunicji S.M.A.R.T."
	desc = "Implant w dłoni, który przesyła stan amunicji i energii trzymanej broni prosto do kory wzrokowej."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#750137"
	actions_types = list()
	/// Licznik na ekranie właściciela
	var/atom/movable/screen/cybernetics/ammo_counter/counter
	/// Broń trzymana w ręce z implantem
	var/obj/item/gun/our_gun

/obj/item/organ/cyberimp/arm/ammo_counter/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/ammo_counter/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_SWAP_HANDS), PROC_REF(refresh_gun))
	RegisterSignal(M, COMSIG_MOB_DROPPED_ITEM, PROC_REF(on_dropped))
	refresh_gun()

/obj/item/organ/cyberimp/arm/ammo_counter/Remove(mob/living/carbon/M, special = FALSE)
	UnregisterSignal(M, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_SWAP_HANDS, COMSIG_MOB_DROPPED_ITEM))
	set_gun(null)
	remove_counter(M)
	return ..()

/obj/item/organ/cyberimp/arm/ammo_counter/Destroy()
	set_gun(null)
	remove_counter(owner)
	return ..()

/// Broń trzymana w ręce, w której siedzi implant
/obj/item/organ/cyberimp/arm/ammo_counter/proc/find_gun()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return null
	for(var/obj/item/gun/gun in owner.get_held_items_for_side(zone == BODY_ZONE_L_ARM ? "left" : "right", TRUE))
		if(istype(gun, /obj/item/gun/ballistic) || istype(gun, /obj/item/gun/energy))
			return gun
	return null

/obj/item/organ/cyberimp/arm/ammo_counter/proc/refresh_gun()
	SIGNAL_HANDLER
	set_gun(find_gun())

/obj/item/organ/cyberimp/arm/ammo_counter/proc/on_dropped(datum/source, obj/item/dropped)
	SIGNAL_HANDLER
	if(dropped == our_gun)
		set_gun(null)

/obj/item/organ/cyberimp/arm/ammo_counter/proc/set_gun(obj/item/gun/new_gun)
	if(our_gun == new_gun)
		update_counter()
		return
	if(our_gun)
		UnregisterSignal(our_gun, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_PARENT_QDELETING))
	our_gun = new_gun
	if(our_gun)
		RegisterSignal(our_gun, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_counter))
		RegisterSignal(our_gun, COMSIG_PARENT_QDELETING, PROC_REF(refresh_gun))
	update_counter()

/// Ile strzałów zostało w broni
/obj/item/organ/cyberimp/arm/ammo_counter/proc/shots_left()
	if(istype(our_gun, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/ballistic_gun = our_gun
		return ballistic_gun.get_ammo(TRUE)
	var/obj/item/gun/energy/energy_gun = our_gun
	if(!energy_gun.cell || !length(energy_gun.ammo_type))
		return 0
	var/obj/item/ammo_casing/energy/shot = energy_gun.ammo_type[energy_gun.select]
	if(!istype(shot) || !shot.e_cost)
		return 0
	return FLOOR(energy_gun.cell.charge / shot.e_cost, 1)

/obj/item/organ/cyberimp/arm/ammo_counter/proc/update_counter()
	SIGNAL_HANDLER
	var/datum/hud/hud = owner?.hud_used
	if(!our_gun || QDELETED(our_gun) || !hud)
		remove_counter(owner)
		return
	if(!counter)
		counter = new
		counter.hud = hud
		// Nad slotem ręki z implantem, jak u Monke
		counter.screen_loc = zone == BODY_ZONE_L_ARM ? "CENTER:16,SOUTH:14" : "CENTER-1:16,SOUTH:14"
		hud.infodisplay += counter
		owner.client?.screen += counter
	counter.maptext = MAPTEXT("<div align='center' valign='middle'><font color='white'>[shots_left()]</font></div>")

/obj/item/organ/cyberimp/arm/ammo_counter/proc/remove_counter(mob/living/carbon/from)
	if(!counter)
		return
	var/datum/hud/hud = from?.hud_used
	if(hud)
		hud.infodisplay -= counter
	from?.client?.screen -= counter
	QDEL_NULL(counter)

/obj/item/organ/cyberimp/arm/ammo_counter/syndicate
	syndicate_implant = TRUE

/atom/movable/screen/cybernetics
	icon = 'aquila/icons/obj/cybernetics/screen_cybernetics.dmi'

/atom/movable/screen/cybernetics/ammo_counter
	name = "cyfrowy licznik amunicji"
	icon_state = "basic_interface"
	maptext_width = 32
	maptext_y = 2

/obj/item/autosurgeon/syndicate/ammo_counter
	starting_organ = list(/obj/item/organ/cyberimp/arm/ammo_counter/syndicate)
	uses = 1

/datum/design/cyberimp_set/ammo_counter
	name = "System logistyki amunicji S.M.A.R.T."
	desc = "Implant w dłoni pokazujący liczbę strzałów w trzymanej broni."
	id = "ci-ammo-counter"
	build_path = /obj/item/organ/cyberimp/arm/ammo_counter
