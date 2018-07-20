within IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.Examples;
model BoreholeOneUTube "Test for the single U-tube borehole model"
  extends
    IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.Examples.BaseClasses.PartialBorehole(
      redeclare
      IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BoreholeOneUTube
      borHol(energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial));
  extends Modelica.Icons.Example;

  annotation (
    __Dymola_Commands( file=
          "Resources/Scripts/Dymola/Fluid/HeatExchangers/GroundHeatExchangers/Boreholes/Examples/BoreholeOneUTube.mos"
        "Simulate and plot"),
    Diagram(coordinateSystem(preserveAspectRatio=false,extent={{-100,-100},{100,
            100}})),
    Documentation(info="<html>
<p>
This example illustrates the use of the 
<a href=\"modelica://IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BoreholeOneUTube\">
IBPSA.Fluid.HeatExchangers.GroundHeatExchangers.Boreholes.BoreholeOneUTubes</a>
model. It simulates the behavior of a borehole with a prescribed
borehole wall boundary condition.
</p>
</html>", revisions="<html>
<ul>
<li>
July 10, 2018, by Alex Laferri&egrave;re:<br/>
Adjusted the example following major changes to the GroundHeatExchangers package.
Additionally, implemented a partial example model.
</li>
<li>
August 30, 2011, by Pierre Vigouroux:<br/>
First implementation.
</li>
</ul>
</html>"),
    experiment(Tolerance=1e-6, StopTime=360000));
end BoreholeOneUTube;
