// AQUILA - sloty nowych narządów AquilaMed 6 (aquila/code/modules/surgery/organs/med6/)

#define ORGAN_SLOT_PANCREAS "pancreas"
#define ORGAN_SLOT_ESOPHAGUS "esophagus"
#define ORGAN_SLOT_AQ_SPINE "aq_spine"

/// Cukru we krwi powyżej tej ilości: hiperglikemia (bez działającej trzustki)
#define AQ_HYPERGLYCEMIA_SUGAR 40

/// Strony narządów parzystych (płuca, nerki; surgery/organs/med6/paired_organs.dm)
#define AQ_SIDE_LEFT (1<<0)
#define AQ_SIDE_RIGHT (1<<1)
#define AQ_SIDES_BOTH (AQ_SIDE_LEFT|AQ_SIDE_RIGHT)
