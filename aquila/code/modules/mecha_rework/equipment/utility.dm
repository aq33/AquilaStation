// AQUILA - moduły użytkowe, sensory i medyczne mechów (źródła w opisach).

/obj/item/mecha_parts/mecha_equipment/aq_utility
	name = "moduł użytkowy egzoszkieletu"
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_equip"
	selectable = FALSE
	aq_slot = AQ_MECHA_UTILITY
	mech_flags = EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_COMBAT | EXOSUIT_MODULE_MEDICAL
	/// Typ akcji przyznawanej pilotowi, gdy moduł jest zamontowany
	var/action_type
	var/datum/action/innate/mecha/aq_module/module_action

/obj/item/mecha_parts/mecha_equipment/aq_utility/attach(obj/mecha/M)
	. = ..()
	if(action_type && !module_action)
		module_action = new action_type
		module_action.module = src
		if(M.occupant)
			module_action.Grant(M.occupant, M)

/obj/item/mecha_parts/mecha_equipment/aq_utility/detach(atom/moveto)
	if(module_action)
		if(module_action.owner)
			module_action.Remove(module_action.owner)
		QDEL_NULL(module_action)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/Destroy()
	QDEL_NULL(module_action)
	return ..()

/// Akcja modułu (przycisk)
/obj/item/mecha_parts/mecha_equipment/aq_utility/proc/use_action(mob/living/user)
	return

/obj/mecha/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/U in equipment)
		U.module_action?.Grant(user, src)

/obj/mecha/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/U in equipment)
		U.module_action?.Remove(user)

/datum/action/innate/mecha/aq_module
	name = "Moduł mecha"
	button_icon_state = "mech_cycle_equip_on"
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/module

/datum/action/innate/mecha/aq_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner || !module || module.chassis != chassis)
		return
	module.use_action(owner)

/datum/action/innate/mecha/aq_module/Destroy()
	module = null
	return ..()

// ---------------------------------------------------------------- ruch
/obj/item/mecha_parts/mecha_equipment/aq_utility/magtreads
	name = "magnetyczne gąsienice egzoszkieletu"
	desc = "Magnetyczne podeszwy (Yogstation): mech trzyma się pokładu bez grawitacji i nie dryfuje w próżni, o ile ma pod sobą poszycie."
	icon_state = "mecha_magtreads"
	energy_drain = 2

/obj/mecha/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if((locate(/obj/item/mecha_parts/mecha_equipment/aq_utility/magtreads) in equipment) && !isspaceturf(get_turf(src)) && get_charge())
		return TRUE
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/jumpjet
	name = "silniki skokowe egzoszkieletu"
	desc = "Silniczki skokowe (Polaris): mech przeskakuje trzy pola przed sobą nad stołami, barierkami i ludźmi. Ściany i drzwi zatrzymują skok."
	icon_state = "mecha_afterburner"
	energy_drain = 300
	action_type = /datum/action/innate/mecha/aq_module/jumpjet
	COOLDOWN_DECLARE(jump_cd)

/datum/action/innate/mecha/aq_module/jumpjet
	name = "Skok"
	button_icon_state = "mech_thrusters_on"

/obj/item/mecha_parts/mecha_equipment/aq_utility/jumpjet/use_action(mob/living/user)
	if(!COOLDOWN_FINISHED(src, jump_cd))
		chassis.balloon_alert(user, "silniki stygną")
		return
	if(!chassis.has_charge(energy_drain) || chassis.equipment_disabled)
		return
	chassis.use_power(energy_drain)
	COOLDOWN_START(src, jump_cd, 10 SECONDS)
	playsound(chassis, 'sound/effects/podwoosh.ogg', 50, TRUE)
	chassis.visible_message("<span class='warning'>[chassis] wybija się w powietrze!</span>")
	var/old_layer = chassis.layer
	chassis.layer = ABOVE_MOB_LAYER
	animate(chassis, pixel_z = 12, time = 2)
	for(var/i in 1 to 3)
		var/turf/T = get_step(chassis, chassis.dir)
		if(!T || T.density)
			break
		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && (istype(O, /obj/machinery/door) || istype(O, /obj/structure/window) || ismecha(O)))
				blocked = TRUE
				break
		if(blocked)
			break
		chassis.forceMove(T)
		sleep(1)
	animate(chassis, pixel_z = 0, time = 2)
	chassis.layer = old_layer
	playsound(chassis, 'sound/mecha/mechstep.ogg', 60, TRUE)

/obj/item/mecha_parts/mecha_equipment/aq_utility/ejection
	name = "awaryjny system wyrzutu"
	desc = "Katapulta fotela (Yogstation): przy zniszczeniu mecha wyrzuca pilota i drugiego załoganta bez ogłuszenia. Przyciskiem można też wyskoczyć od razu."
	icon_state = "mecha_eject"
	action_type = /datum/action/innate/mecha/aq_module/ejection

/datum/action/innate/mecha/aq_module/ejection
	name = "Katapultuj"
	button_icon_state = "mech_eject"

/obj/item/mecha_parts/mecha_equipment/aq_utility/ejection/use_action(mob/living/user)
	eject_crew()

/obj/item/mecha_parts/mecha_equipment/aq_utility/ejection/proc/eject_crew()
	var/obj/mecha/M = chassis
	if(!M)
		return
	var/list/crew = list()
	if(M.aq_copilot)
		crew += M.aq_copilot
		M.aq_copilot_out()
	if(M.occupant && ishuman(M.occupant) && M.occupant != M.aq_remote_pilot)
		crew += M.occupant
		M.destruction_sleep_duration = 0
		M.go_out(TRUE)
	playsound(M, 'sound/effects/podwoosh.ogg', 60, TRUE)
	for(var/mob/living/L in crew)
		var/turf/T = get_edge_target_turf(M, turn(M.dir, 180))
		L.throw_at(T, 3, 1)
		to_chat(L, "<span class='notice'>Fotel wyrzuca cię z mecha!</span>")

/obj/mecha/obj_destruction(damage_flag)
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/ejection/E = locate() in equipment
	E?.eject_crew()
	return ..()

// ---------------------------------------------------------------- atmosfera i przewóz
/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield
	name = "osłona powietrzna egzoszkieletu"
	desc = "Pole wokół mecha (Baystation), które zatrzymuje gaz na sąsiednich polach. Ratuje ludzi przy wyłomach w kadłubie. Włącza się przyciskiem, zużywa prąd."
	icon_state = "aq_airshield"
	energy_drain = 10
	action_type = /datum/action/innate/mecha/aq_module/airshield
	var/active = FALSE
	var/list/barriers = list()

/datum/action/innate/mecha/aq_module/airshield
	name = "Osłona powietrzna"
	button_icon_state = "mech_internals_on"

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/use_action(mob/living/user)
	active = !active
	if(active)
		RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(refresh))
		START_PROCESSING(SSobj, src)
		refresh()
	else
		UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
		STOP_PROCESSING(SSobj, src)
		clear()
	chassis.occupant_message("Osłona powietrzna: [active ? "włączona" : "wyłączona"].")

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/proc/clear()
	QDEL_LIST(barriers)

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/proc/refresh()
	SIGNAL_HANDLER
	clear()
	if(!chassis)
		return
	for(var/turf/open/T in orange(1, chassis))
		if(locate(/obj/structure/holosign/barrier/atmos) in T)
			continue
		barriers += new /obj/structure/holosign/barrier/atmos(T)

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/process(delta_time)
	if(!chassis || !chassis.has_charge(energy_drain * delta_time))
		if(active && chassis)
			use_action(null)
		return
	chassis.use_power(energy_drain * delta_time)

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/detach(atom/moveto)
	if(active)
		use_action(null)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/airshield/Destroy()
	STOP_PROCESSING(SSobj, src)
	clear()
	return ..()

/// Moduł, który wiezie człowieka w mechu (pasażer, cela, nosze). Człowiek siedzi w zawartości mecha.
/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier
	var/max_carried = 1
	var/list/mob/living/carried = list()
	var/load_time = 3 SECONDS

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/proc/can_carry(mob/living/M)
	return length(carried) < max_carried

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/proc/load(mob/living/M)
	if(!chassis || !can_carry(M) || M.buckled || M == chassis.occupant)
		return FALSE
	carried += M
	M.forceMove(chassis)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/proc/unload(mob/living/M)
	carried -= M
	if(M.loc == chassis)
		M.forceMove(chassis.drop_location())

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/get_equip_info()
	. = ..()
	. += " \[[length(carried)]/[max_carried]\]"
	if(length(carried))
		. += " - <a href='byond://?src=[REF(src)];aq_unload=1'>wysadź</a>"

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/Topic(href, href_list)
	..()
	if(href_list["aq_unload"])
		for(var/mob/living/M in carried.Copy())
			unload(M)
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/detach(atom/moveto)
	for(var/mob/living/M in carried.Copy())
		unload(M)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/Destroy()
	for(var/mob/living/M in carried.Copy())
		unload(M)
	return ..()

/obj/mecha/Exited(atom/movable/M, atom/newloc)
	. = ..()
	if(isliving(M))
		for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/C in equipment)
			C.carried -= M

/obj/mecha/Destroy()
	for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/C in equipment)
		for(var/mob/living/M in C.carried.Copy())
			C.unload(M)
	return ..()

/obj/mecha/proc/aq_carrier_of(mob/living/M)
	for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/C in equipment)
		if(M in C.carried)
			return C
	return null

/obj/mecha/MouseDrop_T(mob/M, mob/user)
	if(!isliving(M) || !ishuman(user) || user.incapacitated() || !Adjacent(user) || !Adjacent(M))
		return ..()
	// Ktoś wkłada innego: skutego do celi, leżącego na nosze
	if(user != M)
		var/mob/living/L = M
		for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/C in equipment)
			if(!C.accepts_from_outside(L) || !C.can_carry(L))
				continue
			visible_message("<span class='warning'>[user] wkłada [L] do [src].</span>")
			if(do_after(user, C.load_time, target = L) && C.chassis == src && C.load(L))
				to_chat(L, "<span class='warning'>Lądujesz w: [C.name] ([src]).</span>")
			return
		return ..()
	// Pasażer wsiada sam, gdy pilot już siedzi
	if(occupant && (!aq_has_copilot_seat() || aq_copilot))
		var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/passenger_compartment/P = locate() in equipment
		if(P?.can_carry(M))
			visible_message("[user] wchodzi do przedziału pasażerskiego [src].")
			if(do_after(user, P.load_time, target = src) && P.chassis == src)
				P.load(user)
			return
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/proc/accepts_from_outside(mob/living/M)
	return FALSE

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/passenger_compartment
	name = "przedział pasażerski egzoszkieletu"
	desc = "Fotel z pasami za kabiną (Aurora i inne): przewozi pasażera wewnątrz mecha. Pasażer wsiada przeciągając się na mecha, a wysiada ruchem. Z portami strzeleckimi może strzelać z wnętrza."
	icon_state = "aq_passenger"

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/passenger_compartment/accepts_from_outside(mob/living/M)
	return M.stat != CONSCIOUS

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/stretcher
	name = "montowane nosze egzoszkieletu"
	desc = "Nosze (MonkeStation) do przewozu leżącego rannego. Rannego kładzie się, przeciągając go na mecha; wysiada ruchem albo przyciskiem w oknie mecha."
	icon_state = "mecha_mounted_stretcher"
	mech_flags = EXOSUIT_MODULE_MEDICAL | EXOSUIT_MODULE_RIPLEY
	load_time = 2 SECONDS

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/stretcher/accepts_from_outside(mob/living/M)
	return !(M.mobility_flags & MOBILITY_STAND) || M.stat != CONSCIOUS

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/stretcher/load(mob/living/M)
	. = ..()
	if(.)
		M.SetSleeping(0)

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell
	name = "cela egzoszkieletu"
	desc = "Cela w kadłubie mecha (tg, /vg/, SS220) na dwóch skutych zatrzymanych. Wkłada się ich chwytakiem Paddy albo przeciągając na mecha. Z celi nie wyjdzie się ruchem: trzeba się wyrwać (pół minuty)."
	icon_state = "aq_jail_cell"
	max_carried = 2
	load_time = 4 SECONDS
	mech_flags = EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell/accepts_from_outside(mob/living/M)
	return iscarbon(M) && (M.restrained() || M.stat != CONSCIOUS)

/obj/mecha/relaymove(mob/user, direction)
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell/cell = aq_carrier_of(user)
	if(istype(cell))
		if(world.time - last_message > 30)
			to_chat(user, "<span class='warning'>Szarpiesz się w celi, ale drzwi są zamknięte.</span>")
		return FALSE
	return ..()

/obj/mecha/container_resist(mob/living/user)
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell/cell = aq_carrier_of(user)
	if(istype(cell))
		to_chat(user, "<span class='notice'>Próbujesz wyważyć drzwi celi (30 s).</span>")
		occupant_message("<span class='warning'>Zatrzymany próbuje wyrwać się z celi!</span>")
		if(do_after(user, 30 SECONDS, target = src) && (user in cell.carried))
			cell.unload(user)
			visible_message("<span class='danger'>[user] wyrywa się z celi [src]!</span>")
		return
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/C = aq_carrier_of(user)
	if(C)
		C.unload(user)
		return
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/gunner
	name = "moduł strzelca"
	desc = "Moduł z podów (Goonstation): wieżyczka pod wybraną bronią, z której drugi załogant albo pasażer strzela w dowolną stronę."
	icon_state = "aq_gunner"

/obj/item/mecha_parts/mecha_equipment/aq_utility/weapons_loader
	name = "ładowarka uzbrojenia"
	desc = "Moduł z podów (Goonstation): podwaja zapas amunicji broni balistycznej i sam przeładowuje pustą broń z zapasu."
	icon_state = "aq_weapons_loader"
	mech_flags = EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak
	name = "moduł maskujący egzoszkieletu"
	desc = "Maskowanie optyczne (Polaris): mech staje się prawie niewidzialny i niewidoczny w podczerwieni. Każdy strzał albo cios zdejmuje maskowanie. Pożera prąd. Sprzęt Syndykatu."
	icon_state = "aq_cloak"
	energy_drain = 40
	action_type = /datum/action/innate/mecha/aq_module/cloak
	mech_flags = EXOSUIT_MODULE_COMBAT
	var/active = FALSE

/datum/action/innate/mecha/aq_module/cloak
	name = "Maskowanie"
	button_icon_state = "mech_phasing_off"

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/use_action(mob/living/user)
	set_cloak(!active)

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/proc/set_cloak(state)
	if(!chassis || state == active)
		return
	active = state
	if(active)
		animate(chassis, alpha = 20, time = 1 SECONDS)
		chassis.infra_luminosity = 0
		START_PROCESSING(SSobj, src)
	else
		animate(chassis, alpha = 255, time = 0.5 SECONDS)
		chassis.infra_luminosity = initial(chassis.infra_luminosity)
		STOP_PROCESSING(SSobj, src)
	chassis.occupant_message("Maskowanie: [active ? "włączone" : "wyłączone"].")

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/process(delta_time)
	if(!chassis || !chassis.has_charge(energy_drain * delta_time))
		set_cloak(FALSE)
		return
	chassis.use_power(energy_drain * delta_time)

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/detach(atom/moveto)
	set_cloak(FALSE)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_on_used()
	. = ..()
	if(chassis && harmful)
		for(var/obj/item/mecha_parts/mecha_equipment/aq_utility/cloak/C in chassis.equipment)
			C.set_cloak(FALSE)

// ---------------------------------------------------------------- sensory
/obj/item/mecha_parts/mecha_equipment/aq_utility/light_amp
	name = "moduł wzmacniania światła egzoszkieletu"
	desc = "Wzmacniacz obrazu kabiny (MonkeStation): noktowizja i widok konstrukcji dla pilota. Ciemne wraki, opuszczone stacje i planety nocą."
	icon_state = "mecha_lightamplification"

/obj/mecha/update_remote_sight(mob/living/user)
	. = ..()
	if(user == occupant && (locate(/obj/item/mecha_parts/mecha_equipment/aq_utility/light_amp) in equipment))
		user.sight |= SEE_TURFS
		user.see_in_dark = max(user.see_in_dark, 8)
		user.lighting_alpha = min(user.lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)

/obj/item/mecha_parts/mecha_equipment/aq_utility/light_amp/attach(obj/mecha/M)
	. = ..()
	M.occupant?.update_sight()

/obj/item/mecha_parts/mecha_equipment/aq_utility/light_amp/detach(atom/moveto)
	var/mob/living/L = chassis?.occupant
	. = ..()
	L?.update_sight()

/obj/item/mecha_parts/mecha_equipment/aq_utility/zoom
	name = "moduł przybliżenia egzoszkieletu"
	desc = "Optyka dalekiego zasięgu (TGMC): przybliża widok pilota. W trybie przybliżenia mech stoi w miejscu."
	icon_state = "aq_zoom"
	action_type = /datum/action/innate/mecha/aq_module/zoom
	var/zoom_range = 4.5

/datum/action/innate/mecha/aq_module/zoom
	name = "Przybliżenie"
	button_icon_state = "mech_zoom_off"

/obj/item/mecha_parts/mecha_equipment/aq_utility/zoom/use_action(mob/living/user)
	if(!user?.client)
		return
	chassis.zoom_mode = !chassis.zoom_mode
	if(chassis.zoom_mode)
		user.client.view_size.setTo(zoom_range)
		SEND_SOUND(user, sound('sound/mecha/imag_enh.ogg', volume = 50))
	else
		user.client.view_size.resetToDefault()
	chassis.occupant_message("Przybliżenie: [chassis.zoom_mode ? "włączone" : "wyłączone"].")

/obj/item/mecha_parts/mecha_equipment/aq_utility/zoom/artillery
	name = "moduł artyleryjski egzoszkieletu"
	desc = "Daleki widok i namierzanie (CM-SS13) dla broni dalekiego zasięgu: dużo większe przybliżenie niż zwykła optyka. Dla strzelca Savannah i rakiet kierowanych."
	icon_state = "aq_artillery"
	zoom_range = 8
	mech_flags = EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/aq_utility/camera
	name = "kamera egzoszkieletu"
	desc = "Kamera mecha (Baystation) widoczna na monitorach okrętu w sieci stacji i badań. Mostek widzi akcję mecha."
	icon_state = "mecha_camera"
	var/obj/machinery/camera/cam

/obj/item/mecha_parts/mecha_equipment/aq_utility/camera/attach(obj/mecha/M)
	. = ..()
	if(!cam)
		cam = new(M)
		cam.network = list("ss13", "rd")
		cam.c_tag = "Mech: [M.name]"

/obj/item/mecha_parts/mecha_equipment/aq_utility/camera/detach(atom/moveto)
	QDEL_NULL(cam)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/camera/Destroy()
	QDEL_NULL(cam)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/radar
	name = "\improper antena radarowa U-56"
	desc = "Radar (CM-SS13) pokazujący pilotowi żywe cele w promieniu 10 pól, także za ścianami. Wykrywanie boarderów i fauny na planetach."
	icon_state = "mecha_radio"
	energy_drain = 5

/obj/item/mecha_parts/mecha_equipment/aq_utility/radar/attach(obj/mecha/M)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/aq_utility/radar/detach(atom/moveto)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/radar/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_utility/radar/process(delta_time)
	var/mob/pilot = chassis?.occupant
	if(!pilot?.client || chassis.equipment_disabled || !chassis.has_charge(energy_drain))
		return
	chassis.use_power(energy_drain)
	var/list/blips = list()
	for(var/mob/living/L in range(10, chassis))
		if(L == pilot || L == chassis.aq_copilot || L.stat == DEAD || L.loc == chassis)
			continue
		var/image/I = image('icons/effects/effects.dmi', get_turf(L), "blip", ABOVE_LIGHTING_LAYER)
		I.plane = ABOVE_LIGHTING_PLANE
		blips += I
	if(length(blips))
		for(var/image/I as anything in blips)
			flick_overlay(I, list(pilot.client), 1.5 SECONDS)

// ---------------------------------------------------------------- medyczne
/obj/item/mecha_parts/mecha_equipment/aq_health_analyzer
	name = "montowany analizator zdrowia egzoszkieletu"
	desc = "Analizator zdrowia (Aurora) działający z kabiny: klik w człowieka obok mecha pokazuje jego stan."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_health_analyzer"
	aq_slot = AQ_MECHA_UTILITY
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 10
	energy_drain = 5
	mech_flags = EXOSUIT_MODULE_MEDICAL | EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/aq_health_analyzer/action(atom/target, params)
	if(!action_checks(target) || !isliving(target) || get_dist(chassis, target) > 2)
		return 0
	healthscan(chassis.occupant, target)
	return 1
