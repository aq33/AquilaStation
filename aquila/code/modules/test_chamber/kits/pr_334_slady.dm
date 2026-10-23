// aq33/AquilaStation#334 - ślady zależne od butów i nóg (port Yogstation#21511)

/datum/test_chamber_kit/pr_334
	name = "PR 334: ślady butów, łap i pazurów"
	pr = "aq33/AquilaStation#334"
	description = "Załóż buty i przejdź przez krew: ślady stóp (examine - polska nazwa i opis). Testowe buty \"łapy\" i \"pazury\" udają nogi małpy i pazury - \
	ich ślady mają mieć inny sprite i nazwę (ślady łap / ślady pazurów) i NIE łączyć się ze śladami innego rodzaju ani innej krwi (krew xeno, olej). \
	Leżący gotowy ślad ma być widoczny. Zakrwaw nóż o kałużę i połóż go na stole - nakładka krwi nie może przeciekać na stół ani inne obiekty. Mydło czyści."
	items = list(
		/obj/item/clothing/shoes/sneakers/black = 1,
		/obj/item/clothing/shoes/sneakers/white/pr_334_paws = 1,
		/obj/item/clothing/shoes/sneakers/white/pr_334_claws = 1,
		/obj/effect/decal/cleanable/blood = 1,
		/obj/effect/decal/cleanable/xenoblood = 1,
		/obj/effect/decal/cleanable/oil = 1,
		/obj/effect/decal/cleanable/blood/footprints = 1,
		/obj/item/kitchen/knife = 1,
		/obj/structure/table = 1,
		/obj/item/soap = 1,
	)

/obj/item/clothing/shoes/sneakers/white/pr_334_paws
	name = "testowe buty \"łapy\""
	footprint_sprite = FOOTPRINT_SPRITE_PAWS

/obj/item/clothing/shoes/sneakers/white/pr_334_claws
	name = "testowe buty \"pazury\""
	footprint_sprite = FOOTPRINT_SPRITE_CLAWS
