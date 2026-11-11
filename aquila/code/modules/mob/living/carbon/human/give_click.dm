// AQUILA - Ctrl+Shift+klik oferuje trzymany przedmiot tylko wtedy, gdy klikasz kogoś stojącego obok.
// W core (give.dm) każdy Ctrl+Shift+klik woła Give(): bez nikogo obok oferta od razu znika, a w czacie zostaje
// „Oferujesz ...”, więc klikanie po podłodze z bronią w ręku spamowało ofertami karabinu.
// Na wszystkim innym zostaje zwykła akcja Ctrl+Shift+kliku obiektu (CtrlShiftClick, np. przewracanie stołu).

/mob/living/carbon/human/CtrlShiftClickOn(atom/A)
	if(A != src && iscarbon(A) && Adjacent(A))
		return ..()
	A.CtrlShiftClick(src)
