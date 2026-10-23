// aq33/AquilaStation#382 - bugfixy: podnoszenie ludzi (fireman carry, na barana), automatyczna fabryka amunicji

/datum/test_chamber_kit/pr_382_carry
	name = "PR 382: podnoszenie ludzi"
	pr = "aq33/AquilaStation#382"
	description = "Na plecy: połóż człowieka testowego, chwyć go agresywnie (intent grab), przeciągnij go na siebie - po 5 s ma wylądować na twoich plecach (wcześniej nic się nie działo). \
	W lateksowych rękawiczkach ma to trwać 4 s, w nitrylowych 3 s. Na barana: drugi człowiek trzyma cię agresywnym chwytem, przeciągasz siebie na niego (dwie wolne ręce, 1,5 s). \
	Porażka ma dawać komunikat."
	items = list(
		/mob/living/carbon/human = 2,
		/obj/item/clothing/gloves/color/latex = 1,
		/obj/item/clothing/gloves/color/latex/nitrile = 1,
	)

/datum/test_chamber_kit/pr_382_missile_builder
	name = "PR 382: fabryka amunicji (aplikator)"
	pr = "aq33/AquilaStation#382"
	description = "Aplikator części patrzy na pole przed sobą (alt-klik obraca, z daleka ma nic nie robić i nie psuć ramienia). Włóż ręcznie część (bez uderzania maszyny), \
	albo przeciągnij skrzynię z częściami na aplikator (wcześniej nie działało). Magazyn jest mieszany - głowica torpedy nie pasuje do pocisku i nie może blokować linii. \
	Wpychaj obudowę pocisku na pole przed ramieniem: ma kolejno wkładać pasujące części; examine obudowy pokazuje włożone części, ręczne dokończenie działa. \
	Części rzucone na pole przed ramieniem ma zbierać do magazynu. Kartą amunicji wysypujesz magazyn."
	items = list(
		/obj/machinery/missile_builder/assembler = 1,
		/obj/item/ship_weapon/ammunition/missile/missile_casing = 2,
		/obj/structure/closet/crate = 1,
		/obj/item/ship_weapon/parts/missile/warhead = 1,
		/obj/item/card/id/job/munitions_technician = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/weldingtool = 1,
		/obj/item/stack/cable_coil = 1,
	)

/datum/test_chamber_kit/pr_382_missile_builder/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/closet/crate/crate = locate() in spawned
	if(!crate)
		return
	crate.name = "części pocisków"
	for(var/part_type in list(
		/obj/item/ship_weapon/parts/missile/warhead/torpedo,
		/obj/item/ship_weapon/parts/missile/warhead, /obj/item/ship_weapon/parts/missile/warhead,
		/obj/item/ship_weapon/parts/missile/guidance_system, /obj/item/ship_weapon/parts/missile/guidance_system,
		/obj/item/ship_weapon/parts/missile/propulsion_system, /obj/item/ship_weapon/parts/missile/propulsion_system,
		/obj/item/ship_weapon/parts/missile/iff_card, /obj/item/ship_weapon/parts/missile/iff_card,
	))
		new part_type(crate)
