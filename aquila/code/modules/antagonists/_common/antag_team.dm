/// AQUILA - drużyna i jej cele trzymają się nawzajem (team.objectives -> cel -> team), a lista członków trzyma umysły,
/// których role wskazują na drużynę. Usunięta drużyna nigdy się nie zwalniała (twarde usunięcie, a w CI ~3 minuty szukania
/// referencji z zamrożonym światem). Cele usuwamy przed wyczyszczeniem członków, bo Destroy() celu zdejmuje go z ich ról
/// przez team.members. Iteracja po kopii, bo każdy usuwany cel sam wypisuje się z team.objectives.
/datum/team/Destroy(force, ...)
	for(var/datum/objective/objective as anything in objectives?.Copy())
		qdel(objective)
	objectives?.Cut()
	members?.Cut()
	return ..()
