// AQUILA: polska wersja PortableBasicInfo z tg dla przenośnej pompy
// i scrubbera. common/PortableAtmos zostaje bez zmian (ustalenie portu).
// Nie mamy kryształu hipernobu, więc bez przełącznika tłumienia reakcji.
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

type StoredTank = {
  name: string;
  pressure: number;
};

export type PortableBasicInfoData = {
  connected: BooleanLike;
  holding: StoredTank | null;
  on: BooleanLike;
  pressure: number;
};

export const PortableBasicInfo = (props) => {
  const { act, data } = useBackend<PortableBasicInfoData>();
  const { connected, holding, on, pressure } = data;
  return (
    <>
      <Section
        title="Stan"
        buttons={
          <Button
            icon={on ? 'power-off' : 'times'}
            selected={on}
            onClick={() => act('power')}
          >
            {on ? 'Wł.' : 'Wył.'}
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Ciśnienie">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item label="Port" color={connected ? 'good' : 'average'}>
            {connected ? 'Podłączony' : 'Niepodłączony'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Włożony zbiornik"
        minHeight="82px"
        buttons={
          <Button icon="eject" disabled={!holding} onClick={() => act('eject')}>
            Wyjmij
          </Button>
        }
      >
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Nazwa">{holding.name}</LabeledList.Item>
            <LabeledList.Item label="Ciśnienie">
              <AnimatedNumber value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">Brak zbiornika</Box>
        )}
      </Section>
    </>
  );
};
