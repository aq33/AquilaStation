// AQUILA - skrzynka skarg (Apollo Station code/game/machinery/computer/complaints.dm, sprite stamtąd).
// Kartka wrzucona do skrzynki dostaje numer i tytuł i trafia na listę skarg. Skrzynka nie zapisuje autora
// (w logach admina jest). Listę czytają i drukują Kapitan, Starszy Oficer, Komendant i prawnik. Wpływ skargi
// ogłasza się na kanale Dowództwa. Rama do zawieszenia na ścianie z autolathe.

/// Skargi z tej rundy: lista list("number", "title", "text", "time")
GLOBAL_LIST_EMPTY(aq_complaints)
GLOBAL_VAR_INIT(aq_complaint_counter, 0)

#define COMPLAINT_ANNOUNCE_COOLDOWN (30 SECONDS)

/obj/machinery/complaint_box
	name = "skrzynka skarg"
	desc = "Wrzuć zapisaną kartkę ze skargą. Skrzynka nie zapisuje nadawcy, skargi czyta dowództwo i prawnik."
	icon = 'aquila/icons/obj/security/complaint_box.dmi'
	icon_state = "complaintbox"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	max_integrity = 150
	COOLDOWN_DECLARE(announce_cooldown)

/obj/machinery/complaint_box/update_icon_state()
	icon_state = (machine_stat & (NOPOWER|BROKEN)) ? "complaintbox0" : "complaintbox"
	return ..()

/obj/machinery/complaint_box/update_overlays()
	. = ..()
	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "complaintbox_idle"

/obj/machinery/complaint_box/power_change()
	. = ..()
	update_appearance()

/obj/machinery/complaint_box/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/paper))
		return ..()
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>Skrzynka nie działa.</span>")
		return TRUE
	var/obj/item/paper/paper = I
	var/text = paper.get_raw_text()
	if(length(trim(text)) < 10)
		flick("complaintbox_deny", src)
		to_chat(user, "<span class='warning'>Skrzynka odrzuca prawie pustą kartkę.</span>")
		return TRUE
	var/title = trim(tgui_input_text(user, "Tytuł skargi", name, max_length = MAX_NAME_LEN))
	if(!title || QDELETED(paper) || !user.is_holding(paper) || !user.Adjacent(src))
		return TRUE
	add_complaint(title, text, user)
	qdel(paper)
	flick("complaintbox_insert", src)
	to_chat(user, "<span class='notice'>Skarga przyjęta pod numerem [GLOB.aq_complaint_counter].</span>")
	return TRUE

/// Zapisuje skargę, ogłasza ją na kanale Dowództwa (bez autora). Zwraca numer
/obj/machinery/complaint_box/proc/add_complaint(title, text, mob/user)
	var/number = ++GLOB.aq_complaint_counter
	GLOB.aq_complaints += list(list("number" = number, "title" = title, "text" = text, "time" = station_time_timestamp()))
	log_game("Complaint #[number] \"[title]\" submitted by [key_name(user)] at [AREACOORD(src)]")
	if(COOLDOWN_FINISHED(src, announce_cooldown))
		COOLDOWN_START(src, announce_cooldown, COMPLAINT_ANNOUNCE_COOLDOWN)
		aq_security_announce("Skrzynka skarg: wpłynęła skarga nr [number]: „[title]”.", list(RADIO_CHANNEL_COMMAND))
	SStgui.update_uis(src)
	return number

/// Kapitan, Starszy Oficer, Komendant, prawnik
/obj/machinery/complaint_box/proc/can_read(mob/user)
	if(IsAdminGhost(user) || issilicon(user))
		return TRUE
	var/list/access = user.get_idcard(TRUE)?.GetAccess() || list()
	return (ACCESS_CAPTAIN in access) || (ACCESS_HOP in access) || (ACCESS_HOS in access) || (ACCESS_LAWYER in access)

/obj/machinery/complaint_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ComplaintBox")
		ui.open()

/obj/machinery/complaint_box/ui_data(mob/user)
	var/list/data = list()
	data["can_read"] = can_read(user)
	data["count"] = length(GLOB.aq_complaints)
	if(data["can_read"])
		var/list/complaints = list()
		for(var/i in length(GLOB.aq_complaints) to 1 step -1)
			complaints += list(GLOB.aq_complaints[i])
		data["complaints"] = complaints
	return data

/obj/machinery/complaint_box/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "print" || !can_read(usr) || (machine_stat & (NOPOWER|BROKEN)))
		return FALSE
	var/number = text2num("[params["number"]]")
	for(var/list/complaint as anything in GLOB.aq_complaints)
		if(complaint["number"] != number)
			continue
		var/obj/item/paper/copy = new(drop_location())
		copy.name = "skarga nr [number] – [complaint["title"]]"
		copy.add_raw_text("<h2>Skarga nr [number]: [complaint["title"]]</h2><i>Wpłynęła: [complaint["time"]]</i><hr>[complaint["text"]]")
		copy.update_appearance()
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		return TRUE
	return FALSE

/obj/machinery/complaint_box/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz odkręcać [name]...</span>")
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		new /obj/item/wallframe/complaint_box(drop_location())
		qdel(src)
	return TRUE

/obj/item/wallframe/complaint_box
	name = "rama skrzynki skarg"
	desc = "Skrzynka skarg do zawieszenia na ścianie."
	icon = 'aquila/icons/obj/security/complaint_box.dmi'
	icon_state = "complaintbox0"
	custom_materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	result_path = /obj/machinery/complaint_box
	pixel_shift = -28

/datum/design/complaint_box_frame
	name = "Rama skrzynki skarg"
	id = "complaint_box_frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	build_path = /obj/item/wallframe/complaint_box
	category = list("initial", "Construction")

#undef COMPLAINT_ANNOUNCE_COOLDOWN
