import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';

type Data = {
  connected: any;
  holding: any;
  on: any;
  pressure: any;
};

export const PortableBasicInfo = (props) => {
  const { act, data } = useBackend<Data>();

  const { connected, holding, on, pressure } = data;

  return (
    <>
      <Section
        title="Stan"
        buttons={
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'Wł.' : 'Wył.'}
            selected={on}
            onClick={() => act('power')}
          />
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
        title="Butla"
        minHeight="82px"
        buttons={
          <Button
            icon="eject"
            content="Wysuń"
            disabled={!holding}
            onClick={() => act('eject')}
          />
        }
      >
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Etykieta">{holding.name}</LabeledList.Item>
            <LabeledList.Item label="Ciśnienie">
              <AnimatedNumber value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">No holding tank</Box>
        )}
      </Section>
    </>
  );
};
