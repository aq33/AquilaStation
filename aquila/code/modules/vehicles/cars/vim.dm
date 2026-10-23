// AQUILA - VIM, mini-mech dla małych zwierząt (tg code/modules/vehicles/cars/vim.dm + dodatki Monkestation2.0:
// butla z powietrzem, montaż ze śrubokrętem, brak eksplozji). Sprite'y z Monkestation2.0.

#define VIM_HEAL_AMOUNT 20
#define VIM_SOUND_COOLDOWN (1 SECONDS)

/// from the VIM headlights action: (headlights_on)
#define COMSIG_VIM_HEADLIGHTS_TOGGLED "vim_headlights_toggled"
/// from the VIM chime action
#define COMSIG_VIM_CHIME_USED "vim_chime_used"
/// from the VIM buzz action
#define COMSIG_VIM_BUZZ_USED "vim_buzz_used"

#ifndef ASSEMBLY_SIXTH_STEP
#define ASSEMBLY_SIXTH_STEP 5
#endif

/**
 * ## VIM!!!!!!!
 *
 * It's a teenie minature mecha... for critters!
 * For the critters that cannot be understood, there is a sound creator in the mecha. It also has headlights.
 */
/obj/vehicle/sealed/car/vim
	name = "\improper Vim"
	desc = "Miniaturowy egzoszkielet od Nanotrasen, opracowany, by niezastąpione zwierzaki stacji pożyły trochę dłużej."
	icon = 'aquila/icons/monke/vim.dmi'
	icon_state = "vim"
	max_integrity = 50
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0, "bleed" = 0)
	enter_delay = 20
	movedelay = 0.6
	engine_sound_length = 0.3 SECONDS
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 2
	light_on = FALSE
	engine_sound = 'sound/effects/servostep.ogg'
	explode_on_destruction = FALSE
	///Maximum size of a mob trying to enter the mech
	var/maximum_mob_size = MOB_SIZE_SMALL
	///Bigger animals that still fit inside (the station corgis)
	var/list/allowed_bigger_mobs = list(/mob/living/simple_animal/pet/dog/corgi)
	///Whether the headlights are on
	var/headlights_toggle = FALSE
	/// Air tank used for internals.
	var/obj/item/tank/internals/tank
	COOLDOWN_DECLARE(sound_cooldown)

/obj/vehicle/sealed/car/vim/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(new /obj/item/circuit_component/vim), SHELL_CAPACITY_SMALL)

/obj/vehicle/sealed/car/vim/Destroy()
	QDEL_NULL(tank)
	return ..()

/obj/vehicle/sealed/car/vim/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Można go naprawić spawarką.</span>"
	if(!QDELETED(tank))
		. += "<span class='notice'>[icon2html(tank, user)] Ma zamontowaną butlę: [tank].</span>"
	else
		. += "<span class='notice'>Można do niego podpiąć butlę z tlenem, by nadawał się na kosmos.</span>"

/obj/vehicle/sealed/car/vim/obj_destruction(damage_flag)
	new /obj/effect/decal/cleanable/oil(drop_location())
	new /obj/effect/decal/cleanable/robot_debris/limb(drop_location())
	do_sparks(5, TRUE, src)
	visible_message("<span class='boldannounce'>[src] rozpada się na kawałki!</span>")
	tank?.forceMove(drop_location())
	tank = null
	return ..()

/obj/vehicle/sealed/car/vim/return_air()
	return tank?.return_air() || loc?.return_air()

/obj/vehicle/sealed/car/vim/return_analyzable_air()
	return tank?.return_analyzable_air()

/obj/vehicle/sealed/car/vim/mob_try_enter(mob/entering)
	if(!isanimal(entering))
		return FALSE
	var/mob/living/animal = entering
	if(animal.mob_size > maximum_mob_size && !is_type_in_list(animal, allowed_bigger_mobs))
		entering.balloon_alert(entering, "nie zmieścisz się!")
		return FALSE
	return ..()

// Zwierzęta nie są "advanced tool userami", więc pomijamy sprawdzenie z /obj/vehicle/sealed
/obj/vehicle/sealed/car/vim/mob_enter(mob/newoccupant, silent = FALSE)
	if(!istype(newoccupant))
		return FALSE
	if(!silent)
		newoccupant.visible_message("<span class='notice'>[newoccupant] wskakuje do [src]!</span>")
	newoccupant.forceMove(src)
	add_occupant(newoccupant)
	update_appearance()
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	if(obj_integrity == max_integrity)
		newoccupant.playsound_local(src, 'sound/mecha/nominal.ogg', 50)
	return TRUE

/obj/vehicle/sealed/car/vim/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	update_appearance()

/obj/vehicle/sealed/car/vim/attackby(obj/item/I, mob/user, params)
	if(user.combat_mode || !istype(I, /obj/item/tank/internals))
		return ..()
	if(!QDELETED(tank))
		to_chat(user, "<span class='warning'>[src] ma już butlę!</span>")
		return
	var/obj/item/tank/internals/tank_to_attach = I
	if(!vim_tank_has_air(tank_to_attach))
		to_chat(user, "<span class='warning'>W [tank_to_attach] jest za mało powietrza!</span>")
		return
	user.balloon_alert_to_viewers("podpina butlę...")
	if(!do_after(user, 5 SECONDS, target = src))
		return
	if(!QDELETED(tank) || !user.transferItemToLoc(tank_to_attach, src))
		return
	tank = tank_to_attach
	user.balloon_alert_to_viewers("butla podpięta")

/obj/vehicle/sealed/car/vim/welder_act(mob/living/user, obj/item/W)
	if(user.combat_mode)
		return
	. = TRUE
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "nie jest uszkodzony!")
		return
	if(!W.tool_start_check(user, amount=1))
		return
	user.balloon_alert_to_viewers("zaczyna spawać [src]", "zaczynasz naprawiać [src]")
	audible_message("<span class='hear'>Słyszysz spawanie.</span>")
	var/did_the_thing
	while(obj_integrity < max_integrity)
		if(W.use_tool(src, user, 2.5 SECONDS, volume=50, amount=1))
			did_the_thing = TRUE
			obj_integrity += min(VIM_HEAL_AMOUNT, (max_integrity - obj_integrity))
			audible_message("<span class='hear'>Słyszysz spawanie.</span>")
		else
			break
	if(did_the_thing)
		user.balloon_alert_to_viewers("[(obj_integrity >= max_integrity) ? "w pełni" : "częściowo"] naprawił [src]")
	else
		user.balloon_alert_to_viewers("przestaje spawać [src]", "naprawa przerwana!")

/obj/vehicle/sealed/car/vim/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out/vim)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/chime, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/noise/buzz, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights/vim, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/vim/update_overlays()
	. = ..()
	var/static/piloted_overlay
	var/static/headlights_overlay
	if(isnull(piloted_overlay))
		piloted_overlay = iconstate2appearance(icon, "vim_piloted")
		headlights_overlay = iconstate2appearance(icon, "vim_headlights")

	if(occupant_amount())
		. += piloted_overlay
	if(headlights_toggle)
		. += headlights_overlay

/// Pojazd mapowy z butlą w środku
/obj/vehicle/sealed/car/vim/with_tank

/obj/vehicle/sealed/car/vim/with_tank/Initialize(mapload)
	. = ..()
	tank = new /obj/item/tank/internals/oxygen(src)

// Akcje pilota

/datum/action/vehicle/sealed/climb_out/vim
	name = "Wysiądź z mecha"
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/noise
	icon_icon = 'aquila/icons/monke/vim_actions.dmi'
	var/sound_path = 'sound/items/carhorn.ogg'
	var/sound_message = "wydaje dźwięk."

/datum/action/vehicle/sealed/noise/Trigger()
	if(!..())
		return FALSE
	var/obj/vehicle/sealed/car/vim/vim_mecha = vehicle_entered_target
	if(!istype(vim_mecha))
		return FALSE
	if(!COOLDOWN_FINISHED(vim_mecha, sound_cooldown))
		vim_mecha.balloon_alert(owner, "jeszcze nie!")
		return FALSE
	COOLDOWN_START(vim_mecha, sound_cooldown, VIM_SOUND_COOLDOWN)
	vim_mecha.visible_message("<span class='notice'>[vim_mecha] [sound_message]</span>")
	playsound(vim_mecha, sound_path, 75)
	return TRUE

/datum/action/vehicle/sealed/noise/chime
	name = "Dzyń!"
	desc = "Tak!"
	button_icon_state = "vim_chime"
	sound_path = 'sound/machines/chime.ogg'
	sound_message = "radośnie dzwoni!"

/datum/action/vehicle/sealed/noise/chime/Trigger()
	. = ..()
	if(.)
		SEND_SIGNAL(vehicle_entered_target, COMSIG_VIM_CHIME_USED)

/datum/action/vehicle/sealed/noise/buzz
	name = "Bzzz."
	desc = "Nie!"
	button_icon_state = "vim_buzz"
	sound_path = 'sound/machines/buzz-sigh.ogg'
	sound_message = "brzęczy przecząco."

/datum/action/vehicle/sealed/noise/buzz/Trigger()
	. = ..()
	if(.)
		SEND_SIGNAL(vehicle_entered_target, COMSIG_VIM_BUZZ_USED)

/datum/action/vehicle/sealed/headlights/vim
	name = "Reflektory"
	desc = "Włącz światła!"
	icon_icon = 'aquila/icons/monke/vim_actions.dmi'
	button_icon_state = "vim_headlights"

/datum/action/vehicle/sealed/headlights/vim/Trigger()
	if(!..())
		return FALSE
	var/obj/vehicle/sealed/car/vim/vim_mecha = vehicle_entered_target
	if(!istype(vim_mecha))
		return FALSE
	to_chat(owner, "<span class='notice'>Przestawiasz przełącznik reflektorów.</span>")
	vim_mecha.headlights_toggle = !vim_mecha.headlights_toggle
	vim_mecha.set_light_on(vim_mecha.headlights_toggle)
	vim_mecha.update_appearance()
	playsound(owner, vim_mecha.headlights_toggle ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, TRUE)
	SEND_SIGNAL(vim_mecha, COMSIG_VIM_HEADLIGHTS_TOGGLED, vim_mecha.headlights_toggle)
	return TRUE

// Komponent wiremod

/obj/item/circuit_component/vim
	display_name = "Vim"
	desc = "Miniaturowy egzoszkielet dla zwierzaków. Zgłasza użycie dzwonka, brzęczyka i stan reflektorów."

	/// Sent when the mech chimes.
	var/datum/port/output/chime
	/// Sent when the mech buzzes.
	var/datum/port/output/buzz
	/// Whether the mech headlights are currently on.
	var/datum/port/output/are_headlights_on

/obj/item/circuit_component/vim/Initialize(mapload)
	. = ..()
	are_headlights_on = add_output_port("Are Headlights On", PORT_TYPE_NUMBER)
	chime = add_output_port("On Chime Used", PORT_TYPE_SIGNAL)
	buzz = add_output_port("On Buzz Used", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/vim/register_shell(atom/movable/shell)
	. = ..()
	RegisterSignal(shell, COMSIG_VIM_HEADLIGHTS_TOGGLED, PROC_REF(on_headlights_toggle))
	RegisterSignal(shell, COMSIG_VIM_CHIME_USED, PROC_REF(on_chime_used))
	RegisterSignal(shell, COMSIG_VIM_BUZZ_USED, PROC_REF(on_buzz_used))

/obj/item/circuit_component/vim/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_VIM_HEADLIGHTS_TOGGLED, COMSIG_VIM_CHIME_USED, COMSIG_VIM_BUZZ_USED))
	return ..()

/obj/item/circuit_component/vim/proc/on_headlights_toggle(datum/source, headlights_on)
	SIGNAL_HANDLER
	are_headlights_on.set_output(headlights_on)

/obj/item/circuit_component/vim/proc/on_chime_used()
	SIGNAL_HANDLER
	chime.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/vim/proc/on_buzz_used()
	SIGNAL_HANDLER
	buzz.set_output(COMPONENT_SIGNAL)

// Montaż

/datum/crafting_recipe/vim
	name = "Vim"
	result = /obj/vehicle/sealed/car/vim
	reqs = list(
		/obj/item/clothing/head/helmet/space/eva = 1,
		/obj/item/bodypart/l_leg/robot = 1,
		/obj/item/bodypart/r_leg/robot = 1,
		/obj/item/flashlight = 1,
		/obj/item/assembly/voice = 1,
	)
	tools = list(TOOL_SCREWDRIVER)
	time = 60
	category = CAT_ROBOT

// Hełm EVA na ziemi + noga robota = początek montażu
/obj/item/clothing/head/helmet/space/eva/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/bodypart/l_leg/robot) && !istype(I, /obj/item/bodypart/r_leg/robot))
		return ..()
	if(!isturf(loc))
		to_chat(user, "<span class='warning'>Połóż najpierw [src] na ziemi!</span>")
		return
	if(!user.temporarilyRemoveItemFromInventory(I))
		return
	to_chat(user, "<span class='notice'>Przymocowujesz [I] do [src].</span>")
	new /obj/item/bot_assembly/vim(loc)
	qdel(I)
	qdel(src)

/obj/item/bot_assembly/vim
	name = "niekompletny montaż Vima"
	desc = "Hełm kosmiczny z przyczepioną nogą. Wygląda na to, że potrzebuje drugiej nogi."
	icon = 'aquila/icons/monke/vim_assembly.dmi'
	icon_state = "vim_0"
	created_name = "\improper Vim"

/obj/item/bot_assembly/vim/attackby(obj/item/part, mob/user, params)
	..()
	switch(build_step)
		if(ASSEMBLY_FIRST_STEP)
			if(istype(part, /obj/item/bodypart/l_leg/robot) || istype(part, /obj/item/bodypart/r_leg/robot))
				if(!user.temporarilyRemoveItemFromInventory(part))
					return
				balloon_alert(user, "noga dołączona")
				icon_state = "vim_1"
				desc = "Jakiś niekompletny mechanizm. Brakuje mu reflektorów."
				qdel(part)
				build_step++

		if(ASSEMBLY_SECOND_STEP)
			if(istype(part, /obj/item/flashlight))
				if(!user.temporarilyRemoveItemFromInventory(part))
					return
				balloon_alert(user, "latarka dodana")
				icon_state = "vim_2"
				desc = "Jakiś niekompletny mechanizm. Latarka jest włożona, ale nieprzykręcona."
				qdel(part)
				build_step++

		if(ASSEMBLY_THIRD_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "przykręcasz latarkę...")
				if(!part.use_tool(src, user, 4 SECONDS, volume=100) || build_step != ASSEMBLY_THIRD_STEP)
					return
				balloon_alert(user, "latarka przykręcona")
				icon_state = "vim_3"
				desc = "Jakiś niekompletny mechanizm. Prawie gotowy, brakuje mu tylko butli z tlenem i modułu głosowego."
				build_step++

		if(ASSEMBLY_FOURTH_STEP)
			if(istype(part, /obj/item/assembly/voice))
				if(!can_finish_build(part, user))
					return
				balloon_alert(user, "moduł głosowy dodany")
				qdel(part)
				desc = "Jakiś niekompletny mechanizm. Moduł głosowy jest włożony, ale nieprzykręcony."
				build_step++

		if(ASSEMBLY_FIFTH_STEP)
			if(part.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "przykręcasz moduł głosowy...")
				if(!part.use_tool(src, user, 4 SECONDS, volume=100) || build_step != ASSEMBLY_FIFTH_STEP)
					return
				balloon_alert(user, "moduł głosowy przykręcony")
				desc = "Jakiś niekompletny mechanizm. Prawie gotowy, brakuje mu tylko butli z tlenem."
				build_step++

		if(ASSEMBLY_SIXTH_STEP)
			if(istype(part, /obj/item/tank/internals))
				var/obj/item/tank/internals/new_tank = part
				if(!vim_tank_has_air(new_tank))
					balloon_alert(user, "w butli jest za mało powietrza!")
					return
				if(!user.temporarilyRemoveItemFromInventory(part))
					return
				balloon_alert(user, "montaż ukończony!")
				var/obj/vehicle/sealed/car/vim/new_vim = new(drop_location())
				new_vim.name = created_name
				new_vim.tank = new_tank
				new_tank.forceMove(new_vim)
				qdel(src)

#undef VIM_HEAL_AMOUNT
#undef VIM_SOUND_COOLDOWN

/// Does the tank hold enough air to keep a VIM pilot alive
/proc/vim_tank_has_air(obj/item/tank/internals/tank)
	var/datum/gas_mixture/air = tank?.return_air()
	return air && air.return_pressure() > HAZARD_LOW_PRESSURE
