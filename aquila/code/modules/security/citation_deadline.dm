// AQUILA - nieopłacony mandat zamienia się w nakaz aresztowania (pomysł z Fluffy Frontier, tff_modular/modules/timed_citations).
// Każdy mandat (Citationinator, konsola rekordów, HUD) idzie przez addCitation(), więc termin liczy się tu, bez hooka w core.

/// Nazwa wpisu w kartotece po terminie (artykuł w config/space_law.json, Wykroczenia)
#define CITATION_EVASION_CRIME "Uchylanie się od grzywny"
#define CITATION_SERVER_AUTHOR "Serwer mandatów"

/datum/datacore/addCitation(id = "", datum/data/crime/crime)
	. = ..()
	var/minutes = CONFIG_GET(number/citation_payment_minutes)
	if(minutes <= 0 || !crime || crime.fine <= 0)
		return
	if(!find_record("id", id, security)) // mandat spoza manifestu: nie ma czego eskalować
		return
	addtimer(CALLBACK(src, PROC_REF(aq_citation_deadline), id, crime.dataId), minutes MINUTES)

/// Termin minął: niespłacony w całości mandat dopisuje wykroczenie i stawia status „do aresztowania”.
/// Zwraca TRUE, gdy mandat był zaległy
/datum/datacore/proc/aq_citation_deadline(id, crime_id)
	var/datum/data/record/record = find_record("id", id, security)
	if(!record)
		return FALSE
	var/datum/data/crime/citation
	for(var/datum/data/crime/candidate in record.fields["citation"])
		if(candidate.dataId == crime_id)
			citation = candidate
			break
	if(!citation || citation.paid >= citation.fine) // anulowany albo spłacony
		return FALSE
	var/datum/data/crime/evasion = createCrimeEntry(CITATION_EVASION_CRIME, "Mandat „[citation.crimeName]” ([citation.fine] kr) z [citation.time] nie został opłacony w terminie.", CITATION_SERVER_AUTHOR, station_time_timestamp())
	addCrime(id, evasion)
	// Osadzonego ani zwolnionego warunkowo nie cofamy do poszukiwanego
	if(!(record.fields["criminal"] in list("Arrest", "Incarcerated", "Paroled")))
		set_criminal_status(record, "Arrest", CITATION_SERVER_AUTHOR, "niezapłacony mandat „[citation.crimeName]”")
	return TRUE

#undef CITATION_EVASION_CRIME
#undef CITATION_SERVER_AUTHOR

/// Dopisek o terminie do wiadomości PDA o mandacie
/proc/aq_citation_deadline_text()
	var/minutes = CONFIG_GET(number/citation_payment_minutes)
	if(minutes <= 0)
		return ""
	return " Termin zapłaty: [minutes] min, potem kartoteka wystawia nakaz aresztowania."
