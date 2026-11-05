import { useState } from 'react';
import { Box, Button, Divider, LabeledList, Section } from 'tgui/components';
import { sanitizeText } from 'tgui/sanitize';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PlantScanner = (props) => {
  const { data } = useBackend();
  const { last_target, render_rule } = data;
  return (
    <Window width={750} height={870}>
      <Window.Content scrollable>
        {render_rule === 'RENDER_RULE_PLANTSEED' ? <SeedRule /> : null}
        {render_rule === 'RENDER_RULE_FRUIT' ? <FruitRule /> : null}
        {render_rule === 'RENDER_RULE_TRAY' ? <TrayRule /> : null}
        {render_rule ? null : (
          <Section title="Skaner roślin">
            Zeskanuj roślinę, nasiona, owoc albo tacę hydroponiczną.
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const capitalize = (text) =>
  text ? text.charAt(0).toUpperCase() + text.slice(1) : text;

// AQUILA - linie „Etykieta: wartość” jako LabeledList, jak w innych konsolach
const StatusList = (props) => {
  const { lines = [] } = props;
  return (
    <LabeledList>
      {lines.map((line, index) => {
        const split = line.indexOf(': ');
        return split === -1 ? (
          <LabeledList.Item key={index}>{line}</LabeledList.Item>
        ) : (
          <LabeledList.Item key={index} label={line.slice(0, split)}>
            {line.slice(split + 2)}
          </LabeledList.Item>
        );
      })}
    </LabeledList>
  );
};

// AQUILA - wspólny blok części rośliny: pogrubiony nagłówek, cechy i statystyki, potrzeby jako HTML
const FeatureBlock = (props) => {
  const { feature = {}, needs = {} } = props;
  const lines = Object.values(feature).filter((line) => line !== '');
  const needList = Object.values(needs);
  return (
    <Box
      className="plant__dialogue"
      style={{ whiteSpace: 'pre-line' }}
      my={'4px'}
      p={'4px'}
    >
      {lines.map((line, index) => (
        <Box key={index} bold={index === 0} mb={'4px'}>
          {line}
        </Box>
      ))}
      {needList.length > 0 && <Divider />}
      {needList.map((need, index) => (
        <Box key={index} mb={'6px'}>
          <span
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{
              __html: sanitizeText(need, false), // This is sanitized in code too
            }}
          />
        </Box>
      ))}
    </Box>
  );
};

// AQUILA - najpierw krótki stan rośliny, szczegóły genetyczne i katalog potrzeb dopiero po rozwinięciu
const SeedRule = (props) => {
  const { data } = useBackend();
  const { buffer, status = [], last_target } = data;
  const [showDetails, setShowDetails] = useState(!status.length);
  return (
    <>
      {status.length > 0 && (
        <Section title={capitalize(last_target)}>
          <StatusList lines={status} />
        </Section>
      )}
      <Section
        title={
          status.length ? 'Części, cechy i potrzeby' : capitalize(last_target)
        }
        buttons={
          status.length > 0 && (
            <Button
              icon={showDetails ? 'chevron-up' : 'chevron-down'}
              onClick={() => setShowDetails(!showDetails)}
            >
              {showDetails ? 'Ukryj' : 'Pokaż'}
            </Button>
          )
        }
      >
        {showDetails
          ? Object.entries(buffer).map(([buffer_key, buffer_data]) => (
              <FeatureBlock
                key={buffer_key}
                feature={buffer_data['feature']}
                needs={buffer_data['needs']}
              />
            ))
          : 'Budowa rośliny, cechy i pełna lista potrzeb.'}
      </Section>
    </>
  );
};

const FruitRule = (props) => {
  const { data } = useBackend();
  const { buffer, last_target } = data;
  return (
    <>
      <Section title={capitalize(last_target)}>
        {Object.entries(buffer['genes']).map(([buffer_key, buffer_data]) => (
          <FeatureBlock
            key={buffer_key}
            feature={buffer_data['feature']}
            needs={buffer_data['needs']}
          />
        ))}
      </Section>
      <Section title="Zawartość">
        {Object.values(buffer['reagents']).length
          ? Object.entries(buffer['reagents']).map(
              ([reagent_key, reagent_data]) => (
                <Box key={reagent_key}>{`${reagent_data}`}</Box>
              ),
            )
          : 'Brak odczynników.'}
      </Section>
    </>
  );
};

// AQUILA - skan tacy: najpierw dane tacy, potem osobna sekcja na każdą roślinę (linia „<b>Nazwa</b>” zaczyna roślinę)
const TrayRule = (props) => {
  const { data } = useBackend();
  const { buffer = [], last_target } = data;
  const groups = [];
  let current = { title: capitalize(last_target), lines: [] };
  groups.push(current);
  Object.values(buffer).forEach((line) => {
    if (line === '') {
      return;
    }
    const header = /^<b>(.*)<\/b>$/.exec(line);
    if (header) {
      current = { title: header[1], lines: [] };
      groups.push(current);
      return;
    }
    current.lines.push(line);
  });
  return (
    <>
      {groups.map((group, index) => (
        <Section key={index} title={group.title}>
          <StatusList lines={group.lines} />
        </Section>
      ))}
    </>
  );
};
