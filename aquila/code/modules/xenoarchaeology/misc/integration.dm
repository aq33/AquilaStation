// Zaczepienia xenoarch z Bee (BeeStation/BeeStation-Hornet#10906) w kodzie, którego nie ruszamy bezpośrednio.

/obj/item/clothing/suit/hooded/cultrobes/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)

/obj/item/discovery_scanner/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)

/*
	Odpowiednik discoverable dla artefaktów
	patrzy na cechy artefaktu
*/
/datum/component/discoverable/artifact

/datum/component/discoverable/artifact/discovery_scan(datum/techweb/linked_techweb, mob/user)
	//Already scanned our atom.
	var/atom/atom_parent = parent
	if(scanned)
		to_chat(user, "<span class='warning'>[atom_parent] został już przeanalizowany.</span>")
		return
	//Is it *even* an artifact
	var/datum/component/xenoartifact/artifact_datum = atom_parent.GetComponent(/datum/component/xenoartifact)
	if(!artifact_datum)
		return
	//Loop through artfact traits
	var/total_payout = 0
	var/discovered_trait_count = 0
	for(var/trait in artifact_datum.traits_catagories)
		for(var/datum/xenoartifact_trait/trait_datum as anything in artifact_datum.traits_catagories[trait])
			//Already scanned another of this type.
			var/discover_id = trait_datum.type
			if(!unique && linked_techweb.scanned_atoms[discover_id])
				continue
			if(atom_parent.flags_1 & HOLOGRAM_1)
				continue
			total_payout += trait_datum.discovery_reward
			discovered_trait_count++
			linked_techweb.scanned_atoms[discover_id] = TRUE
	scanned = TRUE
	if(total_payout)
		linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, total_payout)
		playsound(user, 'sound/machines/terminal_success.ogg', 60)
		to_chat(user, "<span class='notice'>Zeskanowano nowy punkt danych, zdobyto [total_payout] punktów odkryć.\nOdkryte nowe cechy: [discovered_trait_count]!</span>")
		pulse_effect(get_turf(atom_parent), 4)
	else
		playsound(user, 'sound/machines/uplinkerror.ogg', 60)
		to_chat(user, "<span class='warning'>W [atom_parent] nie wykryto nowych cech.</span>")

/// Cząsteczka jądrowa w trycie zamienia przedmioty w sztuczne artefakty (perły)
/obj/item/projectile/energy/nuclear_particle/scan_moved_turf()
	. = ..()
	//Do a gas check first
	var/turf/turf = get_turf(src)
	var/datum/gas_mixture/air = turf?.return_air()
	if(!air)
		return
	if(air.get_moles(GAS_TRITIUM) < MOLES_GAS_VISIBLE)
		return
	for(var/obj/item/item in loc)
		if(!prob(33))
			continue
		//Proceed with artifact logic
		if(item.GetComponent(/datum/component/xenoartifact))
			continue
		//Check for any pearls attached to the item first
		var/list/trait_list
		for(var/obj/item/sticker/trait_pearl/pearl in item.contents)
			LAZYADD(trait_list, pearl.stored_trait)
			qdel(pearl)
		//Make the item an artifact
		item.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material/pearl, trait_list, TRUE, FALSE)
		playsound(item, 'sound/magic/staff_change.ogg', 50, TRUE)
		qdel(src)
		break

/// Sprzedawalne przez cargo mimo czarnej listy (świadomy artefakt)
GLOBAL_LIST_INIT(whitelisted_cargo_types, typecacheof(list(
	/obj/effect/mob_spawn/sentient_artifact,
	/mob/living/simple_animal/shade/sentience
)))

/obj/structure/sign/poster/official/xenoarchaeology
	name = "Ksenoarcheologia"
	desc = "Plakat z kilkoma schematami artefaktów.\
	\n\
	Artefakty można opisać etykietą i sprzedać przez cargo, zdobywając punkty badań i odkryć.\n\
	Źle opisane artefakty dają mniejsze nagrody niż trafnie opisane."
	icon = 'icons/obj/xenoarchaeology/xenoartifact_poster.dmi'
	icon_state = "poster52"

/obj/structure/sign/poster/official/xenoarchaeology_pearl
	name = "???"
	desc = "Plakat z artefaktem, którego nie rozpoznajesz.\
	\n\
	Legenda głosi, że artefakty można stworzyć, trafiając przedmioty cząsteczkami jądrowymi, gdy leżą w trycie. \
	Mówi też, że ustabilizowane artefakty zachowują się dziwnie, gdy ułoży się je na pewnych siatkach, \
	zależnych od właściwości ich cech."
	icon = 'icons/obj/xenoarchaeology/xenoartifact_poster.dmi'
	icon_state = "poster52"

/atom
	/// Cena artefaktu przy sprzedaży przez cargo (w Bee: item_price na każdym atomie)
	var/item_price

/// Przemiana celu w zwierzę (Bestialized). U nas zamiast statusu Bee jest stary /obj/shapeshift_holder.
/proc/artifact_shapeshift(mob/living/target, shape_type)
	if(locate(/obj/shapeshift_holder) in target)
		return
	var/mob/living/shape = new shape_type(get_turf(target))
	new /obj/shapeshift_holder/artifact(shape, null, target)
	return shape

/// Holder bez zaklęcia źródłowego - oryginalne casterDeath odwołuje się do source
/obj/shapeshift_holder/artifact

/// Bez darmowego pełnego leczenia przy powrocie (oryginalne restore robi revive(full_heal))
/obj/shapeshift_holder/artifact/restore(death = FALSE, convert_damage = FALSE)
	if(!stored)
		return FALSE
	restoring = TRUE
	qdel(slink)
	stored.forceMove(get_turf(src))
	stored.notransform = FALSE
	if(shape.mind)
		shape.mind.transfer_to(stored)
	if(death)
		stored.death()
	if(!QDELETED(shape))
		qdel(shape)
	qdel(src)

/obj/shapeshift_holder/artifact/casterDeath()
	restore(death = TRUE)

/obj/shapeshift_holder/artifact/shapeDeath(death = TRUE)
	restore(death = death)

/// Karaluch odporny na rozdeptanie (forma z Bestialized Δ)
/mob/living/simple_animal/cockroach/strong
	squish_chance = 0

/// Wygłodzony niedźwiedź z Bee - przywoływany przez wadliwy artefakt
/mob/living/simple_animal/hostile/bear/malnourished
	name = "starving space bear"
	desc = "You can practically see its ribcage through its thinning layer of fur. Looks like it hasn't eaten anything in a long while."
	maxHealth = 60
	health = 40
	obj_damage = 30
	melee_damage = 10

/// Leczenie jednego typu obrażeń (Bee: /mob/living/proc/heal_damage_type)
/proc/artifact_heal_damage_type(mob/living/victim, amount, damage_type)
	switch(damage_type)
		if(BRUTE)
			victim.adjustBruteLoss(-amount)
		if(BURN)
			victim.adjustFireLoss(-amount)
		if(TOX)
			victim.adjustToxLoss(-amount, forced = TRUE)
		if(OXY)
			victim.adjustOxyLoss(-amount)
		if(CLONE)
			victim.adjustCloneLoss(-amount)
		if(STAMINA)
			victim.adjustStaminaLoss(-amount)
