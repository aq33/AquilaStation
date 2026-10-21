/// How long Sol lasts
#define TIME_VAMPIRE_DAY 90
/// The grace period inbetween Sol
#define TIME_VAMPIRE_NIGHT 1200
/// First audio warning that Sol is coming
#define TIME_VAMPIRE_DAY_WARN_1 90
/// Second audio warning that Sol is coming
#define TIME_VAMPIRE_DAY_WARN_2 30
/// Final audio warning that Sol is coming
#define TIME_VAMPIRE_DAY_WARN_3 15

///How much time Sol can be 'off' by, keeping the time inconsistent.
#define TIME_VAMPIRE_SOL_DELAY 120

SUBSYSTEM_DEF(sunlight)
	name = "Sol"
	wait = 1 SECONDS
	flags = SS_NO_INIT | SS_BACKGROUND

	///If the Sun is currently out our not.
	var/sunlight_active = FALSE
	///The time between the next cycle, randomized every night.
	var/time_til_cycle = TIME_VAMPIRE_NIGHT
	///If Vampire levels for the night has been given out already.
	var/issued_XP = FALSE
	///Whether to send ghost notifications for sunlight cycle events. Set to TRUE when a vampire antagonist is active.
	var/send_messages = FALSE

/datum/controller/subsystem/sunlight/fire(resumed = FALSE)
	time_til_cycle--
	if(sunlight_active)
		if(time_til_cycle > 0)
			SEND_SIGNAL(src, COMSIG_SOL_RISE_TICK)
			if(!issued_XP && time_til_cycle <= 15)
				issued_XP = TRUE
				SEND_SIGNAL(src, COMSIG_SOL_NEAR_END)
		if(time_til_cycle <= 1)
			sunlight_active = FALSE
			issued_XP = FALSE
			//randomize the next sol timer
			time_til_cycle = round(rand((TIME_VAMPIRE_NIGHT-TIME_VAMPIRE_SOL_DELAY), (TIME_VAMPIRE_NIGHT+TIME_VAMPIRE_SOL_DELAY)), 1)
			if(send_messages)
				notify_ghosts(
					"KOMUNIKAT WAMPIRZY: Dzień się skończył. Wraca noc (potrwa [time_til_cycle / 60] min).",
					flashwindow = FALSE
					)
			GLOB.news_network.submit_article(
				"<h1>Aktualizacja MAP - rozbłysk słoneczny minął</h1><br><br>\
				Oto aktualizacja Międzygwiezdnej Agencji Pogodowej. Ostatni rozbłysk słoneczny klasy I całkowicie minął już orbitę stacji [station_name()].<br><br>\
				Nie wykryto żadnych anomalii ani zakłóceń.<br><br>\
				- Administrator monitoringu MAP",
				"Międzygwiezdna Agencja Pogodowa (MAP)",
				"AuriNet WeatherCast"
			)
			SEND_SIGNAL(src, COMSIG_SOL_END)
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ENDED,
				vampire_warning_message = span_announce("Rozbłysk słoneczny dobiegł końca, a niebezpieczeństwo dnia minęło... na razie."),
				vassal_warning_message = span_announce("Rozbłysk słoneczny dobiegł końca, a niebezpieczeństwo dnia minęło... na razie."),
			)
		return

	switch(time_til_cycle)
		if(TIME_VAMPIRE_DAY_WARN_1)
			SEND_SIGNAL(src, COMSIG_SOL_NEAR_START)
			GLOB.news_network.submit_article("<h1>Komunikat MAP - wykryto niewielką aktywność słoneczną</h1><br><br>\
												To rutynowy komunikat Międzygwiezdnej Agencji Pogodowej. Zaobserwowano <b>rozbłysk słoneczny klasy I</b> pochodzący z Auri Geminae.<br><br>\
												<b>Przewidywane dotarcie do stacji [station_name()] za około [TIME_VAMPIRE_DAY_WARN_1 / 60] min.</b><br><br>\
												Procedury osłonowe nie są wymagane. Możliwe drobne zakłócenia sensorów dalekiego zasięgu i łączności. Załoga powinna zachować czujność i zgłaszać wszelkie anomalie dowództwu stacji.<br><br>\
												- Administrator monitoringu MAP",
												"Międzygwiezdna Agencja Pogodowa (MAP)",
												"AuriNet WeatherCast")
			warn_daylight(
				danger_level = DANGER_LEVEL_FIRST_WARNING,
				vampire_warning_message = span_danger("Za [TIME_VAMPIRE_DAY_WARN_1 / 60] min rozbłyski słoneczne zaleją stację niebezpiecznym promieniowaniem UV. <b>Przygotuj się, żeby schronić się w trumnie albo szafce.</b>")
			)
		if(TIME_VAMPIRE_DAY_WARN_2)
			if(send_messages)
				notify_ghosts(
					"KOMUNIKAT WAMPIRZY: dzień zacznie się za [TIME_VAMPIRE_DAY_WARN_2] s.",
					flashwindow = FALSE
				)
			warn_daylight(
				danger_level = DANGER_LEVEL_SECOND_WARNING,
				vampire_warning_message = span_dangerbold("Rozbłyski słoneczne zaraz uderzą w stację! Masz [TIME_VAMPIRE_DAY_WARN_2] sekund, żeby się ukryć!"),
				vassal_warning_message = span_danger("Za [TIME_VAMPIRE_DAY_WARN_2] sekund twojemu panu zagrozi rozbłysk słoneczny. Dopilnuj, żeby się ukrył!"),
			)
		if(TIME_VAMPIRE_DAY_WARN_3)
			warn_daylight(
				danger_level = DANGER_LEVEL_THIRD_WARNING,
				vampire_warning_message = span_narsiesmall("SOL ZNÓW WSCHODZI!"),
			)
		if(NONE)
			sunlight_active = TRUE
			//set the timer to countdown daytime now.
			time_til_cycle = TIME_VAMPIRE_DAY
			if(send_messages)
				notify_ghosts(
						"KOMUNIKAT WAMPIRZY: zaczyna się dzień (potrwa [TIME_VAMPIRE_DAY / 60] min).",
						flashwindow = FALSE
					)
			warn_daylight(
				danger_level = DANGER_LEVEL_SOL_ROSE,
				vampire_warning_message = span_danger("Rozbłyski słoneczne zalewają stację zabójczym światłem UV! Pozostań w ukryciu przez następne [TIME_VAMPIRE_DAY / 60] min!"),
				vassal_warning_message = span_danger("Rozbłyski słoneczne zalewają stację światłem UV!"),
			)

/datum/controller/subsystem/sunlight/proc/warn_daylight(danger_level, vampire_warning_message, vassal_warning_message)
	SEND_SIGNAL(src, COMSIG_SOL_WARNING_GIVEN, danger_level, vampire_warning_message, vassal_warning_message)

#undef TIME_VAMPIRE_SOL_DELAY

#undef TIME_VAMPIRE_DAY
#undef TIME_VAMPIRE_NIGHT
#undef TIME_VAMPIRE_DAY_WARN_1
#undef TIME_VAMPIRE_DAY_WARN_2
#undef TIME_VAMPIRE_DAY_WARN_3
