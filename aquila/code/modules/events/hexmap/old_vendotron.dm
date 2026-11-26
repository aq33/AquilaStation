// AQUILA - Stary Vendotron: kapsuła przywozi z dryfującego złomu stary automat, który sprzedaje dziwne staroci za kredyty (port z vgstation-coders/vgstation13 code/modules/events/old_vendotron_event/vendor_crash_event.dm i old_vendotron.dm)
// On vg the vendor flies in as an immovable rod, smashes 4-6 walls and stops inside the station; its stock is a long
// list of oddities with random prices, including guns, armour, implants and wizard items, and hitting or emagging it
// can turn it into a hostile mob or set off spiders, cannons and bombs. Ours never breaks the hull: it lands in a
// supply pod without an explosion on a free safe turf of a safe room, away from doors so it blocks no passage. Its
// stock is drawn from our own harmless odd items (no weapons, armour, implants, access or precious materials) at
// prices of 30-600 credits with a random +-30%, it runs on its own battery and it has none of the punishments.

/datum/round_event_control/aquila_hex_old_vendotron
	name = "Stary Vendotron"
	typepath = /datum/round_event/aquila_hex_old_vendotron
	weight = 8
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_old_vendotron
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Pomieszczenie, w którym ląduje automat
	var/impact_area_name

/datum/round_event/aquila_hex_old_vendotron/start()
	var/list/spots = aquila_hex_room_turfs(1, TRUE)
	if(!length(spots))
		log_game("Old Vendotron: no free safe turf away from doors, cancelling the event.")
		return kill()
	var/turf/landing = spots[1]
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_STANDARD)
	pod.explosionSize = list(0, 0, 0, 0)
	new /obj/machinery/vending/aquila_old_vendotron(pod)
	var/obj/effect/pod_landingzone/marker = new(landing, pod)
	impact_area_name = get_area_name(landing, TRUE)
	announce_to_ghosts(marker)
	log_game("Old Vendotron: landing at [AREACOORD(landing)].")

/datum/round_event/aquila_hex_old_vendotron/announce(fake)
	if(!impact_area_name)
		return
	priority_announce("Ekipa złomiarzy Nanotrasen wyłowiła z wraków bardzo stary automat sprzedający. Nie wiemy, kto go zbudował ani co w nim jest, ale nadal przyjmuje kredyty, więc odsyłamy go do was kapsułą. Miejsce lądowania: [impact_area_name]. Dział Handlu nie odpowiada za towary z automatu ani za ich daty ważności.", "Dział Handlu Nanotrasen")

/// Stary automat z losowym zapasem dziwnych, ale nieszkodliwych staroci w losowych cenach
/obj/machinery/vending/aquila_old_vendotron
	name = "stary Vendotron"
	desc = "Pokryty warstwami brudu z różnych epok i miejsc. Widać, że ten stary automat ma swoją historię i towar do kompletu."
	icon_state = "generic"
	use_power = NO_POWER_USE
	product_slogans = "Towar z duszą! I z kurzem.;Kiedyś wszystko było lepsze. Na przykład ten towar.;Gwarancja wygasła w poprzednim stuleciu.;Kupujcie, póki jeszcze działam!"
	product_ads = "Prawdziwe antyki!;Ceny jak za starych czasów, tylko wyższe.;Nie pytaj, skąd to mam."
	vend_reply = "Dziękuję. Zwrotów nie przyjmuję."
	default_price = 100
	extra_price = 300
	/// Typ => cena bazowa, z której losuje się zapas
	var/static/list/stock_prices = list(
		/obj/item/toy/crayon/rainbow = 30,
		/obj/item/clothing/glasses/monocle = 40,
		/obj/item/storage/box/donkpockets = 60,
		/obj/item/storage/box/snappops = 40,
		/obj/item/toy/beach_ball = 40,
		/obj/item/clothing/mask/horsehead = 150,
		/obj/item/clothing/head/hardhat/pumpkinhead = 60,
		/obj/item/clothing/head/foilhat = 50,
		/obj/item/storage/fancy/donut_box = 80,
		/obj/item/soap = 30,
		/obj/item/storage/wallet = 40,
		/obj/item/tank/internals/emergency_oxygen/double = 120,
		/obj/item/clothing/shoes/magboots = 400,
		/obj/item/bikehorn/rubberducky = 150,
		/obj/item/stock_parts/micro_laser/ultra = 200,
		/obj/item/stock_parts/manipulator/pico = 200,
		/obj/item/stock_parts/scanning_module/phasic = 200,
		/obj/item/stock_parts/capacitor/super = 200,
		/obj/item/stock_parts/cell/high = 150,
		/obj/item/slime_extract/grey = 120,
		/obj/item/dice/d20 = 50,
		/obj/item/storage/box/actionfigure = 150,
		/obj/item/storage/box/monkeycubes = 150,
		/obj/item/clothing/head/collectable/tophat = 120,
		/obj/item/toy/cards/deck = 40,
		/obj/item/toy/eightball = 60,
		/obj/item/toy/plush/carpplushie = 80,
		/obj/item/toy/talking/AI = 90,
		/obj/item/storage/fancy/candle_box = 40,
		/obj/item/clothing/neck/scarf = 40,
		/obj/item/clothing/head/flatcap = 50,
		/obj/item/clothing/head/witchwig = 70,
		/obj/item/flashlight/lantern = 60,
		/obj/item/reagent_containers/food/drinks/bottle/wine = 90,
		/obj/item/reagent_containers/food/drinks/bottle/grappa = 120,
		/obj/item/clothing/suit/hooded/wintercoat = 100,
		/obj/item/stack/ore/bluespace_crystal = 450,
		/obj/item/clothing/gloves/color/fyellow = 200,
	)
	/// Wylosowane ceny zapasu (typ => cena)
	var/list/rolled_prices = list()

/obj/machinery/vending/aquila_old_vendotron/Initialize(mapload)
	roll_stock()
	. = ..()
	for(var/datum/data/vending_product/record as anything in product_records)
		if(rolled_prices[record.product_path])
			record.custom_price = rolled_prices[record.product_path]

/// Losuje 6-12 pozycji z ilością 1-3 i ceną bazową +-30%
/obj/machinery/vending/aquila_old_vendotron/proc/roll_stock()
	products = list()
	rolled_prices = list()
	var/list/pool = stock_prices.Copy()
	for(var/i in 1 to rand(6, 12))
		if(!length(pool))
			break
		var/item_type = pick_n_take(pool)
		products[item_type] = pick(1, 1, 2, 3)
		var/base_price = stock_prices[item_type]
		rolled_prices[item_type] = max(1, round(rand(base_price * 7, base_price * 13) / 10))

/// Własna bateria: działa także w kapsule i w pomieszczeniu bez zasilania
/obj/machinery/vending/aquila_old_vendotron/powered(chan = -1)
	return TRUE
