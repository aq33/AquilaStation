// AQUILA - dzika flora zimnych i jałowych planet (partia „zimne”). Każda struktura /obj/structure/flora/ash to prawdziwa
// roślina naszej botaniki z nasion seed_type (jak paproć jaskiniowa w ash_flora.dm): zbiera się ją ręką, odrasta,
// a z plonu siewnik robi nasiona do tacy.
// Źródła (ikony CC BY-SA 3.0):
// - planeta lodowa: flora księżyca lodowego z tgstation/tgstation (code/modules/mining/lavaland/ash_flora.dm,
//   icons/obj/mining_zones/ash_flora.dmi, icons/obj/service/hydroponics/seeds.dmi);
// - księżyc i asteroidy: grzyby jaskiniowe z NebulaSS13/Nebula (code/modules/hydroponics/plant_types/seeds_misc.dm,
//   sprite'y z hydroponics_growing.dmi, hydroponics_products.dmi i seed_packets.dmi pokolorowane jak w grze);
// - plaża i woda: glony z NebulaSS13/Nebula (/datum/seed/algae) i wodorosty z shiptest-ss13/Shiptest
//   (code/modules/hydroponics/grown/misc.dm, /obj/structure/flora/ash/garden/seaweed).
// Odczynników, których nie mamy, nie przenosimy; zamienniki:
// - fluid luminescencyjny i glowsap -> bioluminescencja owocu i fosfor (jak świecący grzyb);
// - guidoferrun, plasma oxide, liquidgibs, sproszkowany grzyb -> pominięte;
// - berserker -> efedryna, ekstrakt z mięty -> toksyna miętowa, ekstrakt seraki (koagulant) -> bikarydyna,
//   bromek (Nebula) -> brom;
// - podśnieżka smakuje jak mięso, więc zamiast odżywki ma białko; „chem_cooling” z tg to nasza cecha chłodzenia owocu.
// Kwiat plazmowy nie jest nakryciem głowy (nie mamy sprite'u na głowie), a świecąca narośl rośnie w tacy (w tg nie).

// Struktury: planeta lodowa (tg)

/obj/structure/flora/ash/fonarstolbe
	name = "owocujące fonarsztolbe"
	desc = "Chemotroficzna, słabo świecąca roślina, którą naukowcy ze Spinwardu nazwali fonarsztolbe. Dobrze ukorzeniona przetrwa tygodnie w warunkach i ciśnieniach zabójczych dla większości roślin."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "fonarstolbe1"
	base_icon_state = "fonarstolbe"
	seed_type = /obj/item/plant_seeds/preset/fonarstolbe
	light_range = 1.5
	light_power = 0.8
	light_color = "#6699FF"

/obj/structure/flora/ash/vahrezjia
	name = "kwiaty wachrezji"
	desc = "Jaskrawoniebieskie łodygi wyrastające z fioletowych, kwiecistych strąków. Podobno doprowadzają zwierzęta do szału."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "vahrezjia1"
	base_icon_state = "vahrezjia"
	seed_type = /obj/item/plant_seeds/preset/vahrezjia

/obj/structure/flora/ash/podsneyzka
	name = "kwitnące podśnieżki"
	desc = "Kępa kwitnących podśnieżek. Te kwiaty smakują podobno jak mięso i mają podobny skład chemiczny. Lepiej się nad tym nie zastanawiać."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "podsneyzka1"
	base_icon_state = "podsneyzka"
	seed_type = /obj/item/plant_seeds/preset/podsneyzka

/obj/structure/flora/ash/inozhakust
	name = "inożakust"
	desc = "Roślina wyglądająca jak korzenie rosnące w niebo, pokryta miękkimi, mokrymi, oleistymi pędami. Pod dotykiem mlaszczą i się rozpadają, więc zbiera się je jako papkę."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "inozhakust1"
	base_icon_state = "inozhakust"
	seed_type = /obj/item/plant_seeds/preset/inozhakust

/obj/structure/flora/ash/plasma_flower
	name = "kwiaty plazmowe"
	desc = "Pnącza oplatające kępę kwiatów z plazmy. Badacze wciąż nie potrafią ich zrozumieć."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "plasma_flower1"
	base_icon_state = "plasma_flower"
	seed_type = /obj/item/plant_seeds/preset/plasma_flower
	light_range = 2
	light_power = 0.8
	light_color = "#D966FF"

// Dwa sprite'y (bazowe Initialize losuje stan 1-4)
/obj/structure/flora/ash/plasma_flower/Initialize(mapload)
	. = ..()
	icon_state = "plasma_flower[rand(1, 2)]"

/obj/structure/flora/ash/glowgrowth
	name = "kolonia świecącej narośli"
	desc = "Kolonia bioluminescencyjnych grzybów na wylocie gorącego powietrza. Żywi się drobinami minerałów niesionymi z głębi planety."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "glowgrowth1"
	base_icon_state = "glowgrowth"
	seed_type = /obj/item/plant_seeds/preset/glowgrowth
	light_range = 1.7
	light_power = 0.8
	light_color = "#67b6a5"

// Trzy sprite'y i świecąca warstwa
/obj/structure/flora/ash/glowgrowth/Initialize(mapload)
	. = ..()
	icon_state = "glowgrowth[rand(1, 3)]"
	update_appearance()

/obj/structure/flora/ash/glowgrowth/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]e", alpha = 120)

/obj/structure/flora/ash/seraka
	name = "grzyby seraka"
	desc = "Mała kępa grzybów seraka. Musiały przybyć tu razem z popielnymi jaszczurami."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "seraka1"
	base_icon_state = "seraka"
	seed_type = /obj/item/plant_seeds/preset/seraka

/obj/structure/flora/ash/seraka/Initialize(mapload)
	. = ..()
	icon_state = "seraka[rand(1, 2)]"

// Struktury: księżyc i asteroidy (Nebula)

/obj/structure/flora/ash/glowbell
	name = "kępa świecących dzwonków"
	desc = "Grzyby o dzwonkowatych kapeluszach, które świecą chłodnym, błękitnym światłem w ciemnych jaskiniach."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "glowbell"
	base_icon_state = "glowbell"
	seed_type = /obj/item/plant_seeds/preset/glowbell
	light_range = 1.5
	light_power = 0.6
	light_color = "#9eefff"

// Jeden sprite (bazowe Initialize losuje stan 1-4)
/obj/structure/flora/ash/glowbell/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/glowbell/weeping_moon
	name = "kępa płaczących księżyców"
	desc = "Grzyby o opadających, sierpowatych kapeluszach, z których kapie świecący sok."
	icon_state = "weeping_moon"
	base_icon_state = "weeping_moon"
	seed_type = /obj/item/plant_seeds/preset/weeping_moon

/obj/structure/flora/ash/glowbell/cavern_candle
	name = "kępa jaskiniowych świec"
	desc = "Smukłe grzyby o płaskich kapeluszach, które oświetlają jaskinię jak świece."
	icon_state = "cavern_candle"
	base_icon_state = "cavern_candle"
	seed_type = /obj/item/plant_seeds/preset/cavern_candle

// Struktury: plaża i woda

/obj/structure/flora/ash/algae
	name = "kożuch glonów"
	desc = "Zielony kożuch glonów unoszący się na płytkiej wodzie."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "algae"
	base_icon_state = "algae"
	seed_type = /obj/item/plant_seeds/preset/algae

/obj/structure/flora/ash/algae/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/ash/seaweed
	name = "kępa wodorostów"
	desc = "Kępa wodorostów unosząca się na powierzchni wody."
	icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	icon_state = "seaweed"
	base_icon_state = "seaweed"
	seed_type = /obj/item/plant_seeds/preset/seaweed

/obj/structure/flora/ash/seaweed/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

// Cechy owoców. Kształty owoców na roślinie w tacy z naszego fruit.dmi i mushroom.dmi.

/datum/plant_feature/fruit/fonarstolbe
	species_name = "lucerna columnae"
	name = "fonarsztolbe"
	icon_state = "orb"
	colour_override = "#7fd4ff"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-fonarstolbe"
	fruit_product = /obj/item/food/grown/ash_flora/fonarstolbe
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue)
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/nutriment/vitamin = PLANT_REAGENT_MEDIUM, /datum/reagent/iron = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/vahrezjia
	species_name = "furor caeruleus"
	name = "wachrezja"
	icon_state = "flower_2"
	colour_overlay = "flower_2_colour"
	colour_override = "#3f5fff"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-vahrezjia"
	fruit_product = /obj/item/food/grown/ash_flora/vahrezjia
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_SMALL, /datum/reagent/consumable/nutriment/vitamin = PLANT_REAGENT_SMALL, /datum/reagent/medicine/ephedrine = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/nutriment/fat/oil = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/podsneyzka
	species_name = "galanthus carnis"
	name = "podśnieżka"
	icon_state = "flower_1"
	colour_overlay = "flower_1_colour"
	colour_override = "#e8e0ff"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-podsneyzka"
	fruit_product = /obj/item/food/grown/ash_flora/podsneyzka
	plant_traits = list(/datum/plant_trait/fruit/temperature/cold)
	fast_reagents = list(/datum/reagent/consumable/nutriment/protein = PLANT_REAGENT_MEDIUM, /datum/reagent/consumable/nutriment/vitamin = PLANT_REAGENT_MEDIUM, /datum/reagent/cryostylane = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/inozhakust
	species_name = "radix caelestis"
	name = "inożakust"
	icon_state = "nettle"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-inozhakust"
	fruit_product = /obj/item/food/grown/ash_flora/inozhakust
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_LARGE, /datum/reagent/consumable/nutriment/vitamin = PLANT_REAGENT_MICRO, /datum/reagent/toxin/minttoxin = PLANT_REAGENT_SMALL, /datum/reagent/impurity = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/plasma_flower
	species_name = "flos plasmatis"
	name = "kwiat plazmowy"
	icon_state = "flower_3"
	colour_overlay = "flower_3_colour"
	colour_override = "#c04dff"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-plasma_flower"
	fruit_product = /obj/item/food/grown/ash_flora/plasma_flower
	plant_traits = list(/datum/plant_trait/fruit/biolight/purple)
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_SMALL, /datum/reagent/stable_plasma = PLANT_REAGENT_MEDIUM)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/mushroom/glowgrowth
	species_name = "lumen vaporis"
	name = "świecąca narośl"
	icon_state = "button"
	colour_overlay = "button_colour"
	colour_override = "#67b6a5"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "mycelium-glowgrowth"
	fruit_product = /obj/item/food/grown/ash_flora/glowgrowth
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue)
	fast_reagents = list(/datum/reagent/phosphorus = PLANT_REAGENT_SMALL, /datum/reagent/silicon = PLANT_REAGENT_SMALL, /datum/reagent/consumable/nutriment = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3

/datum/plant_feature/fruit/mushroom/seraka
	species_name = "seraka tiziranae"
	name = "seraka"
	icon_state = "plump"
	colour_overlay = "plump_colour"
	colour_override = "#4f6fb0"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "mycelium-seraka"
	fruit_product = /obj/item/food/grown/ash_flora/seraka
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_LARGE, /datum/reagent/medicine/bicaridine = PLANT_REAGENT_MICRO)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3

/datum/plant_feature/fruit/mushroom/glowbell
	species_name = "campanula lucens"
	name = "świecący dzwonek"
	icon_state = "destroying_angel"
	colour_overlay = "destroying_angel_colour"
	colour_override = "#90d7f0"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "mycelium-glowbell"
	fruit_product = /obj/item/food/grown/mushroom/glowbell
	plant_traits = list(/datum/plant_trait/fruit/biolight/blue)
	fast_reagents = list(/datum/reagent/phosphorus = PLANT_REAGENT_SMALL, /datum/reagent/consumable/nutriment = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_MICRO
	growth_time = PLANT_FRUIT_GROWTH_MEDIUM
	genetic_budget = 3
	mutations = list(/datum/plant_feature/fruit/mushroom/glowbell/weeping_moon, /datum/plant_feature/fruit/mushroom/glowbell/cavern_candle)

/datum/plant_feature/fruit/mushroom/glowbell/weeping_moon
	species_name = "luna lacrimans"
	name = "płaczący księżyc"
	icon_state = "fly"
	colour_overlay = "fly_colour"
	seed_icon_state = "mycelium-weeping_moon"
	fruit_product = /obj/item/food/grown/mushroom/weeping_moon
	mutations = list()

/datum/plant_feature/fruit/mushroom/glowbell/cavern_candle
	species_name = "candela cavernae"
	name = "jaskiniowa świeca"
	icon_state = "tower"
	colour_overlay = "tower_colour"
	seed_icon_state = "mycelium-cavern_candle"
	fruit_product = /obj/item/food/grown/mushroom/cavern_candle
	mutations = list()

/datum/plant_feature/fruit/algae
	species_name = "alga vulgaris"
	name = "glony"
	icon_state = "tea"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-algae"
	fruit_product = /obj/item/food/grown/algae
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_MEDIUM, /datum/reagent/bromine = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

/datum/plant_feature/fruit/seaweed
	species_name = "alga marina"
	name = "wodorosty"
	icon_state = "tabacco_2"
	seed_icon = 'aquila/icons/planets/flora/zimne_flora.dmi'
	seed_icon_state = "seed-seaweed"
	fruit_product = /obj/item/food/grown/seaweed
	fast_reagents = list(/datum/reagent/consumable/nutriment = PLANT_REAGENT_LARGE, /datum/reagent/consumable/nutriment/vitamin = PLANT_REAGENT_SMALL, /datum/reagent/water = PLANT_REAGENT_SMALL)
	total_volume = PLANT_FRUIT_VOLUME_SMALL
	growth_time = PLANT_FRUIT_GROWTH_FAST
	genetic_budget = 3
	whitelist_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber)
	plant_needs = list()

// Nasiona (nie do automatu: tylko z dzikich roślin przez siewnik)

/obj/item/plant_seeds/preset/fonarstolbe
	name = "nasiona: fonarsztolbe (dowolne podłoże)"
	name_override = "fonarsztolbe"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/fonarstolbe)

/obj/item/plant_seeds/preset/vahrezjia
	name = "nasiona: wachrezja (dowolne podłoże)"
	name_override = "wachrezja"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/vahrezjia)

/obj/item/plant_seeds/preset/podsneyzka
	name = "nasiona: podśnieżka (dowolne podłoże)"
	name_override = "podśnieżka"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/podsneyzka)

/obj/item/plant_seeds/preset/inozhakust
	name = "nasiona: inożakust (dowolne podłoże)"
	name_override = "inożakust"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/inozhakust)

/obj/item/plant_seeds/preset/plasma_flower
	name = "nasiona: kwiat plazmowy (dowolne podłoże)"
	name_override = "kwiat plazmowy"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/plasma_flower)

/obj/item/plant_seeds/preset/glowgrowth
	name = "zarodniki: świecąca narośl (dowolne podłoże)"
	name_override = "świecąca narośl"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowgrowth)

/obj/item/plant_seeds/preset/seraka
	name = "zarodniki: seraka (dowolne podłoże)"
	name_override = "seraka"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/seraka)

/obj/item/plant_seeds/preset/glowbell
	name = "zarodniki: świecący dzwonek (dowolne podłoże)"
	name_override = "świecący dzwonek"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowbell)

/obj/item/plant_seeds/preset/weeping_moon
	name = "zarodniki: płaczący księżyc (dowolne podłoże)"
	name_override = "płaczący księżyc"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowbell/weeping_moon)

/obj/item/plant_seeds/preset/cavern_candle
	name = "zarodniki: jaskiniowa świeca (dowolne podłoże)"
	name_override = "jaskiniowa świeca"
	plant_features = list(/datum/plant_feature/roots/hyphae, /datum/plant_feature/body/mushroom, /datum/plant_feature/fruit/mushroom/glowbell/cavern_candle)

/obj/item/plant_seeds/preset/algae
	name = "nasiona: glony (dowolne podłoże)"
	name_override = "glony"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/algae)

/obj/item/plant_seeds/preset/seaweed
	name = "nasiona: wodorosty (dowolne podłoże)"
	name_override = "wodorosty"
	plant_features = list(/datum/plant_feature/roots, /datum/plant_feature/body/tuber/lavaland, /datum/plant_feature/fruit/seaweed)

// Plony

/obj/item/food/grown/ash_flora/fonarstolbe
	name = "owoc fonarsztolbe"
	desc = "Owoc fonarsztolbe. Słabo świeci na niebiesko."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "fonarstolbe"
	seed = /obj/item/plant_seeds/preset/fonarstolbe
	wine_power = 50
	foodtypes = FRUIT
	tastes = list("słodko-kwaśny owoc" = 1)

/obj/item/food/grown/ash_flora/vahrezjia
	name = "łodygi wachrezji"
	desc = "Związane łodygi wachrezji. Zaskakująco szorstkie w dotyku."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "vahrezjia"
	seed = /obj/item/plant_seeds/preset/vahrezjia
	wine_power = 50
	foodtypes = FRUIT

/obj/item/food/grown/ash_flora/podsneyzka
	name = "pęczek podśnieżek"
	desc = "Pęczek nakrapianych, zwiniętych kwiatów podśnieżki. Pachną trochę jak zepsute mięso."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "podsneyzka"
	seed = /obj/item/plant_seeds/preset/podsneyzka
	wine_power = 50
	foodtypes = MEAT | VEGETABLES
	tastes = list("mięso" = 1, "kwiaty" = 1)

/obj/item/food/grown/ash_flora/inozhakust
	name = "papka z inożakustu"
	desc = "Rozgniecione pędy inożakustu zgarnięte do czegokolwiek, co było pod ręką."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "inozhakust"
	seed = /obj/item/plant_seeds/preset/inozhakust
	foodtypes = VEGETABLES | GROSS

/obj/item/food/grown/ash_flora/plasma_flower
	name = "kwiat plazmowy"
	desc = "Kawałek pnącza z krystalicznym kwiatem z plazmy."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "plasma_flower"
	seed = /obj/item/plant_seeds/preset/plasma_flower
	wine_power = 40
	foodtypes = TOXIC

/obj/item/food/grown/ash_flora/glowgrowth
	name = "płat świecącej narośli"
	desc = "Gruby płat świecących grzybów."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "glowgrowth"
	seed = /obj/item/plant_seeds/preset/glowgrowth
	wine_power = 50

/obj/item/food/grown/ash_flora/seraka
	name = "kapelusz seraki"
	desc = "Małe, bardzo aromatyczne grzyby, pochodzące z Tiziry."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "seraka"
	seed = /obj/item/plant_seeds/preset/seraka
	wine_power = 40
	foodtypes = VEGETABLES

/obj/item/food/grown/mushroom/glowbell
	name = "świecący dzwonek"
	desc = "Grzyb o dzwonkowatym kapeluszu, który świeci chłodnym, błękitnym światłem."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "glowbell"
	seed = /obj/item/plant_seeds/preset/glowbell

/obj/item/food/grown/mushroom/weeping_moon
	name = "płaczący księżyc"
	desc = "Grzyb o opadającym, sierpowatym kapeluszu, z którego kapie świecący sok."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "weeping_moon"
	seed = /obj/item/plant_seeds/preset/weeping_moon

/obj/item/food/grown/mushroom/cavern_candle
	name = "jaskiniowa świeca"
	desc = "Smukły grzyb o płaskim kapeluszu, świecący jak świeca."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "cavern_candle"
	seed = /obj/item/plant_seeds/preset/cavern_candle

/obj/item/food/grown/algae
	name = "glony"
	desc = "Garść śliskich, zielonych glonów."
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "algae"
	seed = /obj/item/plant_seeds/preset/algae
	foodtypes = VEGETABLES
	tastes = list("glony" = 1)

/obj/item/food/grown/seaweed
	name = "wodorosty"
	desc = "Są takie gumowate... czy to w ogóle można jeść?"
	icon = 'aquila/icons/planets/flora/zimne_flora_harvest.dmi'
	icon_state = "seaweed"
	seed = /obj/item/plant_seeds/preset/seaweed
	bite_consumption_mod = 1
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/water = 1, /datum/reagent/consumable/sodiumchloride = 2)
	tastes = list("wodorosty" = 1)

// Suszone wodorosty to nasz arkusz wodorostów do sushi (Shiptest: seaweed/sheet)
/obj/item/food/grown/seaweed/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/seaweed_sheet)

// Mutacje z roślin, które już mamy (Nebula: reishi -> glowbell)
/datum/plant_mutation_set/zimne
	mutations = list(
		/datum/plant_feature/fruit/mushroom/reishi = list(/datum/plant_feature/fruit/mushroom/glowbell = 3),
	)
