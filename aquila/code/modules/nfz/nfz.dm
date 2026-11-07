// AQUILA - dział medyczny w barwach NFZ (turkus, genetyka fioletowa, chemia pomarańczowa, wirusologia zielona).
// Mundury, fartuchy, kitle, czapki, plecaki, rękawiczki, kombinezony bio, szafki, automaty i słuchawki z arkusza medycy.dmi
// wpisane w miejsce stanów medycyny. Nowe przedmioty z arkusza (czepki, bandana, fartuch chirurgiczny, golf ordynatora, kitle,
// torby, buty, czarne rękawiczki, pilot ordynatora) mają grafikę w aquila/icons/nfz/. Profesje i kanał radia bez zmian.

/****************************\
|********** dekale ***********|
\****************************/
// Niebieskie dekale w obszarach medycznych na mapach są podmienione na te podtypy (te same kształty).
// Jasny turkus z palety arkusza medycy.dmi (rozjaśnienia szafek i mundurów): pasuje do działu, a ciemniejszy mundur odcina się od podłogi.
#define NFZ_DECAL_COLOR "#52CCC2"

/obj/effect/turf_decal/tile/ship/blue/nfz
	name = "turkusowy narożnik NFZ"
	color = NFZ_DECAL_COLOR

/obj/effect/turf_decal/tile/blue/nfz
	name = "turkusowy narożnik NFZ"
	color = NFZ_DECAL_COLOR

/obj/effect/turf_decal/tile/blue/flat_side/nfz
	name = "turkusowy bok NFZ"
	color = NFZ_DECAL_COLOR

#undef NFZ_DECAL_COLOR

/****************************\
|********** automaty *********|
\****************************/
/obj/machinery/vending/wardrobe/medi_wardrobe
	name = "\improper Mundurownia NFZ"
	desc = "Automat z odzieżą roboczą NFZ dla personelu medycznego."
	vend_reply = "Dziękujemy, NFZ dba o Twój styl!"
	light_color = LIGHT_COLOR_CYAN

/obj/item/vending_refill/wardrobe/medi_wardrobe
	machine_name = "Mundurownia NFZ"

/obj/machinery/vending/wardrobe/chem_wardrobe
	name = "\improper Mundurownia NFZ (chemia)"
	vend_reply = "Dziękujemy, NFZ dba o Twój styl!"
	light_color = LIGHT_COLOR_ORANGE

/obj/item/vending_refill/wardrobe/chem_wardrobe
	machine_name = "Mundurownia NFZ (chemia)"

/obj/machinery/vending/wardrobe/gene_wardrobe
	name = "\improper Mundurownia NFZ (genetyka)"
	vend_reply = "Dziękujemy, NFZ dba o Twój styl!"
	light_color = LIGHT_COLOR_LAVENDER

/obj/item/vending_refill/wardrobe/gene_wardrobe
	machine_name = "Mundurownia NFZ (genetyka)"

/obj/machinery/vending/wardrobe/viro_wardrobe
	name = "\improper Mundurownia NFZ (wirusologia)"
	vend_reply = "Dziękujemy, NFZ dba o Twój styl!"
	light_color = LIGHT_COLOR_GREEN

/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "Mundurownia NFZ (wirusologia)"

/****************************\
|***** hełmy plazmoludzi *****|
\****************************/
// Kolory greyscale (podstawa, pas, środkowy pasek) dobrane do kombinezonów środowiskowych z arkusza NFZ
/obj/item/clothing/head/helmet/space/plasmaman/medical
	greyscale_colors = "#029F98#AF2747#165D6B"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	greyscale_colors = "#029F98#AF2747#17171F"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	greyscale_colors = "#B8B6A5#6D4D96#737365"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	greyscale_colors = "#B8B6A5#D4752C#737365"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	greyscale_colors = "#B8B6A5#31875F#737365"

/****************************\
|*********** szafki **********|
\****************************/
// Szafka chemiczna miała korpus zwykłej szafki medycznej, arkusz rysuje dla niej własny (stany chemical, chemical_open, chemical_back)
/obj/structure/closet/secure_closet/chemical
	icon_state = "chemical"

/****************************\
|******* ubrania i rzeczy ****|
\****************************/
// Kurtka zimowa zapina się Alt+klikiem, a opuszczony kaptur widać na plecach (aquila/code/modules/clothing/suits/wintercoat_zip.dm)
/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "kurtka zimowa NFZ"
	hood_down_state = "winterhood_medical_down"

/obj/item/clothing/under/ship/medical
	name = "kombinezon lekarza NFZ"

/obj/item/clothing/under/rank/medical/doctor
	name = "kombinezon lekarza NFZ"

/obj/item/clothing/under/rank/medical/chief_medical_officer
	name = "kombinezon ordynatora NFZ"

/obj/item/clothing/under/rank/medical/geneticist
	name = "kombinezon genetyka NFZ"

/obj/item/clothing/under/rank/medical/chemist
	name = "kombinezon chemika NFZ"

/obj/item/clothing/under/rank/medical/virologist
	name = "kombinezon wirologa NFZ"

/obj/item/clothing/suit/toggle/labcoat/cmo
	name = "fartuch laboratoryjny Ordynatora NFZ"

/obj/item/clothing/suit/toggle/labcoat/genetics
	name = "fartuch laboratoryjny genetyka NFZ"

/obj/item/clothing/suit/toggle/labcoat/chemist
	name = "fartuch laboratoryjny chemika NFZ"

/obj/item/clothing/suit/toggle/labcoat/virologist
	name = "fartuch laboratoryjny wirologa NFZ"

/obj/item/clothing/head/beret/med
	name = "beret NFZ"

/obj/item/clothing/head/beret/cmo
	name = "beret ordynatora NFZ"

/obj/item/clothing/head/soft/paramedic
	name = "czapka NFZ"

/obj/item/storage/backpack/medic
	name = "plecak NFZ"

/obj/item/storage/backpack/satchel/med
	name = "torba na ramię NFZ"

/obj/item/storage/backpack/duffelbag/med
	name = "torba podróżna NFZ"

// Pilot ordynatora ma własną grafikę: stan gangtool-blue dzieli z nadajnikiem wyboru
/obj/item/door_remote/chief_medical_officer
	icon = 'aquila/icons/nfz/nfz.dmi'
	icon_state = "door_remote"

/****************************\
|****** nowe przedmioty ******|
\****************************/
/obj/item/clothing/head/nfz
	icon = 'aquila/icons/nfz/nfz.dmi'
	w_class = WEIGHT_CLASS_SMALL // materiałowe czepki i bandana mieszczą się w kieszeni jak czapka zimowa
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	// bandana nie przycina fryzury (domyślne +generic ją obcinało), czepki chowają włosy całkiem przez HIDEHAIR
	dynamic_hair_suffix = ""

/obj/item/clothing/head/nfz/surgerycap
	flags_inv = HIDEHAIR
	name = "czepek chirurgiczny NFZ"
	desc = "Turkusowy czepek, który trzyma włosy z dala od pola operacyjnego."
	icon_state = "surgerycap"

/obj/item/clothing/head/nfz/bouffant
	flags_inv = HIDEHAIR
	name = "czepek bufiasty NFZ"
	desc = "Obszerny czepek chirurgiczny na bujniejsze fryzury."
	icon_state = "bouffant"

/obj/item/clothing/head/nfz/bandana
	name = "bandana NFZ"
	desc = "Turkusowa bandana personelu medycznego."
	icon_state = "bandana"

/obj/item/clothing/suit/apron/surgical/nfz
	name = "fartuch operacyjny NFZ"
	desc = "Sterylny niebieski fartuch operacyjny z długimi rękawami."
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "surgicalcoat"
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck
	name = "golf ordynatora NFZ"
	desc = "Turkusowy golf z insygniami ordynatora. Daje słabą ochronę biologiczną."
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "cmoturtle"

/obj/item/clothing/under/rank/medical/doctor/nfz
	name = "strój chirurgiczny NFZ"
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest turkusowy."
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "scrubs_medic"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/nfz/magenta
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest amarantowy."
	icon_state = "scrubs_magenta"

/obj/item/clothing/under/rank/medical/doctor/nfz/orange
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest pomarańczowy."
	icon_state = "scrubs_chemist"

/obj/item/storage/backpack/duffelbag/med/genetics
	name = "torba podróżna genetyka"
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "duffel-gene"

/obj/item/storage/backpack/duffelbag/med/chemistry
	name = "torba podróżna chemika"
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "duffel-chemist"

/obj/item/storage/backpack/duffelbag/med/virology
	name = "torba podróżna wirologa"
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "duffel-viro"

/obj/item/clothing/gloves/color/latex/black
	name = "czarne rękawiczki lateksowe"
	desc = "Tanie, sterylne rękawiczki z lateksu, w czerni."
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "latex_black"
	worn_icon_state = "latex_black"

/obj/item/clothing/shoes/nfz
	name = "buty medyczne NFZ"
	desc = "Lekkie białe buty, w których da się przestać cały dyżur."
	icon = 'aquila/icons/nfz/nfz.dmi'
	worn_icon = 'aquila/icons/nfz/nfz_noszone.dmi'
	icon_state = "shoes"
	permeability_coefficient = 0.01

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/turtleneck(src)
