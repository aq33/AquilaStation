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
				if(ispath(thing, /obj/item/clothing/under))
					var/obj/item/clothing/under/uniform = thing
					if(initial(uniform.can_adjust) && !("[state]_d" in icon_states(worn_file)))
						missing += "[thing]: podwinięty '[state]_d' w [worn_file]"
	TEST_ASSERT(checked >= 30, "Sprawdzono tylko [checked] typów z aquila/icons/dowodztwo/")
	TEST_ASSERT(!length(missing), "Brakujące stany po resprite dowództwa: [jointext(missing, "; ")]")

	var/mob/living/carbon/human/captain = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	captain.equipOutfit(/datum/outfit/job/captain, TRUE)
	TEST_ASSERT(istype(captain.w_uniform, /obj/item/clothing/under/rank/captain), "Kapitan startuje w [captain.w_uniform?.type]")
	TEST_ASSERT(istype(captain.wear_suit, /obj/item/clothing/suit/ship/officer/captain), "Kapitan startuje w kurtce [captain.wear_suit?.type]")

	var/obj/structure/closet/secure_closet/bridge/locker = allocate(/obj/structure/closet/secure_closet/bridge, run_loc_floor_bottom_left)
	TEST_ASSERT(locate(/obj/item/clothing/head/beret/durathread/bridge) in locker, "W szafce mostka brak beretu Oficera Pokładowego")
	for(var/obj/item/clothing/head/beret/durathread/beret in locker)
		TEST_ASSERT(beret.type == /obj/item/clothing/head/beret/durathread/bridge, "W szafce mostka został zwykły beret z duranici")

#undef TEST_ASSERT
