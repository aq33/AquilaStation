// AQUILA - zdalne sterowanie mechem (wzór: Aurora, pilot siedzi w konsoli i steruje mechem z odbiornikiem).
// Mech musi mieć moduł odbiornika i być pusty. Pilot wsiada do kokpitu zdalnego (przeciągnięcie na konsolę),
// wybiera mech z listy i od tej chwili jest jego occupantem na odległość: ruch idzie przez remote_control,
// kliknięcia przez COMSIG_MOB_CLICKON, widok przez reset_perspective. Wyjście z mecha kończy sesję, a pilot
// zostaje w konsoli. Rdzeń sprawdza w process(), czy occupant siedzi w mechu: hook AQ EDIT pomija to dla pilota zdalnego.

/obj/mecha
	/// Pilot sterujący z konsoli (wtedy jest też occupantem)
	var/mob/living/carbon/aq_remote_pilot
	/// Konsola, z której idzie sterowanie
	var/obj/machinery/aq_mecha_remote_pod/aq_remote_pod

/obj/item/mecha_parts/mecha_equipment/aq_remote_receiver
	name = "odbiornik zdalnego sterowania egzoszkieletu"
	desc = "Antena i komputer pozwalające sterować pustym mechem z kokpitu zdalnego. Mech z odbiornikiem widać na liście konsoli zdalnego sterowania."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_remote"
	selectable = FALSE
	aq_slot = AQ_MECHA_UTILITY

/obj/mecha/proc/aq_start_remote(mob/living/carbon/human/pilot, obj/machinery/aq_mecha_remote_pod/pod)
	if(occupant || aq_remote_pilot || !pilot?.client)
		return FALSE
	if(!(locate(/obj/item/mecha_parts/mecha_equipment/aq_remote_receiver) in equipment))
		return FALSE
	if(!aq_entry_allowed(pilot)) // blokada DNA i kody operacyjne jak przy wejściu do kabiny
		return FALSE
	aq_remote_pilot = pilot
	aq_remote_pod = pod
	occupant = pilot
	pilot.remote_control = src
	pilot.reset_perspective(src)
	GrantActions(pilot, human_occupant = 1)
	RegisterSignal(pilot, COMSIG_MOB_CLICKON, PROC_REF(aq_remote_click))
	icon_state = initial(icon_state)
	update_icon()
	setDir(dir_in)
	log_message("[pilot] started remote control from [pod].", LOG_MECHA)
	to_chat(pilot, "<span class='notice'>Łącze nawiązane: sterujesz [src] zdalnie. Wyjście z mecha kończy sesję.</span>")
	return TRUE

/obj/mecha/proc/aq_end_remote()
	var/mob/living/carbon/pilot = aq_remote_pilot
	if(!pilot)
		return
	aq_remote_pilot = null
	aq_remote_pod = null
	if(occupant == pilot)
		occupant = null
	UnregisterSignal(pilot, COMSIG_MOB_CLICKON)
	RemoveActions(pilot, human_occupant = 1)
	if(pilot.remote_control == src)
		pilot.remote_control = null
	pilot.reset_perspective(null)
	pilot.clear_alert("charge")
	pilot.clear_alert("mech damage")
	SStgui.close_user_uis(pilot, src)
	if(pilot.client)
		pilot.client.view_size.resetToDefault()
	zoom_mode = FALSE
	icon_state = initial(icon_state) + "-open"
	update_icon()
	log_message("[pilot] ended remote control.", LOG_MECHA)
	to_chat(pilot, "<span class='notice'>Łącze zdalnego sterowania zamknięte.</span>")
	// go_out() pilota zdalnego nie dochodzi do rdzenia ani do copilot.dm: kierowca przejmuje fotel tutaj
	aq_promote_copilot()

/obj/mecha/proc/aq_remote_click(mob/source, atom/A, list/modifiers)
	SIGNAL_HANDLER
	if(source != aq_remote_pilot)
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK)) // oglądanie zostaje zwykłe
		return
	INVOKE_ASYNC(src, PROC_REF(click_action), A, source, list2params(modifiers))
	return COMSIG_MOB_CANCEL_CLICKON

/obj/mecha/go_out(forced, atom/newloc = loc)
	if(aq_remote_pilot && occupant == aq_remote_pilot)
		aq_end_remote()
		return
	return ..()

/obj/mecha/container_resist(mob/living/user)
	if(aq_remote_pilot && user == aq_remote_pilot)
		aq_end_remote()
		return
	return ..()

/// Pocisk broni mecha sterowanego zdalnie startuje z mecha, nie z kokpitu: rdzeń (weapons.dm) podaje chassis.occupant
/// jako źródło. Kąt z kursora liczy się dalej od pilota, bo jego widok jest wyśrodkowany na mechu.
/obj/item/projectile/preparePixelProjectile(atom/target, atom/source, params, spread = 0)
	var/mob/living/pilot = source
	if(!istype(pilot))
		return ..()
	var/obj/mecha/remote_mech = pilot.remote_control
	if(!istype(remote_mech) || remote_mech.aq_remote_pilot != pilot || pilot.loc == remote_mech)
		return ..()
	. = ..(target, remote_mech, params, spread)
	if(QDELETED(src) || !params || !pilot.client)
		return
	var/list/calculated = calculate_projectile_angle_and_pixel_offsets(pilot, params)
	p_x = calculated[2]
	p_y = calculated[3]
	setAngle(calculated[1] + spread)

/obj/mecha/Destroy()
	if(aq_remote_pilot)
		to_chat(aq_remote_pilot, "<span class='userdanger'>Sygnał z [src] urywa się!</span>")
		aq_end_remote()
	return ..()

// ---------------------------------------------------------------- kokpit zdalny
/obj/machinery/aq_mecha_remote_pod
	name = "kokpit zdalnego sterowania egzoszkieletem"
	desc = "Fotel z pulpitem i goglami, z którego steruje się mechem wyposażonym w odbiornik zdalnego sterowania. Przeciągnij się na fotel, żeby usiąść."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/aq_mecha_remote_pod
	req_one_access = list(ACCESS_ROBOTICS, ACCESS_RD)
	idle_power_usage = 50
	active_power_usage = 500
	/// Kto siedzi w kokpicie
	var/mob/living/carbon/human/pilot
	/// Którym mechem steruje
	var/obj/mecha/linked

/obj/machinery/aq_mecha_remote_pod/Destroy()
	aq_eject()
	return ..()

/obj/machinery/aq_mecha_remote_pod/update_icon_state()
	icon_state = pilot ? "sleeper" : "sleeper-open"
	return ..()

/obj/machinery/aq_mecha_remote_pod/MouseDrop_T(mob/M, mob/user)
	if(user != M || !ishuman(user) || user.incapacitated() || !Adjacent(user))
		return
	if(pilot)
		to_chat(user, "<span class='warning'>[src] jest zajęty.</span>")
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")
		return
	if(!do_after(user, 2 SECONDS, target = src))
		return
	if(pilot)
		return
	pilot = user
	user.forceMove(src)
	update_appearance()
	START_PROCESSING(SSmachines, src)
	INVOKE_ASYNC(src, PROC_REF(aq_pick_mech), user)

/obj/machinery/aq_mecha_remote_pod/proc/aq_available_mechs()
	. = list()
	for(var/obj/mecha/M as anything in GLOB.mechas_list)
		if(M.occupant || M.aq_remote_pilot || QDELETED(M))
			continue
		if(!(locate(/obj/item/mecha_parts/mecha_equipment/aq_remote_receiver) in M.equipment))
			continue
		if(M.z && z && M.z != z && !(M.z in SSmapping.levels_by_trait(ZTRAIT_STATION)))
			continue
		.["[M.name] ([get_area_name(M, TRUE)])"] = M

/obj/machinery/aq_mecha_remote_pod/proc/aq_pick_mech(mob/user)
	if(user != pilot || user.loc != src)
		return
	var/list/mechs = aq_available_mechs()
	if(!length(mechs))
		to_chat(user, "<span class='warning'>Brak dostępnych mechów z odbiornikiem zdalnego sterowania.</span>")
		return
	var/choice = input(user, "Którym mechem sterować?", "Zdalne sterowanie") as null|anything in mechs
	if(!choice || user != pilot || user.loc != src)
		return
	var/obj/mecha/M = mechs[choice]
	if(QDELETED(M) || !M.aq_start_remote(user, src))
		to_chat(user, "<span class='warning'>Nie udało się nawiązać łącza.</span>")
		return
	linked = M
	use_power = ACTIVE_POWER_USE

/obj/machinery/aq_mecha_remote_pod/process()
	if(!pilot)
		return PROCESS_KILL
	if(pilot.loc != src || pilot.stat || machine_stat & (NOPOWER|BROKEN))
		aq_eject()
		return PROCESS_KILL
	if(linked && linked.aq_remote_pilot != pilot)
		linked = null
		use_power = IDLE_POWER_USE

/obj/machinery/aq_mecha_remote_pod/container_resist(mob/living/user)
	if(user == pilot)
		aq_eject()

/obj/machinery/aq_mecha_remote_pod/relaymove(mob/user, direction)
	if(user == pilot && !linked)
		aq_eject()

/obj/machinery/aq_mecha_remote_pod/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user == pilot && !linked)
		INVOKE_ASYNC(src, PROC_REF(aq_pick_mech), user)
		return TRUE

/obj/machinery/aq_mecha_remote_pod/proc/aq_eject()
	if(linked?.aq_remote_pilot)
		linked.aq_end_remote()
	linked = null
	if(pilot)
		var/mob/living/L = pilot
		pilot = null
		if(L.loc == src)
			L.forceMove(drop_location())
	use_power = IDLE_POWER_USE
	update_appearance()

/obj/machinery/aq_mecha_remote_pod/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == pilot)
		if(linked?.aq_remote_pilot)
			linked.aq_end_remote()
		linked = null
		pilot = null
		update_appearance()

/obj/item/circuitboard/machine/aq_mecha_remote_pod
	name = "kokpit zdalnego sterowania egzoszkieletem (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/aq_mecha_remote_pod
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5)
