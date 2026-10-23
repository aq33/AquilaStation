// aq33/AquilaStation#413 - combat mode z BeeStation + stary tryb intencji jako preferencja

/datum/test_chamber_kit/pr_413
	name = "PR 413: combat mode - prawy klik i broń"
	pr = "aq33/AquilaStation#413"
	description = "Tryb walki przełączasz klawiszem F albo ikoną w HUD. Prawy przycisk to akcja dodatkowa: strzykawka pobiera krew z małpy, klucz i śrubokręt na prawym na krześle, stole, szafie i szafce na akta, \
	prawy na stosie metalu dzieli stos, RCD prawym rozbiera, akcelerator kinetyczny prawym otwiera menu modów, crusher prawym strzela, strzelba z hakiem prawym rzuca hak, katana ninja prawym robi zryw. \
	Ctrl+klik to chwyt, Shift+prawy otwiera menu kontekstowe, Alt+lewy/Alt+prawy obraca krzesło. Śluza: spawarka naprawia, prawy zaspawuje. Okno: bez trybu walki pukasz, w trybie walki walisz. \
	Książka CQC: licznik kombinacji w HUD i okno poradnika. W trybie walki strzał z przyłożenia uderza kolbą, bez niego strzela. \
	Potem włącz w Preferencjach „Stary tryb intencji”: cztery intencje w HUD, harm = walka, disarm = prawy klik, prawy przycisk znów otwiera menu."
	items = list(
		/mob/living/carbon/monkey = 2,
		/mob/living/carbon/human = 1,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/structure/chair = 1,
		/obj/structure/table = 1,
		/obj/structure/closet = 1,
		/obj/structure/filingcabinet = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/item/gun/energy/kinetic_accelerator = 1,
		/obj/item/borg/upgrade/modkit/cooldown = 1,
		/obj/item/kinetic_crusher = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel/hook = 1,
		/obj/item/energy_katana = 1,
		/obj/item/weldingtool/largetank = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/window/reinforced = 1,
		/obj/item/book/granter/martial/cqc = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
	)
