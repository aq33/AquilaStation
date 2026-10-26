// ByondUi z tgui-core 6 wysyła renderByondUi/unmountByondUi, ale sam zdejmuje kontrolkę mapy tylko przy odmontowaniu w React.
// Po crashu TGUI (niebieski ekran) React już nic nie odmontuje i kontrolka zostaje w oknie z puli
// jako czarny prostokąt, np. podgląd postaci zasłaniający pół listy prac w preferencjach.

/datum/tgui_window
	/// Ids of map controls rendered by ByondUi in this window
	var/list/byondui_elements

/datum/tgui_window/proc/clear_byondui_elements()
	if(client)
		for(var/element_id in byondui_elements)
			winset(client, element_id, "parent=")
	byondui_elements = null

/datum/tgui_window/initialize(strict_mode = FALSE, assets = list(), inline_html = "", inline_js = "", inline_css = "")
	clear_byondui_elements()
	return ..()

/datum/tgui_window/close(can_be_suspended = TRUE)
	clear_byondui_elements()
	return ..()

/datum/tgui_window/on_message(type, payload, href_list)
	switch(type)
		if("renderByondUi")
			var/element_id = payload?["renderByondUi"]
			if(istext(element_id))
				LAZYOR(byondui_elements, element_id)
		if("unmountByondUi")
			LAZYREMOVE(byondui_elements, payload?["renderByondUi"])
	return ..()
