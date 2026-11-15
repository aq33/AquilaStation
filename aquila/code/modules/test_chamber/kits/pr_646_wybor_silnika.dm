/datum/test_chamber_kit/pr_646
	name = "Wybór silnika statku"
	pr = "aq33/AquilaStation#646"
	description = "Zestaw od razu podmienia silnik statku na wariant wybrany z listy (ta sama procedura co na starcie rundy). \
	1) Na Atlasie, Trawniku albo Padalcu zrzuć zestaw i wybierz inny silnik niż obecny: hala ma mieć tylko nowy silnik, bez resztek starego, \
	a ściany, drzwi i rury na granicy hali bez zmian. Uruchom nowy silnik jak inżynier i sprawdź prąd w sterowni. \
	2) Właściwy test na starcie rundy: w Ustawieniach gry ustaw „Preferowany silnik statku”, ustaw Głównego Inżyniera na wysoko i zgłoś gotowość. \
	Po starcie w czacie ma być komunikat o wybranym silniku, a hala ma go mieć. Z dwoma graczami: Główny Inżynier wygrywa z Inżynierem. \
	3) Silnik, którego statek nie ma (Tesla na Padalcu), zostawia wylosowany wariant."
	items = list()

/datum/test_chamber_kit/pr_646/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!length(GLOB.engine_choice_slots))
		to_chat(user, "<span class='warning'>Ta mapa nie ma slotu silnika do wyboru.</span>")
		return
	var/list/slot = GLOB.engine_choice_slots[1]
	var/datum/map_template/random_room/current = slot[ENGINE_SLOT_TEMPLATE]
	var/datum/preference/choiced/preferred_engine/preference = GLOB.preference_entries[/datum/preference/choiced/preferred_engine]
	var/list/names = preference.get_display_names()
	var/list/variants = engine_choice_variants(current)
	var/list/options = list()
	for(var/engine_type in variants)
		if(engine_type != current.engine_type)
			options[names[engine_type]] = engine_type
	if(!length(options))
		to_chat(user, "<span class='warning'>Na tej mapie nie ma innego wariantu silnika.</span>")
		return
	var/choice = tgui_input_list(user, "Obecny silnik: [names[current.engine_type]]. Na co podmienić?", "Wybór silnika", options)
	if(!choice)
		return
	var/datum/map_template/random_room/wanted = variants[options[choice]]
	if(wanted && engine_choice_swap(slot, wanted))
		to_chat(user, "<span class='notice'>Silnik podmieniony na: [choice].</span>")
		message_admins("[key_name_admin(user)] podmienia silnik statku na: [choice] (komora testowa).")
	else
		to_chat(user, "<span class='warning'>Podmiana się nie udała.</span>")
