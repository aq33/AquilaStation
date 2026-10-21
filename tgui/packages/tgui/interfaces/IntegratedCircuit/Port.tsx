import { Component, createRef } from 'react';
import { Box, Stack } from 'tgui-core/components';

import { noop } from './constants';
import { DisplayName } from './DisplayName';

export class Port extends Component<any> {
  iconRef = createRef<HTMLSpanElement>();

  constructor(props) {
    super(props);
    this.handlePortMouseDown = this.handlePortMouseDown.bind(this);
    this.handlePortRightClick = this.handlePortRightClick.bind(this);
    this.handlePortMouseUp = this.handlePortMouseUp.bind(this);
  }

  handlePortMouseDown(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortMouseDown = noop,
    } = this.props;
    onPortMouseDown(portIndex, componentId, port, isOutput, e);
  }

  handlePortMouseUp(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortMouseUp = noop,
    } = this.props;
    onPortMouseUp(portIndex, componentId, port, isOutput, e);
  }

  handlePortRightClick(e) {
    const {
      port,
      portIndex,
      componentId,
      isOutput,
      onPortRightClick = noop,
    } = this.props;
    onPortRightClick(portIndex, componentId, port, isOutput, e);
  }

  componentDidUpdate() {
    const { port, onPortUpdated } = this.props;
    if (onPortUpdated) {
      onPortUpdated(port, this.iconRef.current);
    }
  }

  componentDidMount() {
    const { port, onPortLoaded } = this.props;
    if (onPortLoaded) {
      onPortLoaded(port, this.iconRef.current);
    }
  }

  renderDisplayName() {
    const { port, portIndex, componentId, isOutput, act } = this.props;

    return (
      <Stack.Item>
        <DisplayName
          act={act}
          port={port}
          isOutput={isOutput}
          componentId={componentId}
          portIndex={portIndex}
        />
      </Stack.Item>
    );
  }

  render() {
    const {
      port,
      isOutput,
      portIndex,
      componentId,
      act,
      onPortMouseDown,
      onPortMouseUp,
      onPortRightClick,
      onPortUpdated,
      onPortLoaded,
      ...rest
    } = this.props;

    return (
      <Stack {...rest} justify={isOutput ? 'flex-end' : 'flex-start'}>
        {!!isOutput && this.renderDisplayName()}
        <Stack.Item>
          <Box
            className="ObjectComponent__Port"
            onMouseDown={this.handlePortMouseDown}
            onContextMenu={this.handlePortRightClick}
            onMouseUp={this.handlePortMouseUp}
          >
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
                overflow: 'visible',
              }}
              viewBox="0, 0, 100, 100"
            >
              <circle
                cx="50"
                cy="50"
                r="50"
                className={`color-fill-${port.color || 'blue'}`}
              />
            </svg>
            <span ref={this.iconRef} className="ObjectComponent__PortPos" />
          </Box>
        </Stack.Item>
        {!isOutput && this.renderDisplayName()}
      </Stack>
    );
  }
}
