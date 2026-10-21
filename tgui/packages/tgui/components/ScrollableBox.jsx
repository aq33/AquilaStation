import { useEffect, useRef } from 'react';
import { addScrollableNode, removeScrollableNode } from 'tgui/events';
import { Box } from 'tgui-core/components';

export const ScrollableBox = (props) => {
  const { children, ...rest } = props;
  const node = useRef(null);
  useEffect(() => {
    const self = node.current;
    if (self) {
      addScrollableNode(self);
    }
    return () => {
      if (self) {
        removeScrollableNode(self);
      }
    };
  }, []);

  return (
    <Box ref={node} {...rest}>
      {children}
    </Box>
  );
};
