// aq33/AquilaStation#641 - zbiorczy 14.11: rozkazy DeepL, przydział do drużyny, wkładki do pancerza, ciepło broni energetycznych

/datum/test_chamber_kit/pr_641
	name = "Zbiorczy 14.11 (wkładki do pancerza, ciepło broni energetycznych, wózek, rozkazy)"
	pr = "aq33/AquilaStation#641"
	description = "Na arenie leżą: kamizelka, hardsuit, gotowe wkładki (ciężka tytanowa, ciężka złota, lekka diamentowa), śrubokręt, multitool, fazer seryjny z chłodnicą i magazynem ciepła, wózek amunicyjny z trzema rakietami obok oraz konsola drużyn XO. \
	1) Wkładka: klik ciężką tytanową w kamizelkę (3 s) → w opisie kamizelki „Ma włożoną…”, w panelu pancerza +20 na pociski. Druga wkładka do tej samej kamizelki → odmowa (negatyw). Śrubokręt → wkładka wraca do ręki. \
	2) Złota ciężka w hardsuicie → wolniejszy chód; po wyjęciu prędkość wraca. Postrzel się w tułów kilka razy z czegokolwiek → wytrzymałość w opisie spada, przy 0 komunikat „pęka”. Trafienie w głowę nie zużywa wkładki. \
	3) Kuźnia (jeśli jest na mapie): forma wkładek z pudełka form → piec łukowy, wybierz materiał → kowadło → gotowa wkładka; stół montażowy jej nie przyjmuje (negatyw). \
	4) Fazer: śrubokręt + klucz na fazerze → w opisie sekwencja strojenia; ręką wpisz ją w menu kołowym; pomyłka podnosi ciepło. Multitool na otwartym fazerze ustawia soczewki do 100%. Chłodnica i magazyn ciepła są już połączone (opis: „połączony z…”). Okno fazera (zamknięta obudowa): pasek ciepła, przycisk „Odprowadź ciepło”, soczewki i strojenie. \
	5) Wózek: przeciągnij trzy rakiety na wózek → leżą równo jedna nad drugą; zdejmij środkową w oknie wózka → reszta zostaje w porządku. \
	6) Konsola XO: rozkaz dla swojej drużyny (z kluczem DeepL na serwerze gracz z angielskim widzi go po angielsku; bez klucza wszyscy dostają oryginał)."
	items = list(
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/clothing/suit/space/hardsuit = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wrench = 1,
		/obj/item/multitool = 1,
		/obj/machinery/ship_weapon/energy = 1,
		/obj/machinery/cooling/cooler = 1,
		/obj/machinery/cooling/storage = 1,
		/obj/structure/munitions_trolley = 1,
		/obj/item/ship_weapon/ammunition/missile = 3,
		/obj/machinery/computer/squad_manager = 1,
		/obj/item/storage/box/munition_casts = 1,
	)

/datum/test_chamber_kit/pr_641/setup(list/spawned, list/turfs, turf/center, mob/user)
	// gotowe wkładki: typ, materiał
	var/list/made = list(
		list(/obj/item/munition_part/body/armor_insert/heavy, /datum/material/titanium),
		list(/obj/item/munition_part/body/armor_insert/heavy, /datum/material/gold),
		list(/obj/item/munition_part/body/armor_insert/light, /datum/material/diamond),
	)
	for(var/list/entry in made)
		var/insert_type = entry[1]
		var/obj/item/munition_part/body/armor_insert/insert = new insert_type(center)
		insert.set_material(get_munition_material(entry[2]))
		insert.forging_finished(get_munition_quality(/datum/munition_quality), 1)
		spawned += insert
	// chłodnica i magazyn łączą się z fazerem jak postawione na mapie
	for(var/obj/machinery/cooling/unit in spawned)
		unit.auto_link()
	var/mob/living/carbon/human/H = user
	var/datum/squad/alpha = GLOB.squad_manager.get_squad("Alpha")
	if(istype(H) && alpha && H.squad != alpha)
		if(H.squad)
			H.squad.remove_member(H)
		alpha.add_member(H)
