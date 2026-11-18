// AQUILA - uśpiony pradawny horror jako jeden z okazów w klatce xenobio (xenobiology_fun_spawner).
// Duch przejmuje go jak inne role duchów (kliknięcie albo menu spawnerów) i dostaje antaga horrora,
// tak jak przy evencie. Horror z klatki nie trzyma rundy, podobnie jak żywy guz.

/obj/effect/mob_spawn/horror_xenobio
	name = "uśpiony pradawny horror"
	desc = "Zwinięte, oślizgłe plugastwo. Śpi. Chyba."
	icon = 'aquila/icons/mob/horror.dmi'
	icon_state = "horror"
	density = FALSE
	anchored = FALSE

	mob_type = /mob/living/simple_animal/horror
	mob_name = "pradawny horror"
	random = TRUE // horror sam losuje imię z GLOB.horror_names
	death = FALSE
	roundstart = FALSE
	use_cooldown = TRUE
	show_flavour = FALSE // horror dostaje playstyle_string w special()
	antagonist_type = /datum/antagonist/horror/xenobio
	banType = ROLE_HORROR

/obj/effect/mob_spawn/horror_xenobio/special(mob/living/simple_animal/horror/horror)
	if(!istype(horror) || !horror.mind)
		return
	horror.mind.assigned_role = ROLE_HORROR
	horror.mind.special_role = ROLE_HORROR
	to_chat(horror, horror.playstyle_string)
	SEND_SOUND(horror, sound('sound/hallucinations/growl2.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(horror)] budzi pradawnego horrora w klatce xenobio.")
	log_game("[key_name(horror)] became an eldritch horror from a xenobiology cell in [AREACOORD(horror)].")

/// Horror z klatki xenobio: poboczny antag, nie wstrzymuje końca rundy
/datum/antagonist/horror/xenobio
	delay_roundend = FALSE
