package com.mycompany.app.ast.visitor;

import com.mycompany.app.ast.AlwaysConstructASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.DataTypeASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.ParameterPortASTNode;
import com.mycompany.app.ast.ParameterPortListASTNode;
import com.mycompany.app.ast.PortASTNode;
import com.mycompany.app.ast.PortDirection;
import com.mycompany.app.ast.RangeExpressionASTNode;
import com.mycompany.app.ast.VariableAssignmentASTNode;
import com.mycompany.app.domain.ModuleDescriptor;
import com.mycompany.app.domain.Port;
import com.mycompany.app.domain.Process;

public class DefaultASTNodeVisitor extends BaseASTNodeVisitor {

    public ModuleDescriptor moduleDescriptor;

    // @Override
    // public void visit(final AlwaysConstructASTNode node) {
    // System.out.println(node.getClass());
    // }

    // @Override
    // public void visit(final AssignmentASTNode node) {
    // System.out.println(node.getClass());
    // }

    @Override
    public void visit(final ModuleDeclaractionASTNode node) {

        System.out.println(node.getClass());

        // name
        moduleDescriptor.name = node.name;

        PortDirection portDirection = null;
        DataTypeASTNode dataType = null;

        // port AST node
        for (PortASTNode portASTNode : node.ports) {

            if (portASTNode.portDirection == PortDirection.UNKNOWN) {
                portASTNode.portDirection = portDirection;
            }
            if (portASTNode.dataType == null) {
                portASTNode.dataType = dataType;
            }

            System.out.println(portASTNode.portDirection + " " + portASTNode.value + " " + portASTNode.dataType.value
                    + " " + portASTNode.dataType.rangeExpression.toString());

            Port port = new Port();
            moduleDescriptor.ports.add(port);

            port.portDirection = portASTNode.portDirection;
            port.name = portASTNode.value;
            port.dataType = portASTNode.dataType.value;
            if (portASTNode.dataType.rangeExpression != null) {

                RangeExpressionASTNode rangeExpressionASTNode = (RangeExpressionASTNode) portASTNode.dataType.rangeExpression;
                port.rangeLeft = rangeExpressionASTNode.left.value;
                port.rangeRight = rangeExpressionASTNode.right.value;
            }

            portDirection = portASTNode.portDirection;
            dataType = portASTNode.dataType;
        }
    }

    @Override
    public void visit(final VariableAssignmentASTNode node) {

        System.out.println(node.getClass());

        // TODO: find all signals used in the RHS of the expression
        // and add them to the sensitivity list of the process

        Process process = new Process();
        process.statements.add(node);
        moduleDescriptor.processes.add(process);
    }

    public void visit(ParameterPortListASTNode parameterPortListASTNode) {
        System.out.println(parameterPortListASTNode.getClass());
    }

    public void visit(ParameterPortASTNode parameterPortASTNode) {
        System.out.println(parameterPortASTNode.getClass());
    }

}
