// aq33/AquilaStation#390 - higiena: poprawki, miazma od brudasów, Czyścioszek, bramka Hygiene, hygienebot

/datum/test_chamber_kit/pr_390
	name = "PR 390: higiena i hygienebot"
	pr = "aq33/AquilaStation#390"
	description = "Człowiek testowy jest brudny: z odległości do 2 kratek examine ma mówić, że śmierdzi, a wokół niego powoli zbiera się miazma (analizator). \
	Hygienebot ma go ścigać i umyć do normalnego poziomu (także w ubraniu); po emagu podpala. Szoruj mydłem drugiego człowieka - +20 higieny, mydło na usta myje cel, nie ciebie. \
	Bramka skanera: tryb Hygiene (Clean/Dirty) w oknie, przejdź przez nią brudnym i czystym. \
	Budowa bota: z 2 arkuszy żelaza zrób hygienebot assembly, spawarka -> czujnik zbliżeniowy -> rura (ducts). \
	Quirk Czyścioszek sprawdź w preferencjach (nie może iść razem z Socjalsem)."
	items = list(
		/mob/living/carbon/human = 2,
		/mob/living/simple_animal/bot/hygienebot = 1,
		/obj/machinery/scanner_gate = 1,
		/obj/item/soap = 1,
		/obj/item/card/emag = 1,
		/obj/item/analyzer = 1,
		/obj/item/stack/sheet/iron/five = 1,
		/obj/item/weldingtool = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/stack/ducts/fifty = 1,
	)

/datum/test_chamber_kit/pr_390/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Pierwszy człowiek jest brudasem do testów, drugi zostaje czysty
	for(var/mob/living/carbon/human/H in spawned)
		if(istype(H, /mob/living/carbon/human/ai_boarder))
			continue
		H.set_hygiene(HYGIENE_LEVEL_DISGUSTING)
		H.name = "brudas testowy"
		H.real_name = H.name
		break
