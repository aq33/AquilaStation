// AQUILA - drinki z tg (tgstation/tgstation, code/modules/reagents/chemistry/reagents/drinks i recipes/drinks).
// 82 drinki i 15 bazowych alkoholi i napojów (w dyspenserach baru). Efekty drinków: tg_drink_effects.dm.
// Sprite'y szklanek: tg (icons/obj/drinks/*.dmi), CC BY-SA 3.0, w aquila/icons/obj/drinks/tg_drinks.dmi.

/datum/reagent/consumable/ethanol/coconut_rum
	name = "Rum kokosowy"
	description = "Destylowana esencja plaży. Smakuje jak utlenione na blond włosy i krem z filtrem."
	color = "#e4f2f5"
	boozepwr = 21
	quality = DRINK_NICE
	taste_description = "rum kokosowy"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "ginvodkaglass"
	glass_name = "szklanka rumu kokosowego"
	glass_desc = "Weź głęboki oddech i odpręż się: masz wakacje, dopóki ta szklanka się nie opróżni."

/datum/reagent/consumable/ethanol/curacao
	name = "Curaçao"
	description = "Robiony z pomarańczy laraha, dla aromatycznego finiszu."
	color = "#1a5fa1"
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "niebieska pomarańcza"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "curacao"
	glass_name = "kieliszek curaçao"
	glass_desc = "Jest niebieski, niebieski jak w tej piosence z lat 90."

/datum/reagent/consumable/ethanol/beer/maltliquor
	name = "Mocne piwo"
	description = "Napój alkoholowy warzony od starożytności na Starej Ziemi. Ta odmiana jest mocniejsza niż zwykle, supertania i superokropna."
	boozepwr = 35
	taste_description = "słodkie piwo kukurydziane i życie na dzielni"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_name = "kufel mocnego piwa"
	glass_desc = "Lodowato zimny kufel mocnego piwa."

/datum/reagent/consumable/ethanol/navy_rum
	name = "Rum marynarski"
	description = "Rum, jaki piją najlepsi marynarze."
	color = "#d8e8f0"
	boozepwr = 90
	quality = DRINK_NICE
	taste_description = "życie na falach"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "ginvodkaglass"
	glass_name = "szklanka rumu marynarskiego"
	glass_desc = "Podwójna porcja rumu dla załogi i Boże, chroń Króla."

/datum/reagent/consumable/ethanol/rice_beer
	name = "Piwo ryżowe"
	description = "Lekki ryżowy lager popularny na Marsie. Według ustawy Reinheitsgebot z 1516 roku uchodzi za zbrodnię z nienawiści wobec Bawarczyków."
	color = "#664300"
	boozepwr = 5
	quality = DRINK_NICE
	taste_description = "łagodny gazowany słód"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "rice_beer"
	glass_name = "kufel piwa ryżowego"
	glass_desc = "Kufel wybornego, lekkiego piwa ryżowego. Najlepsze na zimno."

/datum/reagent/consumable/ethanol/yuyake
	name = "Yūyake"
	description = "Słodki likier melonowy z Japonii. Większość uważa go za relikt lat 80., ale ma niszowe zastosowanie w koktajlach, po części dzięki jaskrawoczerwonej barwie."
	color = "#F54040"
	boozepwr = 40
	quality = DRINK_NICE
	taste_description = "słodki melon"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_name = "kieliszek yūyake"
	glass_desc = "To przesłodzona esencja lat 70. w szklance... tych tysiąc dziewięćset siedemdziesiątych, rzecz jasna!"

/datum/reagent/consumable/mintextract
	name = "Ekstrakt miętowy"
	description = "Przydaje się do radzenia sobie z niepożądanymi klientami."
	color = "#CF3600"
	taste_description = "mięta"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/melon_soda
	name = "Oranżada melonowa"
	description = "Neonowo zielony zastrzyk nostalgii."
	color = "#6FEB48"
	taste_description = "gazowany melon"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "melon_soda"
	glass_name = "szklanka oranżady melonowej"
	glass_desc = "Uwielbiana przez japońskie dzieci i trzydziestoletnich fanów Japonii."

/datum/reagent/consumable/sol_dry
	name = "Sol Dry"
	description = "Kojący, łagodny napój z imbiru."
	color = "#f7d26a"
	quality = DRINK_NICE
	taste_description = "słodka imbirowa ostrość"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "soldry"
	glass_name = "Sol Dry"
	glass_desc = "Kojący, łagodny napój z imbiru."

/datum/reagent/consumable/ethanol/bitters
	name = "Bitter Andromeda"
	description = "Najlepszy przyjaciel barmana, często dodawany, by nadać drinkowi delikatnej korzenności. Produkowany w Nowym Trynidadzie, teraz i na zawsze."
	color = "#1c0000"
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "korzenny alkohol"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "bitters"
	glass_name = "kieliszek bittera"
	glass_desc = "Zwykle miesza się to z czymś, ale rób, jak uważasz."

/datum/reagent/consumable/ethanol/amaretto
	name = "Amaretto"
	description = "Łagodny trunek o słodkim aromacie."
	color = "#E17600"
	boozepwr = 25
	taste_description = "owocowo-orzechowa słodycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "amarettoglass"
	glass_name = "kieliszek amaretto"
	glass_desc = "Słodko i syropowato wyglądający trunek."

/datum/reagent/consumable/ethanol/maraschino
	name = "Likier maraschino"
	description = "Klasyczny słodki likier z owoców, liści, a nawet gałązek wiśni maraski. Co zaskakujące, wcale nie smakuje szczególnie wiśniowo."
	color = "#DDDDDD"
	boozepwr = 50
	taste_description = "orzechowa słodycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "maraschino"
	glass_name = "kieliszek likieru maraschino"
	glass_desc = "Jeśli mieszanie cukru z alkoholem naprawdę sprzyja kacowi, picie tego bez dodatków to niezły sposób, żeby się przekonać."

/datum/reagent/consumable/ethanol/aperitivo
	name = "Likier aperitivo"
	description = "Agresywnie słodko-gorzki likier aromatyzowany korą chinowca i innymi ziołami. Idealny na pobudzenie apetytu albo walkę z malarią."
	color = "#bf1038"
	boozepwr = 40
	taste_description = "intensywna cytrusowa gorycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "aperitivo"
	glass_name = "kieliszek likieru aperitivo"
	glass_desc = "Jaskrawoczerwona barwa pobudza ci apetyt, ale chyba lepiej najpierw z czymś to wymieszać."

/datum/reagent/consumable/ethanol/herbal_liqueur
	name = "Likier ziołowy"
	description = "Likier z mnóstwa ziół i przypraw, które przechodzą do spirytusu przez destylację i macerację. Jest ich tak wiele, że rozpoznanie ich po zapachu i smaku wydaje się niemal niemożliwe..."
	color = "#95be7d"
	boozepwr = 75
	quality = DRINK_NICE
	taste_description = "zagadkowa ziołowość"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "herbal_liqueur"
	glass_name = "kieliszek likieru ziołowego"
	glass_desc = "Zastanawiasz się, ile ziół trzeba było na ten jeden kieliszek."

/datum/reagent/consumable/ethanol/shochu
	name = "Shochu"
	description = "Znany też jako soju albo baijiu. Robi się go ze sfermentowanego ryżu, podobnie jak sake, ale zwykle jest mocniejszy, przez co bliżej mu do prawdziwego spirytusu."
	color = "#DDDDDD"
	boozepwr = 45
	quality = DRINK_NICE
	taste_description = "mocne wino ryżowe"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "ginvodkaglass"
	glass_name = "kieliszek shochu"
	glass_desc = "Kieliszek mocnego wina ryżowego."

/datum/reagent/consumable/wellcheers
	name = "Wellcheers"
	description = "Dziwny fioletowy napój pachnący morską wodą. Gdzieś w oddali słychać mewy."
	color = "#762399"
	taste_description = "winogrona i świeże otwarte morze"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING

/datum/reagent/consumable/ethanol/hiveminderaser
	name = "Kasownik Roju"
	description = "Naczynie czystego smaku."
	color = "#FF80FC"
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "więzi psychiczne"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "hiveminderaser"
	glass_name = "Kasownik Roju"
	glass_desc = "Na wypadek, gdy nawet implant ochrony umysłu cię nie uratuje."

/datum/reagent/consumable/ethanol/moscow_mule
	name = "Moscow Mule"
	description = "Chłodny drink, który przypomina ci o Wraku."
	color = "#EEF1AA"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "orzeźwiająca ostrość"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "moscow_mule"
	glass_name = "Moscow Mule"
	glass_desc = "Chłodny drink, który przypomina ci o Wraku."

/datum/reagent/consumable/ethanol/pina_olivada
	name = "Piña Olivada"
	description = "Dziwnie pomyślana mikstura oliwy z oliwek i soku ananasowego."
	color = "#493c00"
	boozepwr = 20
	quality = DRINK_NICE
	taste_description = "okropna emulsja ananasa i oliwy z oliwek"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "pina_olivada"
	glass_name = "Piña Olivada"
	glass_desc = "Równowaga owocowego ananasa i gęstej, treściwej oliwy. Przed wypiciem dobrze zamieszać."

/datum/reagent/consumable/ethanol/godfather
	name = "Ojciec Chrzestny"
	description = "Szorstki koktajl z nielegalnymi koneksjami."
	color = "#E68F00"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "rozkosznie złagodzony cios"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "godfather"
	glass_name = "Ojciec Chrzestny"
	glass_desc = "Klasyka ze starych Włoch, ceniona przez gangsterów. Módl się, żeby skórka pomarańczy nie wpadła ci do ust."

/datum/reagent/consumable/ethanol/godmother
	name = "Matka Chrzestna"
	description = "Wariacja na temat klasyka, bardziej lubiana przez dojrzałe kobiety."
	color = "#E68F00"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "słodycz z cytrusowym akcentem"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "godmother"
	glass_name = "Matka Chrzestna"
	glass_desc = "Uroczy, świeżo pachnący koktajl, prawdziwa sycylijska rozkosz."

/datum/reagent/consumable/ethanol/amaretto_alexander
	name = "Amaretto Aleksander"
	description = "Słabsza wersja Aleksandra: czego brakuje jej w mocy, nadrabia smakiem."
	color = "#DBD5AE"
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "słodkie, kremowe kakao"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "alexanderam"
	glass_name = "Amaretto Aleksander"
	glass_desc = "Kremowa, dekadencka rozkosz, która naprawdę jest tak łagodna, na jaką wygląda."

/datum/reagent/consumable/ethanol/ginger_amaretto
	name = "Amaretto z imbirem"
	description = "Rozkosznie prosty koktajl, który cieszy zmysły."
	color = "#EFB42A"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "słodycz, a po niej delikatna kwaskowość i ciepło"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "gingeramaretto"
	glass_name = "Amaretto z imbirem"
	glass_desc = "Gałązka rozmarynu dodaje drinkowi przyjemnego aromatu, a wcale nie jest tylko na pokaz!"

/datum/reagent/consumable/ethanol/helianthus
	name = "Helianthus"
	description = "Ciemna, a zarazem promienna mieszanka absyntu i halucynogenów. Wybór wszystkich prawdziwych artystów."
	color = "#fba914"
	boozepwr = 75
	quality = DRINK_VERYGOOD
	taste_description = "złote wspomnienia"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "helianthus"
	glass_name = "Helianthus"
	glass_desc = "Kolejny powód, żeby obciąć sobie ucho..."

/datum/reagent/consumable/ethanol/gin_garden
	name = "Ginowy Ogród"
	description = "Świetny, chłodzący drink alkoholowy o niezbyt zwyczajnym smaku."
	color = "#6cd87a"
	boozepwr = 20
	quality = DRINK_VERYGOOD
	taste_description = "lekki gin ze słodkim imbirem i ogórkiem"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "gin_garden"
	glass_name = "ginowy ogród"
	glass_desc = "Hej, ktoś zapomniał o ziołach i... ogórku w moim koktajlu!"

/datum/reagent/consumable/ethanol/yuyakita
	name = "Yūyakita"
	description = "Piekło rozpętane na świecie przez bezimiennego klienta."
	color = "#e43414"
	boozepwr = 40
	quality = DRINK_NICE
	taste_description = "śmierć"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "yuyakita"
	glass_name = "Yūyakita"
	glass_desc = "I widziałem, a oto koń płowy, a tego, który siedział na nim, imię było Śmierć, a piekło szło za nim."

/datum/reagent/consumable/ethanol/saibasan
	name = "Saibāsan"
	description = "Drink sławiący nieprzerwaną działalność Cybersun."
	color = "#f25100"
	boozepwr = 20
	quality = DRINK_FANTASTIC
	taste_description = "zdrada"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "saibasan"
	glass_name = "Saibāsan"
	glass_desc = "Drink stworzony na cześć 600 lat nieprzerwanej działalności Cybersun Industries. Na stacjach Nanotrasen oficjalnie powinno się go nazywać „Hong Kong Cooler”, ale ta nazwa jest beznadziejna."

/datum/reagent/consumable/ethanol/banzai_ti
	name = "Banzai-Tī"
	description = "Wariacja na temat Long Island Iced Tea z yūyake, które daje odmienny, trudny do uchwycenia smak."
	color = "#fd3b00"
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "azjatycka wariacja na temat barku z alkoholami"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "banzai_ti"
	glass_name = "Banzai-Tī"
	glass_desc = "Drink na dziesięć tysięcy lat, więc lepiej sączyć powoli."

/datum/reagent/consumable/ethanol/sanraizusoda
	name = "Sanraizusōda"
	description = "To melonowa oranżada śmietankowa, tylko z alkoholem. Czego tu nie kochać? No... może kaca."
	color = "#f37d7b"
	boozepwr = 6
	quality = DRINK_GOOD
	taste_description = "kremowa oranżada melonowa"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "sanraizusoda"
	glass_name = "Sanraizusōda"
	glass_desc = "Popularny japoński deser dla dzieci, który dzięki procentom stał się dorosły. Kanpai!"

/datum/reagent/consumable/ethanol/kumicho
	name = "Kumichō"
	description = "Nowe spojrzenie na klasyczny koktajl: Kumichō bierze przepis na Ojca Chrzestnego i dodaje shochu dla azjatyckiego akcentu."
	color = "#b87456"
	boozepwr = 62
	quality = DRINK_VERYGOOD
	taste_description = "ryż i żyto"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "kumicho"
	glass_name = "Kumichō"
	glass_desc = "Podobnie jak amerykański Ojciec Chrzestny, Kumichō jest wyrafinowany, mocny i niemal na pewno powiązany z nielegalną działalnością."

/datum/reagent/consumable/ethanol/red_planet
	name = "Czerwona Planeta"
	description = "Stworzona dla uczczenia Koncesji Marsjańskiej, Czerwona Planeta bazuje na klasycznym El Presidente i jest równie patriotyczna, co jaskrawo karmazynowa."
	color = "#ac4948"
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "duch wolności"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "red_planet"
	glass_name = "Czerwona Planeta"
	glass_desc = "Patriotyczny drink z Marsa, pity zwykle 15 września: w dniu ogłoszenia pokoju po marsjańskim powstaniu, gdy Koncesja Marsjańska zapewniła Marsowi należytą reprezentację w Federacji Terrańskiej."

/datum/reagent/consumable/ethanol/amaterasu
	name = "Amaterasu"
	description = "Nazwany na cześć Amaterasu, shintoistycznej bogini słońca, ten koktajl uosabia promienność. A przynajmniej coś w tym stylu."
	color = "#e43414"
	boozepwr = 54
	quality = DRINK_VERYGOOD
	taste_description = "słodki nektar bogów"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "amaterasu"
	glass_name = "Amaterasu"
	glass_desc = "I tak Amaterasu wyszła z Niebiańskiej Skalnej Groty, a na świat powróciło światło."

/datum/reagent/consumable/ethanol/nekomimosa
	name = "Nekomimosa"
	description = "Przesłodzony koktajl z likieru melonowego, soku z melona i szampana (w którym, niestety, nie ma melona)."
	color = "#FF0C8D"
	boozepwr = 17
	quality = DRINK_GOOD
	taste_description = "MELON"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "nekomimosa"
	glass_name = "Nekomimosa"
	glass_desc = "Syropowaty bałagan, a nie koktajl, poświęcony felinidzkiej gwieździe popu, która kilka lat temu podbiła Marsa."

/datum/reagent/consumable/ethanol/sentai_quencha
	name = "Sentai Quencha"
	description = "Inspirowana znanym w całej galaktyce „Kyūkyoku no Ninja Pawā Sentai” Sentai Quencha jest ulubieńcem konwentów anime i barów dla weebów."
	color = "#00ffa6"
	boozepwr = 28
	quality = DRINK_GOOD
	taste_description = "ostateczna moc ninja"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "sentai_quencha"
	glass_name = "Sentai Quencha"
	glass_desc = "Smakuje jak ostateczna moc ninja. I melon. I cytrusy. I parę innych rzeczy."

/datum/reagent/consumable/ethanol/bosozoku
	name = "Bōsōzoku"
	description = "Prosty letni drink z Marsa: piwo ryżowe z lemoniadą w proporcji 1:1."
	color = "#d7d84f"
	boozepwr = 6
	quality = DRINK_GOOD
	taste_description = "słodko-gorzka cytryna"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "bosozoku"
	glass_name = "Bōsōzoku"
	glass_desc = "Orzeźwiający letni drink pity na Marsie i nie tylko. Wszelkie podobieństwo do shandy czy radlera jest niezamierzone."

/datum/reagent/consumable/ethanol/ersatzche
	name = "Ersatzche"
	description = "Słodki, gorzki, pikantny. Świetne połączenie."
	color = "#bc6a2b"
	boozepwr = 6
	quality = DRINK_VERYGOOD
	taste_description = "pikantne piwo ananasowe"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "ersatzche"
	glass_name = "Ersatzche"
	glass_desc = "Ciekawy drink wymyślony w Blue Room Bar and Grill w Nowej Osace. Smaczna wersja meksykańskiego tepache, na bazie piwa."

/datum/reagent/consumable/ethanol/kings_ransom
	name = "Królewski Okup"
	description = "Mocny, gorzki drink o dziwnej nazwie i jeszcze dziwniejszym przepisie."
	color = "#bd2e20"
	boozepwr = 26
	quality = DRINK_VERYGOOD
	taste_description = "gorzka malina"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "kings_ransom"
	glass_name = "Królewski Okup"
	glass_desc = "Dziwny drink, który łączy wiele pozornie sprzecznych smaków w jeden harmonijny."

/datum/reagent/consumable/ethanol/maui_sunrise
	name = "Maui Sunrise"
	description = "Za czerwoną fasadą tego drinka czai się ostry, złożony smak."
	color = "#f1922b"
	boozepwr = 15
	quality = DRINK_VERYGOOD
	taste_description = "wschód słońca nad Pacyfikiem"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "maui_sunrise"
	glass_name = "Maui Sunrise"
	glass_desc = "Weź łyk i przenieś się do Stanu Aloha. Metaforycznie, rzecz jasna."

/datum/reagent/consumable/ethanol/imperial_mai_tai
	name = "Imperialny Mai Tai"
	description = "Gdy brakuje syropu orgeat, rób jak kosmonauci: radź sobie tym, co masz."
	color = "#cf7d61"
	boozepwr = 52
	quality = DRINK_VERYGOOD
	taste_description = "korzenny orzechowy rum"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "imperial_mai_tai"
	glass_name = "Imperialny Mai Tai"
	glass_desc = "No bo kto dziś w ogóle wydaje kasę na orgeat? Orzech korta to teraz hit, skarbie."

/datum/reagent/consumable/ethanol/konococo_rumtini
	name = "Konococo Rumtini"
	description = "Rum kokosowy, likier kawowy i espresso. Dziwne połączenie, bez dwóch zdań, ale mile widziane."
	color = "#421711"
	boozepwr = 20
	quality = DRINK_VERYGOOD
	taste_description = "kokosowa kawa"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "konococo_rumtini"
	glass_name = "Konococo Rumtini"
	glass_desc = "W Małych Hawajach uchodzi za całkiem przyzwoity drink do śniadania."

/datum/reagent/consumable/ethanol/blue_hawaiian
	name = "Blue Hawaiian"
	description = "Słodki, ostry i kokosowy."
	color = "#295875"
	boozepwr = 30
	quality = DRINK_VERYGOOD
	taste_description = "stan Aloha"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "blue_hawaiian"
	glass_name = "Blue Hawaiian"
	glass_desc = "Tropikalne wakacje w szklance."

/datum/reagent/consumable/ethanol/star
	name = "Gwiazda"
	description = "Mieszanka wódki jabłkowej i wermutu, podkreślona bitterem."
	color = "#e5a654"
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "winne jabłka"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "star"
	glass_name = "Gwiazda"
	glass_desc = "Ten koktajl bierze rustykalną wódkę jabłkową i uszlachetnia ją słodkim wermutem. Równie swojski w sadzie, co we dworze."

/datum/reagent/consumable/ethanol/old_fashioned
	name = "Old Fashioned"
	description = "Według niektórych pierwszy koktajl: mocny trunek doprawiony cukrem i bitterem, dziś najczęściej whisky."
	color = "#b4a287"
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "zaokrąglona whisky"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "old_fashioned"
	glass_name = "Old Fashioned"
	glass_desc = "Oryginalny Koktajl... z paroma dodanymi anachronizmami."

/datum/reagent/consumable/ethanol/sazerac
	name = "Sazerac"
	description = "Whisky z aromatem absyntu i kreolskiego bittera."
	color = "#f43f69"
	boozepwr = 65
	quality = DRINK_GOOD
	taste_description = "kwiecista whisky o zapachu anyżu"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "sazerac"
	glass_name = "Sazerac"
	glass_desc = "Klasyczny koktajl z Nowego Orleanu. Kreolski bitter i płukanie szklanki absyntem nadają mu rozkoszny anyżowy zapach."

/datum/reagent/consumable/ethanol/french_75
	name = "French 75"
	description = "Wyrafinowany koktajl: szampan wzmocniony ginem, doprawiony sokiem z cytryny i cukrem."
	color = "#ffffc1"
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "chwała i artyleria"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "french_75"
	glass_name = "French 75"
	glass_desc = "Nazwany na cześć działa polowego używanego przez Francuzów na początku XX wieku. Ten elegancki koktajl z szampanem wielokrotnie się zmieniał na przestrzeni dziejów, ale jego zdolność przywoływania zwycięstwa pozostała niezmienna."

/datum/reagent/consumable/ethanol/sangria
	name = "Sangria"
	description = "Krwistoczerwony poncz winny, wzmocniony mocniejszym alkoholem i osłodzony taką ilością pokrojonych owoców, jaką tylko da się zdobyć."
	color = "#c4383b"
	boozepwr = 20
	quality = DRINK_GOOD
	taste_description = "orzeźwiające owocowe wino"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "sangria"
	glass_name = "Sangria"
	glass_desc = "Poncz winny na upalne letnie dni. Przy jego przyrządzaniu, miejmy nadzieję, nikt nie upuszcza krwi."

/datum/reagent/consumable/ethanol/suffering_bastard
	name = "Cierpiący Drań"
	description = "Lek na kaca w stylu tiki, z piwa imbirowego, mocnych trunków i bittera."
	color = "#e8ca78"
	boozepwr = 20
	quality = DRINK_VERYGOOD
	taste_description = "imbirowa rekonwalescencja"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "suffering_bastard"
	glass_name = "Cierpiący Drań"
	glass_desc = "Pierwotnie lek na kaca dla żołnierzy z dala od domu, później przerobiony w estetyce tiki. Ten drink ma niesamowitą zdolność leczenia bólu głowy i uspokajania żołądka."

/datum/reagent/consumable/ethanol/hot_toddy
	name = "Hot Toddy"
	description = "Rozgrzana mieszanka mocnych trunków, cukru i przypraw. Sam pomysł jest prastary, ale ta wersja z koniakiem i rafinowanym cukrem jest nieco nowsza."
	color = "#f2d2b4"
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "ciepło przytulnego kominka"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "hot_toddy"
	glass_name = "Hot Toddy"
	glass_desc = "Choć na chwilę zabiera cię z mrozu tej podzerowej dziury, w której akurat siedzisz."

/datum/reagent/consumable/ethanol/tizirian_sour
	name = "Tizirski Sour"
	description = "Wariacja na temat Trinidad Sour, z nektarem korta zamiast syropu orgeat. Mimo nazwy wymyślił go marsjański barman."
	color = "#9b4b3a"
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "osłodzona i doprawiona gorycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "tizirian_sour"
	glass_name = "Tizirski Sour"
	glass_desc = "Od Trynidadu przez Tobago po Tizirię: rzadko trafia się koktajl, w którym bitter jest alkoholem bazowym."

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	description = "Pod pewnymi względami ostateczny tropikalny koktajl: niewiele drinków z rumem nie wywodzi się w jakiś sposób od tego klasyka."
	color = "#b6d3a6"
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "rześka limonka"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "daiquiri"
	glass_name = "Daiquiri"
	glass_desc = "Czyste, proste, naturalne. Kubański klasyk."

/datum/reagent/consumable/ethanol/blue_blazer
	name = "Blue Blazer"
	description = "Popisowy drink legendarnego barmana z XIX wieku. Choć zapamiętano go jako innowatora sztuki barmańskiej, ten drink to w gruncie rzeczy po prostu podgrzana i osłodzona whisky."
	color = "#b5949b"
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "przypalona słodka whisky"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "blue_blazer"
	glass_name = "Blue Blazer"
	glass_desc = "Widowiskowy drink stworzony przez jednego z ojców sztuki barmańskiej, przyrządzany przez przelewanie płonącej whisky między dwiema szklankami. Nie podawać, gdy na zewnątrz jest powyżej pięćdziesięciu stopni Fahrenheita, choć na stacji kosmicznej to raczej nie problem."

/datum/reagent/consumable/ethanol/bartenders_handshake
	name = "Barmański Uścisk Dłoni"
	description = "Tradycja o dość niepewnym rodowodzie, być może związana z mało znaną akcją marketingową opartą na monetach okolicznościowych. Tym drinkiem barmani witają się i sprawdzają nawzajem, bo docenić go może tylko inny barman. Wersji jest prawie tyle, ile barów, a ta sprawdza podniebienie, łącząc dwa najbardziej gorzkie składniki, jakie zwykle znajdziesz w barze."
	color = "#270101"
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "pretensjonalna gorycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "bartenders_handshake"
	glass_name = "Barmański Uścisk Dłoni"
	glass_desc = "Doprawdy, drink, który może pokochać tylko jego matka (albo ojciec)."

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	description = "Znacznie bardziej wystrojony przodek Sidecara. Ten obficie przybrany koktajl jest dziadkiem wielu podstawowych drinków podawanych dziś."
	color = "#f8c51c"
	boozepwr = 30
	quality = DRINK_VERYGOOD
	taste_description = "pomarańczowa słodycz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "brandy_crusta"
	glass_name = "Brandy Crusta"
	glass_desc = "Oblepiony brzeg szklanki przypomina przesłodzony śnieg... albo po prostu słodką margaritę."

/datum/reagent/consumable/ethanol/casino
	name = "Kasyno"
	description = "Klasyk z przewagą ginu. Jałowiec złagodzony odrobiną cytrusów i osłodzony likierem."
	color = "#fdee65"
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "słodki jałowiec"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "casino"
	glass_name = "Kasyno"
	glass_desc = "Na chwile, gdy chcesz poczuć się z klasą, przepuszczając pensję w automatach."

/datum/reagent/consumable/ethanol/garibaldi
	name = "Garibaldi"
	description = "Nazwany na cześć dziewiętnastowiecznego włoskiego generała. Czerwono-pomarańczowa barwa tego drinka naśladuje koszule tych, którzy szli za nim do bitew na całym świecie."
	color = "#f77e2e"
	boozepwr = 15
	quality = DRINK_GOOD
	taste_description = "gorzkie pomarańcze"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "garibaldi"
	glass_name = "Garibaldi"
	glass_desc = "Drink dla zjednoczycieli i rewolucjonistów."

/datum/reagent/consumable/ethanol/improved_whiskey
	name = "Ulepszony Koktajl z Whisky"
	description = "Klasyczny koktajl z whisky ulepszony dodatkiem absyntu i maraschino, z cytrynową skórką zamiast zwykłej pomarańczowej."
	color = "#b8a385"
	boozepwr = 65
	quality = DRINK_VERYGOOD
	taste_description = "orzechowa whisky o zapachu anyżu"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "improved_whiskey"
	glass_name = "Ulepszony Koktajl z Whisky"
	glass_desc = "Potomek koktajli w starym stylu, który zarazem wyprzedza Old Fashioned o mniej więcej dekadę. Znawca historii koktajli rozwiąże ten paradoks."

/datum/reagent/consumable/ethanol/jungle_bird
	name = "Jungle Bird"
	description = "Ten późny koktajl tiki wykorzystuje znakomite połączenie gorzkiego likieru i soku ananasowego, dając niezwykle zrównoważony smak."
	color = "#da8370"
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "ananas i chinina"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "jungle_bird"
	glass_name = "Jungle Bird"
	glass_desc = "SKRZEK! Żadnych pijaków w maszynowni! SKRZEK!"

/datum/reagent/consumable/ethanol/last_word
	name = "Ostatnie Słowo"
	description = "Choć wymyślony na przełomie XIX i XX wieku, drink popadł w zapomnienie aż do koktajlowego renesansu na początku XXI wieku, kiedy to zawładnął barami i zainspirował niezliczone wariacje."
	color = "#dddfcaff"
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "ziołowa ostateczność"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "last_word"
	glass_name = "Ostatnie Słowo"
	glass_desc = "Mówi samo za siebie."

/datum/reagent/consumable/ethanol/mary_pickford
	name = "Mary Pickford"
	description = "Nazwany na cześć gwiazdy filmowej z początku XX wieku, ten koktajl podaje połączenie rumu i ananasa w formie bardziej eleganckiej i wytwornej, niż można by się spodziewać."
	color = "#f7b7a7ff"
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "elegancki ananas"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "mary_pickford"
	glass_name = "Mary Pickford"
	glass_desc = "Może sprawić, że poczujesz się odrobinę zalotnie."

/datum/reagent/consumable/ethanol/negroni
	name = "Negroni"
	description = "Kultowy włoski aperitif, który swoją prostą intensywnością zasłużył na miano być może najlepszego gorzkiego koktajlu. Podobno nazwano go na cześć włoskiego hrabiego, który chciał mocniejszej wersji spritza i poprosił barmana, by zamienił wodę sodową na gin."
	color = "#cf0e00ff"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "słodko-gorzki wermut"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "negroni"
	glass_name = "Negroni"
	glass_desc = "Chwała karmazynowemu hrabiemu."

/datum/reagent/consumable/ethanol/nuclear_daiquiri
	name = "Nuklearne Daiquiri"
	description = "Wysokoprocentowy, wyrazisty rum z alembiku i likier ziołowy biorą prostą elegancję kubańskiego daiquiri i stawiają ją na głowie."
	color = "#22cc22"
	boozepwr = 65
	quality = DRINK_GOOD
	taste_description = "rumowe hogo i zioła"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "nuclear_daiquiri"
	glass_name = "Nuklearne Daiquiri"
	glass_desc = "Bomba funku w szklance."

/datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo
	name = "Termonuklearne Daiquiri"
	description = "Drink dla tych, którzy lubią w życiu ostrzejsze rzeczy, jak rumy bogate w estry i kobalt-60."
	color = "#00dd00"
	boozepwr = 80
	quality = DRINK_FANTASTIC
	taste_description = "około 3,6 rentgena"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "nuclear_daiquiri_thermo"
	glass_name = "Termonuklearne Daiquiri"
	glass_desc = "Patrząc na ten drink, zdaje ci się, że słyszysz nieregularne tykanie."

/datum/reagent/consumable/ethanol/poets_dream
	name = "Sen Poety"
	description = "Ten koktajl bierze klasyczną bazę martini i przerabia ją na rozkosznie słodką i ziołową modłę. Regulamin Nanotrasen zabrania pić go tuż przed snem, bo grozi to „onirycznym wtargnięciem”, cokolwiek to znaczy."
	color = "#d4b14f"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "miodowy ziołowy gin"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "poets_dream"
	glass_name = "Sen Poety"
	glass_desc = "„Ci, którzy mieszkają za zasłoną, mają mało czasu na poezję”, jak mówią, „ale za to mnóstwo czasu na poetów”. A może było „świetnie się bawią z poetami”?"

/datum/reagent/consumable/ethanol/pousse_cafe
	name = "Pousse Cafe"
	description = "Przepiękny koktajl z ostrożnie i drobiazgowo ułożonych warstw różnych likierów. Strasznie męczący w przygotowaniu."
	color = "#93cf33"
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "kaskada różnych likierów"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "pousse_cafe"
	glass_name = "Pousse Cafe"
	glass_desc = "Jeśli barman poda ci to bez zamówienia, pewnie chce ci zaimponować. Jeśli to twoje zamówienie, pewnie chce nabić twoją głowę na pal."

/datum/reagent/consumable/ethanol/spritz
	name = "Spritz"
	description = "Ten słodko-gorzki, orzeźwiający aperitif przywodzi na myśl piękne letnie zachody słońca w Wenecji."
	color = "#ee714b"
	boozepwr = 20
	quality = DRINK_GOOD
	taste_description = "słodko-gorzkie orzeźwienie"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "spritz"
	glass_name = "Spritz"
	glass_desc = "Chyba najlepszy sposób, żeby zacząć wieczór na mieście."

/datum/reagent/consumable/ethanol/vieux_carre
	name = "Vieux Carré"
	description = "Jeden z najlepszych spośród wielu świetnych koktajli z Nowego Orleanu. Oddaje hołd Dzielnicy Francuskiej tego miasta zarówno nazwą, jak i smakiem."
	color = "#b43110"
	boozepwr = 60
	quality = DRINK_VERYGOOD
	taste_description = "kreolska gościnność"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "vieux_carre"
	glass_name = "Vieux Carré"
	glass_desc = "Laissez les bons temps rouler!"

/datum/reagent/consumable/ethanol/stone_cold_stout
	name = "Kamiennie Zimny Stout"
	description = "Kamiennie zimny drink, wyzwanie nawet dla zaprawionych w piciu. Jeśli to przeżyjesz, poradzisz sobie ze wszystkim."
	color = "#9DDCFA"
	boozepwr = 100
	taste_description = "gorzkie dno"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "stone_cold_stout"
	glass_name = "Kamiennie Zimny Stout"
	glass_desc = "Kamiennie zimny drink, wyzwanie nawet dla zaprawionych w piciu. Jeśli to przeżyjesz, poradzisz sobie ze wszystkim."

/datum/reagent/consumable/ethanol/footsoldiers_razor
	name = "Brzytwa Piechura"
	description = "Drink armii wyrżniętej do ostatniego człowieka, pity rankiem przed bitwą. „Teraz kropla. Wkrótce potok”."
	color = "#563517"
	boozepwr = 60
	quality = DRINK_FANTASTIC
	taste_description = "gorycz doprawiona krwią"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "footsoldiers_razor"
	glass_name = "Brzytwa Piechura"
	glass_desc = "Parabellum o świcie."

/datum/reagent/consumable/ethanol/farstar_amrita
	name = "Amrita Dalekiej Gwiazdy"
	description = "Wino do zupełnie innego rodzaju komunii."
	color = "#76276b"
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "coś innego, co smakuje razem z tobą"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "farstar_amrita"
	glass_name = "Amrita Dalekiej Gwiazdy"
	glass_desc = "Każdy kosmonauta wie, że jeśli zbyt długo patrzysz w otchłań, coś może spojrzeć na ciebie. Mniej osób wie, że otchłań zawsze przyjmie drinka."

/datum/reagent/consumable/ethanol/lunacy
	name = "Obłęd"
	description = "Wiele barów koktajlowych chce serwować klientom wakacje w szklance. Czemu nie wakacje od zdrowych zmysłów?"
	color = "#c4eef6"
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "coś <span class='hypnophrase'>zabawnego</span>"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "lunacy"
	glass_name = "Obłęd"
	glass_desc = "Zabij prawdę albo wypowiedz imię..."

/datum/reagent/consumable/ethanol/emptiest_glass
	name = "Najpustsza Szklanka"
	description = "Każdy przyziemny instrument, jaki masz pod ręką, jest zgodny: nic tu nie ma. Skąd oczekiwanie, że będzie inaczej?"
	color = "#000000"
	boozepwr = 1
	quality = DRINK_FANTASTIC
	taste_description = "nieobecność"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "emptiest_glass"
	glass_name = "Najpustsza Szklanka"
	glass_desc = "Wszystkie zmysły są zgodne: nic tu nie ma. A jednak jakaś cząstka twojej duszy błaga, żeby wziąć łyk..."

/datum/reagent/consumable/ethanol/admiralty
	name = "Admiralicja"
	description = "Wyrafinowany, gorzki drink z rumu marynarskiego, wermutu i fernetu."
	color = "#1F0001"
	boozepwr = 80
	quality = DRINK_VERYGOOD
	taste_description = "wyniosła arogancja"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "admiralty"
	glass_name = "Admiralicja"
	glass_desc = "Chwała Admirałowi, bo niesie dobre wieści, a do tego rum."

/datum/reagent/consumable/ethanol/dark_and_stormy
	name = "Dark and Stormy"
	description = "Klasyczny drink, który wkracza przy gromkich brawach."
	color = "#8c5046"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "imbir i rum"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "dark_and_stormy"
	glass_name = "Dark and Stormy"
	glass_desc = "Grzmoty i błyskawice w szklance. Strach się bać."

/datum/reagent/consumable/ethanol/long_haul
	name = "Długi Kurs"
	description = "Ulubiony drink pilotów frachtowców, pozbawionych skrupułów przemytników i pasterzy nerfów."
	color = "#003153"
	boozepwr = 20
	quality = DRINK_VERYGOOD
	taste_description = "towarzystwo"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "long_haul"
	glass_name = "Długi Kurs"
	glass_desc = "Idealny towarzysz na samotny, długi lot."

/datum/reagent/consumable/ethanol/long_john_silver
	name = "Long John Silver"
	description = "Long drink z rumu marynarskiego, bittera i lemoniady. Szczególnie popularny we Flocie Ćm, bo mało kosztuje w punktach przydziałowych, a smaku ma dużo."
	color = "#c4b35c"
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "rum i przyprawy"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "long_john_silver"
	glass_name = "Long John Silver"
	glass_desc = "Nazwany na cześć słynnego pirata, który mógł, ale nie musiał być postacią fikcyjną. Ale hej, po co prawda ma psuć dobrą opowieść?"

/datum/reagent/consumable/ethanol/tropical_storm
	name = "Burza Tropikalna"
	description = "Smak Karaibów w jednej szklance."
	color = "#00bfa3"
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "tropiki"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "tropical_storm"
	glass_name = "Burza Tropikalna"
	glass_desc = "Mniej niszczycielska niż prawdziwa."

/datum/reagent/consumable/vanillashake
	name = "Koktajl waniliowy"
	description = "Waniliowy koktajl mleczny. Podstawy wciąż są dobre."
	color = "#E9D2B2"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "słodka, kremowa wanilia"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "vanillashake"
	glass_name = "koktajl waniliowy"
	glass_desc = "Waniliowy koktajl mleczny."

/datum/reagent/consumable/caramelshake
	name = "Koktajl karmelowy"
	description = "Karmelowy koktajl mleczny. Zęby bolą od samego patrzenia."
	color = "#E17C00"
	quality = DRINK_GOOD
	nutriment_factor = 10
	taste_description = "słodki, gęsty, kremowy karmel"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "caramelshake"
	glass_name = "koktajl karmelowy"
	glass_desc = "Karmelowy koktajl mleczny."

/datum/reagent/consumable/choccyshake
	name = "Koktajl czekoladowy"
	description = "Mroźny czekoladowy koktajl mleczny."
	color = "#541B00"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "słodka, kremowa czekolada"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "choccyshake"
	glass_name = "koktajl czekoladowy"
	glass_desc = "Czekoladowy koktajl mleczny."

/datum/reagent/consumable/strawberryshake
	name = "Koktajl truskawkowy"
	description = "Truskawkowy koktajl mleczny."
	color = "#ff7b7b"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "słodkie truskawki z mlekiem"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "strawberryshake"
	glass_name = "koktajl truskawkowy"
	glass_desc = "Truskawkowy koktajl mleczny."

/datum/reagent/consumable/bananashake
	name = "Koktajl bananowy"
	description = "Bananowy koktajl mleczny. Piją go klauni na swoich honkodzinach."
	color = "#f2d554"
	quality = DRINK_VERYGOOD
	nutriment_factor = 8
	taste_description = "gęsty banan"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "bananashake"
	glass_name = "koktajl bananowy"
	glass_desc = "Bananowy koktajl mleczny."

/datum/reagent/consumable/toechtauese_syrup
	name = "Syrop töchtaüse"
	description = "Ostry, pikantny i gorzki syrop z jagód töchtaüse. Przydatny jako składnik potraw i koktajli."
	color = "#554862"
	nutriment_factor = 0
	taste_description = "cukier, przyprawy i nic a nic miłego"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_name = "kieliszek syropu töchtaüse"
	glass_desc = "Nie do picia bez dodatków."

/datum/reagent/consumable/roy_rogers
	name = "Roy Rogers"
	description = "Słodki gazowany napój."
	color = "#53090B"
	quality = DRINK_GOOD
	taste_description = "owocowa, przesłodzona cola"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "royrogers"
	glass_name = "Roy Rogers"
	glass_desc = "90% cukru w szklance."

/datum/reagent/consumable/shirley_temple
	name = "Shirley Temple"
	description = "Proszę bardzo, dziewczynko, teraz możesz pić jak dorośli."
	color = "#F43724"
	quality = DRINK_GOOD
	taste_description = "słodki syrop wiśniowy i imbirowa ostrość"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "shirleytemple"
	glass_name = "Shirley Temple"
	glass_desc = "Ginger ale z przetworzoną grenadyną."

/datum/reagent/consumable/agua_fresca
	name = "Agua Fresca"
	description = "Orzeźwiająca arbuzowa agua fresca. Idealna na dzień w holodeku."
	color = "#D25B66"
	quality = DRINK_VERYGOOD
	taste_description = "chłodny, orzeźwiający arbuz"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "aguafresca"
	glass_name = "Agua Fresca"
	glass_desc = "W 90% woda, ale wciąż orzeźwia."

/datum/reagent/consumable/cinderella
	name = "Cinderella"
	description = "Zdecydowanie owocowy koktajl alkoholowy do picia na imprezie ze znajomymi."
	color = "#FF6A50"
	quality = DRINK_VERYGOOD
	taste_description = "słodkie, cierpkie owoce"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "cinderella"
	glass_name = "Cinderella"
	glass_desc = "W tym czymś nie ma ani kropli alkoholu."

/datum/reagent/consumable/strawberry_banana
	name = "Smoothie truskawkowo-bananowe"
	description = "Klasyczne smoothie z truskawek i bananów."
	color = "#FF9999"
	nutriment_factor = 0
	taste_description = "truskawka i banan"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "strawberry_banana"
	glass_name = "smoothie truskawkowo-bananowe"
	glass_desc = "Klasyczny napój, przy którym zaprzyjaźniły się niezliczone dusze..."

/datum/reagent/consumable/berry_blast
	name = "Smoothie Jagodowa Bomba"
	description = "Klasyczne smoothie z mieszanki jagód."
	color = "#A76DC5"
	nutriment_factor = 0
	taste_description = "mieszanka jagód"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "berry_blast"
	glass_name = "smoothie Jagodowa Bomba"
	glass_desc = "Klasyczny napój, świeżo przyrządzony z ręcznie zbieranych jagód. A może i nie."

/datum/reagent/consumable/funky_monkey
	name = "Smoothie Odjechana Małpa"
	description = "Klasyczne smoothie z czekolady i bananów."
	color = COLOR_BROWNER_BROWN
	nutriment_factor = 0
	taste_description = "czekolada i banan"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "funky_monkey"
	glass_name = "smoothie Odjechana Małpa"
	glass_desc = "Klasyczny napój z czekolady i banana. Oficjalnie żadna małpa nie ucierpiała."

/datum/reagent/consumable/green_giant
	name = "Smoothie Zielony Olbrzym"
	description = "Zielone smoothie warzywne, zrobione bez warzyw."
	color = "#003300"
	nutriment_factor = 0
	taste_description = "zieleń, po prostu zieleń"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "green_giant"
	glass_name = "smoothie Zielony Olbrzym"
	glass_desc = "Klasyczny napój, jeśli lubisz wyciskaną trawę pszeniczną i nasiona chia."

/datum/reagent/consumable/melon_baller
	name = "Smoothie Melonowe Kulki"
	description = "Klasyczne smoothie z melonów."
	color = "#D22F55"
	nutriment_factor = 0
	taste_description = "świeży melon"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "melon_baller"
	glass_name = "smoothie Melonowe Kulki"
	glass_desc = "Cudownie świeże smoothie melonowe. Gwarantowana poprawa dnia."

/datum/reagent/consumable/vanilla_dream
	name = "Smoothie Waniliowy Sen"
	description = "Klasyczne smoothie z wanilii i świeżej śmietanki."
	color = "#FFF3DD"
	nutriment_factor = 0
	taste_description = "kremowa wanilia"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "vanilla_dream"
	glass_name = "smoothie Waniliowy Sen"
	glass_desc = "Klasyczny napój z wanilii i świeżej śmietanki."

/datum/reagent/consumable/cucumberlemonade
	name = "Lemoniada ogórkowa"
	description = "Sok z ogórka, cukier i woda sodowa. Czego więcej mi trzeba?"
	color = "#cbe248"
	quality = DRINK_GOOD
	taste_description = "cytrusowy napój gazowany z ogórkiem"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "cucumber_lemonade"
	glass_name = "lemoniada ogórkowa"
	glass_desc = "Lemoniada pachnąca ogórkiem. Na pewno się nie otruję."

/datum/reagent/consumable/mississippi_queen
	name = "Mississippi Queen"
	description = "Myślisz, że z ciebie gorący towar? To może drink zwycięstwa?"
	color = "#d4422f"
	taste_description = "szlam spływający ci do gardła"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "mississippiglass"
	glass_name = "Mississippi Queen"
	glass_desc = "Fryzury na czeskiego piłkarza i obcięte dżinsowe szorty nie są w zestawie."

/datum/reagent/consumable/t_letter
	name = "T"
	description = "Raczej spodziewasz się tego w zupie, ale tak też jest dobrze."
	color = "#583d09"
	taste_description = "jedna z 26 twoich ulubionych liter"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "tletter"
	glass_name = "szklanka T"
	glass_desc = "Dwudziesta."

/datum/reagent/consumable/ethanol/bitters_soda
	name = "Bitter z wodą sodową"
	description = "Prosty napój z wody sodowej aromatyzowanej bitterem. Koi rozstrojony żołądek."
	color = "#f1c1b3"
	boozepwr = 0
	quality = DRINK_NICE
	taste_description = "łagodne aromaty"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	glass_icon = 'aquila/icons/obj/drinks/tg_drinks.dmi'
	glass_icon_state = "bitters_soda"
	glass_name = "Bitter z wodą sodową"
	glass_desc = "Łagodniejsza i bardziej wytrawna alternatywa dla piwa imbirowego, gdy trzeba uspokoić burczący brzuszek. Technicznie zawiera alkohol, ale w tak niskim stężeniu, że dzieci i kobiety w ciąży mogą go pić bez obaw."

// ---------- Reakcje ----------

/datum/chemical_reaction/tg_wellcheers
	name = "Wellcheers"
	id = /datum/reagent/consumable/wellcheers
	results = list(/datum/reagent/consumable/wellcheers = 5)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/watermelonjuice = 1, /datum/reagent/consumable/sodawater = 1, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/ethanol/absinthe = 1)

/datum/chemical_reaction/tg_hiveminderaser
	name = "Kasownik Roju"
	id = /datum/reagent/consumable/ethanol/hiveminderaser
	results = list(/datum/reagent/consumable/ethanol/hiveminderaser = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/black_russian = 2, /datum/reagent/consumable/ethanol/thirteenloko = 1, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/tg_moscow_mule
	name = "Moscow Mule"
	id = /datum/reagent/consumable/ethanol/moscow_mule
	results = list(/datum/reagent/consumable/ethanol/moscow_mule = 10)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 5, /datum/reagent/consumable/ethanol/vodka = 5, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/tg_pina_olivada
	name = "Piña Olivada"
	id = /datum/reagent/consumable/ethanol/pina_olivada
	results = list(/datum/reagent/consumable/ethanol/pina_olivada = 5)
	required_reagents = list(/datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/nutriment/fat/oil/olive = 1)

/datum/chemical_reaction/tg_godfather
	name = "Ojciec Chrzestny"
	id = /datum/reagent/consumable/ethanol/godfather
	results = list(/datum/reagent/consumable/ethanol/godfather = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/whiskey = 1)

/datum/chemical_reaction/tg_godmother
	name = "Matka Chrzestna"
	id = /datum/reagent/consumable/ethanol/godmother
	results = list(/datum/reagent/consumable/ethanol/godmother = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/vodka = 1)

/datum/chemical_reaction/tg_amaretto_alexander
	name = "Amaretto Aleksander"
	id = /datum/reagent/consumable/ethanol/amaretto_alexander
	results = list(/datum/reagent/consumable/ethanol/amaretto_alexander = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/creme_de_cacao = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_ginger_amaretto
	name = "Amaretto z imbirem"
	id = /datum/reagent/consumable/ethanol/ginger_amaretto
	results = list(/datum/reagent/consumable/ethanol/ginger_amaretto = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/sol_dry = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/lemonjuice = 1)

/datum/chemical_reaction/tg_helianthus
	name = "Helianthus"
	id = /datum/reagent/consumable/ethanol/helianthus
	results = list(/datum/reagent/consumable/ethanol/helianthus = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/absinthe = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/toxin/mindbreaker = 1)
	mix_message = "Drink wydaje z siebie cichy, oświecony śmiech..."

/datum/chemical_reaction/tg_gin_garden
	name = "Ginowy Ogród"
	id = /datum/reagent/consumable/ethanol/gin_garden
	results = list(/datum/reagent/consumable/ethanol/gin_garden = 15)
	required_reagents = list(/datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/cucumberjuice = 3, /datum/reagent/consumable/sol_dry = 5, /datum/reagent/consumable/ice = 2)

/datum/chemical_reaction/tg_yuyakita
	name = "Yūyakita"
	id = /datum/reagent/consumable/ethanol/yuyakita
	results = list(/datum/reagent/consumable/ethanol/yuyakita = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/margarita = 3, /datum/reagent/consumable/ethanol/yuyake = 1)

/datum/chemical_reaction/tg_saibasan
	name = "Saibāsan"
	id = /datum/reagent/consumable/ethanol/saibasan
	results = list(/datum/reagent/consumable/ethanol/saibasan = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 2, /datum/reagent/consumable/ethanol/yuyake = 2, /datum/reagent/consumable/triple_citrus = 3, /datum/reagent/consumable/cherryjelly = 3)

/datum/chemical_reaction/tg_banzai_ti
	name = "Banzai-Tī"
	id = /datum/reagent/consumable/ethanol/banzai_ti
	results = list(/datum/reagent/consumable/ethanol/banzai_ti = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/tequila = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/triple_citrus = 2, /datum/reagent/consumable/sodawater = 2)

/datum/chemical_reaction/tg_sanraizusoda
	name = "Sanraizusōda"
	id = /datum/reagent/consumable/ethanol/sanraizusoda
	results = list(/datum/reagent/consumable/ethanol/sanraizusoda = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/sodawater = 2, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_kumicho
	name = "Kumichō"
	id = /datum/reagent/consumable/ethanol/kumicho
	results = list(/datum/reagent/consumable/ethanol/kumicho = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/godfather = 2, /datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/tg_red_planet
	name = "Czerwona Planeta"
	id = /datum/reagent/consumable/ethanol/red_planet
	results = list(/datum/reagent/consumable/ethanol/red_planet = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 2, /datum/reagent/consumable/ethanol/triple_sec = 2, /datum/reagent/consumable/ethanol/vermouth = 2, /datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/tg_amaterasu
	name = "Amaterasu"
	id = /datum/reagent/consumable/ethanol/amaterasu
	results = list(/datum/reagent/consumable/ethanol/amaterasu = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/vodka = 1, /datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/berryjuice = 2, /datum/reagent/consumable/sodawater = 5)

/datum/chemical_reaction/tg_nekomimosa
	name = "Nekomimosa"
	id = /datum/reagent/consumable/ethanol/nekomimosa
	results = list(/datum/reagent/consumable/ethanol/nekomimosa = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/yuyake = 2, /datum/reagent/consumable/watermelonjuice = 2, /datum/reagent/consumable/ethanol/champagne = 1)

/datum/chemical_reaction/tg_sentai_quencha
	name = "Sentai Quencha"
	id = /datum/reagent/consumable/ethanol/sentai_quencha
	results = list(/datum/reagent/consumable/ethanol/sentai_quencha = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/shochu = 1, /datum/reagent/consumable/ethanol/curacao = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/melon_soda = 2)

/datum/chemical_reaction/tg_bosozoku
	name = "Bōsōzoku"
	id = /datum/reagent/consumable/ethanol/bosozoku
	results = list(/datum/reagent/consumable/ethanol/bosozoku = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 1, /datum/reagent/consumable/lemonade = 1)

/datum/chemical_reaction/tg_ersatzche
	name = "Ersatzche"
	id = /datum/reagent/consumable/ethanol/ersatzche
	results = list(/datum/reagent/consumable/ethanol/ersatzche = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 5, /datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_kings_ransom
	name = "Królewski Okup"
	id = /datum/reagent/consumable/ethanol/kings_ransom
	results = list(/datum/reagent/consumable/ethanol/kings_ransom = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 5, /datum/reagent/consumable/ethanol/gin = 2, /datum/reagent/consumable/berryjuice = 2, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/tg_maui_sunrise
	name = "Maui Sunrise"
	id = /datum/reagent/consumable/ethanol/maui_sunrise
	results = list(/datum/reagent/consumable/ethanol/maui_sunrise = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/pineapplejuice = 2, /datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/triple_citrus = 1, /datum/reagent/consumable/lemon_lime = 4)

/datum/chemical_reaction/tg_imperial_mai_tai
	name = "Imperialny Mai Tai"
	id = /datum/reagent/consumable/ethanol/imperial_mai_tai
	results = list(/datum/reagent/consumable/ethanol/imperial_mai_tai = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 1, /datum/reagent/consumable/ethanol/rum = 1, /datum/reagent/consumable/ethanol/triple_sec = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/korta_nectar = 1)

/datum/chemical_reaction/tg_konococo_rumtini
	name = "Konococo Rumtini"
	id = /datum/reagent/consumable/ethanol/konococo_rumtini
	results = list(/datum/reagent/consumable/ethanol/konococo_rumtini = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/ethanol/kahlua = 3, /datum/reagent/consumable/coffee = 3, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/tg_blue_hawaiian
	name = "Blue Hawaiian"
	id = /datum/reagent/consumable/ethanol/blue_hawaiian
	results = list(/datum/reagent/consumable/ethanol/blue_hawaiian = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/coconut_rum = 2, /datum/reagent/consumable/pineapplejuice = 1, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/curacao = 1)

/datum/chemical_reaction/tg_star
	name = "Gwiazda"
	id = /datum/reagent/consumable/ethanol/star
	results = list(/datum/reagent/consumable/ethanol/star = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/applejack = 5, /datum/reagent/consumable/ethanol/vermouth = 5, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/tg_old_fashioned
	name = "Old Fashioned"
	id = /datum/reagent/consumable/ethanol/old_fashioned
	results = list(/datum/reagent/consumable/ethanol/old_fashioned = 30)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 25, /datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/ethanol/bitters = 2)
	mix_message = "Cukier rozpuszcza się w bitterze i whisky."

/datum/chemical_reaction/tg_sazerac
	name = "Sazerac"
	id = /datum/reagent/consumable/ethanol/sazerac
	results = list(/datum/reagent/consumable/ethanol/sazerac = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/old_fashioned = 10, /datum/reagent/consumable/ethanol/absinthe = 1)
	mix_message = "Mieszanka nabiera przyjemnego różowego odcienia."

/datum/chemical_reaction/tg_french_75
	name = "French 75"
	id = /datum/reagent/consumable/ethanol/french_75
	results = list(/datum/reagent/consumable/ethanol/french_75 = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 5, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_sangria
	name = "Sangria"
	id = /datum/reagent/consumable/ethanol/sangria
	results = list(/datum/reagent/consumable/ethanol/sangria = 20)
	required_reagents = list(/datum/reagent/consumable/ethanol/wine = 10, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/triple_citrus = 3, /datum/reagent/consumable/sodawater = 3, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_suffering_bastard
	name = "Cierpiący Drań"
	id = /datum/reagent/consumable/ethanol/suffering_bastard
	results = list(/datum/reagent/consumable/ethanol/suffering_bastard = 20)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 10, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/ethanol/gin = 3, /datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_hot_toddy
	name = "Hot Toddy"
	id = /datum/reagent/consumable/ethanol/hot_toddy
	results = list(/datum/reagent/consumable/ethanol/hot_toddy = 10)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/cognac = 3, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/lemonjuice = 1)
	required_temp = 320
	mix_message = "Zapach ciepłego koniaku wypełnia powietrze."

/datum/chemical_reaction/tg_tizirian_sour
	name = "Tizirski Sour"
	id = /datum/reagent/consumable/ethanol/tizirian_sour
	results = list(/datum/reagent/consumable/ethanol/tizirian_sour = 8)
	required_reagents = list(/datum/reagent/consumable/ethanol/bitters = 3, /datum/reagent/consumable/lemonjuice = 2, /datum/reagent/consumable/korta_nectar = 2, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_daiquiri
	name = "Daiquiri"
	id = /datum/reagent/consumable/ethanol/daiquiri
	results = list(/datum/reagent/consumable/ethanol/daiquiri = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 3, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/tg_blue_blazer
	name = "Blue Blazer"
	id = /datum/reagent/consumable/ethanol/blue_blazer
	results = list(/datum/reagent/consumable/ethanol/blue_blazer = 9)
	required_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 4, /datum/reagent/water = 4, /datum/reagent/consumable/sugar = 1)
	required_temp = 365
	mix_message = "Whisky zapala się jaskrawym niebieskim płomieniem!"

/datum/chemical_reaction/tg_bartenders_handshake
	name = "Barmański Uścisk Dłoni"
	id = /datum/reagent/consumable/ethanol/bartenders_handshake
	results = list(/datum/reagent/consumable/ethanol/bartenders_handshake = 2)
	required_reagents = list(/datum/reagent/consumable/ethanol/aperitivo = 1, /datum/reagent/consumable/ethanol/fernet = 1)

/datum/chemical_reaction/tg_brandy_crusta
	name = "Brandy Crusta"
	id = /datum/reagent/consumable/ethanol/brandy_crusta
	results = list(/datum/reagent/consumable/ethanol/brandy_crusta = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/sidecar = 4, /datum/reagent/consumable/ethanol/maraschino = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_casino
	name = "Kasyno"
	id = /datum/reagent/consumable/ethanol/casino
	results = list(/datum/reagent/consumable/ethanol/casino = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 8, /datum/reagent/consumable/lemonjuice = 1, /datum/reagent/consumable/ethanol/maraschino = 1)

/datum/chemical_reaction/tg_garibaldi
	name = "Garibaldi"
	id = /datum/reagent/consumable/ethanol/garibaldi
	results = list(/datum/reagent/consumable/ethanol/garibaldi = 5)
	required_reagents = list(/datum/reagent/consumable/orangejuice = 4, /datum/reagent/consumable/ethanol/aperitivo = 1)

/datum/chemical_reaction/tg_improved_whiskey
	name = "Ulepszony Koktajl z Whisky"
	id = /datum/reagent/consumable/ethanol/improved_whiskey
	results = list(/datum/reagent/consumable/ethanol/improved_whiskey = 7)
	required_reagents = list(/datum/reagent/consumable/ethanol/sazerac = 6, /datum/reagent/consumable/ethanol/maraschino = 1)

/datum/chemical_reaction/tg_jungle_bird
	name = "Jungle Bird"
	id = /datum/reagent/consumable/ethanol/jungle_bird
	results = list(/datum/reagent/consumable/ethanol/jungle_bird = 9)
	required_reagents = list(/datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/ethanol/rum = 3, /datum/reagent/consumable/ethanol/aperitivo = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_last_word
	name = "Ostatnie Słowo"
	id = /datum/reagent/consumable/ethanol/last_word
	results = list(/datum/reagent/consumable/ethanol/last_word = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/herbal_liqueur = 1, /datum/reagent/consumable/limejuice = 1, /datum/reagent/consumable/ethanol/maraschino = 1)

/datum/chemical_reaction/tg_mary_pickford
	name = "Mary Pickford"
	id = /datum/reagent/consumable/ethanol/mary_pickford
	results = list(/datum/reagent/consumable/ethanol/mary_pickford = 9)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 4, /datum/reagent/consumable/pineapplejuice = 3, /datum/reagent/consumable/grenadine = 1, /datum/reagent/consumable/ethanol/maraschino = 1)

/datum/chemical_reaction/tg_negroni
	name = "Negroni"
	id = /datum/reagent/consumable/ethanol/negroni
	results = list(/datum/reagent/consumable/ethanol/negroni = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 3, /datum/reagent/consumable/ethanol/aperitivo = 2, /datum/reagent/consumable/ethanol/vermouth = 1)

/datum/chemical_reaction/tg_nuclear_daiquiri
	name = "Nuklearne Daiquiri"
	id = /datum/reagent/consumable/ethanol/nuclear_daiquiri
	results = list(/datum/reagent/consumable/ethanol/nuclear_daiquiri = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 4, /datum/reagent/consumable/ethanol/herbal_liqueur = 3, /datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/tg_nuclear_daiquiri_thermo
	name = "Termonuklearne Daiquiri"
	id = /datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo
	results = list(/datum/reagent/consumable/ethanol/nuclear_daiquiri_thermo = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/nuclear_daiquiri = 10, /datum/reagent/uranium = 1, /datum/reagent/hydrogen = 9)
	mix_message = "Gdy mieszanka łączy się i zaczyna świecić, w ustach czujesz złowrogi metaliczny posmak."

/datum/chemical_reaction/tg_poets_dream
	name = "Sen Poety"
	id = /datum/reagent/consumable/ethanol/poets_dream
	results = list(/datum/reagent/consumable/ethanol/poets_dream = 4)
	required_reagents = list(/datum/reagent/consumable/ethanol/martini = 3, /datum/reagent/consumable/ethanol/herbal_liqueur = 1)

/datum/chemical_reaction/tg_pousse_cafe
	name = "Pousse Cafe"
	id = /datum/reagent/consumable/ethanol/pousse_cafe
	results = list(/datum/reagent/consumable/ethanol/pousse_cafe = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/herbal_liqueur = 1, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/consumable/ethanol/branca_menta = 1, /datum/reagent/consumable/ethanol/irish_cream = 1, /datum/reagent/consumable/ethanol/yuyake = 1, /datum/reagent/consumable/ethanol/aperitivo = 1, /datum/reagent/consumable/ethanol/amaretto = 1, /datum/reagent/consumable/ethanol/curacao = 1, /datum/reagent/consumable/ethanol/maraschino = 1, /datum/reagent/consumable/toechtauese_syrup = 1)

/datum/chemical_reaction/tg_spritz
	name = "Spritz"
	id = /datum/reagent/consumable/ethanol/spritz
	results = list(/datum/reagent/consumable/ethanol/spritz = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/champagne = 3, /datum/reagent/consumable/ethanol/aperitivo = 2, /datum/reagent/consumable/sodawater = 1)

/datum/chemical_reaction/tg_vieux_carre
	name = "Vieux Carré"
	id = /datum/reagent/consumable/ethanol/vieux_carre
	results = list(/datum/reagent/consumable/ethanol/vieux_carre = 15)
	required_reagents = list(/datum/reagent/consumable/ethanol/manhattan = 6, /datum/reagent/consumable/ethanol/cognac = 4, /datum/reagent/consumable/ethanol/vermouth = 2, /datum/reagent/consumable/ethanol/herbal_liqueur = 2, /datum/reagent/consumable/ethanol/bitters = 1)

/datum/chemical_reaction/tg_stone_cold_stout
	name = "Kamiennie Zimny Stout"
	id = /datum/reagent/consumable/ethanol/stone_cold_stout
	results = list(/datum/reagent/consumable/ethanol/stone_cold_stout = 6)
	required_reagents = list(/datum/reagent/consumable/ethanol/beer/maltliquor = 1, /datum/reagent/consumable/frostoil = 1, /datum/reagent/consumable/ethanol/fernet = 1, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/cryostylane = 1)

/datum/chemical_reaction/tg_footsoldiers_razor
	name = "Brzytwa Piechura"
	id = /datum/reagent/consumable/ethanol/footsoldiers_razor
	results = list(/datum/reagent/consumable/ethanol/footsoldiers_razor = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/patron = 3, /datum/reagent/consumable/ethanol/fernet = 2, /datum/reagent/consumable/ethanol/kahlua = 2, /datum/reagent/consumable/blackpepper = 1, /datum/reagent/silver = 1, /datum/reagent/medicine/pumpup = 1)
	mix_message = "Gdy otacza cię zapach kawy i agawy, czujesz, że to dobry dzień, by umrzeć."

/datum/chemical_reaction/tg_farstar_amrita
	name = "Amrita Dalekiej Gwiazdy"
	id = /datum/reagent/consumable/ethanol/farstar_amrita
	results = list(/datum/reagent/consumable/ethanol/farstar_amrita = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/star = 3, /datum/reagent/consumable/ethanol/singulo = 3, /datum/reagent/toxin/plasma = 2, /datum/reagent/consumable/honey = 2)
	mix_message = "Gdy mieszanka się łączy, czujesz, że ktoś cię obserwuje."

/datum/chemical_reaction/tg_lunacy
	name = "Obłęd"
	id = /datum/reagent/consumable/ethanol/lunacy
	results = list(/datum/reagent/consumable/ethanol/lunacy = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/suffering_bastard = 4, /datum/reagent/consumable/ethanol/absinthe = 2, /datum/reagent/consumable/ethanol/moonshine = 2, /datum/reagent/mercury = 1, /datum/reagent/iron = 1)
	mix_message = "Ktoś rozciąga usta w upiornym uśmiechu. Może to nawet ty."

/datum/chemical_reaction/tg_emptiest_glass
	name = "Najpustsza Szklanka"
	id = /datum/reagent/consumable/ethanol/emptiest_glass
	results = list(/datum/reagent/consumable/ethanol/emptiest_glass = 4)
	required_reagents = list(/datum/reagent/consumable/ice = 1, /datum/reagent/consumable/ethanol/last_word = 1, /datum/reagent/consumable/nothing = 1, /datum/reagent/cryostylane = 1)
	required_temp = 250
	is_cold_recipe = TRUE
	mix_message = "Przez chwilę świat wydaje się odrobinę bledszy."

/datum/chemical_reaction/tg_admiralty
	name = "Admiralicja"
	id = /datum/reagent/consumable/ethanol/admiralty
	results = list(/datum/reagent/consumable/ethanol/admiralty = 5)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 3, /datum/reagent/consumable/ethanol/vermouth = 1, /datum/reagent/consumable/ethanol/fernet = 1)

/datum/chemical_reaction/tg_dark_and_stormy
	name = "Dark and Stormy"
	id = /datum/reagent/consumable/ethanol/dark_and_stormy
	results = list(/datum/reagent/consumable/ethanol/dark_and_stormy = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 3, /datum/reagent/consumable/sol_dry = 7)

/datum/chemical_reaction/tg_long_haul
	name = "Długi Kurs"
	id = /datum/reagent/consumable/ethanol/long_haul
	results = list(/datum/reagent/consumable/ethanol/long_haul = 25)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 4, /datum/reagent/consumable/ethanol/curacao = 3, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/consumable/sodawater = 15)

/datum/chemical_reaction/tg_long_john_silver
	name = "Long John Silver"
	id = /datum/reagent/consumable/ethanol/long_john_silver
	results = list(/datum/reagent/consumable/ethanol/long_john_silver = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/navy_rum = 4, /datum/reagent/consumable/ethanol/bitters = 1, /datum/reagent/consumable/lemonade = 5)

/datum/chemical_reaction/tg_tropical_storm
	name = "Burza Tropikalna"
	id = /datum/reagent/consumable/ethanol/tropical_storm
	results = list(/datum/reagent/consumable/ethanol/tropical_storm = 10)
	required_reagents = list(/datum/reagent/consumable/ethanol/rum = 2, /datum/reagent/consumable/ethanol/curacao = 2, /datum/reagent/consumable/triple_citrus = 4, /datum/reagent/consumable/pineapplejuice = 2)

/datum/chemical_reaction/tg_vanillashake
	name = "Koktajl waniliowy"
	id = /datum/reagent/consumable/vanillashake
	results = list(/datum/reagent/consumable/vanillashake = 3)
	required_reagents = list(/datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_caramelshake
	name = "Koktajl karmelowy"
	id = /datum/reagent/consumable/caramelshake
	results = list(/datum/reagent/consumable/caramelshake = 3)
	required_reagents = list(/datum/reagent/consumable/caramel = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_choccyshake
	name = "Koktajl czekoladowy"
	id = /datum/reagent/consumable/choccyshake
	results = list(/datum/reagent/consumable/choccyshake = 3)
	required_reagents = list(/datum/reagent/consumable/cocoa = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_strawberryshake
	name = "Koktajl truskawkowy"
	id = /datum/reagent/consumable/strawberryshake
	results = list(/datum/reagent/consumable/strawberryshake = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_bananashake
	name = "Koktajl bananowy"
	id = /datum/reagent/consumable/bananashake
	results = list(/datum/reagent/consumable/bananashake = 3)
	required_reagents = list(/datum/reagent/consumable/banana = 1, /datum/reagent/consumable/ice = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_toechtauese_syrup
	name = "Syrop töchtaüse"
	id = /datum/reagent/consumable/toechtauese_syrup
	results = list(/datum/reagent/consumable/toechtauese_syrup = 10)
	required_reagents = list(/datum/reagent/consumable/toechtauese_juice = 6, /datum/reagent/consumable/sugar = 4)

/datum/chemical_reaction/tg_roy_rogers
	name = "Roy Rogers"
	id = /datum/reagent/consumable/roy_rogers
	results = list(/datum/reagent/consumable/roy_rogers = 3)
	required_reagents = list(/datum/reagent/consumable/space_cola = 2, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/tg_shirley_temple
	name = "Shirley Temple"
	id = /datum/reagent/consumable/shirley_temple
	results = list(/datum/reagent/consumable/shirley_temple = 3)
	required_reagents = list(/datum/reagent/consumable/sol_dry = 2, /datum/reagent/consumable/grenadine = 1)

/datum/chemical_reaction/tg_agua_fresca
	name = "Agua Fresca"
	id = /datum/reagent/consumable/agua_fresca
	results = list(/datum/reagent/consumable/agua_fresca = 10)
	required_reagents = list(/datum/reagent/consumable/watermelonjuice = 4, /datum/reagent/consumable/ice = 1, /datum/reagent/water = 2, /datum/reagent/consumable/limejuice = 2, /datum/reagent/consumable/menthol = 1)

/datum/chemical_reaction/tg_cinderella
	name = "Cinderella"
	id = /datum/reagent/consumable/cinderella
	results = list(/datum/reagent/consumable/cinderella = 50)
	required_reagents = list(/datum/reagent/consumable/pineapplejuice = 10, /datum/reagent/consumable/orangejuice = 10, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/sol_dry = 20, /datum/reagent/consumable/ethanol/bitters = 2)

/datum/chemical_reaction/tg_strawberry_banana
	name = "Smoothie truskawkowo-bananowe"
	id = /datum/reagent/consumable/strawberry_banana
	results = list(/datum/reagent/consumable/strawberry_banana = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/banana = 1)

/datum/chemical_reaction/tg_berry_blast
	name = "Smoothie Jagodowa Bomba"
	id = /datum/reagent/consumable/berry_blast
	results = list(/datum/reagent/consumable/berry_blast = 3)
	required_reagents = list(/datum/reagent/consumable/berryjuice = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_funky_monkey
	name = "Smoothie Odjechana Małpa"
	id = /datum/reagent/consumable/funky_monkey
	results = list(/datum/reagent/consumable/funky_monkey = 3)
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 2, /datum/reagent/consumable/banana = 1)

/datum/chemical_reaction/tg_green_giant
	name = "Smoothie Zielony Olbrzym"
	id = /datum/reagent/consumable/green_giant
	results = list(/datum/reagent/consumable/green_giant = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/limejuice = 1)

/datum/chemical_reaction/tg_melon_baller
	name = "Smoothie Melonowe Kulki"
	id = /datum/reagent/consumable/melon_baller
	results = list(/datum/reagent/consumable/melon_baller = 3)
	required_reagents = list(/datum/reagent/consumable/watermelonjuice = 1, /datum/reagent/consumable/ethanol/creme_de_menthe = 1, /datum/reagent/consumable/milk = 1)

/datum/chemical_reaction/tg_vanilla_dream
	name = "Smoothie Waniliowy Sen"
	id = /datum/reagent/consumable/vanilla_dream
	results = list(/datum/reagent/consumable/vanilla_dream = 3)
	required_reagents = list(/datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/consumable/cream = 1)

/datum/chemical_reaction/tg_cucumberlemonade
	name = "Lemoniada ogórkowa"
	id = /datum/reagent/consumable/cucumberlemonade
	results = list(/datum/reagent/consumable/cucumberlemonade = 5)
	required_reagents = list(/datum/reagent/consumable/lemon_lime = 3, /datum/reagent/consumable/cucumberjuice = 2, /datum/reagent/consumable/ice = 1)

/datum/chemical_reaction/tg_mississippi_queen
	name = "Mississippi Queen"
	id = /datum/reagent/consumable/mississippi_queen
	results = list(/datum/reagent/consumable/mississippi_queen = 50)
	required_reagents = list(/datum/reagent/consumable/tomatojuice = 15, /datum/reagent/consumable/mayonnaise = 10, /datum/reagent/consumable/soysauce = 5, /datum/reagent/consumable/vinegar = 2, /datum/reagent/consumable/capsaicin = 10, /datum/reagent/consumable/cocoa = 2)

/datum/chemical_reaction/tg_t_letter
	name = "T"
	id = /datum/reagent/consumable/t_letter
	results = list(/datum/reagent/consumable/t_letter = 2)
	required_reagents = list(/datum/reagent/consumable/nothing = 1, /datum/reagent/consumable/tea = 1)

/datum/chemical_reaction/tg_bitters_soda
	name = "Bitter z wodą sodową"
	id = /datum/reagent/consumable/ethanol/bitters_soda
	results = list(/datum/reagent/consumable/ethanol/bitters_soda = 15)
	required_reagents = list(/datum/reagent/consumable/sodawater = 10, /datum/reagent/consumable/ice = 5, /datum/reagent/consumable/ethanol/bitters = 1)

// ---------- Bazy w dyspenserach baru (jak w tg) ----------

/obj/machinery/chem_dispenser/drinks/beer/Initialize(mapload)
	dispensable_reagents |= list(/datum/reagent/consumable/ethanol/coconut_rum, /datum/reagent/consumable/ethanol/curacao, /datum/reagent/consumable/ethanol/beer/maltliquor, /datum/reagent/consumable/ethanol/navy_rum, /datum/reagent/consumable/ethanol/rice_beer, /datum/reagent/consumable/ethanol/yuyake, /datum/reagent/consumable/ethanol/bitters, /datum/reagent/consumable/ethanol/amaretto, /datum/reagent/consumable/ethanol/maraschino, /datum/reagent/consumable/ethanol/aperitivo, /datum/reagent/consumable/ethanol/herbal_liqueur, /datum/reagent/consumable/ethanol/shochu, /datum/reagent/consumable/mintextract)
	return ..()

/obj/machinery/chem_dispenser/drinks/Initialize(mapload)
	if(type == /obj/machinery/chem_dispenser/drinks || type == /obj/machinery/chem_dispenser/drinks/fullupgrade)
		dispensable_reagents |= list(/datum/reagent/consumable/melon_soda, /datum/reagent/consumable/sol_dry)
	return ..()
