// aq33/AquilaStation#701 - wspomnienia z tg: okno wspomnień, dłuto i ryciny, zestaw do tatuażu

/datum/test_chamber_kit/pr_701
	name = "PR 701: wspomnienia, ryciny i tatuaże"
	pr = "aq33/AquilaStation#701"
	description = "Twoja postać dostaje trzy wspomnienia (operacja, podpalenie, zabicie megafauny), a obok stawia się ściana. \
	1) Werb Notes: okno ma sekcję „Wspomnienia” z ikonami wartości (klucz przy numerze konta, gwiazdki, korona) i podpowiedziami po najechaniu. \
	2) Weź dłuto, kliknij ścianę prawym przyciskiem (w starych intencjach: na intencji rozbrajania) → okno wyboru wspomnienia, po 5 s rycina na ścianie; obejrzyj ścianę: opowieść po polsku z datą, potem 2 s oceniania i nastrój za sztukę. Ponowne rycie tej ściany: „ta ściana ma już rycinę!”; użyte wspomnienie znika z wyboru. \
	3) Zestaw do tatuażu bez trybu walki na manekinie (wybierz część ciała na kukle) → po 5 s tatuaż; obejrzyj manekina (bez ubrania na tej części ciała widać tatuaż, w kombinezonie na tułowiu nie). Z trybem walki zestaw zwyczajnie uderza. Toner uzupełnia tusz (zestaw jest pełny przy 5). \
	4) Drugi manekin ma już tatuaż na lewej ręce. \
	5) Zapis rycin między rundami działa tylko dla ścian w technicznych i więzieniu na statku (komora się nie liczy)."
	items = list(
		/obj/item/chisel = 1,
		/obj/item/tattoo_kit = 1,
		/obj/item/toner = 1,
		/mob/living/carbon/human = 2,
	)

/datum/test_chamber_kit/pr_701/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(user?.mind)
		user.add_mob_memory(/datum/memory/surgery, deuteragonist = "manekin", surgery_type = "wycięcie wyrostka")
		user.add_mob_memory(/datum/memory/was_burning)
		user.add_mob_memory(/datum/memory/megafauna_slayer, antagonist = "smok popielny")
	var/tattooed = FALSE
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.name = tattooed ? "manekin do tatuażu" : "wytatuowany manekin"
		dummy.real_name = dummy.name
		if(!tattooed)
			tattooed = TRUE
			var/obj/item/bodypart/arm = dummy.get_bodypart(BODY_ZONE_L_ARM)
			arm?.AddComponent(/datum/component/tattoo, "Tatuaż przedstawia scenę: kucharz staje w płomieniach. Na tatuażu płonie wielka czaszka.")
	for(var/turf/open/candidate in turfs)
		if(candidate == center || (locate(/mob) in candidate) || (locate(/obj) in candidate))
			continue
		candidate.ChangeTurf(/turf/closed/wall)
		break
