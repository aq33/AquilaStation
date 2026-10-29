// AQUILA: kamera reporterska (port Monkestation broadcast_camera.dm)
// Nadaje obraz do telewizorów rozrywkowych i Spess.tv, a dźwięk na kanał rozrywkowy.
// Każdy egzemplarz z innym camera_networks to osobny kanał; kurator dostaje jedną na start.

/obj/item/broadcast_camera
	name = "kamera reporterska"
	desc = "Duża kamera, która nadaje obraz i dźwięk na żywo do telewizorów rozrywkowych na statku."
	icon = 'aquila/icons/obj/broadcast.dmi'
	icon_state = "broadcast_cam0"
	item_state = "broadcast_cam0"
	lefthand_file = 'aquila/icons/mob/inhands/broadcast_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/broadcast_righthand.dmi'
	force = 8
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slot_flags = NONE
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_RED
	light_range = 1
	light_power = 0.3
	light_on = FALSE
	/// Czy kamera nadaje
	var/active = FALSE
	/// Czy mikrofon jest włączony
	var/active_microphone = TRUE
	/// Nazwa programu
	var/broadcast_name = "Wiadomości Kuratora"
	/// Sieci, na które nadaje kamera
	var/list/camera_networks = list(CAMERANET_NETWORK_CURATOR)
	/// Wirtualna kamera w trzymającym
	var/obj/machinery/camera/internal_camera
	/// Wirtualny mikrofon w kamerze
	var/obj/item/radio/entertainment/microphone/internal_radio

/obj/item/broadcast_camera/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS | EMP_PROTECT_WIRES)

/obj/item/broadcast_camera/Destroy()
	if(active)
		stop_broadcasting_network(camera_networks, null, src)
	QDEL_NULL(internal_radio)
	QDEL_NULL(internal_camera)
	return ..()

/obj/item/broadcast_camera/update_icon_state()
	icon_state = "broadcast_cam[active]"
	item_state = icon_state
	return ..()

/obj/item/broadcast_camera/attack_self(mob/living/user)
	. = ..()
	if(active)
		on_deactivating()
	else
		on_activating(user)

/obj/item/broadcast_camera/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Nazwa programu: <b>[html_encode(broadcast_name)]</b>.</span>"
	. += "<span class='notice'>Mikrofon jest <b>[active_microphone ? "włączony" : "wyłączony"]</b>.</span>"
	if(active && internal_camera)
		. += "<span class='notice'>Na żywo! Widzowie: <b>[internal_camera.count_spesstv_viewers()]</b>.</span>"
	. += "<span class='notice'>Użyj w ręce, żeby zacząć lub skończyć nadawanie. <b>Alt+klik</b> przełącza mikrofon, <b>Ctrl+Shift+klik</b> zmienia nazwę programu.</span>"

/obj/item/broadcast_camera/dropped(mob/user, silent)
	. = ..()
	if(active)
		on_deactivating()

/obj/item/broadcast_camera/equipped(mob/user, slot, initial)
	. = ..()
	if(active && !(slot & ITEM_SLOT_HANDS))
		on_deactivating()

/obj/item/broadcast_camera/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	active_microphone = !active_microphone
	balloon_alert(user, active_microphone ? "mikrofon włączony" : "mikrofon wyłączony")
	if(active)
		set_microphone_state()

/obj/item/broadcast_camera/CtrlShiftClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_name = tgui_input_text(user, "Jak ma się nazywać twój program?", "Nazwa programu", broadcast_name, MAX_CHARTER_LEN, encode = FALSE)
	if(!new_name || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	broadcast_name = new_name
	if(internal_camera)
		internal_camera.c_tag = unique_broadcast_tag("NA ŻYWO: [broadcast_name]", internal_camera)
	balloon_alert(user, "nazwa zmieniona")

/// Włącza nadawanie
/obj/item/broadcast_camera/proc/on_activating(mob/living/user)
	if(!isliving(loc))
		return
	var/mob/living/wielder = loc
	if(!wielder.is_holding(src))
		return
	active = TRUE
	update_icon()
	wielder.update_inv_hands()

	// Kamera w obiektach nie widzi otoczenia, więc siedzi w trzymającym
	internal_camera = new(wielder)
	internal_camera.internal_light = FALSE
	internal_camera.network = camera_networks.Copy()
	internal_camera.c_tag = unique_broadcast_tag("NA ŻYWO: [broadcast_name]", internal_camera)
	wielder.log_message("started a Spess.tv stream named \"[broadcast_name]\" at [loc_name(wielder)]", LOG_GAME)
	start_broadcasting_network(camera_networks, "[html_encode(broadcast_name)] - teraz NA ŻYWO!", src)

	internal_radio = new(src)
	set_microphone_state()

	set_light_on(TRUE)
	playsound(src, 'sound/machines/terminal_processing.ogg', 20, FALSE)
	balloon_alert_to_viewers("na żywo!")

/// Wyłącza nadawanie
/obj/item/broadcast_camera/proc/on_deactivating()
	active = FALSE
	update_icon()
	if(ismob(loc))
		var/mob/holder = loc
		holder.update_inv_hands()
	QDEL_NULL(internal_camera)
	QDEL_NULL(internal_radio)
	stop_broadcasting_network(camera_networks, null, src)

	set_light_on(FALSE)
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 20, FALSE)
	balloon_alert_to_viewers("koniec transmisji")

/obj/item/broadcast_camera/proc/set_microphone_state()
	internal_radio?.broadcasting = active_microphone
