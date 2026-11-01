//Not to be confused with /obj/item/reagent_containers/food/drinks/bottle

/obj/item/reagent_containers/glass/bottle
	name = "butelka"
	desc = "Mała butelka."
	icon_state = "bottle"
	item_state = "atoxinbottle"
	possible_transfer_amounts = list(5,10,15,25,30)
	volume = 30
	fill_icon_thresholds = list(1, 20, 40, 60, 80, 100) //AQUILA EDIT - Paradise fill states

/obj/item/reagent_containers/glass/bottle/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_icon()

/obj/item/reagent_containers/glass/bottle/epinephrine
	name = "butelka: epinefryna"
	label_name = "epinephrine"
	desc = "Mała butelka. Zawiera epinefrynę – służy do stabilizowania pacjentów."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30)

/obj/item/reagent_containers/glass/bottle/tricordrazine
	name = "butelka: trikordrazyna"
	label_name = "tricordrazine"
	desc = "Mała butelka trikordrazyny. Wspomaga powrót pacjenta do zdrowia."
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 30)

/obj/item/reagent_containers/glass/bottle/spaceacillin
	name = "butelka: spacyklina"
	label_name = "spaceacillin"
	desc = "Mała butelka spacykliny. Leczy niektóre choroby."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 30)

/obj/item/reagent_containers/glass/bottle/antitoxin
	name = "butelka: antytoksyna"
	label_name = "antitoxin"
	desc = "Mała butelka antytoksyny. Leczy uszkodzenia od toksyn."
	list_reagents = list(/datum/reagent/medicine/antitoxin = 30)

/obj/item/reagent_containers/glass/bottle/toxin/mutagen
	name = "butelka: mutagen"
	label_name = "mutagen toxin"
	desc = "Mała butelka toksycznego mutagenu. Nie pić, może wywołać nieprzewidywalne mutacje."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/toxin
	name = "butelka: toksyna"
	label_name = "toxin"
	desc = "Mała butelka toksyn. Nie pić, to trucizna."
	list_reagents = list(/datum/reagent/toxin = 30)

/obj/item/reagent_containers/glass/bottle/cyanide
	name = "butelka: cyjanek"
	label_name = "cyanide"
	desc = "Mała butelka cyjanku. Gorzkie migdały?"
	list_reagents = list(/datum/reagent/toxin/cyanide = 30)

/obj/item/reagent_containers/glass/bottle/spewium
	name = "butelka: rzygium"
	label_name = "spewium"
	desc = "Mała butelka rzygium."
	list_reagents = list(/datum/reagent/toxin/spewium = 30)

/obj/item/reagent_containers/glass/bottle/morphine
	name = "butelka: morfina"
	label_name = "morphine"
	desc = "Mała butelka morfiny."
	icon = 'icons/obj/chemical.dmi'
	list_reagents = list(/datum/reagent/medicine/morphine = 30)

/obj/item/reagent_containers/glass/bottle/chloralhydrate
	name = "butelka: wodzian chloralu"
	label_name = "chloral hydrate"
	desc = "Mała butelka wodzianu chloralu. Ulubieniec Mickeya!"
	icon_state = "bottle20"
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 30)

/obj/item/reagent_containers/glass/bottle/mannitol
	name = "butelka: mannitol"
	label_name = "mannitol"
	desc = "Mała butelka mannitolu. Przydaje się przy leczeniu uszkodzeń mózgu."
	list_reagents = list(/datum/reagent/medicine/mannitol = 30)

/obj/item/reagent_containers/glass/bottle/charcoal
	name = "butelka: węgiel aktywowany"
	label_name = "charcoal"
	desc = "Mała butelka węgla aktywowanego, który usuwa z krwiobiegu toksyny i inne chemikalia."
	list_reagents = list(/datum/reagent/medicine/charcoal = 30)

/obj/item/reagent_containers/glass/bottle/mutagen
	name = "butelka: niestabilny mutagen"
	label_name = "unstable mutagen"
	desc = "Mała butelka niestabilnego mutagenu. Losowo zmienia strukturę DNA każdego, kto się z nim zetknie."
	list_reagents = list(/datum/reagent/toxin/mutagen = 30)

/obj/item/reagent_containers/glass/bottle/plasma
	name = "butelka: ciekła plazma"
	label_name = "liquid plasma"
	desc = "Mała butelka ciekłej plazmy. Skrajnie toksyczna, reaguje z mikroorganizmami we krwi."
	list_reagents = list(/datum/reagent/toxin/plasma = 30)

/obj/item/reagent_containers/glass/bottle/synaptizine
	name = "butelka: synaptizyna"
	label_name = "synaptizine"
	desc = "Mała butelka synaptizyny."
	list_reagents = list(/datum/reagent/medicine/synaptizine = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "butelka: formaldehyd"
	label_name = "formaldehyde"
	desc = "Mała butelka formaldehydu."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/cryostylane
	name = "butelka: kriostylan"
	label_name = "cryostylane"
	desc = "Mała butelka kriostylanu. Jest zimna w dotyku."
	list_reagents = list(/datum/reagent/cryostylane = 30)

/obj/item/reagent_containers/glass/bottle/ammonia
	name = "butelka: amoniak"
	label_name = "ammonia"
	desc = "Mała butelka amoniaku."
	list_reagents = list(/datum/reagent/ammonia = 30)

/obj/item/reagent_containers/glass/bottle/diethylamine
	name = "butelka: dietyloamina"
	label_name = "diethylamine"
	desc = "Mała butelka dietyloaminy."
	list_reagents = list(/datum/reagent/diethylamine = 30)

/obj/item/reagent_containers/glass/bottle/facid
	name = "butelka: kwas fluorosulfonowy"
	label_name = "Fluorosulfuric Acid"
	desc = "Mała butelka. Zawiera niewielką ilość kwasu fluorosulfonowego."
	list_reagents = list(/datum/reagent/toxin/acid/fluacid = 30)

/obj/item/reagent_containers/glass/bottle/adminordrazine
	name = "butelka: adminordrazyna"
	label_name = "Adminordrazine"
	desc = "Mała butelka. Zawiera płynną esencję bogów."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/medicine/adminordrazine = 30)

/obj/item/reagent_containers/glass/bottle/viralbase
	name = "butelka: bardzo silna baza wirusowa"
	label_name = "Highly potent Viral Base"
	desc = "Mała butelka. Zawiera śladową ilość odkrytej przez naukowców substancji, z której po wystawieniu na uran da się stworzyć niezwykle zaawansowane choroby."
	list_reagents = list(/datum/reagent/consumable/virus_food/viralbase = 1)

/obj/item/reagent_containers/glass/bottle/capsaicin
	name = "butelka: olejek kapsaicynowy"
	label_name = "Capsaicin"
	desc = "Mała butelka. Zawiera ostry sos."
	list_reagents = list(/datum/reagent/consumable/capsaicin = 30)

/obj/item/reagent_containers/glass/bottle/frostoil
	name = "butelka: olej mroźny"
	label_name = "Frost Oil"
	desc = "Mała butelka. Zawiera lodowy sos."
	list_reagents = list(/datum/reagent/consumable/frostoil = 30)

/obj/item/reagent_containers/glass/bottle/traitor
	name = "butelka Syndykatu"
	label_name = "syndicate"
	desc = "Mała butelka. Zawiera losową paskudną substancję."
	icon = 'icons/obj/chemical.dmi'
	var/extra_reagent = null

/obj/item/reagent_containers/glass/bottle/traitor/Initialize(mapload)
	. = ..()
	extra_reagent = pick(/datum/reagent/toxin/polonium, /datum/reagent/toxin/histamine, /datum/reagent/toxin/formaldehyde, /datum/reagent/toxin/venom, /datum/reagent/toxin/fentanyl, /datum/reagent/toxin/cyanide)
	reagents.add_reagent(extra_reagent, 3)

/obj/item/reagent_containers/glass/bottle/polonium
	name = "butelka: polon"
	label_name = "polonium"
	desc = "Mała butelka. Zawiera polon."
	list_reagents = list(/datum/reagent/toxin/polonium = 30)

/obj/item/reagent_containers/glass/bottle/magillitis
	name = "butelka: magillitis"
	label_name = "magillitis"
	desc = "Mała butelka. Zawiera surowicę znaną tylko jako „magillitis”."
	list_reagents = list(/datum/reagent/magillitis = 5)

/obj/item/reagent_containers/glass/bottle/venom
	name = "butelka: jad"
	label_name = "venom"
	desc = "Mała butelka. Zawiera jad."
	list_reagents = list(/datum/reagent/toxin/venom = 30)

/obj/item/reagent_containers/glass/bottle/fentanyl
	name = "butelka: fentanyl"
	label_name = "fentanyl"
	desc = "Mała butelka. Zawiera fentanyl."
	list_reagents = list(/datum/reagent/toxin/fentanyl = 30)

/obj/item/reagent_containers/glass/bottle/formaldehyde
	name = "butelka: formaldehyd"
	label_name = "formaldehyde"
	desc = "Mała butelka. Zawiera formaldehyd."
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)

/obj/item/reagent_containers/glass/bottle/initropidril
	name = "butelka: initropidryl"
	label_name = "initropidril"
	desc = "Mała butelka. Zawiera initropidryl."
	list_reagents = list(/datum/reagent/toxin/initropidril = 30)

/obj/item/reagent_containers/glass/bottle/pancuronium
	name = "butelka: pankuronium"
	label_name = "pancuronium"
	desc = "Mała butelka. Zawiera pankuronium."
	list_reagents = list(/datum/reagent/toxin/pancuronium = 30)

/obj/item/reagent_containers/glass/bottle/sodium_thiopental
	name = "butelka: tiopental sodu"
	label_name = "sodium thiopental"
	desc = "Mała butelka. Zawiera tiopental sodu."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 30)

/obj/item/reagent_containers/glass/bottle/coniine
	name = "butelka: koniina"
	label_name = "coniine"
	desc = "Mała butelka. Zawiera koniinę."
	list_reagents = list(/datum/reagent/toxin/coniine = 30)

/obj/item/reagent_containers/glass/bottle/curare
	name = "butelka: kurara"
	label_name = "curare"
	desc = "Mała butelka. Zawiera kurarę."
	list_reagents = list(/datum/reagent/toxin/curare = 30)

/obj/item/reagent_containers/glass/bottle/amanitin
	name = "butelka: amanityna"
	label_name = "amanitin"
	desc = "Mała butelka. Zawiera amanitynę."
	list_reagents = list(/datum/reagent/toxin/amanitin = 30)

/obj/item/reagent_containers/glass/bottle/histamine
	name = "butelka: histamina"
	label_name = "histamine"
	desc = "Mała butelka. Zawiera histaminę."
	list_reagents = list(/datum/reagent/toxin/histamine = 30)

/obj/item/reagent_containers/glass/bottle/diphenhydramine
	name = "butelka: lek przeciwhistaminowy"
	label_name = "antihistamine"
	desc = "Mała butelka difenhydraminy."
	list_reagents = list(/datum/reagent/medicine/diphenhydramine = 30)

/obj/item/reagent_containers/glass/bottle/potass_iodide
	name = "butelka: lek przeciwradiacyjny"
	label_name = "anti-radiation"
	desc = "Mała butelka jodku potasu."
	list_reagents = list(/datum/reagent/medicine/potass_iodide = 30)

/obj/item/reagent_containers/glass/bottle/salglu_solution
	name = "butelka: sól fizjologiczna z glukozą"
	label_name = "saline-glucose"
	desc = "Mała butelka soli fizjologicznej z glukozą. Przydaje się pacjentom, którym brakuje krwi."
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 30)

/obj/item/reagent_containers/glass/bottle/atropine
	name = "butelka: atropina"
	label_name = "atropine"
	desc = "Mała butelka atropiny."
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/glass/bottle/romerol
	name = "butelka: romerol"
	label_name = "romerol"
	desc = "Mała butelka romerolu. PRAWDZIWY proszek zombie."
	list_reagents = list(/datum/reagent/romerol = 30)

/obj/item/reagent_containers/glass/bottle/random_virus/minor //for mail only...yet
	name = "butelka z kulturą: słaba eksperymentalna choroba"
	label_name = "Minor experimental disease culture"
	desc = "Mała butelka. Zawiera osłabioną wersję nieprzetestowanej kultury wirusa w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/advance/random/minor

/obj/item/reagent_containers/glass/bottle/random_virus
	name = "butelka z kulturą: eksperymentalna choroba"
	label_name = "Experimental disease culture"
	desc = "Mała butelka. Zawiera nieprzetestowaną kulturę wirusa w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/advance/random

/obj/item/reagent_containers/glass/bottle/pierrot_throat
	name = "butelka z kulturą: Gardło Pierrota"
	label_name = "Pierrot's Throat culture"
	desc = "Mała butelka. Zawiera kulturę wirionów H0NI<42 w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/pierrot_throat

/obj/item/reagent_containers/glass/bottle/cold
	name = "butelka z kulturą: rinowirus"
	label_name = "Rhinovirus culture"
	desc = "Mała butelka. Zawiera kulturę rinowirusa XY w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/advance/cold

/obj/item/reagent_containers/glass/bottle/flu_virion
	name = "butelka z kulturą: wiriony grypy"
	label_name = "Flu virion culture"
	desc = "Mała butelka. Zawiera kulturę wirionów grypy H13N1 w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/advance/flu

/obj/item/reagent_containers/glass/bottle/retrovirus
	name = "butelka z kulturą: retrowirus"
	label_name = "Retrovirus culture"
	desc = "Mała butelka. Zawiera kulturę retrowirusa w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/dna_retrovirus

/obj/item/reagent_containers/glass/bottle/gbs
	name = "butelka z kulturą: GBS"
	label_name = "GBS culture"
	desc = "Mała butelka. Zawiera kulturę grawitokinetycznego dwupotencjałowego SADS+ w pożywce z syntetycznej krwi."//Or simply - General BullShit
	amount_per_transfer_from_this = 5
	spawned_disease = /datum/disease/gbs

/obj/item/reagent_containers/glass/bottle/fake_gbs
	name = "butelka z kulturą: GBS"
	label_name = "GBS culture"
	desc = "Mała butelka. Zawiera kulturę grawitokinetycznego dwupotencjałowego SADS- w pożywce z syntetycznej krwi."//Or simply - General BullShit
	spawned_disease = /datum/disease/fake_gbs

/obj/item/reagent_containers/glass/bottle/brainrot
	name = "butelka z kulturą: gnicie mózgu"
	label_name = "Brainrot culture"
	desc = "Mała butelka. Zawiera kulturę Cryptococcus Cosmosis w pożywce z syntetycznej krwi."
	icon_state = "bottle3"
	spawned_disease = /datum/disease/brainrot

/obj/item/reagent_containers/glass/bottle/magnitis
	name = "butelka z kulturą: magnitis"
	label_name = "Magnitis culture"
	desc = "Mała butelka. Zawiera niewielką dawkę Fukkos Miracos."
	spawned_disease = /datum/disease/magnitis

/obj/item/reagent_containers/glass/bottle/wizarditis
	name = "butelka z kulturą: czarodziejowica"
	label_name = "Wizarditis culture"
	desc = "Mała butelka. Zawiera próbkę Rincewindus Vulgaris."
	spawned_disease = /datum/disease/wizarditis

/obj/item/reagent_containers/glass/bottle/anxiety
	name = "butelka z kulturą: ciężki lęk"
	label_name = "Severe Anxiety culture"
	desc = "Mała butelka. Zawiera próbkę Lepidopticides."
	spawned_disease = /datum/disease/anxiety

/obj/item/reagent_containers/glass/bottle/beesease
	name = "butelka z kulturą: pszczelica"
	label_name = "Beesease culture"
	desc = "Mała butelka. Zawiera próbkę inwazyjnych Apidae."
	spawned_disease = /datum/disease/beesease

/obj/item/reagent_containers/glass/bottle/fluspanish
	name = "butelka z kulturą: grypa hiszpańska"
	label_name = "Spanish flu culture"
	desc = "Mała butelka. Zawiera próbkę Inquisitius."
	spawned_disease = /datum/disease/fluspanish

/obj/item/reagent_containers/glass/bottle/tuberculosis
	name = "butelka z kulturą: gruźlica grzybicza"
	label_name = "Fungal Tuberculosis culture"
	desc = "Mała butelka. Zawiera próbkę grzybiczego prątka gruźlicy."
	spawned_disease = /datum/disease/tuberculosis

/obj/item/reagent_containers/glass/bottle/tuberculosiscure
	name = "butelka BVAK"
	label_name = "BVAK"
	desc = "Mała butelka z zestawem odtrutek na biowirusy (BVAK)."
	list_reagents = list(/datum/reagent/medicine/atropine = 5, /datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/spaceacillin = 10)

/obj/item/reagent_containers/glass/bottle/necropolis_seed
	name = "misa krwi"
	label_name = "blood"
	desc = "Gliniana misa z zalążkiem Nekropolii zakonserwowanym we krwi. Krzepki wirolog może zdołać uwolnić jego pełen potencjał..."
	icon_state = "mortar"
	spawned_disease = /datum/disease/advance/random/necropolis

/obj/item/reagent_containers/glass/bottle/felinid
	name = "butelka z kulturą: nanokocia toksoplazmoza asymilacyjna"
	label_name = "Nano-Feline Assimilative Toxoplasmosis culture"
	desc = "Mała butelka. Zawiera próbkę nanokociej toksoplazmy w pożywce z syntetycznej krwi."
	spawned_disease = /datum/disease/transformation/felinid/contagious

/obj/item/reagent_containers/glass/bottle/advanced_felinid
	name = "butelka z kulturą: kocia histeria"
	label_name = "Feline Hysteria culture"
	desc = "Mała butelka. Zawiera próbkę niebezpiecznej eksperymentalnej choroby A.R.C."
	spawned_disease = /datum/disease/advance/feline_hysteria

//Oldstation.dmm chemical storage bottles

/obj/item/reagent_containers/glass/bottle/hydrogen
	name = "butelka: wodór"
	label_name = "hydrogen"
	list_reagents = list(/datum/reagent/hydrogen = 30)

/obj/item/reagent_containers/glass/bottle/lithium
	name = "butelka: lit"
	label_name = "lithium"
	list_reagents = list(/datum/reagent/lithium = 30)

/obj/item/reagent_containers/glass/bottle/carbon
	name = "butelka: węgiel"
	label_name = "carbon"
	list_reagents = list(/datum/reagent/carbon = 30)

/obj/item/reagent_containers/glass/bottle/nitrogen
	name = "butelka: azot"
	label_name = "nitrogen"
	list_reagents = list(/datum/reagent/nitrogen = 30)

/obj/item/reagent_containers/glass/bottle/oxygen
	name = "butelka: tlen"
	label_name = "oxygen"
	list_reagents = list(/datum/reagent/oxygen = 30)

/obj/item/reagent_containers/glass/bottle/fluorine
	name = "butelka: fluor"
	label_name = "fluorine"
	list_reagents = list(/datum/reagent/fluorine = 30)

/obj/item/reagent_containers/glass/bottle/sodium
	name = "butelka: sód"
	label_name = "sodium"
	list_reagents = list(/datum/reagent/sodium = 30)

/obj/item/reagent_containers/glass/bottle/aluminium
	name = "butelka: aluminium"
	label_name = "aluminium"
	list_reagents = list(/datum/reagent/aluminium = 30)

/obj/item/reagent_containers/glass/bottle/silicon
	name = "butelka: krzem"
	label_name = "silicon"
	list_reagents = list(/datum/reagent/silicon = 30)

/obj/item/reagent_containers/glass/bottle/phosphorus
	name = "butelka: fosfor"
	label_name = "phosphorus"
	list_reagents = list(/datum/reagent/phosphorus = 30)

/obj/item/reagent_containers/glass/bottle/sulfur
	name = "butelka: siarka"
	label_name = "sulfur"
	list_reagents = list(/datum/reagent/sulfur = 30)

/obj/item/reagent_containers/glass/bottle/chlorine
	name = "butelka: chlor"
	label_name = "chlorine"
	list_reagents = list(/datum/reagent/chlorine = 30)

/obj/item/reagent_containers/glass/bottle/potassium
	name = "butelka: potas"
	label_name = "potassium"
	list_reagents = list(/datum/reagent/potassium = 30)

/obj/item/reagent_containers/glass/bottle/iron
	name = "butelka: żelazo"
	label_name = "iron"
	list_reagents = list(/datum/reagent/iron = 30)

/obj/item/reagent_containers/glass/bottle/copper
	name = "butelka: miedź"
	label_name = "copper"
	list_reagents = list(/datum/reagent/copper = 30)

/obj/item/reagent_containers/glass/bottle/mercury
	name = "butelka: rtęć"
	label_name = "mercury"
	list_reagents = list(/datum/reagent/mercury = 30)

/obj/item/reagent_containers/glass/bottle/radium
	name = "butelka: rad"
	label_name = "radium"
	list_reagents = list(/datum/reagent/uranium/radium = 30)

/obj/item/reagent_containers/glass/bottle/water
	name = "butelka: woda"
	label_name = "water"
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/glass/bottle/ethanol
	name = "butelka: etanol"
	label_name = "ethanol"
	list_reagents = list(/datum/reagent/consumable/ethanol = 30)

/obj/item/reagent_containers/glass/bottle/sugar
	name = "butelka: cukier"
	label_name = "sugar"
	list_reagents = list(/datum/reagent/consumable/sugar = 30)

/obj/item/reagent_containers/glass/bottle/sacid
	name = "butelka: kwas siarkowy"
	label_name = "sulphuric acid"
	list_reagents = list(/datum/reagent/toxin/acid = 30)

/obj/item/reagent_containers/glass/bottle/welding_fuel
	name = "butelka: paliwo spawalnicze"
	label_name = "welding fuel"
	list_reagents = list(/datum/reagent/fuel = 30)

/obj/item/reagent_containers/glass/bottle/silver
	name = "butelka: srebro"
	label_name = "silver"
	list_reagents = list(/datum/reagent/silver = 30)

/obj/item/reagent_containers/glass/bottle/iodine
	name = "butelka: jod"
	label_name = "iodine"
	list_reagents = list(/datum/reagent/iodine = 30)

/obj/item/reagent_containers/glass/bottle/bromine
	name = "butelka: brom"
	label_name = "bromine"
	list_reagents = list(/datum/reagent/bromine = 30)

// Bottles for mail goodies.

/obj/item/reagent_containers/glass/bottle/clownstears
	name = "butelka destylowanej klauńskiej rozpaczy"
	label_name = "distilled clown misery"
	desc = "Mała butelka. Zawiera mityczny płyn, którego używają wysublimowani barmani; robi się go z nieszczęścia klaunów."
	list_reagents = list(/datum/reagent/consumable/clownstears = 30)

/obj/item/reagent_containers/glass/bottle/saltpetre
	name = "butelka: saletra"
	label_name = "saltpetre"
	desc = "Mała butelka. Zawiera saletrę."
	list_reagents = list(/datum/reagent/saltpetre = 30)

/obj/item/reagent_containers/glass/bottle/flash_powder
	name = "butelka: proszek błyskowy"
	label_name = "flash powder"
	desc = "Mała butelka. Zawiera proszek błyskowy."
	list_reagents = list(/datum/reagent/flash_powder = 30)

/obj/item/reagent_containers/glass/bottle/caramel
	name = "butelka: karmel"
	label_name = "caramel"
	desc = "Butelka skarmelizowanego cukru, czyli karmelu. Nie lizać."
	list_reagents = list(/datum/reagent/consumable/caramel = 30)

/obj/item/reagent_containers/glass/bottle/ketamine
	name = "butelka: ketamina"
	label_name = "ketamine"
	desc = "Mała butelka. Zawiera ketaminę. Po co?"
	list_reagents = list(/datum/reagent/drug/ketamine = 30)
