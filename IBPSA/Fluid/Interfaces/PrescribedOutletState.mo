within IBPSA.Fluid.Interfaces;
model PrescribedOutletState
  "Component that assigns the outlet fluid property at port_a based on an input signal"
  extends IBPSA.Fluid.Interfaces.PartialTwoPortInterface;
  extends IBPSA.Fluid.Interfaces.PrescribedOutletStateParameters(
    redeclare final package _Medium = Medium);

  Modelica.Blocks.Interfaces.RealInput TSet(unit="K", displayUnit="degC") if use_TSet
    "Set point temperature of the fluid that leaves port_b"
    annotation (Placement(transformation(origin={-120,80},
              extent={{20,-20},{-20,20}},rotation=180)));

  Modelica.Blocks.Interfaces.RealInput XiSet(unit="1") if use_XiSet
    "Set point for water vapor mass fraction of the fluid that leaves port_b"
    annotation (Placement(transformation(origin={-120,40},
              extent={{20,-20},{-20,20}},rotation=180)));

  Modelica.Blocks.Interfaces.RealOutput Q_flow(unit="W")
    "Heat flow rate added to the fluid (if flow is from port_a to port_b)"
    annotation (Placement(transformation(extent={{100,70},{120,90}})));

  Modelica.Blocks.Interfaces.RealOutput mWat_flow(unit="kg/s")
    "Water vapor mass flow rate added to the fluid (if flow is from port_a to port_b)"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));

protected
  parameter Modelica.SIunits.SpecificHeatCapacity cp_default=
      Medium.specificHeatCapacityCp(
        Medium.setState_pTX(
          p=Medium.p_default,
          T=Medium.T_default,
          X=Medium.X_default)) "Specific heat capacity at default medium state";

  parameter Boolean restrictHeat = Q_flow_maxHeat < Modelica.Constants.inf/10.0
    "Flag, true if maximum heating power is restricted"
    annotation(Evaluate = true);
  parameter Boolean restrictCool = Q_flow_maxCool > -Modelica.Constants.inf/10.0
    "Flag, true if maximum cooling power is restricted"
    annotation(Evaluate = true);

  parameter Boolean restrictHumi = m_flow_maxHumidification < Modelica.Constants.inf/10.0
    "Flag, true if maximum humidification is restricted"
    annotation(Evaluate = true);
  parameter Boolean restrictDehu = m_flow_maxDehumidification > -Modelica.Constants.inf/10.0
    "Flag, true if maximum dehumidification is restricted"
    annotation(Evaluate = true);

  parameter Modelica.SIunits.SpecificEnthalpy deltaH=
    cp_default*m_flow_small*0.01
    "Small value for deltaH used for regularization";

  parameter Modelica.SIunits.MassFraction deltaXi = 0.001
    "Small mass fraction used for regularization";

  final parameter Boolean dynamic = tau > 1E-10 or tau < -1E-10
    "Flag, true if the sensor is a dynamic sensor";

  Modelica.SIunits.MassFlowRate m_flow_pos
    "Mass flow rate, or zero if reverse flow";

  Modelica.SIunits.MassFlowRate m_flow_non_zero
    "Mass flow rate bounded away from zero";

  Modelica.SIunits.SpecificEnthalpy hSet
    "Set point for enthalpy leaving port_b";

  Modelica.SIunits.Temperature T
    "Temperature of outlet state assuming unlimited capacity and taking dynamics into account";

  Modelica.SIunits.MassFraction Xi
    "Water vapor mass fraction of outlet state assuming unlimited capacity and taking dynamics into account";

  Modelica.SIunits.MassFraction Xi_instream[Medium.nXi]
    "Instreaming water vapor mass fraction at port_a";

  Modelica.SIunits.MassFraction Xi_outflow
    "Outstreaming water vapor mass fraction at port_a";

  Modelica.SIunits.SpecificEnthalpy dhAct
    "Actual enthalpy difference from port_a to port_b";

  Real dXiAct(final unit="1")
    "Actual mass fraction difference from port_a to port_b";

  Real k(start=1)
    "Gain to take flow rate into account for sensor time constant";

  Real mNor_flow "Normalized mass flow rate";

  Modelica.Blocks.Interfaces.RealInput TSet_internal(unit="K", displayUnit="degC")
    "Internal connector for set point temperature of the fluid that leaves port_b";

  Modelica.Blocks.Interfaces.RealInput XiSet_internal(unit="1")
    "Internal connector for set point for water vapor mass fraction of the fluid that leaves port_b";

  function getCapacity "Function to compute outlet state, applied power and difference in potential variable"
    input Real XSet "Set point signal";
    input Real XIn "Inlet potential variable";
    input Real PMax "Maximum power";
    input Real PMin "Minimum power";
    input Boolean restrictMax "true, if maximum power is restricted";
    input Boolean restrictMin "true, if minimum power is restricted";
    input Modelica.SIunits.MassFlowRate m_flow_pos "Non-negative mass flow rate";
    input Modelica.SIunits.MassFlowRate m_flow_non_zero(min=Modelica.Constants.eps)
      "Non-zero, positive mass flow rate";
    input Real deltaX "Small value for smoothing";
    output Real XOut "Actual outlet potential variable";
    output Real P "Power applied";
    output Real dXAct "Actual difference in potential variable, taking power limitation into account";
  algorithm
  if not restrictMax and not restrictMin then
    // No capacity limit
    dXAct :=0;
    XOut :=XSet;
    P :=m_flow_pos*(XSet - XIn);
  else
    if restrictMax and restrictMin then
      // Capacity limits for heating and cooling
      dXAct :=IBPSA.Utilities.Math.Functions.smoothLimit(
            x=XSet - XIn,
            l=PMin/m_flow_non_zero,
            u=PMax/m_flow_non_zero,
            deltaX=deltaX);
    elseif restrictMax then
      // Capacity limit for heating only
      dXAct :=IBPSA.Utilities.Math.Functions.smoothMin(
            x1=XSet - XIn,
            x2=PMax/m_flow_non_zero,
            deltaX=deltaX);
    else
      // Capacity limit for cooling only
      dXAct :=IBPSA.Utilities.Math.Functions.smoothMax(
            x1=XSet - XIn,
            x2=PMin/m_flow_non_zero,
            deltaX=deltaX);
    end if;
    XOut :=XIn + dXAct;
    P :=m_flow_pos*dXAct;
  end if;
  end getCapacity;
initial equation
  if energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
      der(T) = 0;
  elseif energyDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
      T = T_start;
  end if;
  if massDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
      der(Xi) = 0;
  elseif massDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
      Xi = X_start[1];
  end if;

  assert((energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState) or
          tau > Modelica.Constants.eps,
"The parameter tau, or the volume of the model from which tau may be derived, is unreasonably small.
 You need to set energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState to model steady-state.
 Received tau = " + String(tau) + "\n");
  assert((massDynamics == Modelica.Fluid.Types.Dynamics.SteadyState) or
          tau > Modelica.Constants.eps,
"The parameter tau, or the volume of the model from which tau may be derived, is unreasonably small.
 You need to set massDynamics == Modelica.Fluid.Types.Dynamics.SteadyState to model steady-state.
 Received tau = " + String(tau) + "\n");

 if use_XiSet then
  assert(Medium.nX > 1, "If use_XiSet = true, require a medium with water vapor, such as IBPSA.Media.Air");
 end if;

equation
  // Conditional connectors
  if not use_TSet then
    TSet_internal = 293.15;
  end if;
  connect(TSet, TSet_internal);
  if not use_XiSet then
    XiSet_internal = 0.01;
  end if;
  connect(XiSet, XiSet_internal);

  if (use_TSet and energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState) or
     (use_XiSet and massDynamics == Modelica.Fluid.Types.Dynamics.SteadyState) then
    mNor_flow = port_a.m_flow/m_flow_nominal;
    k = Modelica.Fluid.Utilities.regStep(x=port_a.m_flow,
                                         y1= mNor_flow,
                                         y2=-mNor_flow,
                                         x_small=m_flow_small);
  else
    mNor_flow = 1;
    k = 1;
  end if;

  if use_TSet and energyDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState then
    der(T) = (TSet_internal-T)*k/tau;
  else
    T = TSet_internal;
  end if;

  if use_XiSet and massDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState then
    der(Xi) = (XiSet_internal-Xi)*k/tau;
  else
    Xi = XiSet_internal;
  end if;

  Xi_instream = inStream(port_a.Xi_outflow);
  // Set point without any capacity limitation
  // fixme: this should be using XiAct....
  // **********
  hSet = if use_TSet then Medium.specificEnthalpy(
    Medium.setState_pTX(
      p = port_a.p,
      T = T,
      X = inStream(port_a.Xi_outflow) + fill(dXiAct, Medium.nXi)))
        else Medium.h_default;

  m_flow_pos = IBPSA.Utilities.Math.Functions.smoothMax(
    x1=m_flow,
    x2=0,
    deltaX=m_flow_small);

   if not restrictHeat and not restrictCool and
      not restrictHumi and not restrictDehu then
     m_flow_non_zero = Modelica.Constants.eps;
   else
     m_flow_non_zero = IBPSA.Utilities.Math.Functions.smoothMax(
       x1 = port_a.m_flow,
       x2 = m_flow_small,
       deltaX=m_flow_small/2);
   end if;

  // Compute mass fraction leaving the component.
  // Below, we use sum(Xi_instream) as Xi anyway has only one element.
  // However, scalar(Xi_instream) would not work as dim(Xi_instream) = 0
  // if the medium is not a mixture.
  if use_XiSet then
    (Xi_outflow, mWat_flow, dXiAct) = getCapacity(
      XSet = Xi,
      XIn =  sum(Xi_instream),
      PMax = m_flow_maxHumidification,
      PMin = m_flow_maxDehumidification,
      restrictMax = restrictHumi,
      restrictMin = restrictDehu,
      m_flow_pos =      m_flow_pos,
      m_flow_non_zero = m_flow_non_zero,
      deltaX = deltaXi);
    port_b.Xi_outflow = fill(Xi_outflow, Medium.nXi);
  else
    Xi_outflow = sum(Xi_instream);
    mWat_flow = 0;
    dXiAct = 0;
    port_b.Xi_outflow = inStream(port_a.Xi_outflow);
  end if;

  // Compute enthalpy leaving the component.
  if use_TSet then
    (port_b.h_outflow, Q_flow, dhAct) = getCapacity(
      XSet = hSet,
      XIn =  inStream(port_a.h_outflow),
      PMax = Q_flow_maxHeat,
      PMin = Q_flow_maxCool,
      restrictMax = restrictHeat,
      restrictMin = restrictCool,
      m_flow_pos =      m_flow_pos,
      m_flow_non_zero = m_flow_non_zero,
      deltaX = deltaH);
   else
    port_b.h_outflow = inStream(port_a.h_outflow);
    Q_flow = 0;
    dhAct = 0;
  end if;

  // Outflowing property at port_a is unaffected by this model.
  if allowFlowReversal then
    port_a.h_outflow =  inStream(port_b.h_outflow);
    port_a.Xi_outflow = inStream(port_b.Xi_outflow);
    port_a.C_outflow =  inStream(port_b.C_outflow);
  else
    port_a.h_outflow =  Medium.h_default;
    port_a.Xi_outflow = Medium.X_default[1:Medium.nXi];
    port_a.C_outflow =  zeros(Medium.nC);
  end if;
  // No pressure drop
  dp = 0;

  assert(m_flow > -m_flow_small or allowFlowReversal,
      "Reverting flow occurs even though allowFlowReversal is false");

  // Mass balance (no storage)
  port_a.m_flow + port_b.m_flow = 0;

  // Transport of substances
  port_b.C_outflow = inStream(port_a.C_outflow);

    annotation (
  defaultComponentName="heaCoo",
  Icon(coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},{100,100}}),
                      graphics={
        Rectangle(
          extent={{-68,70},{74,-70}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={95,95,95},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-99,6},{102,-4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{2,-4},{102,6}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-94,94},{-76,72}},
          lineColor={0,0,127},
          textString="T"),
        Text(
          extent={{48,102},{92,74}},
          lineColor={0,0,127},
          textString="Q_flow"),
        Text(
          extent={{-92,54},{-74,32}},
          lineColor={0,0,127},
          textString="Xi"),
        Text(
          extent={{50,56},{94,28}},
          lineColor={0,0,127},
          textString="mWat_flow")}),
  Documentation(info="<html>
<p>
This model sets the temperature of the medium that leaves <code>port_a</code>
to the value given by the input <code>TSet</code>, subject to optional
limitations on the heating and cooling capacity.
</p>
<p>
In case of reverse flow, the set point temperature is still applied to
the fluid that leaves <code>port_b</code>.
</p>
<p>
If the parameter <code>energyDynamics</code> is not equal to
<code>Modelica.Fluid.Types.Dynamics.SteadyState</code>,
the component models the dynamic response using a first order differential equation.
The time constant of the component is equal to the parameter <code>tau</code>.
This time constant is adjusted based on the mass flow rate using
</p>
<p align=\"center\" style=\"font-style:italic;\">
&tau;<sub>eff</sub> = &tau; |m&#775;| &frasl; m&#775;<sub>nom</sub>
</p>
<p>
where
<i>&tau;<sub>eff</sub></i> is the effective time constant for the given mass flow rate
<i>m&#775;</i> and
<i>&tau;</i> is the time constant at the nominal mass flow rate
<i>m&#775;<sub>nom</sub></i>.
This type of dynamics is equal to the dynamics that a completely mixed
control volume would have.
</p>
<p>
This model has no pressure drop.
See <a href=\"modelica://IBPSA.Fluid.HeatExchangers.HeaterCooler_T\">
IBPSA.Fluid.HeatExchangers.HeaterCooler_T</a>
for a model that instantiates this model and that has a pressure drop.
</p>
</html>", revisions="<html>
<ul>
<li>
January 26, 2016, by Michael Wetter:<br/>
Removed inequality comparison of real numbers in <code>restrictCool</code>
and in <code>restrictHeat</code> as this is not allowed in Modelica.
</li>
<li>
November 10, 2014, by Michael Wetter:<br/>
First implementation.
</li>
</ul>
</html>"));
end PrescribedOutletState;
