/obj/effect/forcefield
	desc = "Magiczna ściana kosmicznego czarodzieja."
	name = "ŚCIANA MOCY"
	icon_state = "m_shield"
	anchored = TRUE
	opacity = 0
	density = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	var/timeleft = 300 //Set to 0 for permanent forcefields (ugh)

/obj/effect/forcefield/Initialize(mapload, ntimeleft)
	. = ..()
	if(isnum_safe(ntimeleft))
		timeleft = ntimeleft
	if(timeleft)
		QDEL_IN(src, timeleft)

/obj/effect/forcefield/singularity_pull()
	return

/obj/effect/forcefield/cult
	desc = "Bezbożna tarcza, która blokuje wszystkie ataki."
	name = "świecąca ściana"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "cultshield"
	CanAtmosPass = ATMOS_PASS_NO
	timeleft = 200

///////////Mimewalls///////////

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "niewidzialna ściana"
	desc = "Masz co do tego złe przeczucia."

/obj/effect/forcefield/mime/advanced
	name = "niewidzialna blokada"
	desc = "Trochę tu posiedzisz."
	timeleft = 600
