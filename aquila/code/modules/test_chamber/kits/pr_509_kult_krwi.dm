/datum/test_chamber_kit/pr_509
	name = "Kult krwi Cult 4 (Monkestation/vgstation)"
	pr = "aq33/AquilaStation#509"
	description = "Pierwszy człowiek jest kultystą z 600 punktami devotion (Wspólnota krwi i Krwawy sztylet), drugi i trzeci to ofiary. Przejmij kultystę. \
		Panel kultu: przycisk w lewym górnym rogu (członkowie, rola, rytuały, Zaćmienie, pomoc). Tom: pisanie słów run krwią, talizmany. \
		Runy: Konwersja na drugim człowieku (odmowa albo więzienie), Komunikacja, Akcesoria, Wzniesienie Budowli (ołtarz, iglica, kuźnia), Ujawnienie/Ukrycie, Ścieżki. \
		Rytuały: małpa i mysz na ołtarzu, zakrwawiona podłoga. Kamień dusz i klejnot: konstrukty (też hex i doskonałe). Kapelan: Biblia + woda święcona na kultyście = dekonwersja, sól na runie. \
		Zaćmienie przyspiesz z panelu admina (VV drużyny: eclipse_progress = eclipse_target), potem runa Tear Reality, taniec i Krwawy Kamień."
	items = list(
		/mob/living/carbon/human = 3,
		/mob/living/carbon/monkey = 1,
		/mob/living/simple_animal/mouse = 1,
		/obj/item/tome = 1,
		/obj/item/talisman = 3,
		/obj/item/kitchen/knife/ritual = 1,
		/obj/item/melee/cultblade = 1,
		/obj/item/soulstone = 1,
		/obj/item/soulstone/gem = 1,
		/obj/item/stack/sheet/runed_metal/twenty = 1,
		/obj/item/candle/blood = 3,
		/obj/item/reagent_containers/glass/cult/bloodfilled = 1,
		/obj/item/storage/book/bible = 1,
		/obj/item/nullrod = 1,
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 1,
		/obj/item/reagent_containers/food/condiment/saltshaker = 1,
	)

/datum/test_chamber_kit/pr_509/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/cultist_mob = locate() in spawned
	if(!cultist_mob)
		return
	cultist_mob.mind_initialize()
	// mob bez klienta nie przechodzi is_convertable_to_cult
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	var/datum/antagonist/cult/cultist = cultist_mob.mind.add_antag_datum(new_cultist)
	cultist?.gain_devotion(600, DEVOTION_TIER_4)
	cultist_mob.name = "kultysta testowy"
	cultist_mob.real_name = cultist_mob.name
