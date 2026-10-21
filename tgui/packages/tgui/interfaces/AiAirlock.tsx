import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  emergency: any;
  id_scanner: any;
  lights: any;
  locked: any;
  opened: any;
  power: any;
  safe: any;
  shock: any;
  shock_timeleft: any;
  speed: any;
  welded: any;
  wires: any;
};

const dangerMap = {
  2: {
    color: 'good',
    localStatusText: 'Wyłączone',
  },
  1: {
    color: 'average',
    localStatusText: 'Uwaga',
  },
  0: {
    color: 'bad',
    localStatusText: 'Optymalne',
  },
};

export const AiAirlock = (props) => {
  const { act, data } = useBackend<Data>();
  const statusMain = dangerMap[data.power.main] || dangerMap[0];
  const statusBackup = dangerMap[data.power.backup] || dangerMap[0];
  const statusElectrify = dangerMap[data.shock] || dangerMap[0];
  return (
    <Window width={500} height={390}>
      <Window.Content>
        <Section title="Stan zasilania">
          <LabeledList>
            <LabeledList.Item
              label="Główne"
              color={statusMain.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.main}
                  content="Przerwij"
                  onClick={() => act('disrupt-main')}
                />
              }
            >
              {data.power.main ? 'Działa' : 'Wyłączone'}{' '}
              {((!data.wires.main_1 || !data.wires.main_2) &&
                '[Przewody przecięte!]') ||
                (data.power.main_timeleft > 0 &&
                  `[${data.power.main_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Zapasowe"
              color={statusBackup.color}
              buttons={
                <Button
                  icon="lightbulb-o"
                  disabled={!data.power.backup}
                  content="Przerwij"
                  onClick={() => act('disrupt-backup')}
                />
              }
            >
              {data.power.backup ? 'Działa' : 'Wyłączone'}{' '}
              {((!data.wires.backup_1 || !data.wires.backup_2) &&
                '[Przewody przecięte!]') ||
                (data.power.backup_timeleft > 0 &&
                  `[${data.power.backup_timeleft}s]`)}
            </LabeledList.Item>
            <LabeledList.Item
              label="Elektryzacja"
              color={statusElectrify.color}
              buttons={
                <>
                  <Button
                    icon="wrench"
                    disabled={!(data.wires.shock && data.shock === 0)}
                    content="Przywróć"
                    onClick={() => act('shock-restore')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content="Tymczasowa"
                    onClick={() => act('shock-temp')}
                  />
                  <Button
                    icon="bolt"
                    disabled={!data.wires.shock}
                    content="Stała"
                    onClick={() => act('shock-perm')}
                  />
                </>
              }
            >
              {data.shock === 2 ? 'Bezpieczne' : 'Pod napięciem'}{' '}
              {(!data.wires.shock && '[Przewody przecięte!]') ||
                (data.shock_timeleft > 0 && `[${data.shock_timeleft}s]`) ||
                (data.shock_timeleft === -1 && '[Stała]')}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Dostęp i sterowanie drzwiami">
          <LabeledList>
            <LabeledList.Item
              label="Skaner ID"
              color="bad"
              buttons={
                <Button
                  icon={data.id_scanner ? 'power-off' : 'times'}
                  content={data.id_scanner ? 'Włączony' : 'Wyłączony'}
                  selected={data.id_scanner}
                  disabled={!data.wires.id_scanner}
                  onClick={() => act('idscan-toggle')}
                />
              }
            >
              {!data.wires.id_scanner && '[Przewody przecięte!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Dostęp awaryjny"
              buttons={
                <Button
                  icon={data.emergency ? 'power-off' : 'times'}
                  content={data.emergency ? 'Włączony' : 'Wyłączony'}
                  selected={data.emergency}
                  onClick={() => act('emergency-toggle')}
                />
              }
            />
            <LabeledList.Divider />
            <LabeledList.Item
              label="Rygle"
              color="bad"
              buttons={
                <Button
                  icon={data.locked ? 'lock' : 'unlock'}
                  content={data.locked ? 'Opuszczone' : 'Podniesione'}
                  selected={data.locked}
                  disabled={!data.wires.bolts}
                  onClick={() => act('bolt-toggle')}
                />
              }
            >
              {!data.wires.bolts && '[Przewody przecięte!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Światła rygli"
              color="bad"
              buttons={
                <Button
                  icon={data.lights ? 'power-off' : 'times'}
                  content={data.lights ? 'Włączone' : 'Wyłączone'}
                  selected={data.lights}
                  disabled={!data.wires.lights}
                  onClick={() => act('light-toggle')}
                />
              }
            >
              {!data.wires.lights && '[Przewody przecięte!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Czujniki nacisku"
              color="bad"
              buttons={
                <Button
                  icon={data.safe ? 'power-off' : 'times'}
                  content={data.safe ? 'Włączone' : 'Wyłączone'}
                  selected={data.safe}
                  disabled={!data.wires.safe}
                  onClick={() => act('safe-toggle')}
                />
              }
            >
              {!data.wires.safe && '[Przewody przecięte!]'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Zabezpieczenie czasowe"
              color="bad"
              buttons={
                <Button
                  icon={data.speed ? 'power-off' : 'times'}
                  content={data.speed ? 'Włączone' : 'Wyłączone'}
                  selected={data.speed}
                  disabled={!data.wires.timing}
                  onClick={() => act('speed-toggle')}
                />
              }
            >
              {!data.wires.timing && '[Przewody przecięte!]'}
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item
              label="Sterowanie drzwiami"
              color="bad"
              buttons={
                <Button
                  icon={data.opened ? 'sign-out-alt' : 'sign-in-alt'}
                  content={data.opened ? 'Otwarte' : 'Zamknięte'}
                  selected={data.opened}
                  disabled={data.locked || data.welded}
                  onClick={() => act('open-close')}
                />
              }
            >
              {!!(data.locked || data.welded) && (
                <span>
                  [Drzwi są {data.locked ? 'zaryglowane' : ''}
                  {data.locked && data.welded ? ' i ' : ''}
                  {data.welded ? 'zaspawane' : ''}!]
                </span>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
