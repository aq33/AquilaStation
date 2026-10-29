// NSV13

import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  contents: any;
  hardpoints: any;
  loaded: any;
  ready: any;
};

export const FighterTug = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        <Section title="Sterowanie startem">
          <Button
            content={data.loaded ? 'Rozładuj myśliwiec' : 'Załaduj myśliwiec'}
            color={data.loaded && 'green'}
            disabled={!data.ready}
            icon={!data.loaded ? 'power-off' : 'times'}
            onClick={() => act('load')}
          />
          <Button
            content="Wystrzel załadowany myśliwiec"
            disabled={!data.loaded}
            color={data.ready && 'green'}
            icon={!data.loaded ? 'power-off' : 'times'}
            onClick={() => act('launch')}
          />
        </Section>
        <Section title="Punkty mocowania:">
          {Object.keys(data.hardpoints).map((key) => {
            let value = data.hardpoints[key];
            return (
              <Section title={value.name} key={key}>
                <Button
                  content="Wysuń"
                  icon="eject"
                  onClick={() =>
                    act('remove_hardpoint', { target: value.name })
                  }
                />
                <Button
                  content="Obejrzyj"
                  icon="bullseye"
                  onClick={() => act('interact', { target: value.name })}
                />
                <ProgressBar
                  value={(value.capacity / value.max_capacity) * 100 * 0.01}
                  ranges={{
                    good: [0, 0.25],
                    average: [0.8, 0.9],
                    bad: [0.9, Infinity],
                  }}
                />
              </Section>
            );
          })}
        </Section>
        <Section title="Załadowany ładunek:">
          {Object.keys(data.contents).map((key) => {
            let value = data.contents[key];
            return <Button key={key} content={value.name} icon="search" />;
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
