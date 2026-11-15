// AQUILA - atuty frakcji w kampanii (raport/ftl_mapa_07): każda nowa kampania losuje frakcjom mnożnik 0,7–1,3.
// Wyższy atut to więcej rudy z kopalń i natarcie przy mniejszej przewadze, więc ta sama mapa daje różne wojny.
// Atuty zapisują się w kampanii; gracze ich nie widzą wprost, tylko po przebiegu wojny.

/datum/hex_war
	/// frakcja -> mnożnik 0,7–1,3 (brak wpisu = 1)
	var/list/fortunes = list()

/datum/hex_war/proc/roll_fortunes()
	fortunes = list()
	for(var/faction in GLOB.hex_war_factions)
		fortunes[faction] = rand(70, 130) / 100
	log_game("HEXWAR: campaign fortunes [json_encode(fortunes)]")

/datum/hex_war/proc/fortune_of(faction)
	var/f = fortunes[faction]
	return isnum(f) && f > 0 ? f : 1

/// Liczba całkowita z mnożnikiem: część ułamkowa jako szansa (2 × 1,25 = 2 albo 3, średnio 2,5)
/datum/hex_war/proc/fortune_amount(faction, base)
	var/value = base * fortune_of(faction)
	. = round(value)
	if(prob((value - .) * 100))
		.++
