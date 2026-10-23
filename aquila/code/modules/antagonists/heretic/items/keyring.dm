/obj/effect/lock_portal
	name = "crack in reality"
	desc = "Pęknięcie w przestrzeni, niemożliwie głębokie i bolesne dla oczu. Zdecydowanie niebezpieczne."
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "realitycrack"
	light_system = COMPLEX_LIGHT
	light_power = 1
	light_on = TRUE
	light_color = COLOR_GREEN
	light_range = 3
	opacity = TRUE
	density = FALSE //so we dont block doors closing
	layer = OBJ_LAYER //under doors
	///The knock portal we teleport to
	var/obj/effect/lock_portal/destination
	///The airlock we are linked to, we delete if it is destroyed
	var/obj/machinery/door/our_airlock
	/// if true the heretic is teleported to a random airlock, nonheretics are sent to the target
	var/inverted = FALSE

/obj/effect/lock_portal/Initialize(mapload, target, invert = FALSE)
	. = ..()
	if(target)
		our_airlock = target
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(delete_on_door_delete))

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	inverted = invert

///Deletes us and our destination portal if our_airlock is destroyed
/obj/effect/lock_portal/proc/delete_on_door_delete(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Signal handler for when our location is entered, calls teleport on the victim, if their old_loc didnt contain a portal already (to prevent loops)
/obj/effect/lock_portal/proc/on_entered(datum/source, mob/living/loser, atom/old_loc)
	SIGNAL_HANDLER
	if(istype(loser) && !(locate(type) in old_loc))
		INVOKE_ASYNC(src, PROC_REF(teleport), loser)

/obj/effect/lock_portal/Destroy()
	if(!isnull(destination) && !QDELING(destination))
		QDEL_NULL(destination)

	destination = null
	our_airlock = null
	return ..()

///Teleports the teleportee, to a random airlock if the teleportee isnt a heretic, or the other portal if they are one
/obj/effect/lock_portal/proc/teleport(mob/living/teleportee)
	if(isnull(destination)) //dumbass
		qdel(src)
		return

	if(SSmapping.level_trait(z, ZTRAIT_NOPHASE) || SSmapping.level_trait(destination.z, ZTRAIT_NOPHASE))
		qdel(src)
		return

	//get it?
	var/obj/machinery/door/doorstination = (inverted ? !IS_HERETIC_OR_MONSTER(teleportee) : IS_HERETIC_OR_MONSTER(teleportee)) ? destination.our_airlock : find_random_airlock()
	if(isnull(doorstination))
		return
	if(!do_teleport(teleportee, get_turf(doorstination), channel = TELEPORT_CHANNEL_MAGIC))
		return

	teleportee.client?.move_delay = 0 //make moving through smoother

	if(!IS_HERETIC_OR_MONSTER(teleportee))
		teleportee.apply_damage(20, BRUTE) //so they dont roll it like a jackpot machine to see if they can land in the armory
		to_chat(teleportee, span_userdanger("Wpadasz w [src], poturbowany przez siły przekraczające twoje pojęcie, i lądujesz gdziekolwiek, tylko nie tam, gdzie chciałeś."))

	INVOKE_ASYNC(src, PROC_REF(async_opendoor), doorstination)

///Returns a random airlock on the same Z level as our portal, that isnt our airlock
/obj/effect/lock_portal/proc/find_random_airlock()
	var/list/turf/possible_destinations = list()
	// AQUILA - u nas wszystkie drzwi są w GLOB.airlocks, a zakaz teleportu to teleport_restriction obszaru
	for(var/obj/machinery/door/airlock/airlock in GLOB.airlocks)
		if(airlock.z != z)
			continue
		if(airlock.loc == loc)
			continue
		var/area/airlock_area = get_area(airlock)
		if(airlock_area.teleport_restriction != TELEPORT_ALLOW_ALL)
			continue
		possible_destinations += airlock
	if(!length(possible_destinations))
		return null
	return pick(possible_destinations)

///Asynchronous proc to unbolt, then open the passed door
/obj/effect/lock_portal/proc/async_opendoor(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock)) //they can create portals on ANY door, but we should unlock airlocks so they can actually open
		var/obj/machinery/door/airlock/as_airlock = door
		as_airlock.unbolt()
	door.open()

///An ID card capable of shapeshifting to other IDs given by the Key Keepers Burden knowledge
// AQUILA - u nas nie ma /obj/item/card/id/advanced, karta heretyka to zwykły podtyp karty ID
/obj/item/card/id/heretic
	access = list(ACCESS_HERETIC)
	///List of IDs this card consumed
	var/list/obj/item/card/id/fused_ids = list()
	///The first portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_one
	///The second portal in the portal pair, so we can clear it later
	var/obj/effect/lock_portal/portal_two
	///The first door we are linking in the pair, so we can create a portal pair
	var/datum/weakref/link
	/// are our created portals inverted? (heretics get sent to a random airlock, crew get sent to the target)
	var/inverted = FALSE

/obj/item/card/id/heretic/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_hypnophrase("Zaklęta przez Mansus!")
	. += span_hypnophrase("Użycie karty ID na tej karcie albo tej karty na innej pochłania tamtą i kopiuje jej dostęp.")
	. += span_hypnophrase("<b>Użycie jej w dłoni</b> pozwala zmienić jej wygląd.")
	. += span_hypnophrase("<b>Użycie jej na dwóch drzwiach</b> łączy je ze sobą. Wejście w jedne przeniesie cię do drugich, a niewiernych teleportuje do losowej śluzy.")
	. += span_hypnophrase("<b>Ctrl-kliknięcie karty</b> sprawia, że tworzy odwrócone portale: ciebie przenoszą do losowej śluzy na stacji, a niewiernych do celu.")

/obj/item/card/id/heretic/attack_self(mob/user)
	if(!IS_HERETIC(user))
		return ..()
	if(!length(fused_ids))
		balloon_alert(user, "brak opcji!")
		return ..()
	var/cardname = tgui_input_list(user, "W co się zmienić?", "Przemiana", fused_ids)
	if(!cardname)
		return
	var/obj/item/card/id/card = fused_ids[cardname]
	if(QDELETED(card) || QDELETED(src))
		return
	shapeshift(card)

// AQUILA - tg item_ctrl_click
/obj/item/card/id/heretic/CtrlClick(mob/user)
	if(loc != user || !IS_HERETIC(user))
		return ..()
	inverted = !inverted
	balloon_alert(user, "[inverted ? "tworzy" : "nie tworzy już"] odwróconych szczelin")

///Changes our appearance to the passed ID card
/obj/item/card/id/heretic/proc/shapeshift(obj/item/card/id/card)
	// AQUILA - nasze karty nie mają trim/registered_age/assigned_icon_state
	assignment = card.assignment
	registered_name = card.registered_name
	hud_state = card.hud_state
	icon = card.icon
	icon_state = card.icon_state
	item_state = card.item_state
	name = card.name //not update_label because of the captains spare moment
	update_icon()
	if(ishuman(loc))
		var/mob/living/carbon/human/wearing = loc
		wearing.sec_hud_set_ID()

///Deletes and nulls our portal pair
/obj/item/card/id/heretic/proc/clear_portals()
	QDEL_NULL(portal_one)
	QDEL_NULL(portal_two)

///Clears portal references
/obj/item/card/id/heretic/proc/clear_portal_refs()
	SIGNAL_HANDLER
	portal_one = null
	portal_two = null

///Creates a portal pair at door1 and door2, displays a balloon alert to user
/obj/item/card/id/heretic/proc/make_portal(mob/user, obj/machinery/door/door1, obj/machinery/door/door2)
	var/message = "połączono"
	if(portal_one || portal_two)
		clear_portals()
		message += ", poprzednie usunięte"

	portal_one = new(get_turf(door2), door2, inverted)
	portal_two = new(get_turf(door1), door1, inverted)
	portal_one.destination = portal_two
	RegisterSignal(portal_one, COMSIG_PARENT_QDELETING, PROC_REF(clear_portal_refs))  //we only really need to register one because they already qdel both portals if one is destroyed
	portal_two.destination = portal_one
	balloon_alert(user, "[message]")

// AQUILA - tg item_interaction: inna karta ID użyta na tej karcie
/obj/item/card/id/heretic/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/card/id) && IS_HERETIC(user))
		eat_card(W, user)
		return TRUE
	return ..()

/obj/item/card/id/heretic/proc/eat_card(obj/item/card/id/card, mob/user)
	if(card == src)
		return //no self vore
	if(!isnull(user) && card.loc == user && !user.temporarilyRemoveItemFromInventory(card))
		return
	fused_ids[card.name] = card
	card.moveToNullspace()
	access |= card.access
	if(!isnull(user))
		playsound(drop_location(), 'sound/items/eatfood.ogg', rand(10,30), TRUE)
		balloon_alert(user, "karta pochłonięta")

// AQUILA - tg interact_with_atom; u nas pre_attack (TRUE = kontynuuj zwykły atak)
/obj/item/card/id/heretic/pre_attack(atom/target, mob/living/user, params)
	if(!IS_HERETIC(user))
		return ..()
	if(istype(target, /obj/item/card/id))
		eat_card(target, user)
		return FALSE
	if(istype(target, /obj/effect/lock_portal))
		clear_portals()
		return FALSE
	if(!istype(target, /obj/machinery/door))
		return ..()
	if(SSmapping.level_trait(target.z, ZTRAIT_NOPHASE))
		return ..()
	var/reference_resolved = link?.resolve()
	if(reference_resolved == target)
		return FALSE

	if(reference_resolved)
		make_portal(user, reference_resolved, target)
		to_chat(user, span_notice("Łączysz [reference_resolved] i [target] za pomocą [src]."))
		link = null
		balloon_alert(user, "połączenie 2/2")
	else
		link = WEAKREF(target)
		balloon_alert(user, "połączenie 1/2")
	return FALSE

/obj/item/card/id/heretic/Destroy()
	QDEL_LIST_ASSOC_VAL(fused_ids)
	link = null
	clear_portals()
	return ..()
