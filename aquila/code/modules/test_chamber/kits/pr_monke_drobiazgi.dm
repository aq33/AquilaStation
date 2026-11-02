// aq33/AquilaStation#488 - drobiazgi z Monkestation: loafer, sterty śmieci, dzwonki, bartending, Lifeline

/datum/test_chamber_kit/pr_monke_drobiazgi
	name = "PR Monke: loafer, sterty, dzwonki"
	pr = "aq33/AquilaStation#488"
	description = "Zestaw: dwie sterty śmieci, dzwonki, kosz utylizacji z wylotem, RPD, narzędzia, emag, bochenki, mózg i słuchawka medyczna. \
	1) Sterta śmieci: LPM (grzebanie) → oczekiwane: śmieci lecą w ciebie, a raz na stertę wypada łup z maint (druga próba tej samej sterty dla tego samego gracza bez łupu). Przedmiot w ręku + klik w stertę → chowa się w środku; PPM → chowasz się ty (i da się stamtąd wyjść). \
	2) Dzwonek medyczny: kliknij → oczekiwane: dzwonienie i wezwanie medbay przez radio (słuchawka medyczna pokaże wiadomość), kolejne dzwonienie w ciągu minuty tylko dzwoni bez wezwania (negatyw: raz na minutę). Wynieś go z obszaru → włącza GPS. Zwykły dzwonek: odkręć kluczem. \
	3) Loafer: przykręć kosz utylizacji i wylot kluczem, RPD (Disposal → Loafer) wybuduj rury i segment loafera między nimi (załóż pozostałe odcinki rury), wrzuć do kosza przedmioty i bochenek → oczekiwane: na wylocie wypada bochenek więzienny o większej gęstości; wrzuć też mózg (negatyw: mózg i głowy z czarnej listy przepływają bez sprasowania). Emag na loaferze: komunikat o wyłączeniu limitów bezpieczeństwa, mechanizm usmażony w examine. \
	4) Bochenek z prętem: rzuć nim w ścianę lub kogoś → oczekiwane: po rzucie wypuszcza nieruchomy pręt."
	items = list(
		/obj/structure/trash_pile = 2,
		/obj/structure/desk_bell = 1,
		/obj/structure/desk_bell/departmental/medical = 1,
		/obj/machinery/disposal/bin = 1,
		/obj/structure/disposaloutlet = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/card/emag = 1,
		/obj/item/food/prison_loaf = 3,
		/obj/item/food/prison_loaf/rod = 1,
		/obj/item/organ/brain = 1,
		/obj/item/radio/headset/headset_med = 1,
	)

/datum/test_chamber_kit/pr_monke_bartending
	name = "PR Monke: plastyczne szklanki i Lifeline"
	pr = "aq33/AquilaStation#488"
	description = "Zestaw: trzy szklanki, pudełko dekoracji, owoce i nóż, przecinak, kabel, złoto, srebro, zapalniczka, tablet z Lifeline i człowiek „Testowy Załogant” z czujnikami. Leżą też zlewki: jedna z solą, druga z popiołem (po 20 u). \
	1) Alt-klik na szklance → oczekiwane: szklanka zmienia kształt (wariant sprite). \
	2) Dekoracje: weź parasolkę albo dekorację z pudełka i kliknij nią szklankę → oczekiwane: dekoracja pojawia się na szklance i znika z ręki. Negatyw: druga dekoracja na tę samą stronę (np. limonka i potem wiśnia) → „Na tej części szklanki już coś jest!”; umycie szklanki (zlew/woda) zdejmuje dekoracje. \
	3) Plastry: nożem w ręce kliknij limonkę, cytrynę, pomarańczę i wiśnie → oczekiwane: powstają plastry (limonka daje plaster limonki). Przecinak na kablu, srebrze i złocie → oczekiwane: drut oraz obwódki srebrna i złota. \
	4) Krawędzie: podgrzej zlewkę z solą zapalniczką do ok. 600 K (zlewka w ręce, zapalona zapalniczka) → oczekiwane: sól zamienia się w solną krawędź do szklanki; to samo z popiołem (popielna krawędź). Negatyw: sól poniżej 600 K nic nie daje. \
	5) Lifeline: uruchom program na tablecie → oczekiwane: lista załogi z „Testowy Załogant” (nazwa i stanowisko z karty), jego odległość, kierunek i obszar; człowiek z czujnikiem na pełnym śledzeniu. Gdy odejdziesz o kilka kratek, odległość rośnie."
	items = list(
		/obj/item/reagent_containers/food/drinks/modglass = 1,
		/obj/item/reagent_containers/food/drinks/modglass/small = 1,
		/obj/item/reagent_containers/food/drinks/modglass/large = 1,
		/obj/item/storage/box/garnish = 1,
		/obj/item/garnish/umbrellared = 1,
		/obj/item/food/grown/citrus/lime = 1,
		/obj/item/food/grown/citrus/lemon = 1,
		/obj/item/food/grown/citrus/orange = 1,
		/obj/item/food/grown/cherries = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/wirecutters = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1,
		/obj/item/reagent_containers/food/drinks/shaker = 1,
		/obj/item/lighter = 1,
		/obj/item/modular_computer/tablet/preset/advanced = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_monke_bartending/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/item/modular_computer/tablet/tablet in spawned)
		var/obj/item/computer_hardware/hard_drive/drive = tablet.all_components[MC_HDD]
		drive?.store_file(new /datum/computer_file/program/radar/lifeline)
	// Zlewki z solą i popiołem do krawędzi; poza items, więc test komory ich nie liczy
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	var/obj/item/reagent_containers/glass/beaker/salt_beaker = new(drop)
	salt_beaker.name = "zlewka z solą"
	salt_beaker.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 20)
	var/obj/item/reagent_containers/glass/beaker/ash_beaker = new(drop)
	ash_beaker.name = "zlewka z popiołem"
	ash_beaker.reagents.add_reagent(/datum/reagent/ash, 20)
	// Człowiek z czujnikami na pełnym śledzeniu i kartą, żeby Lifeline miał kogo pokazać
	for(var/mob/living/carbon/human/crew in spawned)
		crew.name = "Testowy Załogant"
		crew.real_name = crew.name
		var/obj/item/clothing/under/color/grey/suit = new
		suit.sensor_mode = SENSOR_COORDS
		crew.equip_to_slot_or_del(suit, ITEM_SLOT_ICLOTHING)
		var/obj/item/card/id/job/scientist/badge = new
		badge.registered_name = crew.real_name
		badge.update_label()
		crew.equip_to_slot_or_del(badge, ITEM_SLOT_ID)
