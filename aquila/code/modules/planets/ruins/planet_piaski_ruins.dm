// AQUILA: ruiny planet skalistych i białych piasków przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy
// jak kod, grafiki CC BY-SA 3.0): _maps/RandomRuins/RockRuins/, SandRuins/ i code/datums/ruins/rockplanet.dm,
// whitesands.dm. Planety pustynne i mgliste nie mają w Shiptest własnych ruin, więc pożyczają pasujące: pustynia osady
// i zakłady z białych piasków, planeta mglista opuszczoną placówkę, poligon pustelników i rozbity statek, każda
// przepięta na własny teren, atmosferę i obszary (tools/planets/recipes/piaski_retheme.sh).
// Jak przy lawie: wszystkie są ruinami głównymi (koszt 10, poza budżetem małych ruin); kilka ma ponad 60 pól wysokości,
// więc planeta, która je wylosuje, dostaje większą powierzchnię (planet_surface.dm).
//
// Mapy przerobione skryptem tools/planets/convert_maps.py z zamiennikami tools/planets/mappings/piaski.py:
// - Frontiersmeni i pustelnicy -> nasi piraci (basic trooper) według broni, Klika Ramziego -> żołnierze Syndykatu,
//   roboty automated/* -> hivebot z frakcją obrońców, fauna -> nasze moby z portu fauny;
// - zwłoki frakcji -> nasze zwłoki piratów, Syndykatu, NT i górników; martwe zwierzęta -> szczątki;
// - podłogi z atmosferą planety (*/rockplanet, */whitesands) -> nasze podłogi z initial_gas_mix planety;
// - bronie, amunicja, ubrania i jedzenie -> najbliższe nasze; platformy, holoszyldy, flagi i znaki Warra pominięte;
// - źródło promieniowania -> /obj/effect/planet_radiation (nasz radiation_pulse);
// - instalacje: wiszące końcówki rur z oryginału i po zmianie urządzeń naprawione skryptem tools/planets/prune_pipes.py
//   (rozgałęzienia zmieniają kształt, wiszące końce znikają).

/datum/map_template/ruin/planet_rock
	prefix = "aquila/_maps/RandomRuins/PlanetRock/"
	cost = 10

/datum/map_template/ruin/planet_rock/shippingdock
	name = "Opuszczony Dok Przeładunkowy"
	id = "planet_rock_shippingdock"
	description = "Porzucony dok przeładunkowy dla małych frachtowców i przemytników. Ktoś zastawił tu pułapki na szabrowników."
	suffix = "planet_rock_shippingdock.dmm"

/datum/map_template/ruin/planet_rock/distillery
	name = "Gorzelnia Frontiersmenów"
	id = "planet_rock_distillery"
	description = "Dawna placówka Makosso-Warra sprzed wojny, przerobiona przez bimbrowników na gorzelnię."
	suffix = "planet_rock_distillery.dmm"

/datum/map_template/ruin/planet_rock/mining_base
	name = "Instalacja Górnicza N+S"
	id = "planet_rock_mining_base"
	description = "Instalacja górnicza N+S, która niedawno padła ofiarą bandy piratów."
	suffix = "planet_rock_mining_installation.dmm"

/datum/map_template/ruin/planet_rock/rust_base
	name = "ISV Rust Base"
	id = "planet_rock_rustbase"
	description = "Rozbity statek, który zmienił się w odcięty od świata posterunek piratów."
	suffix = "planet_rock_rustbase.dmm"

/datum/map_template/ruin/planet_rock/oasis_stash
	name = "Skrytka w Oazie"
	id = "planet_rock_oasis_stash"
	description = "Skrytka z narkotykami, którą ktoś właśnie zakopuje."
	suffix = "planet_rock_oasis_stash.dmm"

/datum/map_template/ruin/planet_rock/somme
	name = "Kompleks Okopów"
	id = "planet_rock_somme"
	description = "Banda okopała się na powierzchni planety jak kleszcz."
	suffix = "planet_rock_somme.dmm"

/datum/map_template/ruin/planet_rock/ngr_mining_colony
	name = "Opuszczona Kolonia Górnicza"
	id = "planet_rock_ngr_mining_colony"
	description = "Kolonia górnicza ewakuowana po dziwnym zachowaniu fauny. W chwili ewakuacji trzymano w niej więźniów Kliki Ramziego."
	suffix = "planet_rock_ngr_mining_colony.dmm"

/datum/map_template/ruin/planet_sand
	prefix = "aquila/_maps/RandomRuins/PlanetSand/"
	cost = 10

/datum/map_template/ruin/planet_sand/cave_base
	name = "Opuszczona Placówka"
	id = "planet_sand_cave_base"
	description = "Dawny dom nieszczęśnika na posterunku obserwacyjnym. Teraz chytra pułapka."
	suffix = "planet_sand_cave_base.dmm"

/datum/map_template/ruin/planet_sand/saloon
	name = "Saloon Pustelników"
	id = "planet_sand_saloon"
	description = "Saloon w stylu westernu, ulubione miejsce spotkań pustelników na powierzchni."
	suffix = "planet_sand_camp_saloon.dmm"

/datum/map_template/ruin/planet_sand/e11_manufactory
	name = "Zakład Montażu Karabinów"
	id = "planet_sand_e11_manufactory"
	description = "Stara fabryka Eoehoma Firearms, w której składano lubiane przez wielu karabiny E-11."
	suffix = "planet_sand_e11_manufactory.dmm"

/datum/map_template/ruin/planet_sand/brazillian_lab
	name = "Poligon Pustelników"
	id = "planet_sand_brazillianlab"
	description = "Rzucający się w oczy kompleks pośrodku piaszczystych pustkowi. Co ciekawego jest w środku?"
	suffix = "planet_sand_brazillianlab.dmm"

/datum/map_template/ruin/planet_sand/nomads_stop
	name = "Przystanek Nomadów"
	id = "planet_sand_nomads_stop"
	description = "Zespół budynków ze starych prefabrykatów i szybkiego betonu, zamieniony w punkt handlowy na powierzchni planety."
	suffix = "planet_sand_nomads_stop.dmm"

/datum/map_template/ruin/planet_sand/settlement_raid
	name = "Napad na Osadę"
	id = "planet_sand_settlement_raid"
	description = "Osada żyjąca ze złomowania pod wodzą dawnego Marudera Gorlex, właśnie napadnięta przez brutalnych piratów."
	suffix = "planet_sand_settlement_raid.dmm"

/datum/map_template/ruin/planet_sand/pubbytown
	name = "Miasteczko Pubby"
	id = "planet_sand_pubbytown"
	description = "Miasteczko wokół wraku statku klasy Pubby, założone przez technika, który pomaga pustelnikom w naprawach broni."
	suffix = "planet_sand_pubbytown.dmm"

/datum/map_template/ruin/planet_desert
	prefix = "aquila/_maps/RandomRuins/PlanetDesert/"
	cost = 10

/datum/map_template/ruin/planet_desert/saloon
	name = "Saloon na Pustyni"
	id = "planet_desert_saloon"
	description = "Saloon w stylu westernu, w którym zbierają się zbieracze z pustyni."
	suffix = "planet_desert_camp_saloon.dmm"

/datum/map_template/ruin/planet_desert/nomads_stop
	name = "Pustynny Przystanek Nomadów"
	id = "planet_desert_nomads_stop"
	description = "Punkt handlowy z prefabrykatów pośrodku pustyni."
	suffix = "planet_desert_nomads_stop.dmm"

/datum/map_template/ruin/planet_desert/e11_manufactory
	name = "Pustynny Zakład Montażu Karabinów"
	id = "planet_desert_e11_manufactory"
	description = "Stara fabryka karabinów E-11 zasypywana przez piasek."
	suffix = "planet_desert_e11_manufactory.dmm"

/datum/map_template/ruin/planet_desert/settlement_raid
	name = "Napad na Pustynną Osadę"
	id = "planet_desert_settlement_raid"
	description = "Osada złomiarzy na pustyni, właśnie napadnięta przez piratów."
	suffix = "planet_desert_settlement_raid.dmm"

/datum/map_template/ruin/planet_shrouded
	prefix = "aquila/_maps/RandomRuins/PlanetShrouded/"
	cost = 10

/datum/map_template/ruin/planet_shrouded/cave_base
	name = "Placówka we Mgle"
	id = "planet_shrouded_cave_base"
	description = "Opuszczony posterunek obserwacyjny w mgle. Teraz chytra pułapka."
	suffix = "planet_shrouded_cave_base.dmm"

/datum/map_template/ruin/planet_shrouded/brazillian_lab
	name = "Poligon we Mgle"
	id = "planet_shrouded_brazillianlab"
	description = "Kompleks badawczy pustelników ukryty w mgle. Co ciekawego jest w środku?"
	suffix = "planet_shrouded_brazillianlab.dmm"

/datum/map_template/ruin/planet_shrouded/rust_base
	name = "Wrak we Mgle"
	id = "planet_shrouded_rustbase"
	description = "Rozbity statek piratów zasnuty mgłą."
	suffix = "planet_shrouded_rustbase.dmm"

/// Ruiny jednego rodzaju z szablonów wczytanych przez SSmapping (nazwa -> szablon), jak get_planet_lava_ruin_templates()
/proc/get_planet_ruin_templates(ruin_root)
	var/static/list/cache = list()
	var/list/templates = cache[ruin_root]
	if(!length(templates))
		templates = list()
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, ruin_root))
				templates[name] = ruin
		cache[ruin_root] = templates
	return templates

// Kartki z kolonii górniczej i gorzelni (Shiptest: code/modules/ruins/rockplanet_ruin_code/ngr_mining_colony.dm,
// rockplanet_ruin_code.dm)

/obj/item/paper/fluff/ruins/planet_piaski
	icon_state = "scrap"

/obj/item/paper/fluff/ruins/planet_piaski/mine_report
	name = "raport z kopalni"
	desc = "Część kartki pokrywa cienka warstwa zaschniętej krwi."
	icon_state = "scrap_bloodied"
	default_raw_text = "Trochę się martwię o dziurę numer dwa. Jedynka jest w porządku, to tylko klasa druga, ale jest dość głęboka, a solidne stanowiska wieżyczek sprawiają, że naszym raczej nic się nie stanie. Za to z dwójki wyrastają jakieś dziwne, <i>naprawdę niepokojące</i> błękitne kryształy."

/obj/item/paper/fluff/ruins/planet_piaski/cavein
	name = "WAŻNE"
	icon_state = "scrap_bloodied"
	default_raw_text = "JEŚLI WIERCENIE W DZIURZE 2 SIĘ SPIEPRZY, PODŁOŻYŁEM POD STROPEM JASKINI MASĘ C4, ŻEBY JĄ ZAWALIĆ. UWAŻAJCIE."

/obj/item/paper/fluff/ruins/planet_piaski/commanders_log
	name = "dziennik dowódcy, dzień 72"
	default_raw_text = "<b>Dzień 72</b><br><br>Nasza ochrona zatrzymała na wschód od kolonii bimbrownika Frontiersmenów, który próbował sprzedać jednemu z górników tani bimber. Winnego górnika ukarałem (a trochę bimbru pożyczyłem dla siebie), a Frontiersmen na razie siedzi w areszcie. Czekam na odpowiedź Dowództwa w sprawie przewiezienia go."

/obj/item/paper/fluff/ruins/planet_piaski/commanders_log/two
	name = "dziennik dowódcy, dzień 78"
	default_raw_text = "<b>Dzień 78</b><br><br>Jest. Dziewięcioosobowy oddział zdrajców Ramziego zaatakował dziś kolonię. Dobra wiadomość: namierzyliśmy ich desantowiec, zanim wszyscy z niego wysiedli. Jednego zabiliśmy, resztę wzięliśmy żywcem. Zła wiadomość: areszt kolonii jest teraz potwornie przepełniony, więc zamówiliśmy kilka materacy, żeby mieli gdzie spać. Dowództwo mówi, że transport będzie za „miesiąc albo dwa”, podobno przez ostatnią falę poddających się komórek Frontiersmenów, które trzeba przewieźć. Niech przynajmniej mają wygodnie."

/obj/item/paper/fluff/ruins/planet_piaski/commanders_log/three
	name = "dziennik dowódcy, dzień 108"
	default_raw_text = "<b>Dzień 108</b><br><br>Górnicy zaczęli dziś pracę przy Żyle 2. Podobno idzie bardzo głęboko i ma dużo dobrego materiału, ale jeden z nich martwił się błękitnymi kryształami w środku. <s>Jestem pewien, że będzie dobrze</s>Spojrzałem na czujniki skafandrów: cała ekipa górnicza nie żyje. Zamykam kopalnię na kilka dni, aż przyjdą posiłki."

/obj/item/paper/fluff/ruins/planet_piaski/commanders_log/four
	name = "dziennik dowódcy, dzień 109"
	default_raw_text = "<b>Dzień 109</b><br><br>Wartownicy donoszą, że niedaleko stąd zbiera się wielka horda fauny. Najwyraźniej wczorajszy wypadek przy wierceniu spłoszył całe gniazdo gruboidów, migo i innych paskudztw, jakie mają te światy, i sporo z nich ruszyło w naszą stronę. Miło byłoby wiedzieć wcześniej. Wydaję rozkaz ewakuacji: opuszczamy kolonię, dopóki Dowództwo jej nie odbije."

/obj/item/paper/fluff/ruins/planet_piaski/prisoner_notice
	name = "ogłoszenie dla więźniów"
	default_raw_text = "Powiem szczerze: ta kolonia nigdy nie była budowana na tylu z was. Robimy, co możemy, żebyście mieli w miarę wygodnie, dopóki Dowództwo nie przestanie się ociągać. Jeśli potrzebujecie dodatkowej pościeli albo zapasów, zgłoście się do sierżanta, a on sprawdzi, co technicy mogą oddać. Zachowujcie się grzecznie, proszę."

/obj/item/paper/fluff/ruins/planet_piaski/prisoner_procedure
	name = "przypomnienie dla strażników"
	default_raw_text = "Dawajcie im tylko dodatki zatwierdzone przez sierżanta i nic ponad to. Alkohol jest zakazany, a jeśli któryś z nich pędzi coś z tego, co rośnie w ogródku, macie to zgłosić. Zwłaszcza że jeden z nich to bimbrownik z Frontiersmenów. Aha, jeśli kiedyś trzeba będzie się ewakuować, zapędźcie ich na prom, jeśli się da."

/obj/item/paper/fluff/ruins/planet_piaski/moonshine_note
	name = "zabłocona kartka"
	default_raw_text = "udało mi się odzyskać z magazynu większość twojego sprzętu do pędzenia, podobno rzucili go tam po tym, jak pocięli twój statek, i nigdy się do niego nie zabrali. wisisz mi za to kilka dzbanów dobrego towaru."

/obj/item/paper/fluff/ruins/planet_piaski/distillery
	name = "instrukcja gorzelni"
	desc = "Pognieciona kartka przesiąknięta alkoholem."
	default_raw_text = "<center><h3>Instrukcja bimbru</h3><BR>Wiem, że niektórzy z was nie umieją dość dobrze czytać, ale jeśli kiedyś znajdą mnie martwego albo zaginę, <i>przeczytajcie to.</i> Rzemiosło musi przetrwać.</center><br><br>1. Wlej do destylatora około 5 jednostek enzymu. Cały zapas trzymamy w zielonej skrzyni w magazynie.<br>2. Zmiel kolbę kukurydzy i dodaj zacier do destylatora.<br>3. Wsyp tyle samo cukru i zamieszaj.<br>4. Teraz trzeba wybrać produkt i przefiltrować go ręcznie. Mieliśmy lepszy destylator, który filtrował sam, aż do zeszłorocznego wypadku. Na razie musi wystarczyć ten.<br>5. Oceń produkt. Dobry bimber jest przejrzysty jak woda i pali się na niebiesko. Jeśli nie jest dobry, wylej go.<BR><BR>."
