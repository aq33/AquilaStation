// Broń z wymiennymi ogniwami microfusion (MCR-01), port z Monkestation/Monkestation2.0.
// Oryginał to kopia tg-owego _energy.dm; tu strzelanie idzie przez nasze /obj/item/gun/process_fire(),
// a emiter i dodatki wpinają się w before_firing(), process_chamber() i shoot_live_shot().

/obj/item/gun/microfusion
	name = "prototype detatchable cell energy projection aparatus"
	desc = "Koderzy najwyraźniej nie zauważyli, że to nie działa."
	icon = 'aquila/icons/microfusion/microfusion_gun40x32.dmi'
	icon_state = "mcr01"
	item_state = "mcr01"
	lefthand_file = 'aquila/icons/microfusion/guns_lefthand.dmi'
	righthand_file = 'aquila/icons/microfusion/guns_righthand.dmi'
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = UNIQUE_RENAME
	ammo_x_offset = 2
	flight_x_offset = 15
	flight_y_offset = 10
	knife_x_offset = 20
	knife_y_offset = 12

	/// What type of power cell this uses
	var/obj/item/stock_parts/cell/microfusion/cell
	/// The cell we will spawn with
	var/cell_type = /obj/item/stock_parts/cell/microfusion
	/// The cell type we check when inserting a cell
	var/base_cell_type = /obj/item/stock_parts/cell/microfusion
	/// How many charge sections do we have?
	var/charge_sections = 4
	/// if this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	/// Should we give an overlay to empty guns?
	var/display_empty = TRUE
	/// Spawn with an empty cell
	var/dead_cell = FALSE

	// MICROFUSION SPECIFIC VARS

	/// The microfusion lens used for generating the beams.
	var/obj/item/ammo_casing/energy/laser/microfusion/microfusion_lens
	/// The sound played when you insert a cell.
	var/sound_cell_insert = 'aquila/sound/microfusion/mag_insert.ogg'
	/// Should the insertion sound played vary?
	var/sound_cell_insert_vary = TRUE
	/// The volume at which we will play the insertion sound.
	var/sound_cell_insert_volume = 50
	/// The sound played when you remove a cell.
	var/sound_cell_remove = 'aquila/sound/microfusion/mag_insert.ogg'
	/// Should the removal sound played vary?
	var/sound_cell_remove_vary = TRUE
	/// The volume at which we will play the removal sound.
	var/sound_cell_remove_volume = 50
	/// A list of attached upgrades
	var/list/attachments = list()
	/// The starting phase emitter in this weapon.
	var/phase_emitter_type = /obj/item/microfusion_phase_emitter
	/// The base emitter type that we check when putting a new emitter in.
	var/base_phase_emitter_type = /obj/item/microfusion_phase_emitter
	/// The phase emitter that this gun currently has.
	var/obj/item/microfusion_phase_emitter/phase_emitter
	/// The amount of heat produced per shot
	var/heat_per_shot = 100
	/// The heat dissipation bonus granted by the weapon.
	var/heat_dissipation_bonus = 0
	/// What slots does this gun have?
	var/list/attachment_slots = list(GUN_SLOT_BARREL, GUN_SLOT_UNDERBARREL, GUN_SLOT_RAIL, GUN_SLOT_UNIQUE, GUN_SLOT_CAMO)
	/// Do we use more power because of attachments?
	var/extra_power_usage = 0
	/// Spread from attachments.
	var/attachment_spread = 0
	/// Recoil from attachments.
	var/attachment_recoil = 0

/obj/item/gun/microfusion/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.parent_gun = src
	cell.chargerate = 300
	if(!dead_cell)
		cell.give(cell.maxcharge)
	if(phase_emitter_type)
		phase_emitter = new phase_emitter_type(src)
	else
		phase_emitter = new(src)
	phase_emitter.parent_gun = src
	update_microfusion_lens()
	recharge_newshot()
	update_appearance()
	START_PROCESSING(SSobj, src)

/obj/item/gun/microfusion/Destroy()
	chambered = null
	QDEL_NULL(microfusion_lens)
	if(cell)
		cell.parent_gun = null
		QDEL_NULL(cell)
	if(length(attachments))
		for(var/obj/item/iterating_item as anything in attachments)
			qdel(iterating_item)
		attachments = null
	QDEL_NULL(phase_emitter)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/microfusion/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null
		update_appearance()
	else if(gone == phase_emitter)
		phase_emitter = null
		update_appearance()

/obj/item/gun/microfusion/get_cell()
	return cell

/obj/item/gun/microfusion/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS) && cell)
		cell.use(round(cell.charge / severity))
		chambered = null //we empty the chamber
		recharge_newshot() //and try to charge a new shot
		update_appearance()

/obj/item/gun/microfusion/can_shoot()
	if(QDELETED(cell) || !microfusion_lens)
		return FALSE
	return cell.charge >= (microfusion_lens.e_cost + extra_power_usage)

/obj/item/gun/microfusion/recharge_newshot()
	if(!microfusion_lens || !cell || !phase_emitter)
		return
	if(cell.charge < microfusion_lens.e_cost + extra_power_usage)
		return
	chambered = microfusion_lens
	if(!chambered.BB)
		chambered.newshot()

/obj/item/gun/microfusion/process_chamber()
	if(chambered && !chambered.BB && cell) //if BB is null, i.e the shot has been fired...
		cell.use(microfusion_lens.e_cost + extra_power_usage) //... drain the cell
		if(!cell?.stabilised && prob(40))
			do_sparks(2, FALSE, src) //Microfusion guns create sparks!
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/microfusion/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	// check to see if the emitter prevents us from firing before anything else
	var/attempted_shot = process_emitter()
	if(attempted_shot != SHOT_SUCCESS)
		if(user)
			balloon_alert(user, attempted_shot)
		return FALSE
	if(!chambered && can_shoot())
		process_chamber() // If the gun was drained and then recharged, load a new shot.
	// The emitter slows the gun down when hot or damaged, this delays both the burst and the next shot
	var/base_fire_delay = fire_delay
	fire_delay += phase_emitter.fire_delay
	. = ..()
	fire_delay = base_fire_delay

/obj/item/gun/microfusion/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override = "", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!can_shoot())
		firing_burst = FALSE
		return FALSE
	if(!chambered)
		process_chamber() // Ditto.
	return ..()

/obj/item/gun/microfusion/before_firing(atom/target, mob/user, aimed)
	. = ..()
	process_microfusion()

/obj/item/gun/microfusion/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	if(!phase_emitter)
		return
	phase_emitter.add_heat(heat_per_shot)
	if(phase_emitter.current_heat > phase_emitter.max_heat && ishuman(user))
		var/mob/living/carbon/human/human = user
		var/obj/item/bodypart/affecting = human.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		if(affecting?.receive_damage(0, 5))
			to_chat(user, "<span class='warning'>[src] parzy cię w dłoń, jest za gorący!</span>")

/obj/item/gun/microfusion/process(delta_time)
	for(var/obj/item/microfusion_gun_attachment/attached as anything in attachments)
		attached.process_attachment(src, delta_time)

/obj/item/gun/microfusion/update_overlays()
	. = ..()
	if(!phase_emitter)
		. += "[icon_state]_phase_emitter_missing"
	else if(phase_emitter.damaged)
		. += "[icon_state]_phase_emitter_damaged"
	else if(cell)
		var/ratio = get_charge_ratio()
		if(ratio == 0 && display_empty)
			. += "[icon_state]_empty"
		else if(shaded_charge)
			. += "[icon_state]_charge[ratio]_[phase_emitter.icon_state]"
	else
		. += "[icon_state]_phase_emitter_missing"

	for(var/obj/item/microfusion_gun_attachment/microfusion_gun_attachment as anything in attachments)
		. += "[icon_state]_[microfusion_gun_attachment.attachment_overlay_icon_state]"

/obj/item/gun/microfusion/ignition_effect(atom/to_ignite, mob/living/user)
	if(!can_shoot() || !microfusion_lens)
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/item/projectile/loaded_projectile = microfusion_lens.BB
		if(!loaded_projectile)
			. = ""
		else if(loaded_projectile.nodamage || !loaded_projectile.damage || loaded_projectile.damage_type == STAMINA)
			user.visible_message("<span class='danger'>[user] próbuje zapalić [to_ignite] za pomocą [src], ale nic się nie dzieje. Głupek.</span>")
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost + extra_power_usage)
			. = ""
		else if(loaded_projectile.damage_type != BURN)
			user.visible_message("<span class='danger'>[user] próbuje zapalić [to_ignite] za pomocą [src], ale udaje mu się jedynie doszczętnie to zniszczyć. Głupek.</span>")
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost + extra_power_usage)
			qdel(to_ignite)
			. = ""
		else
			playsound(user, microfusion_lens.fire_sound, 50, TRUE)
			playsound(user, loaded_projectile.hitsound, 50, TRUE)
			cell.use(microfusion_lens.e_cost + extra_power_usage)
			. = "<span class='danger'>[user] od niechcenia zapala [to_ignite] za pomocą [src]. No nieźle.</span>"

/obj/item/gun/microfusion/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, base_cell_type))
		insert_cell(user, attacking_item)
		return TRUE
	if(istype(attacking_item, /obj/item/microfusion_gun_attachment))
		add_attachment(attacking_item, user)
		return TRUE
	if(istype(attacking_item, base_phase_emitter_type))
		insert_phase_emitter(attacking_item, user)
		return TRUE
	return ..()

/obj/item/gun/microfusion/attack_hand(mob/user, list/modifiers)
	if(loc == user && user.is_holding(src) && cell)
		eject_cell(user)
		return
	return ..()

/obj/item/gun/microfusion/crowbar_act(mob/living/user, obj/item/tool)
	if(!phase_emitter)
		balloon_alert(user, "brak emitera fazowego!")
		return TRUE
	playsound(src, 'sound/items/crowbar.ogg', 70, TRUE)
	remove_phase_emitter(user)
	return TRUE

/obj/item/gun/microfusion/AltClick(mob/user)
	if(!length(attachments) || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	var/obj/item/microfusion_gun_attachment/to_remove = tgui_input_list(user, "Który dodatek chcesz zdjąć?", "Zdejmij dodatek", sortNames(attachments))
	if(!to_remove || !(to_remove in attachments) || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	remove_attachment(to_remove, user)
	return TRUE

/obj/item/gun/microfusion/proc/remove_all_attachments()
	if(!length(attachments))
		return
	for(var/obj/item/microfusion_gun_attachment/attachment as anything in attachments)
		if(!(attachment in attachments)) // the rail removes everything else when it comes off
			continue
		attachments -= attachment
		attachment.remove_attachment(src)
		attachment.forceMove(get_turf(src))
	update_appearance()

/obj/item/gun/microfusion/examine(mob/user)
	. = ..()
	if(length(attachments))
		for(var/obj/item/microfusion_gun_attachment/microfusion_gun_attachment as anything in attachments)
			. += "<span class='notice'>Zamontowano: [microfusion_gun_attachment.name].</span>"
		. += "<span class='notice'><b>Alt+klik</b> zdejmuje dodatek.</span>"
	if(phase_emitter)
		. += "<span class='notice'>Ma zamontowany [phase_emitter.name], nagrzany do <b>[phase_emitter.get_heat_percent()]%</b>.</span>"
		. += "<span class='notice'>Integralność emitera: <b>[phase_emitter.integrity]%</b>.</span>"
		. += "<span class='notice'>Dławienie termiczne włącza się przy <b>[phase_emitter.throttle_percentage]%</b> nagrzania.</span>"
		. += "<span class='notice'>Emiter fazowy wyjmiesz <b>łomem</b>.</span>"
	else
		. += "<span class='danger'>Nie ma zamontowanego emitera fazowego!</span>"

	if(cell)
		. += "<span class='notice'>Ma włożone [cell.name], naładowane do <b>[cell.charge]/[cell.maxcharge] MF</b>.</span>"
	. += "<span class='notice'>Użyj w ręce, żeby otworzyć panel sterowania.</span>"

/obj/item/gun/microfusion/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message("<span class='suicide'>[user] wkłada lufę [src] do ust. Wygląda na to, że próbuje popełnić samobójstwo!</span>")
		sleep(2.5 SECONDS)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] wypala sobie twarz z [src]!</span>")
			playsound(loc, fire_sound, 50, TRUE, -1)
			cell.use(microfusion_lens.e_cost + extra_power_usage)
			update_appearance()
			return FIRELOSS
		else
			user.visible_message("<span class='suicide'>[user] wpada w panikę i zaczyna się dusić!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] udaje, że wypala sobie twarz z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return OXYLOSS

/obj/item/gun/microfusion/proc/process_microfusion()
	for(var/obj/item/microfusion_gun_attachment/attachment as anything in attachments)
		attachment.process_fire(src, chambered)
	return TRUE

/obj/item/gun/microfusion/proc/process_emitter()
	if(!phase_emitter)
		return SHOT_FAILURE_NO_EMITTER
	var/phase_emitter_process = phase_emitter.check_emitter()
	if(phase_emitter_process != SHOT_SUCCESS)
		return phase_emitter_process
	return SHOT_SUCCESS

///Used by update_overlays()
/obj/item/gun/microfusion/proc/get_charge_ratio()
	// Sets the ratio to 0 if the gun doesn't have enough charge to fire, or if its power cell is removed.
	return can_shoot() ? CEILING(clamp(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1) : 0

/// Reloads the chambered shot, so a changed projectile type applies to the next shot
/obj/item/gun/microfusion/proc/refresh_shot()
	if(!microfusion_lens?.BB)
		return
	QDEL_NULL(microfusion_lens.BB)
	microfusion_lens.newshot()

/obj/item/gun/microfusion/proc/update_microfusion_lens()
	if(!microfusion_lens)
		microfusion_lens = new(src)
	fire_sound = microfusion_lens.fire_sound
	fire_sound_volume = microfusion_lens.fire_sound_volume
	fire_delay = microfusion_lens.delay

// Cell, emitter and upgrade interactions

/obj/item/gun/microfusion/proc/remove_phase_emitter(mob/user)
	var/obj/item/microfusion_phase_emitter/old_emitter = phase_emitter
	playsound(src, sound_cell_insert, 50, TRUE)
	old_emitter.forceMove(get_turf(src))
	if(user)
		user.put_in_hands(old_emitter)
		balloon_alert(user, "wyjęto emiter fazowy")
	old_emitter.parent_gun = null
	phase_emitter = null
	update_appearance()

/obj/item/gun/microfusion/proc/insert_phase_emitter(obj/item/microfusion_phase_emitter/inserting_phase_emitter, mob/living/user)
	if(phase_emitter)
		balloon_alert(user, "emiter już jest!")
		return FALSE
	if(!user.transferItemToLoc(inserting_phase_emitter, src))
		return FALSE
	balloon_alert(user, "włożono emiter fazowy")
	playsound(src, sound_cell_remove, 50, TRUE)
	phase_emitter = inserting_phase_emitter
	phase_emitter.parent_gun = src
	recharge_newshot()
	update_appearance()
	return TRUE

/// Try to insert the cell into the gun, if successful, return TRUE
/obj/item/gun/microfusion/proc/insert_cell(mob/user, obj/item/stock_parts/cell/microfusion/inserting_cell, display_message = TRUE)
	if(inserting_cell.charge)
		balloon_alert(user, "nie włożysz naładowanego ogniwa!")
		return FALSE
	var/obj/item/stock_parts/cell/microfusion/old_cell = cell
	if(!user.transferItemToLoc(inserting_cell, src))
		return FALSE
	if(display_message)
		balloon_alert(user, "włożono ogniwo")
	if(old_cell)
		eject_cell(user, FALSE, FALSE)
	if(sound_cell_insert)
		playsound(src, sound_cell_insert, sound_cell_insert_volume, sound_cell_insert_vary)
	cell = inserting_cell
	inserting_cell.inserted_into_weapon()
	cell.parent_gun = src
	if(old_cell)
		user.put_in_hands(old_cell)
	recharge_newshot()
	update_appearance()
	return TRUE

/// Ejecting a cell.
/obj/item/gun/microfusion/proc/eject_cell(mob/user, display_message = TRUE, put_in_hands = TRUE)
	var/obj/item/stock_parts/cell/microfusion/old_cell = cell
	old_cell.forceMove(get_turf(src))
	old_cell.cell_removal_discharge()
	if(user)
		if(put_in_hands)
			user.put_in_hands(old_cell)
		if(display_message)
			balloon_alert(user, "wyjęto ogniwo")
	if(sound_cell_remove)
		playsound(src, sound_cell_remove, sound_cell_remove_volume, sound_cell_remove_vary)
	old_cell.update_appearance()
	old_cell.parent_gun = null
	cell = null
	chambered = null
	update_appearance()

/// Attatching an upgrade.
/obj/item/gun/microfusion/proc/add_attachment(obj/item/microfusion_gun_attachment/microfusion_gun_attachment, mob/living/user)
	if(is_type_in_list(microfusion_gun_attachment, attachments))
		balloon_alert(user, "już jest taki!")
		return FALSE
	if(!(microfusion_gun_attachment.slot in attachment_slots))
		balloon_alert(user, "nie da się zamontować!")
		return FALSE
	for(var/obj/item/microfusion_gun_attachment/iterating_attachment as anything in attachments)
		if(is_type_in_list(microfusion_gun_attachment, iterating_attachment.incompatible_attachments) || is_type_in_list(iterating_attachment, microfusion_gun_attachment.incompatible_attachments))
			balloon_alert(user, "niezgodne z: [iterating_attachment]!")
			return FALSE
		if(iterating_attachment.slot != GUN_SLOT_UNIQUE && iterating_attachment.slot == microfusion_gun_attachment.slot)
			balloon_alert(user, "slot zajęty!")
			return FALSE
	if(!user.transferItemToLoc(microfusion_gun_attachment, src))
		return FALSE
	attachments += microfusion_gun_attachment
	microfusion_gun_attachment.run_attachment(src)
	balloon_alert(user, "zamontowano dodatek")
	playsound(src, 'sound/effects/pop.ogg', 70, TRUE)
	return TRUE

/obj/item/gun/microfusion/proc/remove_attachment(obj/item/microfusion_gun_attachment/microfusion_gun_attachment, mob/living/user)
	if(user)
		balloon_alert(user, "zdjęto dodatek")
	playsound(src, 'sound/items/screwdriver.ogg', 70)
	attachments -= microfusion_gun_attachment
	microfusion_gun_attachment.forceMove(get_turf(src))
	microfusion_gun_attachment.remove_attachment(src)
	user?.put_in_hands(microfusion_gun_attachment)
	update_appearance()

/// Recalculates the spread, based on attachment-provided values.
/obj/item/gun/microfusion/proc/recalculate_spread()
	spread = max(0, attachment_spread)

/// Recalculates the recoil, based on attachment-provided values.
/obj/item/gun/microfusion/proc/recalculate_recoil()
	recoil = max(0, attachment_recoil)

// UI CONTROL

/obj/item/gun/microfusion/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MicrofusionGunControl")
		ui.set_autoupdate(TRUE) // heat and charge change on their own
		ui.open()

/obj/item/gun/microfusion/ui_data(mob/user)
	var/list/data = list()

	data["gun_name"] = name
	data["gun_desc"] = desc
	data["gun_heat_dissipation"] = heat_dissipation_bonus

	if(phase_emitter)
		data["has_emitter"] = TRUE
		data["phase_emitter_data"] = list(
			"type" = capitalize(phase_emitter.name),
			"integrity" = phase_emitter.integrity,
			"current_heat" = phase_emitter.current_heat,
			"throttle_percentage" = phase_emitter.throttle_percentage,
			"heat_dissipation_per_tick" = phase_emitter.heat_dissipation_per_tick,
			"max_heat" = phase_emitter.max_heat,
			"damaged" = phase_emitter.damaged,
			"hacked" = phase_emitter.hacked,
			"heat_percent" = phase_emitter.get_heat_percent(),
			"process_time" = phase_emitter.fire_delay,
			"cooling_system" = phase_emitter.cooling_system,
			"cooling_system_rate" = phase_emitter.cooling_system_rate,
		)
	else
		data["has_emitter"] = FALSE

	if(cell)
		var/list/cell_attachments = list()
		for(var/obj/item/microfusion_cell_attachment/attachment as anything in cell.attachments)
			cell_attachments += attachment.name
		data["has_cell"] = TRUE
		data["cell_data"] = list(
			"type" = capitalize(cell.name),
			"charge" = cell.charge,
			"max_charge" = cell.maxcharge,
			"status" = cell.meltdown,
			"attachments" = cell_attachments,
		)
	else
		data["has_cell"] = FALSE

	if(length(attachments))
		data["has_attachments"] = TRUE
		data["attachments"] = list()
		for(var/obj/item/microfusion_gun_attachment/attachment as anything in attachments)
			var/list/attachment_functions = attachment.get_modify_data()
			data["attachments"] += list(list(
				"name" = uppertext(attachment.name),
				"desc" = attachment.desc,
				"slot" = capitalize(attachment.slot),
				"information" = attachment.get_information_data(),
				"has_modifications" = length(attachment_functions) > 0,
				"modify" = attachment_functions,
				"ref" = REF(attachment),
			))
	else
		data["has_attachments"] = FALSE

	return data

/obj/item/gun/microfusion/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_cell")
			if(!cell)
				return
			eject_cell(usr)
			return TRUE
		if("overclock_emitter")
			if(!phase_emitter?.hacked)
				return
			phase_emitter.set_overclock(usr)
			return TRUE
		if("eject_emitter")
			if(!phase_emitter)
				return
			remove_phase_emitter(usr)
			return TRUE
		if("remove_attachment")
			var/obj/item/microfusion_gun_attachment/to_remove = locate(params["attachment_ref"]) in attachments
			if(!to_remove)
				return
			remove_attachment(to_remove, usr)
			return TRUE
		if("modify_attachment")
			var/obj/item/microfusion_gun_attachment/to_modify = locate(params["attachment_ref"]) in attachments
			if(!to_modify)
				return
			to_modify.run_modify_data(params["modify_ref"], usr, src)
			return TRUE
		if("toggle_cooling_system")
			if(!phase_emitter)
				return
			phase_emitter.toggle_cooling_system(usr)
			return TRUE
