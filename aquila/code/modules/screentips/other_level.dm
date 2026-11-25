// Przez otwartą przestrzeń widać piętro niżej, a obiekty stamtąd wyglądają jak te z piętra gracza (w kosmosie nie ma
// po czym ich odróżnić). Podpowiedź na ekranie i opis przy badaniu mówią więc, na którym piętrze coś leży.

/// "piętro niżej", "2 piętra wyżej" albo "" (to samo piętro, inny statek, brak połączenia)
/atom/proc/aq_other_level_text(mob/user)
	var/turf/here = get_turf(user)
	var/turf/there = get_turf(src)
	if(!here || !there || here.z == there.z)
		return ""
	var/turf/down = here
	var/turf/up = here
	for(var/levels in 1 to 3)
		down = down?.below()
		up = up?.above()
		if(down?.z == there.z)
			return levels == 1 ? "piętro niżej" : "[levels] piętra niżej"
		if(up?.z == there.z)
			return levels == 1 ? "piętro wyżej" : "[levels] piętra wyżej"
	return ""

/atom/examine(mob/user)
	. = ..()
	var/other_level = aq_other_level_text(user)
	if(other_level)
		. += span_notice("To jest [other_level].")
