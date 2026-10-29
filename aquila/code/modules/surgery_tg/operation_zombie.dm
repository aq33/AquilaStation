// AQUILA - tg code/modules/surgery/operations/operation_zombie.dm
// Nekrotyczne ożywienie (stara wersja: code/modules/surgery/advanced/necrotic_revival.dm). Zaawansowana operacja:
// OPERATION_LOCKED, odblokowuje ją to samo co starą (legacy_unlocked_by). Zostaje nasze zachowanie: organiczna głowa,
// mózg nie jest wymagany, odczynniki się nie zużywają. Jak w tg operacja pokazuje się dopiero, gdy pacjent albo
// strzykawka ma w sobie proszek zombie albo rezadon (stara wersja w takim przypadku po prostu się nie udawała).

/datum/surgery_operation/limb/bionecrosis
	name = "wywołanie bionekrozy"
	rnd_name = "Bionekroplastyka (nekrotyczne ożywienie)"
	desc = "Wstrzykuje odczynniki, które pobudzają wzrost guza romerolowego w mózgu pacjenta."
	rnd_desc = "Eksperymentalna operacja, która wywołuje wzrost guza romerolowego w mózgu pacjenta. Wymaga proszku zombie albo rezadonu."
	implements = list(
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/pen = 3.33,
	)
	time = 5 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE
	legacy_unlocked_by = list(/datum/surgery/advanced/necrotic_revival)
	required_bodytype = BODYTYPE_ORGANIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	/// Wystarczy którykolwiek
	var/list/zombie_chems = list(
		/datum/reagent/medicine/rezadone,
		/datum/reagent/toxin/zombiepowder,
	)

/datum/surgery_operation/limb/bionecrosis/get_default_radial_image()
	return get_item_radial_image(/obj/item/reagent_containers/syringe)

/datum/surgery_operation/limb/bionecrosis/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_HEAD)]") + ..()

/datum/surgery_operation/limb/bionecrosis/any_required_strings()
	. = ..()
	for(var/datum/reagent/chem as anything in zombie_chems)
		. += "pacjent albo narzędzie musi zawierać [initial(chem.name)]"

/datum/surgery_operation/limb/bionecrosis/all_blocked_strings()
	return ..() + list("w głowie nie może już być guza romerolowego")

/datum/surgery_operation/limb/bionecrosis/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_HEAD)
		return FALSE
	return !limb.owner.getorganslot(ORGAN_SLOT_ZOMBIE)

/datum/surgery_operation/limb/bionecrosis/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	for(var/chem in zombie_chems)
		if(isitem(tool) && tool.reagents?.has_reagent(chem))
			return TRUE
		if(limb.owner.reagents?.has_reagent(chem))
			return TRUE
	return FALSE

/datum/surgery_operation/limb/bionecrosis/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz hodować guz romerolowy w mózgu [limb.owner]..."),
		span_notice("[surgeon] zaczyna majstrować przy mózgu [limb.owner]..."),
		span_notice("[surgeon] zaczyna operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Głowa pęka ci z niewyobrażalnego bólu!")

/datum/surgery_operation/limb/bionecrosis/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Udaje ci się wyhodować guz romerolowy w mózgu [limb.owner]."),
		span_notice("[surgeon] pomyślnie hoduje guz romerolowy w mózgu [limb.owner]!"),
		span_notice("[surgeon] kończy operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Głowa na chwilę zupełnie drętwieje, ból jest przytłaczający!")
	if(limb.owner.getorganslot(ORGAN_SLOT_ZOMBIE)) // dostał drugi w trakcie? trudno
		return
	var/obj/item/organ/zombie_infection/infection = new()
	infection.Insert(limb.owner)
