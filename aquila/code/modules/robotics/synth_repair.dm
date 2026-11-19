// AQUILA - leki i materiały naprawcze dla syntetyków i protez (Nova Sector modular_nova/modules/deforest_medical_items/code/synth_healing.dm,
// modular_nova/modules/synths/code/reagents/reagents.dm, MonkeStation monkestation/code/modules/smithing/ipcs/reagents/reagents.dm).
// - łatka naprawcza (stos): leczy robotyczną kończynę i naprawia lekkie rany robotyczne, cięższe zabezpiecza (robotic_wounds.dm),
// - zawiesina nanitów: lek dla ciał syntetycznych i protez (działa w IPC i w ludziach z protezami); leczy protezy i organy
//   cybernetyczne, czasem naprawia lekką ranę robotyczną; przedawkowanie (ponad 20 j.) przegrzewa nanity i parzy protezy,
// - spray naprawczy: zawiesina nanitów w rozpylaczu, na skórę działa od razu na protezę, w którą celujesz,
// - apteczka syntetyka: łatki, spray, kabel, spawarka awaryjna, worek chłodziwa i klucz resetu.
// Nanopasty nie dodajemy: robi ją AquilaMed 5 (aq33/AquilaStation#652). Worek z chłodziwem już mamy (blood_pack.dm, Coolant).
// Ikony: istniejące sprite'y gazy i sprayu z naszymi kolorami.

/obj/item/stack/medical/aq_robo_patch
	name = "łatka naprawcza"
	singular_name = "łatka naprawcza"
	desc = "Samoprzylepna łatka z siatką nanitów. Łata obudowę protezy albo syntetyka i naprawia drobne usterki. Na żywą tkankę nie działa."
	icon_state = "gauze"
	color = "#8fb1d6"
	amount = 10
	max_amount = 10
	heal_brute = 10
	heal_burn = 10
	self_delay = 2 SECONDS
	resistance_flags = NONE
	merge_type = /obj/item/stack/medical/aq_robo_patch

/obj/item/stack/medical/aq_robo_patch/five
	amount = 5

/obj/item/stack/medical/aq_robo_patch/attack(mob/living/M, mob/user)
	if(!iscarbon(M) || (M in user.do_afters))
		return ..()
	var/mob/living/carbon/patient = M
	if(try_treat_wound(patient, user))
		return
	var/obj/item/bodypart/affecting = patient.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		to_chat(user, "<span class='warning'>[patient] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return
	if(IS_ORGANIC_LIMB(affecting) || !(affecting.bodytype & BODYTYPE_ROBOTIC))
		to_chat(user, "<span class='warning'>Łatka działa tylko na protezy i ciała syntetyków.</span>")
		return
	if(!(affecting.brute_dam || affecting.burn_dam))
		to_chat(user, "<span class='warning'>Ta część ([strefa_pl(user.zone_selected)]) nie jest uszkodzona.</span>")
		return
	if(patient == user && !do_mob(user, patient, self_delay))
		return
	user.visible_message("<span class='green'>[user] nakłada [singular_name] na [patient].</span>", "<span class='green'>Nakładasz [singular_name] na [patient].</span>")
	if(affecting.heal_damage(heal_brute, heal_burn, 0, BODYTYPE_ROBOTIC))
		patient.update_damage_overlays()
	use(1)

/datum/design/aq_robo_patch
	name = "Łatki naprawcze"
	desc = "Pięć łatek do naprawy protez i syntetyków."
	id = "aq_robo_patch"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 1000, /datum/material/plastic = 500)
	build_path = /obj/item/stack/medical/aq_robo_patch/five
	category = list("Cyborg", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

// --- Zawiesina nanitów ---

/datum/reagent/medicine/aq_nanite_slurry
	name = "Zawiesina nanitów"
	description = "Rój nanitów naprawczych w płynie. Naprawia protezy, ciała syntetyków i organy cybernetyczne. W nadmiarze nanity się przegrzewają."
	reagent_state = LIQUID
	color = "#9aa6ad"
	taste_description = "metal i prąd"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20
	process_flags = ORGANIC | SYNTHETIC
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/medicine/aq_nanite_slurry/on_mob_life(mob/living/carbon/M)
	if(iscarbon(M))
		M.aq_nanite_repair(1.5 * REM, 1.5 * REM)
	return ..()

/datum/reagent/medicine/aq_nanite_slurry/overdose_process(mob/living/carbon/M)
	if(iscarbon(M))
		for(var/obj/item/bodypart/limb as anything in M.bodyparts)
			if(!IS_ORGANIC_LIMB(limb) && (limb.bodytype & BODYTYPE_ROBOTIC))
				limb.receive_damage(0, 1 * REM)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.aq_adjust_synth_heat(2 * REM)
		if(prob(10))
			to_chat(M, "<span class='warning'>Nanity w twoich protezach grzeją się do czerwoności!</span>")
	return ..()

/// Spray: zawiesina na powierzchni naprawia protezę, w którą celuje rozpylacz
/datum/reagent/medicine/aq_nanite_slurry/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(!iscarbon(M) || !(method in list(TOUCH, PATCH, VAPOR)))
		return
	var/mob/living/carbon/patient = M
	var/heal = reac_volume * (1 - touch_protection)
	var/list/limbs = affecting ? list(affecting) : patient.bodyparts
	for(var/obj/item/bodypart/limb as anything in limbs)
		if(IS_ORGANIC_LIMB(limb) || !(limb.bodytype & BODYTYPE_ROBOTIC))
			continue
		if(limb.heal_damage(heal, heal, 0, BODYTYPE_ROBOTIC))
			patient.update_damage_overlays()

/// Naprawa nanitami: robotyczne kończyny, organy cybernetyczne i czasem lekka rana robotyczna
/mob/living/carbon/proc/aq_nanite_repair(brute, burn)
	var/needs_update = FALSE
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(IS_ORGANIC_LIMB(limb) || !(limb.bodytype & BODYTYPE_ROBOTIC))
			continue
		if(limb.heal_damage(brute, burn, 0, BODYTYPE_ROBOTIC, FALSE))
			needs_update = TRUE
		for(var/datum/wound/aq_robotic/wound in limb.wounds)
			if(wound.severity <= WOUND_SEVERITY_MODERATE && prob(5))
				to_chat(src, "<span class='green'>Nanity naprawiają usterkę: [lowertext(wound.name)] ([limb.name]).</span>")
				wound.replaced = TRUE
				qdel(wound)
				break
	for(var/obj/item/organ/organ as anything in internal_organs)
		if((organ.organ_flags & ORGAN_SYNTHETIC) && organ.damage > 0 && organ.slot != ORGAN_SLOT_BRAIN)
			organ.applyOrganDamage(-brute)
	updatehealth()
	if(needs_update)
		update_damage_overlays()

/datum/chemical_reaction/aq_nanite_slurry
	name = "Zawiesina nanitów"
	id = /datum/reagent/medicine/aq_nanite_slurry
	results = list(/datum/reagent/medicine/aq_nanite_slurry = 3)
	required_reagents = list(/datum/reagent/silicon = 1, /datum/reagent/aluminium = 1, /datum/reagent/medicine/liquid_solder = 1)

/obj/item/reagent_containers/medspray/aq_nanite
	name = "spray naprawczy"
	desc = "Rozpylacz z zawiesiną nanitów. Spryskana proteza albo obudowa syntetyka naprawia się na oczach."
	icon_state = "synthspray"
	color = "#b8c4cc"
	list_reagents = list(/datum/reagent/medicine/aq_nanite_slurry = 60)

/datum/design/aq_nanite_spray
	name = "Spray naprawczy"
	desc = "Rozpylacz z zawiesiną nanitów do naprawy protez i syntetyków."
	id = "aq_nanite_spray"
	build_type = PROTOLATHE
	construction_time = 40
	materials = list(/datum/material/plastic = 1000, /datum/material/silver = 500)
	build_path = /obj/item/reagent_containers/medspray/aq_nanite
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

// --- Apteczka syntetyka ---

/obj/item/storage/firstaid/aq_synthetic
	name = "apteczka syntetyka"
	desc = "Apteczka do napraw syntetyków i protez: łatki, spray z nanitami, kabel, spawarka, chłodziwo i klucz resetu."
	icon_state = "medkit_o2"
	item_state = "medkit"
	color = "#a8b8c8"

/obj/item/storage/firstaid/aq_synthetic/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/aq_robo_patch = 1,
		/obj/item/reagent_containers/medspray/aq_nanite = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weldingtool/mini = 1,
		/obj/item/reagent_containers/blood/synthetic = 1,
		/obj/item/aq_synth_reset_key = 1)
	generate_items_inside(items_inside, src)
