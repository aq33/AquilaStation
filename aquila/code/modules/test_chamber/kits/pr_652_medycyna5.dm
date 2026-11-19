/datum/test_chamber_kit/pr_652
	name = "PR 652: AquilaMed 5: szyny, leki, zarazki, krążenie, hipotermia, nowe narządy, zęby, implanty, pająk-robot"
	pr = "aq33/AquilaStation#652"
	description = "Obok stoją „Pacjent” (zdrowy), „Ranny” (złamana noga, przerwany nerw prawej ręki) i pusty pająk-robot.<br>1) Szyna na złamaną nogę „Rannego” (skaner: utykanie spada), kula w rękę, młotek neurologiczny na prawą rękę (brak odruchu).<br>2) Krążenie: zatrzymaj „Rannemu” serce (emag z zestawu części 2 na defibrylator, potem defibrylator w trybie walki). Stetoskop i skaner: brak pulsu; RKO kliknięciem pomocy w klatkę; defibrylator z zabezpieczeniem.<br>3) Narządy „Pacjenta”: mocne ciosy w brzuch i skaner (uszkodzenie narządów brzucha), zszycie narządów brzucha, cewnik. Wyjmij krtań: „Pacjent” nie mówi.<br>4) Nerw: operacja zszycia nerwu na ręce „Rannego”.<br>5) Zęby: młotek w usta „Pacjenta” (cel: usta), seplenienie; wstawienie zęba (sztuczne zęby z zestawu).<br>6) Skafander: bij się w tors, aż się zatnie; ktoś inny wycina go spawarką (bez trybu walki, cel: tors), taśma zakleja.<br>7) Stos korowy: wyjmij go i spróbuj sklonować (konsola odmawia). Implanty: podskórny pancerz, wzmacniacz celowania.<br>8) Pająk-robot: włóż MMI z mózgiem, wejdź do wentylacji.<br>Kliknięcia narzędziami sprawdź w obu trybach sterowania (combat mode i intencje)."
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
		/obj/item/organ/cortical_stack = 1,
		/obj/item/organ/cyberimp/chest/aq_subdermal_armor = 1,
		/obj/item/organ/cyberimp/brain/aq_aim = 1,
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

	new /mob/living/simple_animal/aq_spiderbot(drop)
