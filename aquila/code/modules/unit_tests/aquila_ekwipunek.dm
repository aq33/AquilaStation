// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Czapka na hełmie hardsuitu: zakładanie, druga czapka, nakładka, zdejmowanie, czapka przez kombinezon
/datum/unit_test/aquila_hardsuit_hat

/datum/unit_test/aquila_hardsuit_hat/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human)
	var/obj/item/clothing/suit/space/hardsuit/engine/suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine)
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet = suit.helmet
	TEST_ASSERT(helmet, "Hardsuit nie ma hełmu")
	var/obj/item/clothing/head/beret/hat = allocate(/obj/item/clothing/head/beret)
	var/obj/item/clothing/head/that/second_hat = allocate(/obj/item/clothing/head/that)

	// czapka kliknięta w kombinezon trafia na schowany hełm
	wearer.put_in_hands(hat)
	suit.attackby(hat, wearer)
	TEST_ASSERT(helmet.attached_hat == hat && hat.loc == helmet, "Czapka kliknięta w kombinezon nie trafiła na hełm")
	var/overlays_with_hat = length(helmet.worn_overlays(null, FALSE))
	TEST_ASSERT(overlays_with_hat >= 1, "Hełm z czapką nie dodaje nakładki")

	// druga czapka się nie mieści
	wearer.put_in_hands(second_hat)
	helmet.attackby(second_hat, wearer)
	TEST_ASSERT(helmet.attached_hat == hat && second_hat.loc != helmet, "Druga czapka weszła na hełm z czapką")

	// hełm na hełmie nie przechodzi
	var/obj/item/clothing/head/helmet/space/eva = allocate(/obj/item/clothing/head/helmet/space)
	TEST_ASSERT(!helmet.can_attach_hat(eva), "Hełm kosmiczny dał się założyć jako czapka")

	// zdejmowanie
	TEST_ASSERT(helmet.detach_hat(wearer) == hat, "Zdjęcie czapki nie zwróciło czapki")
	TEST_ASSERT(!helmet.attached_hat && hat.loc != helmet, "Czapka została w hełmie po zdjęciu")
	TEST_ASSERT(length(helmet.worn_overlays(null, FALSE)) < overlays_with_hat, "Nakładka czapki została po zdjęciu")

/// Pasy z TGMC: co wchodzi do pasa amunicyjnego, przekładanie nabojów z pudełka
/datum/unit_test/aquila_tgmc_belts

/datum/unit_test/aquila_tgmc_belts/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/storage/belt/aq_tgmc/ammo/belt = allocate(/obj/item/storage/belt/aq_tgmc/ammo)
	var/datum/component/storage/STR = belt.GetComponent(/datum/component/storage)
	var/obj/item/ammo_box/magazine/m556/mag = allocate(/obj/item/ammo_box/magazine/m556)
	var/obj/item/storage/firstaid/regular/kit = allocate(/obj/item/storage/firstaid/regular)
	var/obj/item/ammo_box/magazine/nsv/light_cannon/shell = allocate(/obj/item/ammo_box/magazine/nsv/light_cannon)
	TEST_ASSERT(STR.can_be_inserted(mag, TRUE, user), "Magazynek nie wchodzi do pasa amunicyjnego")
	TEST_ASSERT(!STR.can_be_inserted(kit, TRUE, user), "Apteczka weszła do pasa amunicyjnego")
	TEST_ASSERT(!STR.can_be_inserted(shell, TRUE, user), "Pocisk działa okrętowego wszedł do pasa amunicyjnego")

	var/obj/item/storage/belt/aq_tgmc/shotgun/shotgun_belt = allocate(/obj/item/storage/belt/aq_tgmc/shotgun)
	var/obj/item/storage/box/lethalshot/box = allocate(/obj/item/storage/box/lethalshot)
	var/in_box = length(box.contents)
	TEST_ASSERT(in_box > 0, "Pudełko z nabojami jest puste")
	var/moved = shotgun_belt.refill_from(box, user)
	TEST_ASSERT(moved == in_box, "Przełożono [moved] z [in_box] nabojów")
	TEST_ASSERT(!length(box.contents) && length(shotgun_belt.contents) == in_box, "Naboje nie są w pasie po przełożeniu")
	// drugie pudełko: pas mieści 14, więc przechodzi tylko część
	var/obj/item/storage/box/lethalshot/box2 = allocate(/obj/item/storage/box/lethalshot)
	var/obj/item/storage/box/lethalshot/box3 = allocate(/obj/item/storage/box/lethalshot)
	shotgun_belt.refill_from(box2, user)
	shotgun_belt.refill_from(box3, user)
	TEST_ASSERT(length(shotgun_belt.contents) == 14, "Pas na naboje ma [length(shotgun_belt.contents)] zamiast 14 nabojów")
	TEST_ASSERT(length(box3.contents) == in_box * 3 - 14, "Nadmiarowe naboje zniknęły z pudełka")

#undef TEST_ASSERT
