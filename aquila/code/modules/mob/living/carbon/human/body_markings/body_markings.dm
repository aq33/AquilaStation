// AQUILA - markingi przypisane do kończyn (wzór: Skyrat/Nova /datum/body_marking).
// Gracz wybiera w oknie postaci do AQ_MARKINGS_PER_ZONE markingów na każdą część ciała, każdy z własnym kolorem.
// Zapis: features["aq_markings"] jako JSON {strefa: [[id, kolor], ...]}, więc markingi idą razem z DNA (klonowanie, zmiana wyglądu).
// Rysuje je kończyna (get_limb_icon) na warstwie skóry, pod bielizną i ubraniem, więc odcięta kończyna zabiera swoje markingi.
// Markingi gatunkowe (lizard_markings, moth_markings, paski apida) działają dalej osobno.

#define AQ_BODY_MARKINGS_ICON 'aquila/icons/mob/body_markings_extra.dmi'
/// Ile markingów gracz może nałożyć na jedną część ciała
#define AQ_MARKINGS_PER_ZONE 3
/// Klucz w features postaci i w dna.features
#define AQ_MARKINGS_FEATURE "aq_markings"

/// id -> /datum/aq_body_marking
GLOBAL_LIST_INIT(aq_body_markings, init_aq_body_markings())
/// Części ciała w oknie postaci, w tej kolejności. Dłonie rysuje ręka na warstwie dłoni.
GLOBAL_LIST_INIT(aq_body_marking_zones, list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))

/datum/aq_body_marking
	/// Początek nazwy stanu w AQ_BODY_MARKINGS_ICON: "[id]_[strefa]", tors "[id]_chest_m" i "[id]_chest_f"
	var/id
	/// Nazwa w oknie postaci
	var/name
	/// Części ciała z GLOB.aq_body_marking_zones, dla których marking ma sprite
	var/list/zones = list()

/proc/init_aq_body_markings()
	var/list/output = list()
	for(var/marking_type in subtypesof(/datum/aq_body_marking))
		var/datum/aq_body_marking/marking = new marking_type
		if(!marking.id)
			continue
		output[marking.id] = marking
	return output

/// Tekst z features -> list(strefa = list(list(id, "#kolor"), ...)). Odrzuca nieznane markingi, złe strefy i nadmiar ponad limit.
/proc/aq_markings_decode(text)
	var/list/output = list()
	if(!istext(text) || !length(text))
		return output
	var/list/decoded
	try
		decoded = json_decode(text)
	catch
		return output
	if(!islist(decoded))
		return output
	for(var/zone in GLOB.aq_body_marking_zones)
		var/list/entries = decoded[zone]
		if(!islist(entries))
			continue
		var/list/valid = list()
		for(var/list/entry in entries)
			if(length(valid) >= AQ_MARKINGS_PER_ZONE)
				break
			if(length(entry) < 2 || !istext(entry[1]))
				continue
			var/datum/aq_body_marking/marking = GLOB.aq_body_markings[entry[1]]
			if(!marking || !(zone in marking.zones))
				continue
			valid += list(list(marking.id, sanitize_hexcolor(entry[2], 6, TRUE, "#FFFFFF")))
		if(length(valid))
			output[zone] = valid
	return output

/// list(strefa = list(list(id, kolor), ...)) -> tekst do features. Bez markingów pusty tekst.
/proc/aq_markings_encode(list/markings)
	var/list/output = list()
	for(var/zone in GLOB.aq_body_marking_zones)
		if(length(markings?[zone]))
			output[zone] = markings[zone]
	return length(output) ? json_encode(output) : ""

/// Czy rasa może mieć markingi na kończynach (kolorowalna skóra albo futro)
/datum/species
	var/aq_body_markings = FALSE

/datum/species/human
	aq_body_markings = TRUE

/datum/species/lizard
	aq_body_markings = TRUE

/datum/species/moth
	aq_body_markings = TRUE

/datum/species/apid
	aq_body_markings = TRUE

/datum/species/simian
	aq_body_markings = TRUE

/datum/species/squid
	aq_body_markings = TRUE

/obj/item/bodypart
	/// Markingi tej kończyny: list(list(id, kolor, strefa)). Strefa dłoni to aux_zone ręki.
	var/list/aq_markings

/obj/item/bodypart/update_limb(dropping_limb, mob/living/carbon/source, is_creating = FALSE)
	. = ..()
	if(!is_creating)
		return
	if(!source && original_owner && !IS_WEAKREF_OF(owner, original_owner)) // obca kończyna zostaje przy swoich markingach
		return
	var/mob/living/carbon/human/human_owner = source || owner
	aq_markings = null
	if(!istype(human_owner) || animal_origin || !human_owner.dna?.species?.aq_body_markings)
		return
	var/list/markings = aq_markings_decode(human_owner.dna.features[AQ_MARKINGS_FEATURE])
	for(var/zone in list(body_zone, aux_zone))
		if(!zone)
			continue
		for(var/list/entry in markings[zone])
			LAZYADD(aq_markings, list(list(entry[1], entry[2], zone)))

/obj/item/bodypart/get_limb_icon(dropped)
	. = ..()
	if(!length(aq_markings) || !length(.) || is_husked || animal_origin || !IS_ORGANIC_LIMB(src))
		return
	if(limb_id == "digitigrade") // sprite'y są pod proste nogi, na nogach jaszczura wisiałyby w powietrzu
		return
	var/image_dir = dropped ? SOUTH : 0
	for(var/list/entry in aq_markings)
		var/zone = entry[3]
		var/state = zone == BODY_ZONE_CHEST ? "[entry[1]]_chest_[limb_gender == "f" ? "f" : "m"]" : "[entry[1]]_[zone]"
		var/image/marking = image(AQ_BODY_MARKINGS_ICON, state, -(zone == aux_zone ? aux_layer : BODYPARTS_LAYER), image_dir)
		marking.color = entry[2]
		. += marking

/// Inne markingi = inna ikona kończyny w pamięci podręcznej
/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	for(var/list/entry in BP.aq_markings)
		. += "-[entry[1]][entry[2]]"
