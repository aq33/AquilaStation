// aq33/AquilaStation#564 - pasek etapów ładowania nad bronią statkową i skrzydła ćmy w animacji chodu

/datum/test_chamber_kit/pr_564
	name = "PR 564: pasek ładowania broni, skrzydła ćmy"
	pr = "aq33/AquilaStation#564"
	description = "Połączenie: postaw konsolę amunicji obok broni i z multitoolem w ręce kliknij w jej oknie „Połącz z najbliższą bronią” (albo zapisz broń multitoolem i wybierz „Połącz z: …”); druga konsola dla drugiej broni. 	1) Przeciągnij torpedę na podajnik VLS (poczekaj na pasek do_after) → oczekiwane: torpeda w środku. W konsoli kliknij „I1 - Pocisk podany”, potem „I2 - Pocisk w komorze” → oczekiwane: nad VLS pasek rośnie od czerwonego do żółtego (ok. 2 s podawania, potem 1 s komorowania) i znika. \
	2) Drugą postacią albo z boku: ten pasek widzi każdy obok, nie tylko ładujący. \
	3) To samo z MAC-iem i jego amunicją → oczekiwane: pasek wyśrodkowany nad całym działem, nie nad lewym dolnym kafelkiem. Rozładuj broń → oczekiwane: krótki pasek rozładunku. \
	4) Ćma (druga postać w zestawie): przejmij ją albo chodź obok i patrz → oczekiwane: przy każdym kroku w każdą stronę skrzydła są całe, bez nacięć i kawałków ruszających się razem z rękami i nogami; po zatrzymaniu wyglądają tak jak przed ruszeniem. \
	Negatyw: ubierz ćmie skafander, który chowa skrzydła → oczekiwane: w ruchu skrzydeł dalej nie widać."
	items = list(
		/obj/machinery/ship_weapon/vls = 1,
		/obj/item/ship_weapon/ammunition/torpedo = 2,
		/obj/machinery/ship_weapon/mac = 1,
		/obj/item/ship_weapon/ammunition/railgun_ammo = 2,
		/obj/machinery/computer/ship/munitions_computer = 2,
		/obj/item/multitool = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_564/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/moth = locate(/mob/living/carbon/human) in spawned
	if(!moth)
		return
	moth.dna.features["moth_wings"] = "Monarch"
	moth.set_species(/datum/species/moth)
	moth.real_name = "Ćma testowa"
	moth.name = moth.real_name
