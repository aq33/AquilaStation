// AQUILA - zgodność ścieżek Popiołu i Ciała heretyka z tg (port heretyka).
// Rzeczy z tg, których u nas nie było, w wersji na naszym API. Ścieżki typów jak w tg.

// Osiągnięcia za wniebowstąpienie

/datum/award/achievement/misc/ash_ascension
	name = "Oczy Nocnego Strażnika"
	desc = "Wzniosłeś się ponad płomienie i stałeś się jednym z popiołami. Odrodziłeś się jako jedno z Nocnym Strażnikiem."
	database_id = "Ash"

/datum/award/achievement/misc/flesh_ascension
	name = "Wir ramion"
	desc = "Stałeś się czymś więcej, czymś większym. Cząstka cesarza mieszka w tobie, a ty w nim."
	database_id = "Flesh"

// tg: TRAIT_BOMBIMMUNE chroni przed wybuchami (wniebowstąpienie Popiołu)

/mob/living/carbon/human/ex_act(severity, target, origin)
	if(HAS_TRAIT(src, TRAIT_BOMBIMMUNE))
		return FALSE
	return ..()

// tg: sygnał zmiany liczby ładunków ognia (przycisk Volcano Blast pokazuje wzmocnienie)

/mob/living/adjust_fire_stacks(add_fire_stacks)
	. = ..()
	SEND_SIGNAL(src, COMSIG_FIRE_STACKS_UPDATED, add_fire_stacks)

/// tg: odcinek wiązki, który reaguje na wchodzące w niego rzeczy.
/// U nas odcinki dostają właściciela i pozycję już po Initialize(), więc podpinamy się do pola z opóźnieniem.
/obj/effect/ebeam/reacting
	/// Pole, na którego wejścia nasłuchujemy
	var/turf/watched_turf

/obj/effect/ebeam/reacting/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(watch_turf)), 1)

/obj/effect/ebeam/reacting/Destroy()
	if(watched_turf)
		UnregisterSignal(watched_turf, COMSIG_ATOM_ENTERED)
		watched_turf = null
	return ..()

/obj/effect/ebeam/reacting/proc/watch_turf()
	if(QDELETED(src) || !isturf(loc))
		return
	watched_turf = loc
	RegisterSignal(watched_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

/obj/effect/ebeam/reacting/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(isnull(owner) || entered == src)
		return
	beam_entered(entered)

/// Coś weszło na linię wiązki
/obj/effect/ebeam/reacting/proc/beam_entered(atom/movable/entered)
	return

// tg: /datum/component/mind_linker - sieć telepatyczna kilku umysłów (Mansus Link Raw Prophet)

/datum/component/mind_linker
	/// Nazwa sieci
	var/network_name = "łącze umysłów"
	/// Kolor wiadomości
	var/chat_color
	/// Sygnały rodzica, po których sieć się rozpada
	var/list/signals_which_destroy_us
	/// Wołane po odłączeniu kogoś
	var/datum/callback/post_unlink_callback
	/// Ikona akcji mowy
	var/speech_action_icon = 'icons/mob/actions/actions_slime.dmi'
	var/speech_action_icon_state = "link_speech"
	var/speech_action_background_icon_state = "bg_alien"
	var/speech_action_overlay_state = "bg_alien_border"
	/// Czy pokazywać dymek przy wiadomości
	var/show_balloon_alert = FALSE
	/// Akcja mowy właściciela sieci
	var/datum/action/innate/mind_linker_speech/master_speech
	/// [mob/living] => akcja mowy
	var/list/mob/living/linked_mobs = list()

/datum/component/mind_linker/Initialize(
	network_name = "łącze umysłów",
	chat_color = "#008CA2",
	speech_action_icon = 'icons/mob/actions/actions_slime.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	speech_action_overlay_state = "bg_alien_border",
	signals_which_destroy_us,
	datum/callback/post_unlink_callback,
	show_balloon_alert,
)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	src.network_name = network_name
	src.chat_color = chat_color
	src.speech_action_icon = speech_action_icon
	src.speech_action_icon_state = speech_action_icon_state
	src.speech_action_background_icon_state = speech_action_background_icon_state
	if(islist(signals_which_destroy_us))
		src.signals_which_destroy_us = signals_which_destroy_us
	if(post_unlink_callback)
		src.post_unlink_callback = post_unlink_callback
	if(!isnull(show_balloon_alert))
		src.show_balloon_alert = show_balloon_alert

	master_speech = new(src)
	master_speech.Grant(owner)

/datum/component/mind_linker/Destroy(force, silent)
	for(var/mob/living/remaining_mob as anything in linked_mobs)
		unlink_mob(remaining_mob)
	linked_mobs.Cut()
	QDEL_NULL(master_speech)
	post_unlink_callback = null
	return ..()

/datum/component/mind_linker/RegisterWithParent()
	if(signals_which_destroy_us)
		RegisterSignals(parent, signals_which_destroy_us, PROC_REF(destroy_link))

/datum/component/mind_linker/UnregisterFromParent()
	if(signals_which_destroy_us)
		UnregisterSignal(parent, signals_which_destroy_us)

/// Podłącza moba do sieci. TRUE, jeśli się udało.
/datum/component/mind_linker/proc/link_mob(mob/living/to_link)
	if(QDELETED(to_link) || to_link.stat == DEAD)
		return FALSE
	if(linked_mobs[to_link])
		return FALSE
	var/mob/living/owner = parent
	if(to_link == owner)
		return FALSE

	var/datum/action/innate/mind_linker_speech/new_link = new(src)
	new_link.Grant(to_link)
	linked_mobs[to_link] = new_link
	RegisterSignals(to_link, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(sig_unlink_mob))
	return TRUE

/datum/component/mind_linker/proc/sig_unlink_mob(mob/living/to_unlink)
	SIGNAL_HANDLER
	unlink_mob(to_unlink)

/// Odłącza moba od sieci
/datum/component/mind_linker/proc/unlink_mob(mob/living/to_unlink)
	if(!linked_mobs[to_unlink])
		return FALSE
	post_unlink_callback?.Invoke(to_unlink)
	UnregisterSignal(to_unlink, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	var/datum/action/innate/mind_linker_speech/old_link = linked_mobs[to_unlink]
	linked_mobs -= to_unlink
	qdel(old_link)
	return TRUE

/datum/component/mind_linker/proc/destroy_link(datum/source)
	SIGNAL_HANDLER
	if(isliving(source))
		to_chat(source, span_boldwarning("Twoje [network_name] się rozpada!"))
	qdel(src)

/// Sieć, do której właściciel sam dołącza ludzi zaklęciem
/datum/component/mind_linker/active_linking
	/// Wiadomość przy podłączeniu
	var/link_message
	/// Wiadomość przy odłączeniu
	var/unlink_message
	/// Akcja właściciela do podłączania
	var/datum/action/linker_action

/datum/component/mind_linker/active_linking/Initialize(
	network_name = "łącze umysłów",
	chat_color = "#008CA2",
	speech_action_icon = 'icons/mob/actions/actions_slime.dmi',
	speech_action_icon_state = "link_speech",
	speech_action_background_icon_state = "bg_alien",
	speech_action_overlay_state = "bg_alien_border",
	signals_which_destroy_us,
	datum/callback/post_unlink_callback,
	show_balloon_alert,
	link_message,
	unlink_message,
	linker_action_path,
)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/mob/living/owner = parent
	src.link_message = link_message || "Jesteś teraz połączony z [network_name] istoty [owner.real_name]."
	src.unlink_message = unlink_message || "Nie jesteś już połączony z [network_name] istoty [owner.real_name]."

	if(ispath(linker_action_path))
		linker_action = new linker_action_path(src)
		linker_action.Grant(owner)
	else
		stack_trace("[type] was created without a valid linker_action_path. No one will be able to link to it.")

	to_chat(owner, span_boldnotice("Tworzysz [network_name], przez które możesz łączyć umysły i porozumiewać się telepatycznie."))

/datum/component/mind_linker/active_linking/Destroy(force, silent)
	QDEL_NULL(linker_action)
	return ..()

/datum/component/mind_linker/active_linking/link_mob(mob/living/to_link)
	if(HAS_TRAIT(to_link, TRAIT_MINDSHIELD)) // chroniony umysł
		return FALSE
	if(to_link.can_block_magic(MAGIC_RESISTANCE_MIND))
		return FALSE

	. = ..()
	if(!.)
		return

	RegisterSignal(to_link, SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD), PROC_REF(sig_unlink_mob))
	var/mob/living/owner = parent
	to_chat(to_link, span_notice(link_message))
	to_chat(owner, span_notice("Łączysz umysł [to_link] ze swoim [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		if(other_link == to_link)
			continue
		to_chat(other_link, span_notice("Czujesz nową obecność w [network_name] istoty [owner.real_name]."))

/datum/component/mind_linker/active_linking/unlink_mob(mob/living/to_unlink)
	. = ..()
	if(!.)
		return

	UnregisterSignal(to_unlink, SIGNAL_ADDTRAIT(TRAIT_MINDSHIELD))
	var/mob/living/owner = parent
	to_chat(to_unlink, span_warning(unlink_message))
	to_chat(owner, span_warning("Czujesz, jak ktoś odłącza się od twojego [network_name]."))
	for(var/mob/living/other_link as anything in linked_mobs)
		to_chat(other_link, span_warning("Czujesz, jak jakaś obecność znika z [network_name] istoty [owner.real_name]."))

/// tg: /datum/action/innate/linked_speech. U nas ta ścieżka należy już do łącza slimeludzi, stąd inna nazwa.
/datum/action/innate/mind_linker_speech
	name = "Mowa przez łącze umysłów"
	desc = "Wyślij telepatyczną wiadomość do wszystkich podłączonych do twojego łącza."
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "link_speech"
	background_icon_state = "bg_alien"

/datum/action/innate/mind_linker_speech/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)
		return
	var/datum/component/mind_linker/linker = Target
	name = "Mowa: [linker.network_name]"
	desc = "Wyślij telepatyczną wiadomość do wszystkich podłączonych do [linker.network_name]."
	icon_icon = linker.speech_action_icon
	button_icon_state = linker.speech_action_icon_state
	background_icon_state = linker.speech_action_background_icon_state
	UpdateButtonIcon()

/datum/action/innate/mind_linker_speech/IsAvailable()
	return ..() && owner.stat != DEAD

/datum/action/innate/mind_linker_speech/Activate()
	var/datum/component/mind_linker/linker = target
	var/mob/living/linker_parent = linker.parent

	var/message = tgui_input_text(owner, "Wpisz wiadomość do przekazania.", "Telepatia: [linker.network_name]", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(src) || QDELETED(owner) || owner.stat == DEAD)
		return

	if(QDELETED(linker))
		to_chat(owner, span_warning("Łącze chyba zostało zerwane."))
		return

	var/formatted_message = "<i><font color=[linker.chat_color]>\[[linker.network_name] istoty [linker_parent.real_name]\] <b>[owner]:</b> [message]</font></i>"
	log_directed_talk(owner, linker_parent, message, LOG_SAY, "mind link ([linker.network_name])")

	var/list/all_who_can_hear = list()
	for(var/mob/living/linked as anything in linker.linked_mobs)
		all_who_can_hear += linked
	all_who_can_hear |= linker_parent

	for(var/mob/living/recipient as anything in all_who_can_hear)
		var/avoid_highlighting = (recipient == owner) || (recipient == linker_parent)
		to_chat(recipient, formatted_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = avoid_highlighting)
		if(linker.show_balloon_alert && recipient != owner)
			recipient.balloon_alert(recipient, "słyszysz głos z [linker.network_name]")

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		to_chat(recipient, "[FOLLOW_LINK(recipient, owner)] [formatted_message]", type = MESSAGE_TYPE_RADIO)
