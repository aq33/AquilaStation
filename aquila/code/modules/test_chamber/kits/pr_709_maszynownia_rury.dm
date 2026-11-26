// aq33/AquilaStation#709 - wytrzymałość rur, kanistry, zawór odcinający, zacisk, iskrownik, wysoki przepływ (plan maszynowni E1–E4)

/datum/test_chamber_kit/pr_709
	name = "Maszynownia: rury, zawory, wysoki przepływ"
	pr = "aq33/AquilaStation#709"
	description = "1) RPD: w „Pipes” jest zawór odcinający, w „Devices” iskrownik rurowy, pompa wysokiego ciśnienia (13 500 kPa), pompa objętościowa i filtr wysokiego przepływu (600 L/s, złota obwódka). \
		2) Zbuduj zamkniętą pętlę rur z portem, pompą wysokiego ciśnienia, zaworem odcinającym i iskrownikiem. Wpompuj z kanistrów plazmę i tlen do kilku tysięcy kPa, potem kliknij iskrownik: ciśnienie rośnie z temperaturą, od 80% progu (40 000 kPa) rury jęczą i ostrzegają w opisie, powyżej 50 000 kPa jedna pęka, syczy i wypuszcza gaz na kafelek. \
		3) Zawór odcinający po stronie pęknięcia sam się zatrzaskuje; ręcznie go nie otworzysz, póki automat jest włączony (multitool przełącza). \
		4) Zespawaj pękniętą rurę (3 s): zawór otwiera się sam. \
		5) Wzmocnij rurę 5 arkuszami plastali: opis pokazuje 500 000 kPa i 100 000 K. Rozkręcona oddaje plastal. \
		6) Załóż zacisk na prosty odcinek: rura staje się zamkniętym zaworem w tym samym kolorze. Kliknij, żeby otworzyć, i zdejmij kluczem: wraca rura. \
		7) Kanister: opis ma naklejkę z limitami. Zapal w nim mieszankę plazmy z tlenem: niszczeje i pęka. \
		8) Iskrownik z przyciskiem: multitool na przycisk zapłonu (zapisuje go w buforze), potem na iskrownik. Przycisk zapala wtedy rury."
	items = list(
		/obj/item/pipe_dispenser = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/wrench = 1,
		/obj/item/multitool = 1,
		/obj/item/analyzer = 1,
		/obj/item/stack/sheet/plasteel/twenty = 1,
		/obj/item/pipe_clamp = 2,
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
	)
