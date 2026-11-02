// Port BeeStation #8776: opisy, historia i unikalne cechy gatunków do okna wyboru gatunku (teksty z BeeStation)

/// Krótki opis gatunku w oknie wyboru
/datum/species/proc/get_species_description()
	return ""

/// Akapity historii gatunku, null gdy brak
/datum/species/proc/get_species_lore()
	return null

/// Lista cech (SPECIES_PERK_*) pokazywanych w oknie wyboru
/datum/species/proc/create_pref_unique_perks()
	return list()

/// Cechy pogrupowane tak, jak oczekuje okno
/datum/species/proc/get_species_perks()
	var/list/perks = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEGATIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
	)
	for(var/list/perk as anything in create_pref_unique_perks())
		var/list/perk_list = perks[perk[SPECIES_PERK_TYPE]]
		perk_list += list(list(
			"ui_icon" = perk[SPECIES_PERK_ICON],
			"name" = perk[SPECIES_PERK_NAME],
			"description" = perk[SPECIES_PERK_DESC],
		))
	return perks

/datum/species/ipc/get_species_description()
	return "IPC to najnowsze osiągnięcie sztucznego życia: w pełni zrobotyzowane, syntetyczne istoty z silników, obwodów i przewodów \
	- oparte na niedawno opracowanej technologii mózgu pozytronowego."

/datum/species/ipc/get_species_lore()
	return null

/datum/species/ipc/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Porażająco smaczne",
			SPECIES_PERK_DESC = "IPC odnawiają ładunek, żywiąc się prądem z APC i ogniw zasilających, i poza tym nie muszą jeść.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "robot",
			SPECIES_PERK_NAME = "Robotyczne",
			SPECIES_PERK_DESC = "IPC mają całkowicie robotyczne ciało, więc zwykle leczy je robotyka albo inżynieria. \
			Czy to pomaga, zależy w dużej mierze od współpracowników. Za to zwykle łatwo naprawisz się sam.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "magnet",
			SPECIES_PERK_NAME = "Podatne na EMP",
			SPECIES_PERK_DESC = "Organy IPC są cybernetyczne, więc podatne na zakłócenia elektromagnetyczne. Trafienie impulsem EMP może zatrzymać ci serce.",
		),
	)

	return to_add

/datum/species/apid/get_species_description()
	return "Pszczeloludzie, do cholery. Modne i żywe! Bzz bzz!"

/datum/species/apid/get_species_lore()
	return null

/datum/species/ethereal/get_species_description()
	return "Eterycy to wyjątkowy gatunek: zamiast krwi mają płynną elektryczność, a ich ciała świecą. Żywią się elektrycznością i z natury nie mają płci."

/datum/species/ethereal/get_species_lore()
	return null

/datum/species/human/felinid/get_species_description()
	return "Felinidzi to jedna z wielu odmian ludzi zmodyfikowanych genetycznie na zamówienie \
		dzięki mistrzostwu ludzkości w genetyce, a przy tym \
		jedna z najpowszechniejszych. Miau?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Felinidzi to bioinżynieria w najbardziej kociej postaci i szczytowy przykład tego, jak ludzkość opanowała kod genetyczny. \
			Spośród wielu odmian „zwierzoludzi” felinidzi są najpopularniejsi i najliczniejsi, a zarazem budzą jedne z \
			największych sporów wokół modyfikacji genetycznych.",

		"Modyfikatorzy ciała chętnie łączyli ludzkie i kocie DNA w poszukiwaniu świętej trójcy: uszu, oczu i ogona. \
			Te cechy cieszyły się ogromnym popytem, a skutki uboczne w postaci zmian głosu i neurochemii uznawano za drobną niedogodność.",

		"Niestety dla felinidów nie były to drobne niedogodności. Wielu uważało ich za podludzi i potwory, więc felinidzi (i inni zwierzoludzie) \
			szukali szczęścia w koloniach, zamykając się we własnych społecznościach. \
			Dlatego na obrzeżach ludzkiej przestrzeni żyje wielu zwierzoludzi.",
	)

/datum/species/fly/get_species_description()
	return "O pochodzeniu tego gatunku nie ma żadnych oficjalnych dokumentów \
		ani wiedzy, więc dla większości pozostaje on zagadką. Wszelkie plotki \
		o mucholudziach wśród personelu Nanotrasen szybko uciszają wysocy \
		rangą pracownicy albo urzędnicy."

/datum/species/fly/get_species_lore()
	return list(
		"Mucholudzie to ciekawy gatunek, uderzająco podobny do owadów z rzędu muchówek, \
		czyli po prostu much. Ich pochodzenie nie jest publicznie znane, a plotki głoszą, że są skutkiem ubocznym podróży przez bluespace, \
		mimo oświadczeń urzędników Nanotrasen.",

		"O pochodzeniu tej rasy wiadomo niewiele, \
		ale potrafią porozumiewać się z gigantycznymi pająkami, odkrytymi pierwotnie w sektorze Australicus, \
		a dziś pospolitymi na czarnym rynku dzięki przełomowi w badaniach Syndykatu nad bronią biologiczną.",

		"Inne gatunki często boją się mucholudzi albo ich unikają. Ich wygląd bywa opisywany jako niechlujny, a czasem przerażający, \
		nawyki żywieniowe jeszcze bardziej, a na dokładkę mają nieznośny akcent.",
	)

/datum/species/human/get_species_description()
	return "Ludzie to dominujący gatunek w znanej galaktyce. \
		Zamieszkują wszystko od starej Ziemi po krańce znanego kosmosu."

/datum/species/human/get_species_lore()
	return list(
		"Te istoty pochodzące od naczelnych, wywodzące się z w większości niegroźnej Ziemi, \
		dawno wyrosły ze swojego domu i z opinii w miarę nieszkodliwych. \
		Era kosmiczna wyprowadziła ludzi poza Układ Słoneczny, w szeroką galaktykę."
	)

/datum/species/lizard/get_species_description()
	return "Jaszczury, w przeciwieństwie do wielu gatunków „zwierzoludzi”, nie pochodzą od ludzi. To po prostu dwunożne istoty podobne do gadów. \
	Jaszczury często są bardzo dumne ze swojego gatunku."

/datum/species/lizard/get_species_lore()
	return null

/datum/species/moth/get_species_description()
	return "Ćmy to inteligentny gatunek, znany z zamiłowania do wszystkiego, co ćmie: światła, tkanin, skrzydeł i przyjaźni."

/datum/species/moth/get_species_lore()
	return null

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Cenne skrzydła",
			SPECIES_PERK_DESC = "Ćmy mogą latać w miejscach z ciśnieniem i bez grawitacji, a skrzydła pozwalają im bezpiecznie wylądować po krótkim upadku.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Jadłospis",
			SPECIES_PERK_DESC = "Ćmy mogą żywić się ubraniami.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Płonące skrzydła",
			SPECIES_PERK_DESC = "Skrzydła ćmy są delikatne i łatwo je spalić. W razie potrzeby ćma może jednak uprząść kokon, by je odzyskać.",
		),
	)

	return to_add

/datum/species/oozeling/get_species_description()
	return "Oozelingi są dosłownie zrobione z galaretki. To mięciutcy przyjaciele na pokładzie Stacji Kosmicznej 13."

/datum/species/oozeling/get_species_lore()
	return null

/datum/species/oozeling/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Plask!",
			SPECIES_PERK_DESC = "Oozelingi są wyjątkowo odporne na upadki, bo ich ciało i organy spłaszczają się przy uderzeniu. \
			Może trochę boleć, ale zwykle oozeling spadnie z dużo większej wysokości, zanim jego ważne organy zaczną się rozpłaszczać na miazgę.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "street-view",
			SPECIES_PERK_NAME = "Odrastające kończyny",
			SPECIES_PERK_DESC = "Oozelingi mogą do woli odtwarzać kończyny, o ile mają dość galaretki.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Wodowstręt",
			SPECIES_PERK_DESC = "Woda rozkłada oozelingi: kontakt z wodą, parą wodną albo jej wypicie może szybko odebrać im masę ciała.",
		)
	)

	return to_add

/datum/species/plasmaman/get_species_description()
	return "Plazmaludzie, odkryci na lodowym księżycu Freyja, składają się z kolonii \
		organizmów grzybowych, które razem tworzą świadomą istotę. W ludzkiej przestrzeni \
		zwykle osadza się je na szkieletach, by nadać im ludzki wygląd."

/datum/species/plasmaman/get_species_lore()
	return list(
		"Plazmaludzie to zagadkowy gatunek, prawdziwy „grzyb wśród nas”. \
		To, co wygląda na pojedynczą istotę, jest w rzeczywistości kolonią milionów organizmów \
		oplatającą znaleziony (albo dostarczony) szkielet.",

		"NT odkryło ich, gdy pewien badacz \
		wpadł do otwartego zbiornika z ciekłą plazmą, a niezauważona wcześniej kolonia grzybów przejęła jego ciało i stworzyła \
		pierwszego „prawdziwego” plazmamana. Od tamtej pory proces usprawniono dzięki hojnym darowiznom zwłok skazańców, a plazmaludzi \
		masowo rozmieszczono w całym NT, by wzmocnić siłę roboczą.",

		"Plazmaludzie są na galaktycznej scenie nowi i stanowią czystą kartę. \
		Ich wygląd, powszechnie uznawany za „upiorny”, budzi spory niepokój wśród reszty załogi. \
		Może chodzi o cały ten „łatwopalny fioletowy szkielet”.",

		"Kolonie tworzące plazmaludzi potrzebują bogatej w plazmę atmosfery, w której wyewoluowały. \
		Ich pseudoukład nerwowy działa na zewnętrznych impulsach elektrycznych, które w obecności tlenu natychmiast podpalają ich plazmowe ciała.",
	)

