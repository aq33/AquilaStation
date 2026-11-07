// AQUILA - kurtki zimowe z osobnym zapięciem i kapturem (grafika z arkuszy Żandarmerii i InPostu).
// W tych arkuszach "[icon_state]" to kurtka zapięta, "[icon_state]_t" rozpięta, a kaptur ma dwa stany w icons/mob/clothing/head.dmi:
// założony (stan kaptura) i opuszczony (hood_down_state, rysowany na kurtce). Stare kurtki bez hood_down_state działają jak dotąd:
// kaptur przełącza "_t".

/obj/item/clothing/suit/hooded/wintercoat
	/// Stan opuszczonego kaptura w icons/mob/clothing/head.dmi. Ustawiony = zapięcie przełącza Alt+klik, a kaptur nie zmienia kurtki.
	var/hood_down_state
	/// Kurtka rozpięta (stan "[icon_state]_t")
	var/zip_open = FALSE

/obj/item/clothing/suit/hooded/wintercoat/security
	hood_down_state = "winterhood_security_down"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	hood_down_state = "winterhood_cargo_down"

/obj/item/clothing/suit/hooded/wintercoat/ToggleHood()
	. = ..()
	update_zip_icon()

/obj/item/clothing/suit/hooded/wintercoat/RemoveHood()
	. = ..()
	update_zip_icon()

/// Ustawia grafikę zapięcia niezależnie od kaptura i odświeża kurtkę na postaci
/obj/item/clothing/suit/hooded/wintercoat/proc/update_zip_icon()
	if(!hood_down_state)
		return
	icon_state = "[initial(icon_state)][zip_open ? "_t" : ""]"
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_inv_wear_suit()

/obj/item/clothing/suit/hooded/wintercoat/AltClick(mob/user)
	if(!hood_down_state)
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	zip_open = !zip_open
	to_chat(user, "<span class='notice'>[zip_open ? "Rozpinasz" : "Zapinasz"] [src].</span>")
	update_zip_icon()
	return TRUE

/obj/item/clothing/suit/hooded/wintercoat/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(!isinhands && hood_down_state && !suittoggled)
		. += mutable_appearance('icons/mob/clothing/head.dmi', hood_down_state)

/obj/item/clothing/suit/hooded/wintercoat/examine(mob/user)
	. = ..()
	if(hood_down_state)
		. += "<span class='notice'>Alt+klik, by [zip_open ? "zapiąć" : "rozpiąć"] kurtkę.</span>"
