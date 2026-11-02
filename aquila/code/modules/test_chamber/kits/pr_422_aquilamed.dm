// aq33/AquilaStation#422 - AquilaMed: krwawienie, grupy krwi, autopsja, odzyskana załoga i inne

/datum/test_chamber_kit/pr_422
	name = "PR 422: krwawienie i kolory krwi"
	pr = "aq33/AquilaStation#422"
	description = "Człowiek, jaszczur, eteryk i IPC krwawią od startu (niewielkie cięcie, które samo słabnie po ok. 2 minutach; żeby je odnowić, tnij pacjenta nożem w trybie walki, a krew uzupełnisz workiem 0-). \
	1) Obejrzyj plamy i ślady ciągnięcia → oczekiwane: kolor krwi zależy od rasy (jaszczur turkusowa, eteryk świecąca, IPC jasnoszare chłodziwo). \
	2) Kliknij alert krwawienia → oczekiwane: uciskasz ranę (zajmuje rękę), krwawienie słabnie. Bandaż → oczekiwane: z krwawienia robi się opatrunek; zapalniczka i laser przypalają ranę. \
	3) IPC cieknie → oczekiwane: załatasz go spawarką. Medbot → oczekiwane: bandażuje krwawiących. \
	4) Tnij nożem człowieka bez pancerza, potem w kamizelce → oczekiwane: pancerz zmniejsza krwawienie. Analizator i stetoskop → oczekiwane: pokazują tempo krwawienia. \
	5) Stół operacyjny + serweta, menu radialne: kauteryzacja krwawienia → oczekiwane: krwawienie ustaje. \
	6) Płukanie żołądka na człowieku (pacjenci mają w organizmie 30u wody) → oczekiwane: wymioty i usunięcie 2/3 substancji (zostaje ok. 10u). Negatyw: u IPC operacja płukania żołądka nie jest dostępna (tylko organiczni). \
	7) Rekalibracja tożsamości IPC → oczekiwane: karta ID w otwartej klatce zmienia imię IPC. \
	8) Wyjęte serce → oczekiwane: krew przestaje się odnawiać. \
	Kroplówka, monitor, autopsja i odzyskana załoga - zestaw PR 457."
	items = list(
		/mob/living/carbon/human = 1,
		/mob/living/carbon/human/species/lizard = 1,
		/mob/living/carbon/human/species/ethereal = 1,
		/mob/living/carbon/human/species/ipc = 1,
		/obj/item/stack/medical/bandage = 1,
		/obj/item/lighter = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/clothing/neck/stethoscope = 1,
		/mob/living/simple_animal/bot/medbot = 1,
		/obj/structure/table/optable = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/card/id = 1,
		/obj/item/reagent_containers/blood/OMinus = 1,
	)

/datum/test_chamber_kit/pr_422/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/patient in spawned)
		patient.add_bleeding(BLEED_CUT)
		// Coś w organizmie, żeby płukanie żołądka miało co usuwać
		patient.reagents?.add_reagent(/datum/reagent/water, 30)
