import { Box, Collapsible, Divider, Section } from 'tgui/components';
import { sanitizeText } from 'tgui/sanitize';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const PlantScanner = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule } = data;
  return (
    <Window width={750} height={870}>
      <Window.Content>
        <Section textAlign={'center'}>
          {last_target || 'Brak celu w buforze'}
        </Section>
        <Section>
          {render_rule === 'RENDER_RULE_PLANTSEED' ? <SeedRule /> : null}
          {render_rule === 'RENDER_RULE_FRUIT' ? <FruitRule /> : null}
          {render_rule === 'RENDER_RULE_TRAY' ? <TrayRule /> : null}
          {render_rule ? null : 'bufor wyczyszczony 0x0000'}
        </Section>
      </Window.Content>
    </Window>
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
  const { buffer, status = [] } = data;
  const details = Object.entries(buffer).map(([buffer_key, buffer_data]) => (
    <FeatureBlock
      key={buffer_key}
      feature={buffer_data['feature']}
      needs={buffer_data['needs']}
    />
  ));
  return (
    <Box className={'plant__scrollbox'} height={'660px'} overflowY="scroll">
      {status.length > 0 && (
        <Section title="Stan">
          {status.map((line, index) => (
            <Box key={index} mb={'4px'}>
              {line}
            </Box>
          ))}
        </Section>
      )}
      {status.length > 0 ? (
        <Collapsible title="Części, cechy i potrzeby">{details}</Collapsible>
      ) : (
        details
      )}
    </Box>
  );
};

const FruitRule = (props) => {
  const { data } = useBackend();
  const { buffer } = data;
  return (
    <Box className={'plant__scrollbox'} height={'660px'} overflowY="scroll">
      {Object.entries(buffer['genes']).map(([buffer_key, buffer_data]) => (
        <FeatureBlock
          key={buffer_key}
          feature={buffer_data['feature']}
          needs={buffer_data['needs']}
        />
      ))}
      <Box
        className="plant__dialogue"
        style={{ whiteSpace: 'pre-line' }}
        my={'4px'}
        p={'4px'}
      >
        <Box bold mb={'4px'}>
          Zawiera:
        </Box>
        {Object.entries(buffer['reagents']).map(
          ([reagent_key, reagent_data]) => (
            <Box key={reagent_key}>{`${reagent_data}`}</Box>
          ),
        )}
      </Box>
    </Box>
  );
};

const TrayRule = (props) => {
  const { act, data } = useBackend();
  const { buffer, last_target, render_rule } = data;
  return (
    <Box className={'plant__scrollbox'} height={'660px'} overflowY="scroll">
      {Object.entries(buffer).map(([buffer_key, buffer_data]) => (
        <Box
          className={buffer_data === '' ? null : 'plant__dialogue'}
          key={buffer_key}
          my={'2px'}
          style={{ whiteSpace: 'pre-line' }}
        >
          <span
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{
              __html: sanitizeText(buffer_data, false), // This is sanitized in code too
            }}
          />
          {buffer_data === '' ? null : <br />}
        </Box>
      ))}
    </Box>
  );
};
