/obj/item/implant/chem
	name = "implant chemiczny"
	desc = "Wstrzykuje różne rzeczy."
	icon_state = "reagents"
	activated = FALSE

/obj/item/implant/chem/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant zarządzania więźniami Robust Corp MJ-420<BR><b>Żywotność:</b> przy śmierci nosiciela wstrzykuje całą zawartość, a pusty implant się rozpada.<BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera małą kapsułkę, w której można umieścić różne substancje. Po otrzymaniu specjalnie zakodowanego sygnału<BR>implant uwalnia substancje bezpośrednio do krwiobiegu.<BR><b>Cechy specjalne:</b><i>Mikrokapsułka</i> - można ją napełnić dowolną substancją za pomocą zwykłej strzykawki, mieści 50 jednostek.<BR>Można ją napełniać tylko w oryginalnym opakowaniu.<BR><b>Trwałość:</b> implant działa, dopóki ma w sobie substancje."} // AQ EDIT - opis zgodny z działaniem (wstrzyknięcie przy śmierci, rozpad po opróżnieniu, bez wpływu na apetyt)
	return dat

/obj/item/implant/chem/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)
	GLOB.tracked_chem_implants += src

/obj/item/implant/chem/Destroy()
	GLOB.tracked_chem_implants -= src
	return ..()

/obj/item/implant/chem/trigger(emote, mob/living/source)
	if(emote == "deathgasp")
		if(istype(source) && !(source.stat == DEAD))
			return
		activate(reagents.total_volume)

/obj/item/implant/chem/activate(cause)
	. = ..()
	if(!cause || !imp_in)
		return 0
	var/mob/living/carbon/R = imp_in
	var/injectamount = null
	if (cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	to_chat(R, "<span class='italics'>Słyszysz ciche piknięcie.</span>")
	if(!reagents.total_volume)
		to_chat(R, "<span class='italics'>Słyszysz ciche kliknięcie w swojej klatce piersiowej.</span>")
		qdel(src)


/obj/item/implantcase/chem
	name = "etui na implant – „Zdalny chemiczny”"
	desc = "Szklane etui ze zdalnie sterowanym implantem chemicznym."
	imp_type = /obj/item/implant/chem

/obj/item/implantcase/chem/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/syringe) && imp)
		W.afterattack(imp, user, TRUE, params)
		return TRUE
	else
		return ..()
