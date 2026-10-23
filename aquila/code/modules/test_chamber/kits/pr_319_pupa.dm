// aq33/AquilaStation#319 - pupa jako narząd z HippieStation13 (+ #350 ikony po *superfart, #385 małpy i butt pocket)

/datum/test_chamber_kit/pr_319
	name = "PR 319: pupa - kieszeń i emotki"
	pr = "aq33/AquilaStation#319"
	description = "Zdejmij kombinezon, wybierz groin i intencję grab: kliknij siebie/człowieka przedmiotem - po 4 s chowa go w pupie, pustą ręką - otwiera okno kieszeni. \
	Ubranie zamyka okno kieszeni. Wsadź zapalniczkę/klakson/megafon i zrób *fart (podpalenie, trąbienie, głośne pierdnięcie; 12% na utratę pupy). \
	*superfart: pupa wylatuje, zawartość wbija się w cele (3% na mały wybuch!). #350: po *superfart ikony przedmiotów NIE mogą zostać w lewym dolnym rogu HUD. \
	#385: małpy chodzą przez chwilę obok - nie mogą trzymać w ręce własnego butt_pocket. Pupę można rzucić (stamina) i założyć na głowę."
	items = list(
		/obj/item/lighter = 1,
		/obj/item/bikehorn = 1,
		/obj/item/megaphone = 1,
		/obj/item/reagent_containers/pill/patch = 2,
		/obj/item/organ/butt = 2,
		/obj/item/organ/butt/xeno = 1,
		/obj/item/organ/butt/bluebutt = 1,
		/obj/item/clothing/under/color/grey = 1,
		/mob/living/carbon/human = 1,
		/mob/living/carbon/monkey = 3,
	)

/datum/test_chamber_kit/pr_319_dodatki
	name = "PR 319: pupa - zszywacz, buttbot, kwiat"
	pr = "aq33/AquilaStation#319"
	description = "Zszywacz: z prętów zrób zszywki (menu prętów), naładuj zszywacz, zszyj człowieka, przyszyj papier do ściany, przyszyj pupę z powrotem (luźna). \
	Trumna: 10 zszywek ją zamyka, łom otwiera. Buttbot: mów obok - powtarza zdania z \"butt\" zamiast części słów. \
	Kwiat-pupa: zjedz - zostaje pupa; fartium wywołuje pierdzenie, bez pupy zadaje obrażenia toksyczne. Nasiona też w MegaSeed."
	items = list(
		/obj/item/staplegun = 1,
		/obj/item/stack/rods/twentyfive = 1,
		/obj/item/paper = 2,
		/obj/item/organ/butt = 1,
		/obj/structure/closet/crate/coffin = 1,
		/obj/item/crowbar = 1,
		/mob/living/simple_animal/bot/buttbot = 1,
		/obj/item/food/grown/buttflower = 2,
		/obj/item/plant_seeds/preset/butt = 1,
		/mob/living/carbon/human = 1,
	)
