/datum/test_chamber_kit/pr_mob_mining
	name = "Moby górnicze (basic moby)"
	pr = "aq33/AquilaStation#XXX"
	description = "Wrogie moby górnicze jako basic moby z tg. Ustaw się kilka pól od nich (najlepiej z kinetycznym miażdżycielem albo laserem). \
		1) Władca roju trzyma dystans i wypuszcza pomioty, które gryzą; uderzony wypuszcza pomiot od razu; po śmierci zostawia rdzeń regeneracyjny i trzy pomioty. \
		2) Legion trzyma dystans 4-6 pól i wystrzeliwuje czaszki (znacznik celu na ziemi, czaszka spada z góry); czaszka leczy rannego sojusznika z frakcji górniczej, a człowieka nieprzytomnego zamienia w nowego legiona z ciałem w środku. Zabity legion wypuszcza ciało i rdzeń legionu; legion bez ciała zostawia zwłoki górnika. \
		3) Karłowaty legion jest mniejszy i szybszy. \
		4) Duch może przejąć władcę roju (klik duchem); w obu trybach sterowania klik w coś daleko wypuszcza pomiot, a przycisk zdolności celuje nim."
	items = list(
		/mob/living/basic/mining/hivelord = 1,
		/mob/living/basic/mining/legion = 1,
		/mob/living/basic/mining/legion/dwarf = 1,
	)
