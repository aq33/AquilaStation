/// Simple event type that checks if you have a tool and after a retrieval delay adds loot to drone.
/datum/exploration_event/simple/resource
	name = "surowiec do odzyskania"
	abstract_type = /datum/exploration_event/simple/resource
	discovery_log = "Natrafiono na surowiec do odzyskania."
	action_text = "Wydobądź"
	/// Tool type required to recover this resource
	var/required_tool
	/// What you get out of it, either /obj path or adventure_loot_generator id
	var/loot_type = /obj/item/trash/chips
	/// Message logged on success
	var/success_log = "Coś odzyskano."
	/// Description shown when you don't have the tool
	var/no_tool_description = "Bez wiertła tego nie wydobędziesz."
	/// Description shown when you have the necessary tool
	var/has_tool_description = "Możesz to wydobyć wiertłem!"
	var/delay = 30 SECONDS
	var/delay_message = "Odzyskiwanie surowca..."
	/// How many times can this be extracted
	var/amount = 1

/// Description shown below image
/datum/exploration_event/simple/resource/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_list = list(.)
	if(!required_tool || drone.has_tool(required_tool))
		desc_list += has_tool_description
	else
		desc_list += no_tool_description
	return desc_list.Join("\n")

/datum/exploration_event/simple/resource/action_enabled(obj/item/exodrone/drone)
	return (amount > 0) && (!required_tool || drone.has_tool(required_tool))

/datum/exploration_event/simple/resource/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone)) //someone used it up or we lost the tool while we were looking at ui
		end(drone)
		return
	amount--
	if(delay > 0)
		drone.set_busy(delay_message, delay)
		addtimer(CALLBACK(src, PROC_REF(delay_finished), WEAKREF(drone)), delay)
	else
		finish_event(drone)

/datum/exploration_event/simple/resource/is_targetable()
	return visited && amount > 0 ///Can go back if something is left.

/datum/exploration_event/simple/resource/proc/delay_finished(datum/weakref/drone_ref)
	var/obj/item/exodrone/drone = drone_ref.resolve()
	if(QDELETED(drone)) //drone blown up in the meantime
		return
	drone.unset_busy(EXODRONE_EXPLORATION)
	finish_event(drone)

/datum/exploration_event/simple/resource/proc/finish_event(obj/item/exodrone/drone)
	drone.drone_log(success_log)
	dispense_loot(drone)
	end(drone)

/datum/exploration_event/simple/resource/proc/dispense_loot(obj/item/exodrone/drone)
	if(ispath(loot_type, /datum/adventure_loot_generator))
		var/datum/adventure_loot_generator/generator = new loot_type
		generator.transfer_loot(drone)
	else
		var/obj/loot = new loot_type()
		drone.try_transfer(loot)


/// Resource Events

// All
/datum/exploration_event/simple/resource/concealed_cache
	name = "ukryta skrytka"
	band_values = list(EXOSCANNER_BAND_DENSITY = 1)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Odkryto ukrytą, zamkniętą skrytkę."
	description = "Dostrzegasz sprytnie ukryty metalowy pojemnik."
	no_tool_description = "Bez spawarki nie da się go otworzyć."
	has_tool_description = "Możesz spróbować rozspawać go spawarką."
	action_text = "Rozspawaj"
	delay_message = "Rozspawywanie skrytki..."
	loot_type = /datum/adventure_loot_generator/maintenance

// EXPLORATION_SITE_RUINS 2/2
/datum/exploration_event/simple/resource/remnants
	name = "wyschnięte zwłoki"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Odkryto zwłoki humanoida."
	description = "Znajdujesz wyschnięte zwłoki humanoida, zbyt zniszczone, żeby je rozpoznać. Obok leży zamknięta teczka."
	no_tool_description = "Bez multitoola jej nie otworzysz."
	has_tool_description = "Możesz spróbować włamać się do niej multitoolem!"
	action_text = "Włam się"
	delay_message = "Włamywanie..."
	loot_type = /datum/adventure_loot_generator/simple/cash

/datum/exploration_event/simple/resource/gunfight
	name = "pozostałości strzelaniny"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Odkryto miejsce dawnej strzelaniny."
	description = "Znajdujesz miejsce pełne łusek i śladów po laserach. Pod pobliskim gruzem coś leży."
	no_tool_description = "Bez wiertła się do tego nie dostaniesz."
	has_tool_description = "Możesz usunąć gruz wiertłem!"
	action_text = "Usuń gruz"
	delay_message = "Wiercenie..."
	loot_type = /datum/adventure_loot_generator/simple/weapons

// EXPLORATION_SITE_TECHNOLOGY 2/2
/datum/exploration_event/simple/resource/maint_room
	name = "zamknięte pomieszczenie techniczne"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY, EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Odkryto zamknięte pomieszczenie techniczne."
	success_log = "Odzyskano zawartość zamkniętego pomieszczenia technicznego."
	description = "Odkrywasz zamknięte pomieszczenie techniczne. W pobliżu widać ślady częstego ruchu."
	no_tool_description = "Bez multitoola go nie otworzysz."
	has_tool_description = "Możesz spróbować otworzyć je multitoolem!"
	action_text = "Włam się"
	delay_message = "Włamywanie..."
	loot_type = /datum/adventure_loot_generator/maintenance
	amount = 3

/datum/exploration_event/simple/resource/storage
	name = "magazyn"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY, EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Odkryto magazyn pełen skrzyń."
	success_log = "Dzięki przetłumaczonemu manifestowi znaleziono skrzynię z lekami."
	description = "Znajdujesz magazyn pełen nieopisanych skrzyń. Przy wejściu wisi manifest w nieznanym języku."
	no_tool_description = "Skrzynie dookoła są puste, a manifestu nie przeczytasz bez tłumacza."
	has_tool_description = "Możesz przetłumaczyć manifest tłumaczem!"
	action_text = "Przetłumacz"
	delay_message = "Tłumaczenie manifestu..."
	loot_type = /datum/adventure_loot_generator/simple/drugs

// EXPLORATION_SITE_ALIEN 2/2
/datum/exploration_event/simple/resource/alien_tools
	name = "sarkofag obcych"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_TECH = 1, EXOSCANNER_BAND_RADIATION = 1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Odkryto sarkofag obcych pokryty nieznanymi glifami."
	success_log = "Odzyskano zawartość sarkofagu obcych."
	description = "Znajdujesz ogromny sarkofag obcego pochodzenia, pokryty nieznanym pismem."
	no_tool_description = "Bez tłumacza nie przeczytasz glifów ani nie otworzysz sarkofagu."
	has_tool_description = "Tłumaczysz glify i znajdujesz opis ukrytego mechanizmu, który otwiera grobowiec."
	delay_message = "Otwieranie..."
	action_text = "Otwórz"
	loot_type = /obj/item/scalpel/alien

/datum/exploration_event/simple/resource/pod
	name = "biokapsuła obcych"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_LIFE = 1)
	required_tool = EXODRONE_TOOL_LASER
	discovery_log = "Odkryto kapsułę obcych."
	success_log = "Odzyskano zawartość kapsuły obcych."
	description = "Natrafiasz na biokapsułę obcych pełną dziwnych worków z uprowadzonymi stworzeniami."
	no_tool_description = "Bez precyzyjnego lasera nie przebijesz biokapsuły."
	has_tool_description = "Możesz spróbować rozciąć jeden z worków laserem!"
	delay_message = "Otwieranie..."
	action_text = "Otwórz"
	loot_type = /datum/adventure_loot_generator/pet

// EXPLORATION_SITE_SHIP 2/2
/datum/exploration_event/simple/resource/fuel_storage
	name = "magazyn paliwa"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	band_values = list(EXOSCANNER_BAND_PLASMA = 1)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Odkryto magazyn paliwa statku."
	description = "Znajdujesz magazyn paliwa statku. Niestety ma elektroniczny zamek."
	success_log = "Odzyskano paliwo z magazynu."
	no_tool_description = "Bez multitoola nie złamiesz zamka."
	has_tool_description = "Możesz spróbować zewrzeć zamek multitoolem!"
	delay_message = "Otwieranie..."
	action_text = "Otwórz"
	loot_type = /obj/item/fuel_pellet/exotic

/datum/exploration_event/simple/resource/navigation
	name = "systemy nawigacyjne"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Odkryto systemy nawigacyjne statku."
	description = "Znajdujesz systemy nawigacyjne statku zakodowane w dziwnym języku. Z tłumaczem dane będą użyteczne."
	success_log = "Odzyskano dane żeglugowe z systemów nawigacyjnych."
	no_tool_description = "Do odczytania danych potrzebujesz tłumacza."
	has_tool_description = "Możesz spróbować przetłumaczyć dane nawigacyjne tłumaczem!"
	delay_message = "Pobieranie danych..."
	action_text = "Pobierz dane"
	loot_type = /datum/adventure_loot_generator/cargo

// EXPLORATION_SITE_HABITABLE 2/2
/datum/exploration_event/simple/resource/unknown_microbiome
	name = "nieznany mikrobiom"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	// tg wymaga tu tłumacza, ale opisy mówią o laserze, więc wymagamy lasera
	required_tool = EXODRONE_TOOL_LASER
	discovery_log = "Odkryto odizolowany mikrobiom."
	description = "Odkrywasz ogromną kolonię grzybów."
	success_log = "Pobrano próbki grzyba do dalszych badań."
	no_tool_description = "Precyzyjnym laserem dałoby się odciąć próbkę do badań."
	has_tool_description = "Możesz ostrożnie wyciąć próbkę z kolonii laserem!"
	delay_message = "Pobieranie próbek..."
	action_text = "Pobierz próbkę"
	loot_type = /obj/item/seeds/random

/datum/exploration_event/simple/resource/tcg_nerd
	name = "dziwny nieznajomy"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	band_values = list(EXOSCANNER_BAND_LIFE = 1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Spotkano dziwnego nieznajomego."
	description = "Spotykasz mieszkańca tego miejsca. Jest obdarty i wyraźnie czymś podekscytowany."
	no_tool_description = "Bez tłumacza nie zrozumiesz, o co mu chodzi."
	has_tool_description = "Według tłumaczenia chce się z tobą podzielić swoim hobby!"
	success_log = "Otrzymano prezent od nieznajomego."
	delay_message = "Cierpliwe słuchanie..."
	action_text = "Przyjmij prezent"
	loot_type = /obj/item/toy/cards/deck

// EXPLORATION_SITE_SPACE 2/2
/datum/exploration_event/simple/resource/comms_satellite
	name = "porzucony satelita łączności"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Odkryto porzuconego satelitę łączności."
	description = "Odkrywasz porzuconego satelitę łączności. Klucz szyfrujący jest cały, ale chroni go skomplikowany zamek elektroniczny."
	no_tool_description = "Do wyjęcia klucza potrzebujesz multitoola."
	has_tool_description = "Możesz wyłączyć zamek multitoolem i wyjąć klucz!"
	success_log = "Odzyskano klucz szyfrujący z porzuconego satelity."
	delay_message = "Włamywanie..."
	action_text = "Złam zamek"
	loot_type = /obj/item/encryptionkey/heads/captain

/datum/exploration_event/simple/resource/welded_locker
	name = "zaspawana szafka"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Odkryto pośpiesznie zaspawaną szafkę."
	description = "Odkrywasz zaspawaną szafkę dryfującą w kosmosie. Co może być w środku...?"
	no_tool_description = "Do zawartości szafki potrzebujesz spawarki."
	has_tool_description = "Możesz rozspawać szafkę spawarką!"
	success_log = "Odzyskano... odciętą głowę."
	delay_message = "Rozspawywanie..."
	action_text = "Rozspawaj"
	loot_type = /obj/item/bodypart/head

/datum/exploration_event/simple/resource/welded_locker/dispense_loot(obj/item/exodrone/drone)
	var/mob/living/carbon/human/head_species_source = new
	head_species_source.set_species(/datum/species/skeleton)
	head_species_source.real_name = "ofiara z kosmicznej szafki"
	var/obj/item/bodypart/head/skeleton_head = head_species_source.get_bodypart(BODY_ZONE_HEAD)
	skeleton_head.drop_limb(FALSE)
	qdel(head_species_source)
	drone.try_transfer(skeleton_head)

// EXPLORATION_SITE_SURFACE 2/2
/datum/exploration_event/simple/resource/plasma_deposit
	name = "złoże surowej plazmy"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_PLASMA = 3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Odkryto spore złoże plazmy."
	success_log = "Wydobyto plazmę ze złoża."
	description = "Znajdujesz bogate powierzchniowe złoże plazmy."
	no_tool_description = "Bez wiertła nic ze złoża nie wydobędziesz."
	has_tool_description = "Wiertłem wydobędziesz złoże!"
	action_text = "Wydobądź"
	delay_message = "Wydobywanie..."
	loot_type = /obj/item/stack/sheet/mineral/plasma

/datum/exploration_event/simple/resource/plasma_deposit/dispense_loot(obj/item/exodrone/drone)
	drone.try_transfer(new /obj/item/stack/sheet/mineral/plasma(null, 30))

/datum/exploration_event/simple/resource/mineral_deposit
	name = "złoże"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_DENSITY = 3)
	required_tool = EXODRONE_TOOL_DRILL
	no_tool_description = "Bez wiertła nic ze złoża nie wydobędziesz."
	has_tool_description = "Wiertłem wydobędziesz złoże!"
	action_text = "Wydobądź"
	delay_message = "Wydobywanie..."
	/// Typ arkusza => nazwa materiału w dopełniaczu (w tg: srebro, bananium i pizza, której u nas nie ma)
	var/static/list/possible_materials = list(
		/obj/item/stack/sheet/mineral/silver = "srebra",
		/obj/item/stack/sheet/mineral/bananium = "bananium",
	)
	var/loot_amount = 30
	var/chosen_sheet_type

/datum/exploration_event/simple/resource/mineral_deposit/New()
	. = ..()
	chosen_sheet_type = pick(possible_materials)
	var/material_name = possible_materials[chosen_sheet_type]
	name = "złoże [material_name]"
	discovery_log = "Odkryto spore złoże [material_name]."
	success_log = "Wydobyto złoże [material_name]."
	description = "Znajdujesz bogate powierzchniowe złoże [material_name]."

/datum/exploration_event/simple/resource/mineral_deposit/dispense_loot(obj/item/exodrone/drone)
	var/obj/loot = new chosen_sheet_type(null, loot_amount)
	drone.try_transfer(loot)
