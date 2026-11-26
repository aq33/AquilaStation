/datum/test_chamber_kit/pr_717_reagenty
	name = "Chemia: 45 nowych reagentów"
	pr = "aq33/AquilaStation#717"
	description = "Skrzynia ma butelkę każdego nowego reagentu (po 30 j.), są też zlewki, strzykawki, spryskiwacz, żel kostny, taśma i dwa ciała. 1) Medycyna: złam nogę (pałka), nałóż żel i taśmę, wstrzyknij Osteodaksyn – skaner pokazuje szybszy zrost; bez żelu i taśmy lek nic nie zrasta. Potnij kogoś nożem, wstrzyknij Szybkie krzepnięcie – krew przestaje ubywać, po zejściu leku rana krwawi dalej. Sangwiryt i heparyna znoszą się. Perydaksyna leczy narządy tylko do lekkiego uszkodzenia. Sole trzeźwiące (spryskiwacz) budzą śpiącego, ale nie kogoś w stanie krytycznym. Ignizol grzeje i się pali. Dermagen polany na skórę usuwa blizny. 2) Nałogi: zapal kilka papierosów albo wypij dużo alkoholu, potem Bupropion / Naltreksan / Aminazyna / Addyktol. 3) Narzędzia: superklej na przedmiot w ręce (nie da się upuścić, aceton odkleja), na krwawiącą ranę (krwawienie staje, ból rośnie). Krzemian na okno, beton na podłogę i kratę, dekonstruktor na przedmiot, trawo-gro i serum genezy na podłogę, azotan srebra na przedmiot z odciskami (obejrzyj go), odciskowe nanoboty z krwią innej osoby (skaner detektywa). Sól święcona na podłodze przed upiorem albo demonem cieni. 4) Sabotaż i leki: Obskurytol obok lamp, Fulguracyna na IPC albo cyborga, Kardoks na kafelek z plazmą, Malaksytol / Enzym wzmacniający z innym lekiem, tabletka z Polimerem glukozy, Kordiolis z toksyną. 5) Umysł i pirotechnika: Amnestyki, Lokutogen (powiedz zdanie przy zlewce, potem wypij), Solipsizyna, Enzym bólu (morfina go zdejmuje), Randonium, Trijodek azotu rozlany (po 30 s wybucha od kroku), Fotofosfid rozlany w świetle, Argina w zamrażarce. SDGF: 50 j. w człowieku z umysłem, po ok. 3 min obok wyrasta kopia dla ducha, drugi raz w tej rundzie już tylko leczy."
	items = list(
		/obj/structure/closet/crate/aq_pr717_reagenty = 1,
		/obj/item/reagent_containers/glass/beaker/large = 3,
		/obj/item/reagent_containers/syringe = 4,
		/obj/item/reagent_containers/dropper = 1,
		/obj/item/reagent_containers/spray = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/melee/classic_baton = 1,
		/obj/item/kitchen/knife = 1,
		/mob/living/carbon/human = 2,
	)

/obj/structure/closet/crate/aq_pr717_reagenty
	name = "skrzynia z nowymi reagentami"

/obj/structure/closet/crate/aq_pr717_reagenty/PopulateContents()
	var/static/list/kinds = list(
		/datum/reagent/medicine/osteodaxon, /datum/reagent/medicine/sanguirite, /datum/reagent/medicine/quickclot,
		/datum/reagent/medicine/peridaxon, /datum/reagent/medicine/bupropion, /datum/reagent/medicine/naltrexone,
		/datum/reagent/medicine/aminazine, /datum/reagent/medicine/addictol, /datum/reagent/medicine/ammonium_bicarbonate,
		/datum/reagent/medicine/ignisol, /datum/reagent/toxin/metabolism_inhibitor, /datum/reagent/medicine/equalizone,
		/datum/reagent/toxin/microplastics, /datum/reagent/medicine/dermagen,
		/datum/reagent/superglue, /datum/reagent/silicate, /datum/reagent/concrete, /datum/reagent/matter_deconstructor,
		/datum/reagent/grassgro, /datum/reagent/genesis, /datum/reagent/silver_nitrate, /datum/reagent/fingerprint_nanites,
		/datum/reagent/holy_salt,
		/datum/reagent/obscuritol, /datum/reagent/toxin/radiomagnetic_disruptor, /datum/reagent/fulguracin,
		/datum/reagent/toxin/cardox, /datum/reagent/malaxitol, /datum/reagent/medicine/booster_enzyme,
		/datum/reagent/consumable/glucose_polymer, /datum/reagent/medicine/cordiolis_hepatico,
		/datum/reagent/aq_amnestics, /datum/reagent/aq_locutogen, /datum/reagent/aq_solipsizine, /datum/reagent/aq_pain_enzyme,
		/datum/reagent/toxin/aq_brain_hurting_juice, /datum/reagent/toxin/aq_hyperpsy, /datum/reagent/aq_randonium,
		/datum/reagent/toxin/aq_splitting_poison, /datum/reagent/aq_energetic_nanobots, /datum/reagent/aq_sdgf,
		/datum/reagent/aq_nitrogen_triiodide, /datum/reagent/aq_photophosphide, /datum/reagent/aq_argine,
		/datum/reagent/aq_punctualite, /datum/reagent/medicine/morphine, /datum/reagent/acetone,
	)
	for(var/datum/reagent/kind as anything in kinds)
		// SDGF działa od 50 j., a butelka mieści 30
		var/obj/item/reagent_containers/container = kind == /datum/reagent/aq_sdgf ? new /obj/item/reagent_containers/glass/beaker/large(src) : new /obj/item/reagent_containers/glass/bottle(src)
		container.reagents.add_reagent(kind, kind == /datum/reagent/aq_sdgf ? 60 : 30)
		container.name = "butelka: [initial(kind.name)]"
