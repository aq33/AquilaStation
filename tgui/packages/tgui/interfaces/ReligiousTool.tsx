import { Fragment } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Dimmer,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Sect = {
  name: string;
  desc: string;
  quote: string;
  icon: string;
  alignment: string;
  path: string;
};

type Rite = {
  name: string;
  desc: string;
  favor: number;
  path: string;
};

type Data = {
  alignment: string;
  deity: string;
  desc: string;
  favor: number;
  favordesc: string;
  icon: string;
  name: string;
  quote: string;
  rites: Rite[];
  sects: Sect[] | null;
  toolname: string;
  wanted: string;
};

const ALIGNMENT2COLOR = {
  good: 'yellow',
  neutral: 'white',
  evil: 'red',
};

export const ReligiousTool = (props) => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 1);
  const { sects, alignment, toolname } = data;

  return (
    <Window title={toolname} width={560} height={500}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs textAlign="center" fluid>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Wyznanie{' '}
                <Icon
                  name="place-of-worship"
                  color={ALIGNMENT2COLOR[alignment]}
                />
              </Tabs.Tab>
              {!sects && (
                <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                  Obrzędy{' '}
                  <Icon name="pray" color={ALIGNMENT2COLOR[alignment]} />
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow={1}>
            {tab === 1 && ((!!sects && <SectSelectTab />) || <SectTab />)}
            {tab === 2 && <RiteTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SectTab = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    name,
    quote,
    desc,
    icon,
    favordesc,
    favor,
    wanted,
    deity,
    alignment,
  } = data;
  return (
    <Section fill>
      <Stack fill vertical fontSize="15px" textAlign="center">
        <Stack.Item mt={2} fontSize="32px">
          <Icon name={icon} color={ALIGNMENT2COLOR[alignment]} />
          {` ${name} `}
          <Icon name={icon} color={ALIGNMENT2COLOR[alignment]} />
        </Stack.Item>
        <Stack.Item grow mb={2} color="grey">
          {`"${quote}"`}
        </Stack.Item>
        <Stack.Item color={favor === 0 ? 'white' : 'green'}>
          {favordesc}
        </Stack.Item>
        <Stack.Item mb={2} textAlign="left">
          <BlockQuote>{desc}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <Section mx={3} mt={-1} title="Pożądane ofiary">
            {(!wanted && `${deity} nie chce żadnych ofiar.`) ||
              `${deity} pragnie: ${wanted}.`}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SectSelectTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { sects } = data;
  return (
    <Section fill title="Wybór wyznania" scrollable>
      <Stack vertical>
        {(sects || []).map((sect) => (
          <Fragment key={sect.path}>
            <Collapsible
              mb={-1}
              childStyles={{ paddingTop: '0.5rem' }}
              title={
                <Stack mt={-3.3} ml={4}>
                  <Stack.Item>
                    <Icon
                      name={sect.icon}
                      color={ALIGNMENT2COLOR[sect.alignment]}
                    />
                  </Stack.Item>
                  <Stack.Item grow>{sect.name}</Stack.Item>
                  <Stack.Item italic>{`"${sect.quote}"`}</Stack.Item>
                </Stack>
              }
              color="transparent"
            >
              <Stack.Item>
                {sect.desc}
                <br />
                <Button
                  mt={0.25}
                  textAlign="center"
                  icon="plus"
                  fluid
                  onClick={() =>
                    act('sect_select', {
                      path: sect.path,
                    })
                  }
                >
                  Wybierz: {sect.name}
                </Button>
              </Stack.Item>
            </Collapsible>
            <Stack.Divider />
          </Fragment>
        ))}
      </Stack>
    </Section>
  );
};

const RiteTab = (props) => {
  const { act, data } = useBackend<Data>();
  const { rites, deity, icon, alignment, favor } = data;
  return (
    <>
      {!rites.length && (
        <Section fill>
          <Dimmer>
            <Stack vertical>
              <Stack.Item textAlign="center">
                <Icon
                  color={ALIGNMENT2COLOR[alignment]}
                  name={icon}
                  size={10}
                />
              </Stack.Item>
              <Stack.Item fontSize="18px" color={ALIGNMENT2COLOR[alignment]}>
                {deity} nie ma żadnych obrzędów.
              </Stack.Item>
            </Stack>
          </Dimmer>
        </Section>
      )}
      <Stack vertical>
        {rites.map((rite) => (
          <Stack.Item key={rite.path}>
            <Section
              title={rite.name}
              buttons={
                <Button
                  textColor="white"
                  iconColor={ALIGNMENT2COLOR[alignment]}
                  disabled={favor < rite.favor}
                  color="transparent"
                  icon="arrow-right"
                  onClick={() =>
                    act('perform_rite', {
                      path: rite.path,
                    })
                  }
                >
                  Odpraw
                </Button>
              }
            >
              <Box color={favor < rite.favor ? 'red' : 'grey'} mb={0.5}>
                <Icon name="star" color={ALIGNMENT2COLOR[alignment]} /> Koszt:{' '}
                {rite.favor} łaski.
              </Box>
              <BlockQuote>{rite.desc}</BlockQuote>
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </>
  );
};
