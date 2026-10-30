// Warstwa zgodności portu wirusologii (Monkestation2.0 -> Aquila).
// Monke stoi na nowym /tg/, my na Bee/NSV13, więc tu siedzą brakujące globalne listy,
// zmienne i drobne odpowiedniki procek, żeby nie dłubać w rdzeniu.

/// Patogeny widoczne w panelu admina; w Monke leży to w code/datums/diseases/_disease.dm.
GLOBAL_LIST_EMPTY(inspectable_diseases)

/obj/effect/decal/cleanable
	/// Patogeny w tej plamie. Nasz rdzeń przyjmuje je w Initialize, ale nie trzyma listy.
	var/list/diseases

// Probówka do centryfugi. W Monke to /obj/item/reagent_containers/glass/tube,
// u nas rodzina pojemników nazywa się glass.
/obj/item/reagent_containers/glass/tube
	name = "probówka"
	desc = "Mała szklana probówka. Pasuje do centryfugi."
	icon = 'aquila/icons/virology/items.dmi'
	icon_state = "tube"
	volume = 30
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30)
	w_class = WEIGHT_CLASS_TINY
	spillable = TRUE

/obj/item/reagent_containers/glass/tube/Initialize(mapload)
	. = ..()
	update_icon()

// --- drobne odpowiedniki definicji z tg ---------------------------------------

/// tg trzyma docelową temperaturę ciała na mobie; u nas to stała.
#define standard_body_temperature_compat BODYTEMP_NORMAL

/// tg: czy turf przepuszcza widok w dół.
#define istransparentturf(A) (istype(A, /turf/open/openspace))
/// tg: turf nad danym.
#define GET_TURF_ABOVE(T) (locate(T.x, T.y, T.z + 1))

#define COLOR_MATRIX_GRAYSCALE list(0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0.33,0.33,0.33,0, 0,0,0,1, 0,0,0,0)
#define BLOOD_TYPE_O_MINUS "O-"
#define TRAIT_NO_ZOMBIFY "no_zombify"
#define TRAUMA_SPECIAL_CURE_PROOF TRAUMA_RESILIENCE_ABSOLUTE
#define MUTATION_SOURCE_GENE_SYMPTOM "gene symptom"
#define VV_HK_VIEW_DISEASE_DATA "view_disease_data"
#define AWAY_LATHE PROTOLATHE

/// tg oznacza organy robotyczne flagą, my mamy status ORGAN_SYNTHETIC.
#define IS_ROBOTIC_ORGAN(organ) (organ.status & ORGAN_SYNTHETIC)

/// Ludzie w Monke mają listę wylosowanych genów symptomów (symptom cracker).
/mob/living/carbon/human
	var/created_symptoms = FALSE

/obj/item/bodypart
	/// tg: czytelna nazwa strefy ciała.
	var/plaintext_zone

/// Litery i cyfry do minigry symptom crackera (tg GLOB.alphabet_upper / GLOB.numerals).
GLOBAL_LIST_INIT(alphabet_upper, list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"))
GLOBAL_LIST_INIT(numerals, list("0","1","2","3","4","5","6","7","8","9"))

/// Nastrój od objawu „rozkoszny” (Monke: /datum/mood_event/delightful_symptom).
/datum/mood_event/delightful_symptom
	description = "<span class='nicegreen'>Czuję się wyjątkowo rozkosznie!</span>"
	mood_change = 4
	timeout = 2 MINUTES

/// Losowe geny objawów dla symptom crackera (Monke: code/modules/mob/living/carbon/human/human.dm).
/mob/living/carbon/human/proc/create_symptoms()
	if(!dna?.species)
		return
	AddComponent(/datum/component/symptom_genes, dna.species, 3)
