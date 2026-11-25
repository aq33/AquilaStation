// Link do wiki w powitaniu stanowiska (code/controllers/subsystem/job.dm).
// Wcześniej prowadził do wyszukiwarki wiki BeeStation z polską nazwą stanowiska, a nasza wiki ma tytuły po angielsku
// (wyszukiwanie „Fryzjer” nic nie znajduje). Stanowisko -> tytuł strony na wiki z WIKIURL.

/// Nazwa stanowiska -> tytuł strony na wiki. Stanowiska bez własnej strony wskazują najbliższą (dział, Gimmick).
GLOBAL_LIST_INIT(job_wiki_pages, list(
	JOB_NAME_CAPTAIN = "Captain",
	JOB_NAME_HEADOFPERSONNEL = "Executive Officer",
	JOB_NAME_ASSISTANT = "Assistant",
	JOB_NAME_BARTENDER = "Bartender",
	JOB_NAME_BOTANIST = "Botanist",
	JOB_NAME_COOK = "Cook",
	JOB_NAME_JANITOR = "Janitor",
	JOB_NAME_CURATOR = "Curator",
	JOB_NAME_LAWYER = "Lawyer",
	JOB_NAME_CHAPLAIN = "Chaplain",
	JOB_NAME_MIME = "Mime",
	JOB_NAME_CLOWN = "Clown",
	JOB_NAME_STAGEMAGICIAN = "Gimmick",
	JOB_NAME_BARBER = "Gimmick",
	JOB_NAME_VIP = "Gimmick",
	JOB_NAME_PSYCHIATRIST = "Gimmick",
	JOB_NAME_GIMMICK = "Gimmick",
	JOB_NAME_QUARTERMASTER = "Quartermaster",
	JOB_NAME_CARGOTECHNICIAN = "Cargo Technician",
	JOB_NAME_SHAFTMINER = "Shaft Miner",
	JOB_NAME_BITRUNNER = "Bitrunner",
	JOB_NAME_CHIEFENGINEER = "Chief Engineer",
	JOB_NAME_STATIONENGINEER = "Ship Engineer",
	JOB_NAME_ATMOSPHERICTECHNICIAN = "Atmospheric Technician",
	JOB_NAME_CHIEFMEDICALOFFICER = "Chief Medical Officer",
	JOB_NAME_MEDICALDOCTOR = "Medical Doctor",
	JOB_NAME_PARAMEDIC = "Paramedic",
	JOB_NAME_CHEMIST = "Chemist",
	JOB_NAME_VIROLOGIST = "Virologist",
	JOB_NAME_GENETICIST = "Geneticist",
	JOB_NAME_BRIGPHYSICIAN = "Brig Physician",
	JOB_NAME_RESEARCHDIRECTOR = "Research Director",
	JOB_NAME_SCIENTIST = "Scientist",
	JOB_NAME_ROBOTICIST = "Roboticist",
	JOB_NAME_EXPLORATIONCREW = "Research Division",
	JOB_NAME_HEADOFSECURITY = "Head of Security",
	JOB_NAME_WARDEN = "Warden",
	JOB_NAME_SECURITYOFFICER = "Security Officer",
	JOB_NAME_DETECTIVE = "Detective",
	JOB_NAME_DEPUTY = "Security Officer",
	JOB_NAME_MASTERATARMS = "Master At Arms",
	JOB_NAME_BRIDGESTAFF = "Bridge Staff",
	JOB_NAME_MUNITIONSTECHNICIAN = "Munitions Technician",
	JOB_NAME_PILOT = "Fighter Pilot",
	JOB_NAME_AIRTRAFFICCONTROLLER = "Air Traffic Controller",
	JOB_NAME_DECKTECHNICIAN = "Deck Technician",
	JOB_NAME_AI = "AI",
	JOB_NAME_CYBORG = "Cyborg",
))

/// Adres strony wiki stanowiska albo null, gdy serwer nie ma WIKIURL. Stanowisko bez wpisu prowadzi do listy stanowisk.
/proc/job_wiki_url(rank)
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(!wikiurl)
		return null
	var/page = GLOB.job_wiki_pages[rank] || "Jobs"
	return "[wikiurl]/[replacetext(page, " ", "_")]"
