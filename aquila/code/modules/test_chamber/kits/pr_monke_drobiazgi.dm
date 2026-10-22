// aq33/AquilaStation#488 - drobiazgi z Monkestation: loafer, sterty śmieci, dzwonki, bartending, Lifeline

/datum/test_chamber_kit/pr_monke_drobiazgi
	name = "PR Monke: loafer, sterty, dzwonki"
	pr = "aq33/AquilaStation#488"
	description = "Sterta śmieci: LPM grzebie (śmieci lecą w ciebie, raz na stertę łup z maint), przedmiot w ręku chowa go w środku, PPM chowa ciebie. \
	Dzwonek medyczny: dzwonienie wzywa medbay przez radio (raz na minutę), po wyniesieniu z obszaru włącza GPS. Zwykły dzwonek da się odkręcić kluczem. \
	Loafer: zbuduj z RPD (Disposal, Loafer) w rurze między koszem a wylotem i wrzuć coś do kosza. Emag zdejmuje limit gęstości. Bochenek z prętem po rzucie wypuszcza nieruchomy pręt."
	items = list(
		/obj/structure/trash_pile = 2,
		/obj/structure/desk_bell = 1,
		/obj/structure/desk_bell/departmental/medical = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/weldingtool/experimental = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/card/emag = 1,
		/obj/item/food/prison_loaf = 3,
		/obj/item/food/prison_loaf/rod = 1,
		/obj/item/radio/headset/headset_med = 1,
	)

/datum/test_chamber_kit/pr_monke_bartending
	name = "PR Monke: plastyczne szklanki i Lifeline"
	pr = "aq33/AquilaStation#488"
	description = "Szklanki: alt-klik zmienia kształt, dekoracje kładzie się klikając nimi szklankę (jedna na stronę), mycie je zdejmuje. \
	Plastry: nożem kroisz limonkę, cytrynę, pomarańczę i wiśnie. Przecinak na kablu, srebrze i złocie daje drut i obwódki. \
	Sól lub popiół podgrzane do 600 K w zlewce dają krawędzie. Tablet: Lifeline (lista załogi z czujnikami)."
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
		/obj/item/modular_computer/tablet/preset/advanced = 1,
	)

/datum/test_chamber_kit/pr_monke_bartending/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/modular_computer/tablet/tablet in spawned)
		var/obj/item/computer_hardware/hard_drive/drive = tablet.all_components[MC_HDD]
		drive?.store_file(new /datum/computer_file/program/radar/lifeline)
