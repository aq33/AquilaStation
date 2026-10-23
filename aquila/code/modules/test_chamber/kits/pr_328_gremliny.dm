// aq33/AquilaStation#328 - gremliny z HippieStation

/datum/test_chamber_kit/pr_328
	name = "PR 328: gremliny"
	pr = "aq33/AquilaStation#328"
	description = "Dwa gremliny i maszyny do psucia: śluza, automat, sleeper, pompa, SMES. Gremliny nikogo nie atakują - mają podchodzić do maszyn i w nich grzebać \
	(otwieranie śluzy, kable, przestawianie pompy/SMES). Jedzą jedzenie z podłogi. Polej gremlina wodą (zlew/gaśnica) - ma się podzielić. \
	Granat \"Shitty EMP Grenade\" (uplink, 2 TC) wypuszcza 5 gremlinów po 85 HP. Bez runtime'ów przy klikaniu maszyn."
	items = list(
		/mob/living/simple_animal/hostile/gremlin = 2,
		/obj/item/grenade/spawnergrenade/gremlin = 1,
		/obj/machinery/door/airlock = 1,
		/obj/machinery/vending/cola = 1,
		/obj/machinery/sleeper = 1,
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/power/smes = 1,
		/obj/structure/sink = 1,
		/obj/item/extinguisher = 1,
		/obj/item/food/donut = 3,
	)
