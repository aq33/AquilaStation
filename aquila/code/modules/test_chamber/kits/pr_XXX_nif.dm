/datum/test_chamber_kit/pr_XXX_nif
	name = "PR XXX: NIF (Nanitowa Platforma Implantów)"
	pr = "aq33/AquilaStation#XXX"
	description = "1) Autochirurg z NIF typu Standard na siebie: kalibracja trwa kilka minut, na początku chwilowa ślepota, potem drobne mdłości lub zmęczenie. \
	2) Po kalibracji akcja okna NIF-u: zasilanie z jedzenia i z krwi, lista programów, Poemat Wspólnych Dusz. \
	3) Testowy NIF jest skalibrowany od razu: wgraj dyski (soczewka medyczna z adapterem okularów, rój umysłów dla dwóch osób, automatyczna wycena). \
	4) EMP (granat z zestawu): NIF psuje się na 30 s i traci wytrzymałość, regenerator ją przywraca. Przecinak usuwa NIFSoft. \
	5) Katalog NIFSoftów w PDA: kupno programu instaluje go w NIF-ie kupującego. \
	Sprawdź kliknięcia w obu trybach sterowania (combat mode i intencje)."
	items = list(
		/obj/item/autosurgeon/nif = 1,
		/obj/item/autosurgeon/nif/debug = 2,
		/obj/item/autosurgeon/nif/econo = 1,
		/obj/item/disk/nifsoft_uploader/med_hud = 1,
		/obj/item/disk/nifsoft_uploader/hivemind = 2,
		/obj/item/disk/nifsoft_uploader/money_sense = 1,
		/obj/item/nif_hud_adapter = 1,
		/obj/item/clothing/glasses/regular = 1,
		/obj/item/nif_repair_kit = 1,
		/obj/item/nifsoft_remover = 1,
		/obj/item/grenade/empgrenade = 1,
	)
