import {
  Box,
  Button,
  Collapsible,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatPower } from '../format';
import { Window } from '../layouts';

type Data = {
  availablePower: any;
  desiredLevel: any;
  emagged: any;
  inputLevel: any;
  maxLevel: any;
  nextLevelPower: any;
  points: any;
  powerUse: any;
  product: any;
  safeLevels: any;
  totalPoints: any;
};

export const BluespaceTap = (props) => {
  const { act, data } = useBackend<Data>();
  const product = data.product || [];
  const {
    desiredLevel,
    inputLevel,
    points,
    totalPoints,
    powerUse,
    availablePower,
    maxLevel,
    emagged,
    safeLevels,
    nextLevelPower,
  } = data;
  const barColor = (desiredLevel > inputLevel && 'bad') || 'good';
  return (
    <Window>
      <Window.Content scrollable>
        {!!emagged && (
          <NoticeBox danger>Protokoły bezpieczeństwa wyłączone</NoticeBox>
        )}
        {!!(inputLevel > safeLevels) && (
          <NoticeBox danger>Wysoka moc, prawdopodobna niestabilność</NoticeBox>
        )}
        <Collapsible title="Zarządzanie poborem">
          <Section title="Pobór">
            <LabeledList>
              <LabeledList.Item label="Poziom poboru">
                {inputLevel}
              </LabeledList.Item>
              <LabeledList.Item label="Docelowy poziom">
                <Flex inline width="100%">
                  <Flex.Item>
                    <Button
                      icon="fast-backward"
                      disabled={desiredLevel === 0}
                      tooltip="Ustaw na 0"
                      onClick={() => act('set', { set_level: 0 })}
                    />
                    <Button
                      icon="step-backward"
                      tooltip="Zmniejsz do obecnego poziomu poboru"
                      disabled={desiredLevel === 0}
                      onClick={() => act('set', { set_level: inputLevel })}
                    />
                    <Button
                      icon="backward"
                      disabled={desiredLevel === 0}
                      tooltip="Zmniejsz o jeden poziom"
                      onClick={() => act('decrease')}
                    />
                  </Flex.Item>
                  <Flex.Item grow={1} mx={1}>
                    <Slider
                      value={desiredLevel}
                      fillValue={inputLevel}
                      minValue={0}
                      color={barColor}
                      maxValue={maxLevel}
                      stepPixelSize={20}
                      step={1}
                      onChange={(e, value) =>
                        act('set', {
                          set_level: value,
                        })
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="forward"
                      disabled={desiredLevel === maxLevel}
                      tooltip="Zwiększ o jeden poziom"
                      tooltipPosition="left"
                      onClick={() => act('increase')}
                    />
                    <Button
                      icon="fast-forward"
                      disabled={desiredLevel === maxLevel}
                      tooltip="Ustaw na maksimum"
                      tooltipPosition="left"
                      onClick={() => act('set', { set_level: maxLevel })}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Obecny pobór mocy">
                {formatPower(powerUse)}
              </LabeledList.Item>
              <LabeledList.Item label="Moc na kolejny poziom">
                {formatPower(nextLevelPower)}
              </LabeledList.Item>
              <LabeledList.Item label="Nadwyżka mocy">
                {formatPower(availablePower)}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Collapsible>
        <Section title="Wydajność">
          <Flex>
            <Flex.Item>
              <Box>
                <LabeledList>
                  <LabeledList.Item label="Dostępne punkty">
                    {points}
                  </LabeledList.Item>
                  <LabeledList.Item label="Punkty łącznie">
                    {totalPoints}
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            </Flex.Item>
            <Flex.Item align="end">
              <Box>
                <LabeledList>
                  {product.map((singleProduct) => (
                    <LabeledList.Item
                      key={singleProduct.key}
                      label={singleProduct.name}
                    >
                      <Button
                        disabled={singleProduct.price >= points}
                        onClick={() =>
                          act('vend', { target: singleProduct.key })
                        }
                        content={singleProduct.price}
                      />
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Box>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
