package com.mycompany.app.domain;

import java.util.ArrayList;
import java.util.List;

/**
 * A module descriptor consists of:
 * <ul>
 * <li>the module name</li>
 * <li>all input and output ports to the module</li>
 * <li>all local variables of the module</li>
 * <li>a list of initial processes</li>
 * <li>a list of non-initial processes</li>
 * <li>
 * <ul>
 *      <li>assign is converted to a process</li>
 *      <li>if a module is instantiated within a module, a process for that instantiated module is created</li>
 * </ul>
 * </li>
 */
public class ModuleDescriptor {

    public String name;

    public List<Port> ports = new ArrayList<>();

    public List<Process> initialProcesses = new ArrayList<>();

    public List<Process> processes = new ArrayList<>();

}
