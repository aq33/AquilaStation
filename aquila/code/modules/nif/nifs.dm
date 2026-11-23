// AQUILA - NIF (Nanite Implant Framework): implant mózgu, na którym działają programy NIFSoft.
// Port z Monkestation (code/modules/modular_implants/nifs.dm, pierwotnie Skyrat/Nova).
// Bez przenoszenia między rundami (nif_persistence.dm) i bez punktów nagród.

#define NIF_CALIBRATION_STAGE_1 0
#define NIF_CALIBRATION_STAGE_1_END 0.1
#define NIF_CALIBRATION_STAGE_2 0.2
#define NIF_CALIBRATION_STAGE_2_END 0.9
#define NIF_CALIBRATION_STAGE_FINISHED 1

#define NIF_DURABILITY_LOSS_HALVED 2
#define NIF_MINIMUM_DURABILITY 0
#define NIF_MINIMUM_POWER_LEVEL 0

#define NIF_SETUP_BLINDNESS "nif_setup"

/// Bazowy NIF, z którego wychodzą pozostałe modele
/obj/item/organ/cyberimp/nif
	name = "Nanitowa Platforma Implantów"
	desc = "Implant mózgu, który wypełnia ciało nosiciela nanitami."
	icon = 'aquila/icons/monke/nif/nif.dmi'
	icon_state = "base_nif"
	implant_overlay = null
	w_class = WEIGHT_CLASS_NORMAL
	slot = ORGAN_SLOT_BRAIN_NIF
	zone = BODY_ZONE_HEAD // nie /cyberimp/brain: te ogłuszają nosiciela przy EMP (z pochłanianiem ogłuszeń heretyka), NIF tylko się psuje
	actions_types = list(/datum/action/item_action/nif/open_menu)

	/// Z kim NIF jest teraz połączony
	var/mob/living/carbon/human/linked_mob = null
	/// Ckey pierwszego nosiciela, chroni przed kradzieżą (linked_mob po wyjęciu jest pusty)
	var/stored_ckey

	/// Czy NIF jest już skalibrowany
	var/is_calibrated = FALSE
	/// Czy NIF właśnie się kalibruje
	var/calibrating = FALSE
	/// Ile trwa cała kalibracja
	var/calibration_time = 3 MINUTES
	/// Chwila, w której kalibracja się skończy. Ustawia ją tylko perform_calibration()
	var/calibration_duration
	/// Czy kalibracja oślepiła nosiciela (żeby zdjąć ślepotę tylko raz)
	var/calibration_blinded = FALSE
	/// Szansa na skutek uboczny w każdym cyklu kalibracji: 1 / side_effect_risk
	var/side_effect_risk = 50

	/// Największy zapas energii
	var/max_power_level = 1000
	/// Obecny zapas energii
	var/power_level = 0
	/// Zużycie energii na cykl. Ujemne oznacza ładowanie
	var/power_usage = 0

	/// Czy energia pochodzi z odżywienia
	var/nutrition_drain = FALSE
	/// Mnożnik głodu nosiciela przy zasilaniu z odżywienia
	var/nutrition_drain_rate = 1.5
	/// Przelicznik odżywienia na energię
	var/nutrition_conversion_rate = 5
	/// Poniżej tego odżywienia NIF przestaje z niego czerpać
	var/minimum_nutrition = 25

	/// Czy energia pochodzi z krwi
	var/blood_drain = FALSE
	/// Przelicznik krwi na energię
	var/blood_conversion_rate = 5
	/// Ile krwi NIF pobiera na cykl
	var/blood_drain_rate = 1
	/// Poniżej tej ilości krwi NIF przestaje ją pobierać
	var/minimum_blood_level = BLOOD_VOLUME_SAFE

	/// Największa wytrzymałość
	var/max_durability = 100
	/// Obecna wytrzymałość
	var/durability = 100
	/// Ile wytrzymałości NIF traci przy śmierci nosiciela
	var/death_durability_loss = 10
	/// Czy NIF jest chwilowo zepsuty (np. po EMP). Nie zależy od wytrzymałości
	var/broken = FALSE
	/// Czy NIF odrzuca obcego nosiciela. Wyłączać tylko przy naprawach administracyjnych
	var/theft_protection = TRUE
	/// Czy NIF może teraz tracić wytrzymałość
	var/durability_loss_vulnerable = TRUE

	/// Ile programów mieści NIF
	var/max_nifsofts = 20
	/// Zainstalowane programy
	var/list/loaded_nifsofts = list()
	/// Programy wgrane fabrycznie
	var/list/preinstalled_nifsofts = list(/datum/nifsoft/soul_poem)
	/// Notatka producenta w ustawieniach okna NIF
	var/manufacturer_notes = "Brak danych o tym produkcie."

	/// Dźwięk zwykłych komunikatów
	var/good_sound = 'aquila/sound/monke/nif_good.ogg'
	/// Dźwięk alarmów
	var/bad_sound = 'aquila/sound/monke/nif_bad.ogg'
	/// Dźwięk włączania
	var/click_sound = 'aquila/sound/monke/nif_click.ogg'
	/// Ikona NIF-u w czacie (stan z aquila/icons/monke/nif/nif_chat.dmi)
	var/chat_icon = "standard"

/obj/item/organ/cyberimp/nif/Initialize(mapload)
	. = ..()
	durability = max_durability
	power_level = max_power_level

/obj/item/organ/cyberimp/nif/Destroy()
	if(owner) // wyjęcie przed wyczyszczeniem linked_mob, żeby Remove() zdjął pobór z ciała nosiciela
		Remove(owner, special = TRUE)
	if(linked_mob)
		UnregisterSignal(linked_mob, COMSIG_MOB_DEATH)
		var/datum/component/nif_examine/found_component = linked_mob.GetComponent(/datum/component/nif_examine)
		if(found_component)
			qdel(found_component)
	linked_mob = null
	QDEL_LIST(loaded_nifsofts)
	return ..()

/obj/item/organ/cyberimp/nif/Insert(mob/living/carbon/insertee, special = FALSE, drop_if_replaced = TRUE)
	// Ochrona przed kradzieżą przed bazowym Insert(): ten wyjąłby najpierw działający NIF nosiciela
	if(!ishuman(insertee) || (stored_ckey && stored_ckey != insertee.ckey && theft_protection))
		insertee?.audible_message(span_warning("[src] brzęczy ostrzegawczo i nie chce się połączyć."))
		if(insertee)
			playsound(insertee, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			// operacja i autochirurg zdejmują NIF z ręki przed Insert(): odrzucony ląduje na podłodze, nie w nullspace (jak w Monkestation)
			if(!ismob(loc))
				forceMove(insertee.drop_location())
		return FALSE
	. = ..()
	if(owner != insertee)
		return

	linked_mob = insertee
	if(!stored_ckey)
		stored_ckey = linked_mob.ckey

	START_PROCESSING(SSobj, src)

	if(!is_calibrated)
		send_message("Rozpoczyna się kalibracja.")
		calibrating = TRUE
		calibration_duration = null // przerwana kalibracja zaczyna się od nowa

	linked_mob.AddComponent(/datum/component/nif_examine)
	RegisterSignal(linked_mob, COMSIG_MOB_DEATH, PROC_REF(damage_on_death))

	// Nieskalibrowany NIF nic nie instaluje: fabryczne programy wchodzą po kalibracji (perform_calibration)
	if(is_calibrated && length(preinstalled_nifsofts) && !length(loaded_nifsofts))
		send_message("Wczytywanie fabrycznych NIFSoftów, proszę czekać...")
		addtimer(CALLBACK(src, PROC_REF(install_preinstalled_nifsofts)), 3 SECONDS)

/obj/item/organ/cyberimp/nif/Remove(mob/living/carbon/organ_owner, special = FALSE)
	if(organ_owner && linked_mob == organ_owner)
		// Zasilanie z ciała nosiciela nie może zostać po wyjęciu (mnożnik głodu)
		if(nutrition_drain)
			toggle_nutrition_drain(TRUE)
		if(blood_drain)
			toggle_blood_drain(TRUE)
		if(calibration_blinded)
			organ_owner.cure_blind(NIF_SETUP_BLINDNESS)
			calibration_blinded = FALSE
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(!organ_owner)
		return

	organ_owner.log_message("utracił [src]", LOG_GAME)
	var/datum/component/nif_examine/found_component = organ_owner.GetComponent(/datum/component/nif_examine)
	if(found_component)
		qdel(found_component)

	if(linked_mob)
		UnregisterSignal(linked_mob, COMSIG_MOB_DEATH)

	QDEL_LIST(loaded_nifsofts)
	SStgui.close_uis(src)
	// wyjęty NIF nie trzyma byłego nosiciela: komunikaty i timery (fix_nif, send_message) już do niego nie idą
	linked_mob = null

/// Instaluje programy wgrane fabrycznie
/obj/item/organ/cyberimp/nif/proc/install_preinstalled_nifsofts()
	if(!length(preinstalled_nifsofts) || !owner)
		return FALSE

	for(var/preinstalled_nifsoft in preinstalled_nifsofts)
		new preinstalled_nifsoft(src)

	return TRUE

/obj/item/organ/cyberimp/nif/process(delta_time)
	if(!linked_mob || owner != linked_mob || broken || linked_mob.IsInStasis())
		return FALSE

	if(calibrating)
		perform_calibration()
		return

	if(nutrition_drain && linked_mob.nutrition < minimum_nutrition) // za mało odżywienia: wyłącz pobór
		toggle_nutrition_drain(TRUE)

	if(blood_drain && !blood_check()) // za mało krwi: wyłącz pobór
		toggle_blood_drain(TRUE)

	if(blood_drain)
		linked_mob.blood_volume -= blood_drain_rate

	if(power_usage > power_level)
		for(var/datum/nifsoft/nifsoft as anything in loaded_nifsofts)
			if(!nifsoft.active)
				continue
			nifsoft.activate()

	change_power_level(power_usage)

/// Zmienia zapas energii. Dodatnie power_to_change zużywa energię, ujemne ładuje
/obj/item/organ/cyberimp/nif/proc/change_power_level(power_to_change)
	if(!power_to_change)
		return TRUE

	if((!power_level && (power_to_change > 0)) || ((power_to_change < 0) && (power_level >= max_power_level)))
		return FALSE

	if(power_to_change > 0)
		power_level = max((power_level - power_to_change), NIF_MINIMUM_POWER_LEVEL)
		return TRUE

	power_level = min((power_level - power_to_change), max_power_level)
	return TRUE

/// Włącza albo wyłącza zasilanie z odżywienia. bypass pomija nutrition_check()
/obj/item/organ/cyberimp/nif/proc/toggle_nutrition_drain(bypass = FALSE)
	if(!bypass && !nutrition_check())
		return FALSE

	var/datum/physiology/physiology = linked_mob?.physiology
	if(nutrition_drain)
		if(physiology)
			physiology.hunger_mod /= nutrition_drain_rate
		power_usage += (nutrition_drain_rate * nutrition_conversion_rate)
		nutrition_drain = FALSE
		return TRUE

	if(physiology)
		physiology.hunger_mod *= nutrition_drain_rate
	power_usage -= (nutrition_drain_rate * nutrition_conversion_rate)
	nutrition_drain = TRUE
	return TRUE

/// Czy nosiciel ma odżywienie, z którego NIF może czerpać
/obj/item/organ/cyberimp/nif/proc/nutrition_check()
	if(!linked_mob || !linked_mob.nutrition)
		return FALSE

	if(HAS_TRAIT(linked_mob, TRAIT_NOHUNGER))
		return FALSE

	return linked_mob.nutrition >= minimum_nutrition

/// Włącza albo wyłącza zasilanie z krwi. bypass pomija blood_check()
/obj/item/organ/cyberimp/nif/proc/toggle_blood_drain(bypass = FALSE)
	if(!bypass && !blood_check())
		return

	blood_drain = !blood_drain

	if(!blood_drain)
		power_usage += (blood_drain_rate * blood_conversion_rate)
		linked_mob?.balloon_alert(linked_mob, "pobór krwi wyłączony")
		return

	power_usage -= (blood_drain_rate * blood_conversion_rate)
	linked_mob?.balloon_alert(linked_mob, "pobór krwi włączony")

/// Czy NIF może pobierać krew jako źródło energii
/obj/item/organ/cyberimp/nif/proc/blood_check()
	if(!linked_mob || !linked_mob.blood_volume || (linked_mob.blood_volume <= minimum_blood_level))
		return FALSE

	return TRUE

/// Kalibracja po pierwszym wszczepieniu: chwilowa ślepota, potem drobne skutki uboczne
/obj/item/organ/cyberimp/nif/proc/perform_calibration()
	if(linked_mob.stat >= DEAD)
		return FALSE

	if(!calibration_duration)
		calibration_duration = world.time + calibration_time

	var/percentage_done = (world.time - (calibration_duration - calibration_time)) / calibration_time
	switch(percentage_done)
		if(NIF_CALIBRATION_STAGE_1 to NIF_CALIBRATION_STAGE_1_END)
			if(!calibration_blinded)
				linked_mob.become_blind(NIF_SETUP_BLINDNESS)
				calibration_blinded = TRUE

		if(NIF_CALIBRATION_STAGE_2 to NIF_CALIBRATION_STAGE_2_END)
			if(calibration_blinded)
				linked_mob.cure_blind(NIF_SETUP_BLINDNESS)
				calibration_blinded = FALSE
			switch(rand(1, side_effect_risk))
				if(1)
					to_chat(linked_mob, span_warning("Robi ci się niedobrze!"))
					linked_mob.adjust_disgust(25)
				if(2)
					to_chat(linked_mob, span_warning("Zalewa cię fala zmęczenia!"))
					linked_mob.adjustStaminaLoss(25)

		if(NIF_CALIBRATION_STAGE_FINISHED to INFINITY)
			if(calibration_blinded)
				linked_mob.cure_blind(NIF_SETUP_BLINDNESS)
				calibration_blinded = FALSE
			send_message("Kalibracja zakończona.")
			calibrating = FALSE
			is_calibrated = TRUE
			if(length(preinstalled_nifsofts) && !length(loaded_nifsofts))
				install_preinstalled_nifsofts()

/// Dodaje program do NIF-u. Woła go /datum/nifsoft/New()
/obj/item/organ/cyberimp/nif/proc/install_nifsoft(datum/nifsoft/loaded_nifsoft)
	if(broken || calibrating) // na zepsuty albo kalibrujący się NIF nic się nie instaluje
		return FALSE

	if(length(loaded_nifsofts) >= max_nifsofts)
		send_message("Nie da się zainstalować więcej NIFSoftów. Odinstaluj któryś, żeby zrobić miejsce!", alert = TRUE)
		return FALSE

	if(!is_type_in_list(src, loaded_nifsoft.compatible_nifs))
		send_message("Program [loaded_nifsoft.name] nie jest zgodny z twoim NIF-em!", alert = TRUE)
		return FALSE

	for(var/datum/nifsoft/current_nifsoft as anything in loaded_nifsofts)
		if(loaded_nifsoft.single_install && (loaded_nifsoft.type == current_nifsoft.type))
			send_message("Programu [loaded_nifsoft.name] nie można zainstalować kilka razy.", alert = TRUE)
			return FALSE

		if(is_type_in_list(current_nifsoft, loaded_nifsoft.mutually_exclusive_programs))
			send_message("Program [current_nifsoft.name] blokuje instalację programu [loaded_nifsoft.name].", alert = TRUE)
			return FALSE

	loaded_nifsofts += loaded_nifsoft
	loaded_nifsoft.parent_nif = WEAKREF(src)
	loaded_nifsoft.linked_mob = linked_mob

	send_message("Dodano program [loaded_nifsoft.name].")
	update_static_data_for_all_viewers()
	return TRUE

/// Usuwa program z NIF-u. silent: bez komunikatu dla nosiciela
/obj/item/organ/cyberimp/nif/proc/remove_nifsoft(datum/nifsoft/removed_nifsoft, silent = FALSE)
	if(!(removed_nifsoft in loaded_nifsofts) || broken)
		return FALSE

	if(!silent)
		send_message("Usunięto program [removed_nifsoft.name].", alert = TRUE)

	qdel(removed_nifsoft)
	update_static_data_for_all_viewers()
	return TRUE

/// Zmienia wytrzymałość. Dodatnie wartości naprawiają, ujemne uszkadzają
/obj/item/organ/cyberimp/nif/proc/adjust_durability(adjustment_amount)
	if(!adjustment_amount || ((adjustment_amount > 0) && (durability >= max_durability)) || ((adjustment_amount < 0) && (durability <= NIF_MINIMUM_DURABILITY)))
		return FALSE

	if(adjustment_amount < 0)
		durability = max((durability + adjustment_amount), NIF_MINIMUM_DURABILITY)
		return TRUE

	durability = min((durability + adjustment_amount), max_durability)
	return TRUE

/// Wiadomość od NIF-u albo NIFSoftu do nosiciela
/obj/item/organ/cyberimp/nif/proc/send_message(message_to_send, alert = FALSE)
	if(!linked_mob)
		return
	var/nif_icon = icon2html('aquila/icons/monke/nif/nif_chat.dmi', linked_mob.client, chat_icon) || ""

	if(alert)
		to_chat(linked_mob, span_warning("[nif_icon] <b>Alarm NIF</b>: [message_to_send]"))
		linked_mob.playsound_local(get_turf(linked_mob), bad_sound, 60, FALSE)
		return

	to_chat(linked_mob, span_notice("[nif_icon] <b>Komunikat NIF</b>: [message_to_send]"))
	linked_mob.playsound_local(get_turf(linked_mob), good_sound, 60, FALSE)

/// Kończy chwilową awarię (broken). Nie dotyczy wytrzymałości
/obj/item/organ/cyberimp/nif/proc/fix_nif()
	if(!broken)
		return FALSE

	broken = FALSE
	send_message("Twój NIF znów działa!")
	return TRUE

/// Znów pozwala NIF-owi tracić wytrzymałość
/obj/item/organ/cyberimp/nif/proc/make_vulnerable()
	durability_loss_vulnerable = TRUE

// Okno NIF otwiera się tylko przyciskiem akcji wszczepionego implantu
/obj/item/organ/cyberimp/nif/attack_self(mob/user, modifiers)
	return FALSE

/obj/item/organ/cyberimp/nif/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, span_warning("Czujesz kłujący ból głowy!"))
	if(!durability_loss_vulnerable)
		return FALSE

	durability_loss_vulnerable = FALSE

	// Programy wyłączają się przed awarią: na zepsutym NIF-ie activate() nic nie robi (u Monke zostawały włączone)
	for(var/datum/nifsoft/installed_nifsoft as anything in loaded_nifsofts)
		installed_nifsoft.on_emp(severity)

	if(!broken)
		broken = TRUE
		addtimer(CALLBACK(src, PROC_REF(fix_nif)), 30 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(make_vulnerable)), 3 MINUTES)

	switch(severity)
		if(EMP_HEAVY)
			adjust_durability(-death_durability_loss)
		if(EMP_LIGHT)
			adjust_durability(-death_durability_loss / NIF_DURABILITY_LOSS_HALVED)

	send_message("<b>WYKRYTO ZAKŁÓCENIA ELEKTROMAGNETYCZNE.</b>", alert = TRUE)

/// Uszkadza NIF przy śmierci nosiciela
/obj/item/organ/cyberimp/nif/proc/damage_on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	if(!durability_loss_vulnerable)
		return FALSE

	adjust_durability(-death_durability_loss)
	durability_loss_vulnerable = FALSE

	addtimer(CALLBACK(src, PROC_REF(make_vulnerable)), 20 MINUTES) // dłuższa przerwa, żeby kolejne śmierci nie dobiły NIF-u od razu

/// Dodatkowy opis nosiciela NIF-u przy oględzinach
/datum/component/nif_examine
	/// Tekst widoczny przy oględzinach nosiciela
	var/nif_examine_text = NIF_DEFAULT_EXAMINE_TEXT

/datum/component/nif_examine/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(add_examine))

/datum/component/nif_examine/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	return ..()

/// Dopisuje tekst NIF-u do oględzin nosiciela
/datum/component/nif_examine/proc/add_examine(mob/nif_user, mob/looker, list/examine_texts)
	SIGNAL_HANDLER

	examine_texts += span_purple("<hr><b>[nif_examine_text]</b>")

/// Zwraca zainstalowany program danego typu albo FALSE
/mob/living/carbon/human/proc/find_nifsoft(nifsoft_to_find)
	var/obj/item/organ/cyberimp/nif/installed_nif = getorganslot(ORGAN_SLOT_BRAIN_NIF)
	if(!istype(installed_nif) || !length(installed_nif.loaded_nifsofts))
		return FALSE

	var/datum/nifsoft/located_nifsoft = locate(nifsoft_to_find) in installed_nif.loaded_nifsofts
	return located_nifsoft || FALSE

/// Autochirurg z NIF-em typu Standard
/obj/item/autosurgeon/nif
	name = "autochirurg z NIF typu Standard"
	desc = "Jednorazowy autochirurg z Nanitową Platformą Implantów typu Standard. Użyj go na sobie, żeby wszczepić NIF."
	starting_organ = list(/obj/item/organ/cyberimp/nif/standard)
	uses = 1

/// NIF do testów i komory testowej: od razu skalibrowany
/obj/item/organ/cyberimp/nif/debug
	is_calibrated = TRUE

/obj/item/autosurgeon/nif/debug
	name = "autochirurg z NIF testowym"
	starting_organ = list(/obj/item/organ/cyberimp/nif/debug)

#undef NIF_CALIBRATION_STAGE_1
#undef NIF_CALIBRATION_STAGE_1_END
#undef NIF_CALIBRATION_STAGE_2
#undef NIF_CALIBRATION_STAGE_2_END
#undef NIF_CALIBRATION_STAGE_FINISHED
#undef NIF_DURABILITY_LOSS_HALVED
#undef NIF_MINIMUM_DURABILITY
#undef NIF_MINIMUM_POWER_LEVEL
#undef NIF_SETUP_BLINDNESS
