within IBPSA.Utilities.IO.RESTClient;
block OverWritten_Real
  "Block that receives model input from an external server"
  extends IBPSA.Utilities.IO.RESTClient.BaseClasses.PartialSocketClient;

  parameter Real threshold(start=0)
    "The threshold to determine if the inputs from external server is valid";
  Modelica.Blocks.Interfaces.RealOutput y[numVar]
    "Connector of Real output signal"    annotation (Placement(transformation(extent={{100,-14},{128,14}})));
  Modelica.Blocks.Logical.Switch switch[numVar]
    annotation (Placement(transformation(extent={{-12,-10},{8,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression[numVar](y=oveSig)
    annotation (Placement(transformation(extent={{-94,10},{-74,30}})));
  Modelica.Blocks.Math.RealToBoolean realToBoolean[numVar](each threshold=threshold)
    annotation (Placement(transformation(extent={{-50,-8},{-34,8}})));
equation
  connect(realExpression.y, realToBoolean.u)
    annotation (Line(points={{-73,20},{-74,20},{-62,20},{-62,0},{-51.6,0}}, color={0,0,127}));
  connect(switch.u1, realExpression.y)
    annotation (Line(points={{-14,8},{-26,8},{-26,20},{-62,20},{-73,20}}, color={0,0,127}));
  connect(realToBoolean.y,switch. u2)
    annotation (Line(points={{-33.2,0},{-33.2,0},{-14,0}}, color={255,0,255}));
  connect(switch.y, y)
    annotation (Line(points={{9,0},{114,0},{114,1.77636e-015}},
                                                     color={0,0,127}));
  connect(u, switch.u3) annotation (Line(points={{-120,0},{-80,0},{-80,-20},{
          -20,-20},{-20,-8},{-14,-8}}, color={0,0,127}));
  annotation (Icon(graphics={
        Rectangle(
          extent={{-88,54},{92,-6}},
          lineColor={28,108,200},
          lineThickness=0.5),
        Line(points={{-80,22},{-76,32},{-70,42},{-62,48},{-50,48},{-42,42},{-36,34},{-32,22},{-28,
              12},{-22,6},{-14,-2},{-4,-4},{4,-2},{10,6},{14,16},{16,22},{18,30},{20,40},{24,46},
              {30,50},{42,48},{48,42},{52,34},{56,24},{58,16},{62,8},{64,4},{72,-2},{78,-4},{84,
              -2},{90,2},{92,6}}, color={28,108,200}),
        Text(
          extent={{-62,-22},{70,-60}},
          lineColor={28,108,200},
          textString="Overwritten"),
        Line(
          points={{-22,6},{-22,30},{92,30}},
          color={255,0,0},
          thickness=0.5)}), Documentation(info="<html>
<p>Block that receives input signals from a remoted server. Please noted that users can set a threshold such that the remoted server can actively disable the overwritten. </p>
</html>"));
end OverWritten_Real;