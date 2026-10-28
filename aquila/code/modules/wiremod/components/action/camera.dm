// Aparat polaroid jako obudowa circuitu (tg code/modules/photography/camera/camera.dm
// i code/modules/wiremod/components/action/camera.dm, bez części mod_program).
// U tg w obudowie siedzi też remotecam/polaroid, u nas nie ma komponentu remotecam, więc go pomijamy.

/obj/item/camera/Initialize(mapload)
	. = ..()
	// Aparaty SI i borgów to ich wbudowane narzędzie, nie robimy z nich obudów
	if(istype(src, /obj/item/camera/siliconcam))
		return
	AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/camera), SHELL_CAPACITY_SMALL)

/obj/item/camera/captureimage(atom/target, mob/user, flag, size_x = 1, size_y = 1)
	. = ..()
	if(. == FALSE)
		return
	SEND_SIGNAL(src, COMSIG_CAMERA_IMAGE_CAPTURED, target, user)

/// Zdjęcie bez gracza ląduje na podłodze pod aparatem (u nas printpicture zakłada, że ktoś trzyma aparat).
/obj/item/camera/printpicture(mob/user, datum/picture/picture)
	if(user)
		return ..()
	if(!pictures_left)
		return
	var/obj/item/photo/new_photo = new(get_turf(src), picture)
	pictures_left--
	if(default_picture_name)
		picture.picture_name = default_picture_name
	new_photo.set_picture(picture, TRUE, TRUE)
	if(CONFIG_GET(flag/picture_logging_camera))
		picture.log_to_file()

/**
 * Robi zdjęcie celu bez klikania (odpowiednik attempt_picture z tg).
 * Sprawdza tylko ładowanie flesza, trwające zdjęcie i kliszę.
 */
/obj/item/camera/proc/attempt_picture(atom/target, mob/user)
	if(!on || blending || !pictures_left)
		return FALSE
	if(!get_turf(target))
		return FALSE
	on = FALSE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), cooldown)
	icon_state = state_off
	INVOKE_ASYNC(src, PROC_REF(captureimage), target, user, FALSE, picture_size_x - 1, picture_size_y - 1)
	return TRUE

/**
 * Ustawia rozmiar zdjęcia bez pytania gracza (odpowiednik adjust_zoom z tg z podanymi wymiarami).
 * Nasz adjust_zoom(user) zawsze pyta gracza, więc to osobny proc.
 */
/obj/item/camera/proc/set_zoom(desired_x, desired_y)
	if(isnum(desired_x) && desired_x)
		picture_size_x = min(clamp(round(desired_x), picture_size_x_min, picture_size_x_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	if(isnum(desired_y) && desired_y)
		picture_size_y = min(clamp(round(desired_y), picture_size_y_min, picture_size_y_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)

/obj/item/circuit_component/camera
	display_name = "Camera"
	desc = "Aparat polaroid, który robi zdjęcie po wyzwoleniu. Współrzędne zdjęcia są liczone względem położenia aparatu."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The atom that was photographed from either user click or trigger input.
	var/datum/port/output/photographed_atom
	/// The item that was added/removed.
	var/datum/port/output/picture_taken
	/// If set, the trigger input will target this atom.
	var/datum/port/input/picture_target
	/// If the above is unset, these coordinates will be used.
	var/datum/port/input/picture_coord_x
	var/datum/port/input/picture_coord_y
	/// Adjusts the picture_size_x variable of the camera.
	var/datum/port/input/adjust_size_x
	/// Idem but for picture_size_y.
	var/datum/port/input/adjust_size_y

	/// The camera this circut is attached to.
	var/obj/item/camera/camera

/obj/item/circuit_component/camera/populate_ports()
	picture_taken = add_output_port("Picture Taken", PORT_TYPE_SIGNAL)
	photographed_atom = add_output_port("Photographed Entity", PORT_TYPE_ATOM)

	picture_target = add_input_port("Picture Target", PORT_TYPE_ATOM)
	picture_coord_x = add_input_port("Picture Coordinate X", PORT_TYPE_NUMBER)
	picture_coord_y = add_input_port("Picture Coordinate Y", PORT_TYPE_NUMBER)
	adjust_size_x = add_input_port("Picture Size X", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))
	adjust_size_y = add_input_port("Picture Size Y", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))

/obj/item/circuit_component/camera/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/item/camera))
		return
	camera = shell
	RegisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/camera/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED)
	camera = null
	return ..()

///Adjuts the zoom of the camera
/obj/item/circuit_component/camera/proc/sanitize_picture_size()
	CIRCUIT_TRIGGER
	camera?.set_zoom(adjust_size_x.value, adjust_size_y.value)

/obj/item/circuit_component/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed_atom.set_output(target)
	picture_taken.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/camera/input_received(datum/port/input/port)
	if(!camera)
		return
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		if(!our_turf)
			return
		target = locate(our_turf.x + picture_coord_x.value, our_turf.y + picture_coord_y.value, our_turf.z)
		if(!target)
			return
	// Bez tego układ dostawałby zdjęcia z drugiego końca stacji przez port z bytem
	var/turf/target_turf = get_turf(target)
	var/turf/camera_turf = get_location()
	if(!target_turf || !camera_turf || target_turf.z != camera_turf.z || get_dist(target_turf, camera_turf) > CAMERA_CIRCUIT_MAX_RANGE)
		return
	camera.attempt_picture(target)
