import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { DIRECTIVE_COMPREHENSION, DIRECTIVE_ORDER } from './constants';
import type { PaiData } from './types';

/** Shows the hardcoded PAI info along with any supplied orders. */
export function DirectiveDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { directives = [], prime_directive } = data;

  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <Section fill scrollable title="Rdzeń logiczny">
          <Box color="label">
            {DIRECTIVE_COMPREHENSION}
            <br />
            <br />
            {DIRECTIVE_ORDER}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Dyrektywy">
          <LabeledList>
            <LabeledList.Item label="Główna">
              {prime_directive ? decodeHtmlEntities(prime_directive) : 'Brak.'}
            </LabeledList.Item>
            <LabeledList.Item label="Dodatkowe">
              {directives?.length
                ? directives.map((law, index) => (
                    <BlockQuote key={index}>
                      {decodeHtmlEntities(law)}
                    </BlockQuote>
                  ))
                : 'Brak.'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
