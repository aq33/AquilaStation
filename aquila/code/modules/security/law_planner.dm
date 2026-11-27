// AQUILA - planer zarzutów (port pomysłu z /vg/station code/game/objects/items/sec_lawplanner.dm, sprite stamtąd w granacie Żandarmerii).
// Żandarm wybiera zarzuty z kodeksu (config/space_law.json), skanuje twarz zatrzymanego (kartoteka, czas od skucia)
// i przykłada planer do zegara celi: zegar dostaje osadzonego, zarzuty i wyrok. Czas od skucia tylko się pokazuje.

/mob/living/carbon
	/// world.time założenia kajdanek (najwcześniejsze, ponowne skucie nie resetuje)
	var/aq_cuffed_at

/obj/item/restraints/handcuffs/apply_cuffs(mob/living/carbon/target, mob/user, dispense = 0)
	. = ..()
	if(target.handcuffed && !target.aq_cuffed_at)
		target.aq_cuffed_at = world.time

/// Minuty od skucia albo null, gdy nie jest skuty
/mob/living/carbon/proc/aq_minutes_cuffed()
	if(!handcuffed)
		aq_cuffed_at = null
		return null
	if(!aq_cuffed_at)
		return null
	return round((world.time - aq_cuffed_at) / (1 MINUTES))

/obj/item/law_planner
	name = "planer zarzutów"
	desc = "Tablet Żandarmerii: zarzuty z kodeksu, wyrok, skan twarzy zatrzymanego. Przyłożony do zegara celi wpisuje osadzonego, zarzuty i czas."
	icon = 'aquila/icons/obj/security/law_planner.dmi'
	icon_state = "lawplanner"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	/// Wybrane artykuły kodeksu
	var/list/charges = list()
	/// Imię zeskanowanego zatrzymanego (z kartoteki)
	var/suspect_name

/obj/item/law_planner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Zarzuty: [length(charges) ? jointext(charges, ", ") : "brak"]. Wyrok: [DisplayTimeText(aq_sentence_for_crimes(charges), 1)].</span>"
	if(suspect_name)
		. += "<span class='notice'>Zatrzymany: [suspect_name].</span>"

/obj/item/law_planner/attack_self(mob/user)
	var/choice = tgui_alert(user, "Co zrobić?", name, list("Wybierz zarzuty", "Wyczyść"))
	if(!choice || !user.is_holding(src))
		return
	if(choice == "Wyczyść")
		charges = list()
		suspect_name = null
		say("Wyczyszczono.")
		return
	var/list/names = list()
	for(var/list/category as anything in get_space_law_catalog())
		for(var/list/crime as anything in category["crimes"])
			names += crime["name"]
	var/list/picked = tgui_input_checkboxes(user, "Zarzuty", name, names, 0)
	if(isnull(picked) || !user.is_holding(src))
		return
	charges = picked
	say(length(charges) ? "Zarzuty: [jointext(charges, ", ")]. Wyrok: [DisplayTimeText(aq_sentence_for_crimes(charges), 1)]." : "Brak zarzutów.")

/obj/item/law_planner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(ishuman(target))
		scan_suspect(target)
	else if(istype(target, /obj/machinery/door_timer))
		load_timer(target, user)

/// Skan twarzy: rekord z kartoteki, status i czas od skucia
/obj/item/law_planner/proc/scan_suspect(mob/living/carbon/human/suspect)
	var/face = suspect.get_face_name(null)
	if(!face)
		say("Błąd: nie da się odczytać twarzy.")
		return FALSE
	var/datum/data/record/record = find_record("name", face, GLOB.data_core.security)
	if(!record)
		say("Błąd: brak wpisu w kartotece dla: [face].")
		return FALSE
	suspect_name = face
	var/cuffed = suspect.aq_minutes_cuffed()
	say("Potwierdzono: [face], status: [aq_criminal_status_name(record.fields["criminal"])][isnull(cuffed) ? "" : ", skuty od [cuffed] min"].")
	return TRUE

/// Wpisuje zatrzymanego, zarzuty i wyrok do zegara celi (zegar musi stać)
/obj/item/law_planner/proc/load_timer(obj/machinery/door_timer/cell, mob/user)
	if(!cell.allowed(user))
		to_chat(user, "<span class='warning'>Odmowa dostępu.</span>")
		return FALSE
	if(cell.timing || !isnull(cell.paused_left))
		say("Błąd: zegar celi już odlicza.")
		return FALSE
	if(!length(charges))
		say("Błąd: brak zarzutów.")
		return FALSE
	if(suspect_name)
		cell.prisoner_name = suspect_name
	cell.prisoner_crimes = jointext(charges, ", ")
	var/sentence = aq_sentence_for_crimes(charges)
	if(sentence)
		cell.set_timer(sentence)
	cell.ui_update()
	say("Wgrano do zegara ([cell.cell_label()]): [cell.prisoner_name || "bez imienia"], [cell.prisoner_crimes], [DisplayTimeText(sentence, 1)].")
	return TRUE
