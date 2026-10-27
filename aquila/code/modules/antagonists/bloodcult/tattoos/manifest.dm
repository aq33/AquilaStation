
/datum/cult_tattoo/manifest
	name = TATTOO_MANIFEST
	desc = "Otrzymujesz nowe, w pełni uleczone ciało, które nie czuje bólu."
	icon_state = "manifest"
	tier = 3


/datum/cult_tattoo/manifest/getTattoo(mob/M)
	..()
	var/mob/living/carbon/human/H = bearer
	if (!istype(H))
		return
	H.revive(full_heal = TRUE)
	H.status_flags &= ~CANSTUN
	H.status_flags &= ~CANKNOCKDOWN
	H.regenerate_icons()
