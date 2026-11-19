// AQUILA - implanty i augmenty z wdrożenia robotyki (aquila/code/modules/cybernetics/robotyka/)

// Sloty nowych augmentów (jeden augment w slocie)
#define ORGAN_SLOT_BRAIN_WIRE_INTERFACE "brain_wire_interface"
#define ORGAN_SLOT_BRAIN_JOYWIRE "brain_joywire"
#define ORGAN_SLOT_BRAIN_DIAGNOSTICS "brain_diagnostics"
#define ORGAN_SLOT_BRAIN_HACKING "brain_hacking"
#define ORGAN_SLOT_BRAIN_JUMPSTARTER "brain_jumpstarter"
#define ORGAN_SLOT_BRAIN_EMOTION "brain_emotion"
#define ORGAN_SLOT_EYE_ZOOM "eye_zoom"
#define ORGAN_SLOT_EYE_MAP "eye_map"
#define ORGAN_SLOT_AQ_BLOOD_AUG "aq_blood_aug"
#define ORGAN_SLOT_AQ_AIR_SAC "aq_air_sac"
#define ORGAN_SLOT_AQ_CAMO "aq_camo"
#define ORGAN_SLOT_AQ_GUSTATORIAL "aq_gustatorial"
#define ORGAN_SLOT_AQ_SERVICE_JACK "aq_service_jack"

/// Augmenty nosiciela nie działają (implant zakłócający augmenty)
// TRAIT_AQ_AUGMENTS_DISRUPTED: w __DEFINES/robotics.dm (część ROBOTYKA)
/// Słyszy i mówi na kanale binarnym bez słuchawek (tłumacz maszynowy, powłoka SI)
#define TRAIT_AQ_BINARY_SPEAKER "aq_binary_speaker"

// TRAIT_AQ_WIRE_INTERFACE i COMSIG_AQ_TELEPORT_DENIED są w core (traits.dm, signals_atom.dm), bo używają ich hooki w core

/// Źródło cech nadawanych przez implanty i augmenty z tego modułu
#define AQ_ROBOTYKA_IMPLANT_TRAIT "aq_robotyka_implant"
