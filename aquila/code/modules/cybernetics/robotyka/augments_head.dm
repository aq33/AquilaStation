// AQUILA - augmenty głowy: mózg, oczy, usta, kark. Wdrożenie robotyki, część IMPLANTY.
// Źródła: Paradise (wire_interface), /tg/station (brain/cybernetic/ai, eyes/robotic/tacvisor), Shiptest (joywire),
// Aurora (internal_diagnostics, emotional_manipulator, gustatorial, service_jack), Nova Sector (hackerman_deck),
// Skyrat (anti_sleep), Goonstation (eye/cyber/monitor, eye/cyber/laser), Baystation12 (adaptive_binoculars),
// MonkeStation (eyes/robotic/meson), SS220 (eyes/map).

#define AQ_ROBOTYKA_ICON 'aquila/icons/obj/cybernetics/robotyka_implanty.dmi'

// ===========================================================================
// MÓZG

// Interfejs kabli (Paradise /obj/item/organ/internal/cyberimp/brain/wire_interface)
/obj/item/organ/cyberimp/brain/aq_wire_interface
	name = "implant interfejsu kabli"
	desc = "Implant mózgu, który wyczuwa prądy w przewodach: przy hakowaniu maszyny widać funkcję każdego kabla."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "brain_implant_connector"
	implant_overlay = null
	implant_color = "#FFF782"
	slot = ORGAN_SLOT_BRAIN_WIRE_INTERFACE
	aq_cyberpsychosis_cost = 1
	/// Do kiedy EMP zaślepia interfejs
	var/blind_until = 0

/obj/item/organ/cyberimp/brain/aq_wire_interface/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M)
		ADD_TRAIT(M, TRAIT_AQ_WIRE_INTERFACE, REF(src))

/obj/item/organ/cyberimp/brain/aq_wire_interface/Remove(mob/living/carbon/M, special = FALSE)
	REMOVE_TRAIT(M, TRAIT_AQ_WIRE_INTERFACE, REF(src))
	return ..()

/obj/item/organ/cyberimp/brain/aq_wire_interface/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	REMOVE_TRAIT(owner, TRAIT_AQ_WIRE_INTERFACE, REF(src))
	blind_until = max(blind_until, world.time + 2 MINUTES / severity)
	addtimer(CALLBACK(src, PROC_REF(restore_interface)), 2 MINUTES / severity)

/obj/item/organ/cyberimp/brain/aq_wire_interface/proc/restore_interface()
	if(owner && world.time >= blind_until)
		ADD_TRAIT(owner, TRAIT_AQ_WIRE_INTERFACE, REF(src))

// ---------------------------------------------------------------------------
// Mózg z łączem SI (/tg/station /obj/item/organ/brain/cybernetic/ai): SI wchodzi w w pełni zrobotyzowane ciało

/obj/item/organ/brain/aq_ai_uplink
	name = "mózg z łączem SI"
	desc = "Cybernetyczny mózg bez własnej świadomości. W ciele, w którym wszystkie narządy są robotyczne, SI może przez niego przejąć sterowanie."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "brain-c"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC | ORGAN_VITAL
	decoy_override = TRUE // nie tworzy brainmoba: świadomość należy do SI
	aq_cyberpsychosis_cost = 3
	/// SI, która teraz steruje ciałem
	var/mob/living/silicon/ai/controlling_ai
	/// Przycisk powrotu do rdzenia
	var/datum/action/innate/aq_ai_uplink_return/return_action

/obj/item/organ/brain/aq_ai_uplink/Destroy()
	return_to_core()
	QDEL_NULL(return_action)
	return ..()

/obj/item/organ/brain/aq_ai_uplink/Insert(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	. = ..()
	if(owner != C)
		return
	RegisterSignal(C, COMSIG_CLICK, PROC_REF(on_body_click), override = TRUE)

/obj/item/organ/brain/aq_ai_uplink/Remove(mob/living/carbon/C, special = 0, no_id_transfer = FALSE)
	return_to_core()
	UnregisterSignal(C, COMSIG_CLICK)
	return ..()

/obj/item/organ/brain/aq_ai_uplink/examine(mob/user)
	. = ..()
	if(isAI(user) || isobserver(user))
		. += span_notice("SI przejmuje ciało z tym mózgiem kliknięciem na nie. Wszystkie narządy (poza językiem) muszą być robotyczne, a ciało widoczne dla kamer.")

/obj/item/organ/brain/aq_ai_uplink/proc/on_body_click(atom/source, location, control, params, mob/user)
	SIGNAL_HANDLER
	if(isAI(user))
		INVOKE_ASYNC(src, PROC_REF(try_ai_enter), user)

/// Dlaczego SI nie może teraz wejść w ciało (null = może)
/obj/item/organ/brain/aq_ai_uplink/proc/entry_problem(mob/living/silicon/ai/ai)
	if(!owner)
		return "Mózg nie jest w ciele."
	if(controlling_ai)
		return "Ciałem steruje już SI."
	if(ai.stat || ai.control_disabled || !ai.mind)
		return "Nie możesz teraz nawiązać połączenia."
	if(ai.deployed_shell || !isturf(ai.loc))
		return "Najpierw wróć do rdzenia."
	if(owner.stat == DEAD)
		return "To ciało jest martwe."
	if(owner.key || owner.mind)
		return "To ciało ma już świadomość."
	for(var/obj/item/organ/organ as anything in owner.internal_organs)
		if(organ == src || organ.slot == ORGAN_SLOT_TONGUE)
			continue
		if(organ.status != ORGAN_ROBOTIC)
			return "Narząd [organ.name] nie jest robotyczny."
	if(!GLOB.cameranet.checkCameraVis(owner))
		return "Ciało nie jest widoczne dla kamer."
	return null

/obj/item/organ/brain/aq_ai_uplink/proc/try_ai_enter(mob/living/silicon/ai/ai)
	var/problem = entry_problem(ai)
	if(problem)
		to_chat(ai, span_warning(problem))
		return
	if(alert(ai, "Przejąć sterowanie ciałem [owner]?", "Mózg z łączem SI", "Tak", "Nie") != "Tak")
		return
	problem = entry_problem(ai)
	if(problem)
		to_chat(ai, span_warning(problem))
		return
	controlling_ai = ai
	RegisterSignal(ai, COMSIG_PARENT_QDELETING, PROC_REF(on_core_deleted))
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(on_body_death))
	ADD_TRAIT(owner, TRAIT_AQ_BINARY_SPEAKER, REF(src))
	ai.mind.transfer_to(owner)
	if(!return_action)
		return_action = new(src)
	return_action.Grant(owner)
	to_chat(owner, span_notice("Przejmujesz sterowanie ciałem. Twoje prawa nadal obowiązują:"))
	ai.laws?.show_laws(owner)
	log_game("[key_name(owner)] (SI) przejęła ciało przez mózg z łączem SI w [AREACOORD(owner)].")

/// Wraca do rdzenia SI (albo zostawia ciało, gdy rdzenia już nie ma)
/obj/item/organ/brain/aq_ai_uplink/proc/return_to_core()
	if(!controlling_ai)
		return
	var/mob/living/silicon/ai/ai = controlling_ai
	controlling_ai = null
	UnregisterSignal(ai, COMSIG_PARENT_QDELETING)
	if(owner)
		UnregisterSignal(owner, COMSIG_MOB_DEATH)
		REMOVE_TRAIT(owner, TRAIT_AQ_BINARY_SPEAKER, REF(src))
		return_action?.Remove(owner)
		if(owner.mind)
			if(QDELETED(ai))
				owner.ghostize(FALSE)
			else
				owner.mind.transfer_to(ai)
				to_chat(ai, span_notice("Wracasz do rdzenia."))
				ai.laws?.show_laws(ai)

/obj/item/organ/brain/aq_ai_uplink/proc/on_core_deleted(datum/source)
	SIGNAL_HANDLER
	return_to_core()

/obj/item/organ/brain/aq_ai_uplink/proc/on_body_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(return_to_core))

/datum/action/innate/aq_ai_uplink_return
	name = "Rozłącz z powłoką"
	desc = "Wraca do rdzenia SI."
	icon_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_core"

/datum/action/innate/aq_ai_uplink_return/Trigger()
	var/obj/item/organ/brain/aq_ai_uplink/brain = target
	if(istype(brain))
		brain.return_to_core()

// ---------------------------------------------------------------------------
// Ożywiacz przyjemności Midi-Sed (Shiptest /obj/item/organ/cyberimp/brain/joywire)

/obj/item/organ/cyberimp/brain/aq_joywire
	name = "ożywiacz przyjemności Midi-Sed"
	desc = "Uzależniający implant pobudzający ośrodek przyjemności. Mocno poprawia nastrój, ale na zawsze psuje smak, nawet po wyjęciu."
	implant_color = "#FFABE0"
	slot = ORGAN_SLOT_BRAIN_JOYWIRE
	aq_cyberpsychosis_cost = 2

/obj/item/organ/cyberimp/brain/aq_joywire/on_life()
	. = ..()
	if(!owner || !aq_augment_usable(TRUE))
		return
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "aq_joywire", /datum/mood_event/aq_joywire)
	if(!HAS_TRAIT_FROM(owner, TRAIT_AGEUSIA, "aq_joywire_scar"))
		ADD_TRAIT(owner, TRAIT_AGEUSIA, "aq_joywire_scar") // blizna zostaje po wyjęciu
		to_chat(owner, span_notice("Smak jedzenia blednie. Kogo to obchodzi? Jest cudownie."))

/obj/item/organ/cyberimp/brain/aq_joywire/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "aq_joywire")
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "aq_joywire", /datum/mood_event/aq_joywire_withdrawal)
	return ..()

/obj/item/organ/cyberimp/brain/aq_joywire/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "aq_joywire")
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "aq_joywire_emp", /datum/mood_event/aq_joywire_emp)

/datum/mood_event/aq_joywire
	description = "<span class='nicegreen'>Wszystko jest cudowne. Wszystko jest cudowne. Wszystko jest cudowne.</span>\n"
	mood_change = 8
	timeout = 10 SECONDS

/datum/mood_event/aq_joywire_withdrawal
	description = "<span class='warning'>Gdzie się podziała radość? Wszystko jest szare i płaskie...</span>\n"
	mood_change = -6
	timeout = 10 MINUTES

/datum/mood_event/aq_joywire_emp
	description = "<span class='boldwarning'>Mój ożywiacz przyjemności się spalił. Wszystko jest okropne!</span>\n"
	mood_change = -30
	timeout = 5 MINUTES

// ---------------------------------------------------------------------------
// Procesor diagnostyczny (Aurora /obj/item/organ/internal/machine/internal_diagnostics)

/obj/item/organ/cyberimp/brain/aq_diagnostics
	name = "procesor diagnostyczny"
	desc = "Czujniki stanu ciała syntetyka: na żądanie pokazują pełny raport o uszkodzeniach. Działa też w ciele organicznym."
	implant_color = "#7FD1FF"
	slot = ORGAN_SLOT_BRAIN_DIAGNOSTICS
	actions_types = list(/datum/action/item_action/organ_action/use)
	aq_cyberpsychosis_cost = 0

/obj/item/organ/cyberimp/brain/aq_diagnostics/ui_action_click()
	if(!aq_augment_usable())
		return
	to_chat(owner, span_notice("Procesor diagnostyczny przesyła raport o stanie ciała:"))
	healthscan(owner, owner, 1, TRUE)

// ---------------------------------------------------------------------------
// System hakowania bezprzewodowego Binyat (Nova Sector /obj/item/organ/cyberimp/hackerman_deck)

/obj/item/organ/cyberimp/brain/aq_hacking_deck
	name = "system hakowania bezprzewodowego Binyat"
	desc = "Czip neuronowy: wskazana pobliska maszyna dostaje ładunek, który sam próbuje ją zhakować, szarpiąc przypadkowymi kablami. Nie działa na cyborgi."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "brain_implant_rebooter"
	implant_overlay = null
	slot = ORGAN_SLOT_BRAIN_HACKING
	syndicate_implant = TRUE
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 2
	/// Czy czeka na wskazanie celu
	var/armed = FALSE
	/// Zasięg
	var/hack_range = 7
	/// Ile przypadkowych kabli szarpie
	var/pulses = 3
	COOLDOWN_DECLARE(hack_cooldown)

/obj/item/organ/cyberimp/brain/aq_hacking_deck/ui_action_click()
	if(!aq_augment_usable())
		return
	set_armed(!armed)

/obj/item/organ/cyberimp/brain/aq_hacking_deck/proc/set_armed(new_state)
	if(!owner)
		return
	armed = new_state
	if(armed)
		RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(on_click), override = TRUE)
		to_chat(owner, span_notice("Binyat gotowy. Kliknij maszynę w zasięgu wzroku."))
	else
		UnregisterSignal(owner, COMSIG_MOB_CLICKON)

/obj/item/organ/cyberimp/brain/aq_hacking_deck/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		UnregisterSignal(M, COMSIG_MOB_CLICKON)
	armed = FALSE
	return ..()

/obj/item/organ/cyberimp/brain/aq_hacking_deck/proc/on_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || !ismachinery(target))
		return
	. = COMSIG_MOB_CANCEL_CLICKON
	set_armed(FALSE)
	if(!COOLDOWN_FINISHED(src, hack_cooldown))
		to_chat(source, span_warning("Binyat jeszcze się chłodzi."))
		return
	if(get_dist(source, target) > hack_range || !(target in view(hack_range, source)))
		to_chat(source, span_warning("Maszyna jest za daleko."))
		return
	var/obj/machinery/machine = target
	if(!machine.wires || !length(machine.wires.colors))
		to_chat(source, span_warning("Ładunek nie znajduje w [machine] żadnych kabli."))
		return
	COOLDOWN_START(src, hack_cooldown, 20 SECONDS)
	to_chat(source, span_notice("Wysyłasz ładunek do [machine]..."))
	addtimer(CALLBACK(src, PROC_REF(hack), machine), 3 SECONDS)

/// Szarpie przypadkowe kable maszyny
/obj/item/organ/cyberimp/brain/aq_hacking_deck/proc/hack(obj/machinery/machine)
	if(QDELETED(machine) || !machine.wires || !owner)
		return
	for(var/i in 1 to pulses)
		machine.wires.pulse_color(pick(machine.wires.colors), owner)
	do_sparks(2, FALSE, machine)
	to_chat(owner, span_notice("Ładunek przeszedł przez kable [machine]."))
	log_game("[key_name(owner)] zhakował [machine] systemem Binyat w [AREACOORD(machine)].")

// ---------------------------------------------------------------------------
// Rozrusznik OUN (Skyrat /obj/item/organ/internal/cyberimp/brain/anti_sleep)

/obj/item/organ/cyberimp/brain/aq_jumpstarter
	name = "rozrusznik OUN"
	desc = "Wstrząsem budzi nosiciela, gdy ten straci przytomność poza zwykłym snem. Potem musi się naładować."
	implant_color = "#FFE14D"
	slot = ORGAN_SLOT_BRAIN_JUMPSTARTER
	aq_cyberpsychosis_cost = 2
	/// Odnowienie
	var/cooldown_time = 1 MINUTES
	COOLDOWN_DECLARE(jump_cooldown)

/obj/item/organ/cyberimp/brain/aq_jumpstarter/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || !COOLDOWN_FINISHED(src, jump_cooldown))
		return
	if(!owner.IsUnconscious() || owner.IsSleeping() || !aq_augment_usable(TRUE))
		return
	COOLDOWN_START(src, jump_cooldown, cooldown_time)
	owner.SetUnconscious(0)
	owner.Jitter(5)
	to_chat(owner, span_userdanger("Rozrusznik OUN wstrząsa twoim mózgiem i zrywa cię na nogi!"))
	playsound(owner, 'sound/machines/defib_zap.ogg', 30, TRUE)

// ---------------------------------------------------------------------------
// Manipulator emocji (Aurora /obj/item/organ/internal/augment/emotional_manipulator)

/obj/item/organ/cyberimp/brain/aq_emotional_manipulator
	name = "manipulator emocji"
	desc = "Steruje chemią mózgu i na żądanie wywołuje uczucie szczęścia albo spokoju."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "emotional_manipulator"
	implant_overlay = null
	slot = ORGAN_SLOT_BRAIN_EMOTION
	actions_types = list(/datum/action/item_action/organ_action/use)
	aq_cyberpsychosis_cost = 2
	/// Tryb: null, "happy" albo "calm"
	var/mode
	/// Kiedy następny komunikat
	var/next_message = 0

/obj/item/organ/cyberimp/brain/aq_emotional_manipulator/ui_action_click()
	if(!aq_augment_usable())
		return
	var/choice = tgui_alert(owner, "Jaki stan wywołać?", "Manipulator emocji", list("Szczęście", "Spokój", "Wyłącz"))
	if(!owner || QDELETED(src))
		return
	switch(choice)
		if("Szczęście")
			mode = "happy"
		if("Spokój")
			mode = "calm"
		if("Wyłącz")
			mode = null
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "aq_emotion")
	if(choice)
		to_chat(owner, span_notice((mode ? "Manipulator emocji przestawia chemię twojego mózgu." : "Manipulator emocji się wyłącza.")))

/obj/item/organ/cyberimp/brain/aq_emotional_manipulator/on_life()
	. = ..()
	if(!owner)
		return
	if(organ_flags & ORGAN_FAILING)
		owner.adjust_hallucinations_up_to(4 SECONDS, 20 SECONDS)
		return
	if(!mode || !aq_augment_usable(TRUE))
		return
	if(mode == "happy")
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "aq_emotion", /datum/mood_event/aq_emotion_happy)
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "aq_emotion", /datum/mood_event/aq_emotion_calm)
		owner.jitteriness = max(owner.jitteriness - 5, 0)
	if(world.time >= next_message)
		next_message = world.time + 5 MINUTES
		to_chat(owner, span_notice((mode == "happy" ? "Ogarnia cię ciepła, bezprzyczynowa radość." : "Myśli płyną spokojnie i powoli.")))

/obj/item/organ/cyberimp/brain/aq_emotional_manipulator/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "aq_emotion")
	return ..()

/datum/mood_event/aq_emotion_happy
	description = "<span class='nicegreen'>Czuję się szczęśliwy. Chyba?</span>\n"
	mood_change = 4
	timeout = 10 SECONDS

/datum/mood_event/aq_emotion_calm
	description = "<span class='nicegreen'>Jestem zupełnie spokojny.</span>\n"
	mood_change = 2
	timeout = 10 SECONDS

// ===========================================================================
// OCZY

// Wizjer taktyczny IFF (/tg/station /obj/item/organ/eyes/robotic/tacvisor).
// U tg zamienia ludzi w obrysy IFF; u nas HUD ochrony z oceną zagrożenia i brak rozpoznawania twarzy.
/obj/item/organ/eyes/robotic/aq_tacvisor
	name = "taktyczny wizjer IFF"
	desc = "Wizjer wpięty w mózg: pokazuje dane ochrony i zagrożenie każdej osoby, ale nosiciel przestaje rozpoznawać twarze i imiona."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "eyes_tacvisor"
	eye_color = "3F3"
	flash_protect = 2
	aq_cyberpsychosis_cost = 2

/obj/item/organ/eyes/robotic/aq_tacvisor/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	if(owner != M)
		return
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.add_hud_to(M)
	ADD_TRAIT(M, TRAIT_SECURITY_HUD, REF(src))
	ADD_TRAIT(M, TRAIT_PROSOPAGNOSIA, REF(src))

/obj/item/organ/eyes/robotic/aq_tacvisor/Remove(mob/living/carbon/M, special = FALSE)
	var/datum/atom_hud/sec_hud = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	sec_hud.remove_hud_from(M)
	REMOVE_TRAIT(M, TRAIT_SECURITY_HUD, REF(src))
	REMOVE_TRAIT(M, TRAIT_PROSOPAGNOSIA, REF(src))
	return ..()

// ---------------------------------------------------------------------------
// Cyberoko z monitorem (Goonstation /obj/item/organ/eye/cyber/monitor): podgląd sieci kamer

/obj/item/organ/eyes/robotic/aq_monitor
	name = "cyberoko z monitorem"
	desc = "Mały ekran zamiast oka: pozwala oglądać sieć kamer okrętu z wbudowanego monitora."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "eye-monitor"
	eye_color = "39F"
	actions_types = list(/datum/action/item_action/organ_action/use)
	aq_cyberpsychosis_cost = 1
	/// Wbudowana konsola kamer
	var/obj/machinery/computer/security/aq_eye_monitor/monitor

/obj/item/organ/eyes/robotic/aq_monitor/Destroy()
	QDEL_NULL(monitor)
	return ..()

/obj/item/organ/eyes/robotic/aq_monitor/ui_action_click()
	if(!aq_augment_usable())
		return
	if(!monitor)
		monitor = new(src)
		monitor.eye = src
	if(owner.client) // konsola rejestruje obraz kamer w kliencie
		monitor.ui_interact(owner)

/obj/item/organ/eyes/robotic/aq_monitor/Remove(mob/living/carbon/M, special = FALSE)
	if(monitor && M)
		SStgui.close_uis(monitor)
	return ..()

/obj/machinery/computer/security/aq_eye_monitor
	name = "monitor w oku"
	use_power = NO_POWER_USE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_ALLOW_SILICON
	network = list("ss13")
	/// Oko, w którym siedzi monitor
	var/obj/item/organ/eyes/robotic/aq_monitor/eye

/obj/machinery/computer/security/aq_eye_monitor/Destroy()
	eye = null
	return ..()

/obj/machinery/computer/security/aq_eye_monitor/ui_state(mob/user)
	if(eye?.owner == user && eye.aq_augment_usable(TRUE))
		return GLOB.conscious_state
	return GLOB.never_state

// ---------------------------------------------------------------------------
// Adaptacyjna lornetka (Baystation12 /obj/item/organ/internal/augment/active/item/adaptive_binoculars)

/obj/item/organ/cyberimp/eyes/aq_binoculars
	name = "adaptacyjna lornetka"
	desc = "Soczewki wysuwane na oczy przybliżają obraz jak lornetka, w kierunku, w którym patrzysz."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "adaptive_binoculars"
	implant_overlay = null
	slot = ORGAN_SLOT_EYE_ZOOM
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 1
	/// Czy przybliża
	var/zoomed = FALSE
	/// Przesunięcie widoku w kratkach
	var/zoom_offset = 7

/obj/item/organ/cyberimp/eyes/aq_binoculars/ui_action_click()
	if(!zoomed && !aq_augment_usable())
		return
	set_zoom(!zoomed)

/obj/item/organ/cyberimp/eyes/aq_binoculars/proc/set_zoom(new_state)
	if(!owner?.client)
		zoomed = FALSE
		return
	zoomed = new_state
	if(zoomed)
		RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change), override = TRUE)
		owner.client.view_size.zoomOut(0, zoom_offset, owner.dir)
		to_chat(owner, span_notice("Soczewki wysuwają się i przybliżają obraz."))
	else
		UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
		owner.client.view_size.zoomIn()

/obj/item/organ/cyberimp/eyes/aq_binoculars/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	owner?.client?.view_size.zoomOut(0, zoom_offset, new_dir)

/obj/item/organ/cyberimp/eyes/aq_binoculars/Remove(mob/living/carbon/M, special = FALSE)
	if(zoomed)
		set_zoom(FALSE)
	return ..()

/obj/item/organ/cyberimp/eyes/aq_binoculars/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF || !zoomed)
		return
	set_zoom(FALSE)
	owner.blind_eyes(10)
	owner.blur_eyes(20)
	to_chat(owner, span_warning("Soczewki gwałtownie się zamykają!"))

// ---------------------------------------------------------------------------
// Oczy mezonowe (MonkeStation /obj/item/organ/internal/eyes/robotic/meson)

/obj/item/organ/eyes/robotic/aq_meson
	name = "oczy mezonowe"
	desc = "Cybernetyczne oczy, które pokazują układ ścian i konstrukcji jak gogle mezonowe."
	eye_color = "0C4"
	sight_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	aq_cyberpsychosis_cost = 1

// ---------------------------------------------------------------------------
// Mapa okrętu w oku (SS220 /obj/item/organ/internal/cyberimp/eyes/map): holomapa na żądanie

/obj/item/organ/cyberimp/eyes/aq_map
	name = "implant mapy okrętu"
	desc = "Wyświetla w polu widzenia hologram okrętu z twoją pozycją."
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	implant_color = "#3AD17F"
	slot = ORGAN_SLOT_EYE_MAP
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY
	aq_cyberpsychosis_cost = 1

/obj/item/organ/cyberimp/eyes/aq_map/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	var/datum/component/holomap/holo = AddComponent(/datum/component/holomap)
	holo.holobutton.name = "Mapa okrętu"
	holo.holobutton.Grant(M)

/obj/item/organ/cyberimp/eyes/aq_map/Remove(mob/living/carbon/M, special = FALSE)
	var/datum/component/holomap/holo = GetComponent(/datum/component/holomap)
	if(holo)
		if(holo.holomap_visible && M)
			holo.deactivate_holomap(M)
		qdel(holo)
	return ..()

// ---------------------------------------------------------------------------
// Laserowe cyberoko (Goonstation /obj/item/organ/eye/cyber/laser): strzał z oczu

/obj/item/organ/eyes/robotic/aq_laser
	name = "laserowe cyberoczy"
	desc = "Cyberoczy strzelające laserem. Zasłonięte oczy nie strzelają."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "eye-laser"
	eye_color = "F00"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 3
	/// Czy czeka na cel
	var/armed = FALSE
	/// Odnowienie strzału
	var/cooldown_time = 6 SECONDS
	COOLDOWN_DECLARE(shot_cooldown)

/obj/item/organ/eyes/robotic/aq_laser/ui_action_click()
	if(!aq_augment_usable())
		return
	set_armed(!armed)

/obj/item/organ/eyes/robotic/aq_laser/proc/set_armed(new_state)
	if(!owner)
		return
	armed = new_state
	if(armed)
		RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(on_click), override = TRUE)
		to_chat(owner, span_notice("Cyberoczy celują. Kliknij cel."))
	else
		UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		to_chat(owner, span_notice("Cyberoczy przestają celować."))

/obj/item/organ/eyes/robotic/aq_laser/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		UnregisterSignal(M, COMSIG_MOB_CLICKON)
	armed = FALSE
	return ..()

/obj/item/organ/eyes/robotic/aq_laser/proc/on_click(mob/living/carbon/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || target == source)
		return
	if(source.stat || source.incapacitated())
		return
	. = COMSIG_MOB_CANCEL_CLICKON
	if(!COOLDOWN_FINISHED(src, shot_cooldown))
		to_chat(source, span_warning("Cyberoczy jeszcze się chłodzą."))
		return
	if(source.is_eyes_covered())
		to_chat(source, span_warning("Coś zasłania ci oczy."))
		return
	COOLDOWN_START(src, shot_cooldown, cooldown_time)
	var/obj/item/projectile/beam/laser/aq_eyebeam/beam = new(get_turf(source))
	beam.firer = source
	beam.fired_from = src
	beam.preparePixelProjectile(target, source, list2params(modifiers))
	playsound(source, 'sound/weapons/laser.ogg', 50, TRUE)
	source.visible_message(span_danger("Z oczu [source] wystrzeliwuje laser!"))
	log_combat(source, target, "strzelił laserowymi cyberoczami w")
	beam.fire()

/obj/item/projectile/beam/laser/aq_eyebeam
	name = "promień z oczu"
	icon = AQ_ROBOTYKA_ICON
	icon_state = "eyebeam"
	damage = 20

// ===========================================================================
// USTA I KARK

// Ośrodek smaku (Aurora /obj/item/organ/internal/augment/gustatorial): skład skosztowanych substancji
/obj/item/organ/cyberimp/aq_gustatorial
	name = "ośrodek smaku"
	desc = "Mały analizator chemii w języku. Po skosztowaniu podaje skład substancji, a na żądanie bada to, co trzymasz w ręce."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "augment"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_AQ_GUSTATORIAL
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/organ_action/use)
	aq_cyberpsychosis_cost = 1

/obj/item/organ/cyberimp/aq_gustatorial/ui_action_click()
	if(!aq_augment_usable())
		return
	var/obj/item/held = owner.get_active_held_item()
	if(!held?.reagents)
		to_chat(owner, span_warning("Musisz trzymać w ręce coś z substancjami."))
		return
	to_chat(owner, span_notice("Ośrodek smaku bada [held]:"))
	report_reagents(held.reagents)

/// Wypisuje skład substancji nosicielowi
/obj/item/organ/cyberimp/aq_gustatorial/proc/report_reagents(datum/reagents/holder)
	if(!owner || !holder)
		return
	if(!length(holder.reagent_list))
		to_chat(owner, span_notice("Ośrodek smaku: brak substancji."))
		return
	var/list/lines = list()
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		lines += "[reagent.name] ([round(reagent.volume, 0.1)] j.)"
	to_chat(owner, span_notice("Ośrodek smaku: [jointext(lines, ", ")]."))

// Port serwisowy EMSI (Aurora /obj/item/organ/internal/augment/service_jack): diagnoza augmentów multitoolem
/obj/item/organ/cyberimp/aq_service_jack
	name = "port serwisowy EMSI"
	desc = "Port serwisowy na karku. Technik podłącza do niego multitool, żeby zdiagnozować augmenty i protezy nosiciela."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "augment"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_AQ_SERVICE_JACK
	w_class = WEIGHT_CLASS_TINY
	aq_cyberpsychosis_cost = 0

/obj/item/organ/cyberimp/aq_service_jack/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	RegisterSignal(M, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby), override = TRUE)
	RegisterSignal(M, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine), override = TRUE)

/obj/item/organ/cyberimp/aq_service_jack/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		UnregisterSignal(M, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))
	return ..()

/obj/item/organ/cyberimp/aq_service_jack/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Na karku widać port serwisowy EMSI.")

/obj/item/organ/cyberimp/aq_service_jack/proc/on_attackby(datum/source, obj/item/tool, mob/living/user, params)
	SIGNAL_HANDLER
	if(tool.tool_behaviour != TOOL_MULTITOOL || user.combat_mode)
		return
	INVOKE_ASYNC(src, PROC_REF(diagnose), user)
	return COMPONENT_NO_AFTERATTACK

/// Raport z portu: augmenty, protezy i koszt cyberpsychozy
/obj/item/organ/cyberimp/aq_service_jack/proc/diagnose(mob/living/user)
	if(!owner)
		return
	if(organ_flags & ORGAN_FAILING)
		to_chat(user, span_warning("Port serwisowy [owner] nie odpowiada."))
		return
	var/list/lines = list("<b>Diagnoza portu EMSI: [owner]</b>")
	var/total_cost = 0
	for(var/obj/item/organ/organ as anything in owner.internal_organs)
		if(organ.status != ORGAN_ROBOTIC)
			continue
		total_cost += organ.aq_cyberpsychosis_cost
		var/health = organ.maxHealth ? round(100 - (organ.damage / organ.maxHealth) * 100) : 100
		lines += "[capitalize(organ.name)]: sprawność [health]%[organ.organ_flags & ORGAN_FAILING ? ", NIEWYDOLNY" : ""][organ.aq_cyberpsychosis_cost ? ", obciążenie [organ.aq_cyberpsychosis_cost]" : ""]"
	for(var/obj/item/bodypart/part as anything in owner.bodyparts)
		if(IS_ORGANIC_LIMB(part))
			continue
		lines += "Proteza [part.name]: obrażenia [round(part.brute_dam)] / poparzenia [round(part.burn_dam)]"
	lines += "Łączne obciążenie augmentami: [total_cost]"
	to_chat(user, span_notice(jointext(lines, "<br>")))
	playsound(owner, 'sound/machines/ping.ogg', 30, TRUE)

#undef AQ_ROBOTYKA_ICON
