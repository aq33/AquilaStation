//Visor modules for MODsuits

///Base Visor - Adds a specific HUD and traits to you.
/obj/item/mod/module/visor
	name = "moduł wizjera MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Mówią, że pozwalają też widzieć, co masz za plecami."
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/visor)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)
	/// The HUD type given by the visor.
	var/hud_type
	/// The traits given by the visor.
	var/list/visor_traits = list()

/obj/item/mod/module/visor/on_activation()
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.add_hud_to(mod.wearer)
	for(var/trait in visor_traits)
		ADD_TRAIT(mod.wearer, trait, REF(src))
	mod.wearer.update_sight()

/obj/item/mod/module/visor/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(hud_type)
		var/datum/atom_hud/hud = GLOB.huds[hud_type]
		hud.remove_hud_from(mod.wearer)
	for(var/trait in visor_traits)
		REMOVE_TRAIT(mod.wearer, trait, REF(src))
	mod.wearer.update_sight()

//Medical Visor

/obj/item/mod/module/visor/medhud
	name = "moduł wizjera medycznego MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Zestawia dane z czujników skafandra z nowoczesnym \
		zestawem skanowania biologicznego, pozwalając użytkownikowi widzieć aktualny stan zdrowia organicznych form życia oraz \
		wygodnie przeglądać dane, takie jak karty pacjentów. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "medhud_visor"
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	visor_traits = list(TRAIT_MEDICAL_HUD)

//Diagnostic Visor

/obj/item/mod/module/visor/diaghud
	name = "moduł wizjera diagnostycznego MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Zaawansowane czujniki odczytują dane \
		z zaawansowanych maszyn, egzoszkieletów i innych urządzeń, pozwalając użytkownikowi widzieć ich aktualny poziom energii \
		i stan techniczny. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "diaghud_visor"
	hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	visor_traits = list(TRAIT_DIAGNOSTIC_HUD)

//Security Visor

/obj/item/mod/module/visor/sechud
	name = "moduł wizjera ochrony MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Ten moduł to mocno przerobiony system celowniczy \
		podłączony do różnych kartotek kryminalnych, który pozwala przeglądać rejestry aresztowań, wydawać polecenia prostym robotom ochrony \
		i ogólnie wiedzieć, do kogo strzelać. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "sechud_visor"
	hud_type = DATA_HUD_SECURITY_ADVANCED
	visor_traits = list(TRAIT_SECURITY_HUD)

//Meson Visor

/obj/item/mod/module/visor/meson
	name = "moduł wizjera mezonowego MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Ten moduł opiera się na lubianej technologii skanera mezonowego, \
		której robotnicy budowlani i górnicy w całej galaktyce używają, by widzieć przez ściany podstawowy układ konstrukcji i terenu \
		niezależnie od oświetlenia. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "meson_visor"
	visor_traits = list(TRAIT_MESON_VISION, TRAIT_MADNESS_IMMUNE)

//Thermal Visor

/obj/item/mod/module/visor/thermal
	name = "moduł wizjera termowizyjnego MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Mały skaner podczerwieni wykrywa i rozpoznaje \
		promieniowanie cieplne obiektów w pobliżu użytkownika. Wykryje ciepło nawet czegoś tak \
		małego jak gryzoń, ale wciąż daje irytującą czerwoną nakładkę. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "thermal_visor"
	visor_traits = list(TRAIT_THERMAL_VISION)

//Night Visor

/obj/item/mod/module/visor/night
	name = "moduł wizjera noktowizyjnego MOD"
	desc = "Wyświetlacz HUD zamontowany w wizjerze skafandra. Typowy zarówno w zastosowaniach cywilnych, jak i wojskowych, \
		pozwala widzieć otoczenie w całkowitej ciemności, dziesięciokrotnie wzmacniając obraz, \
		choć wszystko rozjaśnia się upiorną zieloną poświatą. Mówią, że pozwalają też widzieć, co masz za plecami."
	icon_state = "night_visor"
	visor_traits = list(TRAIT_TRUE_NIGHT_VISION)
