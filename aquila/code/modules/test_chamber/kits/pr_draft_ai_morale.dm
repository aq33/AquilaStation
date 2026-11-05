// Lokalny draft (bez PR) - strach, odwrót i błędy taktyczne AI (aquila/code/modules/overmap/ai_morale.dm)

/datum/test_chamber_kit/pr_draft_ai_morale
	name = "Draft: morale AI (strach i odwrót)"
	pr = "lokalny draft, bez PR"
	description = "Zestaw stawia konsolę DRADIS i taktyczną oraz przywołuje trzy niszczyciele Syndykatu AI około 60 pól od okrętu głównego: ostrożny, zwykły i brawurowy (który jest który, napisze się w czacie adminów). \
	1) View Variables na niszczycielu: ai_fear (0-100), ai_temperament, ai_fleeing. \
	2) Zadaj jednemu duże obrażenia w krótkim czasie (np. salwa z MAC): strach rośnie, przy około 30 okręt odsuwa się poza zasięg dział, przy 60+ zaczyna uciekać. \
	3) Uciekający okręt odpala dopalacz od ciebie. Gdy przez 20 s nikt go nie trafi i jesteś dalej niż 40 pól, DRADIS pokazuje „rozgrzewa napęd FTL”, a po 10 s okręt skacze i znika. Trafienie w tym czasie przerywa skok. \
	4) Zniszczenie jednego niszczyciela podnosi strach pozostałych. \
	5) Brawurowy strzela od razu, nie trzyma dystansu i po zgubieniu celu leci tam, gdzie zgaduje, że jesteś. \
	6) Admin > Debug > Toggle AI morale wyłącza całość."
	items = list(
		/obj/machinery/computer/ship/dradis = 1,
		/obj/machinery/computer/ship/tactical = 1,
	)

/datum/test_chamber_kit/pr_draft_ai_morale/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main?.current_system || !main.z)
		to_chat(user, "<span class='warning'>Okręt główny nie jest w systemie gwiezdnym, nie przywołano niszczycieli.</span>")
		return
	var/list/temperaments = list("ostrożny", "zwykły", "brawurowy")
	for(var/i in 1 to length(temperaments))
		var/turf/spot = locate(clamp(main.x + 60, 10, world.maxx - 10), clamp(main.y + (i - 2) * 12, 10, world.maxy - 10), main.z)
		var/obj/structure/overmap/enemy = new /obj/structure/overmap/syndicate/ai(spot)
		main.current_system.add_ship(enemy, spot)
		enemy.ai_temperament = temperaments[i]
		enemy.ai_odds_error = 0
		message_admins("[key_name_admin(user)] przywołał niszczyciel Syndykatu do testu morale ([temperaments[i]]): [ADMIN_VERBOSEJMP(enemy)].")
