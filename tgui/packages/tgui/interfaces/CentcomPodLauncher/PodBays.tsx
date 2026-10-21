import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { BAYS } from './constants';
import type { PodLauncherData } from './types';

export function PodBays(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { bayNumber } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="trash"
            onClick={() => act('clearBay')}
            tooltip={`
              Usuwa wszystko
              z wybranej zatoki`}
            tooltipPosition="top-end"
          />
          <Button
            color="transparent"
            icon="question"
            tooltip={`
              Każda opcja odpowiada
              obszarowi na Centrali.
              Wysłane kapsuły zostaną
              wypełnione przedmiotami
              z tych obszarów zgodnie
              z opcjami „Ładunek z zatoki”
              w lewym górnym rogu.`}
            tooltipPosition="top-end"
          />
        </>
      }
      fill
      title="Zatoka"
    >
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          onClick={() => act('switchBay', { bayNumber: `${i + 1}` })}
          selected={bayNumber === `${i + 1}`}
          tooltipPosition="bottom-end"
        >
          {bay.title}
        </Button>
      ))}
    </Section>
  );
}
