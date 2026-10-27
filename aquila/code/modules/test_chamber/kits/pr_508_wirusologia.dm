/datum/test_chamber_kit/pr_508_wirusologia
	name = "Wirusologia disease2 z Monkestation"
	pr = "aq33/AquilaStation#508"
	description = "Pętla wirusologa: strzykawką pobierz krew od kogoś chorego, wsadź ją do izolatora i wybierz patogen — dostaniesz szalkę. \
		Szalkę wkładasz do inkubatora i karmisz ją pożywką dla wirusów (rośnie) albo wodą (maleje); odczynniki w inkubatorze sterują mutacjami \
		(plazma = siła, spaceacillin = osłabienie, żel uranowy = wytrzymałość, agar mutagenny = mutacja objawu, agar sacharozowy = częstsze objawy), \
		a „focus” mutuje objaw wybranego stopnia. Analizator wymaga szalki OTWARTEJ (otwarta szalka zaraża pomieszczenie — maska i rękawice!) \
		i dopisuje szczep do bazy. Splicer kopiuje objaw ze szalki do bufora i wkleja na inny stopień albo nagrywa na dysk GNA. \
		Centryfuga: cztery probówki, niezbalansowane masy spowalniają; z próbki krwi z przeciwciałami zrobisz szczepionkę (potrzeba ≥30% stężenia). \
		Skaner przeciwciał pokazuje wykres przeciwciał, okulary patologa — chmury patogenów i zakażonych. Ekstrapolator prawym przyciskiem \
		przełącza się w tryb sondy: na człowieku odpala minigrę symptom crackera (gotowy dysk GNA), na szalce wszczepia wariant objawu. \
		Debugowy patogen i dwa gotowce (grypa, gruźlica grzybicza) są na dyskach GNA i w szalkach. \
		Pamiętaj: gorączka powyżej ~100 °C wypala patogen, radium leczy wszystko, ale rozwala ciało, a leżenie w łóżku i spaceacillin podnoszą przeciwciała."
	items = list(
		/obj/machinery/disease2/isolator = 1,
		/obj/machinery/disease2/incubator = 1,
		/obj/machinery/disease2/centrifuge = 1,
		/obj/machinery/disease2/diseaseanalyser = 1,
		/obj/machinery/computer/diseasesplicer = 1,
		/obj/machinery/computer/records/pathology = 1,
		/obj/machinery/computer/curer = 1,
		/obj/machinery/health_scanner_floor = 1,
		/obj/item/weapon/virusdish = 2,
		/obj/item/disk/disease = 2,
		/obj/item/disk/disease/premade = 1,
		/obj/item/reagent_containers/glass/tube = 4,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/extrapolator = 1,
		/obj/item/device/antibody_scanner = 1,
		/obj/item/clothing/glasses/pathology = 1,
		/obj/item/clothing/mask/surgical = 1,
		/obj/item/clothing/gloves/color/latex = 1,
		/obj/item/food/monkeycube/mouse = 2,
		/obj/structure/reagent_dispensers/virusfood = 1,
	)

/datum/test_chamber_kit/pr_508_wirusologia/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Dwie szalki z patogenami do zabawy: jedna wyhodowana i przeanalizowana, druga świeża.
	var/list/dishes = list()
	for(var/obj/item/weapon/virusdish/dish in spawned)
		dishes += dish
	if(length(dishes) >= 1)
		var/obj/item/weapon/virusdish/grown = dishes[1]
		var/datum/disease/acute/virus/pathogen = new
		pathogen.makerandom(list(60, 80), list(40, 70), list(ANTIGEN_COMMON = 1, ANTIGEN_RARE = 1), list(EFFECT_DANGER_ANNOYING = 2, EFFECT_DANGER_HINDRANCE = 1), user)
		pathogen.origin = "Komora testowa"
		grown.contained_virus = pathogen
		grown.growth = 100
		grown.analysed = TRUE
		grown.name = "szalka ([pathogen.name(TRUE)])"
		grown.update_icon()
	if(length(dishes) >= 2)
		var/obj/item/weapon/virusdish/fresh = dishes[2]
		var/datum/disease/acute/bacteria/germ = new
		germ.makerandom(list(30, 60), list(20, 50), list(ANTIGEN_BLOOD = 1, ANTIGEN_COMMON = 2), list(EFFECT_DANGER_FLAVOR = 2, EFFECT_DANGER_ANNOYING = 1), user)
		germ.origin = "Komora testowa"
		fresh.contained_virus = germ
		fresh.growth = 20
		fresh.update_icon()
