// AQUILA - port BeeStation/BeeStation-Hornet#14750: jedna pula staminy na mobie (aquila/code/modules/mob/living/stamina.dm).
// W core, bo korzystają z nich haki w code/ (walka, pałki, pociski).

////
/// STAMINA (jedna pula /datum/stamina_container na każdym /mob/living, jak w Bee#14750)
////

///Maksymalna stamina
#define STAMINA_MAX 250
///Ile staminy wraca na sekundę
#define STAMINA_REGEN 10
///Mnożnik regeneracji, gdy się leży (bez obezwładnienia)
#define STAMINA_RESTING_REGEN_MULTIPLIER 2
///Poniżej tej części puli wchodzi wyczerpanie
#define STAMINA_EXHAUSTION_THRESHOLD_MODIFIER (0.4)
///Powyżej tej części puli wyczerpanie mija
#define STAMINA_EXHAUSTION_RECOVERY_THRESHOLD_MODIFIER (0.7)
///Poniżej tej części wskaźnik pulsuje na czerwono jako ostrzeżenie
#define STAMINA_EXHAUSTION_WARNING_MODIFIER (0.5)
///Spowolnienie przy wyczerpaniu
#define STAMINA_EXHAUSTION_MOVESPEED_SLOWDOWN 3
///Poniżej tej części puli każda utrata staminy może dać stamcrit
#define STAMINA_STUN_THRESHOLD_MODIFIER (0.2)
///Czas stamcritu
#define STAMINA_STUN_TIME (3 SECONDS)
///Bazowa szansa (%) na stamcrit
#define STAMINA_SCALING_STUN_BASE 20
///Dodatkowa szansa (%) zależna od brakującej staminy
#define STAMINA_SCALING_STUN_SCALER 60
///Softcrit zmniejsza pulę o tyle
#define STAMINA_SOFTCRIT_MAX_MODIFIER -100
///Softcrit zmniejsza regenerację o tyle na sekundę
#define STAMINA_SOFTCRIT_REGEN_MODIFIER -5

////
/// WALKA
////

///Domyślny koszt zamachu przedmiotem
#define STAMINA_SWING_COST_ITEM 25
///Domyślne obrażenia staminy przedmiotu
#define STAMINA_DAMAGE_ITEM 15
///Obrażenia staminy ciosu bez broni
#define STAMINA_DAMAGE_UNARMED 24
///Koszt ciosu bez broni
#define STAMINA_SWING_COST_UNARMED 12
///Domyślna szansa (%) na krytyk przedmiotu
#define STAMINA_CRITICAL_RATE_ITEM 25
///Mnożnik obrażeń staminy przy krytyku
#define STAMINA_CRITICAL_MODIFIER 2
///Zamach kosztuje tylko, dopóki po nim zostaje ponad tyle staminy (niżej jest darmowy, więc same zamachy nie wyczerpią)
#define STAMINA_MAXIMUM_TO_SWING 100
///Koszt odepchnięcia
#define STAMINA_DISARM_COST 30
///Obrażenia staminy odepchnięcia
#define STAMINA_DISARM_DMG 18

///Wyczerpanie: brak sprintu, spowolnienie, tylko szept
#define TRAIT_EXHAUSTED "exhausted"
///Źródło cech i modyfikatorów staminy
#define STAMINA_TRAIT "stamina_pool"

#define STATUS_EFFECT_STAMCRIT /datum/status_effect/incapacitating/stamcrit
#define STATUS_EFFECT_DISORIENTED /datum/status_effect/incapacitating/disoriented
///Mob jest zdezorientowany bronią obezwładniającą
#define TRAIT_DISORIENTED "disoriented"
///Pałka nie ogłuszy tego samego celu tego samego atakującego, dopóki ma tę cechę
#define TRAIT_IWASBATONED "iwasbatoned"
#define MOVESPEED_ID_DISORIENT "disorient"

// Animacja interakcji (aquila/code/datums/interaction_particle.dm), stany ikony
#define INTERACT_GENERIC "interact"
#define INTERACT_HELP "help"
#define INTERACT_DISARM "disarm"
#define INTERACT_HARM "harm"
#define INTERACT_GRAB "grab"
#define INTERACT_PULL "pull"
#define INTERACT_UNPULL "unpull"
