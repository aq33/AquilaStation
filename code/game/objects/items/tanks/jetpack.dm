/obj/item/tank/jetpack
	name = "plecak odrzutowy (pusty)"
	desc = "Zbiornik ze sprężonym gazem, który służy do poruszania się w strefach bez grawitacji. Używać ostrożnie."
	icon_state = "jetpack"
	item_state = "jetpack"
	lefthand_file = 'icons/mob/inhands/equipment/jetpacks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/jetpacks_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	actions_types = list(/datum/action/item_action/set_internals, /datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	var/gas_type = GAS_O2
	var/on = FALSE
	var/full_speed = TRUE // If the jetpack will have a speedboost in space/nograv or not
	// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864)
	var/stabilize = FALSE
	var/thrust_callback
	var/use_ion_trail = TRUE
	// AQ EDIT END

// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): ruch, stabilizacja i smuga są w /datum/component/jetpack
/obj/item/tank/jetpack/Initialize(mapload)
	. = ..()
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	configure_jetpack(stabilize)

/obj/item/tank/jetpack/Destroy()
	if(on)
		turn_off(get_thrust_user())
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilize - Should this jetpack be stabalized
 */
/obj/item/tank/jetpack/proc/configure_jetpack(stabilize)
	src.stabilize = stabilize

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_JETPACK_ACTIVATED, \
		COMSIG_JETPACK_DEACTIVATED, \
		JETPACK_ACTIVATION_FAILED, \
		thrust_callback, \
		use_ion_trail ? /datum/effect_system/trail_follow/ion : null, \
		thrust_sound \
	)

/obj/item/tank/jetpack/equipped(mob/user, slot, initial)
	. = ..()
	if(on && !(slot & slot_flags))
		turn_off(user)

/obj/item/tank/jetpack/dropped(mob/user, silent)
	. = ..()
	if(on)
		turn_off(user)
// AQ EDIT END

/obj/item/tank/jetpack/populate_gas()
	if(gas_type)
		air_contents.set_moles(gas_type, ((6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C)))

/obj/item/tank/jetpack/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_jetpack))
		cycle(user)
	else if(istype(action, /datum/action/item_action/jetpack_stabilization))
		if(on)
			configure_jetpack(!stabilize) // AQ EDIT - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864)
			to_chat(user, "<span class='notice'>[stabilize ? "Włączasz" : "Wyłączasz"] stabilizację plecaka odrzutowego.</span>")
	else
		toggle_internals(user)


/obj/item/tank/jetpack/proc/cycle(mob/user)
	if(user.incapacitated())
		return

	if(!on)
		// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): włączenie może się nie udać (brak paliwa)
		if(turn_on(user))
			to_chat(user, "<span class='notice'>Włączasz plecak odrzutowy.</span>")
		else
			to_chat(user, "<span class='notice'>Nie udaje ci się włączyć plecaka odrzutowego.</span>")
			return
		// AQ EDIT END
	else
		turn_off(user)
		to_chat(user, "<span class='notice'>Wyłączasz plecak odrzutowy.</span>")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864); prędkość zostaje nasza (MOVESPEED_ID_JETPACK)
/obj/item/tank/jetpack/proc/turn_on(mob/user)
	if(SEND_SIGNAL(src, COMSIG_JETPACK_ACTIVATED, user) & JETPACK_ACTIVATION_FAILED)
		return FALSE
	on = TRUE
	icon_state = "[initial(icon_state)]-on"
	if(full_speed)
		user.add_movespeed_modifier(MOVESPEED_ID_JETPACK, priority=100, multiplicative_slowdown=-2, movetypes=FLOATING, conflict=MOVE_CONFLICT_JETPACK)
	return TRUE

/obj/item/tank/jetpack/proc/turn_off(mob/user)
	SEND_SIGNAL(src, COMSIG_JETPACK_DEACTIVATED, user)
	on = FALSE
	icon_state = initial(icon_state)
	user?.remove_movespeed_modifier(MOVESPEED_ID_JETPACK)

/// Mob, który ciągnie z tego plecaka (nosi go)
/obj/item/tank/jetpack/proc/get_thrust_user()
	return ismob(loc) ? loc : null

/// Ciąg dysz. use_fuel = FALSE tylko sprawdza, czy jest paliwo (stabilizacja), nic nie zużywa
/obj/item/tank/jetpack/proc/allow_thrust(num, use_fuel = TRUE)
	var/mob/user = get_thrust_user()
	if(!user)
		return FALSE

	if((num < 0.005 || air_contents.total_moles() < num))
		turn_off(user)
		return FALSE

	// We've got the gas, it's chill
	if(!use_fuel)
		return TRUE

	remove_air(num)

	return TRUE
// AQ EDIT END

/obj/item/tank/jetpack/suicide_act(mob/user)
	if (istype(user, /mob/living/carbon/human/))
		var/mob/living/carbon/human/H = user
		H.say(";CO TO, KURWA, JEST DWUTLENEK WĘGLA?", forced="jetpack suicide")
		H.visible_message("<span class='suicide'>[user] dusi się [src]! Wygląda na to, że nie przeczytał, co jest napisane na tym plecaku odrzutowym!</span>")
		return (OXYLOSS)
	else
		..()

/obj/item/tank/jetpack/improvised
	name = "improwizowany plecak odrzutowy"
	desc = "Plecak odrzutowy zrobiony z dwóch butli z powietrzem, gaśnicy i trochę sprzętu atmosferycznego. Nie wygląda, jakby dużo pomieścił."
	icon_state = "jetpack-improvised"
	item_state = "jetpack-sec"
	volume = 20 //normal jetpacks have 70 volume
	gas_type = null //it starts empty
	full_speed = FALSE //moves at hardsuit jetpack speeds

// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864)
/obj/item/tank/jetpack/improvised/allow_thrust(num, use_fuel = TRUE)
	var/mob/user = get_thrust_user()
	if(!user)
		return FALSE
	if(use_fuel && rand(0,250) == 0)
		to_chat(user, "<span class='notice'>Czujesz, jak silniki twojego plecaka odrzutowego gasną.</span>")
		turn_off(user)
		return FALSE
	return ..()
// AQ EDIT END

/obj/item/tank/jetpack/void
	name = "próżniowy plecak odrzutowy (tlen)"
	desc = "Dobrze działa w próżni."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/tank/jetpack/oxygen
	name = "plecak odrzutowy (tlen)"
	desc = "Zbiornik ze sprężonym tlenem, który służy do poruszania się w strefach bez grawitacji. Używać ostrożnie."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/tank/jetpack/oxygen/harness
	name = "uprząż odrzutowa (tlen)"
	desc = "Lekka uprząż taktyczna dla tych, którzy nie chcą dźwigać tradycyjnych plecaków odrzutowych."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT

/obj/item/tank/jetpack/oxygen/captain
	name = "\improper plecak odrzutowy kapitana"
	desc = "Kompaktowy, lekki plecak odrzutowy z dużą ilością sprężonego tlenu."
	icon_state = "jetpack-captain"
	item_state = "jetpack-captain"
	w_class = WEIGHT_CLASS_NORMAL
	volume = 90
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //steal objective items are hard to destroy.
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/tank/jetpack/oxygen/security
	name = "żandarmski plecak odrzutowy (tlen)"
	desc = "Zbiornik ze sprężonym tlenem, który służy siłom ochrony do poruszania się w strefach bez grawitacji."
	icon_state = "jetpack-sec"
	item_state = "jetpack-sec"



/obj/item/tank/jetpack/carbondioxide
	name = "plecak odrzutowy (dwutlenek węgla)"
	desc = "Zbiornik ze sprężonym dwutlenkiem węgla, który służy do poruszania się w strefach bez grawitacji. Pomalowany na czarno na znak, że nie wolno z niego oddychać."
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"
	distribute_pressure = 0
	gas_type = GAS_CO2


/obj/item/tank/jetpack/suit
	name = "ulepszenie hardsuitu: plecak odrzutowy"
	desc = "Modułowy, kompaktowy zestaw dysz do zintegrowania z hardsuitem. Zasila go butla włożona do schowka skafandra."
	icon_state = "jetpack-mining"
	item_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 1
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	var/datum/gas_mixture/temp_air_contents
	var/obj/item/tank/internals/tank = null
	var/mob/living/carbon/human/cur_user

/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	temp_air_contents = air_contents

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, "<span class='warning'>[src] musi być podłączony do hardsuitu!</span>")
		return

	var/mob/living/carbon/human/H = user
	if(!istype(H.s_store, /obj/item/tank/internals))
		to_chat(user, "<span class='warning'>Potrzebujesz butli w schowku skafandra!</span>")
		return
	..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return FALSE // AQ EDIT - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864)
	var/mob/living/carbon/human/H = user
	tank = H.s_store
	air_contents = tank.air_contents
	START_PROCESSING(SSobj, src)
	cur_user = user
	// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): pusta butla = nie włącza się
	. = ..()
	if(!.)
		turn_off(user)
	// AQ EDIT END

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	tank = null
	air_contents = temp_air_contents
	STOP_PROCESSING(SSobj, src)
	cur_user = null
	..()

// AQ EDIT START - jetpack jako komponent (port BeeStation/BeeStation-Hornet#14864): plecak siedzi w hardsuicie, ciągnie noszący
/obj/item/tank/jetpack/suit/get_thrust_user()
	return cur_user
// AQ EDIT END

/obj/item/tank/jetpack/suit/process()
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc))
		turn_off(cur_user)
		return
	var/mob/living/carbon/human/H = loc.loc
	if(!tank || tank != H.s_store)
		turn_off(cur_user)
		return
	..()


//Return a jetpack that the mob can use
//Back worn jetpacks, hardsuit internal packs, and so on.
//Used in Process_Spacemove() and wherever you want to check for/get a jetpack

/mob/proc/get_jetpack()
	return

/mob/living/carbon/get_jetpack()
	var/obj/item/tank/jetpack/J = back
	if(istype(J))
		return J

/mob/living/carbon/human/get_jetpack()
	var/obj/item/tank/jetpack/J = ..()
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	return J
