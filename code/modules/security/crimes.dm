#define MAX_TIMER 10 HOURS //Permabrig.
#define PRESET_SHORT 5 MINUTES
#define PRESET_MEDIUM 10 MINUTES
#define PRESET_LONG 15 MINUTES

#define CRIME_MINOR "Wykroczenia"
#define CRIME_MISDEMEANOUR "Występki"
#define CRIME_MAJOR "Przestępstwa"
#define CRIME_CAPITAL "Zbrodnie"

/* This is overwritten by the config (space_law.json as of writting this), this only exists as a backup in case the game fails to load said file.
Do not modify this unless you know what you're doing. */

/datum/crime
	var/name
	var/tooltip
	var/colour
	var/icon
	var/sentence
	var/category

/datum/crime/minor
	category = CRIME_MINOR
	sentence = PRESET_SHORT
	colour="yellow"

/datum/crime/minor/assault
	name = "Napaść"
	icon = "hand-rock"
	tooltip = "Użycie siły fizycznej wobec kogoś bez widocznego zamiaru zabicia go."

/datum/crime/minor/pickpocketting
	name = "Kieszonkowstwo"
	icon = "mask"
	tooltip = "Kradzież przedmiotów z osoby innego człowieka."

/datum/crime/minor/minor_vandalism
	name = "Drobny wandalizm"
	icon = "house-damage"
	tooltip = "Uszkodzenie, zniszczenie lub trwałe oszpecenie niekrytycznych mebli, automatów lub mienia osobistego."

/datum/crime/minor/vigilantism
	name = "Samosądy"
	icon = "user-secret"
	tooltip = "Wykonywanie obowiązków i zadań działu ochrony bez zgody lub uzasadnionej przyczyny."

/datum/crime/minor/illegal_distribution
	name = "Nielegalna dystrybucja"
	icon = "joint"
	tooltip = "Posiadanie niebezpiecznych lub nielegalnych narkotyków/sprzętu w ilości większej niż rozsądna do użytku osobistego."

/datum/crime/minor/disturbing
	name = "Zakłócanie porządku"
	icon = "fist-raised"
	tooltip = "Świadome organizowanie ruchu, który zakłóca normalną pracę działu."

/datum/crime/minor/negligence
	name = "Zaniedbanie"
	icon = "low-vision"
	tooltip = "Zaniedbanie obowiązków w stopniu, który może spowodować krzywdę, chorobę lub inne negatywne skutki dla innej osoby."

/datum/crime/minor/trespass
	name = "Wtargnięcie"
	icon = "walking"
	tooltip = "Przebywanie w obszarze, do którego dana osoba nie została celowo wpuszczona, nie ma dostępu lub z którego kazała jej wyjść osoba mająca do niego dostęp."

/datum/crime/minor/breaking_and_entering
	name = "Włamanie"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru z użyciem siłowego wejścia."

/datum/crime/minor/discriminatory_language
	name = "Język dyskryminujący"
	icon = "comment-slash"
	tooltip = "Używanie języka, który poniża, uogólnia lub w inny sposób odczłowiecza osobę, do której jest skierowany."

/datum/crime/minor/fine_evasion
	name = "Uchylanie się od grzywny"
	icon = "dollar-sign"
	tooltip = "Celowe unikanie lub odmowa zapłaty legalnej grzywny."

/datum/crime/minor/religious_activity
	name = "Działalność religijna poza kaplicą"
	icon = "cross"
	tooltip = "Nawracanie, prozelityzm, odprawianie rytuałów lub inne próby działania w imieniu religii lub bóstwa poza kaplicą."

/datum/crime/misdemeanour
	category = CRIME_MISDEMEANOUR
	sentence = PRESET_MEDIUM
	colour="orange"

/datum/crime/misdemeanour/aggravated_assault
	name = "Ciężkie pobicie"
	icon = "user-injured"
	tooltip = "Podjęcie działań fizycznych wobec osoby z zamiarem ciężkiego zranienia, ale nie zabicia."

/datum/crime/misdemeanour/theft
	name = "Kradzież"
	icon = "mask"
	tooltip = "Kradzież sprzętu lub przedmiotów z miejsca pracy albo przedmiotów o nadzwyczajnej wartości z osoby."

/datum/crime/misdemeanour/vandilism
	name = "Poważny wandalizm"
	icon = "house-damage"
	tooltip = "Zniszczenie lub uszkodzenie niekrytycznych mebli, automatów lub mienia osobistego w sposób, którego nie da się naprawić."

/datum/crime/misdemeanour/conspiracy
	name = "Zmowa"
	icon = "user-friends"
	tooltip = "Świadoma współpraca z inną osobą w celu popełnienia czynu niezgodnego z prawem."

/datum/crime/misdemeanour/hostile_agent
	name = "Wrogi agent"
	icon = "user-ninja"
	tooltip = "Świadome działanie jako rekruter, przedstawiciel, posłaniec, sojusznik, dobroczyńca lub inny współpracownik wrogiej organizacji w rozumieniu Kodeksu 405 (EOTC)."

/datum/crime/misdemeanour/contraband
	name = "Posiadanie sprzętu z przemytu"
	icon = "briefcase"
	tooltip = "Posiadanie sprzętu niezatwierdzonego do użytku lub produkcji na stacjach Nanotrasen. Obejmuje to sprzęt wytwarzany przez Syndykat, Federację Czarodziejów lub inną wrogą organizację w rozumieniu Kodeksu 405 (EOTC)."

/datum/crime/misdemeanour/rioting
	name = "Udział w zamieszkach"
	icon = "fist-raised"
	tooltip = "Działanie jako członek grupy, która wspólnie dopuszcza się poważnego wandalizmu, sabotażu, wielkiego sabotażu lub innych zbrodni."

/datum/crime/misdemeanour/negligence
	name = "Rażące zaniedbanie"
	icon = "blind"
	tooltip = "Zaniedbanie obowiązków w stopniu, który może spowodować krzywdę wielu osób lub działu albo w sposób, który bezpośrednio prowadzi do poważnego obrażenia innej osoby wymagającego pilnej pomocy medycznej."

/datum/crime/misdemeanour/tresspass
	name = "Wtargnięcie do strefy niebezpiecznej"
	icon = "door-closed"
	tooltip = "Wtargnięcie do obszaru, które może prowadzić do zranienia siebie lub innych."

/datum/crime/misdemeanour/entering
	name = "Włamanie do strefy niebezpiecznej"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru, które może prowadzić do zranienia siebie lub innych, z użyciem siłowego wejścia."

/datum/crime/misdemeanour/insubordination
	name = "Niesubordynacja"
	icon = "hand-middle-finger"
	tooltip = "Świadome nieposłuszeństwo wobec zgodnego z prawem rozkazu przełożonego."

/datum/crime/misdemeanour/fraud
	name = "Oszustwo"
	icon = "comment-dollar"
	tooltip = "Wprowadzanie w błąd co do swoich zamiarów w celu uzyskania mienia lub pieniędzy od innej osoby."

/datum/crime/misdemeanour/genetic_mutilation
	name = "Okaleczenie genetyczne"
	icon = "dna"
	tooltip = "Celowa modyfikacja kodu genetycznego osoby bez jej zgody lub z zamiarem wyrządzenia krzywdy."

/datum/crime/major
	category = CRIME_MAJOR
	sentence = PRESET_LONG
	colour="bad"

/datum/crime/major/murder
	name = "Zabójstwo"
	icon = "skull"
	tooltip = "Celowe zabicie kogoś."

/datum/crime/major/larceny
	name = "Kradzież mienia znacznej wartości"
	icon = "mask"
	tooltip = "Kradzież rzadkiego, drogiego (przedmioty o wartości ponad 1000 kredytów) lub zastrzeżonego sprzętu z obszarów chronionych lub z osoby."

/datum/crime/major/sabotage
	name = "Sabotaż"
	icon = "bomb"
	tooltip = "Zniszczenie mienia lub zasobów stacji krytycznych dla normalnych lub awaryjnych procedur stacji albo doprowadzenie do tego, że części stacji nie nadają się do zamieszkania."

/datum/crime/major/conspiracy
	name = "Poważna zmowa"
	icon = "users"
	tooltip = "Świadoma współpraca z inną osobą w celu popełnienia poważnego lub cięższego przestępstwa."

/datum/crime/major/hostile
	name = "Działalność wroga"
	icon = "thumbs-down"
	tooltip = "Świadome popełnienie czynu sprzecznego z interesami Nanotrasen albo bezpośrednia pomoc znanemu wrogowi korporacji."

/datum/crime/major/contraband
	name = "Posiadanie nielegalnego, niebezpiecznego sprzętu"
	icon = "exclamation-triangle"
	tooltip = "Posiadanie zastrzeżonego lub nielegalnego sprzętu, którego głównym przeznaczeniem jest krzywdzenie innych lub powodowanie dużych zniszczeń."

/datum/crime/major/riot
	name = "Podżeganie do buntu"
	icon = "fist-raised"
	tooltip = "Podejmowanie działań mających wywołać duże niepokoje, aż po zamieszki włącznie."

/datum/crime/major/manslaughter
	name = "Nieumyślne spowodowanie śmierci"
	icon = "book-dead"
	tooltip = "Nieumyślne zabicie kogoś w wyniku niedbałych, lecz nie złośliwych działań."

/datum/crime/major/tresspass
	name = "Wtargnięcie do strefy wysokiego bezpieczeństwa"
	icon = "running"
	tooltip = "Wtargnięcie bez odpowiedniego pozwolenia lub dostępu do któregokolwiek z poniższych: obszarów dowództwa, gabinetów, zbrojowni, produkcji broni, magazynów materiałów wybuchowych, produkcji materiałów wybuchowych lub innych obszarów o wysokim stopniu zabezpieczenia."

/datum/crime/major/break_enter
	name = "Włamanie do strefy wysokiego bezpieczeństwa"
	icon = "door-open"
	tooltip = "Wtargnięcie do obszaru chronionego w rozumieniu Kodeksu 309 (Wtargnięcie, obszary wysokiego bezpieczeństwa) z użyciem siłowego wejścia."

/datum/crime/major/dereliction
	name = "Porzucenie obowiązków"
	icon = "walking"
	tooltip = "Umyślne porzucenie obowiązku krytycznego dla dalszego funkcjonowania stacji."

/datum/crime/major/fraud
	name = "Oszustwo na szkodę korporacji"
	icon = "hand-holding-usd"
	tooltip = "Wprowadzanie w błąd co do swoich zamiarów w celu uzyskania mienia lub pieniędzy od Nanotrasen albo uzyskiwanie lub przekazywanie mienia lub pieniędzy Nanotrasen bez odpowiedniego upoważnienia."

/datum/crime/major/impersonation
	name = "Kradzież tożsamości"
	icon = "theater-masks"
	tooltip = "Podszywanie się pod inną osobę."

/datum/crime/capital
	category = CRIME_CAPITAL
	sentence = MAX_TIMER
	colour = "grey"

/datum/crime/capital/murder
	name = "Zabójstwo kwalifikowane"
	icon = "skull-crossbones"
	tooltip = "Popełnienie morderstwa z wyraźnym zamiarem zabicia oraz wyraźnym zamiarem lub faktycznymi działaniami mającymi uniemożliwić wskrzeszenie ofiary"

/datum/crime/capital/larcany
	name = "Kradzież przedmiotów niebezpiecznych"
	icon = "mask"
	tooltip = "Kradzież z natury niebezpiecznych przedmiotów z ich magazynu, z osoby lub zdobycie ich w inny nielegalny sposób."

/datum/crime/capital/sabotage
	name = "Sabotaż ciężki"
	icon = "bomb"
	tooltip = "Zniszczenie lub modyfikacja mienia lub sprzętu stacji, bez których stacja może się zawalić lub w inny sposób przestać nadawać się do zamieszkania."

/datum/crime/capital/espionage
	name = "Szpiegostwo"
	icon = "user-secret"
	tooltip = "Świadome zdradzenie krytycznych informacji wrogom stacji."

/datum/crime/capital/enemy
	name = "Wróg korporacji"
	icon = "user-alt-slash"
	tooltip = "Członkostwo w którejkolwiek z poniższych organizacji: wrogie grupy abordażowe, czarodzieje, roje zmiennokształtnych, kulty."

/datum/crime/capital/contraband
	name = "Posiadanie tajemnic korporacyjnych"
	icon = "file-invoice"
	tooltip = "Posiadanie tajnej dokumentacji lub odpornych na manipulację urządzeń do przechowywania danych o dużej gęstości (czarnych skrzynek) dowolnej organizacji bez zgody Nanotrasen."

/datum/crime/capital/subversion
	name = "Podważanie łańcucha dowodzenia"
	icon = "link"
	tooltip = "Zakłócanie łańcucha dowodzenia przez zabójstwo oficera dowodzącego lub nielegalne ogłoszenie się oficerem dowodzącym."

/datum/crime/capital/biological
	name = "Terroryzm biologiczny"
	icon = "biohazard"
	tooltip = "Świadome uwolnienie, spowodowanie lub doprowadzenie w inny sposób do skażenia stacji chorobą, rośliną lub inną formą biologiczną, która może rozprzestrzeniać się bez kontroli i/lub powodować poważne obrażenia fizyczne."

// AQ EDIT - PRESET_* są #undef na końcu genpop.dm (używa ich calculate_sentence)
