import {
  setDictionary,
  setLanguage,
  translatePaperText,
  translateUiText,
} from './i18n';

describe('i18n: Wielkie Litery i kartki', () => {
  beforeEach(() => {
    setLanguage('en');
    setDictionary({
      version: 2,
      exact: {
        'tania zapalniczka': 'cheap lighter',
        'automat składu': 'squad vendor',
        'Komunikat bezpieczeństwa telekomunikacji':
          'Telecommunications Security Notice',
        'KONIEC TRANSMISJI.': 'TRANSMISSION END.',
      },
      ui: {},
      templates: [],
    } as any);
  });

  it('tłumaczy nazwę po capitalizeAll/toTitleCase', () => {
    expect(translateUiText('Tania Zapalniczka')).toBe('Cheap Lighter');
    expect(translateUiText('Automat Składu')).toBe('Squad Vendor');
    expect(translateUiText('Hełm środowiskowy Tania')).toBe(
      'Hełm środowiskowy Tania',
    );
    expect(translateUiText('Tania zapalniczka')).toBe('Cheap lighter');
    // zwykła wielkość liter działa jak dawniej
    expect(translateUiText('tania zapalniczka')).toBe('cheap lighter');
  });

  it('nie zgaduje dla tekstu spoza słownika', () => {
    expect(translateUiText('Nieznana Rzecz')).toBe('Nieznana Rzecz');
  });

  it('tłumaczy kartkę z kodu w całości', () => {
    expect(
      translatePaperText(
        '<h2>Komunikat bezpieczeństwa telekomunikacji</h2><br>KONIEC TRANSMISJI.<br>asmall5',
      ),
    ).toBe(
      '<h2>Telecommunications Security Notice</h2><br>TRANSMISSION END.<br>asmall5',
    );
  });

  it('zostawia kartkę z tekstem gracza bez zmian', () => {
    const html =
      '<h2>Komunikat bezpieczeństwa telekomunikacji</h2><br>Kocham kapitana, pozdrawiam załogę';
    expect(translatePaperText(html)).toBe(html);
  });

  it('po polsku nic nie zmienia', () => {
    setLanguage('pl');
    expect(translatePaperText('KONIEC TRANSMISJI.')).toBe('KONIEC TRANSMISJI.');
  });
});
