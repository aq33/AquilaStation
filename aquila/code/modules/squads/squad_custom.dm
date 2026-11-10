// Drużyny tworzone przez XO w konsoli oraz zmiana nazwy i koloru drużyny.
// Kanał pagera ma stały klucz (aq_channel_key), więc zmiana nazwy nie rozłącza pagerów,
// a wiadomości pokazują aktualną nazwę i kolor drużyny.

/// Ile drużyn można mieć łącznie (cztery stałe + utworzone w konsoli)
#define SQUAD_MAX_TOTAL 10

GLOBAL_VAR_INIT(aq_custom_squad_count, 0)
/// Wszystkie pagery drużyn (żeby nowa i rozwiązana drużyna nie przechodziły pętlą po całym świecie)
GLOBAL_LIST_EMPTY(aq_squad_pagers)

/obj/item/squad_pager/Initialize(mapload, datum/squad/squad)
	GLOB.aq_squad_pagers += src
	return ..()

/datum/squad
	/// Nazwa z definicji typu: preferencje postaci zapisują ją na stałe, więc po zmianie nazwy dalej prowadzi do tej drużyny
	var/aq_original_name
	/// Klucz kanału pagera (zostaje po zmianie nazwy)
	var/aq_channel_key

/datum/squad/New()
	aq_original_name = name
	aq_channel_key = name
	return ..()

/datum/squad/aq_custom
	name = "Echo"
	desc = "Drużyna utworzona przez oficera wykonawczego."
	role = DC_SQUAD
	colour = "#3cb371"

/datum/squad/aq_custom/New(new_name, new_colour)
	var/index = ++GLOB.aq_custom_squad_count
	if(new_name)
		name = new_name
	if(new_colour)
		colour = new_colour
	. = ..()
	aq_channel_key = "aq_squad_[index]"
	squad_channel?.key = aq_channel_key
	primary_objective = GLOB.squad_manager?.role_objective_map[role]
	access = GLOB.squad_manager?.role_access_map[role]

/datum/squad/aq_custom/generate_channel()
	squad_channel_type = /datum/component/simple_teamchat/radio_dependent/squad/aq_custom
	squad_channel = AddComponent(squad_channel_type, override = TRUE)
	squad_channel.squad = src

/datum/component/simple_teamchat/radio_dependent/squad/aq_custom
	name = "Drużyna"
	button_icon_state = "Able"
	key = "aq_squad"
	text_span_style = "ableradio"

/// Klucz kanału bierzemy z drużyny dopiero tu: pager dostaje drużynę po AddComponent(), a rejestracja w kanale idzie 1 s później
/datum/component/simple_teamchat/radio_dependent/squad/aq_custom/finalise_chat()
	if(squad?.aq_channel_key)
		key = squad.aq_channel_key
	if(chatAction && squad)
		chatAction.name = "Czat: [squad.name]"
	return ..()

/// Wiadomości pagera z aktualną nazwą i kolorem drużyny (po zmianie nazwy klucz kanału zostaje stary)
/datum/component/simple_teamchat/radio_dependent/squad/style_message(atom/movable/sender, msg)
	if(!squad)
		return ..()
	var/sender_text = isatom(sender) ? "[sender.compose_rank(sender)] [sender]" : "[sender]"
	return "<span class='[text_span_style]' style='color:[squad.colour]'>([squad.name]) [sender_text]: </span><span class='warning'>[msg]</span>"

// Instancja aq_custom tworzona przy starcie przez subtypesof(/datum/squad) w managerze nie jest prawdziwą drużyną
/datum/squad_manager/New()
	. = ..()
	for(var/datum/squad/aq_custom/template in squads)
		squads -= template
		LAZYREMOVEASSOC(role_squad_map, template.role, template)
		qdel(template)

/// Szuka też po nazwie pierwotnej (preferencje postaci po zmianie nazwy drużyny)
/datum/squad_manager/get_squad(name)
	. = ..()
	if(.)
		return
	var/original = GLOB.squad_legacy_names[name] || name // Able/Baker/Duff z bardzo starych zapisów
	for(var/datum/squad/squad as anything in squads)
		if(squad.aq_original_name == original)
			return squad

/// Tworzy nową drużynę; zwraca ją albo null, gdy nazwa zajęta lub osiągnięto limit
/datum/squad_manager/proc/aq_create_squad(new_name, new_colour)
	new_name = aq_clean_squad_name(new_name)
	if(!new_name || length(squads) >= SQUAD_MAX_TOTAL || aq_squad_name_taken(new_name))
		return null
	var/datum/squad/aq_custom/squad = new(new_name, new_colour)
	squads += squad
	LAZYADDASSOCLIST(role_squad_map, squad.role, squad)
	// globalne pagery dowództwa dostrajają się do drużyn tylko przy starcie (LateInitialize)
	for(var/obj/item/squad_pager/all_channels/global_pager in GLOB.aq_squad_pagers)
		var/datum/component/simple_teamchat/radio_dependent/squad/channel = global_pager.AddComponent(squad.squad_channel_type, override = TRUE)
		channel.squad = squad
	return squad

/datum/squad_manager/proc/aq_squad_name_taken(new_name, datum/squad/except)
	for(var/datum/squad/squad as anything in squads)
		if(squad != except && (lowertext(squad.name) == lowertext(new_name) || lowertext(squad.aq_original_name) == lowertext(new_name)))
			return TRUE
	return FALSE

/// Nazwa drużyny: bez znaczników, przycięta, do 20 znaków
/proc/aq_clean_squad_name(new_name)
	new_name = trim(reject_bad_name(strip_html_simple(new_name), allow_numbers = TRUE, max_length = 20, ascii_only = FALSE))
	return length(new_name) ? new_name : null

/// Rozwiązuje drużynę: członkowie zostają bez drużyny, znaczniki znikają, pagery tracą kanał
/// (dostroją się same, gdy właściciel dołączy do innej drużyny). Ostatniej drużyny nie da się usunąć.
/datum/squad_manager/proc/aq_delete_squad(datum/squad/squad, mob/user)
	if(!(squad in squads) || length(squads) <= 1)
		return FALSE
	squad.broadcast(squad, "Drużyna [squad.name] zostaje rozwiązana.", list('nsv13/sound/effects/notice2.ogg'))
	// bez przekazywania dowództwa i komunikatów przy każdym usuniętym członku
	squad.aq_disbanding = TRUE
	squad.unset_leader() // zdejmuje akcje rozkazu i znacznika, bez komunikatu na kanale
	for(var/mob/living/carbon/human/member as anything in squad.members.Copy())
		squad.remove_member(member)
		member.squad = null
		member.aq_update_squad_hud()
	for(var/marker_type in squad.aq_markers)
		squad.aq_clear_marker(marker_type)
	var/list/channels = GLOB.simple_teamchats[squad.aq_channel_key]
	// klucz kanału jest tylko tej drużyny, więc znikają wszystkie jego kanały (także w globalnych pagerach dowództwa)
	for(var/datum/component/simple_teamchat/radio_dependent/squad/channel as anything in channels?.Copy())
		var/obj/item/squad_pager/pager = channel.parent
		if(istype(pager))
			if(pager.squad_channel == channel)
				pager.squad_channel = null
			if(pager.squad == squad)
				pager.squad = null
		qdel(channel)
	// pager dopisuje się do kanału sekundę po powstaniu, więc sprawdzamy też same pagery
	for(var/obj/item/squad_pager/pager as anything in GLOB.aq_squad_pagers)
		if(pager.squad != squad)
			continue
		if(pager.squad_channel)
			QDEL_NULL(pager.squad_channel)
		pager.squad = null
	squads -= squad
	LAZYREMOVEASSOC(role_squad_map, squad.role, squad)
	log_game("[key_name(user)] disbanded squad [squad.name]")
	return TRUE

/datum/squad
	/// Trwa rozwiązywanie: bez przekazywania dowództwa i komunikatów kanału
	var/aq_disbanding = FALSE

/datum/squad/broadcast(mob/living/carbon/human/sender, message, list/sounds)
	if(aq_disbanding)
		return FALSE
	return ..()

/datum/squad/proc/aq_rename(new_name, mob/user)
	new_name = aq_clean_squad_name(new_name)
	if(!new_name || new_name == name || GLOB.squad_manager.aq_squad_name_taken(new_name, src))
		return FALSE
	var/old_name = name
	name = new_name
	if(squad_channel)
		squad_channel.name = "Drużyna [name]"
	log_game("[key_name(user)] renamed squad [old_name] to [name]")
	broadcast(src, "Drużyna nazywa się teraz [name].", list('nsv13/sound/effects/notice2.ogg'))
	return TRUE

/datum/squad/proc/aq_recolour(new_colour, mob/user)
	new_colour = sanitize_hexcolor(new_colour, desired_format = 6, include_crunch = TRUE)
	if(!new_colour || new_colour == colour)
		return FALSE
	colour = new_colour
	log_game("[key_name(user)] changed the colour of squad [name] to [colour]")
	aq_refresh_all()
	return TRUE

#undef SQUAD_MAX_TOTAL
