import { Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  compressor: any;
  compressor_broke: any;
  online: any;
  power: any;
  rpm: any;
  temp: any;
  turbine: any;
  turbine_broke: any;
};

export const TurbineComputer = (props) => {
  const { act, data } = useBackend<Data>();
  const operational = Boolean(
    data.compressor &&
      !data.compressor_broke &&
      data.turbine &&
      !data.turbine_broke,
  );
  return (
    <Window width={310} height={150}>
      <Window.Content>
        <Section
          title="Stan"
          buttons={
            <>
              <Button
                icon={data.online ? 'power-off' : 'times'}
                content={data.online ? 'Włączona' : 'Wyłączona'}
                selected={data.online}
                disabled={!operational}
                onClick={() => act('toggle_power')}
              />
              <Button
                icon="sync"
                content="Połącz ponownie"
                onClick={() => act('reconnect')}
              />
            </>
          }
        >
          {(!operational && (
            <LabeledList>
              <LabeledList.Item
                label="Sprężarka"
                color={
                  !data.compressor || data.compressor_broke ? 'bad' : 'good'
                }
              >
                {data.compressor_broke
                  ? data.compressor
                    ? 'Wyłączona'
                    : 'Brak'
                  : 'Działa'}
              </LabeledList.Item>
              <LabeledList.Item
                label="Turbina"
                color={!data.turbine || data.turbine_broke ? 'bad' : 'good'}
              >
                {data.turbine_broke
                  ? data.turbine
                    ? 'Wyłączona'
                    : 'Brak'
                  : 'Działa'}
              </LabeledList.Item>
            </LabeledList>
          )) || (
            <LabeledList>
              <LabeledList.Item label="Prędkość turbiny">
                {data.rpm} RPM
              </LabeledList.Item>
              <LabeledList.Item label="Temp. wewnętrzna">
                {data.temp} K
              </LabeledList.Item>
              <LabeledList.Item label="Wytwarzana moc">
                {data.power}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
