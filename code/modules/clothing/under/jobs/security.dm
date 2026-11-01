/*
 * Contains:
 *		Security
 *		Detective
 *		Navy uniforms
 */

/*
 * Security
 */

/obj/item/clothing/under/rank/security/officer
	name = "policyjny kombinezon"
	desc = "Taktyczny policyjny kombinezon dla funkcjonariuszy, z klamrą pasa Nanotrasen."
	icon_state = "rsecurity"
	item_state = "r_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/officer/white
	name = "biały policyjny kombinezon"
	desc = "Taktyczny relikt z dawnych lat, zanim Nanotrasen uznało, że taniej jest farbować stroje na czerwono, niż spierać krew."
	icon_state = "security"
	item_state = "gy_suit"

/obj/item/clothing/under/rank/security/officer/corporate
	name = "korporacyjny policyjny kombinezon"
	desc = "Taktyczny policyjny kombinezon w czerni."
	icon_state = "sec_corporate_s"
	item_state = "bl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/skirt
	name = "policyjna spódnica"
	desc = "„Taktyczny” kombinezon ochrony, w którym nogawki zastąpiono spódnicą."
	icon_state = "secskirt"
	item_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE //you know now that i think of it if you adjust the skirt and the sprite disappears isn't that just like flashing everyone
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/officer/blueshirt
	name = "niebieska koszula z krawatem"
	desc = "Jestem teraz trochę zajęty, Calhoun."
	icon_state = "blueshift"
	item_state = "blueshift"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/formal
	name = "galowy mundur policjanta"
	desc = "Ostatni krzyk mody wśród strojów policyjnych."
	icon_state = "officerblueclothes"
	item_state = "officerblueclothes"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/warden
	name = "policyjny garnitur"
	desc = "Oficjalny policyjny garnitur dla funkcjonariuszy, z klamrą pasa Nanotrasen."
	icon_state = "rwarden"
	item_state = "r_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/warden/skirt
	name = "garsonka naczelnika"
	desc = "Oficjalna policyjna garsonka dla funkcjonariuszy, z klamrą pasa Nanotrasen."
	icon_state = "rwarden_skirt"
	item_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/warden/white
	name = "biały policyjny garnitur"
	desc = "Oficjalna pamiątka z dawnych lat, zanim Nanotrasen uznało, że taniej jest farbować garnitury na czerwono, niż spierać z nich krew."
	icon_state = "warden"
	item_state = "gy_suit"

/*
 * Detective
 */
/obj/item/clothing/under/rank/security/detective
	name = "znoszony garnitur"
	desc = "Kto to nosi, nie żartuje."
	icon_state = "detective"
	item_state = "det"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "stamina" = 20, "bleed" = 10)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/detective/skirt
	name = "garsonka detektywa"
	desc = "Kto to nosi, nie żartuje."
	icon_state = "detective_skirt"
	item_state = "det"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/detective/grey
	name = "garnitur noir"
	desc = "Szary garnitur twardego prywatnego detektywa, ze spinką do krawata."
	icon_state = "greydet"
	item_state = "greydet"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/grey/skirt
	name = "garsonka noir"
	desc = "Szara garsonka twardego prywatnego detektywa, ze spinką do krawata."
	icon_state = "greydet_skirt"
	item_state = "greydet"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/*
 * Head of Security
 */
/obj/item/clothing/under/rank/security/head_of_security
	name = "kombinezon komendanta"
	desc = "Zdobiony policyjny kombinezon dla nielicznych, którzy dzięki oddaniu dosłużyli się stanowiska komendanta."
	icon_state = "rhos"
	item_state = "r_suit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30, "bleed" = 10)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/head_of_security/skirt
	name = "spódnica komendanta"
	desc = "Zdobiona policyjna spódnica dla nielicznych, którzy dzięki oddaniu dosłużyli się stanowiska komendanta."
	icon_state = "rhos_skirt"
	item_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/white
	name = "biały kombinezon komendanta"
	desc = "Są starzy ludzie i są odważni ludzie, ale bardzo mało jest starych odważnych ludzi."
	icon_state = "hos"
	item_state = "gy_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "golf komendanta"
	desc = "Stylowa alternatywa dla zwykłego kombinezonu komendanta, z taktycznymi spodniami."
	icon_state = "hosalt"
	item_state = "bl_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	name = "golf ze spódnicą komendanta"
	desc = "Stylowa alternatywa dla zwykłego kombinezonu komendanta, z taktyczną spódnicą."
	icon_state = "hosalt_skirt"
	item_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/*
 * Brig Physician
*/

/obj/item/clothing/under/rank/brig_physician
	name = "kombinezon lekarza więziennego"
	desc = "Lekko opancerzony kombinezon noszony przez Korpus Medyczny Ochrony Mienia Nanotrasen."
	icon_state = "brig_phys"
	item_state = "labcoat_sec"

/obj/item/clothing/under/rank/brig_physician/skirt
	name = "spódnica lekarza więziennego"
	desc = "Lekko opancerzona spódnica noszona przez Korpus Medyczny Ochrony Mienia Nanotrasen."
	icon_state = "brig_phys_skirt"
	item_state = "labcoat_sec"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/*
 * Navy uniforms
 */

/obj/item/clothing/under/rank/security/head_of_security/parade/female
	name = "mundur galowy komendantki"
	desc = "Luksusowy strój komendantki na specjalne okazje."
	icon_state = "hos_parade_fem"
	item_state = "r_suit"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/warden/formal
	desc = "Insygnia na tym mundurze mówią ci, że należy do naczelnika."
	name = "galowy mundur naczelnika"
	icon_state = "wardenblueclothes"
	item_state = "wardenblueclothes"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/head_of_security/formal
	desc = "Insygnia na tym mundurze mówią ci, że należy do komendanta."
	name = "galowy mundur komendanta"
	icon_state = "hosblueclothes"
	item_state = "hosblueclothes"
	alt_covers_chest = TRUE

/*
 *Spacepol
 */

/obj/item/clothing/under/rank/security/officer/spacepol
	name = "mundur policyjny"
	desc = "Przestrzeń kosmiczna, której nie kontrolują megakorporacje, planety ani piraci, podlega jurysdykcji Kosmicznej Policji."
	icon_state = "spacepol"
	item_state = "spacepol"
	can_adjust = FALSE

/obj/item/clothing/under/rank/prisoner
	name = "więzienny kombinezon"
	desc = "Standardowy strój więzienny Nanotrasen. Czujniki kombinezonu zablokowały się w pozycji „w pełni włączone”."
	icon_state = "jumpsuit"
	greyscale_colors = "#ff8300"
	greyscale_config = /datum/greyscale_config/jumpsuit_prison
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_prison_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_prison_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_prison_worn
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/*
 * Triiodine's security uniforms
 */


/obj/item/clothing/under/rank/security/officer/mallcop
	name = "mundur ochroniarza z galerii NT"
	desc = "Radio i odznaka są przyszyte, co za tandetna podróbka. Segway nie wchodzi w zestaw."
	icon_state = "mallcop"
	item_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/mallcop/deputy
	name = "mundur aspiranta"
	desc = "Lekko opancerzony oficjalny mundur dla aspirujących członków policji."
