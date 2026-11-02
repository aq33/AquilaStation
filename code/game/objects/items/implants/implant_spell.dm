/obj/item/implant/spell
	name = "implant zaklęcia"
	desc = "Pozwala ci rzucać zaklęcie, jakbyś był czarodziejem."
	activated = FALSE

	var/autorobeless = TRUE // Whether to automagically make the spell robeless on implant
	var/obj/effect/proc_holder/spell/spell


/obj/item/implant/spell/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant zaklęcia<BR><b>Żywotność:</b> 4 godziny po śmierci nosiciela<BR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> [spell ? "pozwala osobie niebędącej czarodziejem rzucać [spell], jakby była czarodziejem." : "brak"]"}
	return dat

/obj/item/implant/spell/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if (.)
		if (!spell)
			return FALSE
		if (autorobeless && spell.clothes_req)
			spell.clothes_req = FALSE
		target.AddSpell(spell)
		return TRUE

/obj/item/implant/spell/removed(mob/target, silent = FALSE, special = 0)
	. = ..()
	if (.)
		target.RemoveSpell(spell)
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Wiedza o tym, jak rzucać [spell], wymyka ci się z umysłu.</span>")

/obj/item/implanter/spell
	name = "implanter (zaklęcie)"
	imp_type = /obj/item/implant/spell

/obj/item/implantcase/spell
	name = "etui na implant – „Czarodziejstwo”"
	desc = "Szklane etui z implantem, który może nauczyć użytkownika sztuki czarodziejstwa."
	imp_type = /obj/item/implant/spell
