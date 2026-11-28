// AQUILA - tryb noir detektywa (Aurora: noir vision przy kryminalistyce, Daedalus Dock: status effect z fedory,
// Baystation12: dźwięk tropu przy oględzinach śladu). Akcja na fedorze, tylko dla detektywa: świat czarno-biały,
// krew, łuski, odłamki i przedmioty ze śladami na czerwono (te same cele co wzrok N.O.I.R. cyborga).
// Zmytej krwi noir nie pokazuje: od tego są luminol i lampa UV. Oględziny przedmiotu ze śladami grają dźwięk tropu.

#define NOIR_RANGE 6

/// Cele podświetlenia noir w zasięgu widoku (wspólne z wzrokiem N.O.I.R. cyborga)
/proc/aq_noir_targets(mob/viewer, range = NOIR_RANGE)
	. = list()
	if(!viewer)
		return
	for(var/atom/movable/thing in view(range, viewer))
		if(istype(thing, /obj/effect/decal/cleanable/blood) || istype(thing, /obj/effect/decal/cleanable/blood/trail_holder) || istype(thing, /obj/item/ammo_casing) || istype(thing, /obj/item/bullet_fragment))
			. += thing
		else if(isitem(thing))
			var/datum/component/forensics/D = thing.GetComponent(/datum/component/forensics)
			if(D && (length(D.fingerprints) || length(D.blood_DNA) || length(D.fibers)))
				. += thing

/datum/status_effect/aq_noir
	id = "aq_noir"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 1 SECONDS
	alert_type = null
	/// Pokazane obrazki
	var/list/image/shown_images = list()

/datum/status_effect/aq_noir/on_apply()
	owner.add_client_colour(/datum/client_colour/monochrome)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(refresh_noir))
	RegisterSignal(owner, COMSIG_MOB_EXAMINATE, PROC_REF(on_examinate))
	refresh_noir()
	return TRUE

/datum/status_effect/aq_noir/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EXAMINATE))
	clear_images()
	owner.remove_client_colour(/datum/client_colour/monochrome)

/datum/status_effect/aq_noir/tick()
	refresh_noir()

/datum/status_effect/aq_noir/proc/on_examinate(datum/source, atom/A)
	SIGNAL_HANDLER
	owner.aq_noir_clue(A)

/datum/status_effect/aq_noir/proc/clear_images()
	if(owner.client)
		owner.client.images -= shown_images
	shown_images.Cut()

/datum/status_effect/aq_noir/proc/refresh_noir()
	SIGNAL_HANDLER
	clear_images()
	if(!owner.client)
		return
	for(var/atom/movable/target as anything in aq_noir_targets(owner))
		var/image/marker = image(target.icon, target, target.icon_state, ABOVE_ALL_MOB_LAYER, target.dir)
		marker.plane = ABOVE_LIGHTING_PLANE
		marker.appearance_flags = RESET_COLOR | KEEP_APART | NO_CLIENT_COLOR // monochrom klienta nie gasi czerwieni
		marker.color = "#FF2020"
		marker.alpha = 200
		shown_images += marker
	owner.client.images |= shown_images

// --- Akcja na fedorze ---

/datum/action/item_action/aq_noir_mode
	name = "Tryb noir"
	desc = "Świat traci kolory, a krew, łuski i przedmioty ze śladami wyróżniają się na czerwono."

/obj/item/clothing/head/fedora/det_hat
	actions_types = list(/datum/action/item_action/aq_noir_mode)

/obj/item/clothing/head/fedora/det_hat/item_action_slot_check(slot, mob/user)
	return (slot & ITEM_SLOT_HEAD) && aq_is_detective(user)

/obj/item/clothing/head/fedora/det_hat/ui_action_click(mob/user, action)
	if(!istype(action, /datum/action/item_action/aq_noir_mode) || !isliving(user))
		return ..()
	var/mob/living/living_user = user
	if(living_user.has_status_effect(/datum/status_effect/aq_noir))
		living_user.remove_status_effect(/datum/status_effect/aq_noir)
		to_chat(user, "<span class='notice'>Świat odzyskuje kolory.</span>")
	else if(aq_is_detective(user))
		living_user.apply_status_effect(/datum/status_effect/aq_noir)
		to_chat(user, "<span class='notice'>Świat szarzeje. Zostają tylko ślady.</span>")

/obj/item/clothing/head/fedora/det_hat/dropped(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.remove_status_effect(/datum/status_effect/aq_noir)

/proc/aq_is_detective(mob/user)
	return user?.mind?.assigned_role == JOB_NAME_DETECTIVE

// Dźwięk tropu przy oględzinach śladu w trybie noir (wołane z sygnału udanych oględzin, eye_tracking.dm)
/mob/living/proc/aq_noir_clue(atom/A)
	if(has_status_effect(/datum/status_effect/aq_noir) && ismovable(A) && (A in aq_noir_targets(src)))
		playsound_local(get_turf(src), pick('aquila/sound/detective/clue1.ogg', 'aquila/sound/detective/clue2.ogg'), 40, FALSE)

#undef NOIR_RANGE
