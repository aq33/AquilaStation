/datum/test_chamber_kit/pr_000
	name = "PR 000: broń microfusion (MCR-01)"
	pr = "aq33/AquilaStation#000"
	description = "Dwa MCR-01 (jeden zaawansowany), puste ogniwa, emitery i wszystkie dodatki. Użyj broni w ręce: otwiera się panel sterowania (ciepło i ładunek odświeżają się same). \
	Strzelaj seriami, aż emiter się nagrzeje i włączy dławienie termiczne; włącz chłodzenie w panelu. Ręką zdejmujesz ogniwo, łomem emiter, Alt+klik albo panel zdejmuje dodatki. \
	Puste ogniwo włożysz tylko rozładowane (naładowane rozładuj w ręce). Śrubokrętem zdejmiesz dodatki z ogniwa. Multitoolem odblokuj emiter i podkręć próg w panelu. \
	Szyna pozwala zamontować latarkę i bagnet, luneta daje przybliżenie. Broń włożona do ładowarki się ładuje."
	items = list(
		/obj/item/gun/microfusion/mcr01 = 1,
		/obj/item/gun/microfusion/mcr01/advanced = 1,
		/obj/item/stock_parts/cell/microfusion = 1,
		/obj/item/stock_parts/cell/microfusion/enhanced = 1,
		/obj/item/stock_parts/cell/microfusion/advanced = 1,
		/obj/item/stock_parts/cell/microfusion/bluespace = 1,
		/obj/item/stock_parts/cell/microfusion/makeshift = 1,
		/obj/item/microfusion_cell_attachment/overcapacity = 1,
		/obj/item/microfusion_cell_attachment/stabiliser = 1,
		/obj/item/microfusion_cell_attachment/selfcharging = 1,
		/obj/item/microfusion_phase_emitter/enhanced = 1,
		/obj/item/microfusion_phase_emitter/bluespace = 1,
		/obj/item/microfusion_gun_attachment/barrel/scatter = 1,
		/obj/item/microfusion_gun_attachment/barrel/scatter/max = 1,
		/obj/item/microfusion_gun_attachment/barrel/superheat = 1,
		/obj/item/microfusion_gun_attachment/barrel/hellfire = 1,
		/obj/item/microfusion_gun_attachment/barrel/repeater = 1,
		/obj/item/microfusion_gun_attachment/barrel/repeater/penetrator = 1,
		/obj/item/microfusion_gun_attachment/barrel/xray = 1,
		/obj/item/microfusion_gun_attachment/barrel/suppressor = 1,
		/obj/item/microfusion_gun_attachment/barrel/honk = 1,
		/obj/item/microfusion_gun_attachment/barrel/lance = 1,
		/obj/item/microfusion_gun_attachment/barrel/pulse = 1,
		/obj/item/microfusion_gun_attachment/grip = 1,
		/obj/item/microfusion_gun_attachment/heatsink = 1,
		/obj/item/microfusion_gun_attachment/rgb = 1,
		/obj/item/microfusion_gun_attachment/rail = 1,
		/obj/item/microfusion_gun_attachment/scope = 1,
		/obj/item/microfusion_gun_attachment/camo = 1,
		/obj/item/microfusion_gun_attachment/camo/syndicate = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/kitchen/knife/combat = 1,
		/obj/item/crowbar = 1,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1,
		/obj/machinery/recharger = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_000/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/machinery/recharger/recharger in spawned)
		recharger.setAnchored(TRUE)
