// Kończyny ras o innej sylwetce niż ludzka pod ubraniem. Stroje są rysowane na ludzki obrys, więc długie ręce mięsoczłowieka,
// pnącza diony czy szeroki pancerz Akwarianina wystawały spod rękawów i skafandrów. Gdy ubranie zakrywa część ciała,
// ta część rysuje się przycięta do kształtu ludzkiej (icons/mob/human_parts_greyscale.dmi). Dłonie przycina dopiero strój wierzchni.

/datum/species
	/// Przycinać kończyny zakryte ubraniem do ludzkiego obrysu (rasy, których ciało wystaje poza ludzkie stroje)
	var/clip_limbs_under_clothes = FALSE

/datum/species/beefman
	clip_limbs_under_clothes = TRUE

/datum/species/diona
	clip_limbs_under_clothes = TRUE

/datum/species/aquarian
	clip_limbs_under_clothes = TRUE

/// Ikona części ciała przycięta do ludzkiego kształtu tej części, we wszystkich kierunkach; liczona raz na stan
/proc/aq_clipped_limb_icon(icon_file, state, mask_state)
	var/static/list/cache = list()
	var/key = "[icon_file]|[state]|[mask_state]"
	if(cache[key])
		return cache[key]
	if(!icon_exists(icon_file, state) || !icon_exists('icons/mob/human_parts_greyscale.dmi', mask_state))
		return null
	var/icon/limb = icon(icon_file, state)
	var/icon/mask = icon('icons/mob/human_parts_greyscale.dmi', mask_state)
	mask.Blend("#ffffff", ICON_ADD) // biała maska: mnożenie zostawia kolor kończyny, a zeruje przezroczystość poza ludzkim kształtem
	limb.Blend(mask, ICON_MULTIPLY)
	cache[key] = limb
	return limb

/// Czy ubranie zakrywa tę kończynę (dla dłoni: czy strój wierzchni zakrywa rękę)
/obj/item/bodypart/proc/aq_covered_by_clothes(hand = FALSE)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !H.dna?.species?.clip_limbs_under_clothes)
		return FALSE
	// Manekiny podglądu (ikony ras w oknie postaci) rysują się bez przycinania: arkusz ikon ras przy starcie serwera
	// odrzucał podgląd z przyciętymi kończynami (bad icon operation)
	if(istype(H, /mob/living/carbon/human/dummy))
		return FALSE
	var/obj/item/clothing/suit = H.wear_suit
	if(hand)
		return istype(suit) && (suit.body_parts_covered & body_part)
	var/obj/item/clothing/uniform = H.w_uniform
	return (istype(uniform) && (uniform.body_parts_covered & body_part)) || (istype(suit) && (suit.body_parts_covered & body_part))

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(dropped || is_husked || !length(.))
		return
	var/covered = aq_covered_by_clothes()
	var/hand_covered = aux_zone && aq_covered_by_clothes(TRUE)
	if(!covered && !hand_covered)
		return
	var/limb_state = "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]"
	var/aux_state = aux_zone ? "[limb_id]_[aux_zone]" : null
	for(var/image/part in .)
		var/mask_state
		// Prefiks: razem z kończyną przycinamy jej nakładki w tym samym pliku (np. farbę pancerza Akwarianina „..._paint”)
		if(covered && findtext(part.icon_state, limb_state) == 1)
			mask_state = (body_zone == BODY_ZONE_CHEST || body_zone == BODY_ZONE_HEAD) ? "human_[body_zone]_m" : "human_[body_zone]"
		else if(hand_covered && findtext(part.icon_state, aux_state) == 1)
			mask_state = "human_[aux_zone]"
		if(!mask_state)
			continue
		var/icon/clipped = aq_clipped_limb_icon(part.icon, part.icon_state, mask_state)
		if(clipped)
			part.icon = clipped
			part.icon_state = "" // icon(plik, stan) zostawia jeden stan bez nazwy

/// Inne przycięcie = inna ikona kończyny w pamięci podręcznej
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(BP.aq_covered_by_clothes())
		. += "-clip"
	if(BP.aux_zone && BP.aq_covered_by_clothes(TRUE))
		. += "-cliphand"

/mob/living/carbon/human/update_inv_w_uniform()
	. = ..()
	if(dna?.species?.clip_limbs_under_clothes)
		update_body_parts()

/mob/living/carbon/human/update_inv_wear_suit()
	. = ..()
	if(dna?.species?.clip_limbs_under_clothes)
		update_body_parts()
