/datum/test_chamber_kit/pr_672_robotyka
	name = "Robotyka: protezy, syntetycy, cyberpsychoza i implanty"
	pr = "aq33/AquilaStation#672"
	description = "1) Protezy: przyszyj robotyczną rękę operacją – nie słucha, dopóki nie skalibrujesz jej multitoolem albo hemostatem (bez trybu walki, celując w rękę). Kołek i protezę kinetyczną przyłóż do kikuta (3 s); z kinetyczną nie strzelisz. Zaawansowana ręka bije mocniej. \
	2) Marki: włóż protezę do maszyny do dopasowania augmentacji, wybierz styl i obejrzyj ją (marka i cechy). Przy otwartej klapie multitool daje operację zmiany marki. Vey-Med na manekinie wygląda jak skóra, z bliska widać protezę, po uszkodzeniu wyłazi metal. \
	3) EMP: granat EMP przy manekinie z protezami – proteza iskrzy, obrywa i na chwilę przestaje działać, ciało nie pada na 20 s. \
	4) Rany robotyczne: bij protezę klubem i tnij nożem – luźne śruby/wgniecenia/zgniecione serwa i przewody; naprawiaj kluczem, spawarką, śrubokrętem, kablem albo gaśnicą (skaner pokazuje, czym). \
	5) IPC: manekin IPC w próżni (na zewnątrz albo w pomieszczeniu bez powietrza) grzeje się (alert „Przegrzanie”, potem oparzenia); wymień mu chłodzenie na cieczą i sprawdź, że w próżni nadąża. Akcja chłodzenia pokazuje nagrzanie. \
	6) Zabij IPC, napraw spawarką i kablem – nie wstaje sam; klucz resetu (bez trybu walki) albo operacja reaktywacji multitoolem przy otwartej klatce go budzi. Overloadery: wpnij IPC i patrz na komunikaty, trzy naraz robią awarię, klucz resetu je czyści. \
	7) Cyberpsychoza: załóż sobie kilka protez i implantów (autochirurg) i poczekaj na objawy w czacie; neuratreksat w strzykawce je wstrzymuje. \
	8) Implanty: zakłócacz augmentów (implanter) blokuje implant narzędziowy w ręce; jeden implant skoku w nodze daje akcję Skok nad dziurą; wzmocnienie stawów. \
	9) Serce woltaiczne z rdzeniem: wszczep (w ręce, 5 s), zbij się do stanu krytycznego – 30 s na nogach. Psychoskop: zeskanuj karpia, zapisz neuromod w powłoce i wstrzyknij sobie. \
	10) Kreator postaci: sekcja z wyborem rąk, nóg i organów (marki, kinetyczna, zaawansowana, organy cybernetyczne); po wejściu do rundy postać ma te protezy i organy, bez kalibracji. Sprawdź w combat mode i w starym trybie intencji (narzędzia leczą bez trybu walki / na intencji pomocy)."
	items = list(
		/obj/item/bodypart/r_arm/robot = 2,
		/obj/item/bodypart/l_arm/robot/aq_advanced = 1,
		/obj/item/bodypart/l_arm/aq_kinetic = 1,
		/obj/item/bodypart/l_leg/aq_peg = 1,
		/obj/item/bodypart/l_leg/robot = 1,
		/obj/machinery/aug_manipulator = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/extinguisher = 1,
		/obj/item/hemostat = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/scalpel = 1,
		/obj/item/grenade/empgrenade = 2,
		/obj/item/melee/classic_baton = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/organ/aq_cooling/liquid = 1,
		/obj/item/organ/aq_cooling/passive = 1,
		/obj/item/storage/box/aq_overloaders = 1,
		/obj/item/aq_synth_reset_key = 1,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/reagent_containers/glass/bottle/aq_neuratrextate = 1,
		/obj/item/implanter/aq_anti_augment = 1,
		/obj/item/autosurgeon/aq_robotyka/toolset = 1,
		/obj/item/autosurgeon/aq_robotyka/jumpboots = 1,
		/obj/item/autosurgeon/aq_robotyka/bracing = 1,
		/obj/item/organ/heart/cybernetic/aq_anomalock/prebuilt = 1,
		/obj/item/aq_psychoscope = 1,
		/obj/item/aq_neuromod_shell = 2,
		/mob/living/basic/carp = 1,
		/mob/living/carbon/human/species/ipc = 2,
		/mob/living/carbon/human = 1,
	)

/obj/item/reagent_containers/glass/bottle/aq_neuratrextate
	name = "butelka neuratreksatu"
	desc = "Mała butelka z neuratreksatem, lekiem na cyberpsychozę."
	list_reagents = list(/datum/reagent/medicine/aq_neuratrextate = 30)

/obj/item/autosurgeon/aq_robotyka
	uses = 1

/obj/item/autosurgeon/aq_robotyka/toolset
	starting_organ = list(/obj/item/organ/cyberimp/arm/toolset)

/obj/item/autosurgeon/aq_robotyka/jumpboots
	starting_organ = list(/obj/item/organ/cyberimp/leg/aq_jumpboots)

/obj/item/autosurgeon/aq_robotyka/bracing
	starting_organ = list(/obj/item/organ/cyberimp/chest/aq_bracing)

