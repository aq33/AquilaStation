// Czip tłumacza: siedzi we własnym gnieździe słuchawek, obok kluczy szyfrujących (keyslot i keyslot2 zostają wolne).
// Tłumaczy tak samo jak tłumacz kieszonkowy (translator_item.dm), ale tylko gdy słuchawki są na uszach.
// Wkłada się go jak klucz, wyjmuje multitoolem. Śrubokręt wyjmuje same klucze.
/obj/item/aquila_translator_chip
	name = "czip tłumacza"
	desc = "Szklana drzazga z obwodem danych i złotymi stykami. Wsunięta w gniazdo słuchawek przekłada mowę między angielskim i polskim, dopóki nosisz je na uszach. Nie zajmuje miejsca na klucze szyfrujące, a wyjmuje się ją multitoolem."
	icon = 'aquila/icons/obj/translator_chip.dmi'
	icon_state = "translator_chip"
	w_class = WEIGHT_CLASS_TINY

/obj/item/radio/headset
	/// Czip tłumacza w osobnym gnieździe
	var/obj/item/aquila_translator_chip/aq_translator_chip
	/// Kto ma teraz tłumacza z tych słuchawek (żeby zdjąć go temu samemu mobowi)
	var/mob/aq_translator_wearer

/obj/item/radio/headset/Destroy()
	aq_set_translator_wearer(null)
	QDEL_NULL(aq_translator_chip)
	return ..()

/obj/item/radio/headset/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == aq_translator_chip)
		aq_translator_chip = null
		aq_update_translator_wearer()

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(aq_translator_chip)
		. += span_notice("W gnieździe tłumacza siedzi [aq_translator_chip.name]. Multitool go wyjmie.")

/obj/item/radio/headset/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/aquila_translator_chip))
		return ..()
	if(aq_translator_chip)
		to_chat(user, span_warning("W gnieździe tłumacza jest już czip!"))
		return
	if(!user.transferItemToLoc(W, src))
		return
	aq_translator_chip = W
	to_chat(user, span_notice("Wsuwasz [W.name] w gniazdo słuchawek."))
	aq_update_translator_wearer()

/obj/item/radio/headset/multitool_act(mob/living/user, obj/item/tool)
	if(!aq_translator_chip)
		return ..()
	var/obj/item/aquila_translator_chip/chip = aq_translator_chip
	// Exited() czyści gniazdo i zdejmuje tłumacza z noszącego
	if(!user.put_in_hands(chip))
		chip.forceMove(drop_location())
	to_chat(user, span_notice("Podważasz [chip.name] i wyjmujesz go ze słuchawek."))
	return TRUE

/obj/item/radio/headset/equipped(mob/user, slot)
	. = ..()
	aq_update_translator_wearer()

/obj/item/radio/headset/dropped(mob/user)
	. = ..()
	aq_update_translator_wearer()

/// Tłumacz działa, gdy czip siedzi w słuchawkach, a słuchawki są na uszach moba, który je trzyma
/obj/item/radio/headset/proc/aq_update_translator_wearer()
	var/mob/wearer = null
	if(aq_translator_chip && ismob(loc))
		var/mob/holder = loc
		if(holder.get_item_by_slot(ITEM_SLOT_EARS) == src)
			wearer = holder
	aq_set_translator_wearer(wearer)

/obj/item/radio/headset/proc/aq_set_translator_wearer(mob/wearer)
	if(wearer == aq_translator_wearer)
		return
	if(aq_translator_wearer)
		aq_translator_wearer.aq_translator_off(REF(src))
	aq_translator_wearer = wearer
	if(wearer)
		wearer.aq_translator_on(REF(src))
