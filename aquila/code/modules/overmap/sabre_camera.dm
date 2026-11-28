// AQUILA - kamera pokładowa Sabre: każdy Sabre nadaje obraz z wnętrza do Spess.tv i telewizorów rozrywkowych przez całą rundę,
// nie tylko przy lądowaniu (to robi dalej kamera lądowiska, planet_landing_broadcast.dm). Sieć Sabre jest stałym kanałem
// jak Thunderdome (spesstv.dm, telescreen.dm), więc nie zapala ekranów jako „na żywo”. Bez mikrofonu, żeby rozmowy
// w kokpicie nie leciały z głośników na całym okręcie. Kamera stoi niewidzialna na środku wnętrza i leci razem z promem.

/obj/docking_port/mobile/sabre
	/// Kamera pokładowa nadająca do Spess.tv
	var/obj/machinery/camera/sabre_onboard/onboard_camera

/obj/docking_port/mobile/sabre/register()
	. = ..()
	if(onboard_camera)
		return
	var/turf/center = sabre_center_turf()
	if(!center)
		return
	onboard_camera = new(center)
	onboard_camera.c_tag = unique_broadcast_tag("Kamera pokładowa: [craft?.name || name]", onboard_camera)
	RegisterSignal(onboard_camera, COMSIG_PARENT_QDELETING, PROC_REF(onboard_camera_deleted))

/obj/docking_port/mobile/sabre/Destroy(force)
	if(onboard_camera)
		UnregisterSignal(onboard_camera, COMSIG_PARENT_QDELETING)
		QDEL_NULL(onboard_camera)
	return ..()

/// Kamera pojechała z promem: sieć kamer musi przeliczyć, co widać z nowego miejsca
/obj/docking_port/mobile/sabre/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force = FALSE)
	. = ..()
	if(onboard_camera)
		GLOB.cameranet.updatePortableCamera(onboard_camera)

/obj/docking_port/mobile/sabre/proc/onboard_camera_deleted(datum/source)
	SIGNAL_HANDLER
	onboard_camera = null

/// Środek wnętrza promu (z obrysu jego pól)
/obj/docking_port/mobile/sabre/proc/sabre_center_turf()
	var/list/turfs = return_turfs()
	if(!length(turfs))
		return
	var/min_x = INFINITY
	var/max_x = 0
	var/min_y = INFINITY
	var/max_y = 0
	for(var/turf/T as anything in turfs)
		min_x = min(min_x, T.x)
		max_x = max(max_x, T.x)
		min_y = min(min_y, T.y)
		max_y = max(max_y, T.y)
	return locate(round((min_x + max_x) / 2), round((min_y + max_y) / 2), z)

/// Kamera pokładowa Sabre: niewidzialna, nie do zniszczenia, bez światła i zasilania
/obj/machinery/camera/sabre_onboard
	name = "kamera pokładowa"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	internal_light = FALSE
	network = list(CAMERANET_NETWORK_SABRE)
	use_power = NO_POWER_USE
	start_active = TRUE
