/datum/test_chamber_kit/pr_509
	name = "Kult krwi Cult 4 (Monkestation/vgstation)"
	pr = "aq33/AquilaStation#509"
	description = "Trzech ludzi: 1) „kultysta testowy” (600 punktów devotion: Wspólnota krwi i Krwawy sztylet; przejmij go), 2) „kultysta do dekonwersji” (kultysta z wodą święconą we krwi), 3) „ofiara bez gracza” (bez umysłu i klienta). Do tego mysz, małpa, tom, talizmany, 20 runicznego metalu, kamień dusz, klejnot, Biblia i sól. \
	1) Przycisk panelu kultu (lewy górny róg) → oczekiwane: lista członków z dwoma kultystami, rola, rytuały, Zaćmienie na 0%, pomoc. \
	2) Tom: wpisz krwią trzy słowa runy Wzniesienie Budowli, narysuj ją na podłodze z metalem obok i aktywuj → oczekiwane: runiczny metal znika, powstaje ołtarz (też iglica/kuźnia przy innych wyborach). Na ołtarz połóż małpę, potem mysz i złóż w ofierze → oczekiwane: zwierzę znika z ołtarza, a w panelu rośnie devotion/zalicza się rytuał ofiary, o ile jest przypisany. \
	3) Konwersja: runa Konwersji na „ofierze bez gracza” → oczekiwane: nic się nie dzieje albo odmowa, bo do konwersji potrzebny jest umysł i klient (negatyw); wymaga drugiego gracza albo admina w ciele ofiary (ghost → Possess), wtedy pojawia się wybór „Dołącz / Zostań więźniem” na 10 s. \
	4) Dekonwersja bez drugiego gracza: przejmij „ofiarę bez gracza” (nie-kultystę; kultysta z Biblią nie rozpoczyna rytuału), weź Biblię (bez combat mode) i uderz nią „kultystę do dekonwersji” → oczekiwane: po 5 s zaczyna promieniować światłem, po 10 s traci kult, pojawiają się dwa czerwone cienie, a on ma ok. 10 obrażeń. Negatyw: Biblia na „ofierze bez gracza” albo na kultyście bez wody święconej → „...ale nic niezwykłego się nie dzieje” albo brak efektu; martwy kultysta → „Nie da się nawrócić zmarłego!”. Sól sypnięta na runę niszczy ją. \
	5) Kamień dusz i klejnot: schwytaj martwego człowieka/zwierzę i stwórz konstrukt (też hex i doskonały z klejnotu) → oczekiwane: konstrukt pojawia się i słucha kultysty. \
	6) Zaćmienie: z panelu antagonistów otwórz VV drużyny kultu i ustaw eclipse_progress = eclipse_target (1800) → oczekiwane: ogłoszenie Zaćmienia, pękają światła na statku, niebo czerwienieje, kultyści dostają aureolę, w panelu postęp 100%. Wtedy narysuj runę Rozdarcia Rzeczywistości (Tear Reality), wykonaj taniec i obroń powstały Krwawy Kamień; zniszczenie kamienia → porażka i kary. Przed Zaćmieniem runa Tear Reality nie działa (negatyw)."
	items = list(
		/mob/living/carbon/human = 3,
		/mob/living/carbon/monkey = 1,
		/mob/living/basic/mouse = 1,
		/obj/item/tome = 1,
		/obj/item/talisman = 3,
		/obj/item/kitchen/knife/ritual = 1,
		/obj/item/melee/cultblade = 1,
		/obj/item/soulstone = 1,
		/obj/item/soulstone/gem = 1,
		/obj/item/stack/sheet/runed_metal/twenty = 1,
		/obj/item/candle/blood = 3,
		/obj/item/reagent_containers/glass/cult/bloodfilled = 1,
		/obj/item/storage/book/bible = 1,
		/obj/item/nullrod = 1,
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1,
		/obj/item/reagent_containers/food/condiment/saltshaker = 1,
	)

/datum/test_chamber_kit/pr_509/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/list/humans = list()
	for(var/mob/living/carbon/human/person in spawned)
		humans += person
	if(length(humans) < 3)
		return
	var/mob/living/carbon/human/cultist_mob = humans[1]
	pr_509_make_cultist(cultist_mob, "kultysta testowy", 600)
	var/mob/living/carbon/human/prisoner = humans[2]
	pr_509_make_cultist(prisoner, "kultysta do dekonwersji", 0)
	// Rytuał Biblii sprawdza wodę święconą we krwi, a jej nie ma gdy nikt jej nie wstrzyknął
	prisoner.reagents?.add_reagent(/datum/reagent/water/holywater, 30)
	var/mob/living/carbon/human/victim = humans[3]
	victim.name = "ofiara bez gracza"
	victim.real_name = victim.name

/datum/test_chamber_kit/pr_509/proc/pr_509_make_cultist(mob/living/carbon/human/cultist_mob, new_name, devotion)
	cultist_mob.mind_initialize()
	// mob bez klienta nie przechodzi is_convertable_to_cult
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	var/datum/antagonist/cult/cultist = cultist_mob.mind.add_antag_datum(new_cultist)
	if(devotion)
		cultist?.gain_devotion(devotion, DEVOTION_TIER_4)
	cultist_mob.name = new_name
	cultist_mob.real_name = cultist_mob.name
