// AQUILA - dodatki do broni z Yogstation (code/modules/projectiles/attachments/*.dm, sprite'y icons/obj/guns/attachment.dmi,
// CC-BY-SA 3.0): celownik prosty, holograficzny i termowizyjny, chwyt pionowy, celownik laserowy.
// Różnice względem Yoga:
// - poprawione sprawdzanie zajętego miejsca (Yog: `attachment_flags &= typ` kasował zapisane sloty, dało się założyć dwa celowniki);
// - chwyt zmniejsza mnożnik odrzutu broni (nasz model odrzutu), a nie dawne `recoil`;
// - celowniki nie zmieniają kursora (u nas kursor pokazuje rozrzut i tak go zmniejszają);
// - wiązkę lasera rysujemy własnym śledzeniem promienia, a nie pociskiem z karabinu wiązkowego (u nas jest on tylko w nim);
// - dodatek zdejmuje się śrubokrętem, przed latarką i bagnetem.

/// Celowniki, lunety
#define ATTACHMENT_SLOT_SIGHT (1<<0)
/// Lufa
#define ATTACHMENT_SLOT_BARREL (1<<1)
/// Spust
#define ATTACHMENT_SLOT_TRIGGER (1<<2)
/// Chwyt przedni
#define ATTACHMENT_SLOT_FOREGRIP (1<<3)

/obj/item/gun
	/// Dodatki, które można założyć na tę broń
	var/list/available_attachments
	/// Ile dodatków naraz
	var/max_attachments = 0
	/// Założone dodatki
	var/list/current_attachments
	/// Zajęte miejsca (ATTACHMENT_SLOT_*)
	var/attachment_flags = NONE
	/// Akcje dodane przez dodatki
	var/list/attachment_actions

/obj/item/gun/ballistic
	max_attachments = 4
	available_attachments = list(
		/obj/item/attachment/scope/simple,
		/obj/item/attachment/scope/holo,
		/obj/item/attachment/scope/infrared,
		/obj/item/attachment/laser_sight,
		/obj/item/attachment/grip/vertical,
	)

/obj/item/gun/energy
	max_attachments = 4
	available_attachments = list(
		/obj/item/attachment/scope/simple,
		/obj/item/attachment/scope/holo,
		/obj/item/attachment/scope/infrared,
		/obj/item/attachment/laser_sight,
		/obj/item/attachment/grip/vertical,
	)

/obj/item/gun/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/attachment) && !user.combat_mode)
		try_attach(I, user)
		return TRUE
	return ..()

/obj/item/gun/proc/try_attach(obj/item/attachment/attachment, mob/living/user)
	if(!is_type_in_list(attachment, available_attachments))
		to_chat(user, "<span class='warning'>Na [src] nie da się założyć [attachment].</span>")
		return FALSE
	for(var/obj/item/attachment/existing as anything in current_attachments)
		if(existing.type == attachment.type)
			to_chat(user, "<span class='warning'>[src] ma już [attachment].</span>")
			return FALSE
	if(LAZYLEN(current_attachments) >= max_attachments)
		to_chat(user, "<span class='warning'>Na [src] nie ma już miejsca na dodatki.</span>")
		return FALSE
	if(attachment.attachment_type && (attachment_flags & attachment.attachment_type))
		to_chat(user, "<span class='warning'>Miejsce na [attachment] jest na [src] już zajęte.</span>")
		return FALSE
	if(!user.transferItemToLoc(attachment, src))
		return FALSE
	to_chat(user, "<span class='notice'>Zakładasz [attachment] na [src].</span>")
	playsound(src, 'sound/items/screwdriver2.ogg', 30, TRUE)
	attachment.on_attach(src, user)
	return TRUE

/obj/item/gun/screwdriver_act(mob/living/user, obj/item/I)
	if(!LAZYLEN(current_attachments) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return ..()
	var/obj/item/attachment/to_remove = current_attachments[1]
	if(length(current_attachments) > 1)
		to_remove = input(user, "Który dodatek zdjąć?", "Zdejmowanie dodatku") as null|anything in current_attachments
		if(!to_remove || !(to_remove in current_attachments) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return TRUE
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>Zdejmujesz [to_remove] z [src].</span>")
	to_remove.on_detach(src, user)
	return TRUE

/obj/item/gun/examine(mob/user)
	. = ..()
	for(var/obj/item/attachment/attachment as anything in current_attachments)
		. += "Ma założone: [attachment]."
	if(max_attachments && LAZYLEN(current_attachments) < max_attachments)
		. += "<span class='info'>Można na nią założyć dodatki (celowniki, chwyt, laser). Zdejmuje się je <b>śrubokrętem</b>.</span>"

// Dodatki są widoczne na broni jak latarka i bagnet: rysujemy je razem z nimi (get_attachment_overlays() przeżywa cut_overlays()
// w update_icon() broni). Miejsce montażu liczymy z obrysu sprite'a broni (lufa w prawo, jak w ikonach obiektów):
// celownik na górnej krawędzi środka broni, chwyt i laser pod korpusem (bez magazynka i spustu, które wiszą niżej).

/// "[icon]|[icon_state]" -> list("sight" = list(x, y), "grip" = ..., "laser" = ...)
GLOBAL_LIST_EMPTY(aq_gun_mount_points)

/obj/item/gun/proc/get_mount_points()
	var/key = "[icon]|[icon_state]"
	var/list/cached = GLOB.aq_gun_mount_points[key]
	if(cached)
		return cached
	var/icon/sprite = icon(icon, icon_state, SOUTH, 1)
	var/width = sprite.Width()
	var/height = sprite.Height()
	var/list/col_top = new /list(width)
	var/list/col_run_bottom = new /list(width)
	var/left = 0
	var/right = 0
	for(var/x in 1 to width)
		var/top = 0
		for(var/y in height to 1 step -1)
			if(sprite.GetPixel(x, y))
				top = y
				break
		if(!top)
			continue
		var/bottom = top
		while(bottom > 1 && sprite.GetPixel(x, bottom - 1))
			bottom--
		col_top[x] = top
		col_run_bottom[x] = bottom
		if(!left)
			left = x
		right = x
	if(!left)
		left = 8
		right = 24
		for(var/x in left to right)
			col_top[x] = 20
			col_run_bottom[x] = 12
	var/sight_x = round(left + (right - left) * 0.45)
	// Celownik leży na typowym wierzchu broni pod całą swoją szerokością (mediana), a nie na najwyższym wystającym
	// pikselu (muszka, rączka), bo wtedy wisiał w powietrzu
	var/list/sight_tops = list()
	for(var/x in max(sight_x - 3, 1) to min(sight_x + 3, width))
		if(col_top[x])
			sight_tops += col_top[x]
	sortTim(sight_tops, GLOBAL_PROC_REF(cmp_numeric_asc))
	var/sight_top = length(sight_tops) ? sight_tops[round(length(sight_tops) / 2) + 1] : 20
	var/grip_x = aq_nearest_column(col_top, round(left + (right - left) * 0.7))
	var/laser_x = aq_nearest_column(col_top, round(left + (right - left) * 0.86))
	cached = list(
		"sight" = list(sight_x, sight_top - 1), // dolny wiersz sprite'u celownika zachodzi 1 px na broń
		"grip" = list(grip_x, col_run_bottom[grip_x] - 1),
		"laser" = list(laser_x, col_run_bottom[laser_x] - 1),
	)
	GLOB.aq_gun_mount_points[key] = cached
	return cached

/proc/aq_nearest_column(list/col_top, x)
	for(var/offset in 0 to length(col_top))
		for(var/candidate in list(x - offset, x + offset))
			if(candidate >= 1 && candidate <= length(col_top) && col_top[candidate])
				return candidate
	return x

/obj/item/gun/get_attachment_overlays()
	. = ..()
	if(!LAZYLEN(current_attachments))
		return
	var/list/mounts = get_mount_points()
	for(var/obj/item/attachment/attachment as anything in current_attachments)
		var/list/point = mounts[attachment.mount_slot]
		if(!point)
			continue
		var/mutable_appearance/mounted = mutable_appearance('aquila/icons/obj/guns/attachment_mounted.dmi', "[attachment.mounted_state][attachment.is_on && attachment.mounted_has_on ? "_on" : ""]")
		mounted.pixel_x = point[1] - 16
		mounted.pixel_y = point[2] - 16
		. += mounted

/obj/item/gun/handle_atom_del(atom/A)
	if(A in current_attachments)
		var/obj/item/attachment/attachment = A
		attachment.on_detach(src)
	return ..()

/obj/item/gun/Destroy()
	for(var/obj/item/attachment/attachment as anything in current_attachments)
		qdel(attachment)
	current_attachments = null
	return ..()

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	for(var/obj/item/attachment/attachment as anything in current_attachments)
		attachment.set_user(user)
		if(user.is_holding(src))
			attachment.pickup_user(user)
		else
			attachment.equip_user(user)

/obj/item/gun/pickup(mob/user)
	. = ..()
	for(var/datum/action/attachment_action as anything in attachment_actions)
		attachment_action.Grant(user)

/obj/item/gun/dropped(mob/user)
	. = ..()
	for(var/obj/item/attachment/attachment as anything in current_attachments)
		attachment.set_user()
		attachment.drop_user(user)
	for(var/datum/action/attachment_action as anything in attachment_actions)
		attachment_action.Remove(user)

// --- Dodatek ---

/obj/item/attachment
	name = "dodatek do broni"
	desc = "Dodatek do broni."
	icon = 'aquila/icons/obj/guns/attachment.dmi'
	icon_state = "_error"
	w_class = WEIGHT_CLASS_SMALL
	/// Broń, na której jest założony
	var/obj/item/gun/attached_gun
	/// Włączony (laser, termowizja)
	var/is_on = FALSE
	/// Zajmowane miejsce (ATTACHMENT_SLOT_*); 0 = dodatek z boku lufy, nie wyklucza innych
	var/attachment_type = NONE
	/// Kto trzyma broń
	var/mob/current_user
	/// Akcje dodawane do broni
	var/list/actions_list = list()
	/// Gdzie siedzi na broni: "sight", "grip" albo "laser"
	var/mount_slot = "sight"
	/// Stan w aquila/icons/obj/guns/attachment_mounted.dmi
	var/mounted_state = "simple_sight"
	/// Ma osobny stan "_on" na broni
	var/mounted_has_on = FALSE

/obj/item/attachment/update_icon()
	icon_state = "[initial(icon_state)][is_on ? "_on" : ""]"
	. = ..()
	attached_gun?.update_icon() // stan na broni (laser i termowizja świecą po włączeniu)

/obj/item/attachment/Destroy()
	if(attached_gun)
		on_detach(attached_gun)
	return ..()

/obj/item/attachment/proc/on_attach(obj/item/gun/gun, mob/user)
	attached_gun = gun
	for(var/action_type in actions_list)
		var/datum/action/attachment_action = new action_type(gun)
		LAZYADD(gun.attachment_actions, attachment_action)
		if(user && gun.loc == user)
			attachment_action.Grant(user)
	if(user && gun.loc == user)
		set_user(user)
		if(user.is_holding(gun))
			pickup_user(user)
	gun.attachment_flags |= attachment_type
	LAZYADD(gun.current_attachments, src)
	gun.update_icon()
	if(loc != gun)
		forceMove(gun)

/obj/item/attachment/proc/on_detach(obj/item/gun/gun, mob/living/user)
	for(var/action_type in actions_list)
		for(var/datum/action/attachment_action as anything in gun.attachment_actions)
			if(istype(attachment_action, action_type))
				if(user)
					attachment_action.Remove(user)
				LAZYREMOVE(gun.attachment_actions, attachment_action)
				qdel(attachment_action)
				break
	if(current_user)
		drop_user(current_user)
	set_user()
	attached_gun = null
	gun.attachment_flags &= ~attachment_type
	LAZYREMOVE(gun.current_attachments, src)
	gun.update_icon()
	if(QDELETED(src))
		return
	if(user)
		forceMove(user.drop_location())
		user.put_in_hands(src)
	else
		forceMove(get_turf(gun))

/obj/item/attachment/proc/set_user(mob/user)
	current_user = istype(user) ? user : null

/// Broń wzięta do ręki
/obj/item/attachment/proc/pickup_user(mob/user)
	return

/// Broń schowana (pas, plecak)
/obj/item/attachment/proc/equip_user(mob/user)
	return

/// Broń upuszczona albo zdjęta
/obj/item/attachment/proc/drop_user(mob/user)
	return

/// Czy właściciel trzyma broń i może jej używać
/obj/item/attachment/proc/check_user()
	if(!current_user && attached_gun && ismob(attached_gun.loc))
		set_user(attached_gun.loc)
	if(!current_user || !isturf(current_user.loc) || !attached_gun || !current_user.is_holding(attached_gun) || current_user.incapacitated())
		return FALSE
	return TRUE

/// Akcja dodatku na pasku broni
/datum/action/item_action/attachment_toggle
	name = "Przełącz dodatek"
	icon_icon = 'aquila/icons/obj/guns/attachment.dmi'
	/// Typ dodatku, który przełącza
	var/attachment_path

/datum/action/item_action/attachment_toggle/Trigger()
	var/obj/item/gun/gun = target
	if(!istype(gun))
		return FALSE
	for(var/obj/item/attachment/attachment as anything in gun.current_attachments)
		if(istype(attachment, attachment_path))
			attachment.attack_self(owner)
			break
	UpdateButtonIcon()
	return TRUE

// --- Chwyt ---

/obj/item/attachment/grip
	name = "chwyt"
	attachment_type = ATTACHMENT_SLOT_FOREGRIP
	/// O ile zmniejsza mnożnik odrzutu broni
	var/steady = 0

/obj/item/attachment/grip/on_attach(obj/item/gun/gun, mob/user)
	. = ..()
	gun.recoil_multiplier -= steady

/obj/item/attachment/grip/on_detach(obj/item/gun/gun, mob/living/user)
	gun.recoil_multiplier += steady
	return ..()

/obj/item/attachment/grip/vertical
	name = "chwyt pionowy"
	desc = "Wyprofilowany chwyt przedni, dzięki któremu broń pewniej leży w dłoniach i mniej podskakuje przy strzale."
	icon_state = "vert_grip"
	steady = 0.3
	mount_slot = "grip"
	mounted_state = "vert_grip"

// --- Celowniki ---

/obj/item/attachment/scope
	name = "celownik"
	attachment_type = ATTACHMENT_SLOT_SIGHT
	/// O ile zmniejsza rozrzut broni (stopnie)
	var/accuracy = 0

/obj/item/attachment/scope/on_attach(obj/item/gun/gun, mob/user)
	. = ..()
	gun.spread -= accuracy

/obj/item/attachment/scope/on_detach(obj/item/gun/gun, mob/living/user)
	gun.spread += accuracy
	return ..()

/obj/item/attachment/scope/simple
	name = "celownik prosty"
	desc = "Wytrzymały celownik z podświetlanymi kropkami do nocnych akcji. Lepszy niż przyrządy mechaniczne."
	icon_state = "simple_sight"
	accuracy = 3

/obj/item/attachment/scope/holo
	name = "celownik holograficzny"
	desc = "Zaawansowany celownik, który rzuca na szkiełko hologram znaku celowniczego. Nie zasłania widoku i pozwala precyzyjnie celować."
	icon_state = "holo_sight"
	accuracy = 6
	mounted_state = "holo_sight"

/obj/item/attachment/scope/infrared
	name = "celownik termowizyjny"
	desc = "Kamera wyłapująca promieniowanie podczerwone. Obraz jest kiepski, więc celuje się nim gorzej, ale widać przez nią ciepło ciał."
	icon_state = "ifr_sight"
	accuracy = -2
	mounted_state = "ifr_sight"
	mounted_has_on = TRUE
	actions_list = list(/datum/action/item_action/attachment_toggle/infrared)

/datum/action/item_action/attachment_toggle/infrared
	name = "Termowizja celownika"
	button_icon_state = "ifr_sight"
	attachment_path = /obj/item/attachment/scope/infrared

/obj/item/attachment/scope/infrared/attack_self(mob/user)
	. = ..()
	toggle_on()

/obj/item/attachment/scope/infrared/proc/toggle_on()
	is_on = !is_on
	playsound(get_turf(src), is_on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
	if(current_user)
		if(is_on && attached_gun && current_user.is_holding(attached_gun))
			pickup_user(current_user)
		else
			drop_user(current_user)
	update_icon()

/obj/item/attachment/scope/infrared/pickup_user(mob/user)
	. = ..()
	if(user && is_on)
		ADD_TRAIT(user, TRAIT_THERMAL_VISION, REF(src))
		user.update_sight()

/obj/item/attachment/scope/infrared/equip_user(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, REF(src))
		user.update_sight()

/obj/item/attachment/scope/infrared/drop_user(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, REF(src))
		user.update_sight()

// --- Celownik laserowy z wiązką ---

/obj/item/attachment/laser_sight
	name = "celownik laserowy"
	desc = "Przerośnięty wskaźnik laserowy. Kropka pokazuje, w co celujesz, a wiązkę widzą wszyscy dookoła."
	icon_state = "laser_sight"
	mount_slot = "laser"
	mounted_state = "laser_sight"
	mounted_has_on = TRUE
	actions_list = list(/datum/action/item_action/attachment_toggle/laser, /datum/action/item_action/change_laser_sight_color)
	/// Kolor wiązki
	var/laser_color = "#ff0000"
	/// O ile zmniejsza rozrzut po włączeniu
	var/accuracy = 6
	/// Odcinki narysowanej wiązki
	var/list/beam_effects
	/// Ostatni punkt, w który świeciła wiązka (nie rysujemy jej od nowa bez potrzeby)
	var/last_beam_key

/datum/action/item_action/attachment_toggle/laser
	name = "Celownik laserowy"
	button_icon_state = "laser_sight"
	attachment_path = /obj/item/attachment/laser_sight

/datum/action/item_action/change_laser_sight_color
	name = "Kolor lasera"
	icon_icon = 'aquila/icons/obj/guns/attachment.dmi'
	button_icon_state = "laser_sight"

/datum/action/item_action/change_laser_sight_color/Trigger()
	var/obj/item/gun/gun = target
	if(!istype(gun) || !owner)
		return FALSE
	for(var/obj/item/attachment/laser_sight/sight in gun.current_attachments)
		sight.pick_color(owner)
		break
	return TRUE

/obj/item/attachment/laser_sight/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Alt+klik</b> zmienia kolor wiązki.</span>"

/obj/item/attachment/laser_sight/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return ..()
	pick_color(user)

/obj/item/attachment/laser_sight/proc/pick_color(mob/user)
	var/new_color = input(user, "Wybierz kolor wiązki", "Celownik laserowy", laser_color) as null|color
	if(!new_color || QDELETED(src))
		return
	laser_color = new_color
	last_beam_key = null
	update_beam()

/obj/item/attachment/laser_sight/on_attach(obj/item/gun/gun, mob/user)
	. = ..()
	if(is_on)
		gun.spread -= accuracy

/obj/item/attachment/laser_sight/on_detach(obj/item/gun/gun, mob/living/user)
	if(is_on)
		gun.spread += accuracy
	clear_beam()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/attachment/laser_sight/attack_self(mob/user)
	. = ..()
	toggle_on()

/obj/item/attachment/laser_sight/proc/toggle_on()
	is_on = !is_on
	playsound(get_turf(src), is_on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
	if(attached_gun)
		attached_gun.spread += is_on ? -accuracy : accuracy
	if(is_on)
		START_PROCESSING(SSfastprocess, src)
		update_beam()
	else
		STOP_PROCESSING(SSfastprocess, src)
		clear_beam()
	update_icon()

/obj/item/attachment/laser_sight/process()
	if(!is_on || !attached_gun)
		clear_beam()
		return PROCESS_KILL
	update_beam()

/obj/item/attachment/laser_sight/set_user(mob/user)
	if(current_user && current_user != user)
		UnregisterSignal(current_user, COMSIG_MOVABLE_MOVED)
	. = ..()
	if(current_user)
		RegisterSignal(current_user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved), override = TRUE)

/obj/item/attachment/laser_sight/drop_user(mob/user)
	. = ..()
	clear_beam()

/obj/item/attachment/laser_sight/proc/on_user_moved()
	SIGNAL_HANDLER
	update_beam()

/obj/item/attachment/laser_sight/Destroy()
	clear_beam()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/attachment/laser_sight/proc/clear_beam()
	QDEL_LIST(beam_effects)
	last_beam_key = null

/// Rysuje wiązkę od strzelca w stronę kursora do pierwszej ściany, zamkniętych drzwi albo postaci
/obj/item/attachment/laser_sight/proc/update_beam()
	if(!is_on || !check_user() || !isliving(current_user))
		clear_beam()
		return
	var/mob/living/shooter = current_user
	if(!shooter.aq_cursor_known)
		return
	var/angle = SIMPLIFY_DEGREES(ATAN2(shooter.aq_cursor_dy, shooter.aq_cursor_dx)) // jak calculate_projectile_angle_and_pixel_offsets()
	var/turf/start = get_turf(shooter)
	var/datum/point/start_point = RETURN_PRECISE_POINT(start)
	var/datum/point/end_point = trace_laser(start, angle, 15)
	var/beam_key = "[start.x],[start.y],[start.z],[round(angle)],[end_point.x],[end_point.y]"
	if(beam_key == last_beam_key)
		qdel(start_point)
		qdel(end_point)
		return
	last_beam_key = beam_key
	QDEL_LIST(beam_effects)
	beam_effects = list()
	// bez świateł: generate_tracer_between_points() tworzyłby obiekty światła przy każdym ruchu myszy
	var/obj/effect/projectile/tracer/beam = generate_tracer_between_points(start_point, end_point, /obj/effect/projectile/tracer/laser_sight, laser_color, 0, 0)
	if(beam)
		beam_effects += beam
	var/obj/effect/projectile/impact/laser_dot/dot = new
	end_point.move_atom_to_src(dot)
	dot.color = laser_color
	beam_effects += dot
	qdel(start_point)
	qdel(end_point)

/// Śledzi promień co 8 pikseli; zwraca punkt końcowy
/obj/item/attachment/laser_sight/proc/trace_laser(turf/start, angle, max_tiles)
	var/datum/point/vector/ray = new(start.x, start.y, start.z, 0, 0, angle, 8)
	var/steps = max_tiles * 4
	var/turf/last_turf = start
	for(var/i in 1 to steps)
		ray.increment()
		var/turf/T = ray.return_turf()
		if(!T)
			break
		if(T == last_turf)
			continue
		last_turf = T
		if(T.density || T.opacity)
			ray.increment(-1)
			break
		var/blocked = FALSE
		for(var/atom/movable/thing as anything in T)
			if(thing == current_user)
				continue
			if((isliving(thing) && thing.density) || (thing.density && thing.opacity) || istype(thing, /obj/machinery/door) && thing.density)
				blocked = TRUE
				break
		if(blocked)
			break
	var/turf/end_turf = ray.return_turf() || last_turf
	var/datum/point/end = new(end_turf.x, end_turf.y, end_turf.z, ray.return_px(), ray.return_py())
	qdel(ray)
	return end

/obj/effect/projectile/tracer/laser_sight
	name = "wiązka lasera"
	icon_state = "pixelbeam_greyscale"
	alpha = 140
	layer = ABOVE_LIGHTING_LAYER
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/projectile/impact/laser_dot
	name = "kropka lasera"
	icon = 'icons/obj/projectiles_impact.dmi'
	icon_state = "impact_laser"
	alpha = 200
	layer = ABOVE_LIGHTING_LAYER
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


// Wiązka idzie za kursorem
/datum/aq_mouse_tracker/onMouseMove(object, location, control, params)
	. = ..()
	var/obj/item/gun/held_gun = owner?.get_active_held_item()
	if(!istype(held_gun))
		return
	for(var/obj/item/attachment/laser_sight/sight in held_gun.current_attachments)
		sight.update_beam()

// --- Projekty i uplink ---

/datum/design/aq_simple_sight
	name = "Celownik prosty"
	desc = "Dodatek do broni: zmniejsza rozrzut."
	id = "aq_simple_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2500)
	build_path = /obj/item/attachment/scope/simple
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_holo_sight
	name = "Celownik holograficzny"
	desc = "Dodatek do broni: wyraźnie zmniejsza rozrzut."
	id = "aq_holo_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2500, /datum/material/gold = 1000, /datum/material/plastic = 1000)
	build_path = /obj/item/attachment/scope/holo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_infrared_sight
	name = "Celownik termowizyjny"
	desc = "Dodatek do broni: termowizja, ale gorsza celność."
	id = "aq_infrared_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2500, /datum/material/uranium = 1500, /datum/material/gold = 1000, /datum/material/plastic = 1000)
	build_path = /obj/item/attachment/scope/infrared
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_vertical_grip
	name = "Chwyt pionowy"
	desc = "Dodatek do broni: mniejszy odrzut."
	id = "aq_vertical_grip"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/titanium = 2500)
	build_path = /obj/item/attachment/grip/vertical
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/aq_laser_sight
	name = "Celownik laserowy"
	desc = "Dodatek do broni: wiązka pokazuje cel, po włączeniu mniejszy rozrzut."
	id = "aq_laser_sight"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 1000, /datum/material/uranium = 1000, /datum/material/glass = 500)
	build_path = /obj/item/attachment/laser_sight
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/weaponry/New()
	. = ..()
	design_ids += list("aq_simple_sight", "aq_holo_sight", "aq_vertical_grip", "aq_laser_sight", "gun_maintenance_kit")

/datum/techweb_node/adv_weaponry/New()
	. = ..()
	design_ids += "aq_infrared_sight"

/datum/uplink_item/device_tools/holo_sight
	name = "Celownik holograficzny"
	desc = "Dodatek do broni palnej i energetycznej, który wyraźnie zmniejsza rozrzut."
	item = /obj/item/attachment/scope/holo
	cost = 2

/datum/uplink_item/device_tools/vertical_grip
	name = "Chwyt pionowy"
	desc = "Dodatek do broni, który zmniejsza odrzut przy strzale."
	item = /obj/item/attachment/grip/vertical
	cost = 2

/datum/uplink_item/device_tools/laser_sight
	name = "Celownik laserowy"
	desc = "Dodatek do broni z wiązką lasera, która pokazuje cel i zmniejsza rozrzut. Wiązkę widzą wszyscy."
	item = /obj/item/attachment/laser_sight
	cost = 2

/datum/design/gun_maintenance_kit
	name = "Zestaw konserwacji broni"
	desc = "Czyści broń i przywraca jej sprawność."
	id = "gun_maintenance_kit"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plastic = 1000)
	build_path = /obj/item/gun_maintenance_kit
	category = list("Weapons", "Security")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

#undef ATTACHMENT_SLOT_SIGHT
#undef ATTACHMENT_SLOT_BARREL
#undef ATTACHMENT_SLOT_TRIGGER
#undef ATTACHMENT_SLOT_FOREGRIP
