// Narzędzia do pH i czystości z tg (tgstation@b3949ec362, reagents/chemistry/items.dm)

///if the ph_meter gives a detailed output
#define DETAILED_CHEM_OUTPUT 1
///if the pH meter gives a shorter output
#define SHORTENED_CHEM_OUTPUT 0

/// Converts pH to universal indicator colours (tg CONVERT_PH_TO_COLOR)
/proc/ph_to_color(ph)
	switch(ph)
		if(14 to INFINITY)
			return "#462c83"
		if(13 to 14)
			return "#63459b"
		if(12 to 13)
			return "#5a51a2"
		if(11 to 12)
			return "#3853a4"
		if(10 to 11)
			return "#3f93cf"
		if(9 to 10)
			return "#0bb9b7"
		if(8 to 9)
			return "#23b36e"
		if(7 to 8)
			return "#3aa651"
		if(6 to 7)
			return "#4cb849"
		if(5 to 6)
			return "#b5d335"
		if(4 to 5)
			return "#f7ec1e"
		if(3 to 4)
			return "#fbc314"
		if(2 to 3)
			return "#f26724"
		if(1 to 2)
			return "#ef1d26"
	return "#c6040c"

/// Converts pH to a tgui color name
/proc/convert_ph_to_readable_color(ph)
	switch(ph)
		if(-INFINITY to 1)
			return "red"
		if(1 to 2)
			return "orange"
		if(2 to 3)
			return "average"
		if(3 to 4)
			return "yellow"
		if(4 to 5)
			return "olive"
		if(5 to 6)
			return "good"
		if(6 to 8)
			return "green"
		if(8 to 9.5)
			return "teal"
		if(9.5 to 11)
			return "blue"
		if(11 to 12.5)
			return "violet"
	return "purple"

/*
* a pH booklet that contains pH paper pages that will change color depending on the pH of the reagents datum it's attacked onto
*/
/obj/item/ph_booklet
	name = "pH indicator booklet"
	desc = "Książeczka z papierkami nasączonymi wskaźnikiem uniwersalnym. Weź ją do ręki i kliknij, żeby wyrwać papierek."
	icon_state = "pHbooklet"
	icon = 'aquila/icons/obj/chemistry/ph_tools.dmi'
	item_flags = NOBLUDGEON
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	///How many pages the booklet holds
	var/number_of_pages = 50

/obj/item/ph_booklet/attack_hand(mob/user)
	if(user.is_holding(src))
		tear_page(user)
		return
	return ..()

/obj/item/ph_booklet/MouseDrop(atom/over_object)
	. = ..()
	if(isliving(usr) && usr.canUseTopic(src, BE_CLOSE))
		tear_page(usr)

/// Takes one pH paper out of the booklet
/obj/item/ph_booklet/proc/tear_page(mob/user)
	if(!number_of_pages)
		to_chat(user, "<span class='warning'>[src] jest pusta!</span>")
		add_fingerprint(user)
		return
	if(number_of_pages == initial(number_of_pages))
		icon_state = "pHbooklet_open"
	var/obj/item/ph_paper/page = new(get_turf(user))
	page.add_fingerprint(user)
	user.put_in_hands(page)
	to_chat(user, "<span class='notice'>Wyrywasz [page] z [src].</span>")
	number_of_pages--
	playsound(user.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	add_fingerprint(user)
	if(!number_of_pages)
		icon_state = "pHbooklet_emtpy"

/*
* pH paper will change color depending on the pH of the reagents datum it's attacked onto
*/
/obj/item/ph_paper
	name = "pH indicator strip"
	desc = "Pasek papieru, który zmienia kolor zależnie od pH roztworu."
	icon_state = "pHpaper"
	icon = 'aquila/icons/obj/chemistry/ph_tools.dmi'
	item_flags = NOBLUDGEON
	color = "#f5c352"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY
	///If the paper was used, and therefore cannot change color again
	var/used = FALSE

/obj/item/ph_paper/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target, /obj/item/reagent_containers))
		return
	var/obj/item/reagent_containers/cont = target
	if(!LAZYLEN(cont.reagents?.reagent_list))
		return
	if(used)
		to_chat(user, "<span class='warning'>[src] był już użyty!</span>")
		return
	var/ph = round(cont.reagents.ph, 1)
	color = ph_to_color(ph)
	desc += " Wygląda na pH około [ph]."
	name = "used [name]"
	used = TRUE
	return TRUE

/*
* pH meter that will give a detailed or truncated analysis of all the reagents in of an object with a reagents datum attached to it. Only way of detecting purity for now.
*/
/obj/item/ph_meter
	name = "chemical analyzer"
	desc = "Elektroda podłączona do małej skrzynki z układem, która wyświetla szczegóły roztworu: pH, temperaturę i czystość każdego odczynnika. Można przełączyć, czy ma pokazywać opisy odczynników."
	icon_state = "pHmeter"
	icon = 'aquila/icons/obj/chemistry/ph_tools.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass = 2500, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	///level of detail for output for the meter
	var/scanmode = DETAILED_CHEM_OUTPUT

/obj/item/ph_meter/attack_self(mob/user)
	if(scanmode == SHORTENED_CHEM_OUTPUT)
		to_chat(user, "<span class='notice'>Analizator będzie teraz pokazywał opis każdego odczynnika.</span>")
		scanmode = DETAILED_CHEM_OUTPUT
	else
		to_chat(user, "<span class='notice'>Analizator nie będzie już pokazywał opisów odczynników.</span>")
		scanmode = SHORTENED_CHEM_OUTPUT

/obj/item/ph_meter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target, /obj/item/reagent_containers))
		return
	var/obj/item/reagent_containers/cont = target
	if(!LAZYLEN(cont.reagents?.reagent_list))
		return
	var/list/out_message = list()
	to_chat(user, "<i>Analizator chemiczny pika i wyświetla:</i>")
	out_message += "<b>Objętość: [round(cont.reagents.total_volume, 0.01)]u, temperatura: [round(cont.reagents.chem_temp, 0.1)] K, pH: [round(cont.reagents.ph, 0.01)]</b>"
	out_message += "<b>Chemikalia w [target.name]:</b>"
	if(cont.reagents.is_reacting)
		out_message += "<span class='warning'>W środku trwa reakcja.</span>"
	for(var/datum/reagent/reagent as anything in cont.reagents.reagent_list)
		var/details = scanmode ? "[reagent.overdose_threshold ? "<b>Przedawkowanie:</b> [reagent.overdose_threshold]u, " : ""]<b>Bazowe pH:</b> [initial(reagent.ph)], <b>Obecne pH:</b> [round(reagent.ph, 0.01)]." : "<b>Obecne pH:</b> [round(reagent.ph, 0.01)]."
		if(reagent.inverse_chem && reagent.purity < reagent.inverse_chem_val) //If the reagent is impure
			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			out_message += "<span class='warning'>Wykryto odwrócony odczynnik:</span> <b>[round(reagent.volume, 0.01)]u [inverse_reagent.name]</b>, <b>Czystość:</b> [round(1 - reagent.purity, 0.0001) * 100]%, [details]"
		else
			out_message += "<b>[round(reagent.volume, CHEMICAL_VOLUME_ROUNDING)]u [reagent.name]</b>, <b>Czystość:</b> [round(reagent.purity, 0.0001) * 100]%, [details]"
		if(scanmode)
			out_message += "<b>Analiza:</b> [reagent.description]"
	to_chat(user, "<div class='examine_block'><span class='notice'>[out_message.Join("<br>")]</span></div>")
	desc = "Elektroda podłączona do małej skrzynki z układem. Ekran pokazuje: objętość [round(cont.reagents.total_volume, 0.01)]u, pH [round(cont.reagents.ph, 0.1)]."
	return TRUE

#undef DETAILED_CHEM_OUTPUT
#undef SHORTENED_CHEM_OUTPUT
