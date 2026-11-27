// AQUILA - kartoteka Żandarmerii: wspólna zmiana statusu karnego (aquila/code/modules/security/criminal_status.dm)

/// Zmiana statusu karnego w kartotece: (datum/data/record/security_record, old_status, new_status, author, reason)
#define COMSIG_GLOB_AQ_CRIMINAL_STATUS_CHANGED "!aq_criminal_status_changed"
/// Ogłoszenie Żandarmerii przed nadaniem: (message, list/channels). Testy łapią tu komunikaty bez nadajnika
#define COMSIG_GLOB_AQ_SECURITY_ANNOUNCE "!aq_security_announce"

/// Statusy, które wymagają powodu (decyzja planu D2)
#define AQ_CRIMINAL_STATUSES_NEED_REASON list("Arrest", "Search")
/// Statusy, które ogłaszamy także Dowództwu (decyzja planu D1)
#define AQ_CRIMINAL_STATUSES_TO_COMMAND list("Arrest", "Incarcerated")
