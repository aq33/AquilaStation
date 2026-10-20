// AQUILA - trumny wampira z BeeStation (coffins.dm i crates.dm). Zwykła trumna jest w code/game/objects/structures/crates_lockers/crates.dm.

/obj/structure/closet/crate
	/// The vampire owner of this crate (or coffin)
	var/mob/living/resident
	/// The time it takes to pry this open with a crowbar
	var/pry_lid_timer = 25 SECONDS

/obj/structure/closet/crate/coffin/examine(mob/user)
	. = ..()
	if(user == resident)
		. += span_cult("To twoja zajęta trumna.")
		. += span_cult("Odpocznij w niej, gdy jesteś ranny, aby zapaść w torpor. Jeśli wejdziesz do niej z niewykorzystanymi rangami, możesz wydać jedną.")
		. += span_cult("Alt-klik w środku trumny, aby ją zamknąć/otworzyć.")
		. += span_cult("Alt-klik poza trumną, aby z niej zrezygnować - odczepi to ją i wszystkie twoje pozostałe struktury.")

/obj/structure/closet/crate/coffin/blackcoffin
	name = "czarna trumna"
	desc = "Dla zmarłych, którzy nie byli aż tak drodzy."
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
	name = "bezpieczna trumna"
	desc = "Dla tych, którzy zbyt boją się, że ktoś zakłóci im spoczynek."
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
	name = "mięsna trumna"
	desc = "Gdy szykujesz się na spotkanie ze Stwórcą, trzeba mieć mięsną strawę na ostatnią drogę."
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
	name = "metalowa trumna"
	desc = "Wielka metalowa puszka sardynek wewnątrz innej wielkiej metalowej puszki sardynek, w kosmosie."
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
		to_chat(resident, span_cultitalic("Rezygnujesz ze swojej trumny! Tracisz też wszystkie pozostałe wampirze struktury!"))
	else
		to_chat(resident, span_cultitalic("Czujesz, że więź z twoją trumną i legowiskiem została zerwana! Musisz poszukać nowych."))
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
	to_chat(user, span_notice("[src] wygląda na szczelnie zamkniętą od środka."))

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
			switch(tgui_alert(user, "Czy chcesz zająć tę trumnę? Twoim legowiskiem będzie: [get_area(src)].", "Zajmij legowisko", list("Tak", "Nie")))
				if("Tak")
					claim_coffin(user)
				if("Nie")
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
			to_chat(user, span_notice("To znacznie bardziej skomplikowana konstrukcja, niż myślałeś. Nie wiesz, od czego zacząć cięcie."))
			return

	if(anchored && item.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_danger("Trumna nie chce odczepić się od podłogi.[user == resident ? " Alt-klik pozwala zrezygnować z trumny i ją odczepić." : ""]"))
		return

	if(locked && item.tool_behaviour == TOOL_CROWBAR)
		var/pry_time = pry_lid_timer * item.toolspeed // Pry speed must be affected by the speed of the tool.
		user.visible_message(
			span_notice("[user] próbuje podważyć wieko: [src] ([item])."),
			span_notice("Zaczynasz podważać wieko: [src] ([item]). Powinno to zająć około [DisplayTimeText(pry_time)]."),
		)
		if(!vampire_do_after(user, pry_time, src))
			return
		bust_open()
		user.visible_message(
			span_notice("[user] wyłamuje wieko: [src]."),
			span_notice("Wieko odskakuje: [src]."),
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
		balloon_alert(user, "zrezygnować z trumny?")
		var/static/list/unclaim_options = list(
			"Tak" = image(icon = 'aquila/icons/vampires/radial_generic.dmi', icon_state = "radial_yes"),
			"Nie" = image(icon = 'aquila/icons/vampires/radial_generic.dmi', icon_state = "radial_no"))
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Tak")
				unclaim_coffin(TRUE)

/obj/structure/closet/crate/proc/LockMe(mob/user, inLocked = TRUE)
	if(user == resident)
		if(!broken)
			locked = inLocked
			if(locked)
				to_chat(user, span_notice("Przestawiasz ukryty zatrzask i zamykasz się w środku."))
			else
				to_chat(user, span_notice("Przestawiasz ukryty zatrzask i otwierasz zamek."))
			return

		// Broken? Let's fix it.
		to_chat(resident, span_notice("Ukryty zatrzask, który zamyka trumnę od środka, jest zepsuty. Nastawiasz go z powrotem..."))
		if(!vampire_do_after(resident, 5 SECONDS, src))
			to_chat(resident, span_notice("Nie udaje ci się naprawić mechanizmu."))
			return
		to_chat(resident, span_notice("Naprawiasz mechanizm i zamykasz zamek."))
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
	name = "Czarna trumna"
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
	name = "Bezpieczna trumna"
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
	name = "Metalowa trumna"
	result = /obj/structure/closet/crate/coffin/metalcoffin
	tools = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 6,
		/obj/item/stack/rods = 2,
	)
	time = 10 SECONDS
	category = CAT_FURNITURE
