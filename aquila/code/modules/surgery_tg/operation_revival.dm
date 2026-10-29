// AQUILA - tg code/modules/surgery/operations/operation_revival.dm
// Ożywienie porażeniem mózgu (stara wersja: code/modules/surgery/advanced/revival.dm). U nas to zaawansowana
// operacja z dysku albo badań, więc jest OPERATION_LOCKED i odblokowują ją dyski i projekty /datum/design/surgery (surgery_unlocks.dm).
// Zostają nasze efekty: po ożywieniu +50 uszkodzeń mózgu i wiadomość o niepamięci (NSV13), przy porażce +15,
// nie da się ożywić samobójcy, potępionego ani wysuszonego. Pominięte z tg: TRAIT_DEFIB_BLACKLISTED, nastrój TRAIT_MORBID.

/datum/surgery_operation/basic/revival
	name = "porażenie mózgu"
	rnd_name = "Defibrylacja mózgu (ożywienie)"
	desc = "Poraża mózg zmarłego pacjenta defibrylatorem, żeby przywrócić go do życia."
	implements = list(
		/obj/item/shockpaddles = 1,
		/obj/item/melee/touch_attack/shock = 1,
		/obj/item/melee/baton = 1.33,
		/obj/item/gun/energy = 1.67,
	)
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_LOCKED
	time = 5 SECONDS
	preop_sound = list(
		/obj/item/shockpaddles = 'sound/machines/defib_charge.ogg',
		/obj/item = null,
	)
	success_sound = 'sound/magic/lightningbolt.ogg'
	failure_sound = 'sound/magic/lightningbolt.ogg'
	blocked_biotype = null
	target_zone = BODY_ZONE_HEAD
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED

/datum/surgery_operation/basic/revival/get_default_radial_image()
	return get_item_radial_image(/obj/item/shockpaddles)

/datum/surgery_operation/basic/revival/all_required_strings()
	return ..() + list("pacjent musi być martwy", "ciało musi nadawać się do ożywienia")

/datum/surgery_operation/basic/revival/state_check(mob/living/patient)
	if(patient.stat != DEAD)
		return FALSE
	if(patient.suiciding || patient.ishellbound() || HAS_TRAIT(patient, TRAIT_HUSK))
		return FALSE
	if(patient.has_limbs)
		var/obj/item/organ/brain/brain = patient.getorganslot(ORGAN_SLOT_BRAIN)
		return !isnull(brain) && brain_check(brain)
	return mob_check(patient)

/// Mózg pasuje do tej wersji operacji (organiczny)
/datum/surgery_operation/basic/revival/proc/brain_check(obj/item/organ/brain/brain)
	return !(brain.status & ORGAN_ROBOTIC)

/// Mob bez kończyn pasuje do tej wersji operacji (nie robot)
/datum/surgery_operation/basic/revival/proc/mob_check(mob/living/patient)
	return !(MOB_ROBOTIC in patient.mob_biotypes)

/datum/surgery_operation/basic/revival/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = tool
		if((paddles.req_defib && !paddles.defib.powered) || !ISWIELDED(paddles) || paddles.cooldown || paddles.busy)
			return FALSE

	if(istype(tool, /obj/item/melee/baton))
		var/obj/item/melee/baton/baton = tool
		return baton.turned_on

	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/egun = tool
		return istype(egun.chambered, /obj/item/ammo_casing/energy/electrode)

	return TRUE

/datum/surgery_operation/basic/revival/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Przygotowujesz się, by dać mózgowi [patient] iskrę życia za pomocą [tool]."),
		span_notice("[surgeon] przygotowuje się, by porazić mózg [patient] za pomocą [tool]."),
		span_notice("[surgeon] przygotowuje się, by porazić mózg [patient]."),
	)
	patient.notify_ghost_cloning("Ktoś próbuje porazić twój mózg!", source = patient)

/datum/surgery_operation/basic/revival/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Pomyślnie porażasz mózg [patient] za pomocą [tool]..."),
		span_notice("[surgeon] wysyła potężny wstrząs do mózgu [patient] za pomocą [tool]..."),
		span_notice("[surgeon] wysyła potężny wstrząs do mózgu [patient]..."),
	)
	patient.grab_ghost()
	patient.adjustOxyLoss(-50, 0)
	if(iscarbon(patient))
		var/mob/living/carbon/carbon_patient = patient
		carbon_patient.set_heartattack(FALSE)
	patient.updatehealth()
	if(!patient.revive())
		on_no_revive(surgeon, patient)
		return

	on_revived(surgeon, patient)

/// Udało się ożywić
/datum/surgery_operation/basic/revival/proc/on_revived(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_notice("...[patient] budzi się, żywy i przytomny!"))
	patient.emote("gasp")
	to_chat(patient, span_warning("<b>Zostajesz przywrócony do życia operacją ożywienia. Nie pamiętasz dokładnie, jak zginąłeś (ani kto cię zabił), ale możesz pamiętać pewne szczegóły, takie jak użyta broń czy miejsce śmierci.</b>")) //NSV13
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199) // szalona nauka

/// Ciało nie dało się ożywić
/datum/surgery_operation/basic/revival/proc/on_no_revive(mob/living/surgeon, mob/living/patient)
	patient.visible_message(span_warning("...dostaje drgawek, po czym nieruchomieje."))

/datum/surgery_operation/basic/revival/on_failure(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Porażasz mózg [patient] za pomocą [tool], ale nie ma reakcji."),
		span_warning("[surgeon] wysyła potężny wstrząs do mózgu [patient] za pomocą [tool], ale nie ma reakcji."),
		span_warning("[surgeon] wysyła potężny wstrząs do mózgu [patient], ale nie ma reakcji."),
	)
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)

/// Pełny restart systemu (pozytronowy mózg IPC)
/datum/surgery_operation/basic/revival/mechanic
	name = "pełny restart systemu"
	rnd_name = "Restart systemu (ożywienie)"
	required_bodytype = BODYTYPE_ROBOTIC

/datum/surgery_operation/basic/revival/mechanic/brain_check(obj/item/organ/brain/brain)
	return !..()

/datum/surgery_operation/basic/revival/mechanic/mob_check(mob/living/patient)
	return !..()
