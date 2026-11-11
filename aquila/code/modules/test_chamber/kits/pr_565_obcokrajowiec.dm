/datum/test_chamber_kit/pr_565
	name = "Obcokrajowiec, czip tłumacza i tłumacz kieszonkowy"
	pr = "aq33/AquilaStation#565"
	description = "Potrzebne dwie osoby: jedna z językiem English w preferencjach (dołącza do rundy), druga z polskim. \
		Anglik ze słuchawkami dostaje na start czip tłumacza w słuchawkach, bez słuchawek tłumacza kieszonkowego. \
		Bez tłumacza: anglik mówi po Angielsku, polski gracz widzi bełkot z flagą, a anglik nie rozumie polskiej mowy. \
		Z czipem w słuchawkach na uszach (albo tłumaczem w ręce, kieszeni, na pasku): polski gracz widzi polskie zdanie we Wspólnym, także przez radio (;), szeptem (#) i z własną emotką (krzyczy*...). \
		Polska mowa przychodzi anglikowi po angielsku w czacie i w dymku. Słuchawki w ręce albo tłumacz w plecaku nie działają. \
		Czip: wsuń go w słuchawki jak klucz, oba gniazda na klucze zostają wolne. Śrubokręt wyjmuje same klucze, multitool wyjmuje czip. \
		EMP (granat EMP z zestawu): czip i tłumacz kieszonkowy milkną na minutę i same się restartują, a przy silnym EMP (blisko granatu) mają 25% szansy spalić się na stałe. Zapasowe czipy są w pudełku w szafce HoP-a (jedno jest też w zestawie). \
		OOC: anglik i Polak widzą swoje wiadomości nawzajem przetłumaczone. Adminhelp anglika dochodzi do admina z polskim tłumaczeniem, a PW admina dochodzi z angielskim. \
		Imiona: anglik losuje w preferencjach (kostka, nowa postać, zawsze losowe imię) imiona z angielskiej puli. \
		Bez DEEPL_API_KEY w configu tekst przechodzi bez tłumaczenia. \
		Bez drugiego gracza: obcokrajowca da się zrobić przez VV procką aq_make_foreigner() na swojej postaci."
	items = list(
		/obj/item/aquila_translator/chip = 2,
		/obj/item/aquila_translator = 2,
		/obj/item/radio/headset = 2,
		/obj/item/encryptionkey/headset_sec = 2,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1,
		/obj/item/grenade/empgrenade = 2,
		/obj/item/storage/box/aquila_translator_chips = 1,
	)
