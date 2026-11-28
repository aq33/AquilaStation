// AQUILA - czas śladu w skanerze (pomysł z Goob Station, forensics: „DNA X minutes ago”).
// Odciski, krew i włókna pamiętają, kiedy ostatnio je zostawiono. Skaner pokazuje wiek w przybliżeniu
// („mniej niż minutę temu”, „ok. 10 min temu”, „ponad 30 min temu”), żeby zostawić miejsce na dedukcję.
// Odcisk gołych dłoni człowieka skaner liczy z DNA, a ślady z mapy nie mają znacznika: te są bez dopisku.

/datum/component/forensics
	/// Kiedy ostatnio zostawiono ślad: odcisk => world.time
	var/list/print_times
	/// krew (DNA) => world.time
	var/list/blood_times
	/// włókno => world.time
	var/list/fiber_times

/datum/component/forensics/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	var/list/before = fingerprints ? fingerprints.Copy() : list()
	. = ..()
	for(var/print in fingerprints)
		if(!(print in before))
			LAZYSET(print_times, print, world.time)
	// Ponowny dotyk tym samym palcem odświeża czas („ostatni dotyk”)
	if(. && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/print = H.dna ? rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity) : null
		if(print && LAZYACCESS(fingerprints, print))
			LAZYSET(print_times, print, world.time)

/datum/component/forensics/add_fibers(mob/living/carbon/human/M)
	var/list/before = fibers ? fibers.Copy() : list()
	. = ..()
	for(var/fiber in fibers)
		if(!(fiber in before))
			LAZYSET(fiber_times, fiber, world.time)

/datum/component/forensics/add_blood_DNA(list/dna)
	. = ..()
	if(.)
		for(var/dna_key in dna)
			LAZYSET(blood_times, dna_key, world.time)

/datum/component/forensics/InheritComponent(datum/component/forensics/F, original)
	aq_merge_times(F.print_times, "print_times")
	aq_merge_times(F.blood_times, "blood_times")
	aq_merge_times(F.fiber_times, "fiber_times")
	return ..()

/// Scala znaczniki czasu z innego komponentu (bierze nowszy)
/datum/component/forensics/proc/aq_merge_times(list/other, var_name)
	if(!length(other))
		return
	var/list/mine = vars[var_name] || list()
	for(var/key in other)
		mine[key] = max(mine[key], other[key])
	vars[var_name] = mine

/datum/component/forensics/wipe_fingerprints()
	print_times = null
	return ..()

/datum/component/forensics/wipe_blood_DNA()
	blood_times = null
	return ..()

/datum/component/forensics/wipe_fibers()
	fiber_times = null
	return ..()

/// Przybliżony wiek śladu do raportu skanera albo "" (ślad bez znacznika)
/proc/aq_trace_age_text(time)
	if(!time)
		return ""
	var/minutes = (world.time - time) / (1 MINUTES)
	if(minutes < 1)
		return " <i>(mniej niż minutę temu)</i>"
	if(minutes < 5)
		return " <i>(kilka minut temu)</i>"
	if(minutes < 30)
		return " <i>(ok. [round(minutes, 5)] min temu)</i>"
	return " <i>(ponad 30 min temu)</i>"

/// Dopisek wieku śladu: kind = "print", "blood" albo "fiber"
/atom/proc/aq_trace_age(kind, key)
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(!D)
		return ""
	var/list/times
	switch(kind)
		if("print")
			times = D.print_times
		if("blood")
			times = D.blood_times
		if("fiber")
			times = D.fiber_times
	return aq_trace_age_text(LAZYACCESS(times, key))
