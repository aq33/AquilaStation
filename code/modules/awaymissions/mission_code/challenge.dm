//Challenge Areas

/area/awaymission/challenge/start
	name = "Gdzie Jestem?"
	icon_state = "away"

/area/awaymission/challenge/main
	name = "Sala Zagrożeń"
	icon_state = "away1"
	requires_power = FALSE

/area/awaymission/challenge/end
	name = "Administracja Wyzwania"
	icon_state = "away2"
	requires_power = FALSE


/obj/machinery/power/emitter/energycannon
	name = "działo energetyczne"
	desc = "Wytrzymały laser przemysłowy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter_+a"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0

	active = TRUE
	locked = TRUE
	state = 2

/obj/machinery/power/emitter/energycannon/RefreshParts()
	return
