/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */
GLOBAL_LIST_EMPTY(cryopod_computers)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "konsola nadzoru kriogenicznego"
	desc = "Interfejs między załogą a systemami nadzoru przechowywania kriogenicznego."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cellconsole_1"
	// circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Nadzór kriogeniczny"
	var/allow_items = TRUE

/obj/machinery/computer/cryopod/Initialize(mapload)
	. = ..()
	GLOB.cryopod_computers += src

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	..()

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryopodConsole", name)
		ui.open()

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = list()
	data["storage_name"] = storage_name
	data["storage_type"] = storage_type
	data["user_name"] = user.real_name
	data["allow_items"] = allow_items
	data["frozen_crew"] = frozen_crew.Copy()
	var/list/items = list()
	if(allow_items)
		for(var/obj/item/I in frozen_items)
			items += list(list("name" = I.name, "ref" = REF(I)))
	data["frozen_items"] = items
	return data

/obj/machinery/computer/cryopod/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	add_fingerprint(user)
	switch(action)
		if("item")
			if(!allowed(user))
				to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")
				return
			if(!allow_items)
				return
			var/obj/item/I = locate(params["ref"]) in frozen_items
			if(!I)
				to_chat(user, "<span class='notice'>Tego przedmiotu nie ma już w magazynie.</span>")
				return TRUE
			visible_message("<span class='notice'>Konsola radośnie pika, wypluwając [I].</span>")
			I.forceMove(get_turf(src))
			frozen_items -= I
			return TRUE
		if("allitems")
			if(!allowed(user))
				to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")
				return
			if(!allow_items)
				return
			if(!length(frozen_items))
				to_chat(user, "<span class='notice'>W magazynie nie ma nic do odzyskania.</span>")
				return
			visible_message("<span class='notice'>Konsola radośnie pika, wypluwając wybrane przedmioty.</span>")
			for(var/obj/item/I in frozen_items)
				I.forceMove(get_turf(src))
				frozen_items -= I
			return TRUE

/* Should more cryos be buildable?
    /obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = "programming=1"
*/
//Cryopods themselves.
/obj/machinery/cryopod
	name = "zamrażarka kriogeniczna"
	desc = "Kapsuła odpowiednia dla cyborgów i humanoidów. To bezpieczne miejsce, w którym personel dotknięty Kosmicznym Zaburzeniem Snu może odpocząć."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE

	var/on_store_message = "przechodzi do długoterminowego przechowywania."
	var/on_store_name = "Nadzór kriogeniczny"

	// 5 minutes-ish safe period before being despawned.
	var/time_till_despawn = 5 * 600 // This is reduced to 30 seconds if a player manually enters cryo
	var/despawn_world_time = null          // Used to keep track of the safe period.

	var/datum/weakref/control_computer_weakref
	var/last_no_computer_message = 0

	// These items are preserved when the process() despawn proc occurs.
	var/static/list/preserve_items = list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/mmi,
		/obj/item/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/defibrillator/compact,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/krav_maga,
		/obj/item/nullrod,
		/obj/item/tank/jetpack,
		/obj/item/documents,
		/obj/item/nuke_core_container
	)

/obj/machinery/cryopod/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/LateInitialize()
	update_icon()
	find_control_computer()

// This is not a good situation
/obj/machinery/cryopod/Destroy()
	control_computer_weakref = null
	return ..()

/obj/machinery/cryopod/proc/find_control_computer(urgent = FALSE)
	for(var/cryo_console as anything in GLOB.cryopod_computers)
		var/obj/machinery/computer/cryopod/console = cryo_console
		if(get_area(console) == get_area(src))
			control_computer_weakref = WEAKREF(console)
			break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer_weakref && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Kriokapsuła w [get_area(src)] nie może znaleźć komputera sterującego!")
		last_no_computer_message = world.time

	return control_computer_weakref != null

/obj/machinery/cryopod/close_machine(mob/user)
	if(!control_computer_weakref)
		find_control_computer(TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "<span class='boldnotice'>Otacza cię chłodne powietrze. Drętwiejesz, a twoje zmysły zwracają się do wewnątrz.</span>")
		if(mob_occupant.client)//if they're logged in
			despawn_world_time = world.time + (time_till_despawn * 0.1) // This gives them 30 seconds
		else
			despawn_world_time = world.time + time_till_despawn
	icon_state = "cryopod"

/obj/machinery/cryopod/open_machine()
	..()
	icon_state = "cryopod-open"
	density = TRUE
	name = initial(name)

/obj/machinery/cryopod/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] wychodzi z [src]!</span>",
		"<span class='notice'>Wychodzisz z [src]!</span>")
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/cryopod/process()
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		// Eject dead people
		if(mob_occupant.stat == DEAD)
			open_machine()

		if(!(world.time > despawn_world_time))
			return

		if(!mob_occupant.client && mob_occupant.stat < 2) //Occupant is living and has no client.
			if(!control_computer_weakref)
				find_control_computer(urgent = TRUE)//better hope you found it this time

			despawn_occupant()

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/mob_occupant = occupant

	if(mob_occupant.mind && mob_occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role
		SSjob.FreeRole(job)

	// Delete them from datacore.

	var/announce_rank = null
	for(var/datum/data/record/R as() in GLOB.data_core.medical)
		if((R.fields["name"] == mob_occupant.real_name))
			qdel(R)
	for(var/datum/data/record/T as() in GLOB.data_core.security)
		if((T.fields["name"] == mob_occupant.real_name))
			qdel(T)
	for(var/datum/data/record/G as() in GLOB.data_core.general)
		if((G.fields["name"] == mob_occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)

	for(var/obj/machinery/computer/cloning/cloner in GLOB.machines)
		for(var/datum/data/record/R as() in cloner.records)
			if(R.fields["name"] == mob_occupant.real_name)
				cloner.records.Remove(R)

	//Make an announcement and log the person entering storage.
	var/obj/machinery/computer/cryopod/control_computer = control_computer_weakref?.resolve()
	if(!control_computer)
		control_computer_weakref = null
	else
		control_computer.frozen_crew += "[mob_occupant.real_name]"

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		if(mob_occupant.job == JOB_NAME_CAPTAIN)
			minor_announce("[JOB_NAME_CAPTAIN] [mob_occupant.real_name] przechodzi do przechowywania kriogenicznego.")  // for when the admins do a stupid british gimmick that makes 0 sense cough
		else
			announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())
		visible_message("<span class='notice'>[src] buczy i syczy, przenosząc [mob_occupant.real_name] do magazynu.</span>")


	for(var/obj/item/W in mob_occupant.GetAllContents())
		if(W.loc.loc && (( W.loc.loc == loc ) || (W.loc.loc == control_computer)))
			continue//means we already moved whatever this thing was in
			//I'm a professional, okay
		for(var/T in preserve_items)
			if(istype(W, T))
				if(control_computer && control_computer.allow_items)
					control_computer.frozen_items += W
					mob_occupant.transferItemToLoc(W, control_computer, TRUE)
				else
					mob_occupant.transferItemToLoc(W, loc, TRUE)

	for(var/obj/item/W in mob_occupant.GetAllContents())
		qdel(W)//because we moved all items to preserve away
		//and yes, this totally deletes their bodyparts one by one, I just couldn't bother

	if(iscyborg(mob_occupant))
		var/mob/living/silicon/robot/R = occupant
		if(!istype(R)) return

		R.contents -= R.mmi
		QDEL_NULL(R.mmi)

	// Ghost and delete the mob.
	if(!mob_occupant.get_ghost(TRUE))
		if(world.time < 15 * 600)//before the 15 minute mark
			mob_occupant.ghostize(FALSE,SENTIENCE_ERASE) // Players despawned too early may not re-enter the game
		else
			mob_occupant.ghostize(TRUE,SENTIENCE_ERASE)
	if(mob_occupant.mind)
		SEND_SIGNAL(mob_occupant.mind, COMSIG_MIND_CRYOED)
	QDEL_NULL(occupant)
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, "<span class='boldnotice'>Kapsuła kriogeniczna jest już zajęta!</span>")
		return

	if(target.stat == DEAD)
		to_chat(user, "<span class='notice'>Nie można umieszczać zmarłych w kriokomorze.</span>")
		return

	if(target.client && user != target)
		if(iscyborg(target))
			to_chat(user, "<span class='danger'>Nie możesz umieścić [target] w [src]. Jest online.</span>")
		else
			to_chat(user, "<span class='danger'>Nie możesz umieścić [target] w [src]. Jest przytomny.</span>")
		return
	else if(target.client)
		if(alert(target,"Czy chcesz wejść w sen kriogeniczny?",,"Yes","No") != "Yes")
			return

	var/generic_plsnoleave_message = " Przed opuszczeniem rundy napisz ahelp, nawet jeśli żaden administrator nie jest online!"

	if(target == user && world.time - target.client.cryo_warned > 5 MINUTES)//if we haven't warned them in the last 5 minutes
		var/caught = FALSE
		var/datum/antagonist/A = target.mind.has_antag_datum(/datum/antagonist)
		if(target.mind.assigned_role in GLOB.command_positions)
			alert("Jesteś szefem działu![generic_plsnoleave_message]")
			caught = TRUE
		if(A)
			alert("Jesteś: [A.name]![generic_plsnoleave_message]")
			caught = TRUE
		if(caught)
			target.client.cryo_warned = world.time
			return

	if(!target || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return
		//rerun the checks in case of shenanigans

	if(target == user)
		visible_message("[user] zaczyna wchodzić do kapsuły kriogenicznej.")
	else
		visible_message("[user] zaczyna wkładać [target] do kapsuły kriogenicznej.")

	if(occupant)
		to_chat(user, "<span class='boldnotice'>[src] jest w użyciu.</span>")
		return
	close_machine(target)

	to_chat(target, "<span class='boldnotice'>Jeśli teraz zamienisz się w ducha, wylogujesz się lub zamkniesz klienta, twoja postać wkrótce zostanie trwale usunięta z rundy.</span>")
	name = "[name] ([occupant.name])"
	if((world.time - SSticker.round_start_time) < 5 MINUTES)
		message_admins("<span class='danger'>[key_name_admin(target)] ([target.job]) wchodzi do kapsuły stazy. (<A HREF='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a></span>)")
	else
		message_admins("[key_name_admin(target)] ([target.job]) wchodzi do kapsuły stazy. (<A HREF='byond://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	log_admin("<span class='notice'>[key_name(target)], the [target.job] entered a stasis pod.</span>")
	add_fingerprint(target)

//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.
