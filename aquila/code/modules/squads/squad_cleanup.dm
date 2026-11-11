/// Usunięty człowiek zostawał w `members`/`leader` składu (GC fail, hard delete).
/// Bez remove_member(): to nie jest odejście ze składu, więc bez komunikatu „opuszcza drużynę” przy każdym gibie czy sprzątaniu rundy.
/mob/living/carbon/human/Destroy()
	if(squad)
		var/datum/squad/old_squad = squad
		old_squad.handle_hud(src, FALSE)
		old_squad.members -= src
		squad = null
		if(old_squad.leader == src)
			old_squad.leader = null
			old_squad.assign_leader()
	return ..()

/// Pager trzymał komponent kanału, a ten przez akcję wracał do pagera: cykl referencji, cała trójka wisiała do hard delete
/obj/item/squad_pager/Destroy()
	GLOB.aq_squad_pagers -= src
	squad_channel = null
	squad = null
	return ..()

/datum/action/teamchat/Destroy()
	holder = null
	teamspeak = null
	return ..()
