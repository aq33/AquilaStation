// AQUILA - NIFSoft „Rój umysłów”: własna sieć telepatyczna, do której zaprasza się innych nosicieli tego programu.
// Wiadomości pisze się na holograficznym interfejsie, który pojawia się w dłoni po włączeniu programu.
// Port z Monkestation (nifsofts/hivemind.dm), na naszym /datum/component/mind_linker (heretic/_compat/ashflesh.dm).

/// Nosiciele programu „Rój umysłów”, którzy przyjmują zaproszenia
GLOBAL_LIST_EMPTY(nif_hivemind_users)

/obj/item/disk/nifsoft_uploader/hivemind
	loaded_nifsoft = /datum/nifsoft/hivemind

/datum/nifsoft/hivemind
	name = "Rój umysłów"
	program_desc = "Rój umysłów to program pomyślany jako pewniejsza namiastka tajemniczego sposobu porozumiewania się niektórych odmian szlamów. Opiera się na szczególnym ustawieniu NIF-u, które tworzy lokalną sieć podprzestrzenną. Jej treścią są myśli nosiciela, więc program służy jako zaawansowana telepatia między użytkownikami NIF-ów."
	activation_cost = 10
	active_mode = TRUE
	active_cost = 0.2
	purchase_price = 350
	buying_category = NIFSOFT_CATEGORY_UTILITY
	ui_icon = "users"

	/// Sieć, której nosiciel jest właścicielem
	var/datum/component/mind_linker/active_linking/nif/user_network
	/// Sieci, do których nosiciel należy (w tym własna)
	var/list/network_list = list()
	/// Sieć, do której idą wiadomości z interfejsu
	var/datum/component/mind_linker/active_linking/nif/active_network
	/// Interfejs w dłoni, którym pisze się wiadomości
	var/obj/item/hivemind_keyboard/linked_keyboard
	/// Akcja przywołująca interfejs
	var/datum/action/innate/hivemind_keyboard/keyboard_action

/datum/nifsoft/hivemind/New()
	. = ..()
	if(QDELETED(src))
		return

	user_network = linked_mob.AddComponent(/datum/component/mind_linker/active_linking/nif, \
		network_name = "łącze roju", \
		chat_color = "#5ACC6B", \
		linker_action_path = /datum/action/innate/hivemind_config, \
	)

	keyboard_action = new(linked_mob)
	keyboard_action.Grant(linked_mob)

	active_network = user_network
	network_list += user_network
	GLOB.nif_hivemind_users |= linked_mob

/datum/nifsoft/hivemind/Destroy()
	GLOB.nif_hivemind_users -= linked_mob
	QDEL_NULL(keyboard_action)
	remove_keyboard()

	for(var/datum/component/mind_linker/active_linking/nif/hivemind as anything in network_list)
		if(hivemind == user_network)
			continue
		hivemind.remove_member(linked_mob)
		var/mob/living/hivemind_owner = hivemind.parent
		to_chat(hivemind_owner, span_abductor("[linked_mob] opuszcza twój rój."))
		to_chat(linked_mob, span_abductor("Opuszczasz rój: [hivemind.name]."))

	network_list.Cut()
	active_network = null
	QDEL_NULL(user_network)
	return ..()

/datum/nifsoft/hivemind/activate()
	. = ..()
	if(!.)
		return
	if(!active)
		remove_keyboard()
		return TRUE

	linked_keyboard = new(linked_mob.drop_location())
	linked_keyboard.connected_network = active_network
	linked_keyboard.source_user = WEAKREF(linked_mob)
	RegisterSignal(linked_keyboard, COMSIG_PARENT_QDELETING, PROC_REF(on_keyboard_deleted))
	linked_mob.put_in_hands(linked_keyboard)
	linked_mob.visible_message(span_notice("[linked_mob] nagle trzyma [linked_keyboard.name], zmaterializowany z powietrza."), span_notice("W twoich dłoniach pojawia się [linked_keyboard.name]."))
	return TRUE

/// Usuwa interfejs z dłoni
/datum/nifsoft/hivemind/proc/remove_keyboard()
	if(!linked_keyboard)
		return
	UnregisterSignal(linked_keyboard, COMSIG_PARENT_QDELETING)
	QDEL_NULL(linked_keyboard)

/datum/nifsoft/hivemind/proc/on_keyboard_deleted(datum/source)
	SIGNAL_HANDLER
	linked_keyboard = null

/// Sieć tej osoby została rozwiązana: usuwa ją z list
/datum/nifsoft/hivemind/proc/forget_network(datum/component/mind_linker/active_linking/nif/network)
	network_list -= network
	if(active_network == network)
		active_network = user_network
		if(linked_keyboard)
			linked_keyboard.connected_network = user_network

/datum/action/innate/hivemind_config
	name = "Ustawienia roju umysłów"
	desc = "Zapraszaj i usuwaj członków, zmieniaj kolor i aktywny rój."
	button_icon = 'aquila/icons/monke/nif/nif_action_backgrounds.dmi'
	background_icon_state = "android"
	icon_icon = 'aquila/icons/monke/nif/nif_actions.dmi'
	button_icon_state = "phone_settings"

/datum/action/innate/hivemind_config/Activate()
	var/datum/component/mind_linker/active_linking/nif/link = target
	if(!istype(link))
		return

	var/choice = tgui_input_list(owner, "Wybierz opcję", "Ustawienia roju umysłów", list("Zaproś osobę", "Usuń osobę", "Zmień kolor roju", "Zmień aktywny rój", "Opuść rój", "Przełącz zaproszenia"))
	if(!choice || QDELETED(src) || QDELETED(link))
		return

	switch(choice)
		if("Zaproś osobę")
			link.invite_user()
		if("Usuń osobę")
			link.remove_user()
		if("Opuść rój")
			leave_hivemind()
		if("Zmień aktywny rój")
			change_hivemind()
		if("Zmień kolor roju")
			link.change_chat_color()
		if("Przełącz zaproszenia")
			toggle_invites()

/datum/action/innate/hivemind_config/proc/change_hivemind()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind = user.find_nifsoft(/datum/nifsoft/hivemind)
	if(!hivemind)
		return FALSE

	var/datum/component/mind_linker/active_linking/nif/new_active_hivemind = tgui_input_list(user, "Wybierz rój, do którego mają trafiać wiadomości.", "Zmiana roju", hivemind.network_list)
	if(!new_active_hivemind || QDELETED(hivemind) || !(new_active_hivemind in hivemind.network_list))
		return FALSE

	hivemind.active_network = new_active_hivemind
	if(hivemind.linked_keyboard)
		hivemind.linked_keyboard.connected_network = new_active_hivemind
	to_chat(user, span_abductor("Twoje wiadomości trafiają teraz do: [new_active_hivemind.name]."))

/datum/action/innate/hivemind_config/proc/leave_hivemind()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind = user.find_nifsoft(/datum/nifsoft/hivemind)
	if(!hivemind)
		return FALSE

	var/list/other_networks = hivemind.network_list.Copy()
	other_networks -= hivemind.user_network

	var/datum/component/mind_linker/active_linking/nif/hivemind_to_leave = tgui_input_list(user, "Wybierz rój, który chcesz opuścić.", "Opuszczanie roju", other_networks)
	if(!hivemind_to_leave || QDELETED(hivemind) || QDELETED(hivemind_to_leave))
		return FALSE

	to_chat(hivemind_to_leave.parent, span_abductor("[user] opuszcza twój rój."))
	to_chat(user, span_abductor("Opuszczasz rój: [hivemind_to_leave.name]."))

	hivemind.forget_network(hivemind_to_leave)
	hivemind_to_leave.remove_member(user)

/datum/action/innate/hivemind_config/proc/toggle_invites()
	var/mob/living/carbon/human/user = owner
	if(user in GLOB.nif_hivemind_users)
		GLOB.nif_hivemind_users -= user
		to_chat(user, span_abductor("Nie przyjmujesz już zaproszeń do roju."))
		return

	GLOB.nif_hivemind_users |= user
	to_chat(user, span_abductor("Znów przyjmujesz zaproszenia do roju."))

/datum/action/innate/hivemind_keyboard
	name = "Interfejs roju umysłów"
	desc = "Przywołuje albo chowa interfejs, którym piszesz do roju."
	button_icon = 'aquila/icons/monke/nif/nif_action_backgrounds.dmi'
	background_icon_state = "android"
	icon_icon = 'aquila/icons/monke/nif/nif_actions.dmi'
	button_icon_state = "phone"

/datum/action/innate/hivemind_keyboard/Activate()
	var/mob/living/carbon/human/user = owner
	var/datum/nifsoft/hivemind/hivemind_nifsoft = user.find_nifsoft(/datum/nifsoft/hivemind)
	if(!hivemind_nifsoft)
		return FALSE

	hivemind_nifsoft.activate()

/// Sieć roju umysłów z NIF-u: bez akcji mowy (pisze się interfejsem), bez sprawdzania ochrony umysłu
/datum/component/mind_linker/active_linking/nif
	/// Nazwa w menu wyboru
	var/name = ""

/datum/component/mind_linker/active_linking/nif/Initialize(
	network_name = "łącze roju",
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
	QDEL_NULL(master_speech) // rój pisze interfejsem, nie akcją mowy
	var/mob/living/owner = parent
	name = "[network_name] ([owner.real_name])"

/datum/component/mind_linker/active_linking/nif/Destroy(force, silent)
	for(var/mob/living/carbon/human/member as anything in linked_mobs)
		UnregisterSignal(member, COMSIG_PARENT_QDELETING)
		var/datum/nifsoft/hivemind/member_hivemind = member.find_nifsoft(/datum/nifsoft/hivemind)
		member_hivemind?.forget_network(src)
	linked_mobs.Cut()
	return ..()

/// Dodaje osobę do roju (bez akcji mowy)
/datum/component/mind_linker/active_linking/nif/proc/add_member(mob/living/carbon/human/new_member)
	if(QDELETED(new_member) || (new_member in linked_mobs) || new_member == parent)
		return FALSE
	linked_mobs += new_member
	RegisterSignal(new_member, COMSIG_PARENT_QDELETING, PROC_REF(on_member_deleted))
	return TRUE

/// Usuwa osobę z roju
/datum/component/mind_linker/active_linking/nif/proc/remove_member(mob/living/carbon/human/member)
	if(!(member in linked_mobs))
		return FALSE
	linked_mobs -= member
	UnregisterSignal(member, COMSIG_PARENT_QDELETING)
	return TRUE

/datum/component/mind_linker/active_linking/nif/proc/on_member_deleted(datum/source)
	SIGNAL_HANDLER
	remove_member(source)

/// Zaprasza do roju osobę z programem „Rój umysłów”
/datum/component/mind_linker/active_linking/nif/proc/invite_user()
	var/mob/living/carbon/human/owner = parent
	var/list/hivemind_users = GLOB.nif_hivemind_users.Copy()
	hivemind_users -= linked_mobs
	hivemind_users -= owner

	var/mob/living/carbon/human/person_to_add = tgui_input_list(owner, "Wybierz osobę, którą chcesz zaprosić do roju.", "Zaproszenie", hivemind_users)
	if(!person_to_add || QDELETED(src))
		return

	if(tgui_alert(person_to_add, "[owner] zaprasza cię do swojego roju umysłów. Przyjmujesz?", "Zaproszenie do roju", list("Przyjmij", "Odrzuć")) != "Przyjmij")
		to_chat(owner, span_warning("[person_to_add] odrzuca zaproszenie do twojego roju."))
		return

	if(QDELETED(src))
		return
	var/datum/nifsoft/hivemind/target_hivemind = person_to_add.find_nifsoft(/datum/nifsoft/hivemind)
	if(!target_hivemind || !add_member(person_to_add))
		return FALSE

	target_hivemind.network_list |= src
	to_chat(person_to_add, span_abductor("Należysz teraz do roju: [name]."))
	to_chat(owner, span_abductor("[person_to_add] należy teraz do twojego roju."))

/// Usuwa wybraną osobę z roju
/datum/component/mind_linker/active_linking/nif/proc/remove_user()
	var/mob/living/carbon/human/owner = parent
	var/mob/living/carbon/human/person_to_remove = tgui_input_list(owner, "Wybierz osobę, którą chcesz usunąć z roju.", "Usuwanie z roju", linked_mobs)
	if(!person_to_remove || QDELETED(src) || !remove_member(person_to_remove))
		return

	var/datum/nifsoft/hivemind/target_hivemind = person_to_remove.find_nifsoft(/datum/nifsoft/hivemind)
	target_hivemind?.forget_network(src)
	to_chat(person_to_remove, span_abductor("Nie należysz już do roju: [name]."))
	to_chat(owner, span_abductor("[person_to_remove] nie należy już do twojego roju."))

/datum/component/mind_linker/active_linking/nif/proc/change_chat_color()
	var/mob/living/carbon/human/owner = parent
	var/new_chat_color = tgui_color_picker(owner, "", "Kolor roju", chat_color)
	if(!new_chat_color || QDELETED(src))
		return FALSE

	chat_color = new_chat_color

/// Holograficzny interfejs, którym nosiciel pisze do roju
/obj/item/hivemind_keyboard
	name = "interfejs roju umysłów"
	desc = "Holograficzny sterownik gestów, podpięty pod wybrane przez nosiciela ruchy dłoni i palców. Działa razem z programem „Rój umysłów” i odsiewa niechciane myśli, żeby do sieci trafiały tylko świadome wiadomości."
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	/// Sieć, do której idą wiadomości
	var/datum/component/mind_linker/active_linking/nif/connected_network
	/// Właściciel interfejsu
	var/datum/weakref/source_user

/obj/item/hivemind_keyboard/Destroy(force)
	connected_network = null
	return ..()

/obj/item/hivemind_keyboard/attack_self(mob/user)
	. = ..()
	send_message(user)

/// Pyta o wiadomość i wysyła ją do całego roju
/obj/item/hivemind_keyboard/proc/send_message(mob/living/carbon/human/user)
	// Pisać może tylko właściciel interfejsu: cudza ręka nie podpisze się jego imieniem
	var/mob/living/carbon/human/keyboard_owner = source_user?.resolve()
	if(!keyboard_owner || user != keyboard_owner)
		to_chat(user, span_warning("Interfejs nie reaguje na twoje gesty."))
		return
	// Wiadomość idzie do sieci wybranej przy otwarciu okna, nie do tej, na którą przełączono w trakcie pisania
	var/datum/component/mind_linker/active_linking/nif/target_network = connected_network
	if(QDELETED(target_network))
		to_chat(user, span_warning("Połączenie chyba zostało zerwane."))
		return
	var/message = tgui_input_text(user, "Wpisz wiadomość do wysłania.", "Telepatia: [target_network.name]")
	if(!message || QDELETED(src) || QDELETED(user) || user.stat == DEAD || user != source_user?.resolve())
		return

	if(QDELETED(target_network) || !(user == target_network.parent || (user in target_network.linked_mobs)))
		to_chat(user, span_warning("Połączenie chyba zostało zerwane."))
		return

	var/mob/living/network_owner = target_network.parent
	var/hivemind_icon = icon2html('aquila/icons/monke/nif/nif_chat.dmi', user.client, "phone") || ""

	var/formatted_message = "<i><font color=[target_network.chat_color]>\[[hivemind_icon][target_network.name]\] <b>[keyboard_owner]:</b> [message]</font></i>"
	log_directed_talk(user, network_owner, message, LOG_SAY, "mind link ([target_network.network_name])")

	var/list/all_who_can_hear = target_network.linked_mobs.Copy()
	all_who_can_hear |= network_owner

	for(var/mob/living/recipient as anything in all_who_can_hear)
		var/avoid_highlighting = (recipient == user) || (network_owner == user)
		to_chat(recipient, formatted_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = avoid_highlighting)

	for(var/mob/recipient as anything in GLOB.dead_mob_list)
		if(!isobserver(recipient))
			continue
		to_chat(recipient, "[FOLLOW_LINK(recipient, user)] [formatted_message]", type = MESSAGE_TYPE_RADIO)
