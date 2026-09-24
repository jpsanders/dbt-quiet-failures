{#
    Failure 3: text arrives as mojibake.

    UTF-8 text read as Latin-1 or Windows-1252 turns "José" into "JosÃ©"
    and a curly apostrophe into "â€™". Nothing errors. The noise reaches a
    customer facing report weeks later.

    This test returns every value that contains one of those byte pair
    signatures, or the Unicode replacement character. A single "Ã" is not
    enough to fail, so uppercase Portuguese such as "SÃO PAULO" passes.

    Pass `patterns` to replace the default list.
#}

{% macro quiet_failures_mojibake_patterns() %}
    {{ return([
        'Ã¡', 'Ã©', 'Ã­', 'Ã³', 'Ãº',
        'Ã£', 'Ãµ', 'Ã§',
        'Ã¢', 'Ãª', 'Ã´',
        'Ã¨', 'Ã¬', 'Ã²', 'Ã¹',
        'Ã¤', 'Ã«', 'Ã¯', 'Ã¶', 'Ã¼', 'Ã±',
        'Ã‰', 'Ã“', 'Ãš', 'Ã‡', 'Ãƒ', 'Ã•', 'Ã‘',
        'â€',
        'Ã ', 'Â ', 'Â£', 'Â°', 'Â©', 'Â®', 'Â·', 'Â«', 'Â»',
        '�'
    ]) }}
{% endmacro %}

{% test no_mojibake(model, column_name, patterns=none) %}

{%- set signatures = patterns if patterns is not none else quiet_failures.quiet_failures_mojibake_patterns() -%}

select {{ column_name }} as garbled_value
from {{ model }}
where
{%- for signature in signatures %}
    {% if not loop.first %}or {% endif %}{{ column_name }} like '%{{ signature | replace("'", "''") }}%'
{%- endfor %}

{% endtest %}
