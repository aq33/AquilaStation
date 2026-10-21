import {
  BlockQuote,
  Box,
  Button,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  polling: BooleanLike;
};

export const ApprenticeContract = (props) => {
  return (
    <Window width={620} height={640}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section textColor="lightgreen" fontSize="15px">
              Dzięki tej umowie możesz przywołać ucznia, który pomoże ci w
              misji. Jeśli nie uda ci się nawiązać kontaktu z uczniem, możesz
              oddać umowę księdze zaklęć, by odzyskać punkty.
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <ApprenticeSelection
              iconName="fire"
              fluffName="Uczeń zniszczenia"
              schoolTitle="destruction"
              blurb={`
                Twój uczeń specjalizuje się w magii ofensywnej.
                Zna Magiczny Pocisk i Kulę Ognia.
              `}
            />
            <ApprenticeSelection
              iconName="route"
              fluffName="Adept translokacji"
              schoolTitle="bluespace"
              blurb={`
                Twój uczeń potrafi przeczyć fizyce, przenikając przez ciała
                stałe i pokonując wielkie odległości w mgnieniu oka.
                Zna Teleportację i Eteryczny Spacer.
              `}
            />
            <ApprenticeSelection
              iconName="medkit"
              fluffName="Nowicjusz uzdrawiania"
              schoolTitle="healing"
              blurb={`
                Twój uczeń szkoli się w zaklęciach pomagających przetrwać.
                Zna Ścianę Mocy i Ładowanie, a do tego ma Kostur Uzdrawiania.
              `}
            />
            <ApprenticeSelection
              iconName="user-secret"
              fluffName="Uczeń bez szat"
              schoolTitle="robeless"
              blurb={`
                Twój uczeń szkoli się w rzucaniu zaklęć bez szat.
                Zna Pukanie i Zamianę Umysłów.
              `}
            />
            {/* AQUILA - szkoła dzikiej magii, której nie ma w tg */}
            <ApprenticeSelection
              iconName="dice"
              fluffName="Adept dzikiej magii"
              schoolTitle="wildmagic"
              blurb={`
                Twój uczeń ćwiczy dziką magię. Nie wiesz, jakie zaklęcia
                mu przypadły, ale taka już jest szkoła dzikiej magii.
              `}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type SelectionProps = {
  iconName: string;
  fluffName: string;
  schoolTitle: string;
  blurb: string;
};

const ApprenticeSelection = (props: SelectionProps) => {
  const { act, data } = useBackend<Data>();
  const { iconName, fluffName, schoolTitle, blurb } = props;
  return (
    <Section>
      <Stack align="center" fill>
        <Stack.Item grow>
          <Box fontSize="20px">
            <Icon name={iconName} /> {fluffName}
          </Box>
          <BlockQuote fontSize="14px">{blurb}</BlockQuote>
        </Stack.Item>
        <Stack.Item>
          <Button
            textAlign="center"
            width="80px"
            disabled={!!data.polling}
            onClick={() =>
              act('buy', {
                school: schoolTitle,
              })
            }
          >
            Wybierz
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
