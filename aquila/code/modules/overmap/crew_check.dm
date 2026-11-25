// Okręt wysyła dźwięki walki (relay) i wstrząsy (shake_everyone) mobom z mobs_in_ship. Mob trafia na tę listę i z niej wypada
// w update_overmap(), wołanym tylko przy jego własnym Move/forceMove. Ciało przeniesione w worku, szafce albo urządzeniu, czy
// przesunięte razem z kafelkami przy dokowaniu, zostawało na liście starego okrętu: gracz po śmierci na obcym okręcie słyszał
// jego walkę i czuł wstrząsy już na własnym statku, aż do zghostowania. Przed wysłaniem okręt poprawia mobom przypisanie.

/// Mob, którego nie ma już na tym okręcie, dostaje aktualny okręt (jak po własnym ruchu) i wypada z listy załogi
/obj/structure/overmap/proc/aq_check_crew()
	for(var/mob/M as anything in mobs_in_ship.Copy())
		if(QDELETED(M))
			mobs_in_ship -= M
			continue
		if(M.get_overmap() == src)
			continue
		mobs_in_ship -= M
		// Tylko gdy to my byliśmy jego okrętem: update_overmap() liczy okręt z loc, więc pilota myśliwca wpisałby do okrętu-matki
		if(M.last_overmap == src)
			M.update_overmap()

/obj/structure/overmap/relay(S, message = null, loop = FALSE, channel = null)
	aq_check_crew()
	return ..()

/obj/structure/overmap/shake_everyone(severity)
	aq_check_crew()
	return ..()
