/obj/item/implant/krav_maga
	name = "implant krav maga"
	desc = "Uczy cię sztuki Krav Maga w 5 krótkich filmach instruktażowych wyświetlanych prosto w twoje gałki oczne."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	activated = 1
	var/datum/martial_art/krav_maga/style = new

/obj/item/implant/krav_maga/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant Krav Maga<BR><b>Żywotność:</b> 4 godziny po śmierci nosiciela<BR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> uczy nawet najbardziej niezdarnego nosiciela sztuki Krav Maga."}
	return dat

/obj/item/implant/krav_maga/activate()
	. = ..()
	var/mob/living/carbon/human/H = imp_in
	if(!ishuman(H))
		return
	if(!H.mind)
		return
	if(H.mind.has_martialart(MARTIALART_KRAVMAGA))
		style.remove(H)
	else
		style.teach(H,1)

/obj/item/implanter/krav_maga
	name = "implanter (krav maga)"
	imp_type = /obj/item/implant/krav_maga

/obj/item/implantcase/krav_maga
	name = "etui na implant – „Krav Maga”"
	desc = "Szklane etui z implantem, który może nauczyć użytkownika sztuki Krav Maga."
	imp_type = /obj/item/implant/krav_maga

