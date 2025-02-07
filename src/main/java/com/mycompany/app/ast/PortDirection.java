package com.mycompany.app.ast;

public enum PortDirection {

    UNKNOWN,

    INPUT,

    OUTPUT;

    public static PortDirection fromString(final String data) {

        String portDirectionAsString = data.trim().toLowerCase();
        if (portDirectionAsString.equalsIgnoreCase("input")) {
            return INPUT;
        } else if (portDirectionAsString.equalsIgnoreCase("output")) {
            return OUTPUT;
        }

        return UNKNOWN;
    }

}
