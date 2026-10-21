// AQUILA: port okna Gateway z tg (.jsx -> .tsx). U nas brama ma jeden stały cel
// (misja zewnętrzna albo stacja) i nie ma konsoli ani podglądu kamery (ByondUi).
import {
  Box,
  Button,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Destination = {
  name: string;
  available: BooleanLike;
  calibrated: BooleanLike;
  reason?: string;
  timeout?: number;
};

type Data = {
  gateway_present: BooleanLike;
  gateway_status: BooleanLike;
  active: BooleanLike;
  destination: Destination | null;
};

export const Gateway = () => {
  return (
    <Window width={350} height={260}>
      <Window.Content scrollable>
        <GatewayContent />
      </Window.Content>
    </Window>
  );
};

const GatewayContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    gateway_present = false,
    gateway_status = false,
    active = false,
    destination = null,
  } = data;
  if (!gateway_present) {
    return (
      <Section>
        <NoticeBox>
          Brama jest niekompletna. Brakuje części wokół środkowego elementu.
        </NoticeBox>
      </Section>
    );
  }
  if (!destination) {
    return <Section>Nie wykryto żadnego celu bramy.</Section>;
  }
  if (active) {
    return (
      <Section title={destination.name}>
        <Box mb={1} color="good">
          Brama jest aktywna.
        </Box>
        {!destination.calibrated && (
          <NoticeBox color="average">
            Brama docelowa nie jest skalibrowana: skok może skończyć się w
            przypadkowym miejscu.
          </NoticeBox>
        )}
        <Button
          mt="2px"
          textAlign="center"
          fluid
          onClick={() => act('deactivate')}
        >
          Wyłącz
        </Button>
      </Section>
    );
  }
  return (
    <>
      {!gateway_status && <NoticeBox>Brama nie ma zasilania</NoticeBox>}
      <Section title={destination.name}>
        {(destination.available && (
          <>
            {!destination.calibrated && (
              <NoticeBox color="average">
                Brama docelowa nie jest skalibrowana: skok może skończyć się w
                przypadkowym miejscu.
              </NoticeBox>
            )}
            <Button
              fluid
              disabled={!gateway_status}
              onClick={() => act('activate')}
            >
              Uruchom
            </Button>
          </>
        )) || (
          <>
            <Box m={1} textColor="bad">
              {destination.reason}
            </Box>
            {!!destination.timeout && (
              <ProgressBar value={destination.timeout}>
                Kalibracja...
              </ProgressBar>
            )}
          </>
        )}
      </Section>
    </>
  );
};
