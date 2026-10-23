// aq33/AquilaStation#388 - poprawki AI boarderów KNPC

/datum/test_chamber_kit/pr_388
	name = "PR 388: AI boarderów KNPC"
	pr = "aq33/AquilaStation#388"
	description = "UWAGA: syndykaci i pirat strzelają do załogi i do siebie nawzajem. Sprawdź: ranny KNPC bez wroga w zasięgu wzroku wstrzykuje sobie medipen \
	i nie wysypuje plecaka (rzeczy w plecaku po śmierci mają zostać w plecaku). Strzelby/pistolety z nabojami są przeładowywane, puste wyrzucane, nie strzelają. \
	Nieuzbrojony felinid ma iść po leżący pistolet (jeśli nie dojdzie, np. za szybą, zapomina o nim). Wezwanie wsparcia: odpowiadają tylko KNPC tej samej frakcji (pirat nie). \
	Zamknięty w szafie asystent ma się z niej wyłamać (resist), a nie próbować open() w nieskończoność. Gdy KNPC zabierze ofierze ID, ofiara ma je stracić (bez duplikatu). \
	W komorze nie ma punktów patrolu, więc patrolu tu nie zobaczysz."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 2,
		/mob/living/carbon/human/ai_boarder/space_pirate/pistol = 1,
		/mob/living/carbon/human/ai_boarder/assistant/felinid = 1,
		/obj/structure/closet/secure_closet = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_388/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Zwykły asystent KNPC ląduje w zamkniętej szafie, żeby sprawdzić wyłamywanie się
	var/obj/structure/closet/secure_closet/closet = locate() in spawned
	if(!closet)
		return
	new /mob/living/carbon/human/ai_boarder/assistant(closet)
	closet.locked = TRUE
	closet.update_icon()
