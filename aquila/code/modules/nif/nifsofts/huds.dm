// AQUILA - soczewki jasnowidza: NIFSofty z HUD-ami. Działają tylko przez okulary z adapterem (misc_devices.dm).
// Port z Monkestation (nifsofts/huds.dm), bez soczewki pozwoleń (nie mamy HUD-u pozwoleń na broń).

/datum/nifsoft/hud
	name = "Soczewka jasnowidza"
	program_desc = "Zbiorcza nazwa NIFSoftów z wyświetlaczami przeziernymi. Ta technologia sięga niemal początków NIFSoftów. W cywilu łączy się ją z wszelkimi zajęciami: pilotażem, szermierką, badaniami naukowymi, a nawet pomocą SI w ważnych rozmowach. Zwykle nanomaszyny programu tworzą sztuczną soczewkę kontaktową na oku, ale przepisy Nanotrasen każą tym wersjom współpracować z okularami, które nosiciel już ma na sobie."
	compatible_nifs = list(/obj/item/organ/cyberimp/brain/nif/standard)
	active_mode = TRUE
	active_cost = 0.5
	ui_icon = "eye"
	/// Czy program wymaga zgodnych okularów
	var/eyewear_check = TRUE
	/// Rodzaj HUD-u dodawanego po włączeniu
	var/hud_type
	/// Cechy HUD-u dodawane po włączeniu
	var/list/hud_traits
	/// Inne cechy okularów dodawane po włączeniu (np. jak gogle naukowe)
	var/list/added_eyewear_traits = list()
	/// Okulary, przez które program działa
	var/obj/item/clothing/glasses/tracked_glasses

/datum/nifsoft/hud/Destroy()
	untrack_glasses()
	return ..()

/// Pokazuje HUD i dodaje cechy
/datum/nifsoft/hud/proc/add_huds()
	if(hud_type)
		var/datum/atom_hud/our_hud = GLOB.huds[hud_type]
		our_hud.add_hud_to(linked_mob)

	for(var/trait in hud_traits)
		ADD_TRAIT(linked_mob, trait, NIFSOFT_TRAIT)

	for(var/trait in added_eyewear_traits)
		ADD_TRAIT(linked_mob, trait, NIFSOFT_TRAIT)

	linked_mob.update_sight()

/// Chowa HUD i zdejmuje cechy
/datum/nifsoft/hud/proc/remove_huds()
	if(!linked_mob)
		return FALSE
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(linked_mob)

	for(var/trait in hud_traits)
		REMOVE_TRAIT(linked_mob, trait, NIFSOFT_TRAIT)

	for(var/trait in added_eyewear_traits)
		REMOVE_TRAIT(linked_mob, trait, NIFSOFT_TRAIT)

	linked_mob.update_sight()
	return TRUE

/datum/nifsoft/hud/activate()
	var/obj/item/clothing/glasses/worn_glasses = linked_mob.get_item_by_slot(ITEM_SLOT_EYES)
	if(eyewear_check && !active && (!istype(worn_glasses) || !HAS_TRAIT(worn_glasses, TRAIT_NIFSOFT_HUD_GRANTER)))
		linked_mob.balloon_alert(linked_mob, "brak zgodnych okularów!")
		return FALSE

	. = ..()
	if(!.)
		return FALSE

	if(!active)
		remove_huds()
		untrack_glasses()
		return TRUE

	add_huds()
	if(eyewear_check)
		tracked_glasses = worn_glasses
		RegisterSignal(worn_glasses, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_glasses_unequip))
		RegisterSignal(worn_glasses, COMSIG_PARENT_QDELETING, PROC_REF(on_glasses_unequip))

	return TRUE

/// Przestaje śledzić okulary
/datum/nifsoft/hud/proc/untrack_glasses()
	if(!tracked_glasses)
		return
	UnregisterSignal(tracked_glasses, list(COMSIG_ITEM_PRE_UNEQUIP, COMSIG_PARENT_QDELETING))
	tracked_glasses = null

/// Zdjęte albo zniszczone okulary wyłączają soczewkę
/datum/nifsoft/hud/proc/on_glasses_unequip(datum/source)
	SIGNAL_HANDLER
	untrack_glasses()
	if(active)
		INVOKE_ASYNC(src, PROC_REF(activate))

/// Okulary z tym elementem pozwalają używać soczewek NIFSoft
/datum/element/nifsoft_hud
	element_flags = ELEMENT_DETACH

/datum/element/nifsoft_hud/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/item/clothing/glasses))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	ADD_TRAIT(target, TRAIT_NIFSOFT_HUD_GRANTER, INNATE_TRAIT)

/// Dopisuje do oględzin, że okulary obsługują soczewki NIFSoft
/datum/element/nifsoft_hud/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("Noszone na oczach pozwalają używać soczewek NIFSoft (HUD-ów).")

/datum/element/nifsoft_hud/Detach(datum/target)
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)
	REMOVE_TRAIT(target, TRAIT_NIFSOFT_HUD_GRANTER, INNATE_TRAIT)
	return ..()

/// Soczewki zawodowe wykluczają się nawzajem
/datum/nifsoft/hud/job
	mutually_exclusive_programs = list(/datum/nifsoft/hud/job)

/datum/nifsoft/hud/job/medical
	name = "Medyczna soczewka jasnowidza"
	ui_icon = "staff-snake"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	hud_traits = list(TRAIT_MEDICAL_HUD)

/datum/nifsoft/hud/job/diagnostic
	name = "Diagnostyczna soczewka jasnowidza"
	ui_icon = "robot"
	hud_type = DATA_HUD_DIAGNOSTIC_BASIC
	hud_traits = list(TRAIT_DIAGNOSTIC_HUD)

/datum/nifsoft/hud/job/security
	name = "Soczewka jasnowidza ochrony"
	ui_icon = "shield"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	hud_traits = list(TRAIT_SECURITY_HUD)

/datum/nifsoft/hud/job/science
	name = "Naukowa soczewka jasnowidza"
	ui_icon = "flask"
	added_eyewear_traits = list(TRAIT_REAGENT_SCANNER)

/datum/nifsoft/hud/job/meson
	name = "Mezonowa soczewka jasnowidza"
	ui_icon = "radiation"
	added_eyewear_traits = list(TRAIT_MADNESS_IMMUNE, TRAIT_MESON_VISION)

/obj/item/disk/nifsoft_uploader/med_hud
	loaded_nifsoft = /datum/nifsoft/hud/job/medical

/obj/item/disk/nifsoft_uploader/diag_hud
	loaded_nifsoft = /datum/nifsoft/hud/job/diagnostic

/obj/item/disk/nifsoft_uploader/sec_hud
	loaded_nifsoft = /datum/nifsoft/hud/job/security

/obj/item/disk/nifsoft_uploader/sci_hud
	loaded_nifsoft = /datum/nifsoft/hud/job/science

/obj/item/disk/nifsoft_uploader/meson_hud
	loaded_nifsoft = /datum/nifsoft/hud/job/meson
