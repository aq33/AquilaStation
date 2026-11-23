// AQUILA - autoklaw (AquilaMed 5, etap 3), port z Paradise (code/game/machinery/autoclave.dm, AGPL),
// sprite'y z icons/obj/machines/autoclave.dmi (CC-BY-SA 3.0).
// Komora ciśnieniowa sterylizująca narzędzia: włóż przedmiot (albo apteczkę, pas, tacę z narzędziami: sterylizuje też
// zawartość), zamknij drzwiczki pustą ręką i włącz Ctrl+klikiem. Po cyklu wszystko w środku jest czyste (aq_dirt = 0).
// Różnice: bez emaga z napromieniowaniem i bez gotowania stworzeń w środku (Paradise ma holdery mobów, my nie).

/obj/machinery/autoclave
	name = "autoklaw"
	desc = "Komora ciśnieniowa, która zabija zarazki na narzędziach. Otwierasz i zamykasz ją pustą ręką, wyjmujesz Alt+klikiem, włączasz Ctrl+klikiem."
	icon = 'aquila/icons/obj/medical/autoclave.dmi'
	icon_state = "autoclave"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/autoclave
	/// Time one cycle takes
	var/sanitize_time = 10 SECONDS
	/// Is the door open
	var/is_open = FALSE
	/// What is inside
	var/obj/item/chamber_item
	/// Timer of the running cycle, null when idle
	var/work_timer_id
	var/datum/looping_sound/microwave/soundloop
	/// Masks the item drawn in the open chamber
	var/static/alpha_mask_filter

/obj/machinery/autoclave/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	alpha_mask_filter ||= filter(type = "alpha", icon = icon(icon, "alphamask"))
	update_appearance()

/obj/machinery/autoclave/Destroy()
	QDEL_NULL(soundloop)
	if(work_timer_id)
		deltimer(work_timer_id)
		work_timer_id = null
	if(chamber_item)
		chamber_item.forceMove(drop_location())
		chamber_item = null
	return ..()

/obj/machinery/autoclave/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		rating += laser.rating
	sanitize_time = 10 SECONDS / max(1, rating / 2)

/obj/machinery/autoclave/examine(mob/user)
	. = ..()
	if(chamber_item)
		. += "<span class='notice'>W środku jest [chamber_item].</span>"
	if(work_timer_id)
		. += "<span class='notice'>Trwa sterylizacja.</span>"

/obj/machinery/autoclave/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == chamber_item)
		chamber_item = null
		update_appearance()

/obj/machinery/autoclave/update_icon_state()
	icon_state = panel_open ? "autoclave-open" : "autoclave"
	return ..()

/obj/machinery/autoclave/update_overlays()
	. = ..()
	if(is_open)
		if(chamber_item)
			var/mutable_appearance/content = new /mutable_appearance(chamber_item)
			content.layer = FLOAT_LAYER
			content.plane = FLOAT_PLANE
			content.pixel_x = 0
			content.pixel_y = 0
			content.appearance_flags |= KEEP_TOGETHER
			content.filters += alpha_mask_filter
			. += content
		. += mutable_appearance(icon, "door-open")
	else
		. += mutable_appearance(icon, "door-closed")
	if(machine_stat & (NOPOWER|BROKEN))
		. += mutable_appearance(icon, "lights-off")
	else if(work_timer_id)
		. += mutable_appearance(icon, "lights-green")
		. += emissive_appearance(icon, "lights-green-emi", alpha = 90)
	else
		. += mutable_appearance(icon, "lights-red")
		. += emissive_appearance(icon, "lights-red-emi", alpha = 90)

/obj/machinery/autoclave/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(work_timer_id)
		to_chat(user, "<span class='warning'>[src] jest zablokowany do końca cyklu.</span>")
		return TRUE
	toggle_open()
	return TRUE

/obj/machinery/autoclave/attackby(obj/item/I, mob/living/user, params)
	if(user.combat_mode || I.tool_behaviour == TOOL_SCREWDRIVER || I.tool_behaviour == TOOL_CROWBAR || I.tool_behaviour == TOOL_WRENCH)
		return ..()
	if(!is_open)
		to_chat(user, "<span class='warning'>Drzwiczki [src] są zamknięte.</span>")
		return
	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, "<span class='warning'>[I] nie zmieści się w [src].</span>")
		return
	var/obj/item/old = chamber_item
	if(!user.transferItemToLoc(I, src))
		to_chat(user, "<span class='warning'>[I] przykleił się do twojej ręki!</span>")
		return
	chamber_item = I
	if(old)
		user.put_in_hands(old)
		to_chat(user, "<span class='notice'>Zamieniasz [old] na [I] w [src].</span>")
	else
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
	update_appearance()

/obj/machinery/autoclave/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(!is_open || !chamber_item)
		return
	var/obj/item/taken = chamber_item
	user.put_in_hands(taken)
	to_chat(user, "<span class='notice'>Wyjmujesz [taken] z [src].</span>")

/obj/machinery/autoclave/CtrlClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return ..()
	if(is_open)
		to_chat(user, "<span class='warning'>Najpierw zamknij drzwiczki [src].</span>")
		return
	if(try_start())
		to_chat(user, "<span class='notice'>Włączasz [src].</span>")

/obj/machinery/autoclave/screwdriver_act(mob/living/user, obj/item/I)
	if(work_timer_id)
		to_chat(user, "<span class='warning'>[src] pracuje, poczekaj do końca cyklu.</span>")
		return TRUE
	. = default_deconstruction_screwdriver(user, "autoclave-open", "autoclave", I)
	update_appearance()

/obj/machinery/autoclave/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(I)

/obj/machinery/autoclave/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(work_timer_id)
		to_chat(user, "<span class='warning'>Nie odkręcisz [src] w trakcie cyklu.</span>")
		return
	default_unfasten_wrench(user, I, 0)

/obj/machinery/autoclave/proc/toggle_open()
	is_open = !is_open
	playsound(src, is_open ? 'sound/machines/click.ogg' : 'sound/machines/click.ogg', 30, TRUE)
	update_appearance()

/obj/machinery/autoclave/proc/try_start()
	if(work_timer_id || !chamber_item || panel_open || is_open || machine_stat & (NOPOWER|BROKEN))
		return FALSE
	soundloop.start()
	work_timer_id = addtimer(CALLBACK(src, PROC_REF(finish)), sanitize_time, TIMER_STOPPABLE)
	use_power = ACTIVE_POWER_USE
	update_appearance()
	return TRUE

/obj/machinery/autoclave/proc/finish()
	work_timer_id = null
	soundloop.stop()
	use_power = IDLE_POWER_USE
	if(machine_stat & (NOPOWER|BROKEN)) // power cut mid-cycle: nothing gets sterilised
		update_appearance()
		return
	if(chamber_item)
		sanitize(chamber_item)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	update_appearance()

/// Everything in the chamber comes out sterile
/obj/machinery/autoclave/proc/sanitize(obj/item/item)
	item.aq_dirt = 0
	for(var/obj/item/stored in item.GetAllContents())
		stored.aq_dirt = 0

/obj/item/circuitboard/machine/autoclave
	name = "autoklaw (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/autoclave
	req_components = list(/obj/item/stock_parts/micro_laser = 2, /obj/item/stack/sheet/glass = 1)

/datum/design/board/autoclave
	name = "Płytka maszyny (autoklaw)"
	desc = "Płytka komory, która sterylizuje narzędzia chirurgiczne."
	id = "aq_autoclave"
	build_path = /obj/item/circuitboard/machine/autoclave
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/base/New()
	. = ..()
	design_ids += "aq_autoclave"
