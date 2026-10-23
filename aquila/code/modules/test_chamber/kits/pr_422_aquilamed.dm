// aq33/AquilaStation#422 - AquilaMed: krwawienie, grupy krwi, autopsja, odzyskana załoga i inne

/datum/test_chamber_kit/pr_422
	name = "PR 422: krwawienie i kolory krwi"
	pr = "aq33/AquilaStation#422"
	description = "Człowiek, jaszczur, eteryk i IPC już krwawią. Plamy i ślady ciągnięcia mają kolor krwi (jaszczur turkusowa, eteryk świecąca, IPC jasnoszare chłodziwo). \
	Krwawiący ma alert - kliknięty uciska ranę (zajmuje rękę). Gaza robi z krwawienia opatrunek, zapalniczka i laser przypalają ranę. IPC cieknie - załataj spawarką. \
	Medbot ma bandażować krwawiących. Nóż w kamizelce i bez niej: pancerz zmniejsza krwawienie. Analizator i stetoskop pokazują tempo krwawienia. \
	Operacje z menu radialnego (serweta): kauteryzacja krwawienia, płukanie żołądka (wymioty, usunięcie 2/3 substancji), rekalibracja tożsamości IPC (karta ID w otwartej klatce zmienia imię). \
	Wyjęte serce zatrzymuje odnawianie krwi. Kroplówka, monitor, autopsja i odzyskana załoga - zestaw PR 457."
	items = list(
		/mob/living/carbon/human = 1,
		/mob/living/carbon/human/species/lizard = 1,
		/mob/living/carbon/human/species/ethereal = 1,
		/mob/living/carbon/human/species/ipc = 1,
		/obj/item/stack/medical/gauze = 1,
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
