// Medycyna cz. 3: chirurgia z tg, rany kłute, czaszka, oko, blizny, kule w ciele, sprzęt z tg

/datum/test_chamber_kit/pr_530_chirurgia
	name = "PR 530: chirurgia z tg"
	pr = "aq33/AquilaStation#530"
	description = "Pacjent leży na stole, obok komputer operacyjny. Serwety na pacjencie (wybrana strefa) przygotowują ją do operacji. \
	Potem narzędzie w ręce pokazuje w menu tylko pasujące operacje: skalpel (nacięcie), retraktor, hemostat, piła, kauter (zamyka wszystko). \
	W klatce: wyjęcie/włożenie organu, naprawa organów, usunięcie ciał obcych (kula w klatce). Dysk prania mózgu przyłóż do komputera: okno pokazuje stan strefy i pranie mózgu po otwarciu czaszki. \
	Zaawansowany analizator pokazuje stan operowanej strefy i trwającą operację. Implant zęba na sobie: serwety na usta, połóż się, skalpel, retraktor, hemostat, wiertło, pigułka."
	items = list(
		/obj/structure/table/optable = 1,
		/obj/machinery/computer/operating = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/disk/surgery/brainwashing = 1,
		/obj/item/healthanalyzer/advanced = 1,
	)

/datum/test_chamber_kit/pr_530_chirurgia/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/table/optable/table = locate() in spawned
	var/mob/living/carbon/human/patient = new(table ? get_turf(table) : center)
	patient.real_name = "Pacjent na stole"
	patient.name = patient.real_name
	patient.set_resting(TRUE)
	var/obj/item/bullet_fragment/fragment = new(get_turf(patient))
	fragment.tryEmbed(patient.get_bodypart(BODY_ZONE_CHEST), forced = TRUE, silent = TRUE)

/datum/test_chamber_kit/pr_530_rany
	name = "PR 530: rany, kule i sprzęt"
	pr = "aq33/AquilaStation#530"
	description = "Pacjent ma ranę postrzałową na prawej ręce, złamanie otwarte na lewej nodze i przebite oko. Rana kłuta: kauter albo zapalniczka (na kimś trzeba go chwycić agresywnie) obniża ją o stopień. \
	Złamanie: żel kostny, potem taśma chirurgiczna; analizator pokazuje postęp zrastania. Po wyleczeniu poważnej rany zostaje blizna widoczna przy oglądaniu. \
	Strzelaj z pistoletu w manekina z bliska: krople krwi, smugi, rany kłute, kula czasem zostaje w ciele (analizator: Tkwi w ciele). \
	Skaner krwi: lewy i prawy klik. Plaster: Z odrywa folię. Automat do medipenów: wlej epinefrynę, włóż pusty medipen. Worek stazy: po 5 s staza. Analizator: przycisk w prawym górnym rogu okna przełącza na tryb tekstowy."
	items = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/cautery = 1,
		/obj/item/lighter = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/bonesetter = 1,
		/obj/item/blood_scanner = 1,
		/obj/item/bodybag/stasis = 1,
		/obj/item/stack/medical/bandage = 2,
		/obj/item/reagent_containers/pill/patch/styptic = 2,
		/obj/machinery/medipen_refiller = 1,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1,
	)

/datum/test_chamber_kit/pr_530_rany/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/patient = new(center)
	patient.real_name = "Pacjent z ranami"
	patient.name = patient.real_name
	var/datum/wound/pierce/open/hole = new()
	hole.wound_source_is_projectile = TRUE
	hole.apply_wound(patient.get_bodypart(BODY_ZONE_R_ARM), silent = TRUE)
	var/datum/wound/compound = new /datum/wound/blunt/compound()
	compound.apply_wound(patient.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	patient.puncture_eye()
	for(var/obj/item/reagent_containers/hypospray/medipen/pen in spawned)
		pen.reagents.clear_reagents()
	var/mob/living/carbon/human/dummy = new(pick(turfs))
	dummy.real_name = "Manekin do strzelania"
	dummy.name = dummy.real_name
