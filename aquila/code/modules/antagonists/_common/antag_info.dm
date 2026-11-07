// Port BeeStation #9205: okno informacji o roli antagonisty i przycisk, który je otwiera.
// Haki w core: antag_datum.dm (on_gain, on_body_transfer, on_removal).

/// Makes the action button that opens the info window, if this antag has one
/datum/antagonist/proc/make_info_button()
	if(!ui_name || !owner?.current)
		return
	var/datum/action/antag_info/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/antagonist/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bee_antags),
		get_asset_datum(/datum/asset/simple/aquila_antag_info),
	)

/// Pictures used by the BeeStation antag info windows that bee_antags does not have
/datum/asset/simple/aquila_antag_info
	assets = list(
		"apistol.png" = 'aquila/html/img/apistol.png',
		"atool.png" = 'aquila/html/img/atool.png',
		"cult-altar.gif" = 'aquila/html/img/cult-altar.gif',
		"cult-archives.gif" = 'aquila/html/img/cult-archives.gif',
		"cult-carve.png" = 'aquila/html/img/cult-carve.png',
		"cult-comms.png" = 'aquila/html/img/cult-comms.png',
		"cult-forge.gif" = 'aquila/html/img/cult-forge.gif',
		"cult-pylon.gif" = 'aquila/html/img/cult-pylon.gif',
		"vampire.png" = 'aquila/html/img/vampire.png',
	)

/// Button for antags to review their role description and objectives
/datum/action/antag_info
	name = "Informacje o roli"
	button_icon_state = "round_end"

/datum/action/antag_info/New(Target)
	. = ..()
	name = "Informacje o roli: [target]"

/datum/action/antag_info/Trigger()
	. = ..()
	if(!.)
		return
	target.ui_interact(owner)

/datum/action/antag_info/IsAvailable()
	if(!target)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind || !(target in owner.mind.antag_datums))
		return FALSE
	return TRUE

/// Wprowadzenie do roli w oknie ogólnym (AntagInfoGeneric). Domyślnie opis potwora z playstyle_string
/// (pradawny horror, morph, demon, imp...), a bez niego powitanie z greet() zapisane przy starcie roli.
/// Role mogą to nadpisać.
/datum/antagonist/proc/get_antag_intro()
	var/mob/current = owner?.current
	if(current && ("playstyle_string" in current.vars) && current.vars["playstyle_string"])
		return current.vars["playstyle_string"]
	return greeting_text

/datum/antagonist
	/// Powitanie roli z czatu (greet()), pokazywane w oknie roli, gdy rola nie ma własnego opisu
	var/greeting_text
	/// Wiersze powitania zbierane w trakcie greet()
	var/list/greeting_lines
	/// world.time, w którym zaczęło się zbieranie (greet() nie powinno spać, późniejsze wiadomości to już nie powitanie)
	var/greeting_capture_time

/// Rola, której powitanie właśnie zbiera to_chat()
GLOBAL_DATUM(antag_greeting_capture, /datum/antagonist)

/// greet() z zapisem wiadomości dla gracza. Wcześniej cały samouczek wielu ról (demon impulsu, smok, rewenant...)
/// szedł tylko do czatu, a okno pod przyciskiem roli miało samą nazwę i cele. Woła to on_gain() w antag_datum.dm.
/datum/antagonist/proc/greet_and_capture()
	var/datum/antagonist/previous = GLOB.antag_greeting_capture
	GLOB.antag_greeting_capture = src
	greeting_lines = list()
	greeting_capture_time = world.time
	try
		greet()
	catch(var/exception/greet_error)
		// Błąd w greet(): globalny wskaźnik nie może zostać na tej roli (trzymałby referencję do datumu)
		GLOB.antag_greeting_capture = previous
		greeting_lines = null
		throw greet_error
	GLOB.antag_greeting_capture = previous
	if(length(greeting_lines))
		greeting_text = jointext(greeting_lines, "<br>")
	greeting_lines = null

/// Hak z to_chat(): wiadomość do gracza tej roli w trakcie greet()
/datum/antagonist/proc/capture_greeting(target, html)
	if(world.time != greeting_capture_time || !islist(greeting_lines))
		GLOB.antag_greeting_capture = null // greet() zasnął albo się wywalił: dalej nie zbieramy
		return
	if(!istext(html) || !owner || (target != owner && target != owner.current && target != owner.current?.client))
		return
	var/static/regex/media = regex(@"<(img|audio|source)[^>]*>", "gi") // ikony icon2html z czatu nie istnieją w oknie
	greeting_lines += media.Replace(html, "")

// Cele okno pokazuje osobno, więc nie trafiają do powitania
/datum/mind/announce_objectives()
	var/datum/antagonist/capturing = GLOB.antag_greeting_capture
	GLOB.antag_greeting_capture = null
	. = ..()
	GLOB.antag_greeting_capture = capturing

/datum/antagonist/ui_static_data(mob/user)
	. = ..()
	var/intro = get_antag_intro()
	if(intro)
		.["intro"] = intro
