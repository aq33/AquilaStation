// AQUILA - port z tgstation (code/datums/mutations/chameleon.dm)

/// Ulepszona wersja dla zmiennokształtnych: bez niestabilności i znika 2,5 raza szybciej
/datum/mutation/chameleon/changeling
	name = "Changeling Chameleon"
	instability = 0
	effect_speed = 62.5
	locked = TRUE
	conflicts = list(/datum/mutation/chameleon)
