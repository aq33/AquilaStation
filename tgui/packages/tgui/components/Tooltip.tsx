// React 19 removed findDOMNode and legacy render, which the old local Tooltip
// relied on. tgui-core ships the same API on top of Floating UI.
export { Tooltip } from 'tgui-core/components';
