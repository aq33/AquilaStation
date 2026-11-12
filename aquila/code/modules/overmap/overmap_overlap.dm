/// AQUILA - obiekt, który już nachodzi na obrys okrętu, nie blokuje mu ruchu.
/// Ruch wielopolowego okrętu (/atom/movable/Move) sprawdza każde pole pod nowym obrysem. Gdy w środku obrysu leży coś
/// gęstego (wrak zestrzelonego myśliwca, własny myśliwiec przy starcie, okręt postawiony na okręcie), każdy krok w każdą
/// stronę był odrzucony i okręt stał do końca rundy z pracującym silnikiem. Teraz obie strony mogą się rozjechać;
/// zderzenie od zewnątrz (obiekty jeszcze się nie stykają) działa jak dawniej.
/obj/structure/overmap/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(. || !istype(mover, /obj/structure/overmap) || !isturf(loc) || !isturf(mover.loc))
		return
	if(length(locs & mover.locs))
		return TRUE
