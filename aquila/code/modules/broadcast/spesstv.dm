// AQUILA: program Spess.tv na PDA (port Monkestation spesstv.dm). Okno to zwykłe NtosSecurEye.

#define STREAM_ALERT_COOLDOWN (5 SECONDS)

/datum/computer_file/program/secureye/spesstv
	filename = "spesstv"
	filedesc = "Spess.tv"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "Ten program pozwala oglądać publiczne transmisje na żywo."
	requires_ntnet = FALSE
	transfer_access = list()
	usage_flags = PROGRAM_ALL
	size = 0
	program_icon = "video"
	alert_able = TRUE
	network = list(CAMERANET_NETWORK_THUNDERDOME)
	/// Głośnik kanału rozrywkowego, istnieje, gdy program działa
	var/obj/item/radio/entertainment/speakers/pda/radio
	/// Odstęp między powiadomieniami o transmisjach
	COOLDOWN_DECLARE(alert_cooldown)

/datum/computer_file/program/secureye/spesstv/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, PROC_REF(on_network_broadcast_updated))

/datum/computer_file/program/secureye/spesstv/Destroy()
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	UnregisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED)
	QDEL_NULL(radio)
	return ..()

/datum/computer_file/program/secureye/spesstv/clone()
	var/datum/computer_file/program/secureye/spesstv/temp = ..()
	temp.network = network.Copy()
	return temp

/datum/computer_file/program/secureye/spesstv/on_start(mob/living/user)
	. = ..()
	if(. && QDELETED(radio) && !QDELETED(computer))
		radio = new(computer)

/datum/computer_file/program/secureye/spesstv/kill_program(forced)
	. = ..()
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	QDEL_NULL(radio)

/datum/computer_file/program/secureye/spesstv/on_exit(mob/user)
	. = ..()
	if(!active_camera)
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/datum/computer_file/program/secureye/spesstv/update_active_camera_screen()
	. = ..()
	update_spesstv_watcher_list(REF(src), active_camera)

/// PDA odświeża okno co tick, więc przy okazji nadążamy za ruchomą kamerą
/datum/computer_file/program/secureye/spesstv/ui_data(mob/user)
	update_active_camera_screen()
	return ..()

/// Transmisje lecą też z domen bitrunnerów, więc nie ograniczamy się do poziomów stacji
/datum/computer_file/program/secureye/spesstv/get_available_cameras()
	var/list/camlist = list()
	for(var/obj/machinery/camera/cam as anything in GLOB.cameranet.cameras)
		if(!islist(cam.network))
			continue
		var/list/tempnetwork = cam.network & network
		if(length(tempnetwork))
			camlist["[cam.c_tag]"] = cam
	return camlist

/datum/computer_file/program/secureye/spesstv/proc/on_network_broadcast_updated(datum/source, tv_show_id, is_show_active, announcement)
	SIGNAL_HANDLER
	if(is_show_active)
		network |= tv_show_id
		alert_pending = TRUE
	else
		network -= tv_show_id
		network |= CAMERANET_NETWORK_THUNDERDOME
		if(length(network) <= 1)
			alert_pending = FALSE
	if(QDELETED(computer))
		return
	if(announcement && is_show_active && COOLDOWN_FINISHED(src, alert_cooldown))
		INVOKE_ASYNC(computer, TYPE_PROC_REF(/obj/item/modular_computer, alert_call), src, announcement)
		COOLDOWN_START(src, alert_cooldown, STREAM_ALERT_COOLDOWN)
	INVOKE_ASYNC(src, PROC_REF(refresh_viewers))

/// Wysyła nową listę kamer do otwartego okna PDA
/datum/computer_file/program/secureye/spesstv/proc/refresh_viewers()
	if(QDELETED(computer) || computer.active_program != src)
		return
	for(var/datum/tgui/ui as anything in SStgui.get_all_open_uis(computer))
		ui.send_full_update()

/// Spess.tv jest na każdym nowym PDA
/obj/item/computer_hardware/hard_drive/small/pda/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/secureye/spesstv(src))

#undef STREAM_ALERT_COOLDOWN
