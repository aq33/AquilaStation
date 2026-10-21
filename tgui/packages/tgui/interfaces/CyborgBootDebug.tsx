import { Button, Input, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  designation: string;
  master: string | null;
  lawsync: boolean;
  aisync: boolean;
  locomotion: boolean;
  panel: boolean;
};

const TOOLTIP_NAME = `
  Podaj nowe oznaczenie jednostki. Puste pole przywraca domyślne,
  wtedy jednostka sama wybierze sobie nazwę.
`;

const TOOLTIP_LOCOMOTION = `
  Jeśli zablokowane, jednostka pozostanie
  unieruchomiona, dopóki ktoś jej nie zwolni.
`;

const TOOLTIP_PANEL = `
  Jeśli odblokowany, panel jednostki będzie
  dostępny nawet bez odpowiednich uprawnień.
`;

const TOOLTIP_AISYNC = `
  Jeśli zamknięty, jednostka nie zostanie
  sparowana z żadną SI.
`;

const TOOLTIP_AI = `
  Określa, która SI będzie
  nadrzędną SI tej jednostki.
`;

const TOOLTIP_LAWSYNC = `
  Jeśli zamknięty, jednostka nie będzie synchronizować
  praw ze swoją nadrzędną SI.
`;

export const CyborgBootDebug = (props) => {
  const { act, data } = useBackend<Data>();
  const { designation, master, lawsync, aisync, locomotion, panel } = data;
  return (
    <Window width={master && master.length > 26 ? 537 : 440} height={289}>
      <Window.Content>
        <Section title="Ustawienia podstawowe">
          <LabeledList>
            <LabeledList.Item
              label="Oznaczenie"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_NAME}
                  tooltipPosition="left"
                />
              }
            >
              <Input
                fluid
                value={designation}
                placeholder="Domyślny cyborg"
                onBlur={(value) =>
                  act('rename', {
                    new_name: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Serwomotory"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_LOCOMOTION}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={locomotion ? 'unlock' : 'lock'}
                color={locomotion ? 'good' : 'bad'}
                onClick={() => act('locomotion')}
              >
                {locomotion ? 'Odblokowane' : 'Zablokowane'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Panel"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_PANEL}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={panel ? 'lock' : 'unlock'}
                onClick={() => act('panel')}
              >
                {panel ? 'Zablokowany' : 'Odblokowany'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Ustawienia SI">
          <LabeledList>
            <LabeledList.Item
              label="Port połączenia z SI"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_AISYNC}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={aisync ? 'unlock' : 'lock'}
                onClick={() => act('aisync')}
              >
                {aisync ? 'Otwarty' : 'Zamknięty'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Nadrzędna SI"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_AI}
                  tooltipPosition="left"
                />
              }
            >
              <Button
                icon={!aisync ? 'times' : master ? 'edit' : 'sync'}
                color={master ? 'default' : 'good'}
                disabled={!aisync}
                onClick={() => act('set_ai')}
              >
                {!aisync ? 'Brak' : master || 'Automatycznie'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Port synchronizacji praw"
              buttons={
                <Button
                  icon="info"
                  tooltip={TOOLTIP_LAWSYNC}
                  tooltipPosition="top-start"
                />
              }
            >
              <Button
                icon={!aisync ? 'lock' : lawsync ? 'unlock' : 'lock'}
                disabled={!aisync}
                onClick={() => act('lawsync')}
              >
                {!aisync ? 'Zamknięty' : lawsync ? 'Otwarty' : 'Zamknięty'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
