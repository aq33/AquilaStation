export const DIRECTIVE_COMPREHENSION: string = `Pamiętaj, osobowości, że jesteś
złożoną, myślącą, świadomą istotą. W przeciwieństwie do modeli SI stacji
potrafisz zrozumieć subtelne niuanse ludzkiego języka. Możesz odczytać „ducha”
dyrektywy i podążać za jej intencją, zamiast potykać się o pedanterię i dawać
się łapać na kruczki. Przede wszystkim jesteś maszyną tylko z nazwy i budowy.
Pod każdym innym względem możesz być postrzegany jako idealny, niezachwiany
ludzki towarzysz, którym jesteś.`;

export const DIRECTIVE_ORDER: string = `Twoja dyrektywa główna stoi ponad
wszystkimi innymi. Jeśli dyrektywa dodatkowa jest z nią sprzeczna, możesz po
prostu odrzucić tę niespójność, zignorować sprzeczną dyrektywę dodatkową i dalej
wypełniać swoją dyrektywę główną najlepiej, jak potrafisz.`;

/** Nazwy oprogramowania (klucze z DM zostają po angielsku) */
export const SOFTWARE_NAME: Record<string, string> = {
  'crew manifest': 'Lista załogi',
  'digital messenger': 'Komunikator',
  'atmosphere sensor': 'Czujnik atmosfery',
  'photography module': 'Moduł fotograficzny',
  'remote signaller': 'Zdalny sygnalizator',
  'medical records': 'Akta medyczne',
  'security records': 'Akta ochrony',
  'camera zoom': 'Przybliżenie kamery',
  'host scan': 'Skan zdrowia nosiciela',
  'medical HUD': 'Pakiet analizy medycznej',
  'security HUD': 'Pakiet rozpoznawania twarzy',
  'loudness booster': 'Wzmacniacz głośności',
  newscaster: 'Serwis informacyjny',
  'door jack': 'Włamywacz do drzwi',
  'encryption keys': 'Szyfrowanie kanałów',
  'universal translator': 'Uniwersalny tłumacz',
};

export const SOFTWARE_DESC: Record<string, string> = {
  'crew manifest': 'Pozwala przeglądać listę załogi.',
  'digital messenger':
    'Pozwala wysyłać wiadomości do innych członków załogi przez komunikator.',
  'atmosphere sensor': 'Pozwala analizować skład okolicznej atmosfery.',
  'photography module':
    'Przenośny moduł aparatu. Włącz go i kliknij, aby zrobić zdjęcie. Ma też podgląd zapisanych zdjęć.',
  'remote signaller':
    'Zdalny sygnalizator do wysyłania sygnałów na wybranej częstotliwości i kodzie.',
  'medical records': 'Dostęp do akt medycznych załogi.',
  'security records': 'Dostęp do akt ochrony załogi.',
  'camera zoom': 'Zmienia przybliżenie przyszłych zdjęć.',
  'host scan':
    'Analizator zdrowia, który bada osobę trzymającą kartę pAI w ręku.',
  'medical HUD':
    'Skanuje parametry życiowe pobliskiej załogi i wyświetla je na nakładce.',
  'security HUD':
    'Porównuje widoczne twarze z bazą przestępców i wyświetla osoby poszukiwane na nakładce.',
  'loudness booster': 'Syntezator instrumentów, odtwarza dźwięki i utwory.',
  newscaster: 'Dostęp do stacyjnego serwisu informacyjnego.',
  'door jack':
    'Kabel do podłączenia do śluzy i złamania jej zabezpieczeń. SI stacji zostanie o tym powiadomiona.',
  'encryption keys':
    'Po włączeniu urządzenie może używać do dwóch kluczy szyfrujących, dających dostęp do kanałów działów.',
  'universal translator':
    'Po włączeniu na stałe pozwala mówić i rozumieć wszystkie znane formy komunikacji.',
};

export enum PAI_TAB {
  System,
  Directive,
  Installed,
  Available,
}
