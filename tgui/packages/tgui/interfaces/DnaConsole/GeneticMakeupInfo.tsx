import { LabeledList, Section } from 'tgui-core/components';

import type { Makeup } from './constants';

type Props = {
  makeup: Makeup | null;
};

// Bez "Unique Features" z tg - nasze DNA nie ma bloku cech (UF).
export const GeneticMakeupInfo = (props: Props) => {
  const makeup = props.makeup || {};

  return (
    <Section title="Informacje o enzymach">
      <LabeledList>
        <LabeledList.Item label="Imię">
          {makeup.name || 'Brak'}
        </LabeledList.Item>
        <LabeledList.Item label="Grupa krwi">
          {makeup.blood_type || 'Brak'}
        </LabeledList.Item>
        <LabeledList.Item label="Unikalny enzym">
          {makeup.UE || 'Brak'}
        </LabeledList.Item>
        <LabeledList.Item label="Unikalny identyfikator">
          {makeup.UI || 'Brak'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
