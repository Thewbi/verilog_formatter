package com.mycompany.app;

import com.mycompany.app.ast.PortDirection;

/**
 * https://stackoverflow.com/questions/18067571/indexing-vectors-and-arrays-with
 * 
 * Description and examples can be found in IEEE Std 1800-2017 § 11.5.1
 * "Vector bit-select and part-select addressing". First IEEE appearance is
 * IEEE 1364-2001 (Verilog) § 4.2.1 "Vector bit-select and part-select
 * addressing".
 */
public enum RangeExpressionSeparatorType {

    DEFAULT_SEPARATOR,

    OFFSET_POSITIVE,

    OFFSET_NEGATIVE,

    UNKNOWN;

    public static RangeExpressionSeparatorType fromString(final String data) {

        String rangeExpressionSeparatorAsString = data.trim().toLowerCase();
        if (rangeExpressionSeparatorAsString.equalsIgnoreCase(":")) {
            return DEFAULT_SEPARATOR;
        } else if (rangeExpressionSeparatorAsString.equalsIgnoreCase("+:")) {
            return OFFSET_POSITIVE;
        } else if (rangeExpressionSeparatorAsString.equalsIgnoreCase("-+")) {
            return OFFSET_NEGATIVE;
        }

        return UNKNOWN;
    }

    public static String toString(final RangeExpressionSeparatorType data) {

        switch (data) {

            case DEFAULT_SEPARATOR:
                return ":";

            case OFFSET_POSITIVE:
                return "+:";

            case OFFSET_NEGATIVE:
                return "-:";

            default:
                return "UNKNOWN";
        }
    }

}
