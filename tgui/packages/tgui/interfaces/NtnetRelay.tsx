import {
  AnimatedNumber,
  Box,
  Button,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  enabled: BooleanLike;
  dos_capacity: number;
  dos_overload: number;
  dos_crashed: BooleanLike;
};

const OUTAGE_WARNING = `System ma chwilową awarię z powodu przepełnienia
buforów ruchu. Dopóki zbuforowany ruch nie zostanie przetworzony, wszystkie
kolejne żądania będą odrzucane. Częste występowanie tego błędu może
oznaczać niewystarczającą przepustowość sprzętu Twojej sieci. Skontaktuj
się z działem planowania sieci, aby uzyskać instrukcje rozwiązania problemu.`;

export const NtnetRelay = (props) => {
  const { act, data } = useBackend<Data>();
  const { enabled, dos_capacity, dos_overload, dos_crashed } = data;

  return (
    <Window title="Przekaźnik kwantowy NtNet" width={400} height={300}>
      <Window.Content>
        <Section
          title="Bufor sieci"
          buttons={
            <Button
              icon="power-off"
              selected={enabled}
              onClick={() => act('toggle')}
            >
              {enabled ? 'WŁĄCZONY' : 'WYŁĄCZONY'}
            </Button>
          }
        >
          {!dos_crashed ? (
            <ProgressBar
              value={dos_overload}
              minValue={0}
              maxValue={dos_capacity}
            >
              <AnimatedNumber value={dos_overload} /> GQ
              {' / '}
              {dos_capacity} GQ
            </ProgressBar>
          ) : (
            <Box fontFamily="monospace">
              <Box fontSize="20px">PRZEPEŁNIENIE BUFORA SIECI</Box>
              <Box fontSize="16px">TRYB ODZYSKIWANIA PO PRZECIĄŻENIU</Box>
              <Box>{OUTAGE_WARNING}</Box>
              <Box fontSize="20px" color="bad">
                OBEJŚCIE ADMINISTRATORA
              </Box>
              <Box fontSize="16px" color="bad">
                UWAGA - MOŻLIWA UTRATA DANYCH
              </Box>
              <Button
                icon="signal"
                mt={1}
                color="bad"
                onClick={() => act('restart')}
              >
                WYCZYŚĆ BUFOR
              </Button>
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
