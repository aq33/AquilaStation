// AQUILA - awaryjny wyrzut rdzenia reaktora (napęd burzowy, RBMK, supermateria)

import { Box, Button, Section } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';

export type CoreEjectionData = {
  available: BooleanLike;
  ejecting: BooleanLike;
  reason: string | null;
  time_left: number;
};

export const CoreEjectionSection = (props: {
  ejection?: CoreEjectionData | null;
}) => {
  const { act } = useBackend();
  const { ejection } = props;
  if (!ejection) {
    return null;
  }
  return (
    <Section title="Awaryjny wyrzut rdzenia">
      {ejection.ejecting ? (
        <>
          <Box color="bad" bold mb={1}>
            Rdzeń wyleci za {ejection.time_left} s.
          </Box>
          <Button
            fluid
            icon="ban"
            color="good"
            onClick={() => act('core_eject_cancel')}
          >
            Przerwij wyrzut
          </Button>
        </>
      ) : (
        <>
          <Box color="label">
            Wymaga dostępu głównego inżyniera albo kapitana.
          </Box>
          <Box color="label" mb={1}>
            Po potwierdzeniu zostaje 30 s na przerwanie.
          </Box>
          {!ejection.available && (
            <Box color="average" mb={1}>
              {ejection.reason}
            </Box>
          )}
          <Button.Confirm
            fluid
            icon="eject"
            color="bad"
            disabled={!ejection.available}
            confirmContent="Na pewno wyrzucić rdzeń?"
            onClick={() => act('core_eject')}
          >
            Wyrzut rdzenia
          </Button.Confirm>
        </>
      )}
    </Section>
  );
};
