/datum/test_chamber_kit/pr_652
	name = "PR 652: AquilaMed 5: szyny, leki, zarazki, krążenie, hipotermia, nowe narządy, zęby, implanty, pająk-robot"
	pr = "aq33/AquilaStation#652"
	description = "Obok stoją „Pacjent” (zdrowy), „Ranny” (złamana noga, rana cięta ręki z przerwanym nerwem, zatrzymane serce) i pusty pająk-robot. \
	1) Wyposażenie: szyna na złamaną nogę „Rannego” (lepsza od bandaża, nie utyka tak mocno), kula w rękę, nożyce, nanopasta na protezę, młotek neurologiczny na rękę (brak odruchu: przerwany nerw), pas ratownika z medipenami, kroplówka z rur, inhalator. \
	2) Krążenie: stetoskop na „Rannym” (brak tętna), RKO, defibrylator. Skaner: puls, niedotlenienie mózgu. \
	3) Nowe narządy: skaner na „Pacjencie” po mocnych ciosach w brzuch (pęknięta śledziona, krwotok wewnętrzny), operacje zszycia śledziony, jelit, pęcherza, cewnik. Wyjmij krtań: „Pacjent” nie mówi; wsadź ją komuś innemu: mówi głosem pierwszego. Operacja zmiany głosu. \
	4) Nerw: operacja zszycia nerwu na ręce „Rannego”; ręka wraca do czucia. \
	5) Zęby: uderz „Pacjenta” młotkiem w usta (cel: usta): wypadają zęby, seplenienie przy mowie. Wyrwij i wstaw ząb (sztuczne zęby z zestawu). \
	6) Głowa i mózg: przeszczep mózgu albo przyszycie głowy daje bezwładne ręce i nogi, operacja połączenia pnia mózgu na otwartej czaszce je przywraca, potem 5 minut osłabienia. \
	7) Skafander: załóż skafander i bij się w tors: czasem się zatnie. Ktoś inny wycina go spawarką (bez trybu walki, cel: tors), taśma zakleja rozcięcie. \
	8) Zwłoki: zabij kogoś, wstrzyknij 5 j. rezadonu, zrób z niego wysuszone ciało (VV) i operacja odbudowy tkanek; balsamowanie formaldehydem z zestawu. \
	9) Stos korowy: wyjmij go z kogoś i spróbuj sklonować (konsola odmawia). Implanty z zestawu: podskórny pancerz, wzmacniacz celowania, ulepszenia narządów z Eris (na wyjętym narządzie), rusztowanie z organoidami (teratoma, nożem). \
	10) Pająk-robot: włóż MMI z mózgiem, chodź po wentylacji. \
	Sprawdź kliknięcia narzędziami w obu trybach sterowania (combat mode i intencje)."
	items = list(
		/obj/item/stack/medical/splint = 2,
		/obj/item/cane/crutch = 1,
		/obj/item/shears = 1,
		/obj/item/stack/medical/nanopaste = 1,
		/obj/item/reflexhammer = 1,
		/obj/item/storage/belt/medical/paramedic = 1,
		/obj/item/clothing/neck/stethoscope = 1,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/catheter = 2,
		/obj/item/stack/teeth/prosthetic/five = 1,
		/obj/item/clothing/suit/space = 1,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/stack/sticky_tape = 1,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 1,
		/obj/item/reagent_containers/glass/beaker/rezadone_kit = 1,
		/obj/item/organ/cortical_stack = 1,
		/obj/item/organ/cyberimp/chest/aq_subdermal_armor = 1,
		/obj/item/organ/cyberimp/brain/aq_aim = 1,
		/obj/item/aq_organ_mod/durable = 1,
		/obj/item/aq_organ_mod/stem_cells = 1,
		/obj/item/organ/aq_aberrant = 1,
		/obj/item/aq_teratoma = 3,
		/obj/item/mmi = 1,
	)

/datum/test_chamber_kit/pr_652/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	var/mob/living/carbon/human/patient = new(drop)
	patient.real_name = "Pacjent"
	patient.name = patient.real_name

	var/mob/living/carbon/human/injured = new(drop)
	injured.real_name = "Ranny"
	injured.name = injured.real_name
	var/datum/wound/blunt/fracture/fracture = new()
	fracture.apply_wound(injured.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	var/obj/item/bodypart/arm = injured.get_bodypart(BODY_ZONE_R_ARM)
	arm.aq_cut_nerve()
	var/obj/item/organ/heart/heart = injured.getorganslot(ORGAN_SLOT_HEART)
	heart?.Stop()

	new /mob/living/simple_animal/aq_spiderbot(drop)

/obj/item/reagent_containers/glass/beaker/rezadone_kit
	list_reagents = list(/datum/reagent/medicine/rezadone = 30)
