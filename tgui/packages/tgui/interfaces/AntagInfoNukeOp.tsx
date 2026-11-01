import { BooleanLike } from 'common/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { BlockQuote, Box, Image, Section, Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  antag_name: string;
  nuke_code: string;
  leader: BooleanLike;
  lone: BooleanLike;
};

const MissionNormal = (_props) => {
  const { data } = useBackend<Info>();
  return (
    <BlockQuote>
      <p>
        Twoja misja jest prosta: wysadzić stację. Żeby to zrobić, twoja drużyna
        musi zdobyć dysk nuklearny. Gdy go macie, wystarczy dostarczyć bombę na
        stację, uzbroić ją, uruchomić licznik i uciec, zanim wybuch obróci was w
        pył.
      </p>
      {(!!data.leader && (
        <p>
          Zostajesz dowódcą tej misji: musisz koordynować działania drużyny i
          opracować strategię. Jeśli nie czujesz się na siłach, możesz oddać
          swój identyfikator dowódcy innemu członkowi drużyny.
        </p>
      )) || (
        <p>
          Kluczowa jest koordynacja, dlatego misją kieruje wyznaczony dowódca.
          Słuchaj go, a na pewno wam się uda.
        </p>
      )}
    </BlockQuote>
  );
};

const MissionLone = (_props) => {
  return (
    <BlockQuote>
      <p>
        Wysłano cię samotnie na misję nuklearną. Nie wiadomo, czemu sam, ale
        twoim zadaniem jest zdobyć dysk nuklearny i uruchomić stacyjny system
        autodestrukcji.
      </p>
    </BlockQuote>
  );
};

const MissionSection = (_props) => {
  const { data } = useBackend<Info>();
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Section title="Misja">
                {(!data.lone && <MissionNormal />) || <MissionLone />}
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Section>
                <Image
                  src={resolveAsset('nuke.png')}
                  width="64px"
                  style={{
                    imageRendering: 'pixelated',
                    float: 'left',
                  }}
                />
                <b>Kod bomby</b>: {data.nuke_code}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Section title="Uplink">
                W kieszeni masz{' '}
                <Box inline textColor="red">
                  uplink Syndykatu
                </Box>{' '}
                w postaci radia.
                <br />
                Pozwala ci kupować różny sprzęt przydatny na misji.
                <br />
                Wydawaj telekryształy rozważnie!
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Section title="Bomba atomowa w pigułce">
                <Box className="candystripe">
                  <b>1</b>) Włóż dysk do bomby.
                </Box>
                <Box className="candystripe">
                  <b>2</b>) Wyłącz zabezpieczenie.
                </Box>
                <Box className="candystripe">
                  <b>3</b>) Ustaw licznik bomby (co najmniej 90 sekund).
                </Box>
                <Box className="candystripe">
                  <b>4</b>) Odczep bombę od podłogi.
                </Box>
                <Box className="candystripe">
                  <b>5</b>) Zaciągnij bombę na stację.
                </Box>
                <Box className="candystripe">
                  <b>6</b>) Przytwierdź bombę na stacji (nie w kosmosie!).
                </Box>
                <Box className="candystripe">
                  <b>7</b>) Aktywuj bombę.
                </Box>
                <Box className="candystripe">
                  <b>8</b>) Wyjmij dysk z bomby i zabierz go.
                </Box>
                <Box className="candystripe">
                  <b>9</b>) Uciekaj z zasięgu wybuchu – wróć do bazy z resztą
                  operatorów!
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoNukeOp = (_props) => {
  const { data } = useBackend<Info>();
  const { antag_name } = data;
  return (
    <Window width={620} height={620} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader
              name={antag_name || 'Operator nuklearny'}
              asset="nukie.png"
            />
          </Stack.Item>
          <Stack.Item>
            <MissionSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
