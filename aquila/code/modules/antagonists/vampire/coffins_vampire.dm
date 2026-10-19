// AQUILA - trumny wampira z BeeStation (coffins.dm i crates.dm). Zwykła trumna jest w code/game/objects/structures/crates_lockers/crates.dm.

/obj/structure/closet/crate
	/// The vampire owner of this crate (or coffin)
	var/mob/living/resident
	/// The time it takes to pry this open with a crowbar
	var/pry_lid_timer = 25 SECONDS

/obj/structure/closet/crate/coffin/examine(mob/user)
	. = ..()
	if(user == resident)
		. += span_cult("This is your Claimed Coffin.")
		. += span_cult("Rest in it while injured to enter Torpor. Entering it with unspent Ranks will allow you to spend one.")
		. += span_cult("Alt-Click while inside the Coffin to Lock/Unlock.")
		. += span_cult("Alt-Click while outside of your Coffin to Unclaim it, unwrenching it and all your other structures as a result.")

/obj/structure/closet/crate/coffin/blackcoffin
	name = "black coffin"
	desc = "For those departed who are not so dear."
	icon_state = "blackcoffin"
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	open_sound = 'aquila/sound/effects/antag/vampire/coffin_open.ogg'
	close_sound = 'aquila/sound/effects/antag/vampire/coffin_close.ogg'
	breakout_time = 30 SECONDS
	pry_lid_timer = 20 SECONDS
	resistance_flags = NONE
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 2
	armor = list("melee" = 50, "bullet" = 20, "laser" = 30, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60, "stamina" = 0, "bleed" = 0)
	door_anim_time = 0

/obj/structure/closet/crate/coffin/securecoffin
	name = "secure coffin"
	desc = "For those too scared of having their place of rest disturbed."
	icon_state = "securecoffin"
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	open_sound = 'aquila/sound/effects/antag/vampire/coffin_open.ogg'
	close_sound = 'aquila/sound/effects/antag/vampire/coffin_close.ogg'
	breakout_time = 35 SECONDS
	pry_lid_timer = 35 SECONDS
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 2
	armor = list("melee" = 35, "bullet" = 20, "laser" = 20, "energy" = 0, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	door_anim_angle = 140
	azimuth_angle_2 = 180
	door_anim_time = 5
	door_hinge = 5

/obj/structure/closet/crate/coffin/meatcoffin
	name = "meat coffin"
	desc = "When you're ready to meat your maker, the steaks can never be too high."
	icon_state = "meatcoffin"
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF
	open_sound = 'sound/effects/footstep/slime1.ogg'
	close_sound = 'sound/effects/footstep/slime1.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 20 SECONDS
	material_drop = /obj/item/food/meat/slab/human
	material_drop_amount = 3
	armor = list("melee" = 70, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60, "stamina" = 0, "bleed" = 0)
	door_anim_time = 0

/obj/structure/closet/crate/coffin/metalcoffin
	name = "metal coffin"
	desc = "A big metal sardine can inside of another big metal sardine can, in space."
	icon_state = "metalcoffin"
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	open_sound = 'sound/effects/pressureplate.ogg'
	close_sound = 'sound/effects/pressureplate.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 30 SECONDS
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 5
	armor = list("melee" = 40, "bullet" = 15, "laser" = 50, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60, "stamina" = 0, "bleed" = 0)
	door_anim_angle = 140
	azimuth_angle_2 = 180
	door_anim_time = 5
	door_hinge = 5

/// NOTE: This can be any coffin that you are resting AND inside of.
/obj/structure/closet/crate/coffin/proc/claim_coffin(mob/living/claimer)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(claimer)
	if(vampiredatum.claim_coffin(src))
		resident = claimer
		anchored = TRUE
		START_PROCESSING(SSprocessing, src)

/obj/structure/closet/crate/coffin/Destroy()
	unclaim_coffin()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/closet/crate/coffin/process(delta_time)
	if(!(resident in src))
		return
	var/list/turf/area_turfs = get_area_turfs(get_area(src))
	// Create Dirt etc.
	var/turf/T_Dirty = pick(area_turfs)
	if(T_Dirty && !T_Dirty.density)
		// Default: Dirt
		// STEP ONE: COBWEBS
		// CHECK: Wall to North?
		var/turf/check_N = get_step(T_Dirty, NORTH)
		if(istype(check_N, /turf/closed/wall))
			// CHECK: Wall to West?
			var/turf/check_W = get_step(T_Dirty, WEST)
			if(istype(check_W, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb(T_Dirty)
			// CHECK: Wall to East?
			var/turf/check_E = get_step(T_Dirty, EAST)
			if(istype(check_E, /turf/closed/wall))
				new /obj/effect/decal/cleanable/cobweb/cobweb2(T_Dirty)
		new /obj/effect/decal/cleanable/dirt(T_Dirty)

/obj/structure/closet/crate/proc/unclaim_coffin(manual = FALSE)
	// Unanchor it (If it hasn't been broken, anyway)
	anchored = FALSE
	if(!resident || !resident.mind)
		return
	// Unclaiming
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(resident)
	if(vampiredatum && vampiredatum.coffin == src)
		vampiredatum.coffin = null
		vampiredatum.vampire_lair_area = null
	for(var/obj/structure/vampire/vampire_structure in get_area(src))
		if(vampire_structure.owner == resident)
			vampire_structure.unbolt()

	if(manual)
		to_chat(resident, span_cultitalic("You have unclaimed your coffin! This also unclaims all your other Vampire structures!"))
	else
		to_chat(resident, span_cultitalic("You sense that the link with your coffin and your lair has been broken! You will need to seek another."))
	// Remove resident. Because this objec (GC?) we need to give them a way to see they don't have a home anymore.
	resident = null

/// You cannot lock in/out a coffin's owner. SORRY.
/obj/structure/closet/crate/coffin/can_open(mob/living/user)
	if(!locked)
		return ..()
	if(user == resident)
		if(welded)
			welded = FALSE
			update_icon()
		locked = FALSE
		return TRUE
	playsound(get_turf(src), 'sound/machines/door_locked.ogg', 20, 1)
	to_chat(user, span_notice("[src] appears to be locked tight from the inside."))

/obj/structure/closet/crate/coffin/close(mob/living/user)
	. = ..()
	if(!.)
		return FALSE

	// Vampire functionality
	if(user in src)
		var/datum/antagonist/vampire/vampire = IS_VAMPIRE(user)
		if(!vampire)
			return FALSE

		if(!vampire.coffin && !resident)
			switch(tgui_alert(user, "Do you wish to claim this as your coffin? [get_area(src)] will be your lair.", "Claim lair", list("Yes", "No")))
				if("Yes")
					claim_coffin(user)
				if("No")
					return
		LockMe(user)

		// You're in a Coffin, everything else is done, you're likely here to heal. Let's offer them the opportunity to do so.
		vampire.check_begin_torpor()

/// You cannot weld or deconstruct an owned coffin. Only the owner can destroy their own coffin.
/obj/structure/closet/crate/coffin/attackby(obj/item/item, mob/user, params)
	if(!resident)
		return ..()
	if(user != resident)
		if(item.tool_behaviour == cutting_tool)
			to_chat(user, span_notice("This is a much more complex mechanical structure than you thought. You don't know where to begin cutting [src]."))
			return

	if(anchored && item.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_danger("The coffin won't detach from the floor.[user == resident ? " You can Alt-Click to unclaim and unwrench your Coffin." : ""]"))
		return

	if(locked && item.tool_behaviour == TOOL_CROWBAR)
		var/pry_time = pry_lid_timer * item.toolspeed // Pry speed must be affected by the speed of the tool.
		user.visible_message(
			span_notice("[user] tries to pry the lid off of [src] with [item]."),
			span_notice("You begin prying the lid off of [src] with [item]. This should take about [DisplayTimeText(pry_time)]."),
		)
		if(!vampire_do_after(user, pry_time, src))
			return
		bust_open()
		user.visible_message(
			span_notice("[user] snaps the door of [src] wide open."),
			span_notice("The door of [src] snaps open."),
		)
		return
	return ..()

/// Distance Check (Inside Of)
/obj/structure/closet/crate/coffin/AltClick(mob/user)
	. = ..()
	if(user in src)
		LockMe(user, !locked)
		return

	if(user == resident && user.Adjacent(src))
		balloon_alert(user, "unclaim coffin?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'aquila/icons/vampires/radial_generic.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'aquila/icons/vampires/radial_generic.dmi', icon_state = "radial_no"))
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				unclaim_coffin(TRUE)

/obj/structure/closet/crate/proc/LockMe(mob/user, inLocked = TRUE)
	if(user == resident)
		if(!broken)
			locked = inLocked
			if(locked)
				to_chat(user, span_notice("You flip a secret latch and lock yourself inside [src]."))
			else
				to_chat(user, span_notice("You flip a secret latch and unlock [src]."))
			return

		// Broken? Let's fix it.
		to_chat(resident, span_notice("The secret latch that would lock [src] from the inside is broken. You set it back into place..."))
		if(!vampire_do_after(resident, 5 SECONDS, src))
			to_chat(resident, span_notice("You fail to fix [src]'s mechanism."))
			return
		to_chat(resident, span_notice("You fix the mechanism and lock it."))
		broken = FALSE
		locked = TRUE

// Kurator dostaje Archiwum Kindred (Bee: curator.dm)
/datum/outfit/job/curator/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/book/kindred/archive = new(H)
	if(!H.equip_to_slot_if_possible(archive, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
		archive.forceMove(get_turf(H))

// Przepisy trumien (Bee: crafting_lists/structures.dm)

/datum/crafting_recipe/blackcoffin
	name = "Black Coffin"
	result = /obj/structure/closet/crate/coffin/blackcoffin
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/cotton/cloth = 1,
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/stack/sheet/iron = 1,
	)
	time = 15 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/securecoffin
	name = "Secure Coffin"
	result = /obj/structure/closet/crate/coffin/securecoffin
	tools = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/stack/sheet/plasteel = 5,
		/obj/item/stack/sheet/iron = 5,
	)
	time = 15 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/metalcoffin
	name = "Metal Coffin"
	result = /obj/structure/closet/crate/coffin/metalcoffin
	tools = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/rods = 2,
	)
	time = 10 SECONDS
	category = CAT_FURNITURE
