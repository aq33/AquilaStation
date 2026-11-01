#define AREA_ERRNONE 0
#define AREA_STATION 1
#define AREA_SPACE 2
#define AREA_SPECIAL 3

#define LEGEND_VIEWING_LIST "watching_list"
#define LEGEND_OFF "off"

/obj/item/areaeditor
	name = "przedmiot do modyfikacji obszarów"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	attack_verb = list("atakuje", "pacnięciem trąca", "uderza")
	var/fluffnotice = "Nikt nie będzie tego czytał!"
	var/in_use = FALSE

/obj/item/areaeditor/attack_self(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/areaeditor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Blueprints", name)
		ui.open()

/obj/item/areaeditor/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/areaeditor/ui_data(mob/user)
	var/list/data = list()
	switch(get_area_type(get_area(user)))
		if(AREA_SPACE)
			data["area_notice"] = "Według [src.name] jesteś teraz na niczyim terenie."
		if(AREA_SPECIAL)
			data["area_notice"] = "Tego miejsca nie ma na [src.name]."
	data["legend"] = LEGEND_OFF
	data["viewing"] = FALSE
	data["wire_data"] = list()
	return data

/obj/item/areaeditor/ui_static_data(mob/user)
	var/list/data = list()
	data["legend_viewing_list"] = LEGEND_VIEWING_LIST
	data["legend_off"] = LEGEND_OFF
	data["fluff_notice"] = fluffnotice
	data["station_name"] = station_name()
	data["item_name"] = name
	data["blueprints"] = FALSE
	data["wire_devices"] = list()
	return data

/obj/item/areaeditor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!usr.canUseTopic(src))
		return TRUE
	switch(action)
		if("create_area")
			if(in_use)
				return
			in_use = TRUE
			create_area(usr)
			in_use = FALSE
			return TRUE

//Station blueprints!!!
/obj/item/areaeditor/blueprints
	name = "plany stacji"
	desc = "Plany stacji. Widnieje na nich pieczątka „Ściśle tajne” i kilka plam po kawie."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	fluffnotice = "Własność Nanotrasen. Tylko dla szefów działów. Przechowywać w ściśle strzeżonym miejscu."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/list/image/showing = list()
	var/client/viewing
	var/legend = LEGEND_OFF	//Viewing the wire legend: LEGEND_OFF, LEGEND_VIEWING_LIST or a wireset
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/areaeditor/blueprints/Destroy()
	clear_viewer()
	return ..()


/obj/item/areaeditor/blueprints/ui_data(mob/user)
	var/list/data = ..()
	if(get_area_type(get_area(user)) == AREA_STATION)
		var/area/A = get_area(user)
		data["area_notice"] = "Według [src] jesteś teraz w „[A.name]”."
		data["area_name"] = A.name
		data["can_edit_area"] = TRUE
	data["legend"] = legend
	data["viewing"] = !!viewing
	if(legend != LEGEND_VIEWING_LIST && legend != LEGEND_OFF)
		for(var/device in GLOB.wire_color_directory)
			if("[device]" != legend) //for some reason you can't use wireset directly as a derefencer so this is the next best :/
				continue
			data["wires_name"] = GLOB.wire_name_directory[device]
			for(var/individual_color in GLOB.wire_color_directory[device])
				var/wire_name = GLOB.wire_color_directory[device][individual_color]
				if(findtext(wire_name, WIRE_DUD_PREFIX)) //don't show duds
					continue
				data["wire_data"] += list(list(
					"color" = individual_color,
					"message" = wire_name,
				))
	return data

/obj/item/areaeditor/blueprints/ui_static_data(mob/user)
	var/list/data = ..()
	data["blueprints"] = TRUE
	for(var/wireset in GLOB.wire_color_directory)
		data["wire_devices"] += list(list(
			"name" = GLOB.wire_name_directory[wireset],
			"ref" = "[wireset]",
		))
	return data

/obj/item/areaeditor/blueprints/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("edit_area")
			if(get_area_type() != AREA_STATION)
				return
			if(in_use)
				return
			in_use = TRUE
			edit_area()
			in_use = FALSE
			return TRUE
		if("exit_legend")
			legend = LEGEND_OFF
			return TRUE
		if("view_legend")
			legend = LEGEND_VIEWING_LIST
			return TRUE
		if("view_wireset")
			var/setting_wireset = params["view_wireset"]
			for(var/device in GLOB.wire_color_directory)
				if("[device]" == setting_wireset) //I know... don't change it...
					legend = setting_wireset
					return TRUE
		if("view_blueprints")
			set_viewer(usr, "<span class='notice'>Odwracasz plany, by zobaczyć złożony diagram informacyjny.</span>")
			return TRUE
		if("hide_blueprints")
			clear_viewer(usr,"<span class='notice'>Odwracasz plany, by zobaczyć prosty diagram informacyjny.</span>")
			return TRUE
		if("refresh")
			clear_viewer(usr)
			set_viewer(usr)
			return TRUE

/obj/item/areaeditor/blueprints/proc/get_images(turf/T, viewsize)
	. = list()
	for(var/turf/TT in range(viewsize, T))
		if(TT.blueprint_data)
			. += TT.blueprint_data

/obj/item/areaeditor/blueprints/proc/set_viewer(mob/user, message = "")
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(user), viewing.view)
		viewing.images |= showing
		if(message)
			to_chat(user, message)

/obj/item/areaeditor/blueprints/proc/clear_viewer(mob/user, message = "")
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()
	if(message)
		to_chat(user, message)

/obj/item/areaeditor/blueprints/dropped(mob/user)
	..()
	clear_viewer()
	legend = LEGEND_OFF


/obj/item/areaeditor/proc/get_area_type(area/A)
	if (!A)
		A = get_area(usr)
	if(A.outdoors)
		return AREA_SPACE
	var/list/SPECIALS = list(
		/area/shuttle,
		/area/centcom,
		/area/asteroid,
		/area/tdome,
		/area/wizard_station,
		/area/hilbertshotel,
		/area/hilbertshotelstorage
	)
	for (var/type in SPECIALS)
		if ( istype(A,type) )
			return AREA_SPECIAL
	return AREA_STATION

/obj/item/areaeditor/proc/edit_area()
	var/area/A = get_area(usr)
	var/prevname = "[A.name]"
	var/str = stripped_input(usr,"Nowa nazwa obszaru:", "Tworzenie obszaru", "", MAX_NAME_LEN)
	if(!str || !length(str) || str==prevname) //cancel
		return
	if(length(str) > 50)
		to_chat(usr, "<span class='warning'>Podana nazwa jest za długa. Nazwa obszaru pozostaje bez zmian.</span>")
		return

	rename_area(A, str)

	to_chat(usr, "<span class='notice'>Zmieniasz nazwę „[prevname]” na „[str]”.</span>")
	log_game("[key_name(usr)] has renamed [prevname] to [str]")
	A.update_areasize()
	return TRUE

//Blueprint Subtypes

/obj/item/areaeditor/blueprints/cyborg
	name = "schematy stacji"
	desc = "Cyfrowa kopia planów stacji zapisana w twojej pamięci."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	fluffnotice = "Własność intelektualna Nanotrasen. Tylko do użytku przez cyborgi inżynieryjne. Wymazać z pamięci po opuszczeniu stacji."
	investigate_flags = NONE

/proc/rename_area(a, new_name)
	var/area/A = get_area(a)
	var/prevname = "[A.name]"
	set_area_machinery_title(A, new_name, prevname)
	A.name = new_name
	if(A.firedoors)
		for(var/D in A.firedoors)
			var/obj/machinery/door/firedoor/FD = D
			FD.CalculateAffectingAreas()
	A.update_areasize()
	return TRUE


/proc/set_area_machinery_title(area/A, title, oldtitle)
	if(!oldtitle) // or replacetext goes to infinite loop
		return
	for(var/obj/machinery/airalarm/M in A)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/power/apc/M in A)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/M in A)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/M in A)
		M.name = replacetext(M.name,oldtitle,title)
	for(var/obj/machinery/door/M in A)
		M.name = replacetext(M.name,oldtitle,title)
	//TODO: much much more. Unnamed airlocks, cameras, etc.
