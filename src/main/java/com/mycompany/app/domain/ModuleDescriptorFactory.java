package com.mycompany.app.domain;

import com.mycompany.app.ast.ASTNode;
import com.mycompany.app.ast.visitor.DefaultASTNodeVisitor;
import com.mycompany.app.common.Factory;

/**
 * Assumption: The input AST contains exactly a singular module description.
 *
 * The ModuleDescriptorFactory extracts the module and returns a
 * ModuleDescriptor that describes the module
 */
public class ModuleDescriptorFactory implements Factory<ASTNode, ModuleDescriptor> {

    @Override
    public ModuleDescriptor produce(ASTNode rootASTNode) {

        ModuleDescriptor moduleDescriptor = new ModuleDescriptor();

        DefaultASTNodeVisitor defaultASTNodeVisitor = new DefaultASTNodeVisitor();
        defaultASTNodeVisitor.moduleDescriptor = moduleDescriptor;
        defaultASTNodeVisitor.start(rootASTNode);

        return moduleDescriptor;
    }

}
