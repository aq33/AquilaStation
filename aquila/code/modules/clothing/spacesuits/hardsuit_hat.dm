// Czapka na hełmie hardsuitu: każdy hełm hardsuitu przyjmuje czapkę (tylko wygląd, bez pancerza i funkcji czapki).
// Wzór: hełm plazmoluda (attached_hat) i moduł stabilizatora czapki MOD. Moduł na hardsuicie nic nie rysował
// (hardsuit nie ma nakładek modułów), więc teraz robi to sam hełm, a moduł na hardsuicie jest bez działania.

/obj/item/clothing/head/helmet/space/hardsuit
	/// Czapka założona na hełm (tylko wygląd)
	var/obj/item/clothing/head/attached_hat

/// Czy tę czapkę można założyć na hełm hardsuitu
/obj/item/clothing/head/helmet/space/hardsuit/proc/can_attach_hat(obj/item/clothing/head/hat)
	if(!istype(hat))
		return FALSE
	// hełm na hełmie, trzymane zwierzę i czapka z folii (rysowana dopiero po założeniu) nie wchodzą w grę
	if(istype(hat, /obj/item/clothing/head/helmet/space) || istype(hat, /obj/item/clothing/head/mob_holder) || istype(hat, /obj/item/clothing/head/foilhat))
		return FALSE
	return TRUE

/obj/item/clothing/head/helmet/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head) && can_attach_hat(I))
		attach_hat(I, user)
		return
	return ..()

/// Zakłada czapkę na hełm; TRUE, jeśli się udało
/obj/item/clothing/head/helmet/space/hardsuit/proc/attach_hat(obj/item/clothing/head/hat, mob/user)
	if(attached_hat)
		if(user)
			balloon_alert(user, "na hełmie jest już czapka!")
		return FALSE
	if(user && !user.transferItemToLoc(hat, src))
		return FALSE
	if(!user)
		hat.forceMove(src)
	attached_hat = hat
	if(user)
		balloon_alert(user, "czapka założona, Alt-klik, by zdjąć")
	update_hat_wearer()
	return TRUE

/// Zdejmuje czapkę z hełmu do ręki (albo na podłogę); zwraca czapkę
/obj/item/clothing/head/helmet/space/hardsuit/proc/detach_hat(mob/user)
	if(!attached_hat)
		return null
	var/obj/item/clothing/head/hat = attached_hat
	attached_hat = null
	hat.forceMove(drop_location())
	if(user)
		if(user.put_in_hands(hat))
			balloon_alert(user, "czapka zdjęta")
		else
			balloon_alert(user, "czapka spada na podłogę!")
	update_hat_wearer()
	return hat

/obj/item/clothing/head/helmet/space/hardsuit/proc/update_hat_wearer()
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_inv_head()

/obj/item/clothing/head/helmet/space/hardsuit/AltClick(mob/user)
	if(attached_hat && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		detach_hat(user)
		return
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/examine(mob/user)
	. = ..()
	if(attached_hat)
		. += "<span class='notice'>Na hełmie jest [attached_hat.name]. Alt-klik, by zdjąć.</span>"
	else
		. += "<span class='notice'>Możesz założyć na hełm czapkę.</span>"

/obj/item/clothing/head/helmet/space/hardsuit/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(!isinhands && attached_hat)
		. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')

/obj/item/clothing/head/helmet/space/hardsuit/Exited(atom/movable/gone, direction)
	. = ..()
	// czapkę ktoś wyjął inną drogą (np. rozbiórka)
	if(gone == attached_hat)
		attached_hat = null
		update_hat_wearer()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	// czapka nie ginie razem z hełmem
	if(attached_hat)
		var/obj/item/clothing/head/hat = attached_hat
		attached_hat = null
		if(isturf(drop_location()))
			hat.forceMove(drop_location())
		else
			qdel(hat)
	return ..()

// Zwinięty hełm siedzi w kombinezonie: czapkę można założyć, klikając nią kombinezon
/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/head) && helmet?.can_attach_hat(I))
		helmet.attach_hat(I, user)
		return
	return ..()

// Alt-klik na kombinezon zdejmuje czapkę także ze schowanego hełmu
/obj/item/clothing/suit/space/hardsuit/AltClick(mob/user)
	if(helmet?.attached_hat && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		helmet.detach_hat(user)
		return
	return ..()

// Stabilizator czapki MOD: MOD-ów już nie ma, a w hardsuicie czapkę trzyma sam hełm, więc moduł nic nie robi
/obj/item/mod/module/hat_stabilizer/on_part_activation()
	return

/obj/item/mod/module/hat_stabilizer/on_part_deactivation(deleting = FALSE)
	return
