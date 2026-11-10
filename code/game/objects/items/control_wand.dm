#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "pilot do drzwi"
	desc = "Zdalnie steruje śluzami."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	var/department_bitflag = DEPARTMENT_BITFLAG_SERVICE // AQ EDIT - pilot dostaje dostępy działów z tej bitflagi (port BeeStation/BeeStation-Hornet#14139)
	var/list/access_list
	network_id = NETWORK_DOOR_REMOTES

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	// AQ EDIT START - dostępy z grup działów SSdepartment (port BeeStation/BeeStation-Hornet#14139)
	access_list = SSdepartment.get_accesses_by_bitflag(department_bitflag)
	if(!length(access_list))
		stack_trace("[type] has no department_bitflag access, it cannot open any door")
	// AQ EDIT END
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_NAK, PROC_REF(bad_signal))
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_ACK, PROC_REF(good_signal))

/obj/item/door_remote/proc/bad_signal(datum/source, datum/netdata/data, error_code)
	if(QDELETED(data.user))
		return // can't send a message to a missing user
	if(error_code == NETWORK_ERROR_UNAUTHORIZED)
		to_chat(data.user, "<span class='notice'>Ten pilot nie ma uprawnień do zmiany tych drzwi.</span>")
	else
		to_chat(data.user, "<span class='notice'>Błąd: [error_code]</span>")


/obj/item/door_remote/proc/good_signal(datum/source, datum/netdata/data, error_code)
	if(QDELETED(data.user))
		return
	var/toggled = data.data["data"]
	to_chat(data.user, "<span class='notice'>Drzwi: przełączono [toggled]</span>")

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "otwieranie drzwi", WAND_BOLT = "przełączanie rygli", WAND_EMERGENCY = "przełączanie dostępu awaryjnego")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	balloon_alert(user, "Ustawiasz tryb: [desc[mode]].")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/A, mob/user)
	. = ..()
	var/datum/component/ntnet_interface/target_interface = A.GetComponent(/datum/component/ntnet_interface)

	if(!target_interface)
		return
	if(!SSnetworks.station_network.check_function(NTNET_SYSTEMCONTROL, get_virtual_z_level()))
		to_chat(user, "<span class='warning'>Na pilocie miga czerwona lampka! Wygląda na to, że NTNET nie działa!</span>")
		return
	user.set_machine(src)
	// Generate a control packet.
	var/datum/netdata/data = new(list("data" = mode,"data_secondary" = "toggle"))
	data.receiver_id = target_interface.hardware_id
	data.passkey = access_list
	data.user = user // for responce message

	ntnet_send(data)


/obj/item/door_remote/omni
	name = "uniwersalny pilot do drzwi"
	desc = "Ten pilot ma dostęp do wszystkich drzwi na stacji."
	icon_state = "gangtool-yellow"
	department_bitflag = DEPARTMENT_BITFLAG_STATIONS // AQ EDIT - bitflaga działów

/obj/item/door_remote/captain
	name = "pilot do drzwi dowództwa"
	icon_state = "gangtool-yellow"
	department_bitflag = DEPARTMENT_BITFLAG_COMMAND // AQ EDIT - bitflaga działów, zostaje Dowództwo (Bee daje całą stację)

/obj/item/door_remote/chief_engineer
	name = "pilot do drzwi inżynierii"
	icon_state = "gangtool-orange"
	department_bitflag = DEPARTMENT_BITFLAG_ENGINEERING // AQ EDIT - bitflaga działów

/obj/item/door_remote/research_director
	name = "pilot do drzwi działu naukowego"
	icon_state = "gangtool-purple"
	department_bitflag = DEPARTMENT_BITFLAG_SCIENCE // AQ EDIT - bitflaga działów

/obj/item/door_remote/head_of_security
	name = "pilot do drzwi ochrony"
	icon_state = "gangtool-red"
	department_bitflag = DEPARTMENT_BITFLAG_SECURITY // AQ EDIT - bitflaga działów

/obj/item/door_remote/quartermaster
	name = "pilot do drzwi zaopatrzenia"
	desc = "Zdalnie steruje śluzami. Ten pilot ma też dostęp do Skarbca."
	icon_state = "gangtool-green"
	department_bitflag = DEPARTMENT_BITFLAG_CARGO // AQ EDIT - bitflaga działów

/obj/item/door_remote/chief_medical_officer
	name = "pilot do drzwi medycznych"
	icon_state = "gangtool-blue"
	department_bitflag = DEPARTMENT_BITFLAG_MEDICAL // AQ EDIT - bitflaga działów

/obj/item/door_remote/civillian
	name = "pilot do drzwi cywilnych"
	icon_state = "gangtool-white"
	department_bitflag = DEPARTMENT_BITFLAG_SERVICE // AQ EDIT - bitflaga działów

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
