// AQUILA - kontrolka podpowiedzi (mainwindow.tooltip, interface/skin.dmf) chowana zaraz po wczytaniu strony.
// browse() do kontrolki przeglądarki potrafił ją pokazać, a pusta strona 999x999 zostawała na ekranie białym prostokątem
// (w lobby z niebieskim kwadratem ramki podpowiedzi). Resztę chowania robi code/modules/tooltip/tooltip.html.
/datum/tooltip/New(client/C)
	. = ..()
	if(owner)
		winshow(owner, control, FALSE)
