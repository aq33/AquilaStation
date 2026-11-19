/datum/test_chamber_kit/pr_672_boty
	name = "Boty na drzewach zachowań: stare boty jako basic boty i nowe boty"
	pr = "aq33/AquilaStation#672"
	description = "Komora jest poza okrętem, więc patrol po nadajnikach i windy dla botów sprawdź na prawdziwej mapie; tu praca, panel i emag. \
	1) Medibot: zrań się (nóż) i stań obok – medibot podjeżdża i leczy; przewróć go prawym przyciskiem (w trybie intencji na rozbrajaniu), prosi o pomoc, postaw go. Kerfuś i przytulobot obok: przytulobot przytula smutnego. \
	2) Cleanbot: rozlej krew/brud (kredki, odchody) – sprząta; w panelu włącz Szkodniki i wypuść mysz. Repairbot: przestaw podłogę łomem na poszycie, połóż kratę (2 pręty) – z żelazem i szkłem z zestawu stawia szyby i ściany na dźwigarach (włóż arkusze do bota). \
	3) Panel (klik ręką): przełącznik Osobowość – jako duch kliknij bota, masz go przejąć; Zmień nazwę; karta pAI w otwartym panelu. Emag: pierwszy odblokowuje, drugi przy otwartym panelu (śrubokręt) hakuje – zhakowany medibot truje, cleanbot pryska kwasem, securitron ściga wszystkich. \
	4) Securitron i ED-209: zaatakuj ich w combat mode – ścigają i ogłuszają, securitron skuwa. Firebot: podpal się (zapalniczka na plamie paliwa) – gasi. \
	5) Nowe boty: Vibebot (podejdź – impreza i kolory), Doctor Acula (pobiera krew do worków i daje ciastka), BarBuddy (podaje drinka, gdy masz pustą rękę), Cambot (robi zdjęcia), Chefbot (krytykuje kanapkę z zestawu), Digbot (kopie skałę – sprawdź na asteroidzie), Farmbot i żółwik (podlewają tacę), Frightbot, Screambot, tyłkobot, D.E.D.bot (tylko z uplinka za 8 TC: kupującego oszczędza, tnie każdego poza Syndykatem – uważaj), eldritchowe boty (same wybuchają po minucie). \
	6) Konsola SI i PDA (program Zdalny kontroler botów): basic boty są na liście, wezwanie działa (na okręcie także na inny pokład przez windę). Admin: verb Debug → Pokaż drzewo zachowań na bocie."
	items = list(
		/mob/living/basic/bot/medbot = 1,
		/mob/living/basic/bot/medbot/catmedbot = 1,
		/mob/living/basic/bot/medbot/hugbot = 1,
		/mob/living/basic/bot/cleanbot = 1,
		/mob/living/basic/bot/repairbot = 1,
		/mob/living/basic/bot/secbot = 1,
		/mob/living/basic/bot/firebot = 1,
		/mob/living/basic/bot/vibebot = 1,
		/mob/living/basic/bot/bloodbot = 1,
		/mob/living/basic/bot/barbuddy = 1,
		/mob/living/basic/bot/cambot = 1,
		/mob/living/basic/bot/chefbot = 1,
		/mob/living/basic/bot/farmbot = 1,
		/mob/living/basic/bot/frightbot = 1,
		/mob/living/basic/bot/screambot = 1,
		/obj/item/plant_tray = 1,
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/rods/fifty = 1,
		/obj/item/crowbar = 1,
		/obj/item/screwdriver = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/card/emag = 1,
		/obj/item/paicard = 1,
		/obj/item/food/sandwich = 1,
		/obj/item/toy/crayon/red = 2,
	)
