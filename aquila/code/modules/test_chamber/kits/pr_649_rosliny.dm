// Botanika: rośliny przeniesione z innych kodów, mutacje od odczynnika, kompostownik, kapsuła ksenoflory, nasiona z artefaktów

/datum/test_chamber_kit/pr_rosliny_uprawy
	name = "Botanika: nowe rośliny i mutacje od odczynnika"
	pr = "aq33/AquilaStation#649"
	description = "Zestaw: tace z podłożem, łopatka, skaner roślin, nasiona z każdej grupy, zlewki z odczynnikami do mutacji. 1) Posadź nasiona (podłoże widać na paczce) i polej wodą: orzeszki, groch, róża, brzoskwinia, mięta, zioło lecznicze asomna. Plony mają polskie nazwy i ikony; skaner pokazuje części rośliny. 2) Mutacje od odczynnika: posadź pomarańczę i wlej do tacy krew (krwista pomarańcza) albo żelazo (mechaniczna pomarańcza). Mutacja przychodzi losowo w ciągu około minuty i zużywa odczynnik. Stare odmiany (krwisty pomidor, złote jabłko) wychodzą już tylko z pieca. 3) Piec radiacyjny: groch → śmiejący się groch. 4) Automat MegaSeed ma nowe paczki, po zhakowaniu też owoc latarniowy, tojad i kokę."
	items = list(
		/obj/item/plant_tray = 4,
		/obj/item/substrate_bag/dirt = 2,
		/obj/item/substrate_bag/sand = 1,
		/obj/item/shovel/spade = 1,
		/obj/item/plant_scanner = 1,
		/obj/item/plant_seeds/preset/peanut = 1,
		/obj/item/plant_seeds/preset/peas = 1,
		/obj/item/plant_seeds/preset/rose = 1,
		/obj/item/plant_seeds/preset/orange = 2,
		/obj/item/reagent_containers/glass/beaker/large = 3,
	)

/datum/test_chamber_kit/pr_rosliny_uprawy/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/fills = list(list(/datum/reagent/blood, "krew"), list(/datum/reagent/iron, "żelazo"), list(/datum/reagent/consumable/milk, "mleko"))
	var/index = 0
	for(var/obj/item/reagent_containers/glass/beaker/large/beaker in spawned)
		index++
		if(index > length(fills))
			break
		beaker.reagents.add_reagent(fills[index][1], 50)
		beaker.name = "zlewka: [fills[index][2]]"
	for(var/seed_type in list(/obj/item/plant_seeds/preset/peach, /obj/item/plant_seeds/preset/mint, /obj/item/plant_seeds/preset/asomna))
		if(ispath(seed_type))
			spawned += new seed_type(center)

/datum/test_chamber_kit/pr_rosliny_kompost
	name = "Botanika: kompostownik"
	pr = "aq33/AquilaStation#649"
	description = "1) Kompostownik: wrzuć plony albo jedzenie (też z torby), co 20 s rozkłada do 5 rzeczy na nawóz E-Z-Nutrient; zlewką nalewasz kompost, pustą ręką wygrzebujesz worek ziemi (40 j. kompostu). Łom rozbiera skrzynię. Kompostownik jest też w craftingu z 10 desek."
	items = list(
		/obj/structure/compost_bin = 1,
		/obj/item/food/grown/tomato = 6,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/crowbar = 1,
	)

/datum/test_chamber_kit/pr_rosliny_ksenoflora
	name = "Botanika: kapsuła ksenoflory i nasiona z artefaktów"
	pr = "aq33/AquilaStation#649"
	description = "1) Kapsuła ksenoflory 2×2: rury gazowe na lewym dolnym kaflu (z południa wejście wymaganych gazów, na zachód wyjście reszty). Podłącz kanister azotu, zamknij kopułę, ustaw temperaturę w oknie i posadź miotlarza: rośnie tylko w kapsule z azotem i w swojej temperaturze. Sześciomelon potrzebuje bromu w zbiorniku kapsuły i mrozu. W zwykłej tacce ksenoflory nie da się posadzić. 2) Artefakt z cechą „Seeding”: aktywuj (ściśnij w ręce), wyrzuca nasiono obcej rośliny (amauri, gelthi, podglądacz, lotos świetlny, ludożerca…), potem 90 s przerwy. Sprawdź podglądacza (obraca się do ciebie), ludożercę (gryzie przy dotknięciu) i pełzacza (zasiewa się w pustej tacy obok)."
	items = list(
		/obj/machinery/atmospherics/components/binary/xenoflora_pod = 1,
		/obj/machinery/portable_atmospherics/canister/nitrogen = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/broombush = 2,
		/obj/item/plant_seeds/preset/alien/xenoflora/cubomelon = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/plasma_cabbage = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/breather = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/adhomai/fjylozyn = 1,
		/obj/item/plant_seeds/preset/alien/xenoflora/rasy/merlin_tears = 1,
		/obj/machinery/portable_atmospherics/canister/carbon_dioxide = 1,
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/item/wrench = 1,
		/obj/item/shovel/spade = 1,
		/obj/item/plant_tray = 2,
		/obj/item/substrate_bag/dirt = 2,
		/obj/item/xenoartifact/no_traits = 1,
	)

/datum/test_chamber_kit/pr_rosliny_ksenoflora/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/xenoartifact/no_traits/artifact in spawned)
		artifact.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material/bluespace, list(/datum/xenoartifact_trait/activator/sturdy, /datum/xenoartifact_trait/major/seeding), TRUE, FALSE, FALSE)

/datum/test_chamber_kit/pr_rosliny_planety
	name = "Botanika: dzika flora planet"
	pr = "aq33/AquilaStation#649"
	description = "Dzikie rośliny z każdego biomu planet (lód, księżyc, woda, lawa, dżungla, piaski, pustkowia). 1) Kliknij roślinę pustą ręką: zbierasz plon, roślina po czasie odrasta. 2) Plon włóż do siewnika, nasiona posadź w tacy. 3) Na planecie te rośliny rosną w swoich biomach; ruiny planet mają czasem 1-2 paczki obcych nasion. Kaktus popielny w piecu radiacyjnym może dać gwiaździsty kaktus, opuncja San Pedro, a San Pedro pejotl."
	items = list(
		/obj/structure/flora/ash/fonarstolbe = 1,
		/obj/structure/flora/ash/glowbell = 1,
		/obj/structure/flora/ash/seaweed = 1,
		/obj/structure/flora/ash/lightshroom = 1,
		/obj/structure/flora/ash/cinchona = 1,
		/obj/structure/flora/ash/cacti/prickly_pear = 1,
		/obj/structure/flora/ash/mutfruit = 1,
		/obj/structure/flora/ash/geigerpunga = 1,
		/obj/machinery/seeder = 1,
		/obj/item/plant_tray = 2,
		/obj/item/substrate_bag/dirt = 1,
		/obj/item/shovel/spade = 1,
	)
