// AQUILA - napływ ciemnej materii: póki działa grawitacja, załoga ma zawroty głowy, dezorientację, drgania obrazu i czasem wymiotuje (port z Aurora.3 code/modules/events/gravity_anomaly.dm)

/// Najwyższe zawroty i dezorientacja, do których dobija event (w oryginale rosły bez końca przez 24 min)
#define DARK_MATTER_MAX_DIZZINESS 60
#define DARK_MATTER_MAX_CONFUSION 30

/datum/round_event_control/aquila_hex_dark_matter_influx
	name = "Napływ ciemnej materii"
	typepath = /datum/round_event/aquila_hex_dark_matter_influx
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_dark_matter_influx
	announceWhen = 1
	startWhen = 1
	/// Tick, od którego znów trzęsie obrazem
	var/next_camera_drift = 0
	/// Tick najbliższego skoku grawitacji
	var/next_gravity_surge = 0
	var/static/list/nausea_minor = list(
		"Czujesz, jak pokład przechyla się pod tobą.",
		"Świat zdaje się szaleńczo przechylać.",
		"Przez chwilę masz złudzenie, że twój środek ciężkości się przesuwa.",
	)
	var/static/list/nausea_mild_organic = list(
		"Nagle coś przewraca ci się w żołądku i w uchu wewnętrznym.",
		"Nagle ogarniają cię mdlące zawroty głowy.",
		"Fala mdłości na chwilę przyprawia cię o zawroty głowy.",
	)
	var/static/list/nausea_mild_ipc = list(
		"Twoje czujniki propriocepcji na chwilę zalewają błędne odczyty.",
		"Przez chwilę tracisz wszelkie wyczucie orientacji żyroskopowej.",
		"Obraz jest w normie, ale twoje procesy poznawcze upierają się, że pomieszczenie szybko wiruje.",
	)
	var/static/list/nausea_strong_organic = list(
		"Do gardła podchodzi ci potężna fala mdłości.",
		"Czujesz się, jakbyś od godziny kręcił się w kółko.",
		"Ucho wewnętrzne i mózg krzyczą, żebyś przestał się obracać, ale przecież stoisz.",
	)
	var/static/list/nausea_strong_ipc = list(
		"BŁĄD: KOMPILATOR MACIERZY ŻYROSKOPOWEJ ZWRACA WARTOŚCI NIEPRAWIDŁOWEGO TYPU",
		"BŁĄD: KRYTYCZNA DESYNCHRONIZACJA PIERWOTNEGO I WTÓRNEGO SPRZĘŻENIA POZYCYJNEGO",
		"BŁĄD: CZUJNIKI NAPOTYKAJĄ WIELE NIECIĄGŁOŚCI WARTOŚCI",
	)

/datum/round_event/aquila_hex_dark_matter_influx/setup()
	endWhen = rand(240, 720) // 8–24 min

/datum/round_event/aquila_hex_dark_matter_influx/announce(fake)
	priority_announce("Wykryto przeciążenie układów generowania grawitacji spowodowane napływem ciemnej materii. Do czasu opuszczenia strefy należy spodziewać się niestabilności. Zalecane wyłączenie grawitacji na czas trwania zjawiska.", "Napływ ciemnej materii", ANNOUNCER_GRANOMALIES)

/datum/round_event/aquila_hex_dark_matter_influx/start()
	next_camera_drift = activeFor
	schedule_next_gravity_surge()
	if(!ship_gravity_on())
		return
	for(var/mob/living/carbon/human/victim as anything in current_victims())
		if(isipc(victim))
			to_chat(victim, "<span class='warning'>Twoje czujniki propriocepcji na chwilę zalewają błędne odczyty. Coś jest zdecydowanie nie tak z grawitacją.</span>")
		else
			to_chat(victim, "<span class='warning'>Nagle ogarniają cię mdlące zawroty głowy. Coś jest zdecydowanie nie tak z grawitacją.</span>")

/datum/round_event/aquila_hex_dark_matter_influx/tick()
	if(!ship_gravity_on())
		return
	var/list/victims = current_victims()
	if(!length(victims))
		return
	if(activeFor >= next_camera_drift)
		next_camera_drift = activeFor + rand(2, 4)
		for(var/mob/living/carbon/human/victim as anything in victims)
			if(prob(85))
				shake_camera(victim, rand(15, 50), 0.1)
	if(activeFor >= next_gravity_surge) // skok grawitacji trafia jedną osobę, jak w oryginale
		schedule_next_gravity_surge()
		apply_surge(pick(victims))
	for(var/mob/living/carbon/human/victim as anything in victims)
		var/roll = rand(1, 100) // 20% słabe, 8% średnie, 3% silne mdłości, jak w Aurorze
		if(roll <= 20)
			apply_nausea(victim, 1)
		else if(roll <= 28)
			apply_nausea(victim, 2)
		else if(roll <= 31)
			apply_nausea(victim, 3)

/datum/round_event/aquila_hex_dark_matter_influx/end()
	priority_announce("Czujniki grawimetryczne wskazują spadek strumienia ciemnej materii. Sztuczna grawitacja jest znów bezpieczna w normalnym użyciu.", "Napływ ciemnej materii")

/datum/round_event/aquila_hex_dark_matter_influx/proc/schedule_next_gravity_surge()
	next_gravity_surge = activeFor + rand(2, 10)

/// Czy na okręcie działa jakiś generator grawitacji
/datum/round_event/aquila_hex_dark_matter_influx/proc/ship_gravity_on()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		if(length(GLOB.gravity_generators["[z]"]))
			return TRUE
	return FALSE

/// Żywi gracze na okręcie, którzy stoją w grawitacji
/datum/round_event/aquila_hex_dark_matter_influx/proc/current_victims()
	. = list()
	for(var/mob/living/carbon/human/victim in GLOB.player_list)
		if(victim.stat == DEAD || !is_station_level(victim.z) || !victim.has_gravity())
			continue
		. += victim

/// Mdłości: 1 słabe, 2 średnie, 3 silne (wartości z Aurory, przycięte do limitów wyżej)
/datum/round_event/aquila_hex_dark_matter_influx/proc/apply_nausea(mob/living/carbon/human/victim, level)
	var/ipc = isipc(victim)
	switch(level)
		if(1)
			add_disorientation(victim, rand(4, 8), 10)
			if(prob(10))
				to_chat(victim, "<span class='warning'>[pick(nausea_minor)]</span>")
		if(2)
			add_disorientation(victim, rand(5, 8), rand(10, 15))
			if(prob(20))
				to_chat(victim, "<span class='warning'>[pick(ipc ? nausea_mild_ipc : nausea_mild_organic)]</span>")
			if(!ipc && prob(5))
				victim.vomit()
		if(3)
			add_disorientation(victim, rand(8, 15), rand(15, 20))
			if(prob(50))
				to_chat(victim, "<span class='warning'>[pick(ipc ? nausea_strong_ipc : nausea_strong_organic)]</span>")
				if(!ipc && prob(25))
					victim.vomit()

/// Skok grawitacji: silne mdłości i wstrząs obrazu (bez rzucania ludźmi po pokładzie z oryginału)
/datum/round_event/aquila_hex_dark_matter_influx/proc/apply_surge(mob/living/carbon/human/victim)
	var/ipc = isipc(victim)
	add_disorientation(victim, rand(10, 20), rand(20, 25))
	if(prob(33))
		to_chat(victim, "<span class='warning'>[pick(ipc ? nausea_strong_ipc : nausea_strong_organic)]</span>")
		if(!ipc)
			victim.vomit()
	if(victim.buckled)
		to_chat(victim, "<span class='warning'>Nagły skok grawitacji wciska cię w siedzenie!</span>")
		shake_camera(victim, 3, 1)
	else
		to_chat(victim, "<span class='warning'>Pokład szarpie pod tobą!</span>")
		shake_camera(victim, 10, 1)

/datum/round_event/aquila_hex_dark_matter_influx/proc/add_disorientation(mob/living/carbon/human/victim, dizziness, confusion)
	victim.dizziness = clamp(victim.dizziness + dizziness, 0, max(victim.dizziness, DARK_MATTER_MAX_DIZZINESS))
	victim.confused = clamp(victim.confused + confusion, 0, max(victim.confused, DARK_MATTER_MAX_CONFUSION))

#undef DARK_MATTER_MAX_DIZZINESS
#undef DARK_MATTER_MAX_CONFUSION
