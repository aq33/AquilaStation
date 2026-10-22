/datum/generecipe
	var/required = "" //it hurts so bad but initial is not compatible with lists
	var/result = null

/proc/get_mixed_mutation(mutation1, mutation2)
	if(!mutation1 || !mutation2)
		return FALSE
	if(mutation1 == mutation2) //this could otherwise be bad
		return FALSE
	// AQUILA EDIT - dokładne dopasowanie typów; findtext łapał podtypy (cryokinesis pasowało do cryokinesis/pyrokinesis)
	var/text1 = "[mutation1]"
	var/text2 = "[mutation2]"
	for(var/A in GLOB.mutation_recipes)
		var/list/parts = list()
		for(var/part in splittext(A, ";"))
			parts += trim(part)
		if((text1 in parts) && (text2 in parts))
			return GLOB.mutation_recipes[A]

/* RECIPES */

/datum/generecipe/hulk
	required = "/datum/mutation/strong; /datum/mutation/radioactive"
	result = HULK

/datum/generecipe/shock
	required = "/datum/mutation/insulated; /datum/mutation/radioactive"
	result = SHOCKTOUCH

/datum/generecipe/antiglow
	required = "/datum/mutation/glow; /datum/mutation/void"
	result = ANTIGLOWY

/datum/generecipe/cluwne
	required = "/datum/mutation/clumsy; /datum/mutation/badblink"
	result = CLUWNEMUT
