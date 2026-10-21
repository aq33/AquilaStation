// AQUILA - tgstation#94761

/**
 * tgui state: book_state
 *
 * A state specifically intended for book or book-like objects.
 * Checks for state related to being able to read.
 */
GLOBAL_DATUM_INIT(book_state, /datum/ui_state/book, new)

/datum/ui_state/book/can_use_topic(src_object, mob/user)
	// not can_read(), it would spam its warnings on every update
	if(is_blind(user) || !user.is_literate())
		return UI_CLOSE

	if(isitem(src_object))
		var/obj/item/book = src_object
		if(book.resistance_flags & ON_FIRE)
			return UI_CLOSE

	. = user.shared_ui_interaction(src_object)
	if(. <= UI_CLOSE)
		return
	if(isliving(user))
		var/mob/living/living_user = user
		return min(., living_user.shared_living_ui_distance(src_object))
	return min(., UI_UPDATE)
