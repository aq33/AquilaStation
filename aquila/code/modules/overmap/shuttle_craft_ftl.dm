// AQUILA - uwiąz FTL małych jednostek. Napęd FTL myśliwca wiąże się z okrętem tylko w LateInitialize przy wczytaniu
// mapy, więc prom tworzony przez port (Sabre z wnętrzem) latał bez uwiązu i „Powrót” odpowiadał „Utracono uwiąz FTL”.
// Tu: prom z wnętrzem wiąże się z okrętem portu domowego, „Powrót” bez uwiązu bierze ten okręt i mówi, co zrobić,
// a przed skokiem okrętu załogi jednostek zostających w układzie dostają ostrzeżenie.

/// Okręt, do którego napęd FTL wraca „Powrotem”; null bez napędu albo bez uwiązu
/obj/structure/overmap/small_craft/proc/get_ftl_tether()
	var/obj/item/fighter_component/ftl/ftl = loadout?.get_slot(HARDPOINT_SLOT_FTL)
	if(!ftl)
		return
	if(QDELETED(ftl.anchored_to))
		ftl.anchored_to = null
	return ftl.anchored_to

/// Wiąże napęd FTL z okrętem (nie z asteroidą: z niej nie ma dokąd wracać)
/obj/structure/overmap/small_craft/proc/set_ftl_tether(obj/structure/overmap/OM)
	if(!OM || OM == src || QDELETED(OM) || isasteroid(OM))
		return FALSE
	var/obj/item/fighter_component/ftl/ftl = loadout?.get_slot(HARDPOINT_SLOT_FTL)
	if(!ftl)
		return FALSE
	ftl.anchored_to = OM
	return TRUE

/// Okręt macierzysty, gdy uwiąz zginął; myśliwce go nie znają
/obj/structure/overmap/small_craft/proc/ftl_home_overmap()
	return

/// Prom z wnętrzem: okręt, na którym stoi jego port domowy
/obj/structure/overmap/small_craft/transport/ftl_home_overmap()
	var/obj/structure/overmap/home = shuttle_home_port?.get_overmap()
	if(home && home != src && !isasteroid(home))
		return home

/obj/structure/overmap/small_craft/ui_act(action, params, datum/tgui/ui)
	if(action == "return_jump" && (usr == pilot || IsAdminGhost(usr)) && !can_return_jump(usr))
		return TRUE
	return ..()

/// Sprawdza „Powrót” przed napędem FTL i mówi pilotowi, co zrobić, kiedy skok jest niemożliwy
/obj/structure/overmap/small_craft/proc/can_return_jump(mob/user)
	var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
	if(!ftl)
		to_chat(user, span_warning("[src] nie ma napędu FTL."))
		return FALSE
	var/obj/structure/overmap/home = get_ftl_tether()
	if(!home && set_ftl_tether(ftl_home_overmap()))
		home = get_ftl_tether()
	if(!home)
		to_chat(user, span_warning("Nie można wykonać: brak uwiązu FTL. Zadokuj w okręcie macierzystym albo w jego hangarze naciśnij „Wypuść linkę”."))
		return FALSE
	if(ftl.ftl_state == FTL_STATE_JUMPING)
		to_chat(user, span_warning("Skok FTL już trwa."))
		return FALSE
	if(ftl.ftl_state != FTL_STATE_READY)
		if(!ftl.active)
			to_chat(user, span_warning("Napęd FTL jest wyłączony. Naciśnij „Rozkręć napęd”, poczekaj, aż pasek pod przyciskami się zapełni, i dopiero wtedy „Powrót”."))
		else
			to_chat(user, span_warning("Napęd FTL wciąż się rozkręca ([round(ftl.progress / max(ftl.spoolup_time, 1) * 100)]%). Poczekaj, aż pasek się zapełni."))
		return FALSE
	if(!SSmapping.level_trait(z, ZTRAIT_OVERMAP) || SSmapping.level_trait(z, ZTRAIT_RESERVED))
		to_chat(user, span_warning("Z doku nie da się skoczyć. Najpierw wystartuj na otwartą przestrzeń."))
		return FALSE
	if(get_overmap())
		to_chat(user, span_warning("Za blisko innego okrętu albo asteroidy. Odleć kawałek i spróbuj ponownie."))
		return FALSE
	if(!home.current_system)
		to_chat(user, span_warning("[home] jest w tranzycie FTL. Poczekaj, aż wyjdzie z nadprzestrzeni, i spróbuj ponownie."))
		return FALSE
	return TRUE

/obj/structure/overmap/small_craft/set_master_caution(state)
	if(state && master_caution)
		return // Pętla już gra: bez tego use_fuel() bez paliwa zaczynałby ją od nowa przy każdym ticku
	return ..()

// Ostrzeżenie przed skokiem okrętu: jednostki tej samej frakcji w układzie (w locie i zadokowane gdzie indziej,
// także na asteroidach) zostałyby w nim same

/obj/structure/overmap/begin_jump(datum/star_system/target_system, force = FALSE, misjump = FALSE)
	. = ..()
	warn_small_craft_before_jump(target_system)

/obj/structure/overmap/proc/warn_small_craft_before_jump(datum/star_system/target_system)
	if(istype(src, /obj/structure/overmap/small_craft) || ai_controlled || !current_system)
		return
	var/list/warned = list()
	for(var/obj/structure/overmap/OM in current_system.system_contents)
		if(OM == src)
			continue
		var/obj/structure/overmap/small_craft/flying = OM
		if(istype(flying) && flying.faction == faction)
			flying.warn_crew_before_jump(src, target_system, warned)
		for(var/obj/structure/overmap/small_craft/craft in OM.overmaps_in_ship)
			if(craft.faction != faction)
				continue
			// Górnicy na asteroidzie przy zadokowanym promie też muszą zdążyć
			craft.warn_crew_before_jump(src, target_system, warned, isasteroid(OM) ? OM.mobs_in_ship : null)

/// Mówi załodze (i extra_mobs), że okręt skacze i jak potem do niego wrócić
/obj/structure/overmap/small_craft/proc/warn_crew_before_jump(obj/structure/overmap/jumping, datum/star_system/target_system, list/warned, list/extra_mobs)
	var/list/crew = mobs_in_ship.Copy()
	if(extra_mobs)
		crew |= extra_mobs
	var/message = "<span class='userdanger'>[jumping] rozpoczyna skok FTL do [target_system]!</span> "
	if(loadout?.get_slot(HARDPOINT_SLOT_FTL))
		message += "<span class='warning'>Jeśli [src] zostanie w tym układzie, wrócicie napędem FTL jednostki: w panelu jednostki „Rozkręć napęd”, a gdy pasek się zapełni, „Powrót”.</span>"
	else
		message += "<span class='warning'>[src] nie ma napędu FTL: zadokujcie natychmiast, inaczej zostaniecie w tym układzie.</span>"
	for(var/mob/M as anything in crew)
		if(warned[M])
			continue
		warned[M] = TRUE
		SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
		to_chat(M, message)

/// Wylądowany prom z wnętrzem: ludzie w środku należą do gospodarza, a nie do promu
/obj/structure/overmap/small_craft/transport/warn_crew_before_jump(obj/structure/overmap/jumping, datum/star_system/target_system, list/warned, list/extra_mobs)
	if(shuttle_port && shuttle_docked_at)
		var/list/inside = extra_mobs ? extra_mobs.Copy() : list()
		for(var/area/A as anything in shuttle_port.shuttle_areas)
			for(var/mob/living/M in A)
				inside |= M
		extra_mobs = inside
	return ..()
