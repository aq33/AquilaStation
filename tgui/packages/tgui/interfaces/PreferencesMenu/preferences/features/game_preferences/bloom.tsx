import { FeatureNumberInput, FeatureNumeric } from '../base';

export const bloom_amount: FeatureNumeric = {
  name: 'Poziom bloomu',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description:
    'Ile procent bloomu pokazywać. Bloom to efekt oświetlenia, który rozmywa jasne światła w biel. Całkowite wyłączenie może w razie potrzeby poprawić wydajność klienta.',
  component: FeatureNumberInput,
};
