// AQUILA - podświetlanie NTSL z Monkestation (Monkestation/Monkestation2.0#2199), uzupełnione o pola sygnału i funkcje
import { Mode as TextMode } from 'ace-builds/src-noconflict/mode-text';

import { TextHighlightRules } from './text_highlight_rules';

export class NTSLHighlightRules extends TextHighlightRules {
  constructor() {
    super();

    this.$rules = {
      start: [
        // Comments
        { regex: /\/\/.*$/, token: 'comment.line.ntsl' },
        { regex: /\/\*[\s\S]*?\*\//, token: 'comment.block.ntsl' },

        // Strings
        { regex: /"(?:[^"\\]|\\.)*"/, token: 'string.ntsl' },
        { regex: /'(?:[^'\\]|\\.)*'/, token: 'string.ntsl' },

        // Keywords / control
        {
          regex: /\b(if|else|elseif|def|return|while|for|break|continue)\b/,
          token: 'keyword.control.ntsl',
        },

        // Built-in functions
        {
          regex:
            /\b(signal|broadcast|mem|clearmem|remote_signal|pick|find|substr|length|lower|upper|explode|implode|repeat|reverse|tonum|tostring|proper|replace|max|min|prob|rand|sqrt|abs|floor|ceil|round|clamp|inrange|sin|cos|asin|acos|log|time|timestamp|list)\b/,
          token: 'support.function.ntsl',
        },

        // Enums
        {
          regex: /\b(channels|filter_types|languages)\b/,
          token: 'variable.language.ntsl',
        },

        // Signal fields
        {
          regex:
            /\.(content|freq|source|job|pass|filters|language|say|ask|yell|exclaim|sector|uuid)\b/,
          token: 'variable.parameter.ntsl',
        },

        // User functions (detect function call)
        { regex: /\b([\w_]+)(?=\()/, token: 'entity.name.function.ntsl' },

        // Variables
        { regex: /\$[\w_]+\b/, token: 'variable.name.ntsl' },

        // Operators
        {
          regex: /[+\-/*(){};=,|&~^!%<>`]/,
          token: 'keyword.operator.ntsl',
        },

        // Values
        {
          regex:
            /\b(PI|E|SQURT2|FALSE|TRUE|false|true|NORTH|SOUTH|EAST|WEST)\b/,
          token: 'constant.language.ntsl',
        },

        // Numbers
        { regex: /\b\d+(?:\.\d+)?\b/, token: 'constant.numeric.ntsl' },
      ],
    };

    this.normalizeRules();
  }
}

export class NTSLMode extends TextMode {
  $id: string;
  constructor() {
    super();
    this.HighlightRules = NTSLHighlightRules;
    this.$id = 'ace/mode/ntsl';
  }
}
