/datum/rune_spell/summonrobes
	name = "Przywołanie Szat"
	desc = "Zamień ubranie na szaty wyznawców Nar-Sie. Znacznie zwiększa skuteczność niektórych rytuałów. Daje tesserakt, którym od razu wrócisz do starego ubrania."
	desc_talisman = "Zamień ubranie na szaty wyznawców Nar-Sie. Znacznie zwiększa skuteczność niektórych rytuałów. Daje tesserakt, którym od razu wrócisz do starego ubrania. Użycie tesseraktu odda ci też talizman, jeśli zostały mu użycia."
	invocation = "Sa tatha najin"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/destroy
	word3 = /datum/rune_word/other
	talisman_uses = 5
	page = "Ta runa, na której musisz stać, ubiera cię w strój kultu: kaptur, szaty, buty, rękawice i plecak.\
		<br><br>Strój kultu przyspiesza rytuały Konwersji i Wzniesienia Budowli, a kaptur można naciągnąć, by ukryć twarz i głos, co daje słodką anonimowość (o ile nie zapomnisz schować identyfikatora).\
		<br><br>Po użyciu runy w twojej dłoni pojawia się Krwawy Tesserakt z ubraniami, które musiały zostać zdjęte, bo miałeś je już na sobie. \
		Możesz go użyć, by od razu odzyskać ubranie, albo rzucić nim, by go rozbić i odzyskać zawartość.\
		<br><br>Talizman ma 5 użyć i wraca do twojej dłoni, gdy użyjesz Krwawego Tesseraktu. Zawartość plecaka zawsze zostaje przeniesiona.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	var/list/slots_to_store = list(
		ITEM_SLOT_FEET,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_BACK,
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_ICLOTHING,
		)

/datum/rune_spell/summonrobes/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()


	var/list/potential_targets = list()
	var/turf/TU = get_turf(spell_holder)

	for(var/mob/living/carbon/C in TU)
		potential_targets += C
	if(potential_targets.len == 0)
		to_chat(activator, span_warning("Na runie musi ktoś stać albo leżeć.") )
		qdel(src)
		return
	var/mob/living/carbon/target
	if(activator in potential_targets)
		target = activator
	else
		target = pick(potential_targets)

	if (!ishuman(target) && !ismonkey(target))
		qdel(src)
		return

	anim(target = target, a_icon = 'aquila/icons/bloodcult/64x64.dmi', flick_anim = "rune_robes", offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	cult_datum?.gain_devotion(50, DEVOTION_TIER_0, "summon_robes", target)

	var/obj/item/weapon/blood_tesseract/BT = new(get_turf(activator))
	if (istype (spell_holder, /obj/item/talisman))
		var/obj/item/talisman/T = spell_holder
		if (!T.linked_ui)
			activator.dropItemToGround(spell_holder)
			if (T.uses > 1)
				BT.remaining = spell_holder
				spell_holder.forceMove(BT)

	for(var/slot in slots_to_store)
		var/obj/item/user_slot = target.get_item_by_slot(slot)
		if (user_slot)
			BT.stored_gear["[slot]"] = user_slot

	//looping again in case the suit had a stored item
	for(var/slot in BT.stored_gear)
		var/obj/item/user_slot = BT.stored_gear[slot]
		target.dropItemToGround(user_slot)
		user_slot.forceMove(BT)

	// AQUILA - w drafcie zakładanie było w pętli wyżej (po razie na każdy zdjęty slot), w vg po niej
	target.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(target), ITEM_SLOT_ICLOTHING)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(target), ITEM_SLOT_OCLOTHING)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(target), ITEM_SLOT_FEET)
	target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black/cult(target), ITEM_SLOT_GLOVES)

	//transferring backpack items
	var/obj/item/storage/backpack/cultpack/new_pack = new (target)
	if (("[ITEM_SLOT_BACK]" in BT.stored_gear))
		var/obj/item/stored_slot = BT.stored_gear["[ITEM_SLOT_BACK]"]
		if (istype (stored_slot, /obj/item/storage/backpack))
			for(var/obj/item/I in stored_slot.contents)
				I.forceMove(new_pack)
	if (!target.equip_to_slot_if_possible(new_pack, ITEM_SLOT_BACK))
		new_pack.forceMove(get_turf(target))

	activator.put_in_hands(BT)
	target.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(target))
	if(IS_CULTIST(target))
		to_chat(target, span_notice("Wokół twojego ciała materializują się szaty i rynsztunek wyznawców Nar-Sie. Czujesz przypływ mocy.") )
	else
		to_chat(target, span_warning("Wokół twojego ciała materializują się szaty i rynsztunek wyznawców Nar-Sie. Robi ci się niedobrze.") )
	to_chat(activator, span_notice("W twojej dłoni pojawia się [BT]. Możesz go użyć, by od razu wrócić do schowanego ubrania.") )
	qdel(src)
