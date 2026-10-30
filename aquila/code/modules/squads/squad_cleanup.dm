/// Usunięty człowiek zostawał w `members`/`leader` składu (GC fail, hard delete)
/mob/living/carbon/human/Destroy()
	squad?.remove_member(src)
	return ..()

/// Pager trzymał komponent kanału, a ten przez akcję wracał do pagera: cykl referencji, cała trójka wisiała do hard delete
/obj/item/squad_pager/Destroy()
	squad_channel = null
	squad = null
	return ..()

/datum/action/teamchat/Destroy()
	holder = null
	teamspeak = null
	return ..()
