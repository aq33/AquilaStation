import { BlockQuote, Button, Flex, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: nasze prawa mają też kategorie diabelskie i jonowe
const lawTypeColors = {
  devil: 'orange',
  zeroth: 'red',
  hacked: 'red',
  ion: 'blue',
  inherent: 'white',
  supplied: 'purple',
};

type Law = {
  text: string;
  number: string;
  type: string;
  // AQUILA: przełączniki działają na indeksach list lawcheck/ioncheck/...
  category: string;
  index: number;
  checked: BooleanLike;
};

type Data = {
  locked: BooleanLike;
  all_laws: Law[];
};

export const StateLawUi = () => {
  const { data, act } = useBackend<Data>();
  const { locked, all_laws = [] } = data;

  return (
    <Window
      title="Ogłoś prawa"
      width={400}
      height={Math.min(700, Math.max(1, all_laws.length) * 55 + 150)}
    >
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section
          title="Które prawa chcesz uwzględnić, ogłaszając je załodze?"
          scrollable
        >
          <Stack vertical>
            {all_laws.length === 0 ? (
              <Stack.Item>
                <BlockQuote>Brak praw!</BlockQuote>
              </Stack.Item>
            ) : (
              all_laws.map((law) => (
                <Stack.Item
                  key={`${law.category}-${law.index}`}
                  className="candystripe"
                >
                  <Flex align="center" p={0.5}>
                    <Flex.Item mr={0.5}>
                      <Button.Checkbox
                        iconSize={2}
                        checked={!!law.checked}
                        onClick={() =>
                          act('toggle_stated', {
                            category: law.category,
                            index: law.index,
                          })
                        }
                      />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <BlockQuote
                        textColor={lawTypeColors[law.type] || 'white'}
                      >
                        {law.number}. {law.text}
                      </BlockQuote>
                    </Flex.Item>
                  </Flex>
                </Stack.Item>
              ))
            )}
          </Stack>
        </Section>
        <Section>
          <Button.Confirm
            width="100%"
            textAlign="center"
            fontSize="20px"
            color="blue"
            confirmColor="green"
            confirmContent="Na pewno?"
            disabled={locked}
            onClick={() => act('state_laws')}
            italic={!!locked}
          >
            {locked ? 'Trwa ogłaszanie' : 'Ogłoś prawa'}
          </Button.Confirm>
        </Section>
      </Window.Content>
    </Window>
  );
};
