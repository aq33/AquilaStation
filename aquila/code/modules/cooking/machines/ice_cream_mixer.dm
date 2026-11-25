// Mikser lodów: zamraża desery w misie do lodów i cukierki w foremkach. Na wzór Paradise
// (code/modules/cooking/machines/ice_cream_mixer.dm). Sprite: Paradise (icons/obj/cooking/machines.dmi, u nas w desserts.dmi), CC BY-SA 3.0.

/datum/cooking_surface/ice_cream_mixer
	name = "komora miksera"
	cooker_id = COOKER_ICE_CREAM
	allow_temp_change = FALSE
	can_burn = FALSE
	allowed_containers = list(/obj/item/reagent_containers/cooking/icecream_bowl, /obj/item/reagent_containers/cooking/mould)

/obj/machinery/ice_cream_mixer
	name = "mikser lodów"
	desc = "Przemysłowy mikser do deserów: lodów w misie i cukierków w foremkach."
	icon = 'aquila/icons/obj/food/cooking/desserts.dmi'
	icon_state = "ice_cream_mixer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	processing_flags = START_PROCESSING_MANUALLY
	circuit = /obj/item/circuitboard/machine/ice_cream_mixer
	var/datum/cooking_surface/ice_cream_mixer/chamber

/obj/machinery/ice_cream_mixer/Initialize(mapload)
	chamber = new(src)
	. = ..()
	refresh_kitchen_heat()
	update_appearance()

/obj/machinery/ice_cream_mixer/Destroy()
	// Naczynie wypada przez Exited(), które przywraca mu normalny wygląd
	chamber.container?.forceMove(drop_location())
	QDEL_NULL(chamber)
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/ice_cream_mixer/get_cooking_surfaces()
	return list(chamber)

/obj/machinery/ice_cream_mixer/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/ice_cream_mixer/examine(mob/user)
	. = ..()
	. += span_notice("[capitalize(chamber.describe())].")
	. += span_notice("Misę do lodów albo foremkę wkładasz kliknięciem, wyjmujesz pustą ręką, gdy mikser jest wyłączony. <b>Alt+klik</b>: włącz, wyłącz, minutnik.")

/obj/machinery/ice_cream_mixer/attackby(obj/item/used, mob/user, params)
	if(chamber.accepts(used))
		if(chamber.container)
			to_chat(user, span_warning("W mikserze już coś stoi."))
			return TRUE
		if(!user.transferItemToLoc(used, src))
			return TRUE
		place_container(used)
		to_chat(user, span_notice("Wkładasz [used] do miksera."))
		return TRUE
	if(istype(used, /obj/item/reagent_containers/cooking))
		to_chat(user, span_warning("[used] nie pasuje do miksera. Wkłada się do niego misę do lodów albo foremkę."))
		return TRUE
	// Składnik użyty na mikserze trafia do misy w środku
	if(chamber.container && !chamber.on && !user.combat_mode && !(used.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH)) && !istype(used, /obj/item/storage/part_replacer))
		return chamber.container.attackby(used, user, params)
	return ..()

/obj/machinery/ice_cream_mixer/proc/place_container(obj/item/reagent_containers/cooking/bowl)
	if(bowl.loc != src)
		bowl.forceMove(src)
	chamber.set_container(bowl)
	bowl.pixel_x = 0
	bowl.pixel_y = 2
	bowl.vis_flags |= VIS_INHERIT_PLANE
	bowl.make_mini()
	vis_contents += bowl
	update_appearance()

/obj/machinery/ice_cream_mixer/Exited(atom/movable/gone, direction)
	. = ..()
	if(!chamber || gone != chamber.container)
		return
	chamber.turn_off()
	update_mixer_processing()
	chamber.clear_container()
	var/obj/item/reagent_containers/cooking/bowl = gone
	vis_contents -= bowl
	bowl.vis_flags &= ~VIS_INHERIT_PLANE
	bowl.pixel_x = bowl.base_pixel_x
	bowl.pixel_y = bowl.base_pixel_y
	bowl.unmake_mini()
	update_appearance()

/obj/machinery/ice_cream_mixer/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !chamber.container)
		return
	if(chamber.on)
		to_chat(user, span_warning("Najpierw wyłącz mikser."))
		return TRUE
	var/obj/item/bowl = chamber.container
	if(!user.put_in_hands(bowl))
		bowl.forceMove(drop_location())
	return TRUE

/obj/machinery/ice_cream_mixer/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	cooking_settings_menu(src, user)
	update_mixer_processing()
	return TRUE

/obj/machinery/ice_cream_mixer/is_kitchen_active()
	return chamber.on

/obj/machinery/ice_cream_mixer/proc/update_mixer_processing()
	update_kitchen_heating()
	if(chamber.on)
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/ice_cream_mixer/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN) || !chamber.on)
		chamber.turn_off()
		update_mixer_processing()
		return
	chamber.process_cooking(delta_time, kitchen_heat_factor())
	use_power(active_power_usage / max(kitchen_heat.rating, 1))

/obj/machinery/ice_cream_mixer/update_overlays()
	. = ..()
	if(chamber?.on)
		. += mutable_appearance(icon, "ice_cream_mixer_door", ABOVE_OBJ_LAYER)
		. += mutable_appearance(icon, "ice_cream_mixer_on")
		. += emissive_appearance(icon, "ice_cream_mixer_on", alpha = src.alpha)
	else
		. += mutable_appearance(icon, "ice_cream_mixer_door_open", ABOVE_OBJ_LAYER)
	if(panel_open)
		. += mutable_appearance(icon, "ice_cream_mixer_openpanel")

/obj/machinery/ice_cream_mixer/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(chamber.on)
		to_chat(user, span_warning("Najpierw wyłącz mikser."))
		return
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	update_appearance()

/obj/machinery/ice_cream_mixer/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_deconstruction_crowbar(tool)

/obj/machinery/ice_cream_mixer/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool, 2 SECONDS)

/// Z misą do lodów w środku (do map)
/obj/machinery/ice_cream_mixer/loaded/Initialize(mapload)
	. = ..()
	place_container(new /obj/item/reagent_containers/cooking/icecream_bowl(src))

/obj/item/circuitboard/machine/ice_cream_mixer
	name = "mikser lodów (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/ice_cream_mixer
	req_components = list(/obj/item/stock_parts/micro_laser = 2, /obj/item/stock_parts/capacitor = 1)

/datum/design/board/ice_cream_mixer
	name = "Projekt maszyny (mikser lodów)"
	desc = "Płytka drukowana: mikser lodów do deserów i cukierków z foremek."
	id = "ice_cream_mixer"
	build_path = /obj/item/circuitboard/machine/ice_cream_mixer
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/// Patyczek do lodów: z drewnianej kłody w procesorze
/obj/item/popsicle_stick
	name = "patyczek do lodów"
	desc = "Mały drewniany patyczek. Zwykle tkwi w lodach na patyku."
	icon = 'aquila/icons/obj/food/cooking/desserts.dmi'
	icon_state = "popsicle_stick"
	w_class = WEIGHT_CLASS_TINY
	force = 0

/datum/food_processor_process/popsicle_stick
	input = /obj/item/grown/log
	output = /obj/item/popsicle_stick
	food_multiplier = 3

GLOBAL_VAR_INIT(candy_mould_recipes_added, FALSE)

/// Foremki na cukierki z plastiku (jak w Paradise). Wołane przy budowie menu craftingu i przy pierwszym arkuszu plastiku.
/proc/add_candy_mould_recipes()
	if(!GLOB.candy_mould_recipes_added)
		GLOB.plastic_recipes += new /datum/stack_recipe_list("foremki na cukierki", list(
			new /datum/stack_recipe("foremka w misie", /obj/item/reagent_containers/cooking/mould/bear, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w robaki", /obj/item/reagent_containers/cooking/mould/worm, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w fasolki", /obj/item/reagent_containers/cooking/mould/bean, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w kulki", /obj/item/reagent_containers/cooking/mould/ball, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w laski", /obj/item/reagent_containers/cooking/mould/cane, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w banknoty", /obj/item/reagent_containers/cooking/mould/cash, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka w monety", /obj/item/reagent_containers/cooking/mould/coin, 1, on_floor = TRUE),
			new /datum/stack_recipe("foremka na lizaki", /obj/item/reagent_containers/cooking/mould/loli, 1, on_floor = TRUE),
		))
		GLOB.candy_mould_recipes_added = TRUE

/obj/item/stack/sheet/plastic/Initialize(mapload, new_amount, merge = TRUE)
	add_candy_mould_recipes()
	return ..()
