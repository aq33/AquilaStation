#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "konsola kamer ochrony"
	desc = "Daje dostęp do różnych kamer na stacji."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	circuit = /obj/item/circuitboard/computer/security
	light_color = LIGHT_COLOR_RED



	var/list/network = list("ss13")
	var/obj/machinery/camera/active_camera
	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()
	var/long_ranged = FALSE

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/atom/movable/screen/plane_master/o_light_visual/visual_plane_master
	var/atom/movable/screen/background/cam_background

/obj/machinery/computer/security/Initialize(mapload)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	map_name = "camera_console_[REF(src)]_map"
	// Convert networks to lowercase
	for(var/i in network)
		network -= i
		network += lowertext(i)
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/instance = new plane()
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	visual_plane_master = new
	visual_plane_master.name = "plane_master"
	visual_plane_master.assigned_map = map_name
	visual_plane_master.del_on_map_removal = FALSE
	visual_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/security/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(visual_plane_master)
	QDEL_NULL(cam_background)
	return ..()

/obj/machinery/computer/security/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	for(var/i in network)
		network -= i
		network += "[idnum][i]"


/obj/machinery/computer/security/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/security/ui_interact(mob/user, datum/tgui/ui)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	// Update the camera, showing static if necessary and updating data if the location has moved.
	update_active_camera_screen()

	if(!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', 25, FALSE)
			use_power(active_power_usage)
		// Register map objects
		user.client.register_map_obj(cam_screen)
		for(var/plane in cam_plane_masters)
			user.client.register_map_obj(plane)
		user.client.register_map_obj(visual_plane_master)
		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole")
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/computer/security/ui_data()
	var/list/data = list()
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			ref = REF(active_camera),
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/ui_static_data()
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
			ref = REF(C),
		))
	return data

/obj/machinery/computer/security/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/list/cameras = get_available_cameras()
		var/obj/machinery/camera/C
		// AQUILA: okno z tg wybiera kamerę po REF, stare wywołania po c_tag
		if(params["camera"])
			var/obj/machinery/camera/located = locate(params["camera"])
			if(istype(located) && cameras["[located.c_tag]"] == located)
				C = located
		else
			C = cameras[params["name"]]
		active_camera = C
		ui_update()
		playsound(src, get_sfx("terminal_type"), 25, FALSE)

		if(!C)
			return TRUE

		update_active_camera_screen()

		return TRUE

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(!active_camera?.can_use())
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// Is this camera located in or attached to a living thing? If so, assume the camera's loc is the living thing.
	var/atom/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = get_turf(cam_location)

	if(active_camera.isXRay(TRUE))	//ignore_malf_upgrades = TRUE
		visible_turfs += RANGE_TURFS(active_camera.view_range, cam_location)
	else
		for(var/turf/T in view(active_camera.view_range, cam_location))
			visible_turfs += T

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/security/ui_close(mob/user, datum/tgui/tgui)
	var/user_ref = REF(user)
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	user.client.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		playsound(src, 'sound/machines/terminal_off.ogg', 25, FALSE)
		use_power(0)

/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	var/list/L = list()
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		if((is_away_level(z) || is_away_level(C.z)) && (C.get_virtual_z_level() != get_virtual_z_level()))//if on away mission, can only receive feed from same z_level cameras
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list camera network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D

// SECURITY MONITORS

/obj/machinery/computer/security/wooden_tv
	name = "monitor kamer ochrony"
	desc = "Stary telewizor podłączony do sieci kamer stacji."
	icon_state = "television"
	icon_keyboard = "no_keyboard"
	icon_screen = "detective_tv"
	clockwork = TRUE //it'd look weird
	broken_overlay_emissive = TRUE
	pass_flags = PASSTABLE

/obj/machinery/computer/security/mining
	name = "konsola kamer placówki"
	desc = "Daje dostęp do różnych kamer w placówce."
	icon_screen = "mining"
	icon_keyboard = "mining_key"
	network = list("mine", "auxbase")
	circuit = /obj/item/circuitboard/computer/mining

/obj/machinery/computer/security/research
	name = "konsola kamer działu naukowego"
	desc = "Daje dostęp do różnych kamer w dziale naukowym."
	network = list("rd")
	circuit = /obj/item/circuitboard/computer/research

/obj/machinery/computer/security/hos
	name = "\improper konsola kamer Komendanta"
	desc = "Specjalna konsola ochrony z dodatkowym dostępem do sieci obozu pracy."
	network = list("ss13", "labor", "headcam") //NSV13 added helmet cams
	circuit = null

/obj/machinery/computer/security/labor
	name = "monitoring obozu pracy"
	desc = "Daje dostęp do różnych kamer w obozie pracy."
	network = list("labor")
	circuit = null

/obj/machinery/computer/security/qm
	name = "\improper konsola kamer Kwatermistrza"
	desc = "Konsola z dostępem do sieci kamer górnictwa, bazy pomocniczej i skarbca."
	network = list("mine", "auxbase", "vault")
	circuit = null

// TELESCREENS

/obj/machinery/computer/security/telescreen
	name = "\improper teleekran"
	desc = "Służy do oglądania pustej areny."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	layer = SIGN_LAYER
	network = list("thunder")
	density = FALSE
	circuit = null
	clockwork = TRUE //it'd look very weird
	broken_overlay_emissive = TRUE
	light_power = 0

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "monitor rozrywkowy"
	desc = "Kurde, oby był na tym kanał beestation."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment_blank"
	network = list("thunder")
	density = FALSE
	circuit = null
	long_ranged = TRUE
	var/icon_state_off = "entertainment_blank"
	var/icon_state_on = "entertainment"

//Can use this telescreen at long range.
/obj/machinery/computer/security/telescreen/entertainment/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/security/telescreen/entertainment/examine(mob/user)
	. = ..()
	interact(usr)

/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on)
	if(on && icon_state == icon_state_off)
		say(pick(
			"Pokazy odwagi na żywo w Thunderdome!",
			"Dwóch wchodzi, jeden wychodzi! Oglądajcie teraz!",
			"Przemoc, jakiej jeszcze nie widzieliście!",
			"Włócznie! Kamera! Akcja! NA ŻYWO!"))
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/computer/security/telescreen/rd
	name = "\improper teleekran Dyrektora Naukowego"
	desc = "Służy do obserwowania SI i pachołków Dyrektora Naukowego z bezpiecznego gabinetu."
	network = list("rd", "aicore", "aiupload", "minisat", "xeno", "test")

/obj/machinery/computer/security/telescreen/research
	name = "teleekran działu naukowego"
	desc = "Teleekran z dostępem do sieci kamer działu naukowego."
	network = list("rd")

/obj/machinery/computer/security/telescreen/ce
	name = "\improper teleekran Głównego Inżyniera"
	desc = "Służy do obserwowania silnika, telekomunikacji i minisatelity."
	network = list("engine", "singularity", "tcomms", "minisat")

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper teleekran Ordynatora"
	desc = "Teleekran z dostępem do sieci kamer ambulatorium."
	network = list("medbay")

/obj/machinery/computer/security/telescreen/vault
	name = "monitor skarbca"
	desc = "Teleekran podłączony do sieci kamer skarbca."
	network = list("vault")

/obj/machinery/computer/security/telescreen/toxins
	name = "monitor poligonu bombowego"
	desc = "Teleekran podłączony do kamery poligonu bombowego."
	network = list("toxins")

/obj/machinery/computer/security/telescreen/engine
	name = "monitor silnika"
	desc = "Teleekran podłączony do sieci kamer silnika."
	network = list("engine")

/obj/machinery/computer/security/telescreen/turbine
	name = "monitor turbiny"
	desc = "Teleekran podłączony do kamery turbiny."
	network = list("turbine")

/obj/machinery/computer/security/telescreen/interrogation
	name = "monitor pokoju przesłuchań"
	desc = "Teleekran podłączony do kamery pokoju przesłuchań."
	network = list("interrogation")

/obj/machinery/computer/security/telescreen/prison
	name = "monitor więzienia"
	desc = "Teleekran podłączony do sieci kamer więzienia."
	network = list("prison")

/obj/machinery/computer/security/telescreen/auxbase
	name = "monitor bazy pomocniczej"
	desc = "Teleekran podłączony do kamery bazy pomocniczej."
	network = list("auxbase")

/obj/machinery/computer/security/telescreen/minisat
	name = "monitor minisatelity"
	desc = "Teleekran podłączony do sieci kamer minisatelity."
	network = list("minisat")

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper monitor przesyłania praw SI"
	desc = "Teleekran podłączony do sieci kamer Komory Programowania SI."
	network = list("aiupload")

//Nsv13 - ATC telescreen
/obj/machinery/computer/security/telescreen/atc
	name = "\improper teleekran Kontroli Lotów"
	desc = "Służy do monitorowania stanowisk startowych z wieży Kontroli Lotów."
	network = list("hangar")

#undef DEFAULT_MAP_SIZE
