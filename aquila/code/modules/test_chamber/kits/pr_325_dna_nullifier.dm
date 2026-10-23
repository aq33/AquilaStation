// aq33/AquilaStation#325 - DNA nullifier + QoL ręcznego skanera sekwencji (port Bee#9403)

/datum/test_chamber_kit/pr_325
	name = "PR 325: DNA nullifier i skaner sekwencji"
	pr = "aq33/AquilaStation#325"
	description = "Wstrzyknij człowiekowi testowemu injectory (x-ray, telekineza, niezdarność). Ręczny skaner sekwencji na nim: mają być widoczne wstrzyknięte mutacje i stabilność genetyczna. \
	Połóż go w skanerze DNA, w konsoli przy aktywnej mutacji wydrukuj DNA nullifier (cooldown 3x dłuższy niż zwykły injector). \
	Nullifier ma własny sprite, po użyciu pusty \"dnanullifier0\"; mutacja ma zniknąć, a w logu ataków ma być wpis o usuniętej mutacji."
	items = list(
		/obj/machinery/dna_scannernew = 1,
		/obj/machinery/computer/scan_consolenew = 1,
		/obj/item/sequence_scanner = 1,
		/obj/item/dnainjector/xraymut = 1,
		/obj/item/dnainjector/telemut = 1,
		/obj/item/dnainjector/clumsymut = 1,
		/mob/living/carbon/human = 1,
	)
