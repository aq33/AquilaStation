// aq33/AquilaStation#388 - poprawki AI boarderów KNPC

/datum/test_chamber_kit/pr_388
	name = "PR 388: AI boarderów KNPC"
	pr = "aq33/AquilaStation#388"
	description = "UWAGA: syndykaci i pirat strzelają do załogi i do siebie nawzajem; nieuzbrojony felinid jest sojusznikiem obu frakcji. Leczenie medipenem i kradzież ID mają osobne zestawy. \
	1) Strzelby/pistolety z nabojami → oczekiwane: są przeładowywane, puste wyrzucane i nie strzelają. \
	2) Zabij uzbrojonego KNPC z plecakiem → oczekiwane: rzeczy w plecaku zostają w plecaku (nie wysypują się). \
	3) Felinid ma iść po leżący obok pistolet → oczekiwane: podnosi go i zaczyna uzbrojony walczyć; zamknij go za szybą/ścianą → oczekiwane: po nieudanej drodze zapomina o pistolecie. \
	4) Wezwanie wsparcia: zaatakuj jednego syndykatu → oczekiwane: odpowiada drugi syndykat; pirat NIE odpowiada (inna frakcja). \
	5) Zamknięty w szafie asystent → oczekiwane: wyłamuje się (resist), a nie próbuje open() w nieskończoność. \
	6) W komorze nie ma punktów patrolu, więc patrolu tu nie zobaczysz."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 2,
		/mob/living/carbon/human/ai_boarder/space_pirate/pistol = 1,
		/mob/living/carbon/human/ai_boarder/assistant/felinid = 1,
		/obj/structure/closet/secure_closet = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_388/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Pistolet leży blisko felinida (kilka kratek dalej, nie pod nogami), żeby uzbrojeni KNPC nie byli pierwsi
	var/mob/living/carbon/human/ai_boarder/assistant/felinid/cat = locate() in spawned
	var/obj/item/gun/ballistic/automatic/pistol/pistol = locate() in spawned
	if(cat && pistol)
		var/turf/gun_spot = get_step(get_step(cat, EAST), EAST)
		if(gun_spot && !gun_spot.density)
			pistol.forceMove(gun_spot)
	// Zwykły asystent KNPC ląduje w zamkniętej szafie, żeby sprawdzić wyłamywanie się
	var/obj/structure/closet/secure_closet/closet = locate() in spawned
	if(!closet)
		return
	new /mob/living/carbon/human/ai_boarder/assistant(closet)
	closet.locked = TRUE
	closet.update_icon()

/datum/test_chamber_kit/pr_388_heal
	name = "PR 388: ranny KNPC leczy się medipenem"
	pr = "aq33/AquilaStation#388"
	description = "Jeden syndykat z pistoletem, ranny poniżej połowy HP, ma survival medipen w kieszeni. \
	1) Wyjdź mu z pola widzenia (aghost albo stań za ścianą) → oczekiwane: ranny KNPC bez wroga w zasięgu wzroku wstrzykuje sobie medipen i odrzuca pusty na podłogę; HP rośnie. \
	2) Negatyw: jeśli po wstrzyknięciu KNPC nadal ma poniżej połowy HP → oczekiwane: nie leczy się drugi raz (medipen był jeden, pusty leży na podłodze i nie jest brany ponownie). \
	3) Wejdź mu w pole widzenia przed wstrzyknięciem → oczekiwane: KNPC zajmuje się walką z tobą (leczenie dotyczy sytuacji poza walką) - zanotuj, co robi."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 1,
	)

/datum/test_chamber_kit/pr_388_heal/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/mob/living/carbon/human/knpc = locate() in spawned
	if(!knpc)
		return
	knpc.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/medipen/survival(knpc), ITEM_SLOT_LPOCKET)
	knpc.adjustBruteLoss(round(knpc.maxHealth * 0.6))

/datum/test_chamber_kit/pr_388_id
	name = "PR 388: KNPC zabiera ID ofierze"
	pr = "aq33/AquilaStation#388"
	description = "Syndykat z pistoletem i unieruchomiony człowiek z kartą ID na szyi (sparaliżowany na 2 minuty). \
	1) Obserwuj syndykata → oczekiwane: podchodzi do ofiary i po ok. 5 s zabiera jej kartę (komunikat \"zaczyna zabierać\"). \
	2) Sprawdź ofiarę → oczekiwane: nie ma już ID, a karta jest u KNPC tylko raz (bez duplikatu). \
	3) Negatyw: zdejmij ofierze ID przed próbą albo odciągnij ją od KNPC → oczekiwane: nie ma czego zabierać, brak błędów. \
	UWAGA: KNPC może zastrzelić ofiarę z dystansu zanim podejdzie - wtedy wywołaj zestaw ponownie."
	items = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_388_id/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/mob/living/carbon/human/victim
	for(var/mob/living/carbon/human/H in spawned)
		if(!istype(H, /mob/living/carbon/human/ai_boarder))
			victim = H
	if(!victim)
		return
	var/obj/item/card/id/card = new(victim)
	card.registered_name = "Ofiara testowa"
	card.update_label()
	victim.equip_to_slot_or_del(card, ITEM_SLOT_ID)
	victim.Paralyze(120 SECONDS)
