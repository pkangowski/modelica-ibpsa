within Annex60.BoundaryConditions.WeatherData.Examples;
model HDirNor
  "Test model for calculating the direct normal radiation"
  extends Modelica.Icons.Example;
  Annex60.BoundaryConditions.WeatherData.ReaderTMY3 weaDatInpCon(filNam=
        "modelica://Annex60/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos",
      HSou=Annex60.BoundaryConditions.Types.RadiationDataSource.Input_HGloHor_HDifHor)
    "Weather data reader with radiation data obtained from input connector"
    annotation (Placement(transformation(extent={{68,-10},{88,10}})));
protected
    Modelica.Blocks.Sources.Sine HGloHor1(
    freqHz=1/86400,
    startTime=25200,
    offset=0,
    amplitude=100) "Horizontal global radiation"
    annotation (Placement(transformation(extent={{-88,-30},{-68,-10}})));

    Modelica.Blocks.Sources.Sine HGloHor(
    freqHz=1/86400,
    startTime=68428,
    offset=0,
    amplitude=100) "Horizontal global radiation"
    annotation (Placement(transformation(extent={{-88,10},{-68,30}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-32,-10},{-12,10}})));
  Modelica.Blocks.Math.Gain gaiHDifHor(k=0.5)
    "Gain for diffuse solar radiation"
    annotation (Placement(transformation(extent={{0,-34},{20,-14}})));
equation
  connect(HGloHor.y, add.u1) annotation (Line(points={{-67,20},{-52,20},{-52,6},
          {-34,6}}, color={0,0,127}));
  connect(HGloHor1.y, add.u2) annotation (Line(points={{-67,-20},{-50.5,-20},{-50.5,
          -6},{-34,-6}}, color={0,0,127}));
  connect(add.y, weaDatInpCon.HGloHor_in) annotation (Line(points={{-11,0},{28,0},
          {28,-13},{67,-13}}, color={0,0,127}));
  connect(add.y, gaiHDifHor.u) annotation (Line(points={{-11,0},{-6,0},{-6,-2},{
          -6,-24},{-2,-24}}, color={0,0,127}));
  connect(gaiHDifHor.y, weaDatInpCon.HDifHor_in) annotation (Line(points={{21,-24},
          {21,-24},{42,-24},{42,-7.6},{67,-7.6}}, color={0,0,127}));
  annotation (experiment(StartTime=0,StopTime=86400, Tolerance=1e-6),
__Dymola_Commands(file="modelica://Annex60/Resources/Scripts/Dymola/BoundaryConditions/WeatherData/Examples/HDirNor.mos"
        "Simulate and plot"),
    Documentation(info="<html>
<p>
This model tests the calculation of the direct normal radiation.
The instance <code>weaDatInpCon</code> obtains the global horizontal and
the diffuse horizontal solar radiation from its inputs' connectors.
</p>
</html>",
revisions="<html>
<ul>
<li>
December 06, 2016, by Thierry S. Nouidui:<br/>
First implementation.
</li>
</ul>
</html>"));
end HDirNor;
