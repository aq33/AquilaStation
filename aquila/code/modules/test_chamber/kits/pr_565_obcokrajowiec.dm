/datum/test_chamber_kit/pr_565
	name = "Obcokrajowiec i tłumacz kieszonkowy"
	pr = "aq33/AquilaStation#565"
	description = "Potrzebne dwie osoby: jedna z językiem English w preferencjach (dołącza do rundy), druga z polskim. \
		Bez tłumacza: anglik mówi po Angielsku, polski gracz widzi bełkot z flagą, a anglik nie rozumie polskiej mowy. \
		Z tłumaczem w ręce, kieszeni albo na pasku: anglik mówi po angielsku, a polski gracz widzi polskie zdanie we Wspólnym, także przez radio (;), szeptem (#) i z własną emotką (krzyczy*...). \
		Polska mowa przychodzi anglikowi po angielsku w czacie i w dymku nad głową. Tłumacz w plecaku nie działa. \
		Bez DEEPL_API_KEY w configu tekst przechodzi bez tłumaczenia. Polak z tłumaczem w ręce rozumie Angielski. \
		Bez drugiego gracza: obcokrajowca da się zrobić przez VV procką aq_make_foreigner() na swojej postaci."
	items = list(
		/obj/item/aquila_translator = 2,
		/obj/item/radio/headset = 2,
	)
