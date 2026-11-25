// AQUILA - chirurgia mechaniczna syntetyków i protez na szkielecie operacji z tg (aquila/code/modules/surgery_tg/).
// Mamy już otwieranie obudowy (operation_generic_mechanic.dm), debugowanie pozytronowego mózgu (operation_organ_repair.dm)
// i zablokowany pełny restart z dysku (operation_revival.dm). Dochodzi:
// - naprawa obudowy spawarką i kablem (MonkeStation robot_healing.dm): opatrywanie ran z tg nie działa na IPC (blocked_biotype),
// - czyszczenie układu (Baystation12/Paradise robotics.dm): multitool usuwa wszystkie substancje i leczy toksyny i niedotlenienie,
// - reaktywacja (YogStation ipc_revival.dm): ponowne uruchomienie mózgu wyłączonego IPC multitoolem przez otwartą klatkę, bez dysku,
// - przeprogramowanie wyglądu protezy (Paradise robotics.dm, „reprogram limb”) i twarzy IPC (SS220 plastic_surgery_robotics.dm).
// IPC nie wstaje już sam po naprawie (synth_reset_key.dm), więc reaktywacja i klucz resetu to dwie drogi powrotu.

/// Naprawa obudowy spawarką (urazy) i kablem (oparzenia)
/datum/surgery_operation/basic/tend_wounds/aq_mechanic
	name = "naprawa obudowy"
	rnd_name = "Naprawa obudowy syntetyka"
	desc = "Spawa wgniecenia i wymienia przepalone przewody w ciele syntetyka albo w robotycznej klatce (wybór w menu)."
	implements = list(
		TOOL_WELDER = 1,
		/obj/item/stack/cable_coil = 1,
		TOOL_SCREWDRIVER = 2,
	)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING | OPERATION_IGNORE_CLOTHES | OPERATION_MECHANIC
	preop_sound = 'sound/items/welder.ogg'
	success_sound = 'sound/items/welder2.ogg'
	failure_sound = 'sound/machines/buzz-sigh.ogg'
	required_bodytype = BODYTYPE_ROBOTIC
	blocked_biotype = null
	replaced_by = null
	healing_amount = 6
	healing_multiplier = 1 / 10

/datum/surgery_operation/basic/tend_wounds/aq_mechanic/get_default_radial_image()
	return get_item_radial_image(/obj/item/weldingtool)

/datum/surgery_operation/basic/tend_wounds/aq_mechanic/rnd_suffix()
	return " (mechaniczna)"

/// Czyszczenie układu syntetyka z substancji
/datum/surgery_operation/basic/aq_system_purge
	name = "czyszczenie układu"
	rnd_name = "Czyszczenie układu syntetyka"
	desc = "Płucze obieg syntetyka: usuwa wszystkie substancje, toksyny i skutki niedotlenienia."
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 2,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_LOOPING | OPERATION_MECHANIC | OPERATION_IGNORE_CLOTHES
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_biotype = MOB_ROBOTIC
	blocked_biotype = null
	required_bodytype = BODYTYPE_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_ORGANS_CUT

/datum/surgery_operation/basic/aq_system_purge/all_required_strings()
	return ..() + list("w obiegu są substancje albo toksyny")

/datum/surgery_operation/basic/aq_system_purge/get_default_radial_image()
	return get_item_radial_image(/obj/item/multitool)

/datum/surgery_operation/basic/aq_system_purge/state_check(mob/living/patient)
	return patient.reagents?.total_volume > 0 || patient.getToxLoss() > 0 || patient.getOxyLoss() > 0

/datum/surgery_operation/basic/aq_system_purge/can_loop(mob/living/patient, mob/living/operating_on, mob/living/surgeon, tool, list/operation_args)
	return ..() && state_check(patient)

/datum/surgery_operation/basic/aq_system_purge/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz płukać obieg [patient]..."),
		span_notice("[surgeon] zaczyna płukać obieg [patient]."),
		span_notice("[surgeon] grzebie w elektronice [patient]."),
	)

/datum/surgery_operation/basic/aq_system_purge/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	patient.reagents?.clear_reagents()
	patient.adjustToxLoss(-10)
	patient.adjustOxyLoss(-10)
	display_results(
		surgeon,
		patient,
		span_notice("Obieg [patient] jest czystszy."),
		span_notice("[surgeon] płucze obieg [patient]."),
		span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
	)

/// Reaktywacja wyłączonego IPC bez dysku
/datum/surgery_operation/basic/aq_ipc_reactivation
	name = "reaktywacja syntetyka"
	rnd_name = "Reaktywacja syntetyka"
	desc = "Ręcznie restartuje pozytronowy mózg wyłączonego syntetyka przez otwartą klatkę. Najpierw trzeba naprawić uszkodzenia."
	implements = list(
		TOOL_MULTITOOL = 1,
		/obj/item/aq_synth_reset_key = 0.5,
	)
	time = 8 SECONDS
	operation_flags = OPERATION_NOTABLE | OPERATION_MECHANIC
	preop_sound = 'sound/machines/capacitor_charge.ogg'
	success_sound = 'aquila/sound/robotics/reset_key_boot.ogg'
	failure_sound = 'aquila/sound/robotics/reset_key_beep.ogg'
	required_biotype = MOB_ROBOTIC
	blocked_biotype = null
	required_bodytype = BODYTYPE_ROBOTIC
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_ORGANS_CUT

/datum/surgery_operation/basic/aq_ipc_reactivation/all_required_strings()
	return ..() + list("syntetyk musi być wyłączony (martwy)", "uszkodzenia muszą być naprawione")

/datum/surgery_operation/basic/aq_ipc_reactivation/get_default_radial_image()
	return get_item_radial_image(/obj/item/aq_synth_reset_key)

/datum/surgery_operation/basic/aq_ipc_reactivation/state_check(mob/living/patient)
	if(patient.stat != DEAD || patient.suiciding || patient.ishellbound())
		return FALSE
	var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)
	return brain && (brain.organ_flags & ORGAN_SYNTHETIC)

/datum/surgery_operation/basic/aq_ipc_reactivation/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Podłączasz się do magistrali pozytronowego mózgu [patient] i zaczynasz restart..."),
		span_notice("[surgeon] podłącza się do elektroniki [patient]."),
		span_notice("[surgeon] grzebie w elektronice [patient]."),
	)
	patient.notify_ghost_cloning("Ktoś restartuje twoje ciało!", source = patient)

/datum/surgery_operation/basic/aq_ipc_reactivation/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/human/synth = patient
	var/refusal = istype(synth) ? synth.aq_synth_reboot_refusal() : null
	if(refusal == AQ_SYNTH_REBOOT_LOST || refusal == AQ_SYNTH_REBOOT_DNR)
		display_results(
			surgeon,
			patient,
			span_warning("Mózg [patient] nie odpowiada na restart. Jednostki nie da się przywrócić."),
			span_warning("[surgeon] kończy restart, ale [patient] się nie uruchamia."),
			span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
		)
		return
	if(refusal == AQ_SYNTH_REBOOT_BRAIN)
		display_results(
			surgeon,
			patient,
			span_warning("Pozytronowy mózg [patient] jest nieodwracalnie uszkodzony i nie da się go uruchomić."),
			span_warning("[surgeon] kończy restart, ale [patient] się nie uruchamia."),
			span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
		)
		return
	if(refusal || !patient.can_be_revived())
		display_results(
			surgeon,
			patient,
			span_warning("Mózg [patient] odpowiada, ale ciało jest zbyt uszkodzone, by się uruchomić. Najpierw je napraw."),
			span_warning("[surgeon] kończy restart, ale [patient] się nie uruchamia."),
			span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
		)
		return
	patient.grab_ghost()
	patient.revive() // ludzka wersja revive() nic nie zwraca, więc liczy się stat
	if(patient.stat == DEAD)
		return
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 199)
	display_results(
		surgeon,
		patient,
		span_notice("Pozytronowy mózg [patient] budzi się i system się uruchamia."),
		span_notice("[surgeon] restartuje [patient]!"),
		span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
	)

/datum/surgery_operation/basic/aq_ipc_reactivation/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Zwierasz magistralę, a mózg [patient] dostaje przepięcia!"),
		span_warning("[surgeon] zwiera elektronikę [patient]!"),
		span_notice("[surgeon] kończy grzebać w elektronice [patient]."),
	)
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)

// --- Wygląd ---

#define OPERATION_AQ_BRAND "aq_brand"
#define OPERATION_AQ_CHASSIS "aq_chassis"
#define OPERATION_AQ_NAME "aq_name"

/// Zmiana marki i wyglądu protezy multitoolem przy otwartej klapie
/datum/surgery_operation/limb/aq_prosthetic_restyle
	name = "przeprogramowanie wyglądu protezy"
	catalog_sections = list(SURGERY_SECTION_MECHANIC)
	desc = "Przy otwartej klapie przeprogramowuje markę protezy: wygląd i opis producenta (limb_brands.dm)."
	implements = list(
		TOOL_MULTITOOL = 1,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = BODYTYPE_ROBOTIC
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/ping.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/aq_prosthetic_restyle/get_default_radial_image()
	return get_item_radial_image(/obj/item/multitool)

/datum/surgery_operation/limb/aq_prosthetic_restyle/all_required_strings()
	return ..() + list("zwykła proteza (nie IPC, nie zaawansowana)")

/datum/surgery_operation/limb/aq_prosthetic_restyle/state_check(obj/item/bodypart/limb)
	return limb.aq_can_have_brand()

/datum/surgery_operation/limb/aq_prosthetic_restyle/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/list/choices = list()
	for(var/id in GLOB.aq_robolimb_brands)
		var/datum/aq_robolimb_brand/brand = GLOB.aq_robolimb_brands[id]
		choices[brand.name] = brand
	var/picked = input(surgeon, "Wybierz markę protezy.", "Przeprogramowanie protezy") as null|anything in choices
	operation_args[OPERATION_AQ_BRAND] = choices[picked]
	return !!operation_args[OPERATION_AQ_BRAND]

/datum/surgery_operation/limb/aq_prosthetic_restyle/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przeprogramowywać protezę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna przeprogramowywać protezę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] grzebie w protezie ([FORMAT_LIMB_OWNER(limb)])."),
	)

/datum/surgery_operation/limb/aq_prosthetic_restyle/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	var/datum/aq_robolimb_brand/brand = operation_args[OPERATION_AQ_BRAND]
	if(!limb.aq_set_brand(brand))
		return
	display_results(
		surgeon,
		limb.owner,
		span_notice("Proteza ([FORMAT_LIMB_OWNER(limb)]) przyjmuje wygląd marki [brand.name]."),
		span_notice("[surgeon] przeprogramowuje protezę ([FORMAT_LIMB_OWNER(limb)]) na markę [brand.name]."),
		span_notice("[surgeon] kończy grzebać w protezie ([FORMAT_LIMB_OWNER(limb)])."),
	)

/// Robotyczna operacja plastyczna IPC: nowe podwozie i nowe oznaczenie jednostki
/datum/surgery_operation/limb/aq_ipc_restyle
	name = "przeprogramowanie twarzy syntetyka"
	catalog_sections = list(SURGERY_SECTION_FACE)
	desc = "Zmienia podwozie i oznaczenie syntetyka, tak jak chirurgia plastyczna zmienia twarz człowieka."
	implements = list(
		TOOL_MULTITOOL = 1,
	)
	time = 6 SECONDS
	operation_flags = OPERATION_MECHANIC | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ROBOTIC
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/ping.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/aq_ipc_restyle/get_default_radial_image()
	return get_item_radial_image(/obj/item/multitool)

/datum/surgery_operation/limb/aq_ipc_restyle/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_HEAD)]", "pacjent musi być IPC") + ..()

/datum/surgery_operation/limb/aq_ipc_restyle/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD && isipc(limb.owner)

/datum/surgery_operation/limb/aq_ipc_restyle/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/list/chassis = list("Bez zmian") + GLOB.ipc_chassis_list
	operation_args[OPERATION_AQ_CHASSIS] = input(surgeon, "Wybierz podwozie.", "Przeprogramowanie syntetyka") as null|anything in chassis
	if(!operation_args[OPERATION_AQ_CHASSIS])
		return FALSE
	var/list/names = list("Bez zmian")
	for(var/i in 1 to 8)
		names += patient.dna.species.random_name(patient.gender, TRUE)
	operation_args[OPERATION_AQ_NAME] = input(surgeon, "Wybierz nowe oznaczenie.", "Przeprogramowanie syntetyka") as null|anything in names
	return !!operation_args[OPERATION_AQ_NAME]

/datum/surgery_operation/limb/aq_ipc_restyle/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przeprogramowywać wygląd [limb.owner]..."),
		span_notice("[surgeon] zaczyna przeprogramowywać wygląd [limb.owner]."),
		span_notice("[surgeon] grzebie w głowie [limb.owner]."),
	)

/datum/surgery_operation/limb/aq_ipc_restyle/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/new_chassis = operation_args[OPERATION_AQ_CHASSIS]
	if(new_chassis != "Bez zmian" && GLOB.ipc_chassis_list[new_chassis])
		patient.aq_set_ipc_chassis(new_chassis)
	var/new_name = operation_args[OPERATION_AQ_NAME]
	var/old_name = patient.real_name
	if(new_name && new_name != "Bez zmian")
		patient.real_name = new_name
		patient.sec_hud_set_ID()
	REMOVE_TRAIT(patient, TRAIT_DISFIGURED, TRAIT_GENERIC)
	display_results(
		surgeon,
		patient,
		span_notice("Przeprogramowujesz [old_name], teraz to [patient.real_name]."),
		span_notice("[surgeon] przeprogramowuje [old_name], teraz to [patient.real_name]!"),
		span_notice("[surgeon] kończy grzebać w głowie [patient]."),
	)

/// Nowe podwozie IPC (to samo, co /datum/species/ipc/replace_body robi przy tworzeniu ciała)
/mob/living/carbon/human/proc/aq_set_ipc_chassis(chassis_name)
	var/datum/sprite_accessory/ipc_chassis/chassis = GLOB.ipc_chassis_list[chassis_name]
	if(!chassis || !dna)
		return FALSE
	var/datum/sprite_accessory/ipc_chassis/old_chassis = GLOB.ipc_chassis_list[dna.features["ipc_chassis"]]
	dna.features["ipc_chassis"] = chassis_name
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		// tylko części podwozia, bez doczepionych protez innych marek
		if(limb.aq_brand || !(limb.bodytype & BODYTYPE_ROBOTIC) || (limb.limb_id != "synth" && limb.limb_id != old_chassis?.limbs_id))
			continue
		limb.uses_mutcolor = chassis.color_src ? TRUE : FALSE
		if(limb.uses_mutcolor)
			limb.should_draw_greyscale = TRUE
			limb.species_color = dna.features["mcolor"]
		limb.limb_id = chassis.limbs_id
		limb.name = "\improper[chassis.name] [parse_zone(limb.body_zone)]"
		limb.update_limb()
	update_body()
	return TRUE

#undef OPERATION_AQ_BRAND
#undef OPERATION_AQ_CHASSIS
#undef OPERATION_AQ_NAME
