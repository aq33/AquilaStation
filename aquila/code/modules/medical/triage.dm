// AQUILA - tagi triage. Pomysł z Goona (tagger) i tg (karty w NanoMed), kod własny.
// Tag to samoprzylepna karteczka: przykleja się na pacjenta, widać ją na sprite'cie i w examine, długopisem można dopisać notatkę.

/obj/item/sticker/sticky_note/triage
	name = "tag triage"
	desc = "Samoprzylepny tag do segregacji rannych. Przyklej go na pacjenta, a długopisem dopisz notatkę."
	sticker_icon_state = "sticky_note_sticker_written"
	roll_unusual = FALSE
	/// Kategoria na tagu, wielkimi literami
	var/category = "?"
	/// Kolor tekstu kategorii w examine
	var/text_color = "#ffffff"
	/// Kogo oznacza tag (dla examine pacjenta)
	var/mob/living/tagged

/obj/item/sticker/sticky_note/triage/Destroy()
	untag()
	return ..()

/obj/item/sticker/sticky_note/triage/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kategoria: <b><font color='[text_color]'>[category]</font></b>.</span>"
	. += "<span class='info'>Algorytm START:\n\
		- chodzi samodzielnie: <font color='#4caf50'><b>ZIELONY</b></font> (lekki),\n\
		- nie oddycha mimo udrożnienia dróg oddechowych: <b>CZARNY</b> (zmarły),\n\
		- szybki oddech, brak tętna, silne krwawienie albo nie wykonuje poleceń: <font color='#e53935'><b>CZERWONY</b></font> (natychmiast),\n\
		- pozostali: <font color='#ffd23f'><b>ŻÓŁTY</b></font> (opóźniony).</span>"

// Na żywym celu tag się przykleja zamiast uderzać. W trybie walki zostaje zwykły atak.
/obj/item/sticker/sticky_note/triage/pre_attack(atom/A, mob/living/user, params)
	if(!isliving(A) || user.combat_mode)
		return ..()
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	tag_patient(A, user, params)
	return FALSE

// W trybie walki odziedziczone przyklejanie z afterattack też jest wyłączone, inaczej tag lądowałby obok starego.
/obj/item/sticker/sticky_note/triage/afterattack(atom/target, mob/user, proximity_flag, list/modifiers)
	if(isliving(target) && user.combat_mode)
		return
	return ..()

/// Przykleja tag na pacjenta. Poprzedni tag triage spada na podłogę.
/obj/item/sticker/sticky_note/triage/proc/tag_patient(mob/living/patient, mob/user, params)
	for(var/obj/item/sticker/sticky_note/triage/old_tag in patient.contents.Copy())
		if(old_tag.sticker_state != STICKER_STATE_STUCK)
			continue
		old_tag.unstick()
		old_tag.forceMove(patient.drop_location())
	var/list/modifiers = params2list(params)
	var/x_offset = text2num(LAZYACCESS(modifiers, ICON_X)) || (16 + rand(-4, 4))
	var/y_offset = text2num(LAZYACCESS(modifiers, ICON_Y)) || (18 + rand(-3, 3))
	stick_to(patient, x_offset, y_offset)
	if(user)
		user.visible_message("<span class='notice'>[user] przykleja [src] na [patient].</span>", "<span class='notice'>Przyklejasz [src] na [patient].</span>")

/obj/item/sticker/sticky_note/triage/stick_to(atom/movable/target, x_offset, y_offset)
	. = ..()
	if(isliving(target))
		tagged = target
		RegisterSignal(tagged, COMSIG_PARENT_EXAMINE, PROC_REF(on_patient_examine))

/obj/item/sticker/sticky_note/triage/unstick(atom/override)
	untag()
	return ..()

/obj/item/sticker/sticky_note/triage/proc/untag()
	if(!tagged)
		return
	UnregisterSignal(tagged, COMSIG_PARENT_EXAMINE)
	tagged = null

/obj/item/sticker/sticky_note/triage/proc/on_patient_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='notice'>Ma przyklejony tag triage: <b><font color='[text_color]'>[category]</font></b>.</span>"

/obj/item/sticker/sticky_note/triage/minor
	name = "zielony tag triage"
	category = "LEKKI"
	tint = "#4caf50"
	text_color = "#4caf50"

/obj/item/sticker/sticky_note/triage/delayed
	name = "żółty tag triage"
	category = "OPÓŹNIONY"
	tint = "#ffd23f"
	text_color = "#ffd23f"

/obj/item/sticker/sticky_note/triage/immediate
	name = "czerwony tag triage"
	category = "NATYCHMIAST"
	tint = "#e53935"
	text_color = "#e53935"

/obj/item/sticker/sticky_note/triage/dead
	name = "czarny tag triage"
	category = "ZMARŁY"
	tint = "#3a3a3a"
	text_color = "#9e9e9e"

// --- Bloczki i pudełko ---

/obj/item/sticky_note_pile/triage
	name = "bloczek tagów triage"
	desc = "Bloczek samoprzylepnych tagów triage."
	current_notes = 15

/obj/item/sticky_note_pile/triage/minor
	name = "bloczek zielonych tagów triage"
	color = "#4caf50"
	note_type = /obj/item/sticker/sticky_note/triage/minor

/obj/item/sticky_note_pile/triage/delayed
	name = "bloczek żółtych tagów triage"
	color = "#ffd23f"
	note_type = /obj/item/sticker/sticky_note/triage/delayed

/obj/item/sticky_note_pile/triage/immediate
	name = "bloczek czerwonych tagów triage"
	color = "#e53935"
	note_type = /obj/item/sticker/sticky_note/triage/immediate

/obj/item/sticky_note_pile/triage/dead
	name = "bloczek czarnych tagów triage"
	color = "#3a3a3a"
	note_type = /obj/item/sticker/sticky_note/triage/dead

/obj/item/storage/box/triage
	name = "pudełko tagów triage"
	desc = "Cztery bloczki tagów do szybkiej segregacji rannych: zielone, żółte, czerwone i czarne."
	illustration = "writing"

/obj/item/storage/box/triage/PopulateContents()
	new /obj/item/sticky_note_pile/triage/minor(src)
	new /obj/item/sticky_note_pile/triage/delayed(src)
	new /obj/item/sticky_note_pile/triage/immediate(src)
	new /obj/item/sticky_note_pile/triage/dead(src)

// --- Tagger ---

/obj/item/triage_tagger
	name = "triage tagger"
	desc = "Ręczne urządzenie, które drukuje i przykleja tagi triage. Użyj w ręce, by wybrać kategorię."
	icon = 'aquila/icons/obj/sec_med/sec_med.dmi'
	icon_state = "triage_tagger"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200)
	/// Wybrany typ tagu, null oznacza zdejmowanie tagów
	var/obj/item/sticker/sticky_note/triage/selected = /obj/item/sticker/sticky_note/triage/minor

/obj/item/triage_tagger/examine(mob/user)
	. = ..()
	if(selected)
		. += "<span class='notice'>Wybrany tag: <b><font color='[initial(selected.text_color)]'>[initial(selected.category)]</font></b>.</span>"
	else
		. += "<span class='notice'>Tryb: zdejmowanie tagów.</span>"

/obj/item/triage_tagger/attack_self(mob/user)
	var/static/list/choices
	if(!choices)
		choices = list()
		for(var/obj/item/sticker/sticky_note/triage/tag_type as anything in subtypesof(/obj/item/sticker/sticky_note/triage))
			var/image/tag_image = image(icon = initial(tag_type.icon), icon_state = initial(tag_type.icon_state))
			tag_image.color = initial(tag_type.tint)
			choices[initial(tag_type.category)] = tag_image
		choices["Zdejmij"] = image(icon = 'icons/mob/radial.dmi', icon_state = "delete")
	var/choice = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(src) || !user.is_holding(src))
		return
	selected = null
	for(var/obj/item/sticker/sticky_note/triage/tag_type as anything in subtypesof(/obj/item/sticker/sticky_note/triage))
		if(initial(tag_type.category) == choice)
			selected = tag_type
	balloon_alert(user, selected ? lowertext(choice) : "zdejmowanie")

/obj/item/triage_tagger/pre_attack(atom/A, mob/living/user, params)
	if(!isliving(A))
		return ..()
	var/mob/living/patient = A
	if(!selected)
		var/removed = FALSE
		for(var/obj/item/sticker/sticky_note/triage/old_tag in patient.contents.Copy())
			if(old_tag.sticker_state == STICKER_STATE_STUCK)
				qdel(old_tag)
				removed = TRUE
		if(removed)
			playsound(src, 'sound/items/poster_ripped.ogg', 30, TRUE)
			user.visible_message("<span class='notice'>[user] zdejmuje tag triage z [patient].</span>", "<span class='notice'>Zdejmujesz tag triage z [patient].</span>")
		else
			balloon_alert(user, "brak tagu!")
		return FALSE
	var/obj/item/sticker/sticky_note/triage/new_tag = new selected(drop_location())
	new_tag.tag_patient(patient, user, params)
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return FALSE

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/storage/box/triage] = 2
	products[/obj/item/triage_tagger] = 2
	return ..()
