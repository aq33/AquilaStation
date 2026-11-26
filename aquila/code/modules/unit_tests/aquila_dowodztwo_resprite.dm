// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - resprite dowództwa: każdy typ (i podtyp) z plików aquila/icons/dowodztwo/ ma swój stan w przedmiocie i na postaci
/datum/unit_test/aquila_dowodztwo_resprite

/datum/unit_test/aquila_dowodztwo_resprite/Run()
	var/list/roots = list(
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/rank/civilian/head_of_personnel,
		/obj/item/clothing/under/ship/officer,
		/obj/item/clothing/suit/captunic,
		/obj/item/clothing/suit/armor/vest/capcarapace,
		/obj/item/clothing/suit/space/hardsuit/swat/captain,
		/obj/item/clothing/suit/ship/officer,
		/obj/item/clothing/suit/hooded/wintercoat,
		/obj/item/clothing/head/hooded/winterhood,
		/obj/item/clothing/head/caphat,
		/obj/item/clothing/head/beret/captain,
		/obj/item/clothing/head/beret/ship/captain,
		/obj/item/clothing/head/beret/ship/xo,
		/obj/item/clothing/head/hopcap,
		/obj/item/clothing/head/helmet/space/hardsuit/swat/captain,
		/obj/item/clothing/head/beret/durathread,
		/obj/item/clothing/gloves/color/captain,
		/obj/item/clothing/neck/cloak,
		/obj/item/storage/backpack/satchel/cap,
		/obj/item/card/id,
		/obj/item/modular_computer/tablet/pda/heads,
		/obj/structure/closet/secure_closet,
	)
	var/list/missing = list()
	var/checked = 0
	for(var/root in roots)
		for(var/obj/thing as anything in typesof(root))
			var/icon_file = initial(thing.icon)
			if(!findtext("[icon_file]", "aquila/icons/dowodztwo/"))
				continue
			checked++
			var/state = initial(thing.icon_state)
			if(!(state in icon_states(icon_file)))
				missing += "[thing]: '[state]' w [icon_file]"
			if(ispath(thing, /obj/item/clothing))
				var/obj/item/clothing/cloth = thing
				var/worn_file = initial(cloth.worn_icon)
				var/worn_state = ispath(thing, /obj/item/clothing/under) ? state : (initial(cloth.worn_icon_state) || state)
				if(!worn_file || !(worn_state in icon_states(worn_file)))
					missing += "[thing]: na postaci '[worn_state]' w [worn_file]"
				if(ispath(thing, /obj/item/clothing/suit/hooded) && !(("[state]_t" in icon_states(icon_file)) && ("[state]_t" in icon_states(worn_file))))
					missing += "[thing]: rozpięta '[state]_t' w [icon_file] lub [worn_file]"
				if(ispath(thing, /obj/item/clothing/suit/hooded/wintercoat))
					var/obj/item/clothing/suit/hooded/wintercoat/coat = thing
					var/hood_down = initial(coat.hood_down_state)
					if(!hood_down || !(hood_down in icon_states(initial(coat.hood_down_icon))))
						missing += "[thing]: opuszczony kaptur '[hood_down]' w [initial(coat.hood_down_icon)]"
				if(ispath(thing, /obj/item/clothing/under))
					var/obj/item/clothing/under/uniform = thing
					if(initial(uniform.can_adjust) && !("[state]_d" in icon_states(worn_file)))
						missing += "[thing]: podwinięty '[state]_d' w [worn_file]"
	TEST_ASSERT(checked >= 30, "Sprawdzono tylko [checked] typów z aquila/icons/dowodztwo/")
	TEST_ASSERT(!length(missing), "Brakujące stany po resprite dowództwa: [jointext(missing, "; ")]")

	var/mob/living/carbon/human/captain = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	captain.equipOutfit(/datum/outfit/job/captain, TRUE)
	TEST_ASSERT(captain.w_uniform?.type == /obj/item/clothing/under/rank/captain, "Kapitan startuje w [captain.w_uniform?.type]")
	TEST_ASSERT(captain.wear_suit?.type == /obj/item/clothing/suit/armor/vest/capcarapace, "Kapitan startuje w [captain.wear_suit?.type] zamiast napierśnika")
	TEST_ASSERT(captain.head?.type == /obj/item/clothing/head/caphat, "Kapitan startuje w [captain.head?.type] zamiast czapki kapitana")

	// Pudełka kompresyjne: dokładnie nowy zestaw, bez rzeczy z kieszeniami (storage w pudełku kompresyjnym)
	var/list/boxes = list(
		/obj/item/storage/box/suitbox/cap = list(/obj/item/clothing/under/rank/captain, /obj/item/clothing/under/rank/captain/suit, /obj/item/clothing/head/caphat, /obj/item/clothing/head/caphat/parade, /obj/item/clothing/head/caphat/officer, /obj/item/clothing/head/beret/captain),
		/obj/item/storage/box/suitbox/hop = list(/obj/item/clothing/under/rank/civilian/head_of_personnel, /obj/item/clothing/head/hopcap, /obj/item/clothing/head/beret/ship/xo),
		/obj/item/storage/box/suitbox/hos = list(/obj/item/clothing/under/rank/security/head_of_security, /obj/item/clothing/under/rank/security/head_of_security/alt, /obj/item/clothing/head/HoS, /obj/item/clothing/head/HoS/beret, /obj/item/clothing/head/beret/sec/navyhos),
	)
	for(var/box_type in boxes)
		var/obj/item/storage/box/box = allocate(box_type, run_loc_floor_bottom_left)
		var/list/found = list()
		for(var/obj/item/thing as anything in box)
			found += thing.type
			TEST_ASSERT(!thing.GetComponent(/datum/component/storage), "[thing.type] w [box_type] ma własny schowek")
		var/list/wanted = boxes[box_type]
		TEST_ASSERT(length(found) == length(wanted) && !length(found - wanted), "[box_type] zawiera [jointext(found, ", ")]")

	// Peleryna na postaci przykrywa plecak
	captain.equip_to_slot_or_del(allocate(/obj/item/clothing/neck/cloak/cap, run_loc_floor_bottom_left), ITEM_SLOT_NECK)
	TEST_ASSERT(captain.back && captain.wear_neck, "Kapitan bez plecaka albo peleryny")
	var/mutable_appearance/back_overlay = captain.overlays_standing[BACK_LAYER]
	var/mutable_appearance/neck_overlay = captain.overlays_standing[NECK_LAYER]
	TEST_ASSERT(back_overlay && neck_overlay && neck_overlay.layer > back_overlay.layer, "Peleryna rysuje się pod plecakiem (warstwy [neck_overlay?.layer] i [back_overlay?.layer])")

	// Kurtka zimowa: zapięcie zmienia stan, opuszczony kaptur rysuje się z naszego pliku
	var/obj/item/clothing/suit/hooded/wintercoat/xo/coat = allocate(/obj/item/clothing/suit/hooded/wintercoat/xo, run_loc_floor_bottom_left)
	coat.zip_open = TRUE
	coat.update_zip_icon()
	TEST_ASSERT(coat.icon_state == "coatxo_t", "Rozpięta kurtka XO ma stan [coat.icon_state]")
	var/hood_drawn = FALSE
	for(var/mutable_appearance/overlay as anything in coat.worn_overlays(null, FALSE))
		if(overlay.icon == coat.hood_down_icon && overlay.icon_state == coat.hood_down_state)
			hood_drawn = TRUE
	TEST_ASSERT(hood_drawn, "Na kurtce XO nie ma opuszczonego kaptura")

	var/obj/structure/closet/secure_closet/hop/xo_locker = allocate(/obj/structure/closet/secure_closet/hop, run_loc_floor_bottom_left)
	TEST_ASSERT(locate(/obj/item/clothing/suit/ship/officer/xo) in xo_locker, "W szafce Starszego Oficera brak zapasowej kurtki")
	TEST_ASSERT(locate(/obj/item/clothing/shoes/jackboots) in xo_locker, "W szafce Starszego Oficera brak butów wojskowych")
	TEST_ASSERT(locate(/obj/item/clothing/suit/hooded/wintercoat/xo) in xo_locker, "W szafce Starszego Oficera brak kurtki zimowej")

	var/obj/structure/closet/secure_closet/bridge/locker = allocate(/obj/structure/closet/secure_closet/bridge, run_loc_floor_bottom_left)
	TEST_ASSERT(locate(/obj/item/clothing/head/beret/durathread/bridge) in locker, "W szafce mostka brak beretu Oficera Pokładowego")
	TEST_ASSERT(locate(/obj/item/clothing/suit/hooded/wintercoat/bridge) in locker, "W szafce mostka brak kurtki zimowej")
	for(var/obj/item/clothing/head/beret/durathread/beret in locker)
		TEST_ASSERT(beret.type == /obj/item/clothing/head/beret/durathread/bridge, "W szafce mostka został zwykły beret z duranici")

#undef TEST_ASSERT
