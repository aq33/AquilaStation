// AQUILA - przepisy z tgstation (code/datums/mutations/_combined.dm)
// Format jak u nas: required = "typ1; typ2" (tekst), result = typ

/datum/generecipe/thermal_adaptation
	required = "/datum/mutation/adaptation/cold; /datum/mutation/adaptation/heat"
	result = /datum/mutation/adaptation/thermal

/datum/generecipe/cindikinesis
	required = "/datum/mutation/geladikinesis; /datum/mutation/fire"
	result = /datum/mutation/cindikinesis

/datum/generecipe/pyrokinesis
	required = "/datum/mutation/cryokinesis; /datum/mutation/fire"
	result = /datum/mutation/cryokinesis/pyrokinesis

/datum/generecipe/heckacious
	required = "/datum/mutation/wacky; /datum/mutation/stoner"
	result = /datum/mutation/heckacious

/datum/generecipe/ork
	required = "/datum/mutation/hulk; /datum/mutation/clumsy"
	result = /datum/mutation/hulk/ork

// Wymagają Stimmed (tg), którego ten port nie robi. Bez niej da się je zdobyć tylko injectorem.
/datum/generecipe/tonguechem
	required = "/datum/mutation/tongue_spike; /datum/mutation/stimmed"
	result = /datum/mutation/tongue_spike/chem

/datum/generecipe/martyrdom
	required = "/datum/mutation/strong; /datum/mutation/stimmed"
	result = /datum/mutation/martyrdom
