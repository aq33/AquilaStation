/*
	Misc machines used to interact with artifact traits
*/

/obj/machinery/xenoarchaeology_machine
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	///Do we move the artifact to our turf, or inside us?
	var/move_inside = FALSE
	///List of things we need to spit out
	var/list/held_contents = list()
	var/max_contents = 1

/obj/machinery/xenoarchaeology_machine/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, INNATE_TRAIT)

/obj/machinery/xenoarchaeology_machine/attackby(obj/item/I, mob/living/user, params)
	//aquila: u nas attackby dostaje parametry kliknięcia jako tekst
	var/list/modifiers = islist(params) ? params : params2list(params)
	if(user.combat_mode || (I.item_flags & ABSTRACT))
		return ..()
	if(move_inside && length(held_contents) >= max_contents)
		return
	var/atom/target = get_target()
	///Move the item to our target, so we can work with it, like we're a table
	if(user.transferItemToLoc(I, target, silent = FALSE))
		//Handle contents - najpierw, żeby brak pozycji kliknięcia nie zostawił przedmiotu w środku bez rejestracji
		if(move_inside)
			register_contents(I)
		//Center the icon where the user clicked.
		if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
			return
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X/2), ICON_SIZE_X/2)
		I.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y/2), ICON_SIZE_Y/2)

/obj/machinery/xenoarchaeology_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(modifiers && modifiers["right"])
		return
	activate_machine()

/// Does a machine thing when you 'click' the machine. Typically called by 'attack_hand'.
/obj/machinery/xenoarchaeology_machine/proc/activate_machine()
	return

/obj/machinery/xenoarchaeology_machine/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	alt_activate_machine(user)

/// Does a machine thing when you 'alt+click' the machine.
/obj/machinery/xenoarchaeology_machine/proc/alt_activate_machine(mob/user)
	return

/obj/machinery/xenoarchaeology_machine/proc/register_contents(atom/atom_target)
	RegisterSignal(atom_target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_contents))
	RegisterSignal(atom_target, COMSIG_MOVABLE_MOVED, PROC_REF(unregister_contents))
	held_contents += atom_target

/obj/machinery/xenoarchaeology_machine/proc/unregister_contents(datum/source)
	SIGNAL_HANDLER

	held_contents -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/obj/machinery/xenoarchaeology_machine/proc/get_target()
	return move_inside ? src : drop_location()

/obj/machinery/xenoarchaeology_machine/proc/empty_contents(atom/movable/target, force)
	if(target && (list(target) & held_contents || force))
		target.forceMove(get_turf(src))
		unregister_contents(target)
		return
	for(var/atom/movable/AM in held_contents)
		AM.forceMove(get_turf(src))
		unregister_contents(AM)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine
	name = "zaślepka (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 5,
		/obj/item/stock_parts/matter_bin = 1)

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Scale, measures artifact weight
*/
/obj/machinery/xenoarchaeology_machine/scale
	name = "waga przemysłowa"
	desc = "Przemysłowe urządzenie zdolne zważyć tysiące kilogramów."
	icon_state = "scale"
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/scale

/obj/machinery/xenoarchaeology_machine/scale/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Użyj, aby zmierzyć masę artefaktu.\nDla oznaczonych artefaktów pokazane zostaną też masy cech z etykiety na tle sumy.</span>"

/obj/machinery/xenoarchaeology_machine/scale/activate_machine(mob/living/user)
	empty_contents()
	///Get the combined weight of all artifacts in our target
	var/atom/target = get_target()
	var/total_weight = 0
	var/label_weight = 0
	for(var/atom/atom_target in target)
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		if(artifact_component)
			total_weight += artifact_component.get_material_weight()
		//If there's a label and we're obliged to 'help' the player
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		if(label)
			for(var/datum/xenoartifact_trait/T as anything in label.traits)
				say("[initial(T.label_name)] - masa: [initial(T.weight)]")
				label_weight += initial(T.weight)
		else if(isitem(atom_target) || isliving(atom_target))
			if(isliving(atom_target))
				if(prob(1))
					say("Wykryto nieoczekiwanego grubasa!")
					say("Złaź ze mnie, ty spaślaku!")
					playsound(get_turf(src), 'sound/vehicles/clowncar_fart.ogg', 100)
				else
					say("Wykryto nieoczekiwany przedmiot!")
				return
	if(total_weight)
		say("Masa całkowita: [total_weight] kg.\n[label_weight ? "Masa z etykiety: [label_weight] kg." : ""]")
	else
		say("Nie wykryto masy!")
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/scale
	name = "waga przemysłowa (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/scale

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Conductor, measures artifact conductivty
*/
/obj/machinery/xenoarchaeology_machine/conductor
	name = "płyta przewodząca"
	desc = "Przemysłowe urządzenie do pomiaru przewodności materiałów."
	icon_state = "conductor"
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/conductor

/obj/machinery/xenoarchaeology_machine/conductor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Użyj, aby zmierzyć przewodność artefaktu.\nDla oznaczonych artefaktów pokazana zostanie też przewodność cech z etykiety na tle sumy.</span>"

/obj/machinery/xenoarchaeology_machine/conductor/activate_machine(mob/living/user)
	empty_contents()

	///Get the combined conductivity of all artifacts in our target
	var/atom/target = get_target()
	var/total_conductivity = 0
	var/label_conductivity = 0
	for(var/atom/atom_target in target)
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		if(artifact_component)
			total_conductivity += artifact_component.get_material_conductivity()
		//If there's a label and we're obliged to 'help' the player
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		if(label)
			for(var/datum/xenoartifact_trait/T as anything in label.traits)
				say("[initial(T.label_name)] - przewodność: [initial(T.conductivity)]")
				label_conductivity += initial(T.conductivity)
		else if(isitem(atom_target) || isliving(atom_target))
			if(isliving(atom_target))
				if(prob(1))
					say("Wykryto nieoczekiwanego grubasa!")
					say("Złaź ze mnie, ty spaślaku!")
					playsound(get_turf(src), 'sound/vehicles/clowncar_fart.ogg', 100)
				else
					say("Wykryto nieoczekiwany przedmiot!")
				return
	if(total_conductivity)
		say("Przewodność całkowita: [total_conductivity] MPC.\n[label_conductivity ? "Przewodność z etykiety: [label_conductivity] MPC." : ""]")
	else
		say("Nie wykryto przewodności!")
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/conductor
	name = "płyta przewodząca (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/conductor

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Calibrator, calibrates artifacts
*/
/obj/machinery/xenoarchaeology_machine/calibrator
	name = "kalibrator materiałów anomalnych"
	desc = "Eksperymentalne urządzenie naukowe służące do kalibracji anomalnych materiałów."
	icon_state = "calibrator"
	move_inside = TRUE
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/calibrator
	///Which science server receives points
	var/datum/techweb/linked_techweb
	///radio used by the console to send messages on science channel
	var/obj/item/radio/headset/radio
	///Cooking logic
	var/cooking_time = 4 SECONDS
	var/cooking_timer
	///How effective are our parts, for making DP
	var/reward_rate = 1 / 16
	///Kto uruchomił kalibrację - pytamy go o usterki (w callbacku timera usr jest pusty)
	var/datum/weakref/cooking_user

/obj/machinery/xenoarchaeology_machine/calibrator/Initialize(mapload, _artifact_type)
	. = ..()
	radio = new /obj/item/radio/headset/headset_sci(src)
	//aquila: nasze maszyny nie wołają LateInitialize, a SSresearch startuje przed atomami
	if(!linked_techweb)
		linked_techweb = SSresearch.science_tech

/obj/machinery/xenoarchaeology_machine/calibrator/tutorial/Initialize(mapload, _artifact_type)
	. = ..()
	var/obj/item/sticker/sticky_note/calibrator_tutorial/label = new(loc)
	label.stick_to(src)
	unregister_contents(label)
	label.pixel_y = rand(-8, 8)
	label.pixel_x = rand(-8, 8)

/obj/machinery/xenoarchaeology_machine/calibrator/Destroy()
	. = ..()
	QDEL_NULL(radio)
	if(cooking_timer)
		deltimer(cooking_timer)

/obj/machinery/xenoarchaeology_machine/calibrator/RefreshParts()
	. = ..()
	//Should only be one, but I'm lazy and this seems safe
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		reward_rate = part.rating / 16

/obj/machinery/xenoarchaeology_machine/calibrator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij [user.secondary_click_text()], aby skalibrować włożone artefakty.\nArtefakt da się skalibrować, jeśli jego etykieta jest w 100% poprawna (nie licząc usterek).</span>"

/obj/machinery/xenoarchaeology_machine/calibrator/activate_machine(mob/living/user)
	if(length(held_contents))
		empty_contents()
		return

	var/turf/turf = get_turf(src)
	for(var/obj/item/item in turf.contents)
		if(move_inside && length(held_contents) >= max_contents)
			return
		item.forceMove(src)
		register_contents(item)

/obj/machinery/xenoarchaeology_machine/calibrator/alt_activate_machine(mob/user)
	cooking_user = WEAKREF(user)
	if(!length(held_contents) || cooking_timer)
		playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
		return
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)
	for(var/atom/atom_target as anything in contents-radio)
		var/solid_as = TRUE
		//Once we find an artifact-
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		//We then want to find a sticker attached to it-
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		//Early checks
		if(!artifact_component || !label || artifact_component?.calibrated || artifact_component?.calcified)
			var/decision = "Nie"
			if(!label && artifact_component)
				say("Nie wykryto etykiety!")
				if(!artifact_component.calcified)
					decision = tgui_alert(user, "Czy chcesz kontynuować? To zniszczy [atom_target].", "Zwapnienie artefaktu", list("Tak", "Nie"))
			if(decision == "Nie")
				//This stops us from spitting out stuff we shouldn't, mostly
				if(atom_target in held_contents)
					empty_contents(atom_target)
				continue
			else
				solid_as = FALSE
		//Loop through traits and see if we're fucked or not
		var/score = 0
		var/max_score = 0
		if(solid_as) //This is kinda wacky but it's for a player option so idc
			for(var/trait in artifact_component.traits_catagories)
				for(var/datum/xenoartifact_trait/trait_datum in artifact_component.traits_catagories[trait])
					if(trait_datum.contribute_calibration)
						if(!(locate(trait_datum) in label.traits))
							solid_as = FALSE
						else
							score += 1
					max_score = trait_datum.contribute_calibration ?  max_score + 1 : max_score
		//Check against label length, for extra labeled traits
		var/label_length = 0
		for(var/datum/xenoartifact_trait/trait_datum as anything in label?.traits)
			if(initial(trait_datum.contribute_calibration))
				label_length += 1
		if(label_length != max_score)
			solid_as = FALSE
		//FX
		INVOKE_ASYNC(src, PROC_REF(do_cooking_sounds), solid_as)
		cooking_timer = addtimer(CALLBACK(src, PROC_REF(finish_cooking), atom_target, artifact_component, score, max_score, solid_as), cooking_time, TIMER_STOPPABLE)

/obj/machinery/xenoarchaeology_machine/calibrator/proc/do_cooking_sounds(status)
	playsound(src, 'sound/machines/capacitor_charge.ogg', 50, TRUE)
	sleep(2 SECONDS)
	playsound(src, 'sound/machines/capacitor_discharge.ogg', 50, TRUE)
	sleep(2 SECONDS)
	playsound(src, status ? 'sound/machines/microwave/microwave-end.ogg' : 'sound/machines/buzz-two.ogg', 50, TRUE)

/obj/machinery/xenoarchaeology_machine/calibrator/proc/finish_cooking(atom/atom_target, datum/component/xenoartifact/artifact_component, score, max_score, solid_as)
	//Timer
	if(cooking_timer)
		deltimer(cooking_timer)
	cooking_timer = null
	empty_contents(atom_target)
	//If we're cooked
	if(!solid_as)
		artifact_component.calcify()
		return
	//Scoring & success
	if(score)
		var/success_rate = score / max_score
		var/dp_reward = max(0, (atom_target.item_price*artifact_component.artifact_material.dp_rate)*success_rate) * reward_rate
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, dp_reward)
		//Announce this, for honor or shame
		var/message = "Skalibrowano [atom_target], co dało [dp_reward] punktów odkryć!"
		say(message)
		radio?.talk_into(src, message, RADIO_CHANNEL_SCIENCE)
	//Calibrate the artifact
	artifact_component.calibrate()
	//Prompt user to delete or keep malfunctions
	var/decision = tgui_alert(cooking_user?.resolve(), "Czy chcesz zwapnić usterki artefaktu [atom_target]?", "Usuwanie usterek", list("Tak", "Nie"))
	if(decision == "Tak")
		for(var/i in artifact_component.traits_catagories)
			for(var/datum/xenoartifact_trait/trait_datum in artifact_component.traits_catagories[i])
				if(istype(trait_datum, /datum/xenoartifact_trait/malfunction))
					qdel(trait_datum)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/calibrator
	name = "kalibrator materiałów anomalnych (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/calibrator
	req_components = list(/obj/item/stock_parts/matter_bin = 3, /obj/item/stock_parts/manipulator = 1)
