/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	var/message
	var/flavor_text
	switch(announcement_treshold)
		if(PTL_MW)
			message = "Konto PTL zostało założone."
			flavor_text = "Od teraz będziecie otrzymywać regularne raporty o mocy wysłanej pokładowym laserem przesyłu. Powodzenia, [station_name()]!"
			// od założenia konta raport co 30 minut
			announcement_timer = addtimer(CALLBACK(src, PROC_REF(send_regular_ptl_announcement)), 30 MINUTES, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_LOOP)
		if(PTL_GW)
			message = "Pokładowy PTL wysłał już 1 gigawat mocy."
			flavor_text = "Dzięki tej mocy uratowaliśmy stację, której silnik supermaterii uległ delaminacji. Dobra robota!"
		if(PTL_TW)
			message = "Pokładowy PTL wysłał już 1 terawat mocy."
			flavor_text = "Wysłaliście tyle mocy, że przeciążyła sieć energetyczną stacji kosmicznej 15. Dobra robota!"
		if(PTL_PW)
			message = "Pokładowy PTL wysłał już 1 petawat mocy."
			flavor_text = "Wasz PTL wydajnością przegania wszystkie słoneczne platformy PTL Nanotrasen w sektorze. CentCom gratuluje osiągnięcia."
		if(PTL_EW)
			message = "Pokładowy PTL wysłał już 1 eksawat mocy."
			flavor_text = "Dzięki waszej mocy w pobliżu powstała placówka wydobycia plazmy bez własnego silnika! Tak trzymać, liczymy na was!"
		if(PTL_ZW)
			message = "Pokładowy PTL wysłał już 1 zettawat mocy."
			flavor_text = "Dzięki waszej mocy szybko zasililiśmy awaryjnie naszą flotę w opałach i wygraliśmy starcie z pobliskim okrętem Syndykatu. Świetna robota!"
		if(PTL_YW)
			message = "Pokładowy PTL wysłał już 1 jottawat mocy."
			flavor_text = "Nie spodziewaliśmy się aż tyle mocy i przez to [rand(1, 3)] nasze baterie przeładowały się i wysadziły [rand(1, 5)] stacje... tak trzymać?"
		if(PTL_RW)
			message = "Pokładowy PTL wysłał już 1 ronnawat mocy."
			flavor_text = "Ilość mocy, którą nam przesłaliście, pozwoliła wystrzelić z BSA w całą planetę. Obciążymy was za to 50 milionami kredytów po zmianie, bo wiemy, że was stać."
		if(PTL_QW)
			message = "Pokładowy PTL wysłał już 1 kwettawat mocy."
			flavor_text = "Dzięki wam zgromadziliśmy ogromne ilości mocy i założyliśmy kilka nowych placówek górniczych. Wasz Główny Inżynier otrzyma medal na specjalnej ceremonii, a wszyscy inżynierowie dostaną podwyżkę po przybyciu do CentComu. \
				Ale prosimy, przestańcie już wysyłać moc, bo nie mamy jej gdzie trzymać. Dalsze niekontrolowane wysyłanie będzie miało konsekwencje."
		else // wymagałoby 1e33 W, ale na wszelki wypadek
			message = "Pokładowy PTL wysłał niewyobrażalne ilości mocy."
			flavor_text = "Skończyły nam się nazwy rzędów wielkości. Dobra robota!"

	priority_announce("Osiągnięto nowy próg! [message] [flavor_text]", "Raport lasera przesyłu mocy", sender_override = "[command_name()] - dział energetyczny")
	announcement_treshold *= 1000

/obj/machinery/power/transmission_laser/proc/send_regular_ptl_announcement()
	priority_announce("Łącznie wysłano laserem przesyłu: [ptl_readable_power(total_power)]. Łączny zarobek: [total_earnings] kredytów.", "Regularny raport lasera przesyłu mocy", sender_override = "[command_name()] - dział energetyczny")
