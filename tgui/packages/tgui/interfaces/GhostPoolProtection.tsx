import { Button, Flex, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  events_or_midrounds: any;
  minigames: any;
  silicons: any;
  spawners: any;
  station_sentience: any;
};

export const GhostPoolProtection = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    events_or_midrounds,
    spawners,
    station_sentience,
    silicons,
    minigames,
  } = data;
  return (
    <Window theme="admin" title="Ochrona puli duchów" width={400} height={285}>
      <Window.Content>
        <Flex grow={1} height="100%">
          <Section
            title="Opcje"
            buttons={
              <>
                <Button
                  color="good"
                  icon="plus-circle"
                  content="Włącz wszystko"
                  onClick={() => act('all_roles')}
                />
                <Button
                  color="bad"
                  icon="minus-circle"
                  content="Wyłącz wszystko"
                  onClick={() => act('no_roles')}
                />
              </>
            }
          >
            <NoticeBox danger>
              Dla robiących podstępny event: jeśli przełączysz świadomość
              tworzoną na stacji, gracze mogą się zorientować, że admini
              wyłączyli role na potrzeby eventu...
            </NoticeBox>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={events_or_midrounds ? 'good' : 'bad'}
                icon="meteor"
                content="Eventy i midroundy"
                onClick={() => act('toggle_events_or_midrounds')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={spawners ? 'good' : 'bad'}
                icon="pastafarianism"
                content="Spawnery ról duchów"
                onClick={() => act('toggle_spawners')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={station_sentience ? 'good' : 'bad'}
                icon="user-astronaut"
                content="Świadomość tworzona na stacji"
                onClick={() => act('toggle_station_sentience')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={silicons ? 'good' : 'bad'}
                icon="robot"
                content="Silikony"
                onClick={() => act('toggle_silicons')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={0.5}
                textAlign="center"
                color={minigames ? 'good' : 'bad'}
                icon="gamepad"
                content="Minigry"
                onClick={() => act('toggle_minigames')}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                fluid
                my={1.4}
                textAlign="center"
                color="orange"
                icon="check"
                content="Zastosuj zmiany"
                onClick={() => act('apply_settings')}
              />
            </Flex.Item>
          </Section>
        </Flex>
      </Window.Content>
    </Window>
  );
};
