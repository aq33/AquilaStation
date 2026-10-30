//Supply modules for MODsuits

///Internal GPS - Extends a GPS you can use.
/obj/item/mod/module/gps
	name = "moduł wewnętrznego GPS MOD"
	desc = "Ten moduł korzysta z powszechnej technologii Nanotrasenu, by obliczyć położenie użytkownika w dowolnym miejscu kosmosu \
		co do dokładnych współrzędnych. Te informacje trafiają do centralnej bazy danych widocznej z samego urządzenia, \
		ale czy użyjesz ich, by pomagać ludziom, zależy od ciebie."
	icon_state = "gps"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/gps)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE

/obj/item/mod/module/gps/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps/item, "MOD0", state = GLOB.deep_inventory_state, overlay_state = FALSE)

/obj/item/mod/module/gps/on_use()
	attack_self(mod.wearer)

///Hydraulic Clamp - Lets you pick up and drop crates.
/obj/item/mod/module/clamp
	name = "moduł chwytaka hydraulicznego MOD"
	desc = "Zestaw siłowników zamontowanych w obu ramionach skafandra, o udźwigu niemal tony. \
		Nanotrasen zablokował jednak ten projekt tak, by służył głównie do podnoszenia skrzyń. \
		Wiele osób powie, że załadunek towarów to nudna praca, ale nie możesz się z tym bardziej nie zgodzić."
	icon_state = "clamp"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/clamp)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_clamp"
	overlay_state_active = "module_clamp_on"
	required_slots = list(ITEM_SLOT_GLOVES, ITEM_SLOT_BACK)
	/// Time it takes to load a crate.
	var/load_time = 3 SECONDS
	/// The max amount of crates you can carry.
	var/max_crates = 3
	/// The crates stored in the module.
	var/list/stored_crates = list()

/obj/item/mod/module/clamp/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /obj/structure/closet/crate) || istype(target, /obj/structure/big_delivery))
		var/atom/movable/picked_crate = target
		if(!check_crate_pickup(picked_crate))
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "przerwano!")
			return
		if(!check_crate_pickup(picked_crate))
			return
		stored_crates += picked_crate
		picked_crate.forceMove(src)
		balloon_alert(mod.wearer, "podniesiono skrzynię")
		drain_power(use_power_cost)
	else if(length(stored_crates))
		var/turf/target_turf = get_turf(target)
		if(is_blocked_turf(target_turf))
			return
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		if(!do_after(mod.wearer, load_time, target = target))
			balloon_alert(mod.wearer, "przerwano!")
			return
		if(is_blocked_turf(target_turf))
			return
		var/atom/movable/dropped_crate = pop(stored_crates)
		dropped_crate.forceMove(target_turf)
		balloon_alert(mod.wearer, "upuszczono: [dropped_crate]")
		drain_power(use_power_cost)
	else
		balloon_alert(mod.wearer, "nieprawidłowy cel!")

/obj/item/mod/module/clamp/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	for(var/atom/movable/crate as anything in stored_crates)
		crate.forceMove(drop_location())
		stored_crates -= crate

/obj/item/mod/module/clamp/proc/check_crate_pickup(atom/movable/target)
	if(length(stored_crates) >= max_crates)
		balloon_alert(mod.wearer, "za dużo skrzyń!")
		return FALSE
	for(var/mob/living/mob in target.GetAllContents())
		if(mob.mob_size < MOB_SIZE_HUMAN)
			continue
		balloon_alert(mod.wearer, "skrzynia za ciężka!")
		return FALSE
	return TRUE

/obj/item/mod/module/clamp/loader
	name = "moduł chwytaka hydraulicznego ładowacza MOD"
	icon_state = "clamp_loader"
	complexity = 0
	removable = FALSE
	overlay_state_inactive = null
	overlay_state_active = "module_clamp_loader"
	load_time = 1 SECONDS
	max_crates = 5
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

///Drill - Lets you dig through rock and basalt.
/obj/item/mod/module/drill
	name = "moduł wiertła MOD"
	desc = "Zintegrowane wiertło, zwykle wysuwające się nad dłoń użytkownika. Przydaje się do wiercenia w skale, \
		ale twoje wiertło z pewnością jest tym, które przebija niebiosa i je tworzy."
	icon_state = "drill"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/drill)
	cooldown_time = 0.5 SECONDS
	overlay_state_active = "module_drill"

/obj/item/mod/module/drill/on_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP, PROC_REF(bump_mine))

/obj/item/mod/module/drill/on_deactivation(display_message = TRUE, deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_BUMP)

/obj/item/mod/module/drill/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(mod.wearer)
		drain_power(use_power_cost)
	else if(istype(target, /turf/open/floor/plating/asteroid))
		var/turf/open/floor/plating/asteroid/sand_turf = target
		if(!sand_turf.can_dig(mod.wearer))
			return
		sand_turf.getDug()
		drain_power(use_power_cost)

/obj/item/mod/module/drill/proc/bump_mine(mob/living/carbon/human/bumper, atom/bumped_into, proximity)
	SIGNAL_HANDLER
	if(!istype(bumped_into, /turf/closed/mineral) || !drain_power(use_power_cost))
		return
	var/turf/closed/mineral/mineral_turf = bumped_into
	mineral_turf.gets_drilled(mod.wearer)
	return COMPONENT_CANCEL_ATTACK_CHAIN

///Ore Bag - Lets you pick up ores and drop them from the suit.
/obj/item/mod/module/orebag
	name = "moduł torby na rudę MOD"
	desc = "Zintegrowany system przechowywania rudy zamontowany w skafandrze; \
		precyzyjne elektromagnesy i schowki automatycznie zbierają i składują rudę. \
		Nakamura Engineering zaleca, by faktycznie oddawać tę rudę w lokalnych rafineriach."
	icon_state = "ore"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/orebag)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	required_slots = list(ITEM_SLOT_BACK)
	/// The ores stored in the bag.
	var/list/ores = list()

/obj/item/mod/module/orebag/on_equip()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(ore_pickup))

/obj/item/mod/module/orebag/on_unequip()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/orebag/proc/ore_pickup(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/stack/ore/ore in get_turf(mod.wearer))
		INVOKE_ASYNC(src, PROC_REF(move_ore), ore)
		playsound(src, "rustle", 50, TRUE)

/obj/item/mod/module/orebag/proc/move_ore(obj/item/stack/ore)
	for(var/obj/item/stack/stored_ore as anything in ores)
		if(!ore.merge_check(stored_ore))
			continue
		ore.merge(stored_ore)
		if(QDELETED(ore))
			return
		break
	ore.forceMove(src)
	ores += ore

/obj/item/mod/module/orebag/on_use()
	for(var/obj/item/ore as anything in ores)
		ore.forceMove(drop_location())
		ores -= ore
	drain_power(use_power_cost)

/obj/item/mod/module/hydraulic
	name = "moduł hydraulicznych ramion ładowacza MOD"
	desc = "Para potężnych ramion hydraulicznych zamontowanych w MODsuicie."
	icon_state = "launch_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN*10
	incompatible_modules = list(/obj/item/mod/module/hydraulic)
	cooldown_time = 4 SECONDS
	overlay_state_inactive = "module_hydraulic"
	overlay_state_active = "module_hydraulic_active"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)
	/// Time it takes to launch
	var/launch_time = 2 SECONDS
	/// User overlay
	var/mutable_appearance/lightning

/obj/item/mod/module/hydraulic/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/atom/game_renderer = mod.wearer.hud_used.plane_masters["[GAME_PLANE]"]
	var/matrix/render_matrix = matrix(game_renderer.transform)
	render_matrix.Scale(1.25, 1.25)
	animate(game_renderer, launch_time, flags = SINE_EASING|EASE_IN, transform = render_matrix)
	var/current_time = world.time
	mod.wearer.visible_message(span_warning("[mod.wearer] zaczyna furkotać!"), \
		blind_message = span_hear("Słyszysz furkot."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	lightning = mutable_appearance('icons/effects/effects.dmi', "electricity3", plane = -3)
	mod.wearer.add_overlay(lightning)
	balloon_alert(mod.wearer, "zaczynasz ładowanie...")
	var/power = launch_time
	if(!do_after(mod.wearer, launch_time, target = mod))
		power = world.time - current_time
		animate(game_renderer)
	drain_power(use_power_cost)
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	game_renderer.transform = game_renderer.transform.Scale(0.8, 0.8)
	mod.wearer.cut_overlay(lightning)
	var/angle = get_angle(mod.wearer, target)
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	mod.wearer.throw_at(get_ranged_target_turf_direct(mod.wearer, target, power), \
		range = power, speed = max(round(0.2*power), 1), thrower = mod.wearer, spin = FALSE, \
		callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/hydraulic/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)

/obj/item/mod/module/disposal_connector
	name = "moduł wyboru zsypu MOD"
	desc = "Moduł, który łączy się z rurami zsypu i wysyła użytkownika do zsypu wybranego w konfiguracji. \
		Działa chyba tylko przy włączonym skafandrze."
	icon_state = "disposal"
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/disposal_connector)
	var/disposal_tag = NONE

/obj/item/mod/module/disposal_connector/Initialize(mapload)
	. = ..()
	disposal_tag = pick(GLOB.TAGGERLOCATIONS)

/obj/item/mod/module/disposal_connector/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposal_handling))

/obj/item/mod/module/disposal_connector/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_DISPOSING)

/obj/item/mod/module/disposal_connector/get_configuration()
	. = ..()
	.["disposal_tag"] = add_ui_configuration("Cel zsypu", "list", GLOB.TAGGERLOCATIONS[disposal_tag], GLOB.TAGGERLOCATIONS)

/obj/item/mod/module/disposal_connector/configure_edit(key, value)
	switch(key)
		if("disposal_tag")
			for(var/tag in 1 to length(GLOB.TAGGERLOCATIONS))
				if(GLOB.TAGGERLOCATIONS[tag] == value)
					disposal_tag = tag
					break

/obj/item/mod/module/disposal_connector/proc/disposal_handling(datum/disposal_source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_machine, hasmob)
	SIGNAL_HANDLER

	disposal_holder.destinationTag = disposal_tag

/obj/item/mod/module/magnet
	name = "moduł hydraulicznego magnesu ładowacza MOD"
	desc = "Potężny hydrauliczny elektromagnes, który przyciąga skrzynie i szafki do użytkownika i trzyma je przy nim."
	icon_state = "magnet_loader"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/magnet)
	cooldown_time = 1.5 SECONDS
	overlay_state_active = "module_magnet"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/magnet/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		var/obj/structure/closet/locker = mod.wearer.pulling
		playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
		locker.forceMove(mod.wearer.loc)
		locker.throw_at(target, range = 7, speed = 4, thrower = mod.wearer)
		return
	if(!istype(target, /obj/structure/closet) || !(target in view(mod.wearer)))
		balloon_alert(mod.wearer, "nieprawidłowy cel!")
		return
	var/obj/structure/closet/locker = target
	if(locker.anchored || locker.move_resist >= MOVE_FORCE_OVERPOWERING)
		balloon_alert(mod.wearer, "cel jest przytwierdzony!")
		return
	new /obj/effect/temp_visual/mook_dust(get_turf(locker))
	playsound(locker, 'sound/effects/gravhit.ogg', 75, TRUE)
	locker.throw_at(mod.wearer, range = 7, speed = 3, force = MOVE_FORCE_WEAK, \
		callback = CALLBACK(src, PROC_REF(check_locker), locker))

/obj/item/mod/module/magnet/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(istype(mod.wearer.pulling, /obj/structure/closet))
		mod.wearer.stop_pulling()

/obj/item/mod/module/magnet/proc/check_locker(obj/structure/closet/locker)
	if(!mod?.wearer)
		return
	if(!locker.Adjacent(mod.wearer) || !isturf(locker.loc) || !isturf(mod.wearer.loc))
		return
	mod.wearer.start_pulling(locker)

/obj/item/mod/module/ash_accretion
	name = "moduł narastania popiołu MOD"
	desc = "Moduł, który zbiera popiół z terenu i pokrywa nim skafander jako warstwą ochronną; ta warstwa \
		znika przy poruszaniu się po zwykłym terenie."
	icon_state = "ash_accretion"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/ash_accretion)
	overlay_state_inactive = "module_ash"
	use_mod_colors = TRUE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// How many tiles we can travel to max out the armor.
	var/max_traveled_tiles = 10
	/// How many tiles we traveled through.
	var/traveled_tiles = 0
	/// Armor values per tile.
	var/list/armor_mod = list("melee" = 4, "bullet" = 1, "laser" = 2, "energy" = 2, "bomb" = 4)
	/// Speed added when you're fully covered in ash.
	var/speed_added = -0.5
	/// Turfs that let us accrete ash.
	var/static/list/accretion_turfs
	/// Turfs that let us keep ash.
	var/static/list/keep_turfs

/obj/item/mod/module/ash_accretion/Initialize(mapload)
	. = ..()
	if(!accretion_turfs)
		accretion_turfs = typecacheof(list(
			/turf/open/floor/plating/asteroid,
			/turf/open/floor/plating/ashplanet,
			/turf/open/floor/plating/dirt,
		))
	if(!keep_turfs)
		keep_turfs = typecacheof(list(
			/turf/open/floor/plating/grass,
			/turf/open/floor/plating/snowed,
			//turf/open/floor/plating/sandy_dirt,
			/turf/open/floor/plating/ironsand,
			/turf/open/floor/plating/ice,
			/turf/open/indestructible/hierophant,
			/turf/open/indestructible/boss,
			/turf/open/indestructible/necropolis,
			/turf/open/lava,
			/turf/open/water,
		))

/obj/item/mod/module/ash_accretion/on_part_activation()
	mod.wearer.weather_immunities += "ash"
	mod.wearer.weather_immunities += "snow"
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/ash_accretion/on_part_deactivation(deleting = FALSE)
	mod.wearer.weather_immunities -= "ash"
	mod.wearer.weather_immunities -= "snow"
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)
	if(!traveled_tiles)
		return
	var/list/to_remove = list()
	for(var/rating in armor_mod)
		to_remove[rating] = armor_mod[rating] * traveled_tiles
	var/datum/armor/removed_armor = getArmor(arglist(to_remove))
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.armor = part.armor.detachArmor(removed_armor)
	if(traveled_tiles == max_traveled_tiles)
		mod.update_speed()
	traveled_tiles = 0

/obj/item/mod/module/ash_accretion/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	return ..()

/obj/item/mod/module/ash_accretion/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (traveled_tiles == max_traveled_tiles)
		module_slowdowns += speed_added

/obj/item/mod/module/ash_accretion/proc/on_move(atom/source, atom/oldloc, dir, forced)
	if(!isturf(mod.wearer.loc)) //dont lose ash from going in a locker
		return
	if(traveled_tiles) //leave ash every tile
		new /obj/effect/temp_visual/light_ash(get_turf(src))
	if(is_type_in_typecache(mod.wearer.loc, accretion_turfs))
		if(traveled_tiles >= max_traveled_tiles)
			return
		traveled_tiles++
		var/datum/armor/added_armor = getArmor(arglist(armor_mod))
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			part.armor = part.armor.attachArmor(added_armor)
		if(traveled_tiles >= max_traveled_tiles)
			balloon_alert(mod.wearer, "w pełni pokryty popiołem")
			mod.wearer.color = list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,3) //make them super light
			animate(mod.wearer, 1 SECONDS, color = null, flags = ANIMATION_PARALLEL)
			playsound(src, 'sound/effects/sparks1.ogg', 100, TRUE)
			mod.update_speed()
	else if(is_type_in_typecache(mod.wearer.loc, keep_turfs))
		return
	else
		if(traveled_tiles <= 0)
			return
		traveled_tiles--
		if(traveled_tiles == max_traveled_tiles - 1) // Just lost our speed buff
			mod.update_speed()
		var/datum/armor/removed_armor = getArmor(arglist(armor_mod))
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			part.armor = part.armor.detachArmor(removed_armor)
		if(traveled_tiles <= 0)
			balloon_alert(mod.wearer, "skończył się popiół!")

/obj/item/mod/module/sphere_transform
	name = "moduł przemiany w kulę MOD"
	desc = "Moduł, który potrafi przestawiać części skafandra, zmieniając go razem z użytkownikiem w kulę. \
		Kula porusza się szybko, nawet po lawie, i wystrzeliwuje bomby górnicze, które dziesiątkują teren."
	icon_state = "sphere"
	module_type = MODULE_ACTIVE
	removable = FALSE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/sphere_transform)
	cooldown_time = 1.25 SECONDS
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Time it takes us to complete the animation.
	var/animate_time = 0.25 SECONDS

/obj/item/mod/module/sphere_transform/activate()
	if(!mod.wearer.has_gravity())
		balloon_alert(mod.wearer, "brak grawitacji!")
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_activation()
	playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE)
	mod.wearer.add_filter("mod_ball", 1, alpha_mask_filter(icon = icon('icons/mob/clothing/modsuit/mod_modules.dmi', "ball_mask"), flags = MASK_INVERSE))
	mod.wearer.add_filter("mod_blur", 2, angular_blur_filter(size = 15))
	mod.wearer.add_filter("mod_outline", 3, outline_filter(color = "#000000AA"))
	mod.wearer.base_pixel_y -= 4
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.base_pixel_y, flags = ANIMATION_PARALLEL)
	mod.wearer.SpinAnimation(1.5)
	mod.wearer.weather_immunities += "lava"
	ADD_TRAIT(mod.wearer, TRAIT_HANDS_BLOCKED, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_FORCED_STANDING, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPALL, REF(src))
	mod.wearer.add_movespeed_modifier(MOVESPEED_ID_MOD_SPHERE, update = TRUE, priority = 100, multiplicative_slowdown = -0.5)
	RegisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE, PROC_REF(on_statchange))

/obj/item/mod/module/sphere_transform/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/items/modsuit/ballin.ogg', 100, TRUE, frequency = -1)
	mod.wearer.base_pixel_y = 0
	animate(mod.wearer, animate_time, pixel_y = mod.wearer.base_pixel_y)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, remove_filter), list("mod_ball", "mod_blur", "mod_outline")), animate_time)
	mod.wearer.weather_immunities -= "lava"
	REMOVE_TRAIT(mod.wearer, TRAIT_HANDS_BLOCKED, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_FORCED_STANDING, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPALL, REF(src))
	mod.wearer.remove_movespeed_modifier(MOVESPEED_ID_MOD_SPHERE)
	UnregisterSignal(mod.wearer, COMSIG_MOB_STATCHANGE)

/obj/item/mod/module/sphere_transform/used()
	if(!lavaland_equipment_pressure_check(get_turf(src)))
		balloon_alert(mod.wearer, "za wysokie ciśnienie!")
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/sphere_transform/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/item/projectile/bomb = new /obj/item/projectile/bullet/reusable/mining_bomb(mod.wearer.loc)
	bomb.preparePixelProjectile(target, mod.wearer)
	bomb.firer = mod.wearer
	playsound(src, 'sound/weapons/grenadelaunch.ogg', 75, TRUE)
	INVOKE_ASYNC(bomb, TYPE_PROC_REF(/obj/item/projectile, fire))
	drain_power(use_power_cost)

/obj/item/mod/module/sphere_transform/on_active_process(delta_time)
	animate(mod.wearer) //stop the animation
	mod.wearer.SpinAnimation(1.5) //start it back again
	if(!mod.wearer.has_gravity())
		deactivate() //deactivate in no grav

/obj/item/mod/module/sphere_transform/proc/on_statchange(datum/source)
	SIGNAL_HANDLER

	if(!mod.wearer.stat)
		return
	deactivate()

/obj/item/projectile/bullet/reusable/mining_bomb
	name = "bomba górnicza"
	desc = "Bomba. Czemu to oglądasz?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	nodamage = TRUE
	range = 6
	suppressed = TRUE
	flag = "bomb"
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_LIGHT_ORANGE
	ammo_type = /obj/structure/mining_bomb

/obj/structure/mining_bomb
	name = "bomba górnicza"
	desc = "Bomba. Czemu to oglądasz?"
	icon_state = "mine_bomb"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF|LAVA_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_LIGHT_ORANGE
	/// Time to prime the explosion
	var/prime_time = 0.5 SECONDS
	/// Time to explode from the priming
	var/explosion_time = 1 SECONDS
	/// Damage done on explosion.
	var/damage = 15
	/// Damage multiplier on hostile fauna.
	var/fauna_boost = 4
	/// Image overlaid on explosion.
	var/static/image/explosion_image

/obj/structure/mining_bomb/Initialize(mapload)
	. = ..()
	if(!explosion_image)
		explosion_image = image('icons/effects/96x96.dmi', "judicial_explosion")
		explosion_image.pixel_x = -32
		explosion_image.pixel_y = -32
		explosion_image.plane = GAME_PLANE
		explosion_image.layer = ABOVE_ALL_MOB_LAYER
	addtimer(CALLBACK(src, PROC_REF(prime)), prime_time)

/obj/structure/mining_bomb/proc/prime()
	add_overlay(explosion_image)
	addtimer(CALLBACK(src, PROC_REF(boom)), explosion_time)

/obj/structure/mining_bomb/proc/boom(atom/movable/firer)
	visible_message(span_danger("[src] wybucha!"))
	playsound(src, 'sound/magic/magic_missile.ogg', 200, vary = TRUE)
	for(var/turf/closed/mineral/rock in circlerangeturfs(src, 2))
		rock.gets_drilled()
	for(var/mob/living/mob in range(1, src))
		mob.apply_damage(12 * (ishostile(mob) ? fauna_boost : 1), BRUTE)
	for(var/obj/object in range(1, src))
		object.take_damage(damage, BRUTE, "bomb")
	qdel(src)
