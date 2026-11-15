// AQUILA - wygląd wyimaginowanego przyjaciela losuje się z profesji, które mają podgląd ludzkiej postaci.
// SI i cyborg rzucają w equip() z visualsOnly CRASH("dynamic preview is unsupported"), więc trauma z wyimaginowanym
// przyjacielem (losowa trauma mózgu, np. w teście chirurgii aquila_surgery_tg_advanced) sypała runtime'em.
// Hook: setup_friend() w code/datums/brain_damage/imaginary_friend.dm.

/// Losowa profesja do wyglądu wyimaginowanego przyjaciela, bez SI i cyborga; null, gdy żadnej nie ma
/proc/imaginary_friend_preview_job()
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		if(istype(job, /datum/job/ai) || istype(job, /datum/job/cyborg))
			continue
		jobs += job
	return length(jobs) ? pick(jobs) : null
