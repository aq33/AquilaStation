/// Item name without the \proper and \improper markers, shared by the window key and the displayed name
/obj/machinery/smartfridge/proc/smartfridge_plain_name(atom/movable/stored)
	return replacetext(replacetext(stored.name, "\proper", ""), "\improper", "")

/**
 * Name in the window with the contents first: "butelka: węgiel aktywny" becomes "Węgiel aktywny (butelka)".
 * A dose at the end ("pigułka: węgiel aktywny (10 j.)") goes into the same bracket: "Węgiel aktywny (pigułka, 10 j.)".
 * Other brackets belong to the name and stay where they are.
 */
/obj/machinery/smartfridge/proc/smartfridge_display_name(atom/movable/stored)
	var/item_name = smartfridge_plain_name(stored)
	var/split = findtext(item_name, ": ")
	if(!split)
		return capitalize(item_name)
	var/container = copytext(item_name, 1, split)
	var/contents = capitalize(trim(copytext(item_name, split + 2)))
	var/static/regex/dose = regex(@" \((\d+(\.\d+)? ?(j\.|u))\)$")
	if(dose.Find(contents))
		return "[copytext(contents, 1, dose.index)] ([container], [dose.group[1]])"
	return "[contents] ([container])"
