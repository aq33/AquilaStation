// aq33/AquilaStation#642 - kompaktowy HUD sternika i archetypy KNPC

/datum/test_chamber_kit/pr_642
	name = "Sterowanie (radar i pasek) i archetypy KNPC"
	pr = "aq33/AquilaStation#642"
	description = "Na arenie stoi myśliwiec, a obok pięciu nowych KNPC Syndykatu (szturmowiec, medyk, saper, wartownik, dowódca). Uwaga: komora jest na pokładzie, więc KNPC walczą od razu. Najpierw zbadaj ich z daleka albo załóż pancerz; myśliwiec testuj przed rozstawieniem KNPC albo po walce. \
	1) Wejdź do myśliwca → w prawym górnym rogu okrągły radar ze strzałką w środku, nad dłońmi pasek: Hamulec, Ster, Broń z amunicją, Kadłub %, Katapulta, DRADIS. Ekwipunek postaci znika, dłonie i przyciski akcji zostają. Okno DRADIS NIE otwiera się samo. \
	2) Klik w Hamulec, Ster i Broń → stan się zmienia i napis na pasku też. Alt, C i spacja → pasek od razu pokazuje nowy stan. Klik w radar albo DRADIS → pełne okno DRADIS. Shift+klik na radar i pasek → opis w czacie. \
	3) Katapulta: jeden klik → napis „Potwierdź katapultę!” na czerwono; negatyw: na pokładzie drugi klik daje odmowę jak dotąd. Po 5 s napis wraca. \
	4) Wyjdź z myśliwca → radar i pasek znikają, ekwipunek wraca. Czasownik „Pokaż/ukryj panel konsoli” chowa radar i pasek. Preferencje → „Klasyczny panel sterowania” → po ponownym wejściu stary duży panel i samootwierające się okno DRADIS. \
	5) KNPC: zbadaj każdego (examine) → szturmowiec w ODST z C-20r w plecaku, medyk z zieloną torbą medyczną, saper ze spawarką w ręce, wartownik ze strzelbą bojową w ręce, dowódca z czerwonymi dokumentami w plecaku. W walce medyk leczy rannego kolegę medipenem, saper rzuca granaty, a wartownik po opróżnieniu strzelby dobywa pistoletu."
	items = list(
		/obj/structure/overmap/small_craft/combat/light = 1,
		/mob/living/carbon/human/ai_boarder/syndicate/assault = 1,
		/mob/living/carbon/human/ai_boarder/syndicate/medic = 1,
		/mob/living/carbon/human/ai_boarder/syndicate/sapper = 1,
		/mob/living/carbon/human/ai_boarder/syndicate/sentry = 1,
		/mob/living/carbon/human/ai_boarder/syndicate/commander = 1,
	)
