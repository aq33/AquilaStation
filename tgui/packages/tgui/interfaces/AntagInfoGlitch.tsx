import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Objective } from './common/Objectives';

type Data = {
  antag_name: string;
  objectives: Objective[];
};

const textStyles = {
  variable: {
    color: 'white',
  },
  danger: {
    color: 'red',
  },
} as const;

export const AntagInfoGlitch = (props) => {
  const { data } = useBackend<Data>();
  const { antag_name, objectives = [] } = data;

  return (
    <Window width={350} height={450} theme="ntos_terminal">
      <Window.Content>
        <Section scrollable fill>
          <Stack fill vertical>
            <Stack.Item>FN TERMINATE_INTRUDERS (REF)</Stack.Item>
            <Stack.Divider />
            <Stack.Item bold fontSize="16px">
              <span style={textStyles.variable}>Initialize({antag_name})</span>
            </Stack.Item>
            <Stack.Item mb={1}>
              <span style={textStyles.danger}>Bitrunning</span> to przestępstwo.
              Twoja misja: <span style={textStyles.variable}>wyeliminować</span>{' '}
              organicznych intruzów, by zachować integralność systemu.
            </Stack.Item>
            <SpecificInfo />

            <Stack.Divider />
            <Stack.Item>
              <span style={{ opacity: 0.6 }}>
                &#47;&#47; {objectives[0]?.explanation}
              </span>
            </Stack.Item>
            <Stack.Item>
              const <span style={textStyles.variable}>TARGETS</span> ={' '}
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>system.</span>
              <span style={textStyles.danger}>INTRUDERS</span>
            </Stack.Item>
            <Stack.Item>
              while <span style={textStyles.variable}>TARGETS</span>.LIFE !={' '}
              <span style={textStyles.variable}>stat.</span>DEAD
            </Stack.Item>
            <Stack.Item>
              <span style={textStyles.variable}>action.</span>
              <span style={textStyles.danger}>KILL()</span>
            </Stack.Item>
            <Stack.Item>terminate_intruders([0x70cf4020])</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

// Nazwy ról porównywane z antag_name z DM (ROLE_CYBER_POLICE itd.)
const SpecificInfo = (props) => {
  const { data } = useBackend<Data>();
  const { antag_name } = data;

  switch (antag_name) {
    case 'Cyber Police':
      return (
        <>
          <Stack.Item mb={1}>
            Do wykonania zadania twój program dostał najnowocześniejsze{' '}
            <span style={textStyles.variable}>sztuki walki</span>.
          </Stack.Item>
          <Stack.Item grow>
            Broń dystansowa jest <span style={textStyles.danger}>zakazana</span>
            . Ochrona przed pociskami jest źle widziana. Liczy się styl.
          </Stack.Item>
        </>
      );
    case 'Cyber Tac':
      return (
        <>
          <Stack.Item mb={1}>
            Jesteś zaawansowaną jednostką bojową. Wyposażono cię w{' '}
            <span style={textStyles.variable}>śmiercionośną broń</span>.
          </Stack.Item>
          <Stack.Item grow>
            <span style={textStyles.danger}>Zlikwiduj</span> życie organiczne za
            wszelką cenę.
          </Stack.Item>
        </>
      );
    case 'NetGuardian Prime':
      return (
        <Stack.Item grow>
          <span style={{ ...textStyles.danger, fontSize: '16px' }}>
            ŻYCIE ORGANICZNE MUSI ZOSTAĆ ZLIKWIDOWANE.
          </span>
        </Stack.Item>
      );
    default:
      return null;
  }
};
