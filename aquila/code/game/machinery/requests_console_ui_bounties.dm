// AQUILA - zakładka „Zlecenia” w konsoli zgłoszeń: wszystkie zlecenia statku w jednym miejscu.
// Tylko podgląd. Zlecenia przyjmuje się i oddaje w maszynach, które podaje kolumna „gdzie”:
// CentCom w konsoli zleceń zaopatrzenia, zlecenia cywilne w konsoli zleceń cywilnych, ogłoszenia załogi w newscasterze.

/obj/machinery/requests_console
	/// Czy okno pokazuje listę zleceń; lista liczy się tylko wtedy
	var/aq_bounty_view = FALSE

/obj/machinery/requests_console/ui_data(mob/user)
	. = ..()
	.["bounty_view"] = aq_bounty_view
	if(aq_bounty_view)
		.["bounties"] = requests_console_bounty_list(user)

/obj/machinery/requests_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "bounty_view")
		aq_bounty_view = !!text2num(params["show"])
		return TRUE

/// Dział zlecenia CentComu z gałęzi typu (/datum/bounty/item/<gałąź>/...)
/proc/requests_console_bounty_department(datum/bounty/bounty)
	var/static/list/departments = list(
		"assistant" = "Ogólne",
		"botany" = "Botanika",
		"chef" = "Kuchnia",
		"munitions" = "Uzbrojenie",
		"mining" = "Górnictwo",
		"asteroid_mining" = "Górnictwo",
		"science" = "Nauka",
		"slime" = "Nauka",
		"mech" = "Robotyka",
		"medical" = "Medycyna",
		"virus" = "Medycyna",
		"pilot" = "Piloci",
		"janitor" = "Sprzątanie",
		"bitrunning" = "Bitrunning",
		"engineering" = "Inżynieria",
		"bridge" = "Mostek",
		"security" = "Ochrona",
		"syndicate_documents" = "Ochrona",
		"simple_drink" = "Bar",
		"complex_drink" = "Bar",
		"chemical_simple" = "Chemia",
		"chemical_complex" = "Chemia",
		"patrol" = "Ochrona",
	)
	var/list/parts = splittext("[bounty.type]", "/")
	// "", "datum", "bounty", <typ>, <gałąź>...
	for(var/i in 4 to min(5, length(parts)))
		if(departments[parts[i]])
			return departments[parts[i]]
	return "Ogólne"

/obj/machinery/requests_console/proc/requests_console_bounty_entry(datum/bounty/bounty, source, where, reward)
	return list(
		"name" = bounty.name,
		"description" = bounty.description,
		"reward" = reward,
		"progress" = bounty.completion_string(),
		"source" = source,
		"where" = where,
		"department" = requests_console_bounty_department(bounty),
		"urgent" = bounty.high_priority,
	)

/// Lista zleceń widoczna w zakładce. Zlecenie przypięte do karty czytającego jest pierwsze.
/obj/machinery/requests_console/proc/requests_console_bounty_list(mob/user)
	var/list/result = list()
	var/obj/item/card/id/card = user?.get_idcard(TRUE)
	var/datum/bounty/own = card?.registered_account?.civilian_bounty
	if(own)
		var/list/entry = requests_console_bounty_entry(own, "Twoje zlecenie", "konsola zleceń cywilnych", "[own.get_bounty_reward()] kr")
		entry["own"] = TRUE
		result += list(entry)
	for(var/datum/bounty/bounty as anything in GLOB.shared_crew_bounties)
		if(bounty.claimed)
			continue
		result += list(requests_console_bounty_entry(bounty, "Wspólne", "konsola zleceń cywilnych", "[bounty.get_bounty_reward()] kr"))
	for(var/datum/bounty/bounty as anything in GLOB.bounties_list)
		if(bounty.claimed)
			continue
		result += list(requests_console_bounty_entry(bounty, "CentCom", "konsola zleceń zaopatrzenia", bounty.reward_string()))
	for(var/datum/station_request/request as anything in GLOB.request_list)
		result += list(list(
			"name" = "Ogłoszenie: [request.owner]",
			"description" = request.description,
			"reward" = "[request.value] kr",
			"progress" = "",
			"source" = "Ogłoszenia załogi",
			"where" = "newscaster, tablica zleceń",
			"department" = "Załoga",
			"urgent" = FALSE,
		))
	return result
