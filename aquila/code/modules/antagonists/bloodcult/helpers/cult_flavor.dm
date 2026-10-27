/* -- Flavour text for refusing/accepting conversion.
-- Possible context (static) :
	=> Dept (weighted 3)
	=> Specific job (weighted 5)
	=> Race (weighted 3)
	=> Specific special role (weighted 5)
-- Possible context (dynamic) :
	=> The guy that converted you is from the same dept (weighted 3)
	=> Your boss is in the cult (CMO for medbay, ...)
	=> Your underlings are in the cult
	=> Your colleagues are in the cult
	=> Cult has a few/a lot of alive members
*/


GLOBAL_LIST_INIT(acceptance_lines_by_dept,  list(
	ACCOUNT_CMD = list(
		"Wiedziałam, że to w tobie drzemie." = 3,
		"Łańcuchy dowodzenia pękły." = 3,
		"Bądź gotów prowadzić silniejszą stronę." = 3,
		"Powstań, nowy czempionie." = 3,
	),
	ACCOUNT_ENG = list(
		"Kuźnie Geometry witają cię." = 3,
		"Twój prawdziwy potencjał został odsłonięty." = 3,
		"Wykuj miecz, który zgładzi moich wrogów." = 3,
		"Powstań, nowy rzemieślniku." = 3,
	),
	ACCOUNT_MED = list(
		"Krew zawsze była twoją towarzyszką." = 3,
		"Uleczyłeś tak wielu... ale dopiero teraz naprawdę żyjesz." = 3,
		"Powstań, nowy uzdrowicielu." = 3,
	),
	ACCOUNT_SCI = list(
		"To zawsze było twoje powołanie." = 3,
		"Tajemnice zasłony są teraz twoje do zbadania." = 3,
		"Logiczna konsekwencja wybranej kariery." = 3,
		"Czy nie tego zawsze chciałeś?" = 3,
		"Powstań, nowy adepcie." = 3,
	),
	ACCOUNT_CIV = list(
		"Tylko tutaj się spełnisz." = 3,
		"Wreszcie dostałeś zadanie." = 3,
		"Powstań." = 3,
		"I tak kończy się życie w służbie." = 3,
		"Powstań, nowy sługo." = 3,
	),
	ACCOUNT_CAR = list(
		"Gdy to się skończy, spodziewaj się czegoś więcej niż wymarzona Cargonia." = 3,
		"Bądź ręką, która uzbroi moich żołnierzy." = 3,
		"Powstań, nowy zbrojmistrzu." = 3,
	),
	ACCOUNT_SEC = list(
		"Gratulacje, dołączyłeś do silniejszej strony." = 3,
		"Korporacyjny niewolnik umarł. Niech jego miejsce zajmie nowy, wolny człowiek." = 3,
		"Wreszcie ujrzałeś światło." = 3,
		"Twoja wolność zaczyna się o tej godzinie, w tym miejscu." = 3,
		"Powstań, nowy wojowniku." = 3,
	),
))

GLOBAL_LIST_INIT(acceptance_lines_by_specific_race,  list(
	/datum/species/plasmaman = list(
		"Ból kończy się teraz." = 3,
		"Nawet umarli mogą służyć." = 3,
	),
))

// Context lines

GLOBAL_LIST_INIT(acceptance_lines_few_cultists, list(
	"Bądź ręką, której potrzebuję w tych czasach." = 3,
	"Zostałeś wybrany." = 3,
))

GLOBAL_LIST_INIT(acceptance_lines_numerous_cultists, list(
	"Nasze szeregi są bezkresne." = 3,
	"Z każdą duszą stajemy się silniejsi." = 3,
	"Nic nie oprze się naszej potędze." = 3,
))


#define acceptance_lines_same_dept list( \
	"[converter.gender == MALE ? "Ocenił" : "Oceniła"] cię dobrze." = 5, \
	"Teraz oboje służycie temu samemu celowi." = 5, \
	"Czyż praca zespołowa nie jest wspaniała?" = 5, \
)


/datum/team/cult/proc/send_flavour_text_accept(mob/victim, mob/converter)
	// -- Static context
	// Default lines
	var/list/valid_lines = list(
		"Kolejny dołącza do owczarni." = 1,
		"Z każdym nowym zasłona staje się cieńsza." = 1,
		"Wszyscy są mile widziani." = 1,
	)
	// The departement (AQUILA - u nas mind.assigned_role to nazwa, datum pracy bierzemy z SSjob)
	var/datum/job/victim_job = SSjob.GetJob(victim?.mind?.assigned_role)
	var/datum/job/converter_job = SSjob.GetJob(converter?.mind?.assigned_role)
	if (victim_job && (victim_job.paycheck_department in GLOB.acceptance_lines_by_dept))
		valid_lines += GLOB.acceptance_lines_by_dept[victim_job.paycheck_department]

	// The race
	if (ishuman(victim))
		var/mob/living/carbon/human/dude = victim
		if(dude.dna.species.type in GLOB.acceptance_lines_by_specific_race)
			valid_lines += GLOB.acceptance_lines_by_specific_race[dude.dna.species.type]

	// -- Dynamic context
	// Cultist count
	var/cultists = 0
	for (var/datum/mind/mind in members)
		if (mind && mind.current && !mind.current.stat) // If he's alive
			cultists++

	// Not a lot of cultists...
	if (cultists < 3)
		valid_lines += GLOB.acceptance_lines_few_cultists

	// Or a lot of them !
	else if (cultists > 10)
		valid_lines += GLOB.acceptance_lines_numerous_cultists

	// Converter and victim are of the same dept
	if (converter && victim_job && converter_job && (victim_job.paycheck_department == converter_job.paycheck_department))
		valid_lines += acceptance_lines_same_dept

	var/chosen_line = pick_weight(valid_lines)
	to_chat(victim, "<span class='game say'><span class='danger'>Nar-Sie</span> szepcze: [span_cult(chosen_line)]</span>")

#undef acceptance_lines_same_dept
