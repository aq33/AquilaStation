// AQ EDIT - port z tgstation: tgui_input_checkboxes (okno CheckboxInput)
/**
 * ### tgui_input_checkboxes
 * Opens a window with a list of checkboxes and returns a list of selected choices.
 *
 * user - The mob to display the window to
 * message - The message inside the window
 * title - The title of the window
 * list/items - The list of items to display
 * min_checked - The minimum number of checkboxes that must be checked (defaults to 1)
 * max_checked - The maximum number of checkboxes that can be checked (optional)
 * timeout - The timeout for the input (optional)
 */
/proc/tgui_input_checkboxes(mob/user, message, title = "Wybierz", list/items, min_checked = 1, max_checked = 50, timeout = 0, ui_state = GLOB.always_state)
	if (!user)
		user = usr
	if(!length(items))
		return null
	if (!istype(user))
		if (istype(user, /client))
			var/client/client = user
			user = client.mob
		else
			return null

	if(isnull(user.client))
		return null

	// Client does NOT have tgui_input on: Returns regular input (single choice, wrapped in a list)
	if(!(user.client?.prefs?.toggles2 & PREFTOGGLE_2_TGUI_INPUT))
		var/choice = input(user, message, title) as null|anything in items
		return isnull(choice) ? null : list(choice)
	var/datum/tgui_checkbox_input/input = new(user, message, title, items, min_checked, max_checked, timeout, ui_state)
	input.ui_interact(user)
	input.wait()
	if (input)
		. = input.choices
		qdel(input)

/// Window for tgui_input_checkboxes
/datum/tgui_checkbox_input
	/// Title of the window
	var/title
	/// Message to display
	var/message
	/// List of items to display
	var/list/items
	/// List of selected items
	var/list/choices
	/// Time when the input was created
	var/start_time
	/// Timeout for the input
	var/timeout
	/// Whether the input was closed
	var/closed
	/// Minimum number of checkboxes that must be checked
	var/min_checked
	/// Maximum number of checkboxes that can be checked
	var/max_checked
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/ui_state/state

/datum/tgui_checkbox_input/New(mob/user, message, title, list/items, min_checked, max_checked, timeout, ui_state)
	src.title = title
	src.message = message
	src.items = items.Copy()
	src.min_checked = min_checked
	src.max_checked = max_checked
	src.state = ui_state

	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_checkbox_input/Destroy(force, ...)
	SStgui.close_uis(src)
	state = null
	items?.Cut()
	return ..()

/datum/tgui_checkbox_input/proc/wait()
	while (!closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_checkbox_input/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CheckboxInput")
		ui.open()

/datum/tgui_checkbox_input/ui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_checkbox_input/ui_state(mob/user)
	return state

/datum/tgui_checkbox_input/ui_data(mob/user)
	var/list/data = list()

	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

	return data

/datum/tgui_checkbox_input/ui_static_data(mob/user)
	var/list/data = list()

	data["items"] = items
	data["min_checked"] = min_checked
	data["max_checked"] = max_checked
	data["large_buttons"] = !user.client?.prefs || (user.client.prefs.toggles2 & PREFTOGGLE_2_BIG_BUTTONS)
	data["message"] = message
	data["swapped_buttons"] = !user.client?.prefs || (user.client.prefs.toggles2 & PREFTOGGLE_2_SWITCHED_BUTTONS)
	data["title"] = title

	return data

/datum/tgui_checkbox_input/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch(action)
		if("submit")
			var/list/selections = params["entry"]
			if(islist(selections) && length(selections) >= min_checked && length(selections) <= max_checked)
				// Only accept entries that were actually offered
				var/list/valid = list()
				for(var/entry in selections)
					var/item = islist(entry) ? entry[1] : entry
					if(item in items)
						valid |= item
				set_choices(valid)
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

	return FALSE

/datum/tgui_checkbox_input/proc/set_choices(list/selections)
	src.choices = selections.Copy()
