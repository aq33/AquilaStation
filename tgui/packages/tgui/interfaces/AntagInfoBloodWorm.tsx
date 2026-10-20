// AQUILA - okno roli krwawego robaka (port z tgstation#93787)
import { LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Team = {
  blood_consumed_total: number;
  times_reproduced_total: number;
};

type Data = {
  objectives: Objective[];
  team: Team;
};

type Entry = {
  label: string;
  text: string;
};

const POWERS: Entry[] = [
  {
    label: 'Bez oddechu',
    text: 'Nie musisz oddychać. Dotyczy to też twoich nosicieli.',
  },
  {
    label: 'Picie krwi',
    text: 'Rośniesz, pijąc krew Wysysaniem krwi albo wnikając w zwłoki. Krew syntetyczna, np. z małp i worków, liczy się do wzrostu tylko do pewnej granicy. HUD pokazuje poziom krwi każdego, a oględziny celu mówią, ile krwi ma i ile by ci dała.',
  },
  {
    label: 'Etapy wzrostu',
    text: 'Postęp wzrostu widać na przycisku dojrzewania i po najechaniu na ikonę robaka w prawym górnym rogu. Gdy urośniesz, zamknij się w kokonie, by przejść na kolejny etap. Młody robak pluje krwią, a dorosły jest niezwykle silny.',
  },
  {
    label: 'Wentylacja',
    text: 'Larwy chodzą rurami wentylacji. Po dojrzeniu tracisz tę zdolność i zostają ci szpary pod drzwiami, rozbijanie drzwi i dostęp z identyfikatora. Zanim dojrzejesz, znajdź dobre miejsce albo nosiciela.',
  },
  {
    label: 'Szpary pod drzwiami',
    text: 'Larwy i młode robaki wślizgują się pod drzwi (prawy klik na drzwiach). Dorosłe już nie.',
  },
  {
    label: 'Rozmnażanie',
    text: 'Dorosły robak może się rozmnożyć: z kokonu wychodzą 3 nowe larwy, a ty sam wracasz do postaci larwy.',
  },
  {
    label: 'Pasożytnictwo',
    text: 'Potrafisz zamienić się w krew i wniknąć w zwłoki człowieka, robiąc z nich nosiciela. Możesz też przeciągnąć siebie na zwłoki.',
  },
  {
    label: 'Regeneracja',
    text: 'Powoli się leczysz, z progu śmierci do pełni sił w około 5 minut. W nosicielu oznacza to powolne odzyskiwanie krwi. Wstrzyknięciem krwi szybko leczysz nosiciela kosztem własnego zdrowia.',
  },
  {
    label: 'Podtrzymanie życia',
    text: 'Nosiciel nie potrzebuje oddychać ani mieć sprawnego serca i wątroby, wystarczy mu mózg. Martwego nosiciela wskrzesisz jego własną krwią.',
  },
  {
    label: 'Obcy umysł',
    text: 'Twój umysł nie jest ludzki. Nie znasz strachu, nawet w nosicielu.',
  },
];

const WEAKNESSES: Entry[] = [
  {
    label: 'Zimno i próżnia',
    text: 'Dobrze znosisz chłód i niskie ciśnienie, ale skrajne zimno i próżnia cię ranią. W nosicielu cię to nie dotyczy, a nosiciela ochroni skafander.',
  },
  {
    label: 'Gorąco',
    text: 'Źle znosisz wysoką temperaturę i szybko się w niej spalasz. To działa też w nosicielu, chyba że ubierzesz go w ognioodporny strój.',
  },
  {
    label: 'Krwawienie',
    text: 'W nosicielu cały jesteś krwią, więc jego krwawienie rani bezpośrednio ciebie. Nosiciele krwawią też po śmierci i o 50% szybciej niż zwykli ludzie.',
  },
  {
    label: 'Słabsze ciało',
    text: 'Nosicielom brakuje twoich zmysłów, więc ciemność i granaty błyskowe działają na nich normalnie. Pomogą gogle noktowizyjne, ochrona oczu i uszu.',
  },
  {
    label: 'Testy',
    text: 'Korporacja DeForest stworzyła jednorazowe testery, które wykrywają krwawe robaki. Ochrona może je zamówić w cargo. Działają od razu, ale bolą i są drogie.',
  },
];

const TIPS: Entry[] = [
  {
    label: 'Ciche leczenie',
    text: 'Leczenie nosiciela w medbayu zamiast własną krwią nie zostawia mu trupio bladej skóry i oszczędza krew na plucie i leczenie.',
  },
  {
    label: 'Niespodzianka',
    text: 'Możesz wyjść z nosiciela, by kogoś zaskoczyć, zwłaszcza jako dorosły. Najpierw odetnij drogi ucieczki, bo wychodzenie trwa 3 sekundy.',
  },
  {
    label: 'Ostatnia deska ratunku',
    text: 'Gdy zostanie ci mniej niż 10% zdrowia we krwi, nosiciel cię wyrzuci. To szansa na ucieczkę w ostatniej chwili.',
  },
  {
    label: 'Bufet w medbayu',
    text: 'Lodówki z krwią w medbayu to niezłe źródło syntetycznej krwi, gdy nie ma małp. Uważaj, łamanie lodówki słychać przez ściany.',
  },
  {
    label: 'Szybki posiłek',
    text: 'Wnikając w zwłoki, błyskawicznie wypijasz całą ich krew. Krew zdobyta już w nosicielu nie liczy się do wzrostu.',
  },
  {
    label: 'Stado',
    text: 'Pobratymcy zwykle mają te same cele. Rozmawiacie po robaczemu (klawisz języka: w), którego nikt inny nie rozumie. Nosicieli rozpoznasz po ikonie nad głową.',
  },
  {
    label: 'Cela',
    text: 'Ochrona cię złapała? Z aktywnym Pluciem krwią prawy klik rozpuszcza kajdanki, kaftan, a nawet zawiasy szafki. Możesz też wyjść z nosiciela i uciec wentylacją albo przez drzwi.',
  },
];

const EntryList = (props: { entries: Entry[] }) => (
  <LabeledList>
    {props.entries.map((entry) => (
      <LabeledList.Item key={entry.label} label={entry.label}>
        {entry.text}
      </LabeledList.Item>
    ))}
  </LabeledList>
);

export const AntagInfoBloodWorm = (props) => {
  const { data } = useBackend<Data>();
  const { objectives = [], team } = data;
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              Jesteś krwawym robakiem!
            </Stack.Item>
            <Stack.Item>
              <Section title="Cele">
                <Stack vertical>
                  {objectives.map((objective) => (
                    <Stack.Item key={objective.count}>
                      <b>{objective.name}</b>: {objective.explanation}
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Stan stada">
                - Wypita krew: {team?.blood_consumed_total ?? 0} j.
                <br />- Rozmnożeń: {team?.times_reproduced_total ?? 0}
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Moce">
                <EntryList entries={POWERS} />
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Słabości">
                <EntryList entries={WEAKNESSES} />
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Porady">
                <EntryList entries={TIPS} />
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
