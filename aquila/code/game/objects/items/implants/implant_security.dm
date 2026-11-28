// AQUILA - alarm śmierci. Nikt nie ma go na start: implant drukuje tokarka Żandarmerii i protolat medyczny, potem trzeba go wszczepić.
// Przy śmierci nosiciela nadaje na kanały Żandarmerii i Medyczny (zgony w ciągu kilku sekund idą jednym komunikatem).

/// Zgony czekające na zbiorczy komunikat: lista list(imię, obszar)
GLOBAL_LIST_EMPTY(aq_death_alarm_queue)
/// Odstęp zbiorczego komunikatu, żeby abordaż albo wybuch nie zalał radia
#define DEATH_ALARM_BATCH_DELAY (5 SECONDS)

/obj/item/implant/security_down
	name = "implant „funkcjonariusz ranny”"
	activated = 0
	/// Głośny trzask zakłóceń przy śmierci (wersja Żandarmerii)
	var/death_sound = 'aquila/sound/misc/security_down.ogg'

/obj/item/implant/security_down/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> System powiadamiania o śmierci. <BR>Gdy ustają funkcje życiowe użytkownika, nadaje komunikat na kanały Żandarmerii i Medyczny[death_sound ? " i wydaje słyszalny dźwięk" : ""].<BR><b>Żywotność:</b> aktywuje się po śmierci.<BR>
				"}
	return dat

// Reaguje na faktyczną śmierć, a nie na emotkę *deathgasp, którą da się wywołać ręcznie
/obj/item/implant/security_down/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_MOB_DEATH, PROC_REF(on_owner_death))

/obj/item/implant/security_down/removed(mob/living/source, silent = FALSE, special = 0)
	. = ..()
	if(.)
		UnregisterSignal(source, COMSIG_MOB_DEATH)

/obj/item/implant/security_down/proc/on_owner_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(death_sound)
		playsound(source, death_sound, 50, 0)
	var/area/where = get_area(source)
	queue_death_alarm(source.real_name, where?.name || "nieznany obszar")

/// Dopisuje zgon do kolejki; pierwszy zgon w paczce uruchamia zbiorczy komunikat
/proc/queue_death_alarm(name, where)
	var/first = !length(GLOB.aq_death_alarm_queue)
	GLOB.aq_death_alarm_queue += list(list(name, where))
	if(first)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(flush_death_alarms)), DEATH_ALARM_BATCH_DELAY)

/// Nadaje zebrane zgony jednym komunikatem. Zwraca jego treść (test)
/proc/flush_death_alarms()
	var/list/queue = GLOB.aq_death_alarm_queue
	if(!length(queue))
		return null
	GLOB.aq_death_alarm_queue = list()
	var/message
	if(length(queue) == 1)
		message = "Alarm śmierci: [queue[1][1]] nie żyje (obszar: [queue[1][2]])."
	else
		var/list/parts = list()
		for(var/list/entry as anything in queue)
			if(length(parts) >= 6) // limit długości wiadomości radiowej
				break
			parts += "[entry[1]] ([entry[2]])"
		message = "Alarm śmierci: zgony ([length(queue)]): [parts.Join(", ")][length(queue) > length(parts) ? " i inni" : ""]."
	aq_security_announce(message, list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_MEDICAL))
	return message

/obj/item/implanter/security_down
	name = "implanter (funkcjonariusz ranny)"
	imp_type = /obj/item/implant/security_down

/obj/item/implantcase/security_down
	name = "etui na implant – „funkcjonariusz ranny”"
	desc = "Szklane etui z implantem „funkcjonariusz ranny”. Gdy nosiciel umiera, implant wydaje głośny trzask zakłóceń i nadaje alarm na kanały Żandarmerii i Medyczny."
	imp_type = /obj/item/implant/security_down

/// Ta sama logika bez trzasku: alarm śmierci dla reszty załogi
/obj/item/implant/security_down/crew
	name = "implant alarmu śmierci"
	death_sound = null

/obj/item/implantcase/security_down/crew
	name = "etui na implant – alarm śmierci"
	desc = "Szklane etui z implantem alarmu śmierci. Gdy nosiciel umiera, implant nadaje alarm na kanały Żandarmerii i Medyczny."
	imp_type = /obj/item/implant/security_down/crew

#undef DEATH_ALARM_BATCH_DELAY
