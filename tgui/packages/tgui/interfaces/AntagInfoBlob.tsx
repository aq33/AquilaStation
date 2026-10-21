import {
  Box,
  Collapsible,
  Divider,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { Objective } from './common/Objectives';

type Data = {
  color: string;
  description: string;
  effects: string;
  name: string;
  objectives: Objective[];
};

const BLOB_COLOR = '#556b2f';

export const AntagInfoBlob = (props) => {
  return (
    <Window width={400} height={550}>
      <Window.Content>
        <Section fill scrollable>
          <Overview />
          <Divider />
          <Basics />
          <Structures />
          <Minions />
          <ObjectiveDisplay />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Overview = (props) => {
  const { data } = useBackend<Data>();
  const { color, description, effects, name } = data;

  if (!name) {
    return (
      <Stack vertical>
        <Stack.Item bold fontSize="14px" textColor={BLOB_COLOR}>
          Nie ujawniłeś jeszcze swojej prawdziwej postaci!
        </Stack.Item>
        <Stack.Item>
          Musisz poddać się infekcji. Znajdź bezpieczne miejsce i pęknij!
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack vertical>
      <Stack.Item bold fontSize="24px" textColor={BLOB_COLOR}>
        Jesteś Blobem!
      </Stack.Item>
      <Stack.Item>Jako nadumysł sterujesz blobem.</Stack.Item>
      <Stack.Item>
        Twój odczynnik bloba:{' '}
        <span
          style={{
            color,
          }}
        >
          {name}
        </span>
      </Stack.Item>
      <Stack.Item>
        Dzięki odczynnikowi{' '}
        <span
          style={{
            color,
          }}
        >
          {name}
        </span>{' '}
        {description}
      </Stack.Item>
      {effects && (
        <Stack.Item>
          Poza tym{' '}
          <span
            style={{
              color,
            }}
          >
            {name}
          </span>
          : {effects}
        </Stack.Item>
      )}
    </Stack>
  );
};

const Basics = (props) => {
  return (
    <Collapsible title="Podstawy">
      <LabeledList>
        <LabeledList.Item label="Atak">
          Rozrastając się, atakujesz ludzi, niszczysz obiekty albo stawiasz
          zwykłego bloba, jeśli pole jest wolne.
        </LabeledList.Item>
        <LabeledList.Item label="Rdzeń">
          Rdzeń bloba postawisz ręcznie przyciskiem „Place Blob Core” w prawym
          dolnym rogu ekranu.
          <br />
          <br />
          Jeśli jesteś infekcją bloba, możesz postawić rdzeń tam, gdzie stoisz,
          przyciskiem „Pop” w lewym górnym rogu ekranu.
        </LabeledList.Item>
        <LabeledList.Item label="HUD">
          Oprócz przycisków na HUD-zie masz kilka skrótów myszy, które
          przyspieszają rozrost i obronę.
        </LabeledList.Item>
        <LabeledList.Item label="Skróty">
          Kliknięcie = rozrost bloba <br />
          Środkowy przycisk myszy = zbiórka zarodników <br />
          Ctrl + kliknięcie = blob tarczowy <br />
          Alt + kliknięcie = usunięcie bloba <br />
        </LabeledList.Item>
        <LabeledList.Item label="Łączność">
          Gdy coś powiesz, wiadomość trafi do wszystkich innych nadumysłów, więc
          możecie się koordynować.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Minions = (props) => {
  return (
    <Collapsible title="Sługi">
      <LabeledList>
        <LabeledList.Item label="Grzybonauci">
          Tę jednostkę produkują fabryki za opłatą. Są wytrzymali, silni i dość
          bystrzy. Fabryka, która ich wyprodukuje, staje się krucha i przez
          chwilę nie może produkować zarodników.
        </LabeledList.Item>
        <LabeledList.Item label="Zarodniki">
          Fabryki produkują je same. Są słabe, ale można je zebrać do ataku na
          wrogów. Atakują też wrogów w pobliżu fabryki i próbują zamieniać
          zwłoki w zombie.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const Structures = (props) => {
  return (
    <Collapsible title="Struktury">
      <Box>
        Zwykłe bloby zwiększają twój zasięg i można je ulepszać w bloby
        specjalne o określonych funkcjach. Pamiętaj, że rozrost w kosmos ma 80%
        szans na porażkę!
      </Box>
      <br />
      <Box>Zwykłe bloby możesz ulepszyć w następujące rodzaje:</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Bloby tarczowe">
          Drogie, ale wytrzymują więcej obrażeń. Są też ognioodporne i blokują
          powietrze, więc chronią przed pożarami na stacji.
        </LabeledList.Item>
        <LabeledList.Item label="Bloby odbijające">
          Ulepszenie bloba tarczowego daje blob odbijający, który odbija
          większość pocisków kosztem dodatkowej wytrzymałości bloba tarczowego.
        </LabeledList.Item>
        <LabeledList.Item label="Bloby zasobów">
          Produkują dla ciebie więcej zasobów. Buduj ich jak najwięcej, aby
          pochłonąć stację. Działają tylko w pobliżu węzłów albo rdzenia.
        </LabeledList.Item>
        <LabeledList.Item label="Bloby fabryczne">
          Wytwarzają zarodniki, które atakują pobliskich wrogów. Działają tylko
          w pobliżu węzłów albo rdzenia.
        </LabeledList.Item>
        <LabeledList.Item label="Węzły">
          Rosną jak rdzeń i tak jak on uruchamiają bloby zasobów i fabryczne.
        </LabeledList.Item>
      </LabeledList>
    </Collapsible>
  );
};

const ObjectiveDisplay = (props) => {
  const { data } = useBackend<Data>();
  const { color, objectives = [] } = data;

  return (
    <Collapsible title="Cele">
      <LabeledList>
        {objectives.map(({ explanation }, index) => (
          <LabeledList.Item
            color={color ?? 'white'}
            key={index}
            label={(index + 1).toString()}
          >
            {explanation}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Collapsible>
  );
};
