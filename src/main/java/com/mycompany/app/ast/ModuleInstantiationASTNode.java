package com.mycompany.app.ast;

import java.util.ArrayList;
import java.util.List;

public class ModuleInstantiationASTNode extends ModuleBaseASTNode {

    public String name;

    public List<PortASTNode> ports = new ArrayList<>();

    public List<ParameterAssignmentASTNode> parameterAssignments = new ArrayList<>();

    public String instanceIdentifier;

    public List<ModuleInstantiationPortConnection> portConnections = new ArrayList<>();

    public void printRecursive(StringBuilder stringBuilder, int indent) {

        // indent and name
        for (int i = 0; i < indent; i++) {
            stringBuilder.append("  ");
        }
        stringBuilder.append("ModuleInstantiation: ").append(name).append(" InstanceIdentifier: ").append(instanceIdentifier).append("\n");

        // indent and ports
        if (ports.size() > 0) {
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("Ports: ").append("\n");
            for (ASTNode port : ports) {
                port.printRecursive(stringBuilder, indent + 1);
                stringBuilder.append("\n");
            }
        }

        // parameter assignments
        if (parameterAssignments.size() > 0) {
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("ParameterAssignments: ").append("\n");
            for (ASTNode parameter : parameterAssignments) {
                parameter.printRecursive(stringBuilder, indent + 1);
                stringBuilder.append("\n");
            }
        }

        // port connections
        if (portConnections.size() > 0) {
            for (int i = 0; i < indent; i++) {
                stringBuilder.append("  ");
            }
            stringBuilder.append("portConnections: ").append("\n");
            for (ASTNode portConnection : portConnections) {
                portConnection.printRecursive(stringBuilder, indent + 1);
                stringBuilder.append("\n");
            }
        }

        // // all children
        // // stringBuilder.append("children: ").append("\n");
        // for (ASTNode child : children) {
        //     child.printRecursive(stringBuilder, indent + 1);
        // }
    }

}
