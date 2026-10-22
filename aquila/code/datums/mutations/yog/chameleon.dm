// AQUILA - port z Yogstation (code/datums/mutations/chameleon.dm, /chameleon/super)

// Szybciej znika i ruch nie odsłania go od razu całego
/datum/mutation/chameleon/super
	name = "Super Chameleon"
	desc = "A refined version of the chameleon genome. The holder fades from view twice as fast and moving only partially reveals them."
	conflicts = list(/datum/mutation/chameleon)
	allow_transfer = FALSE
	mutadone_proof = TRUE
	locked = TRUE
	effect_speed = 50

/datum/mutation/chameleon/super/on_move()
	owner.alpha = min(owner.alpha + effect_speed, CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY)
