// The mawed crucible, a heretic structure that can create potions from bodyparts and organs.
/obj/structure/destructible/eldritch_crucible
	name = "mawed crucible"
	desc = "Głęboka misa z żeliwa, unieśmiertelniona przez stalowe zęby, które trzymają ją w miejscu. \
		Wpatrywanie się w plugawy wyciąg w środku napełnia umysł strasznymi pomysłami."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	icon_state = "crucible"
	break_sound = 'sound/hallucinations/wail.ogg'
	break_message = "<span class='warning'>Tygiel rozpada się z łoskotem!</span>"
	light_power = 1
	anchored = TRUE
	density = TRUE
	///How much mass this currently holds
	var/current_mass = 3
	///Maximum amount of mass
	var/max_mass = 3
	///Check to see if it is currently being used.
	var/in_use = FALSE
	///Cooldown for the crucible to create mass from the eldritch
	COOLDOWN_DECLARE(refill_cooldown)

/obj/structure/destructible/eldritch_crucible/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/eldritch_crucible/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/eldritch_crucible/process(seconds_per_tick)
	if(COOLDOWN_TIMELEFT(src, refill_cooldown))
		return
	if(current_mass >= max_mass)
		return
	COOLDOWN_START(src, refill_cooldown, 30 SECONDS)
	current_mass++
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	update_icon()

/obj/structure/destructible/eldritch_crucible/deconstruct(disassembled = TRUE)
	// Create a spillage if we were destroyed with leftover mass
	if(current_mass && !disassembled)
		break_message = span_warning("[src] rozpada się z łoskotem, rozlewając wszędzie lśniący ekstrakt!")
		var/turf/our_turf = get_turf(src)

		new /obj/effect/decal/cleanable/greenglow(our_turf)
		for(var/turf/nearby_turf as anything in get_adjacent_open_turfs(our_turf))
			if(prob(10 * current_mass))
				new /obj/effect/decal/cleanable/greenglow(nearby_turf)
		playsound(our_turf, 'sound/effects/bubbles2.ogg', 50, TRUE)

	return ..()

/obj/structure/destructible/eldritch_crucible/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	if(current_mass >= max_mass)
		. += span_notice("Możesz tu napełnić flaszkę esencji eldritch.")

	if(current_mass < max_mass)
		var/to_fill = max_mass - current_mass
		. += span_notice("[src] potrzebuje jeszcze <b>[to_fill]</b> organów lub części ciała.")
	else
		. += span_boldnotice("[src] bulgocze po brzegi lepkim płynem i jest gotowy do użycia.")

	. += span_notice("[src] można <b>[anchored ? "odczepić i przenieść":"przytwierdzić na miejscu"]</b> za pomocą <b>Codex Cicatrix</b> albo <b>Uchwytu Mansusa</b>.")
	. += span_info("Można uwarzyć następujące mikstury:")
	for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
		var/potion_string = span_info("\t" + initial(potion.name) + " - " + initial(potion.crucible_tip))
		. += potion_string

/obj/structure/destructible/eldritch_crucible/examine_status(mob/user)
	if(IS_HERETIC_OR_MONSTER(user) || isobserver(user))
		return span_notice("Stabilność: <b>[round(obj_integrity * 100 / max_integrity)]%</b>.")
	return ..()

// no breaky herety thingy
/obj/structure/destructible/eldritch_crucible/rust_heretic_act()
	return FALSE

/obj/structure/destructible/eldritch_crucible/attackby(obj/item/tool, mob/living/user, params)
	if(istype(tool, /obj/item/codex_cicatrix) || istype(tool, /obj/item/melee/spell_hand/mansus_fist))
		playsound(src, 'sound/items/deconstruct.ogg', 30, TRUE, ignore_walls = FALSE)
		anchored = !anchored
		balloon_alert(user, "[anchored ? "przytwierdzono":"odczepiono"]")
		return TRUE
	if(istype(tool, /obj/item/reagent_containers/glass/beaker/eldritch))
		if(current_mass < max_mass)
			balloon_alert(user, "za mało wypełniony!")
			return TRUE
		var/obj/item/reagent_containers/glass/beaker/eldritch/to_fill = tool
		if(to_fill.reagents.total_volume >= to_fill.reagents.maximum_volume)
			balloon_alert(user, "flaszka jest pełna!")
			return TRUE
		to_fill.reagents.add_reagent(/datum/reagent/eldritch, 50)
		user.do_attack_animation(src)
		current_mass--
		COOLDOWN_START(src, refill_cooldown, 30 SECONDS) // AQUILA - odliczanie od zużycia (pełny tygiel go nie zaczynał)
		update_icon()
		balloon_alert(user, "napełniono flaszkę")
		return TRUE

	if(isbodypart(tool))
		var/obj/item/bodypart/consumed = tool
		if(!IS_ORGANIC_LIMB(consumed))
			balloon_alert(user, "nieorganiczne!")
			return TRUE
		if(!IS_HERETIC_OR_MONSTER(user))
			if(user.combat_mode)
				return ..()
			bite_the_hand(user)
			return TRUE
		consume_fuel(user, consumed)
		return TRUE

	if(isorgan(tool))
		var/obj/item/organ/consumed = tool
		if(consumed.organ_flags & ORGAN_SYNTHETIC)
			balloon_alert(user, "nieorganiczne!")
			return TRUE
		if(consumed.organ_flags & ORGAN_VITAL) // Basically, don't eat organs like brains
			balloon_alert(user, "nieodpowiedni organ!")
			return TRUE
		if(!IS_HERETIC_OR_MONSTER(user))
			if(user.combat_mode)
				return ..()
			bite_the_hand(user)
			return TRUE
		consume_fuel(user, consumed)
		return TRUE

	return ..()

/obj/structure/destructible/eldritch_crucible/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!isliving(user))
		return

	if(!IS_HERETIC_OR_MONSTER(user))
		if(iscarbon(user))
			bite_the_hand(user)
		return TRUE

	if(in_use)
		balloon_alert(user, "w użyciu!")
		return TRUE

	if(current_mass < max_mass)
		balloon_alert(user, "za mało wypełniony!")
		return TRUE

	INVOKE_ASYNC(src, PROC_REF(show_radial), user)
	return TRUE

/*
 * Wrapper for show_radial() to ensure in_use is enabled and disabled correctly.
 */
/obj/structure/destructible/eldritch_crucible/proc/show_radial(mob/living/user)
	in_use = TRUE
	create_potion(user)
	in_use = FALSE

/*
 * Shows the user of radial of possible potions,
 * and create the potion they chose.
 */
/obj/structure/destructible/eldritch_crucible/proc/create_potion(mob/living/user)

	// Assoc list of [name] to [image] for the radial
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial, to spawn it
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/item/eldritch_potion/potion as anything in subtypesof(/obj/item/eldritch_potion))
			names_to_path[initial(potion.name)] = potion
			choices[initial(potion.name)] = image(icon = initial(potion.icon), icon_state = initial(potion.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		src,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/spawned_type = names_to_path[picked_choice]
	if(!ispath(spawned_type, /obj/item/eldritch_potion))
		CRASH("[type] attempted to create a potion that wasn't an eldritch potion! (got: [spawned_type])")

	var/obj/item/spawned_pot = new spawned_type(drop_location())

	playsound(src, 'sound/misc/desecration-02.ogg', 75, TRUE)
	visible_message(span_notice("Lśniący płyn z [src] spływa do fiolki, tworząc: [spawned_pot.name]!"))
	balloon_alert(user, "uwarzono miksturę")

	current_mass = 0
	COOLDOWN_START(src, refill_cooldown, 30 SECONDS) // AQUILA - odliczanie od zużycia (pełny tygiel go nie zaczynał)
	update_icon()

/*
 * "Bites the hand that feeds it", except more literally.
 * Called when a non-heretic interacts with the crucible,
 * causing them to lose their active hand to it.
 */
/obj/structure/destructible/eldritch_crucible/proc/bite_the_hand(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_NODISMEMBER))
		return

	var/obj/item/bodypart/arm = user.get_active_hand()
	if(QDELETED(arm))
		return

	to_chat(user, span_userdanger("[src] chwyta cię za [arm.name]!"))
	arm.dismember()
	consume_fuel(consumed = arm)

/*
 * Consumes an organ or bodypart and increases the mass of the crucible.
 * If feeder is supplied, gives some feedback.
 */
/obj/structure/destructible/eldritch_crucible/proc/consume_fuel(mob/living/feeder, obj/item/consumed)
	if(current_mass >= max_mass)
		if(feeder)
			balloon_alert(feeder, "tygiel pełny!")
		return

	current_mass++
	playsound(src, 'sound/items/eatfood.ogg', 100, TRUE)
	visible_message(span_notice("[src] pożera [consumed] i napełnia się odrobiną płynu!"))

	if(feeder)
		balloon_alert(feeder, "nakarmiono tygiel ([current_mass] / [max_mass])")

	qdel(consumed)
	update_icon()

/obj/structure/destructible/eldritch_crucible/update_icon_state()
	icon_state = "crucible[(current_mass == max_mass) ? null : "_empty"]"
	return ..()

// Potions created by the mawed crucible.
/obj/item/eldritch_potion
	name = "brew of day and night"
	desc = "Nie powinieneś tego widzieć."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// When a heretic examines a mawed crucible, shows a list of possible potions by name + includes this tip to explain what it does.
	var/crucible_tip = "Nic nie robi."
	/// Typepath to the status effect this applies
	var/status_effect
	/// If you can drink the same potion while the effect is active
	var/can_refresh = TRUE

/obj/item/eldritch_potion/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += span_notice(crucible_tip)

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	if(.)
		return

	if(!iscarbon(user))
		return

	var/mob/living/carbon/drinker = user
	if(!can_refresh && drinker.has_status_effect(status_effect))
		return

	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)

	if(!IS_HERETIC_OR_MONSTER(user))
		to_chat(user, span_danger("Wypijasz trochę płynu z [src]. Od smaku zbiera ci się na wymioty, a szkło znika."))
		user.reagents?.add_reagent(/datum/reagent/eldritch, 10)
		user.adjust_disgust(50)
		qdel(src)
		return TRUE

	to_chat(user, span_notice("Wypijasz lepki płyn z [src], a szkło się dematerializuje."))
	potion_effect(user)
	qdel(src)
	return TRUE

/**
 * The effect of the potion, if it has any special one.
 * In general try not to override this
 * and utilize the status_effect var to make custom effects.
 */
/obj/item/eldritch_potion/proc/potion_effect(mob/user)
	var/mob/living/carbon/carbon_user = user
	carbon_user.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "brew of the crucible soul"
	desc = "Szklana butelka z jasnopomarańczowym, przejrzystym płynem."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul
	crucible_tip = "Pozwala przechodzić przez ściany. Po wygaśnięciu przenosi cię z powrotem na miejsce, gdzie go wypiłeś. Trwa 40 sekund."
	can_refresh = FALSE

/obj/item/eldritch_potion/crucible_soul/attack_self(mob/living/user)
	if(isliving(user) && user.has_status_effect(/datum/status_effect/crucible_soul_cooldown))
		balloon_alert(user, "jeszcze nie!")
		return TRUE
	return ..()

/obj/item/eldritch_potion/duskndawn
	name = "brew of dusk and dawn"
	desc = "Szklana butelka z matowożółtym płynem. Regularnie to blednie, to znów nabiera barwy."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn
	crucible_tip = "Pozwala widzieć przez ściany i przedmioty. Trwa 90 sekund."

/obj/item/eldritch_potion/wounded
	name = "brew of the wounded soldier"
	desc = "Szklana butelka z bezbarwnym, ciemnym płynem."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal
	crucible_tip = "Leczy cię tym szybciej, im cięższe masz obrażenia i krwawienie. \
		Dodatkowo obrażenia nie spowalniają cię. Trwa 60 sekund."
