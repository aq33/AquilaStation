// AQUILA: sieć transmisji TV (port Monkestation/tg: telewizory rozrywkowe, Spess.tv, kamery reporterskie)

/// Wysyłany, gdy sieć kamer zaczyna lub kończy nadawać do telewizorów rozrywkowych: (camera_net, is_show_active, announcement)
#define COMSIG_GLOB_NETWORK_BROADCAST_UPDATED "!network_broadcast_updated"

/// Częstotliwość radia rozrywkowego (mikrofony kamer -> głośniki telewizorów i Spess.tv)
#define FREQ_ENTERTAINMENT 1415
/// Nazwa kanału rozrywkowego w czacie
#define RADIO_CHANNEL_ENTERTAINMENT "Rozrywka"

/// Sieć kamer Thunderdome, zawsze dostępna w telewizorach rozrywkowych
#define CAMERANET_NETWORK_THUNDERDOME "thunder"
/// Sieć kamer reporterskich kuratora
#define CAMERANET_NETWORK_CURATOR "curator"
/// Sieć kamery lądowiska: transmisja lądowania promu na planecie (planet_landing_broadcast.dm)
#define CAMERANET_NETWORK_LANDING "landing"
/// Sieć kamer pokładowych Sabre: stały kanał w Spess.tv i telewizorach rozrywkowych (sabre_camera.dm)
#define CAMERANET_NETWORK_SABRE "sabre"
/// Sieci zawsze dostępne w telewizorach rozrywkowych i Spess.tv, niezależnie od transmisji na żywo
#define CAMERANET_PERMANENT_NETWORKS list(CAMERANET_NETWORK_THUNDERDOME, CAMERANET_NETWORK_SABRE)
