// Niezwrócony sprzęt drużyny jako wykroczenie z kosmicznego prawa. XO zgłasza je z rejestru wydań w konsoli drużyn:
// wpis trafia do akt ochrony winnego (jak przestępstwo dopisane HUD-em ochrony), a ochrona decyduje, co dalej.
// Ta sama pozycja jest w config/space_law.json (z niego czyta interfejs więzienia); datum to zapas, gdy pliku brak.

#define SQUAD_GEAR_CRIME "Przywłaszczenie sprzętu drużyny"

/datum/crime/minor/aq_squad_gear
	name = SQUAD_GEAR_CRIME
	icon = "box-open"
	tooltip = "Niezwrócenie do automatu drużyny wydanego zestawu (pancerza, broni, amunicji lub innego sprzętu) po zakończeniu alarmu albo na wezwanie oficera wykonawczego."

/datum/squad_loan
	/// Czy XO już zgłosił to wypożyczenie do akt (jedno zgłoszenie na wypożyczenie)
	var/aq_reported = FALSE

/// Dopisuje wykroczenie do akt ochrony właściciela wypożyczenia. Zwraca TRUE, gdy wpis powstał.
/datum/squad_loan/proc/aq_report(mob/living/user)
	if(aq_reported)
		to_chat(user, "<span class='warning'>To wypożyczenie jest już zgłoszone do ochrony.</span>")
		return FALSE
	var/list/missing = outstanding_names()
	if(!length(missing))
		to_chat(user, "<span class='warning'>[owner_name] oddał już cały sprzęt.</span>")
		return FALSE
	var/datum/data/record/record = find_record("name", owner_name, GLOB.data_core.security)
	if(!record)
		to_chat(user, "<span class='warning'>[owner_name] nie ma akt w rejestrze ochrony.</span>")
		return FALSE
	var/details = "Nie zwrócono: [english_list(missing)] (zestaw: [kit_name], drużyna [squad_name])."
	var/datum/data/crime/crime = GLOB.data_core.createCrimeEntry(SQUAD_GEAR_CRIME, details, "[user.real_name] (konsola drużyn)", station_time_timestamp())
	GLOB.data_core.addCrime(record.fields["id"], crime)
	aq_reported = TRUE
	user.investigate_log("New Crime: <strong>[SQUAD_GEAR_CRIME]</strong> | Added to [owner_name] by [key_name(user)] (squad console)", INVESTIGATE_RECORDS)
	to_chat(user, "<span class='notice'>Dopisano do akt [owner_name]: [SQUAD_GEAR_CRIME].</span>")
	if(owner)
		to_chat(owner, "<span class='warning'>Oficer wykonawczy zgłosił ochronie, że nie oddałeś sprzętu drużyny. Masz wpis w aktach: [SQUAD_GEAR_CRIME].</span>")
	return TRUE

#undef SQUAD_GEAR_CRIME
