/obj/item/grown/log
	seed = /obj/item/plant_seeds/preset/tower
	name = "kłoda z grzyba wieżowego"
	desc = "Jest lepsza niż zła, jest dobra!"
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	attack_verb = list("grzmoci", "okłada", "tłucze", "wali")
	var/plank_type = /obj/item/stack/sheet/mineral/wood
	var/plank_name = "drewniane deski"
	var/static/list/accepted = typecacheof(list(/obj/item/food/grown/tobacco,
	/obj/item/food/grown/tea,
	/obj/item/food/grown/ambrosia,
	/obj/item/food/grown/wheat))

/obj/item/grown/log/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		user.show_message("<span class='notice'>Robisz z [src]: [plank_name]!</span>", MSG_VISUAL)
		var/seed_modifier = get_fruit_trait_power(src)
		var/obj/item/stack/plank = new plank_type(user.loc, 1 + seed_modifier)
		var/old_plank_amount = plank.amount
		for(var/obj/item/stack/ST in user.loc)
			if(ST != plank && istype(ST, plank_type) && ST.amount < ST.max_amount)
				ST.attackby(plank, user) //we try to transfer all old unfinished stacks to the new stack we created.
		if(plank.amount > old_plank_amount)
			to_chat(user, "<span class='notice'>Dodajesz świeżo uformowane [plank_name] do stosu. Zawiera teraz: [plank.amount] [plank_name].</span>")
		qdel(src)

	if(CheckAccepted(W))
		var/obj/item/food/grown/leaf = W
		if(HAS_TRAIT(leaf, TRAIT_DRIED))
			user.show_message("<span class='notice'>Owijasz [W] wokół kłody, robiąc z niej pochodnię!</span>")
			var/obj/item/flashlight/flare/torch/T = new /obj/item/flashlight/flare/torch(user.loc)
			usr.dropItemToGround(W)
			usr.put_in_active_hand(T)
			qdel(leaf)
			qdel(src)
			return
		else
			to_chat(usr, "<span class ='warning'>Najpierw musisz to wysuszyć!</span>")
	else
		return ..()

/obj/item/grown/log/proc/CheckAccepted(obj/item/I)
	return is_type_in_typecache(I, accepted)

/obj/item/grown/log/tree
	seed = null
	name = "kłoda drewna"
	desc = "UWAAAAGA, DRZEEEEEEWO!"

/obj/item/grown/log/steel
	seed = /obj/item/plant_seeds/preset/steel
	name = "kłoda z grzyba stalowego"
	desc = "Jest z metalu."
	icon_state = "steellogs"
	plank_type = /obj/item/stack/rods
	plank_name = "rods"
	discovery_points = 300

/obj/item/grown/log/steel/CheckAccepted(obj/item/I)
	return FALSE
//bamboo
/obj/item/grown/log/bamboo
	seed = /obj/item/plant_seeds/preset/bamboo
	name = "pień bambusa"
	desc = "Długi i wytrzymały pień bambusa."
	icon_state = "bamboo"
	plank_type = /obj/item/stack/sheet/mineral/bamboo
	plank_name = "bambusowe kije"
	discovery_points = 300

/obj/item/grown/log/bamboo/CheckAccepted(obj/item/I)
	return FALSE

/obj/structure/punji_sticks
	name = "pułapka punji"
	desc = "Nie nadepnij na to."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "punji"
	resistance_flags = FLAMMABLE
	max_integrity = 30
	density = FALSE
	anchored = TRUE

/obj/structure/punji_sticks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, min_damage = 20, max_damage = 30, flags = CALTROP_BYPASS_SHOES)

/////////BONFIRES//////////

/obj/structure/bonfire
	name = "ognisko"
	desc = "Do grillowania, pieczenia, opalania, wędzenia, podgrzewania, prażenia, przypiekania, duszenia, obsmażania, topienia, a czasem do palenia różnych rzeczy."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	pass_flags_self = PASSTABLE | LETPASSTHROW
	var/burning = 0
	var/burn_icon = "bonfire_on_fire" //for a softer more burning embers icon, use "bonfire_warm"
	var/grill = FALSE
	var/fire_stack_strength = 5
	var/needs_oxygen = TRUE

/obj/structure/bonfire/bluespace
	needs_oxygen = FALSE

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/dense/askwalker
	needs_oxygen = FALSE

/obj/structure/bonfire/prelit/Initialize(mapload)
	. = ..()
	StartBurning()

/obj/structure/bonfire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	if(mover.throwing)
		return TRUE
	return ..()

/obj/structure/bonfire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/element/connect_loc, loc_connections)

/obj/structure/bonfire/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle && !grill)
		var/obj/item/stack/rods/R = W
		var/choice = input(user, "Co chcesz zbudować?", "Ognisko") as null|anything in list("Pal","Ruszt")
		switch(choice)
			if("Pal")
				R.use(1)
				can_buckle = TRUE
				buckle_requires_restraints = TRUE
				to_chat(user, "<span class='italics'>Dodajesz pręt do [src].")
				var/mutable_appearance/rod_underlay = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
				rod_underlay.pixel_y = 16
				underlays += rod_underlay
			if("Ruszt")
				R.use(1)
				grill = TRUE
				to_chat(user, "<span class='italics'>Dodajesz ruszt do [src].")
				add_overlay("bonfire_grill")
			else
				return ..()
	if(W.is_hot())
		StartBurning()
	if(grill)
		if(!user.combat_mode && !(W.item_flags & ABSTRACT))
			if(user.temporarilyRemoveItemFromInventory(W))
				W.forceMove(get_turf(src))
				var/list/click_params = params2list(params)
				//Center the icon where the user clicked.
				if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				W.pixel_x = W.base_pixel_x + CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
				W.pixel_y = W.base_pixel_y + CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		else
			return ..()


/obj/structure/bonfire/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(burning)
		to_chat(user, "<span class='warning'>Musisz zgasić [src], zanim wyjmiesz kłody!</span>")
		return
	if(!has_buckled_mobs() && do_after(user, 50, target = src))
		for(var/I in 1 to 5)
			var/obj/item/grown/log/L = new /obj/item/grown/log(src.loc)
			L.pixel_x += rand(1,4)
			L.pixel_y += rand(1,4)
		if(can_buckle || grill)
			new /obj/item/stack/rods(loc, 1)
		qdel(src)
		return

/obj/structure/bonfire/proc/CheckOxygen()
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(O.air)
			if(O.air.get_moles(GAS_O2) > 13)
				return TRUE
	return FALSE

/obj/structure/bonfire/proc/StartBurning()
	if(!burning && (!needs_oxygen || CheckOxygen()))
		icon_state = burn_icon
		burning = TRUE
		set_light(6)
		Burn()
		START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	StartBurning()

/obj/structure/bonfire/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(burning & !grill)
		Burn()

/obj/structure/bonfire/proc/Burn(delta_time = 2)
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 250 * delta_time, 1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 250 * delta_time)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength * 0.5 * delta_time)
			L.IgniteMob()

/obj/structure/bonfire/proc/Cook(delta_time = 2)
	var/turf/current_location = get_turf(src)
	for(var/A in current_location)
		if(A == src)
			continue
		else if(isliving(A)) //It's still a fire, idiot.
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength * 0.5 * delta_time)
			L.IgniteMob()
		else if(istype(A, /obj/item))
			var/obj/item/grilled_item = A
			SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, src, delta_time) //Not a big fan, maybe make this use fire_act() in the future.

/obj/structure/bonfire/process(delta_time)
	if(needs_oxygen && !CheckOxygen())
		extinguish()
		return
	if(!grill)
		Burn(delta_time)
	else
		Cook(delta_time)

/obj/structure/bonfire/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = 0
		set_light(0)
		STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(..())
		M.pixel_y += 13

/obj/structure/bonfire/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(..())
		buckled_mob.pixel_y -= 13
