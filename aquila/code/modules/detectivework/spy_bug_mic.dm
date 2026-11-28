// AQUILA - pluskwa z mikrofonem (Baystation12 code/game/objects/items/devices/spy_bug.dm; papierosowa wersja z /vg/station).
// Etui na długopisy z zestawu okularów szpiegowskich detektywa ma już kamerę; dostaje mikrofon, który nadaje
// to, co słychać tuż obok (1 kratka), na prywatnej częstotliwości. Odsłuch: dowolne radio ustawione na tę częstotliwość.
// Antagowie kupują w uplinku samą pluskwę radiową udającą paczkę papierosów.

/// Wspólna logika mikrofonu: nadaje mowę z odległości 1 na ustawioną częstotliwość
/obj/item/radio/aq_bug_mic
	name = "mikrofon pluskwy"
	canhear_range = 1
	broadcasting = TRUE
	listening = FALSE
	radio_silent = TRUE

/obj/item/radio/aq_bug_mic/Initialize(mapload)
	. = ..()
	set_frequency(aq_random_bug_frequency())

/// Wolna częstotliwość spoza kanałów działów (kHz × 10, jak w radiu)
/proc/aq_random_bug_frequency()
	var/freq = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(!(freq % 2)) // radio używa nieparzystych
		freq++
	return sanitize_frequency(freq, TRUE)

/obj/item/clothing/accessory/spy_bug
	/// Mikrofon w środku
	var/obj/item/radio/aq_bug_mic/microphone

/obj/item/clothing/accessory/spy_bug/Initialize(mapload)
	. = ..()
	microphone = new(src)
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	desc = "Zaawansowany sprzęt szpiegowski w kształcie kieszonkowego etui na długopisy. Ma wbudowaną kamerę 360 stopni i mikrofon, który nadaje na prywatnej częstotliwości."

/obj/item/clothing/accessory/spy_bug/Destroy()
	QDEL_NULL(microphone)
	return ..()

/obj/item/clothing/accessory/spy_bug/examine(mob/user)
	. = ..()
	if(microphone)
		. += "<span class='notice'>Mikrofon nadaje na [format_frequency(microphone.frequency)]. Użyj w ręce, żeby zmienić częstotliwość.</span>"

/obj/item/clothing/accessory/spy_bug/attack_self(mob/user)
	if(!microphone)
		return ..()
	var/new_freq = tgui_input_number(user, "Częstotliwość mikrofonu (np. 145.9)", name, microphone.frequency / 10, MAX_FREE_FREQ / 10, MIN_FREE_FREQ / 10, round_value = FALSE)
	if(isnull(new_freq) || !user.is_holding(src))
		return
	microphone.set_frequency(sanitize_frequency(round(new_freq * 10), TRUE))
	to_chat(user, "<span class='notice'>Mikrofon nadaje teraz na [format_frequency(microphone.frequency)].</span>")

/obj/item/clothing/accessory/spy_bug/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(radio_freq || !microphone || get_dist(get_turf(src), get_turf(speaker)) > microphone.canhear_range)
		return
	microphone.talk_into(speaker, raw_message, , spans, language = message_language, message_mods = message_mods)

/// Pluskwa radiowa dla antagonistów: wygląda jak paczka papierosów
/obj/item/radio/aq_bug_mic/cigarettes
	name = "paczka papierosów"
	desc = "Paczka papierosów. Ciężka jak na paczkę papierosów."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	w_class = WEIGHT_CLASS_TINY

/obj/item/radio/aq_bug_mic/cigarettes/examine(mob/user)
	. = ..()
	if(user.mind?.has_antag_datum(/datum/antagonist))
		. += "<span class='notice'>Ukryty mikrofon nadaje na [format_frequency(frequency)]. Ustaw tę częstotliwość na swoim radiu.</span>"

/datum/uplink_item/device_tools/aq_cigarette_bug
	name = "Pluskwa w paczce papierosów"
	desc = "Mikrofon udający paczkę papierosów. Podrzuć go blisko rozmówców i ustaw jego częstotliwość na swoim radiu."
	item = /obj/item/radio/aq_bug_mic/cigarettes
	cost = 1
