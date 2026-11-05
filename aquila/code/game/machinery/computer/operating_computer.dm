// AQUILA - komputer operacyjny dla nowego szkieletu chirurgii (tg code/game/machinery/computer/operating_computer.dm, tgstation#93697).
// Zamiast "następnego kroku" starej operacji pokazuje stan chirurgiczny wybranej strefy ciała i operacje, które da się zrobić dalej.
// Strefę wybiera się na sylwetce w oknie (jak w tg), co przestawia też strefę na HUD-zie. Dyski i badania wczytują typy operacji
// do advanced_surgeries (surgery_unlocks.dm). Hooki: AQ EDIT w ui_data w code/game/machinery/computer/Operating.dm.

/obj/machinery/computer/operating
	/// Strefa ciała pacjenta, której stan pokazuje okno
	var/target_zone = BODY_ZONE_CHEST

/// Typy zablokowanych operacji wczytanych z dysków i badań (do oznaczenia w katalogu)
/obj/machinery/computer/operating/proc/get_loaded_operation_ids()
	var/list/ids = list()
	for(var/operation_type in advanced_surgeries)
		if(ispath(operation_type, /datum/surgery_operation))
			ids += "[operation_type]"
	return ids

/// Stan chirurgiczny wybranej strefy, trwająca operacja i operacje możliwe dalej
/obj/machinery/computer/operating/proc/add_patient_surgery_data(list/data, mob/living/patient)
	data["target_zone"] = target_zone
	if(isnull(patient))
		return
	var/zone = check_zone(target_zone)
	var/datum/surgery_operation/ongoing = LAZYACCESS(patient.ongoing_operations, zone)
	data["patient"]["surgery_state"] = patient.get_surgery_state_as_list(target_zone)
	data["patient"]["prepped"] = patient.is_zone_prepped_for_surgery(target_zone)
	data["patient"]["ongoing"] = ongoing ? capitalize(ongoing.name) : null

	var/list/next_operations = list()
	var/list/available = GLOB.operations.unlocked | (advanced_surgeries & GLOB.operations.locked)
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(available))
		if(operation.show_as_next_step(patient, target_zone))
			next_operations += "[operation.type]"
	data["next_operations"] = next_operations

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	// tg: okno otwiera się na strefie, którą chirurg ma wybraną
	if(isliving(user) && !SStgui.get_open_ui(user, src))
		target_zone = user.zone_selected
	return ..()

/obj/machinery/computer/operating/ui_act(action, params)
	. = ..()
	if(!. || action != "change_zone")
		return
	var/new_zone = params["new_zone"]
	if(!(new_zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_GROIN)))
		return
	target_zone = new_zone
	var/atom/movable/screen/zone_sel/selector = usr?.hud_used?.zone_select
	selector?.set_selected_zone(new_zone, usr)

/obj/machinery/computer/operating/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/simple/body_zones)

// BodyZoneSelector (tgui-core 6) szuka tła "body_zones.base_<motyw>.png", a rejestrowane było tylko "body_zones.base.png"
/datum/asset/simple/body_zones/register()
	assets["body_zones.base_midnight.png"] = icon('icons/mob/screen_midnight.dmi', "zone_sel")
	return ..()
