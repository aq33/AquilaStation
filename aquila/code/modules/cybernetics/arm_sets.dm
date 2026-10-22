// Port cybernetyki z Monkestation (code/modules/cybernetics, autor Dwasint): nowe zestawy w ręce.
// U nas nie ma item_set, więc wszystko siedzi na zwykłym /obj/item/organ/cyberimp/arm (items_to_create).
// Przedmioty, których nie mamy, podmienione na najbliższe nasze (lista w raporcie PR).

/obj/item/organ/cyberimp/arm/cook
	name = "implant kuchenny"
	desc = "Zestaw przyborów kuchennych ukryty za maskowanym panelem w ręce."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_generic"
	items_to_create = list(
		/obj/item/kitchen/rollingpin,
		/obj/item/kitchen/knife,
		/obj/item/reagent_containers/glass/beaker,
	)

/obj/item/organ/cyberimp/arm/cook/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/detective
	name = "implant detektywistyczny"
	desc = "Zestaw narzędzi detektywa ukryty za maskowanym panelem w ręce."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_detective"
	items_to_create = list(
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/evidencebag,
		/obj/item/detective_scanner,
		/obj/item/lighter,
	)

/obj/item/organ/cyberimp/arm/detective/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/detective/Destroy()
	// Dowody w woreczkach nie mogą zniknąć razem z implantem
	var/turf/drop_turf = get_turf(owner || src)
	for(var/obj/item/evidencebag/baggie in contents)
		for(var/obj/item/evidence in baggie)
			evidence.forceMove(drop_turf)
	return ..()

/obj/item/organ/cyberimp/arm/paramedic
	name = "implant ratowniczy"
	desc = "Zestaw narzędzi ratownika ukryty za maskowanym panelem w ręce."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_paramedic"
	items_to_create = list(
		/obj/item/roller/robo,
		/obj/item/sensor_device,
		/obj/item/reagent_containers/borghypo/implant,
	)

/obj/item/organ/cyberimp/arm/paramedic/l
	zone = BODY_ZONE_L_ARM

/// Iniektor z implantu ratowniczego. Hipospray cyborga uzupełnia się tylko z baterii borga, ten powoli z organizmu nosiciela.
/obj/item/reagent_containers/borghypo/implant
	name = "wbudowany iniektor"
	desc = "Mały syntezator leków wbudowany w rękę. Powoli odtwarza zapas z zasobów organizmu."
	recharge_time = 30
	default_reagent_types = list(
		/datum/reagent/medicine/epinephrine,
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/kelotane,
	)

/obj/item/reagent_containers/borghypo/implant/regenerate_reagents(list/reagents_to_regen)
	for(var/reagent in reagents_to_regen)
		if(!stored_reagents.has_reagent(reagent, max_volume_per_reagent))
			stored_reagents.add_reagent(reagent, 5, no_react = TRUE)

/obj/item/organ/cyberimp/arm/atmospherics
	name = "implant atmosferyczny"
	desc = "Zestaw narzędzi atmosferycznych ukryty za maskowanym panelem w ręce."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_atmosph"
	items_to_create = list(
		/obj/item/extinguisher/advanced,
		/obj/item/analyzer/ranged,
		/obj/item/crowbar/cyborg,
		/obj/item/holosign_creator/atmos,
	)

/obj/item/organ/cyberimp/arm/atmospherics/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/barber
	name = "implant fryzjerski"
	desc = "Zestaw narzędzi fryzjera ukryty za maskowanym panelem w ręce."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_generic"
	items_to_create = list(
		/obj/item/razor,
		/obj/item/reagent_containers/spray/hair_dye_implant,
		/obj/item/reagent_containers/spray/barbers_aid_implant,
	)

/obj/item/organ/cyberimp/arm/barber/l
	zone = BODY_ZONE_L_ARM

/obj/item/reagent_containers/spray/hair_dye_implant
	name = "rozpylacz farby do włosów"
	desc = "Wbudowany rozpylacz z farbą, która zmienia kolor włosów na losowy."
	list_reagents = list(/datum/reagent/hair_dye = 50)
	volume = 50

/obj/item/reagent_containers/spray/barbers_aid_implant
	name = "rozpylacz porostu włosów"
	desc = "Wbudowany rozpylacz z płynem, po którym odrastają włosy i zarost."
	list_reagents = list(/datum/reagent/barbers_aid = 50)
	volume = 50

/obj/item/organ/cyberimp/arm/synth_repair
	name = "zintegrowany zestaw naprawczy syntetyków"
	desc = "Mocno okrojony implant z narzędziami, w którym jest tylko to, co trzeba do łatania zewnętrznych uszkodzeń syntetyka: spawarka i duży zwój kabla."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_engineering"
	items_to_create = list(
		/obj/item/weldingtool/experimental,
		/obj/item/stack/cable_coil,
	)

/obj/item/organ/cyberimp/arm/synth_repair/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/officer
	name = "implant oficerski"
	desc = "Potężny implant z modułami bojowymi wbudowanymi w rękę."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_security"
	items_to_create = list(
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/melee/baton/loaded,
		/obj/item/assembly/flash/armimplant,
	)

/obj/item/organ/cyberimp/arm/officer/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/officer/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/item/assembly/flash/armimplant/flash = created_item.resolve()
		if(istype(flash))
			flash.arm = WEAKREF(src)

// Wiertło górnicze w ręce

/obj/item/organ/cyberimp/arm/mining_drill
	name = "wiertło zintegrowane Dalba Masterworks „Kopacz”"
	desc = "Ze stabilizującego mankietu w przedramieniu wysuwa się stalowe wiertło górnicze, które nachodzi na dłoń. Krok po kroku, obrót po obrocie posuwamy się naprzód. Tak właśnie działa wiertło!"
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "drill_steel"
	items_to_create = list(/obj/item/pickaxe/drill/implant)

/obj/item/organ/cyberimp/arm/mining_drill/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/mining_drill/diamond
	name = "diamentowe wiertło zintegrowane Dalba Masterworks „Drążyciel”"
	desc = "Ze stabilizującego mankietu w przedramieniu wysuwa się mistrzowskie diamentowe wiertło górnicze. To wiertło wybije dziurę we wszechświecie, a ta dziura stanie się drogą dla tych, którzy idą za nami!"
	icon_state = "drill_diamond"
	items_to_create = list(/obj/item/pickaxe/drill/implant/diamond)

/obj/item/organ/cyberimp/arm/mining_drill/diamond/l
	zone = BODY_ZONE_L_ARM

/obj/item/pickaxe/drill/implant
	name = "zintegrowane wiertło górnicze"
	desc = "Stalowe wiertło górnicze wysunięte z implantu w przedramieniu. Alt+klik zakręca wiertłem dla efektu."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "drill_steel"
	item_state = "drill_steel"
	lefthand_file = 'aquila/icons/obj/cybernetics/implants_lefthand.dmi'
	righthand_file = 'aquila/icons/obj/cybernetics/implants_righthand.dmi'
	slot_flags = NONE
	toolspeed = 0.6
	usesound = 'sound/weapons/drill.ogg'
	hitsound = 'sound/weapons/drill.ogg'
	/// Kiedy znowu można zakręcić wiertłem (tylko efekt)
	COOLDOWN_DECLARE(spin_cooldown)

/obj/item/pickaxe/drill/implant/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || !COOLDOWN_FINISHED(src, spin_cooldown))
		return
	COOLDOWN_START(src, spin_cooldown, 10 SECONDS)
	user.visible_message(span_warning("[user] zakręca wiertłem [src], które na chwilę rozpędza się do <b>tysięcy obrotów na minutę</b>."), \
		span_notice("Zakręcasz wiertłem [src], które na chwilę rozpędza się do <b>tysięcy obrotów na minutę</b>."))
	playsound(src, 'sound/weapons/drill.ogg', 40, TRUE)

/obj/item/pickaxe/drill/implant/diamond
	name = "zintegrowane diamentowe wiertło górnicze"
	desc = "Mistrzowskie diamentowe wiertło górnicze wysunięte z implantu w przedramieniu. Alt+klik zakręca wiertłem dla efektu."
	icon_state = "drill_diamond"
	item_state = "drill_diamond"
	toolspeed = 0.2
	force = 20
