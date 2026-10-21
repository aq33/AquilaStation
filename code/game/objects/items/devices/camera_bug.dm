
#define BUGMODE_LIST	0
#define BUGMODE_MONITOR	1
#define BUGMODE_TRACK	2



/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	w_class		= WEIGHT_CLASS_TINY
	item_state	= "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	item_flags = NOBLUDGEON

	var/obj/machinery/camera/current = null

	var/last_net_update = 0
	var/list/bugged_cameras = list()

	var/track_mode = BUGMODE_LIST
	var/last_tracked = 0
	var/refresh_interval = 50

	var/tracked_name = null
	var/atom/tracking = null

	var/last_found = null
	var/last_seen = null

/obj/item/camera_bug/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/camera_bug/Destroy()
	get_cameras()
	for(var/cam_tag in bugged_cameras)
		var/datum/weakref/camera_ref = bugged_cameras[cam_tag]
		var/obj/machinery/camera/camera = camera_ref.resolve()
		if(camera && camera.bug == src)
			camera.bug = null
	bugged_cameras = list()
	if(tracking)
		tracking = null
	return ..()

/obj/item/camera_bug/interact(mob/user)
	ui_interact(user)

/obj/item/camera_bug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CameraBug", name)
		ui.open()

/obj/item/camera_bug/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/camera_bug/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/camera_bug/check_eye(mob/user)
	if ( loc != user || user.incapacitated() || user.eye_blind || !current )
		user.unset_machine()
		return 0
	var/turf/T_user = get_turf(user.loc)
	var/turf/T_current = get_turf(current)
	if(T_user.get_virtual_z_level() != T_current.get_virtual_z_level() || !current.can_use())
		to_chat(user, "<span class='danger'>[src] traci sygnał.</span>")
		current = null
		user.unset_machine()
		return 0
	return 1
/obj/item/camera_bug/on_unset_machine(mob/user)
	user.reset_perspective(null)

/obj/item/camera_bug/proc/get_cameras()
	if( world.time > (last_net_update + 100))
		bugged_cameras = list()
		for(var/obj/machinery/camera/camera in GLOB.cameranet.cameras)
			if(camera.machine_stat || !camera.can_use())
				continue
			if(length(list("ss13","mine", "rd", "labor", "toxins", "minisat") & camera.network))
				var/datum/weakref/camera_ref = WEAKREF(camera)
				if(!camera_ref || !camera.c_tag)
					continue
				bugged_cameras[camera.c_tag] = camera_ref
	return sortList(bugged_cameras)


/obj/item/camera_bug/ui_data(mob/user)
	var/list/data = list()
	var/list/cameras = get_cameras()
	if(track_mode == BUGMODE_MONITOR && !current)
		track_mode = BUGMODE_LIST
	if(track_mode == BUGMODE_TRACK && !tracking)
		track_mode = BUGMODE_LIST
	data["mode"] = track_mode
	data["viewing"] = !!current
	var/list/camera_list = list()
	for(var/entry in cameras)
		var/datum/weakref/camera_ref = cameras[entry]
		var/obj/machinery/camera/camera = camera_ref.resolve()
		if(!camera)
			continue
		camera_list += list(list(
			"name" = entry,
			"ref" = REF(camera_ref),
			"bugged" = camera.bug == src,
		))
	data["cameras"] = camera_list
	switch(track_mode)
		if(BUGMODE_MONITOR)
			data["current_name"] = current.c_tag
			data["camera_active"] = !!current.can_use()
			data["seen"] = camera_report()
		if(BUGMODE_TRACK)
			data["tracked_name"] = tracked_name
			if(last_found)
				data["last_found"] = last_found
				var/datum/weakref/camera_ref = bugged_cameras[last_found]
				var/obj/machinery/camera/camera = camera_ref?.resolve()
				if(camera)
					data["last_found_ref"] = REF(camera_ref)
					data["last_found_bugged"] = camera.bug == src
				var/time_diff = round((world.time - last_seen) / 150)
				if(!time_diff)
					data["last_seen"] = "teraz"
				else
					// 15 second intervals ~ 1/4 minute
					var/m = round(time_diff/4)
					var/s = (time_diff - 4*m) * 15
					if(!s)
						s = "00"
					data["last_seen"] = "[m]:[s] min temu"
	return data

/obj/item/camera_bug/proc/get_seens()
	if(current && current.can_use())
		var/list/seen = current.can_see()
		return seen

/// Lista tego, co widzi monitorowana kamera: nazwa, dopisek i ref do śledzenia
/obj/item/camera_bug/proc/camera_report()
	// this should only be called if current exists
	var/list/report = list()
	var/list/seen = get_seens()
	if(!length(seen))
		return report
	var/list/names = list()
	for(var/obj/anomaly/singularity/S in seen) // god help you if you see more than one
		names[S.name]++
		var/stage = round(S.current_size / 2)+1
		report += list(list(
			"name" = names[S.name] > 1 ? "[S.name] ([names[S.name]])" : S.name,
			"extra" = "Stage [stage]",
			"ref" = REF(S),
		))
	for(var/obj/mecha/M in seen)
		names[M.name]++
		report += list(list(
			"name" = names[M.name] > 1 ? "[M.name] ([names[M.name]])" : M.name,
			"ref" = REF(M),
		))
	for(var/mob/living/M in seen)
		names[M.name]++
		var/extra
		if(!(M.mobility_flags & MOBILITY_STAND))
			extra = M.buckled ? "Siedzi" : "Leży"
		report += list(list(
			"name" = names[M.name] > 1 ? "[M.name] ([names[M.name]])" : M.name,
			"extra" = extra,
			"ref" = REF(M),
		))
	return report

/obj/item/camera_bug/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	switch(action)
		if("mode")
			track_mode = text2num(params["mode"])
			return TRUE
		if("monitor")
			//You can't locate on a list with keys
			var/list/cameras = flatten_list(bugged_cameras)
			var/datum/weakref/camera_ref = locate(params["ref"]) in cameras
			var/obj/machinery/camera/camera = camera_ref?.resolve()
			if(camera && istype(camera))
				if(!same_z_level(camera))
					return
				track_mode = BUGMODE_MONITOR
				current = camera
				usr.reset_perspective(null)
			return TRUE
		if("track")
			var/list/seen = get_seens()
			if(length(seen))
				var/atom/A = locate(params["ref"]) in seen
				if(A && istype(A))
					tracking = A
					tracked_name = A.name
					last_found = current.c_tag
					last_seen = world.time
					track_mode = BUGMODE_TRACK
			return TRUE
		if("emp")
			//You can't locate on a list with keys
			var/list/cameras = flatten_list(bugged_cameras)
			var/datum/weakref/camera_ref = locate(params["ref"]) in cameras
			var/obj/machinery/camera/camera = camera_ref?.resolve()
			if(camera && istype(camera) && camera.bug == src)
				if(!same_z_level(camera))
					return
				camera.emp_act(EMP_HEAVY)
				camera.bug = null
				bugged_cameras -= camera.c_tag
			return TRUE
		if("view")
			if(!params["ref"]) // Wyłącz podgląd kamery
				usr.unset_machine()
				return TRUE
			//You can't locate on a list with keys
			var/list/cameras = flatten_list(bugged_cameras)
			var/datum/weakref/camera_ref = locate(params["ref"]) in cameras
			var/obj/machinery/camera/camera = camera_ref?.resolve()
			if(!camera || !istype(camera))
				usr.unset_machine()
				return TRUE
			if(!same_z_level(camera))
				return
			if(!camera.can_use())
				to_chat(usr, "<span class='warning'>Coś jest nie tak z tą kamerą! Nie możesz odebrać obrazu.</span>")
				return
			current = camera
			var/mob/viewer = usr
			spawn(6)
				if(check_eye(viewer))
					viewer.reset_perspective(camera)
				else
					viewer.unset_machine()
			return TRUE

/obj/item/camera_bug/process()
	if(track_mode == BUGMODE_LIST || (world.time < (last_tracked + refresh_interval)))
		return
	last_tracked = world.time
	if(track_mode == BUGMODE_TRACK ) // search for user
		// Note that it will be tricked if your name appears to change.
		// This is not optimal but it is better than tracking you relentlessly despite everything.
		if(!tracking)
			return

		if(tracking.name != tracked_name) // Hiding their identity, tricksy
			var/mob/M = tracking
			if(istype(M))
				if(!(tracked_name == "Unknown" && findtext(tracking.name,"Unknown"))) // we saw then disguised before
					if(!(tracked_name == M.real_name && findtext(tracking.name,M.real_name))) // or they're still ID'd
						return // you won't find em on the cameras
			else
				return

		var/list/tracking_cams = list()
		var/list/b_cams = get_cameras()
		for(var/entry in b_cams)
			tracking_cams += b_cams[entry]
		var/list/target_region = view(tracking)

		for(var/obj/machinery/camera/C in (target_region & tracking_cams))
			if(!can_see(C,tracking)) // target may have xray, that doesn't make them visible to cameras
				continue
			if(C.can_use())
				last_found = C.c_tag
				last_seen = world.time
				break

/obj/item/camera_bug/proc/same_z_level(var/obj/machinery/camera/C)
	var/turf/T_cam = get_turf(C)
	var/turf/T_bug = get_turf(loc)
	if(!T_bug || T_cam.get_virtual_z_level() != T_bug.get_virtual_z_level())
		to_chat(usr, "<span class='warning'>Nie możesz złapać sygnału!</span>")
		return FALSE
	return TRUE

#undef BUGMODE_LIST
#undef BUGMODE_MONITOR
#undef BUGMODE_TRACK
