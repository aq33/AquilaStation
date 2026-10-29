import { Box, Button, Icon, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';

export const ReagentLookup = (props) => {
  const { reagent } = props;
  const { act } = useBackend();
  if (!reagent) {
    return <Box>Nie wybrano odczynnika!</Box>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Odczynnik">
        <Icon name="circle" mr={1} color={reagent.reagentCol} />
        {reagent.name}
        <Button
          ml={1}
          icon="wifi"
          color="teal"
          tooltip="Otwórz stronę wiki tego odczynnika."
          tooltipPosition="left"
          onClick={() => {
            Byond.command(`wiki Guide_to_chemistry#${reagent.name}`);
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Opis">{reagent.desc}</LabeledList.Item>
      <LabeledList.Item label="pH">
        <Icon name="circle" mr={1} color={reagent.pHCol} />
        {reagent.pH}
      </LabeledList.Item>
      <LabeledList.Item label="Właściwości">
        <LabeledList>
          {!!reagent.OD && (
            <LabeledList.Item label="Przedawkowanie">
              {reagent.OD} j.
            </LabeledList.Item>
          )}
          {reagent.addictions[0] && (
            <LabeledList.Item label="Uzależnienie">
              {reagent.addictions.map((addiction) => (
                <Box key={addiction}>{addiction}</Box>
              ))}
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Tempo metabolizmu">
            {reagent.metaRate} j./s
          </LabeledList.Item>
        </LabeledList>
      </LabeledList.Item>
      <LabeledList.Item label="Zanieczyszczenia">
        <LabeledList>
          {reagent.impureReagent && (
            <LabeledList.Item label="Odczynnik zanieczyszczony">
              <Button
                icon="vial"
                tooltip="Przy spożyciu ten odczynnik częściowo zamienia się w ten, gdy jego czystość jest wyższa niż czystość odwrócenia."
                tooltipPosition="left"
                content={reagent.impureReagent}
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.impureId,
                  })
                }
              />
            </LabeledList.Item>
          )}
          {reagent.inverseReagent && (
            <LabeledList.Item label="Odczynnik odwrócony">
              <Button
                icon="vial"
                content={reagent.inverseReagent}
                tooltip="Przy spożyciu ten odczynnik zamienia się w ten, gdy jego czystość jest niższa niż czystość odwrócenia."
                tooltipPosition="left"
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.inverseId,
                  })
                }
              />
            </LabeledList.Item>
          )}
          {reagent.failedReagent && (
            <LabeledList.Item label="Odczynnik nieudany">
              <Button
                icon="vial"
                tooltip="Ten odczynnik zamienia się w ten, jeśli czystość reakcji jest pod koniec niższa od minimalnej."
                tooltipPosition="left"
                content={reagent.failedReagent}
                onClick={() =>
                  act('reagent_click', {
                    id: reagent.failedId,
                  })
                }
              />
            </LabeledList.Item>
          )}
        </LabeledList>
        {reagent.isImpure && (
          <Box>Ten odczynnik powstaje z zanieczyszczeń.</Box>
        )}
        {reagent.deadProcess && <Box>Ten odczynnik działa na zwłoki.</Box>}
        {!reagent.failedReagent &&
          !reagent.inverseReagent &&
          !reagent.impureReagent && (
            <Box>Ten odczynnik nie ma odczynników zanieczyszczonych.</Box>
          )}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          icon="flask"
          mt={2}
          content={'Znajdź powiązaną reakcję'}
          color="purple"
          onClick={() =>
            act('find_reagent_reaction', {
              id: reagent.id,
            })
          }
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
