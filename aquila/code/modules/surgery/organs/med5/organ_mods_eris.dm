// AQUILA - drukowane ulepszenia narządów z CEV-Eris (AquilaMed 5, etap 12). Port pomysłu z Eris
// (code/modules/aberrants/organs/mods/5_upgrades.dm), sprite'y z Eris icons/obj/organ_mods.dmi (CC BY-SA 3.0).
// Ulepszenie wkłada się w narząd wyjęty z ciała (użyj go na narządzie), zwykły narząd mieści dwa.
// Różnice od Eris: nie mamy wydajności narządów, rozmiaru ani zapotrzebowania na krew i tlen (decyzja „bez wydajności”),
// więc „wydajność” to tu odporność narządu na uszkodzenia, a „zapotrzebowanie” to głód nosiciela i gnicie narządu.
// Hemostat wyjmuje ulepszenia z wyjętego narządu, poza komórkami macierzystymi i żelem (jak w Eris). Drukuje je protolathe medyczny po badaniu cybernetycznych narządów.

#define AQ_ORGAN_MOD_SLOTS 2

/obj/item/organ
	/// Eris upgrades in this organ (types)
	var/list/aq_mods
	/// How many upgrades still fit
	var/aq_mod_slots = AQ_ORGAN_MOD_SLOTS
	/// Damage taken is multiplied by this (organ "efficiency")
	var/aq_damage_mult = 1
	/// Hunger of the owner from this organ, per Life (symbiont, bypass)
	var/aq_hunger = 0
	/// Hidden from the health analyzer
	var/aq_scanner_hidden = FALSE

/obj/item/organ/applyOrganDamage(d, maximum = maxHealth)
	if(d > 0 && aq_damage_mult != 1)
		d *= aq_damage_mult
	return ..()

/// "Set exactly X" goes through applyOrganDamage(X - damage): it must not be scaled (a brain set to maxHealth must fail)
/obj/item/organ/setOrganDamage(d)
	var/mult = aq_damage_mult
	aq_damage_mult = 1
	. = ..()
	aq_damage_mult = mult

/obj/item/organ/on_life()
	. = ..()
	if(!aq_hunger || !owner || owner.stat == DEAD)
		return
	// A symbiont eats, bypass tubules only spare food: they slow hunger down, never feed past "fed"
	if(aq_hunger > 0)
		owner.adjust_nutrition(-aq_hunger)
	else if(owner.nutrition > 0 && owner.nutrition < NUTRITION_LEVEL_FED)
		owner.adjust_nutrition(-aq_hunger)

/obj/item/organ/examine(mob/user)
	. = ..()
	for(var/obj/item/aq_organ_mod/mod_type as anything in aq_mods)
		. += "<span class='notice'>Ulepszenie: [initial(mod_type.name)].</span>"

/obj/item/organ/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/aq_organ_mod))
		var/obj/item/aq_organ_mod/mod = I
		mod.try_apply(src, user)
		return TRUE
	if(I.tool_behaviour == TOOL_HEMOSTAT && LAZYLEN(aq_mods))
		aq_remove_mod(user)
		return TRUE
	return ..()

/// Eris: most upgrades come back out with a hemostat (not stem cells and gel); the last removable one goes first
/obj/item/organ/proc/aq_remove_mod(mob/user)
	if(owner)
		to_chat(user, "<span class='warning'>Najpierw wyjmij [src] z ciała.</span>")
		return FALSE
	for(var/i in length(aq_mods) to 1 step -1)
		var/obj/item/aq_organ_mod/mod_type = aq_mods[i]
		if(!initial(mod_type.removable))
			continue
		var/obj/item/aq_organ_mod/mod = new mod_type(drop_location())
		mod.unapply(src)
		aq_mods.Cut(i, i + 1)
		if(!mod.free_slot)
			aq_mod_slots++
		user.put_in_hands(mod)
		to_chat(user, "<span class='notice'>Wyjmujesz [mod.name] z [src].</span>")
		return TRUE
	to_chat(user, "<span class='warning'>Ulepszeń w [src] nie da się już wyjąć.</span>")
	return FALSE

/obj/item/aq_organ_mod
	name = "ulepszenie narządu"
	icon = 'aquila/icons/obj/medical/organ_mods_eris.dmi'
	w_class = WEIGHT_CLASS_TINY
	/// Takes no slot (the gel adds them)
	var/free_slot = FALSE
	/// Comes back out with a hemostat (as in Eris: not stem cells and gel)
	var/removable = TRUE

/obj/item/aq_organ_mod/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Użyj na narządzie wyjętym z ciała. Zwykły narząd mieści dwa ulepszenia. [removable ? "Hemostat wyjmuje je z powrotem." : "Tego ulepszenia nie da się wyjąć."]</span>"

/obj/item/aq_organ_mod/proc/try_apply(obj/item/organ/organ, mob/user)
	if(organ.owner)
		to_chat(user, "<span class='warning'>Najpierw wyjmij [organ] z ciała.</span>")
		return FALSE
	if(type in organ.aq_mods)
		to_chat(user, "<span class='warning'>[organ] ma już [name].</span>")
		return FALSE
	if(!free_slot && organ.aq_mod_slots <= 0)
		to_chat(user, "<span class='warning'>W [organ] nie zmieści się więcej ulepszeń.</span>")
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	if(!free_slot)
		organ.aq_mod_slots--
	LAZYADD(organ.aq_mods, type)
	apply(organ)
	to_chat(user, "<span class='notice'>Wkładasz [name] w [organ].</span>")
	qdel(src)
	return TRUE

/// What the upgrade does to the organ
/obj/item/aq_organ_mod/proc/apply(obj/item/organ/organ)
	return

/// Undoes apply() when the upgrade is taken out
/obj/item/aq_organ_mod/proc/unapply(obj/item/organ/organ)
	return

/obj/item/aq_organ_mod/capillaries
	name = "ulepszone naczynia włosowate"
	desc = "Zmodyfikowane naczynia, które lepiej odżywiają narząd. Narząd poza ciałem gnije o połowę wolniej."
	icon_state = "capillary"

/obj/item/aq_organ_mod/capillaries/apply(obj/item/organ/organ)
	organ.decay_factor *= 0.5

/obj/item/aq_organ_mod/capillaries/unapply(obj/item/organ/organ)
	organ.decay_factor /= 0.5

/obj/item/aq_organ_mod/durable
	name = "błona trwała"
	desc = "Mocniejsza błona: narząd znosi o 20% więcej obrażeń, zanim przestanie działać."
	icon_state = "mucous_membrane"

/obj/item/aq_organ_mod/durable/apply(obj/item/organ/organ)
	organ.maxHealth *= 1.2
	organ.low_threshold *= 1.2
	organ.high_threshold *= 1.2
	if((organ.organ_flags & ORGAN_FAILING) && organ.damage < organ.maxHealth)
		organ.organ_flags &= ~ORGAN_FAILING

/obj/item/aq_organ_mod/durable/unapply(obj/item/organ/organ)
	organ.maxHealth /= 1.2
	organ.low_threshold /= 1.2
	organ.high_threshold /= 1.2
	// The thinner membrane fails again; set by hand, applyOrganDamage ignores damage already at or above the cap
	if(organ.damage >= organ.maxHealth)
		organ.damage = organ.maxHealth
		organ.organ_flags |= ORGAN_FAILING

/obj/item/aq_organ_mod/stem_cells
	name = "komórki macierzyste"
	desc = "Grudka komórek macierzystych, które na stałe wzmacniają narząd: obrażenia trafiają go o 10% słabiej, a sam leczy się szybciej."
	icon_state = "stem_cells"

/obj/item/aq_organ_mod/stem_cells
	removable = FALSE

/obj/item/aq_organ_mod/stem_cells/apply(obj/item/organ/organ)
	organ.aq_damage_mult *= 0.9
	organ.healing_factor *= 1.5

/obj/item/aq_organ_mod/symbiont
	name = "symbiont trzewny"
	desc = "Pijawkowate stworzenie, które przyczepia się do narządu i wspiera jego pracę: obrażenia trafiają go o 20% słabiej, ale nosiciel szybciej głodnieje."
	icon_state = "symbiont"

/obj/item/aq_organ_mod/symbiont/apply(obj/item/organ/organ)
	organ.aq_damage_mult *= 0.8
	organ.aq_hunger += 0.03

/obj/item/aq_organ_mod/symbiont/unapply(obj/item/organ/organ)
	organ.aq_damage_mult /= 0.8
	organ.aq_hunger -= 0.03

/obj/item/aq_organ_mod/bypass
	name = "kanaliki bocznikujące"
	desc = "Kanaliki odprowadzające krew z narządu: nosiciel wolniej głodnieje, ale narząd jest o 20% wrażliwszy na obrażenia."
	icon_state = "tubules"

/obj/item/aq_organ_mod/bypass/apply(obj/item/organ/organ)
	organ.aq_damage_mult *= 1.2
	organ.aq_hunger -= 0.03

/obj/item/aq_organ_mod/bypass/unapply(obj/item/organ/organ)
	organ.aq_damage_mult /= 1.2
	organ.aq_hunger += 0.03

/obj/item/aq_organ_mod/gel
	name = "żel biostrukturalny"
	desc = "Żel, który zastyga w tkankę narządu i robi miejsce na dwa kolejne ulepszenia. Nie zajmuje miejsca."
	icon_state = "advanced_collagen"
	free_slot = TRUE

/obj/item/aq_organ_mod/gel
	removable = FALSE

/obj/item/aq_organ_mod/gel/apply(obj/item/organ/organ)
	organ.aq_mod_slots += 2

/obj/item/aq_organ_mod/masking
	name = "błona maskująca"
	desc = "Zewnętrzna błona, która pochłania fale skanerów medycznych: analizator nie widzi uszkodzeń narządu, a sam narząd jest o 10% wrażliwszy."
	icon_state = "stealth_composites"

/// The analyzer reads the brain, eyes and ears in their own sections, so the membrane would hide nothing there
/obj/item/aq_organ_mod/masking/try_apply(obj/item/organ/organ, mob/user)
	if(istype(organ, /obj/item/organ/brain) || istype(organ, /obj/item/organ/eyes) || istype(organ, /obj/item/organ/ears))
		to_chat(user, "<span class='warning'>[name] nie przylega do [organ]: analizator i tak bada go osobno.</span>")
		return FALSE
	return ..()

/obj/item/aq_organ_mod/masking/apply(obj/item/organ/organ)
	organ.aq_damage_mult *= 1.1
	organ.aq_scanner_hidden = TRUE

/obj/item/aq_organ_mod/masking/unapply(obj/item/organ/organ)
	organ.aq_damage_mult /= 1.1
	organ.aq_scanner_hidden = FALSE

/datum/design/aq_organ_mod
	build_type = PROTOLATHE
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_organ_mod/capillaries
	name = "Ulepszone naczynia włosowate"
	desc = "Ulepszenie narządu: wolniejsze gnicie poza ciałem."
	id = "aq_organ_mod_capillaries"
	materials = list(/datum/material/glass = 200, /datum/material/silver = 100)
	build_path = /obj/item/aq_organ_mod/capillaries

/datum/design/aq_organ_mod/durable
	name = "Błona trwała"
	desc = "Ulepszenie narządu: więcej wytrzymałości."
	id = "aq_organ_mod_durable"
	materials = list(/datum/material/iron = 200, /datum/material/plastic = 300)
	build_path = /obj/item/aq_organ_mod/durable

/datum/design/aq_organ_mod/stem_cells
	name = "Komórki macierzyste"
	desc = "Ulepszenie narządu: odporność i szybsze leczenie."
	id = "aq_organ_mod_stem_cells"
	materials = list(/datum/material/glass = 300, /datum/material/gold = 200)
	build_path = /obj/item/aq_organ_mod/stem_cells

/datum/design/aq_organ_mod/symbiont
	name = "Symbiont trzewny"
	desc = "Ulepszenie narządu: duża odporność za cenę głodu."
	id = "aq_organ_mod_symbiont"
	materials = list(/datum/material/glass = 300, /datum/material/uranium = 200)
	build_path = /obj/item/aq_organ_mod/symbiont

/datum/design/aq_organ_mod/bypass
	name = "Kanaliki bocznikujące"
	desc = "Ulepszenie narządu: mniej głodu za cenę wrażliwości."
	id = "aq_organ_mod_bypass"
	materials = list(/datum/material/glass = 200, /datum/material/plastic = 200)
	build_path = /obj/item/aq_organ_mod/bypass

/datum/design/aq_organ_mod/gel
	name = "Żel biostrukturalny"
	desc = "Ulepszenie narządu: miejsce na dwa kolejne ulepszenia."
	id = "aq_organ_mod_gel"
	materials = list(/datum/material/plastic = 500, /datum/material/diamond = 100)
	build_path = /obj/item/aq_organ_mod/gel

/datum/design/aq_organ_mod/masking
	name = "Błona maskująca"
	desc = "Ulepszenie narządu: ukrywa uszkodzenia przed analizatorem."
	id = "aq_organ_mod_masking"
	materials = list(/datum/material/glass = 300, /datum/material/bluespace = 100)
	build_path = /obj/item/aq_organ_mod/masking

/datum/techweb_node/cyber_organs/New()
	. = ..()
	design_ids += list("aq_organ_mod_capillaries", "aq_organ_mod_durable", "aq_organ_mod_stem_cells", "aq_organ_mod_symbiont", "aq_organ_mod_bypass", "aq_organ_mod_gel", "aq_organ_mod_masking")

#undef AQ_ORGAN_MOD_SLOTS
