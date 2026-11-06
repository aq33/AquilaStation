/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/book/manual
	icon = 'icons/obj/library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = TRUE   // FALSE - Normal book, TRUE - Should not be treated as normal book, unable to be copied, unable to be modified

/obj/item/book/manual/hydroponics_pod_people
	name = "Ludzkie żniwa – od nasiona do targu"
	icon_state ="bookHydroponicsPodPeople"
	author = "Rolnik Jan" // Whoever wrote the paper or book, can be changed by pen or PC. It is not automatically assigned.
	title = "Ludzkie żniwa – od nasiona do targu"
	//book contents below
	dat = {"<h3>Hodowla ludzi</h3>

				Po co hodować ludzi? Cóż, spodziewam się, że większość czytelników zajmuje się handlem niewolnikami, ale niektórzy mogą naprawdę
				chcieć ożywić poległych towarzyszy. Hodowla ludzi ze strąków jest łatwa, ale łatwo też o katastrofę.
				<p>
				<ol>
				<li>Znajdź martwą osobę, która wymaga sklonowania. </li>
				<li>Pobierz strzykawką próbkę krwi. </li>
				<li>Wstrzyknij próbkę krwi do paczki nasion. </li>
				<li>Posadź nasiona. </li>
				<li>Pilnuj poziomu wody i składników odżywczych roślin, aż przyjdzie czas zebrać sklonowanego człowieka.</li>
				</ol>
				<p>
				To naprawdę takie proste! Powodzenia!"}

/obj/item/book/manual/ripley_build_and_repair
	name = "Podręcznik budowy i obsługi APLU \"Ripley\""
	icon_state ="book"
	author = "Weyland-Yutani Corp"
	title = "Podręcznik budowy i obsługi APLU \"Ripley\""
	dat = {"<center>
				<b style='font-size: 12px;'>Weyland-Yutani – budujemy lepsze światy</b>
				<h1>Autonomiczny ładowacz z napędem \"Ripley\"</h1>
				</center>
				<h2>Specyfikacja:</h2>
				<ul>
				<li><b>Klasa:</b> autonomiczny ładowacz z napędem</li>
				<li><b>Zastosowanie:</b> logistyka i budownictwo</li>
				<li><b>Masa:</b> 820 kg (bez operatora i z pustą ładownią)</li>
				<li><b>Wysokość:</b> 2,5 m</li>
				<li><b>Szerokość:</b> 1,8 m</li>
				<li><b>Prędkość maksymalna:</b> 5 km/h</li>
				<li><b>Praca w próżni / wrogim środowisku:</b> możliwa</b>
				<li><b>Pojemność zbiornika powietrza:</b> 500 litrów</li>
				<li><b>Urządzenia:</b>
					<ul>
					<li>Chwytak hydrauliczny</li>
					<li>Szybkoobrotowe wiertło</li>
					</ul>
				</li>
				<li><b>Napęd:</b> układ elektrohydrauliczny.</li>
				<li><b>Pojemność ogniwa zasilającego:</b> różna.</li>
				</ul>

				<h2>Budowa:</h2>
				<ol>
				<li>Podłącz wszystkie części egzoszkieletu do ramy podwozia.</li>
				<li>Podłącz wszystkie złączki hydrauliczne i dokręć je kluczem.</li>
				<li>Wyreguluj serwohydraulikę śrubokrętem.</li>
				<li>Okabluj podwozie (kabel nie jest dołączony).</li>
				<li>W razie potrzeby usuń nadmiar kabla przecinakiem.</li>
				<li>Zainstaluj centralny moduł sterowania (nie jest dołączony; wytwórz go z dołączonego dysku z danymi).</li>
				<li>Przykręć płytę główną śrubokrętem.</li>
				<li>Zainstaluj moduł sterowania peryferiami (nie jest dołączony; wytwórz go z dołączonego dysku z danymi).</li>
				<li>Przykręć moduł sterowania peryferiami śrubokrętem.</li>
				<li>Zamontuj wewnętrzne płyty pancerza (niedołączone z powodu przepisów Nanotrasen; można je zrobić z 5 arkuszy żelaza).</li>
				<li>Przykręć wewnętrzne płyty pancerza kluczem.</li>
				<li>Przyspawaj wewnętrzne płyty pancerza do podwozia.</li>
				<li>Zamontuj zewnętrzne wzmocnione płyty pancerza (niedołączone z powodu przepisów Nanotrasen; można je zrobić z 5 arkuszy wzmocnionego żelaza).</li>
				<li>Przykręć zewnętrzne wzmocnione płyty pancerza kluczem.</li>
				<li>Przyspawaj zewnętrzne wzmocnione płyty pancerza do podwozia.</li>
				<li></li>
				<li>Informacje dodatkowe:</li>
				<li>Wersję strażacką buduje się podobnie.</li>
				<li>Do podwozia wersji strażackiej trzeba podłączyć kombinezon przeciwpożarowy jako osłonę termiczną.</li>
				<li>Wewnętrzny pancerz jest z plastali dla dodatkowej wytrzymałości.</li>
				<li>Zewnętrzny pancerz montuje się w 2 częściach, łącznie 10 arkuszy.</li>
				<li>Gotowy mech jest odporniejszy na ogień i ogólnie nieco wytrzymalszy.</li>
				<li>Nanotrasen dba o bezpieczeństwo swoich <s>inwestycji</s> pracowników.</li>
				</ol>

				<h2>Obsługa:</h2>
				Zajrzyj do kompendium Nanotrasen „Robotyka dla opornych”.
			"}

/obj/item/book/manual/chef_recipes
	name = "Przepisy kucharza"
	icon_state = "cooked_book"
	author = "Lord Frenrir Cageth"
	title = "Przepisy kucharza"
	dat = {"<h1>Jedzenie dla opornych</h1>
				Oto przewodnik po podstawowych przepisach i po tym, jak przypadkiem nie otruć klientów.


				<h2>Przygotowanie podstawowych składników:</h2>

				<b>Ciasto:</b> 10 j. wody + 15 j. mąki daje zwykłe ciasto.<br>
				15 j. żółtka + 15 j. mąki + 5 j. cukru daje masę na ciasto.<br>
				Ciasto można przerabiać nożem i wałkiem do ciasta.<br>
				Każde ciasto można upiec w mikrofalówce.<br>
				<b>Miska:</b> dodaj do niej wodę, żeby przygotować zupę.<br>
				<b>Mięso:</b> upiecz je w mikrofalówce, przetwórz, pokrój nożem na kotlety do mikrofalówki albo użyj na surowo.<br>
				<b>Ser:</b> dodaj 5 j. enzymu uniwersalnego (katalizator) do mleka i mleka sojowego, żeby zrobić ser (do krojenia) i tofu.<br>
				<b>Ryż:</b> wymieszaj w misce 10 j. ryżu z 10 j. wody, a potem podgrzej w mikrofalówce.

				<h2>Własne dania:</h2>
				Dodawaj składniki do bazy, żeby przygotować własne danie.<br>
				Bazy to:<br>
				- bułka (burger)<br>
				- kromki chleba (kanapka)<br>
				- zwykły chleb<br>
				- zwykły placek<br>
				- ciasto waniliowe<br>
				- pusta miska (sałatka)<br>
				- miska z 10 j. wody (zupa)<br>
				- ugotowane spaghetti<br>
				- spód do pizzy<br>
				- żelazny pręt (kebab)

				<h2>Wytwarzanie na stole:</h2>
				Połóż składniki na stole, a potem kliknij i przeciągnij stół na siebie, żeby zobaczyć, co możesz przygotować.

				<h2>Mikrofalówka:</h2>
				Służy do gotowania i pieczenia składników (mięso, ciasto, jajka, spaghetti, pierogi itd.).
				Może przygotować kilka rzeczy naraz.

				<h2>Przetwórca:</h2>
				Służy do przetwarzania niektórych składników (mięso w klopsiki, porcję ciasta w spaghetti, ziemniaki we frytki itd.)

				<h2>Mielarka:</h2>
				Wepchnij do niej zwierzę, żeby zmielić je na mięso.

				<h2>Hak na mięso:</h2>
				Nadziej na niego zwierzę i zacznij zbierać mięso.


				<h2>Przykładowe przepisy:</h2>
				<b>Ciasto waniliowe</b>: upiecz masę na ciasto w mikrofalówce.<br>
				<b>Burger:</b> 1 bułka + 1 stek<br>
				<b>Chleb:</b> upiecz ciasto w mikrofalówce.<br>
				<b>Gofry:</b> 2 spody do ciasta<br>
				<b>Popcorn:</b> podgrzej kukurydzę w mikrofalówce.<br>
				<b>Stek:</b> upiecz mięso w mikrofalówce.<br>
				<b>Placek z mięsem:</b> 1 zwykły placek + 1 j. czarnego pieprzu + 1 j. soli + 2 kotlety<br>
				<b>Ugotowane spaghetti:</b> podgrzej spaghetti w mikrofalówce.<br>
				<b>Pączki:</b> 1 j. cukru + 1 spód do ciasta<br>
				<b>Frytki:</b> przetwórz ziemniaka.

				<h2>Dzielenie się jedzeniem:</h2>
				Możesz kłaść dania na blacie kuchennym albo ładować je do automatów z przekąskami."}

/obj/item/book/manual/nuclear
	name = "Rozszczepienie nieudane: sabotaż jądrowy dla początkujących"
	icon_state ="bookNuclear"
	author = "Syndykat"
	title = "Rozszczepienie nieudane: sabotaż jądrowy dla początkujących"
	dat = {"Ładunki jądrowe dla początkujących:<br>
			Dzień dobry i dziękujemy, że w sprawach wiedzy jądrowej wybierasz Syndykat.<br>
			Dzisiejszy przyspieszony kurs dotyczy obsługi ładunku jądrowego klasy fuzyjnej produkcji Nanotrasen.<br>
			Przede wszystkim NIE DOTYKAJ NICZEGO, DOPÓKI BOMBA NIE BĘDZIE NA MIEJSCU.<br>
			Naciśnięcie dowolnego przycisku na złożonej bombie sprawi, że się rozłoży i przykręci na miejscu.<br>
			Żeby ją wtedy odkręcić, trzeba się w pełni zalogować, co w tej chwili może nie być możliwe.<br>
			Żeby uruchomić ładunek jądrowy:<br>
			<li>Umieść ładunek jądrowy w wyznaczonej strefie detonacji.</li>
			<li>Rozłóż i zakotwicz ładunek jądrowy z poziomu jego interfejsu.</li>
			<li>Włóż dysk autoryzacji jądrowej do gniazda.</li>
			<li>Wpisz na klawiaturze numeryczny kod autoryzacji. Powinieneś go otrzymać. Uwaga: jeśli się pomylisz, naciśnij R, żeby zresetować urządzenie.
			<li>Naciśnij przycisk E, żeby zalogować się do urządzenia.</li>
			Urządzenie jest teraz aktywne. Żeby w dowolnej chwili dezaktywować przyciski, na przykład gdy bomba jest już przygotowana do detonacji, wyjmij dysk autoryzacji ALBO naciśnij R na klawiaturze.<br>
			Teraz bombę MOŻNA zdetonować TYLKO zapalnikiem czasowym. Ręczna detonacja nie wchodzi w grę.<br>
			Uwaga: Nanotrasen to wrzód na tyłku.<br>
			Wyłącz BEZPIECZNIK.<br>
			Uwaga: nie uwierzyłbyś, ilu agentów Syndykatu z doktoratem zapomniało o tym kroku.<br>
			Użyj - - i + +, żeby ustawić czas detonacji od 5 sekund do 10 minut.<br>
			Potem naciśnij przycisk zapalnika, żeby zacząć odliczanie.<br>
			Teraz wyjmij dysk autoryzacji, żeby przyciski się dezaktywowały.<br>
			Uwaga: BOMBA WCIĄŻ JEST USTAWIONA I WYBUCHNIE<br>
			Jeśli przed wyjęciem dysku musisz przenieść bombę, możesz:<br>
			wyłączyć kotwiczenie, przenieść ją i zakotwiczyć ponownie.<br><br>
			Powodzenia. Zapamiętaj kolejność:<br>
			<b>Dysk, kod, bezpiecznik, zapalnik, dysk, UCIEKAJ!</b><br>
			Analitycy wywiadu uważają, że według standardowej procedury Nanotrasen dysk autoryzacji jądrowej zabezpiecza kapitan.<br>
			Powodzenia!"}

// Wiki books that are linked to the configured wiki link.

// A book that links to the wiki
/obj/item/book/manual/wiki
	var/page_link = ""

/obj/item/book/manual/wiki/Initialize(mapload)
	. = ..()

/obj/item/book/manual/wiki/attack_self(mob/user)
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(!wikiurl)
		return
	if(alert(user, "To otworzy stronę wiki w twojej przeglądarce. Na pewno?", null, "Tak", "Nie") != "Tak")
		return
	DIRECT_OUTPUT(user, link("[wikiurl]/[page_link]"))

/obj/item/book/manual/wiki/chemistry
	name = "Podręcznik chemii"
	icon_state ="chemistrybook"
	author = "Nanotrasen"
	title = "Podręcznik chemii"
	page_link = "Guide_to_chemistry"

/obj/item/book/manual/wiki/engineering_construction
	name = "Naprawy i budowa na stacji"
	icon_state ="bookEngineering"
	author = "Encyklopedia Inżynierii"
	title = "Naprawy i budowa na stacji"
	page_link = "Guide_to_construction"

/obj/item/book/manual/wiki/engineering_guide
	name = "Podręcznik inżynierii"
	icon_state ="bookEngineering2"
	author = "Encyklopedia Inżynierii"
	title = "Podręcznik inżynierii"
	page_link = "Guide_to_engineering"

/obj/item/book/manual/wiki/engineering_singulo_tesla
	name = "Osobliwość i Tesla dla opornych"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Encyklopedia Inżynierii"
	title = "Osobliwość i Tesla dla opornych"
	page_link = "Singularity_and_Tesla_engines"

/obj/item/book/manual/wiki/security_space_law
	name = "Prawo kosmiczne"
	desc = "Zbiór wytycznych Nanotrasen dotyczących utrzymania prawa i porządku na jej stacjach kosmicznych."
	icon_state = "bookSpaceLaw"
	author = "Nanotrasen"
	title = "Prawo kosmiczne"
	page_link = "Space_Law"

/obj/item/book/manual/wiki/security_space_law/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] udaje, że uważnie czyta [src]... po czym natychmiast umiera ze śmiechu!</span>")
	return OXYLOSS

/obj/item/book/manual/wiki/infections
	name = "Infekcje – zrób sobie własną pandemię!"
	icon_state = "bookInfections"
	author = "Encyklopedia Infekcji"
	title = "Infekcje – zrób sobie własną pandemię!"
	page_link = "Infections"

/obj/item/book/manual/wiki/telescience
	name = "Nauka o teleportacji – bluespace dla opornych!"
	icon_state = "book7"
	author = "Uniwersytet Bluespace"
	title = "Nauka o teleportacji – bluespace dla opornych!"
	page_link = "Guide_to_telescience"

/obj/item/book/manual/wiki/engineering_hacking
	name = "Hakowanie"
	icon_state ="bookHacking"
	author = "Encyklopedia Inżynierii"
	title = "Hakowanie"
	page_link = "Hacking"

/obj/item/book/manual/wiki/detective
	name = "Film noir: właściwe procedury śledcze"
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "Film noir: właściwe procedury śledcze"
	page_link = "Detective"

/obj/item/book/manual/wiki/barman_recipes
	name = "Przepisy barmana: mieszanie drinków i zmienianie życia"
	icon_state = "barbook"
	author = "Sir John Rose"
	title = "Przepisy barmana: mieszanie drinków i zmienianie życia"
	page_link = "Guide_to_drinks" //NSV13 - Split the Guide to Food and Drinks into two separate pages

/obj/item/book/manual/wiki/robotics_cyborgs
	name = "Robotyka dla opornych"
	icon_state = "borgbook"
	author = "XISC"
	title = "Robotyka dla opornych"
	page_link = "Guide_to_robotics"

/obj/item/book/manual/wiki/research_and_development
	name = "Badania i rozwój dla początkujących"
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Badania i rozwój dla początkujących"
	page_link = "Guide_to_Research_and_Development"

/obj/item/book/manual/wiki/experimentor
	name = "Prowadzenie eksperymentów"
	icon_state = "rdbook"
	author = "Dr. H.P. Kritz"
	title = "Prowadzenie eksperymentów"
	page_link = "Experimentor"

/obj/item/book/manual/wiki/medical_cloning
	name = "Techniki klonowania XXVI wieku"
	icon_state ="bookCloning"
	author = "Dziennik Medyczny, tom 3"
	title = "Techniki klonowania XXVI wieku"
	page_link = "Guide_to_genetics#Cloning"

/obj/item/book/manual/wiki/cooking_to_serve_man
	name = "Jak służyć człowiekowi"
	desc = "To książka kucharska!"
	icon_state ="cooked_book"
	author = "Imperium Kanamitów"
	title = "Jak służyć człowiekowi"
	page_link = "Guide_to_food" //NSV13 - Split the Guide to Food and Drinks into two separate pages

/obj/item/book/manual/wiki/tcomms
	name = "Telekomunikacja podprzestrzenna i ty"
	icon_state = "book3"
	author = "Encyklopedia Inżynierii"
	title = "Telekomunikacja podprzestrzenna i ty"
	page_link = "Guide_to_Telecommunications"

/obj/item/book/manual/wiki/atmospherics
	name = "Lexica Atmosia"
	icon_state = "book5"
	author = "Miasto-państwo Atmosja"
	title = "Lexica Atmosia"
	page_link = "Guide_to_Atmospherics"

/obj/item/book/manual/wiki/medicine
	name = "Kosmiczne kompendium medyczne, tom 638"
	icon_state = "book8"
	author = "Dziennik Medyczny"
	title = "Kosmiczne kompendium medyczne, tom 638"
	page_link = "Guide_to_medicine"

/obj/item/book/manual/wiki/surgery
	name = "Chirurgia mózgu dla opornych"
	icon_state = "book4"
	author = "Dr. F. Fran"
	title = "Chirurgia mózgu dla opornych"
	page_link = "Surgery"

/obj/item/book/manual/wiki/grenades
	name = "Granaty chemiczne – zrób to sam"
	icon_state = "book2"
	author = "W. Powell"
	title = "Granaty chemiczne – zrób to sam"
	page_link = "Grenade"

/obj/item/book/manual/wiki/toxins
	name = "Toksyny, czyli jak przestałem się martwić i pokochałem maxcapa"
	icon_state = "book6"
	author = "Cuban Pete"
	title = "Toksyny, czyli jak przestałem się martwić i pokochałem maxcapa"
	page_link = "Guide_to_toxins"

//NSV13 - Change
//Standard operating procedure books. Inherited of wiki books.

/obj/item/book/manual/wiki/sop
	author = "Ta-Go Clown Resources"
	icon = 'nsv13/icons/obj/nsv_bureaucracy.dmi' //created own dmi for the books

/obj/item/book/manual/wiki/sop/security
	name = "Standardowa procedura operacyjna: ochrona"
	title = "Standardowa procedura operacyjna: ochrona"
	page_link = "Department_Standard_Operating_Procedure:_Security"
	icon_state = "sop_sec"

/obj/item/book/manual/wiki/sop/science
	name = "Standardowa procedura operacyjna: nauka"
	title = "Standardowa procedura operacyjna: nauka"
	page_link = "Department_Standard_Operating_Procedure:_Science"
	icon_state = "sop_sci"

/obj/item/book/manual/wiki/sop/service
	name = "Standardowa procedura operacyjna: służba"
	title = "Standardowa procedura operacyjna: służba"
	page_link = "Department_Standard_Operating_Procedure:_Service/Civilian"
	icon_state = "sop_service"

/obj/item/book/manual/wiki/sop/command
	name = "Standardowa procedura operacyjna: dowództwo"
	title = "Standardowa procedura operacyjna: dowództwo"
	page_link = "Department_Standard_Operating_Procedure:_Command"
	icon_state = "sop_comdom"

/obj/item/book/manual/wiki/sop/engineering
	name = "Standardowa procedura operacyjna: inżynieria"
	title = "Standardowa procedura operacyjna: inżynieria"
	page_link = "Department_Standard_Operating_Procedure:_Engineering"
	icon_state = "sop_engi"

/obj/item/book/manual/wiki/sop/supply
	name = "Standardowa procedura operacyjna: zaopatrzenie"
	title = "Standardowa procedura operacyjna: zaopatrzenie"
	page_link = "Department_Standard_Operating_Procedure:_Supply"
	icon_state = "sop_cargo"

/obj/item/book/manual/wiki/sop/medical
	name = "Standardowa procedura operacyjna: dział medyczny"
	title = "Standardowa procedura operacyjna: dział medyczny"
	page_link = "Department_Standard_Operating_Procedure:_Medical"
	icon_state = "sop_med"

/obj/item/book/manual/wiki/sop/munitions
	name = "Standardowa procedura operacyjna: amunicja"
	title = "Standardowa procedura operacyjna: amunicja"
	page_link = "Department_Standard_Operating_Procedure:_Munitions"
	icon_state = "sop_muni"

	//Should only be used as maint loot / easter eggs
/obj/item/book/manual/wiki/sop/munitions/puce
	icon_state = "sop_muni_puce"

/obj/item/book/manual/wiki/sop/catalogue //Directs to standard SoP page. Able to check any department at will. For command / lawyer
	name = "Standardowa procedura operacyjna: katalog"
	title = "Standardowa procedura operacyjna: katalog"
	page_link = "Standard_Operating_Procedure"
	icon_state = "sop_catalogue"

/obj/item/book/manual/wiki/supermatter_guide //NSV13
	name = "Podręcznik supermaterii"
	icon_state ="bookEngineering2"
	author = "Encyklopedia Inżynierii"
	title = "Podręcznik supermaterii"
	page_link = "Guide_to_the_Supermatter"

/obj/item/book/manual/wiki/toxins/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] zaczyna tańczyć w rytm Rumby! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(H))
		H.emote("spin")
		sleep(20)
		for(var/obj/item/W in H)
			H.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(H, TRAIT_DISFIGURED, TRAIT_GENERIC)
		H.add_bleeding(BLEED_CRITICAL)
		H.gib_animation()
		sleep(3)
		H.adjustBruteLoss(1000) //to make the body super-bloody
		H.spawn_gibs()
		H.spill_organs()
		H.spread_bodyparts()
	return (BRUTELOSS)

/obj/item/book/manual/wiki/plumbing
	name = "Fabryki chemiczne bez narkotyków"
	icon_state ="plumbingbook"
	author = "Nanotrasen"
	title = "Fabryki chemiczne bez narkotyków"
	page_link = "Guide_to_plumbing"


/obj/item/book/manual/wiki/hydroponics
	name = "Botaniczny przewodnik terenowy"
	icon_state ="botany"
	author = "Yamato"
	title = "Botaniczny przewodnik terenowy"
	//TODO: Temporary link - Racc
	page_link = "User:Racc-Off/botany"

/obj/item/book/manual/wiki/hydroponics/tutorial
	color = "#f00" //Make it easier for mappers to identify

/obj/item/book/manual/wiki/hydroponics/tutorial/Initialize(mapload)
	. = ..()
	color = "#fff"
	new /obj/item/sticker/sticky_note/tutorial/book(src)
/obj/item/book/manual/wiki/xenoarchaeology
	name = "Przewodnik terenowy ksenoarcheologii"
	icon_state ="xenoarchaeology"
	author = "Phillippe French"
	title = "Przewodnik terenowy ksenoarcheologii"
	page_link = "Guide_to_Artifacts"
