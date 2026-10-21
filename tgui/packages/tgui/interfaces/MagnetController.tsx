// AQUILA - konsola sterowania magnesami (code/game/machinery/magnet.dm).
// tg usunęło magnesy, więc to własne okno w miejsce dawnego HTML.
// Przyciski przy magnesach wysyłają sygnał radiowy do wszystkich magnesów z tym samym kodem.
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Magnet = {
  on: BooleanLike;
  electricity_level: number;
  magnetic_field: number;
};

type Data = {
  title: string;
  autolink: BooleanLike;
  frequency: number;
  code: number;
  speed: number;
  path: string;
  moving: BooleanLike;
  magnets: Magnet[];
};

export const MagnetController = (props) => {
  const { act, data } = useBackend<Data>();
  const { title, autolink, frequency, code, speed, path, moving } = data;
  const magnets = data.magnets || [];

  return (
    <Window width={440} height={480} title={title}>
      <Window.Content scrollable>
        <Section title="Sterowanie">
          <LabeledList>
            {!autolink && (
              <>
                <LabeledList.Item label="Częstotliwość">
                  {frequency}
                </LabeledList.Item>
                <LabeledList.Item label="Kod">{code}</LabeledList.Item>
              </>
            )}
            <LabeledList.Item label="Prędkość">
              <Button icon="minus" onClick={() => act('minusspeed')} /> {speed}{' '}
              <Button icon="plus" onClick={() => act('plusspeed')} />
            </LabeledList.Item>
            <LabeledList.Item label="Ścieżka">
              <Button icon="route" onClick={() => act('setpath')}>
                {path || '-'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Ruch">
              <Button
                icon="power-off"
                selected={!!moving}
                onClick={() => act('togglemoving')}
              >
                {moving ? 'Włączony' : 'Wyłączony'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Potwierdzone magnesy">
          {magnets.length === 0 ? (
            <NoticeBox>Brak połączonych magnesów.</NoticeBox>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>#</Table.Cell>
                <Table.Cell>Zasilanie</Table.Cell>
                <Table.Cell>Prąd</Table.Cell>
                <Table.Cell>Pole magnetyczne</Table.Cell>
              </Table.Row>
              {magnets.map((magnet, index) => (
                <Table.Row key={index} className="candystripe">
                  <Table.Cell collapsing>{index + 1}</Table.Cell>
                  <Table.Cell>
                    <Button
                      icon="power-off"
                      selected={!!magnet.on}
                      onClick={() => act('togglepower')}
                    >
                      {magnet.on ? 'Wł.' : 'Wył.'}
                    </Button>
                  </Table.Cell>
                  <Table.Cell>
                    <Button icon="minus" onClick={() => act('minuselec')} />{' '}
                    {magnet.electricity_level}{' '}
                    <Button icon="plus" onClick={() => act('pluselec')} />
                  </Table.Cell>
                  <Table.Cell>
                    <Button icon="minus" onClick={() => act('minusmag')} />{' '}
                    {magnet.magnetic_field}{' '}
                    <Button icon="plus" onClick={() => act('plusmag')} />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
