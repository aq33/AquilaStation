// Żółwik (Bee): pomocnik hydroponiki z doniczką na grzbiecie, podlewa tace.
// Od części BOTY to basic bot na drzewie zachowań (aquila/code/modules/mob/living/basic/bots/), plik zostaje tu dla historii.
/mob/living/basic/bot/turtle
	name = "żółwik"
	desc = "Pomocnik hydroponiki."
	icon = 'aquila/icons/mob/turtlebot.dmi'
	icon_state = "turtle"
	maxHealth = 50
	health = 50
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Turtle"
	hackables = "dozownik wody"
	work_reach = 1
	work_scan_range = 7
	work_interval = 1 SECONDS
	work_target_types = list(/obj/item/plant_tray)
	possessed_message = "Jesteś żółwikiem! Podlewaj rośliny w hydroponice."
	/// Plant offset to properly line things up
	var/list/plant_offset = list(0, 26)
	/// Mask for burried visuals
	var/icon/mask
	/// Reference to our 'on' overlay, for when a pai uses us
	var/icon/on_overlay
	/// What reagent we water trays with
	var/dispensed_reagent = /datum/reagent/water
	/// Do we auto water?
	var/water = TRUE
	/// Reference to our internal plant scanner
	var/obj/item/plant_scanner/internal_scanner

/mob/living/basic/bot/turtle/Initialize(mapload)
	additional_access = list(ACCESS_HYDROPONICS)
	. = ..()
	internal_scanner = new(src)
	if(prob(5))
		name = "Louie"
		real_name = name
		icon_state = "louie"
	on_overlay = icon('aquila/icons/mob/turtlebot.dmi', "turtle on")
//Tray stuff
	create_reagents(200)
	var/datum/component/planter/tray_component = AddComponent(/datum/component/planter, plant_offset, 1.2, FALSE)
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE
//Build pot appearance
	var/mutable_appearance/pot = mutable_appearance('icons/obj/hydroponics/features/pots.dmi', "pot_[rand(1, 6)]")
	pot.pixel_y += 14
	add_overlay(pot)
	mask = icon('icons/obj/hydroponics/features/pots.dmi', "pot_mask")

/mob/living/basic/bot/turtle/req_bot_access()
	return list(ACCESS_HYDROPONICS)

/mob/living/basic/bot/turtle/update_icon_state()
	. = ..()
	icon_state = name == "Louie" ? "louie" : "turtle"

/mob/living/basic/bot/turtle/Destroy(force)
	. = ..()
	QDEL_NULL(mask)
	QDEL_NULL(internal_scanner)

/mob/living/basic/bot/turtle/can_seek_work()
	return ..() && water

/mob/living/basic/bot/turtle/is_valid_work_target(atom/target)
	if(!isturf(target.loc) || !target.reagents)
		return FALSE
	// podlewa do połowy, potem idzie dalej
	return target.reagents.total_volume < target.reagents.maximum_volume / 2

/mob/living/basic/bot/turtle/work_on_target(atom/target)
	if(QDELETED(target))
		return BOT_WORK_DONE
	if(get_dist(src, target) > 1)
		return BOT_WORK_OUT_OF_REACH
	water_tray(target)
	return BOT_WORK_DONE

/// Podlewa tacę i skanuje jej roślinę
/mob/living/basic/bot/turtle/proc/water_tray(atom/tray)
	reagents.add_reagent(/datum/reagent/medicine/earthsblood, 200) // Adding this here because nothing matters anymore
	if(tray.GetComponent(/datum/component/plant))
		internal_scanner.afterattack(tray, src, TRUE)
	if(!tray.GetComponent(/datum/component/planter))
		return
	visible_message(span_notice("[src] podlewa [tray]."))
	playsound(tray, 'sound/effects/footstep/water1.ogg', 60, TRUE)
	tray.reagents?.add_reagent(dispensed_reagent, 15)

/mob/living/basic/bot/turtle/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(attack_target.GetComponent(/datum/component/planter) || attack_target.GetComponent(/datum/component/plant))
		water_tray(attack_target)
		return
	return ..()

/mob/living/basic/bot/turtle/emag_effects(mob/user)
	dispensed_reagent = /datum/reagent/toxin/plantbgone
	if(user)
		to_chat(user, span_danger("[src] brzęczy i pika."))

/mob/living/basic/bot/turtle/get_custom_controls(mob/user)
	return list("water_trays" = water)

/mob/living/basic/bot/turtle/bot_custom_act(action, list/params, mob/user)
	if(action != "water_trays")
		return FALSE
	water = !water
	return TRUE

/mob/living/basic/bot/turtle/insertpai(mob/user, obj/item/paicard/card)
	. = ..()
	if(!.)
		return
	add_overlay(on_overlay)
	dispensed_reagent = /datum/reagent/medicine/earthsblood

/mob/living/basic/bot/turtle/ejectpai(mob/user = null, announce = TRUE)
	var/had_card = !!paicard
	. = ..()
	if(!had_card)
		return
	cut_overlay(on_overlay)
	dispensed_reagent = is_emagged() ? /datum/reagent/toxin/plantbgone : /datum/reagent/water

/mob/living/basic/bot/turtle/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/datum/component/plant/plant_component = arrived.GetComponent(/datum/component/plant)
	if(plant_component?.draw_below_water)
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -12, icon = mask, flags = MASK_INVERSE))

/mob/living/basic/bot/turtle/Exited(atom/movable/gone, direction)
	. = ..()
	gone.remove_filter("plant_tray_mask")
	vis_contents -= gone

/datum/crafting_recipe/turtle
	name = "Żółwik"
	result = /mob/living/basic/bot/turtle
	time = 10 SECONDS
	reqs = list(
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_leg/robot = 1,
		/obj/item/bodypart/l_leg/robot = 1
		)
	category = CAT_ROBOT
