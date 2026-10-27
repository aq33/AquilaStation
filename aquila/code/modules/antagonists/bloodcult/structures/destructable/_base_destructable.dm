// Cult buildings!
// AQUILA - stary code/modules/antagonists/cult/cult_structures.dm wypadł z dme (integracja), więc baza jest tu, jak w drafcie.
#define PREVIEW_IMAGE "preview"
#define OUTPUT_ITEMS "output"

/obj/structure/destructible/cult
	icon = 'aquila/icons/bloodcult/monke/obj/cult/structures.dmi'
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	density = TRUE
	anchored = TRUE
	light_power = 2
	debris = list(/obj/item/stack/sheet/runed_metal = 1)
	/// Length of the cooldown between uses.
	var/use_cooldown_duration = 5 MINUTES
	/// If provided, a bonus tip displayed to cultists on examined.
	var/cult_examine_tip
	/// The cooldown for when items can be dispensed.
	COOLDOWN_DECLARE(use_cooldown)

/obj/structure/destructible/cult/examine_status(mob/user)
	if(IS_CULTIST(user) || isobserver(user))
		return span_cult("Stabilność: <b>[round(obj_integrity * 100 / max_integrity)]%</b>.")
	return ..()

/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("[capitalize(src.name)] [anchored ? "jest":"nie jest"] przytwierdzony do podłogi.")
	if(IS_CULTIST(user) || isobserver(user))
		if(cult_examine_tip)
			. += span_cult(cult_examine_tip)
		if(!COOLDOWN_FINISHED(src, use_cooldown))
			. += span_cultitalic("Magia w [src] jest zbyt słaba, znów będzie gotowa za <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]</b>.")

// AQUILA - draft odświeżał ikonę w set_anchored(); u nas nie ma tej procedury, przykręcanie robi wprost anchored
/obj/structure/destructible/cult/update_icon_state()
	icon_state = "[initial(icon_state)][anchored ? "" : "_off"]"
	return ..()

/*
 * Proc for use with the concealing spell. Hides the building (makes it invisible).
 */
/obj/structure/destructible/cult/proc/conceal()
	var/obj/structure/cult/concealed/C = new(loc)
	C.pixel_x = pixel_x
	C.pixel_y = pixel_y
	forceMove(C)
	C.held = src
	C.icon = icon
	C.icon_state = icon_state

/*
 * Proc for use with the concealing spell. Reveals the building (makes it visible).
 */
/obj/structure/destructible/cult/proc/reveal()
	return

// Cult buildings that dispense items to cultists.
/obj/structure/destructible/cult/item_dispenser
	/// An associated list of options this structure can make. See setup_options() for format.
	var/list/options

/obj/structure/destructible/cult/item_dispenser/Initialize(mapload)
	. = ..()
	setup_options()

/obj/structure/destructible/cult/item_dispenser/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!isliving(user) || !IS_CULTIST(user))
		to_chat(user, span_warning("Jesteś prawie pewien, do czego to służy, ale jakoś nie możesz tego dotknąć."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("Najpierw musisz przytwierdzić [src] do podłogi."))
		return
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_cultitalic("Magia w [src] jest zbyt słaba, znów będzie gotowa za <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]</b>."))
		return

	var/list/spawned_items = get_items_to_spawn(user)
	if(!length(spawned_items))
		return
	if(QDELETED(src) || !anchored || !Adjacent(user) || !check_menu(user) || !COOLDOWN_FINISHED(src, use_cooldown))
		return

	COOLDOWN_START(src, use_cooldown, use_cooldown_duration)
	for(var/item_to_make in spawned_items)
		var/obj/item/made_item = new item_to_make(get_turf(src))
		succcess_message(user, made_item)


/*
 * Set up and populate our list of options.
 * Overriden by subtypes.
 *
 * The list of options is a associated list of format:
 *   item_name = list(
 *     preview = image(),
 *     output = list(paths),
 *   )
 */
/obj/structure/destructible/cult/item_dispenser/proc/setup_options()
	return

/*
 * Get all items that this cult building will spawn when interacted with.
 * Opens a radial menu for the user and shows them the list of options, which they can choose from.
 *
 * Return a list: A list of typepaths to items that this building will spawn, chosen by the user.
 */
/obj/structure/destructible/cult/item_dispenser/proc/get_items_to_spawn(mob/living/user)
	if(!LAZYLEN(options))
		CRASH("[type] did not set any options via setup_options!")

	var/list/choices = list()
	for(var/item in options)
		choices[item] = options[item][PREVIEW_IMAGE]

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		custom_check = CALLBACK(src, PROC_REF(check_menu), user),
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(!picked_choice)
		return

	return options[picked_choice][OUTPUT_ITEMS]

/*
 * Gives feedback to [user] after creating a [spawned_item].
 * Override for unique feedback messages on item spawn.
 */
/obj/structure/destructible/cult/item_dispenser/proc/succcess_message(mob/living/user, obj/item/spawned_item)
	to_chat(user, span_cultitalic("[capitalize(src.name)] wytwarza: [spawned_item.name]."))

/*
 * Simple proc intended for use in callbacks to determine if [user] can continue to use a radial menu.
 *
 * Returns TRUE if the user is a living mob that is a cultist and is not incapacitated.
 */
/obj/structure/destructible/cult/item_dispenser/proc/check_menu(mob/user)
	return isliving(user) && IS_CULTIST(user) && !user.incapacitated()

#undef PREVIEW_IMAGE
#undef OUTPUT_ITEMS

// Spooky looking door used in gateways. Or something.
/obj/effect/gateway
	name = "brama"
	desc = "Jesteś prawie pewien, że ta otchłań również w ciebie spogląda."
	icon = 'aquila/icons/bloodcult/monke/obj/cult/structures.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
