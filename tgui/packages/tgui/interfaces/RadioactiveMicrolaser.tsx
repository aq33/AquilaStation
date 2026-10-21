import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  cooldown: string;
  intensity: number;
  irradiate: BooleanLike;
  on_cooldown: BooleanLike;
  scanmode: BooleanLike;
  stealth: BooleanLike;
  wavelength: number;
};

export const RadioactiveMicrolaser = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    irradiate,
    stealth,
    scanmode,
    intensity,
    wavelength,
    on_cooldown,
    cooldown,
  } = data;
  return (
    <Window
      title="Radioaktywny mikrolaser"
      width={320}
      height={335}
      theme="syndicate"
    >
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Stan lasera">
              <Box color={on_cooldown ? 'average' : 'good'}>
                {on_cooldown ? 'Ładowanie' : 'Gotowy'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Sterowanie skanerem">
          <LabeledList>
            <LabeledList.Item label="Napromieniowanie">
              <Button
                icon={irradiate ? 'power-off' : 'times'}
                selected={irradiate}
                onClick={() => act('irradiate')}
              >
                {irradiate ? 'Wł.' : 'Wył.'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Tryb ukryty">
              <Button
                icon={stealth ? 'eye-slash' : 'eye'}
                disabled={!irradiate}
                selected={stealth}
                onClick={() => act('stealth')}
              >
                {stealth ? 'Wł.' : 'Wył.'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Tryb skanu">
              <Button
                icon={scanmode ? 'mortar-pestle' : 'heartbeat'}
                disabled={!!irradiate && !!stealth}
                onClick={() => act('scanmode')}
              >
                {scanmode ? 'Skan odczynników' : 'Skan zdrowia'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Ustawienia lasera">
          <LabeledList>
            <LabeledList.Item label="Natężenie promieniowania">
              <Button
                icon="fast-backward"
                onClick={() => act('radintensity', { adjust: -5 })}
              />
              <Button
                icon="backward"
                onClick={() => act('radintensity', { adjust: -1 })}
              />{' '}
              <NumberInput
                value={Math.round(intensity)}
                width="40px"
                minValue={1}
                maxValue={20}
                step={1}
                onChange={(value) => {
                  return act('radintensity', {
                    target: value,
                  });
                }}
              />{' '}
              <Button
                icon="forward"
                onClick={() => act('radintensity', { adjust: 1 })}
              />
              <Button
                icon="fast-forward"
                onClick={() => act('radintensity', { adjust: 5 })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Długość fali">
              <Button
                icon="fast-backward"
                onClick={() => act('radwavelength', { adjust: -5 })}
              />
              <Button
                icon="backward"
                onClick={() => act('radwavelength', { adjust: -1 })}
              />{' '}
              <NumberInput
                value={Math.round(wavelength)}
                width="40px"
                minValue={0}
                maxValue={120}
                step={1}
                onChange={(value) => {
                  return act('radwavelength', {
                    target: value,
                  });
                }}
              />{' '}
              <Button
                icon="forward"
                onClick={() => act('radwavelength', { adjust: 1 })}
              />
              <Button
                icon="fast-forward"
                onClick={() => act('radwavelength', { adjust: 5 })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Czas odnowienia">
              <Box inline bold>
                {cooldown}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
