package com.mycompany.app.ast.visitor;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.AlwaysConstructASTNode;
import com.mycompany.app.ast.AssignmentASTNode;
import com.mycompany.app.ast.CaseStatementASTNode;
import com.mycompany.app.ast.CaseStatementItemASTNode;
import com.mycompany.app.ast.ConditionalStatementASTNode;
import com.mycompany.app.ast.DataDeclarationASTNode;
import com.mycompany.app.ast.DataTypeASTNode;
import com.mycompany.app.ast.ExpressionStatementASTNode;
import com.mycompany.app.ast.IfStatementASTNode;
import com.mycompany.app.ast.InstanceASTNode;
import com.mycompany.app.ast.ListOfPortConnectionsASTNode;
import com.mycompany.app.ast.ModuleDeclaractionASTNode;
import com.mycompany.app.ast.ModuleItemDeclarationASTNode;
import com.mycompany.app.ast.NetAssignmentASTNode;
import com.mycompany.app.ast.ParameterListASTNode;
import com.mycompany.app.ast.PortASTNode;
import com.mycompany.app.ast.PortConnectionASTNode;
import com.mycompany.app.ast.PrimaryTfCallASTNode;
import com.mycompany.app.ast.ProceduralTimingControlStatementASTNode;
import com.mycompany.app.ast.VariableAssignmentASTNode;

public abstract class BaseASTNodeVisitor implements ASTNodeVisitor {

    public void start(ASTNode node) {
        for (ASTNode child : node.children) {
            child.visit(this);
        }
    }

    public void visit(ASTNode astNode) {}

    public void visit(AlwaysConstructASTNode node) {}

    public void visit(AssignmentASTNode node) {}

    public void visit(ModuleDeclaractionASTNode moduleDeclaractionASTNode) {}

    public void visit(CaseStatementASTNode caseStatementASTNode) {}

    public void visit(CaseStatementItemASTNode caseStatementItemASTNode) {}

    public void visit(ConditionalStatementASTNode conditionalStatementASTNode) {}

    public void visit(DataDeclarationASTNode dataDeclarationASTNode) {}

    public void visit(DataTypeASTNode dataTypeASTNode) {}

    public void visit(ExpressionStatementASTNode expressionStatementASTNode) {}

    public void visit(IfStatementASTNode ifStatementASTNode) {}

    public void visit(InstanceASTNode instanceASTNode) {}

    public void visit(ListOfPortConnectionsASTNode listOfPortConnectionsASTNode) {}

    public void visit(ModuleItemDeclarationASTNode moduleItemDeclarationASTNode) {}

    public void visit(NetAssignmentASTNode netAssignmentASTNode) {}

    public void visit(ParameterListASTNode parameterListASTNode) {}

    public void visit(PortASTNode portASTNode) {}

    public void visit(PortConnectionASTNode portConnectionASTNode) {}

    public void visit(PrimaryTfCallASTNode primaryTfCallASTNode) {}

    public void visit(ProceduralTimingControlStatementASTNode proceduralTimingControlStatementASTNode) {}

    public void visit(VariableAssignmentASTNode variableAssignmentASTNode) {}

}
