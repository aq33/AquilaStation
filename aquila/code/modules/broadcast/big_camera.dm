// AQUILA: duża kamera stacjonarna (port Monkestation bigcamera.dm)

/obj/machinery/big_broadcast_camera
	name = "big broadcast camera"
	desc = "Bardzo duża kamera, która nadaje obraz i dźwięk na żywo do telewizorów rozrywkowych na statku."
	icon = 'aquila/icons/obj/broadcast.dmi'
	icon_state = "big_broadcast_cam"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_RED
	light_power = 0.3
	/// Czy kamera nadaje
	var/active = FALSE
	/// Czy mikrofon jest włączony
	var/active_microphone = TRUE
	/// Nazwa programu
	var/broadcast_name = "Wiadomości Kuratora"
	/// Sieci, na które nadaje kamera
	var/list/camera_networks = list(CAMERANET_NETWORK_CURATOR)
	/// Wirtualna kamera; stoi niewidzialna na naszym polu, bo kamera w obiekcie nie widzi otoczenia
	var/obj/machinery/camera/internal_camera
	/// Wirtualny mikrofon
	var/obj/item/radio/entertainment/microphone/internal_radio

/obj/machinery/big_broadcast_camera/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/machinery/big_broadcast_camera/Destroy()
	if(active)
		stop_broadcasting_network(camera_networks)
	QDEL_NULL(internal_radio)
	QDEL_NULL(internal_camera)
	return ..()

/obj/machinery/big_broadcast_camera/interact(mob/user)
	. = ..()
	if(active)
		on_deactivating()
	else
		on_activating(user)

/obj/machinery/big_broadcast_camera/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Nazwa programu: <b>[html_encode(broadcast_name)]</b>.</span>"
	. += "<span class='notice'>Mikrofon jest <b>[active_microphone ? "włączony" : "wyłączony"]</b>.</span>"
	if(active && internal_camera)
		. += "<span class='notice'>Na żywo! Widzowie: <b>[internal_camera.count_spesstv_viewers()]</b>.</span>"
	. += "<span class='notice'>Kamera jest [anchored ? "przykręcona" : "luźna"] (<b>klucz</b>).</span>"
	. += "<span class='notice'>Kliknij, żeby zacząć lub skończyć nadawanie. <b>Alt+klik</b> przełącza mikrofon, <b>Ctrl+Shift+klik</b> zmienia nazwę programu.</span>"

/obj/machinery/big_broadcast_camera/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	active_microphone = !active_microphone
	balloon_alert(user, active_microphone ? "mikrofon włączony" : "mikrofon wyłączony")
	if(active)
		set_microphone_state()

/obj/machinery/big_broadcast_camera/CtrlShiftClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_name = tgui_input_text(user, "Jak ma się nazywać twój program?", "Nazwa programu", broadcast_name, MAX_CHARTER_LEN, encode = FALSE)
	if(!new_name || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	broadcast_name = new_name
	if(internal_camera)
		internal_camera.c_tag = "NA ŻYWO: [broadcast_name]"
	balloon_alert(user, "nazwa zmieniona")

/obj/machinery/big_broadcast_camera/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE

/// Włącza nadawanie
/obj/machinery/big_broadcast_camera/proc/on_activating(mob/living/user)
	if(!isturf(loc))
		return
	active = TRUE

	internal_camera = new(loc)
	internal_camera.invisibility = INVISIBILITY_ABSTRACT
	internal_camera.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	internal_camera.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	internal_camera.internal_light = FALSE
	internal_camera.network = camera_networks.Copy()
	internal_camera.c_tag = "NA ŻYWO: [broadcast_name]"
	internal_camera.upgradeEmpProof()
	user?.log_message("started a Spess.tv stream named \"[broadcast_name]\" at [loc_name(user)]", LOG_GAME)
	start_broadcasting_network(camera_networks, "[html_encode(broadcast_name)] - teraz NA ŻYWO!")

	internal_radio = new(src)
	set_microphone_state()

	set_light(1)
	playsound(src, 'sound/machines/terminal_processing.ogg', 20, FALSE)
	balloon_alert_to_viewers("na żywo!")

/// Wyłącza nadawanie
/obj/machinery/big_broadcast_camera/proc/on_deactivating()
	active = FALSE
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_radio)
	stop_broadcasting_network(camera_networks)

	set_light(0)
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 20, FALSE)
	balloon_alert_to_viewers("koniec transmisji")

/obj/machinery/big_broadcast_camera/proc/set_microphone_state()
	internal_radio?.broadcasting = active_microphone

/// Kamera jedzie razem z nami
/obj/machinery/big_broadcast_camera/proc/on_moved(datum/source)
	SIGNAL_HANDLER
	if(!internal_camera)
		return
	if(!isturf(loc))
		INVOKE_ASYNC(src, PROC_REF(on_deactivating))
		return
	internal_camera.forceMove(loc)
	GLOB.cameranet.updatePortableCamera(internal_camera)

/datum/crafting_recipe/big_broadcast_camera
	name = "Big broadcast camera"
	result = /obj/machinery/big_broadcast_camera
	reqs = list(
		/obj/item/broadcast_camera = 1,
		/obj/item/stack/rods = 16,
		/obj/item/stack/conveyor = 1,
	)
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	time = 50
	category = CAT_MISC
