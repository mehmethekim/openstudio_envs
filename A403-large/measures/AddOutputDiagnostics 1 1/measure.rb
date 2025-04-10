# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# see the URL below for information on how to write OpenStudio measures
# http://openstudio.nrel.gov/openstudio-measure-writing-guide

# see your EnergyPlus installation or the URL below for information on EnergyPlus objects
# http://apps1.eere.energy.gov/buildings/energyplus/pdfs/inputoutputreference.pdf

# see the URL below for information on using life cycle cost objects in OpenStudio
# http://openstudio.nrel.gov/openstudio-life-cycle-examples

# see the URL below for access to C++ documentation on workspace objects (click on "workspace" in the main window to view workspace objects)
# http://openstudio.nrel.gov/sites/openstudio.nrel.gov/files/nv_data/cpp_documentation_it/utilities/html/idf_page.html

# start the measure
class AddOutputDiagnostics < OpenStudio::Measure::EnergyPlusMeasure
  # define the name that a user will see, this method may be deprecated as
  # the display name in PAT comes from the name field in measure.xml
  def name
    return 'Add Output Diagnostics'
  end

  # human readable description
  def description
    return 'Often the eplusout.err file may request output diagnostics. This measure can be used to add this to the IDF file. Re-run your project to see the requested output.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Makes Output:Diagnostics object with choice list for optional values:, DisplayAllWarnings, DisplayExtraWarnings, DisplayUnusedSchedules, DisplayUnusedObjects, DisplayAdvancedReportVariables, DisplayZoneAirHeatBalanceOffBalance, DoNotMirrorDetachedShading, DisplayWeatherMissingDataWarnings, ReportDuringWarmup, ReportDetailedWarmupConvergence.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # make choice argument for output diagnostic value
    choices = OpenStudio::StringVector.new
    choices << 'DisplayAllWarnings'
    choices << 'DisplayExtraWarnings'
    choices << 'DisplayUnusedSchedules'
    choices << 'DisplayUnusedObjects'
    choices << 'DisplayAdvancedReportVariables'
    choices << 'DisplayZoneAirHeatBalanceOffBalance'
    choices << 'DoNotMirrorDetachedShading'
    choices << 'DisplayWeatherMissingDataWarnings'
    choices << 'ReportDuringWarmup'
    choices << 'ReportDetailedWarmupConvergence'
    outputDiagnostic = OpenStudio::Measure::OSArgument.makeChoiceArgument('outputDiagnostic', choices, true)
    outputDiagnostic.setDisplayName('Output Diagnostic Value')
    outputDiagnostic.setDefaultValue('DisplayExtraWarnings')
    args << outputDiagnostic

    return args
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # assign the user inputs to variables
    outputDiagnostic = runner.getStringArgumentValue('outputDiagnostic', user_arguments)

    # reporting initial condition of model
    starting_objects = workspace.getObjectsByType('Output:Diagnostics'.to_IddObjectType)
    runner.registerInitialCondition("The model started with #{starting_objects.size} Output:Diagnostic objects.")

    # loop through existing objects to see if value of any already matches the requested value.
    object_exists = false
    starting_objects.each do |object|
      if object.getString(0).to_s == outputDiagnostic
        object_exists = true
      end
    end

    # adding a new Output:Diagnostic object of requested value if it doesn't already exist
    if object_exists == false

      # make new string
      new_diagnostic_string = "
      Output:Diagnostics,
        #{outputDiagnostic};    !- Key 1
        "

      # make new object from string
      idfObject = OpenStudio::IdfObject.load(new_diagnostic_string)
      object = idfObject.get
      wsObject = workspace.addObject(object)
      new_diagnostic = wsObject.get

      runner.registerInfo("An output diagnostic object with a value of #{new_diagnostic.getString(0)} has been added to your model.")

    else
      runner.registerAsNotApplicable("An output diagnostic object with a value of #{outputDiagnostic} already existed in your model. Nothing was changed.")
      return true

    end

    # reporting final condition of model
    finishing_objects = workspace.getObjectsByType('Output:Diagnostics'.to_IddObjectType)
    runner.registerFinalCondition("The model finished with #{finishing_objects.size} Output:Diagnostic objects.")

    return true
  end
end

# this allows the measure to be use by the application
AddOutputDiagnostics.new.registerWithApplication
