/// Danger event - unskippable, if you have appriopriate tool you can mitigate damage.
/datum/exploration_event/simple/danger
	abstract_type = /datum/exploration_event/simple/danger
	description = "Natrafiasz na gigantyczny błąd."
	var/required_tool = EXODRONE_TOOL_LASER
	var/has_tool_action_text = "Walcz"
	var/no_tool_action_text = "Przetrwaj"
	var/has_tool_description = ""
	var/no_tool_description = ""
	var/avoid_log = "Uniknięto niebezpieczeństwa bez szkód."
	var/damage = 30
	skippable = FALSE

/datum/exploration_event/simple/danger/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_parts = list(.)
	desc_parts += can_escape_danger(drone) ? has_tool_description : no_tool_description
	return desc_parts.Join("\n")

/datum/exploration_event/simple/danger/get_action_text(obj/item/exodrone/drone)
	return can_escape_danger(drone) ? has_tool_action_text : no_tool_action_text

/datum/exploration_event/simple/danger/proc/can_escape_danger(obj/item/exodrone/drone)
	return !required_tool || drone.has_tool(required_tool)

/datum/exploration_event/simple/danger/fire(obj/item/exodrone/drone)
	if(can_escape_danger(drone))
		drone.drone_log(avoid_log)
	else
		drone.damage(damage)
	end(drone)

/// Danger events
/datum/exploration_event/simple/danger/carp
	name = "atak kosmicznego karpia"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	deep_scan_description = "Ślady uszkodzeń w tym miejscu wskazują na obecność kosmicznych karpi."
	description = "Atakuje cię samotny kosmiczny karp!"
	has_tool_action_text = "Walcz"
	no_tool_action_text = "Uciekaj!"
	has_tool_description = "Ładujesz laser, żeby go odpędzić."
	no_tool_description = "Bez broni możesz tylko spróbować szybkiej ucieczki!"
	avoid_log = "Pokonano kosmicznego karpia."

/// They get everywhere
/datum/exploration_event/simple/danger/carp/surface_variety
	required_site_traits = list(EXPLORATION_SITE_SURFACE)

/datum/exploration_event/simple/danger/assistant
	name = "atak asystenta"
	required_site_traits = list(EXPLORATION_SITE_STATION)
	deep_scan_description = "Wykryty współczynnik użycia masek gazowych sugeruje spory tłum podejrzanych typów."
	description = "Natrafiasz na kudłatą istotę w szarym kombinezonie! To obłąkany asystent!"
	has_tool_action_text = "Walcz"
	no_tool_action_text = "Uciekaj!"
	has_tool_description = "Ładujesz laser, żeby go odpędzić."
	no_tool_description = "Bez broni możesz tylko spróbować szybkiej ucieczki!"
	avoid_log = "Pokonano asystenta."

/datum/exploration_event/simple/danger/collapse
	name = "zawalenie"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	deep_scan_description = "Skan wskazuje, że konstrukcja jest w złym stanie. Zalecana ostrożność."
	description = "Gdy przeszukujesz niezbadany korytarz, zapada się uszkodzony strop! Gruz odcina ci drogę."
	has_tool_action_text = "Przekop się"
	no_tool_action_text = "Przeciśnij się"
	has_tool_description = "Możesz wydostać się wiertłem."
	no_tool_description = "Bez narzędzi przeciśniesz się tylko kosztem kilku zdartych części."
	avoid_log = "Przekopano się przez zawalony korytarz."

/datum/exploration_event/simple/danger/loose_wires
	name = "luźne przewody"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Skany wykrywają dużo uszkodzonego okablowania."
	description = "Za tobą coś głośno trzaska! Drogę wyjścia blokuje plątanina iskrzących przewodów wysokiego napięcia."
	has_tool_action_text = "Odetnij zasilanie"
	no_tool_action_text = "Daj się usmażyć"
	has_tool_description = "Możesz spróbować odciąć zasilanie multitoolem i uciec."
	no_tool_description = "Przy wyjściu zaryzykujesz usmażenie elektroniki."
	avoid_log = "Ominięto luźne przewody."

/datum/exploration_event/simple/danger/cosmic_rays
	name = "rozbłysk promieniowania kosmicznego"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Miejsce jest wystawione na promieniowanie kosmiczne. Zalecana nakładka diagnostyczna z multitoolem."
	description = "Obraz z drona nagle wariuje! Wygląda na to, że trafił go rozbłysk promieniowania kosmicznego. Musisz poczekać, aż sygnał wróci."
	has_tool_description = "Multitool powinien sam naprawić dużą część uszkodzeń."
	no_tool_description = "Nie zostaje nic innego, niż czekać i ocenić szkody."
	has_tool_action_text = "Czekaj"
	no_tool_action_text = "Czekaj"
	avoid_log = "Multitool zapobiegł uszkodzeniom od promieniowania kosmicznego."

/datum/exploration_event/simple/danger/alien_sentry
	name = "zabezpieczenie obcych"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	deep_scan_description = "Wykryto automatyczne zabezpieczenia nieznanego pochodzenia."
	description = "Z podłogi wysuwa się groźnie wyglądająca maszyna, wyświetla dziwne glify i wydaje wysoki pisk!"
	has_tool_description = "Tłumacz rozpoznaje w glifach wezwanie ochrony i radzi przedstawić się jako gość."
	no_tool_description = "Wkrótce maszyna zaczyna strzelać."
	has_tool_action_text = "Przedstaw się"
	no_tool_action_text = "Uciekaj"
	avoid_log = "Uniknięto zabezpieczeń obcych."

/datum/exploration_event/simple/danger/beast
	name = "spotkanie z obcym"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	blacklisted_site_traits = list(EXPLORATION_SITE_CIVILIZED)
	required_tool = EXODRONE_TOOL_LASER
	deep_scan_description = "Wykryto groźną faunę."
	description = "Natrafiasz na dziwne stworzenie: BEAST! Szykuje się do ataku."
	has_tool_action_text = "Walcz"
	no_tool_action_text = "Uciekaj"
	has_tool_description = "Szykujesz laser."
	no_tool_description = "Bez broni możesz tylko spróbować szybkiej ucieczki!"
	avoid_log = "Pokonano stworzenie: BEAST."

/datum/exploration_event/simple/danger/beast/New()
	. = ..()
	var/beast_name = pick_list(EXODRONE_FILE, "alien_fauna")
	description = replacetext(description, "BEAST", beast_name)
	avoid_log = replacetext(avoid_log, "BEAST", beast_name)

/datum/exploration_event/simple/danger/rad
	name = "napromieniowana sekcja"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_MULTITOOL
	deep_scan_description = "Skany wskazują na niebezpieczne promieniowanie."
	description = "Wchodzisz do niepozornej sekcji statku."
	has_tool_action_text = "Obejdź"
	no_tool_action_text = "Uciekaj i ogranicz szkody"
	has_tool_description = "Multitool nagle błyska ostrzeżeniem! Sekcja przed tobą jest napromieniowana, trzeba ją obejść."
	no_tool_description = "Nagle dron zgłasza poważne uszkodzenia. Ta sekcja musiała być mocno napromieniowana."
	avoid_log = "Ominięto napromieniowaną sekcję."
