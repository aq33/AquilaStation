import {
  Component,
  ComponentProps,
  createRef,
  PropsWithChildren,
  ReactNode,
  RefObject,
} from 'react';
import { CollapsibleSection } from 'tgui/interfaces/common/CollapsibleSection';
import { Box, Button, Flex, Stack } from 'tgui-core/components';

type TabbedMenuProps = {
  categoryEntries: [string, ReactNode][];
  categoryScales: Record<string, string>;
  contentProps?: ComponentProps<typeof Flex>;
  /** AQUILA: przyciski przełączają strony zamiast przewijać do kategorii. */
  paged?: boolean;
};

type TabbedMenuState = {
  selectedCategory: string | null;
};

export class TabbedMenu extends Component<
  TabbedMenuProps & PropsWithChildren,
  TabbedMenuState
> {
  state: TabbedMenuState = { selectedCategory: null };
  categoryRefs: Record<string, RefObject<HTMLDivElement | null>> = {};
  sectionRef: RefObject<HTMLDivElement | null> = createRef();

  getCategoryRef(category: string): RefObject<HTMLDivElement | null> {
    if (!this.categoryRefs[category]) {
      this.categoryRefs[category] = createRef();
    }

    return this.categoryRefs[category];
  }

  render() {
    const { paged } = this.props;
    // W trybie stron pokazujemy jedną kategorię: wybraną albo pierwszą.
    const selectedCategory =
      this.props.categoryEntries?.find(
        ([category]) => category === this.state.selectedCategory,
      )?.[0] || this.props.categoryEntries?.[0]?.[0];
    const shownEntries = paged
      ? this.props.categoryEntries.filter(
          ([category]) => category === selectedCategory,
        )
      : this.props.categoryEntries;
    return (
      <Stack vertical fill>
        {this.props.children && (
          <Stack.Item position="relative">{this.props.children}</Stack.Item>
        )}
        {this.props.categoryEntries?.length > 1 && (
          <Stack.Item>
            <Stack fill px={5}>
              {this.props.categoryEntries.map(([category]) => {
                return (
                  <Stack.Item key={category} grow basis="content">
                    <Button
                      align="center"
                      fontSize="1.2em"
                      fluid
                      selected={paged && category === selectedCategory}
                      onClick={() => {
                        if (paged) {
                          this.setState({ selectedCategory: category });
                          if (this.sectionRef.current) {
                            this.sectionRef.current.scrollTop = 0;
                          }
                          return;
                        }
                        const offsetTop =
                          this.categoryRefs[category].current?.offsetTop;

                        if (offsetTop === undefined) {
                          return;
                        }

                        const currentSection = this.sectionRef.current;

                        if (!currentSection) {
                          return;
                        }

                        currentSection.scrollTop = offsetTop;
                      }}
                    >
                      {category}
                    </Button>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Stack.Item>
        )}

        <Stack.Item
          grow
          innerRef={this.sectionRef}
          position="relative"
          overflowY="scroll"
          {...{
            ...this.props.contentProps,

            // Otherwise, TypeScript complains about invalid prop
            className: undefined,
          }}
        >
          <Flex direction="row" px={2} wrap="wrap">
            {shownEntries.map(([category, children]) => {
              return (
                <Flex.Item
                  grow
                  basis={
                    paged
                      ? '100%'
                      : this.props.categoryScales[category] || '45%'
                  }
                  minWidth={'500px'}
                  px={1}
                  py={2}
                  key={category}
                  innerRef={this.getCategoryRef(category)}
                >
                  <CollapsibleSection
                    minWidth="200px"
                    fill
                    title={
                      <Box inline fontSize={1.3}>
                        {category}
                      </Box>
                    }
                    sectionKey={category}
                  >
                    {children}
                  </CollapsibleSection>
                </Flex.Item>
              );
            })}
          </Flex>
        </Stack.Item>
      </Stack>
    );
  }
}
