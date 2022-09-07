/**
  Copyright (C) 2012-2022 by Autodesk, Inc.
  All rights reserved.

  Tormach PathPilot post processor configuration.

  $Revision: 43323 4cf8c960b5665daa19c8c09856f1bfac5c844935 $
  $Date: 2022-08-10 23:04:05 $

  FORKID {3CFDE807-BE2F-4A4C-B12A-03080F4B1285}

  SRG edits:
  09/07/22  - Shortened description to just Tormach and added CAPABILITY_TURNING to capabilities variable


*/

description = "Tormach";
vendor = "Tormach";
vendorUrl = "http://www.tormach.com";
legal = "Copyright (C) 2012-2022 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45793;

longDescription = "Tormach PathPilot post for 3-axis and 4-axis milling with SmartCool support.";

extension = "nc";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_MACHINE_SIMULATION | CAPABILITY_TURNING;  //SRG - added CAPABILITY_TURNING;  

tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion

// user-defined properties
properties = {
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  writeVersion: {
    title      : "Write version",
    description: "Write the version number in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  safePositionMethod: {
    title      : "Safe Retracts",
    description: "Select your desired retract option. 'Clearance Height' retracts to the operation clearance height.",
    group      : "homePositions",
    type       : "enum",
    values     : [
      {title:"G28", id:"G28"},
      // {title: "G53", id: "G53"},
      {title:"Clearance Height", id:"clearanceHeight"},
      {title:"G30", id:"G30"},
      {title:"G28 & G30", id:"G28G30"}
    ],
    value: "G30",
    scope: "post"
  },
  useM06: {
    title      : "Use M6",
    description: "Disable to avoid outputting M6.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Use sequence numbers",
    description: "'Yes' outputs sequence numbers on each block, 'Only on tool change' outputs sequence numbers on tool change blocks only, and 'No' disables the output of sequence numbers.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"Yes", id:"true"},
      {title:"No", id:"false"},
      {title:"Only on tool change", id:"toolChange"}
    ],
    value: "false",
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group      : "formats",
    type       : "integer",
    value      : 10,
    scope      : "post"
  },
  sequenceNumberOperation: {
    title      : "Sequence number at operation only",
    description: "Use sequence numbers at start of operation only.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  optionalStop: {
    title      : "Optional stop between tools",
    description: "Outputs optional stop code prior to a tool change.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  optionalStopOperation: {
    title      : "Optional stop between operations",
    description: "Outputs optional stop code prior between all operations.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useRadius: {
    title      : "Radius arcs",
    description: "If yes is selected, arcs are outputted using radius values rather than IJK.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  dwellInSeconds: {
    title      : "Dwell in seconds",
    description: "Specifies the unit for dwelling, set to 'Yes' for seconds and 'No' for milliseconds.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  forceWorkOffset: {
    title      : "Force work offset",
    description: "Forces the work offset code at tool changes.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  rotaryTableAxis: {
    title      : "Rotary table axis",
    description: "Select rotary table axis. Check the table direction on the machine and use the (Reversed) selection if the table is moving in the opposite direction.",
    group      : "configuration",
    type       : "enum",
    values     : [
      {title:"No rotary", id:"none"},
      {title:"X", id:"x"},
      {title:"Y", id:"y"},
      {title:"Z", id:"z"},
      {title:"X (Reversed)", id:"-x"},
      {title:"Y (Reversed)", id:"-y"},
      {title:"Z (Reversed)", id:"-z"}
    ],
    value: "none",
    scope: "post"
  },
  smartCoolEquipped: {
    title      : "SmartCool equipped",
    description: "Specifies if the machine has the SmartCool attachment.",
    group      : "configuration",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  multiCoolEquipped: {
    title      : "Multi-Coolant equipped",
    description: "Specifies if the machine has the Multi-Coolant module.",
    group      : "configuration",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  smartCoolToolSweepPercentage: {
    title      : "SmartCool sweep percentage",
    description: "Sets the tool length percentage to sweep coolant.",
    group      : "preferences",
    type       : "integer",
    value      : 100,
    scope      : "post"
  },
  multiCoolAirBlastSeconds: {
    title      : "Multi-Coolant air blast in seconds",
    description: "Sets the Multi-Coolant air blast time in seconds.",
    group      : "preferences",
    type       : "integer",
    value      : 4,
    scope      : "post"
  },
  outputCoolants: {
    title      : "Output coolant commands",
    description: "Specfies if coolant commands should be used or disabled.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  reversingHead: {
    title      : "Use self-reversing tapping head",
    description: "Expanded cycles are output with a self-reversing tapping head.",
    group      : "preferences",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  reversingHeadFeed: {
    title      : "Self-reversing head feed ratio",
    description: "The percentage of the tapping feedrate for retracting the tool.",
    group      : "preferences",
    type       : "number",
    value      : 2,
    scope      : "post"
  },
  maxTool: {
    title      : "Maximum tool number",
    description: "Enter the maximum tool number allowed by the control.",
    group      : "configuration",
    type       : "number",
    value      : 256,
    scope      : "post"
  }
};

// wcs definiton
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"G", range:[54, 59]},
    {name:"Extended", format:"G59.", range:[1, 3]},
    {name:"Extra", format:"G54.1 P", range:[10, 500]}
  ]
};

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,=_-*";

var nFormat = createFormat({prefix:"N", decimals:0});
var gFormat = createFormat({prefix:"G", decimals:1});
var mFormat = createFormat({prefix:"M", decimals:0});
var hFormat = createFormat({prefix:"H", decimals:0});
var dFormat = createFormat({prefix:"D", decimals:0});
var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var rFormat = xyzFormat; // radius
var abcFormat = createFormat({decimals:3, forceDecimal:true, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 0 : 1), forceDecimal:true});
var inverseTimeFormat = createFormat({decimals:4, forceDecimal:true});
var toolFormat = createFormat({decimals:0});
var rpmFormat = createFormat({decimals:0});
var coolantOptionFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:3, forceDecimal:true}); // seconds - range 0.001-99999.999
var milliFormat = createFormat({decimals:0}); // milliseconds // range 1-9999
var taperFormat = createFormat({decimals:1, scale:DEG});
var qFormat = createFormat({prefix:"Q", decimals:0});

var xOutput = createVariable({prefix:"X"}, xyzFormat);
var yOutput = createVariable({prefix:"Y"}, xyzFormat);
var zOutput = createVariable({onchange:function () {retracted = false;}, prefix:"Z"}, xyzFormat);
var aOutput = createVariable({prefix:"A"}, abcFormat);
var bOutput = createVariable({prefix:"B"}, abcFormat);
var cOutput = createVariable({prefix:"C"}, abcFormat);
var feedOutput = createVariable({prefix:"F"}, feedFormat);
var inverseTimeOutput = createVariable({prefix:"F", force:true}, inverseTimeFormat);
var sOutput = createVariable({prefix:"S", force:true}, rpmFormat);
var dOutput = createVariable({}, dFormat);

// circular output
var iOutput = createReferenceVariable({prefix:"I", force:true}, xyzFormat);
var jOutput = createReferenceVariable({prefix:"J", force:true}, xyzFormat);
var kOutput = createReferenceVariable({prefix:"K", force:true}, xyzFormat);

var gMotionModal = createModal({force:true}, gFormat); // modal group 1 // G0-G3, ...
var gPlaneModal = createModal({onchange:function () {gMotionModal.reset();}}, gFormat); // modal group 2 // G17-19
var gAbsIncModal = createModal({}, gFormat); // modal group 3 // G90-91
var gFeedModeModal = createModal({}, gFormat); // modal group 5 // G93-94
var gUnitModal = createModal({}, gFormat); // modal group 6 // G20-21
var gCycleModal = createModal({force:false}, gFormat); // modal group 9 // G81, ...
var gRetractModal = createModal({force:true}, gFormat); // modal group 10 // G98-99

var WARNING_WORK_OFFSET = 0;

// collected state
var sequenceNumber;
var currentWorkOffset;
var currentCoolantMode = COOLANT_OFF;
var coolantZHeight;
var masterAxis;
var movementType;
var retracted = false; // specifies that the tool has been retracted to the safe plane

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = getProperty("sequenceNumberStart");
  }
  var seqno = nFormat.format(sequenceNumber);
  sequenceNumber += getProperty("sequenceNumberIncrement");
  return seqno;
}

/**
  Writes the specified block.
*/
function writeBlock() {
  if (!formatWords(arguments)) {
    return;
  }
  if (getProperty("showSequenceNumbers") == "true") {
    writeWords2(formatSequenceNumber(), arguments);
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

function formatComment(text) {
  return ("(" + filterText(String(text), permittedCommentChars) + ")");
}

/**
  Writes the specified block - used for tool changes only.
*/
function writeToolBlock() {
  var show = getProperty("showSequenceNumbers");
  setProperty("showSequenceNumbers", (show == "true" || show == "toolChange") ? "true" : "false");
  writeBlock(arguments);
  setProperty("showSequenceNumbers", show);
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln(formatComment(text));
}

function writeCommentSeqno(text) {
  writeln(formatSequenceNumber() + formatComment(text));
}

/**
  Compare a text string to acceptable choices.

  Returns -1 if there is no match.
*/
function parseChoice() {
  for (var i = 1; i < arguments.length; ++i) {
    if (String(arguments[0]).toUpperCase() == String(arguments[i]).toUpperCase()) {
      return i - 1;
    }
  }
  return -1;
}

// Start of machine configuration logic
var compensateToolLength = false; // add the tool length to the pivot distance for nonTCP rotary heads

// internal variables, do not change
var receivedMachineConfiguration;
var operationSupportsTCP;
var multiAxisFeedrate;

function activateMachine() {
  // disable unsupported rotary axes output
  if (!machineConfiguration.isMachineCoordinate(0) && (typeof aOutput != "undefined")) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1) && (typeof bOutput != "undefined")) {
    bOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(2) && (typeof cOutput != "undefined")) {
    cOutput.disable();
  }

  // setup usage of multiAxisFeatures
  useMultiAxisFeatures = getProperty("useMultiAxisFeatures") != undefined ? getProperty("useMultiAxisFeatures") :
    (typeof useMultiAxisFeatures != "undefined" ? useMultiAxisFeatures : false);
  useABCPrepositioning = getProperty("useABCPrepositioning") != undefined ? getProperty("useABCPrepositioning") :
    (typeof useABCPrepositioning != "undefined" ? useABCPrepositioning : false);

  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // don't need to modify any settings for 3-axis machines
  }

  // save multi-axis feedrate settings from machine configuration
  var mode = machineConfiguration.getMultiAxisFeedrateMode();
  var type = mode == FEED_INVERSE_TIME ? machineConfiguration.getMultiAxisFeedrateInverseTimeUnits() :
    (mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateDPMType() : DPM_STANDARD);
  multiAxisFeedrate = {
    mode     : mode,
    maximum  : machineConfiguration.getMultiAxisFeedrateMaximum(),
    type     : type,
    tolerance: mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateOutputTolerance() : 0,
    bpwRatio : mode == FEED_DPM ? machineConfiguration.getMultiAxisFeedrateBpwRatio() : 1
  };

  // setup of retract/reconfigure  TAG: Only needed until post kernel supports these machine config settings
  if (receivedMachineConfiguration && machineConfiguration.performRewinds()) {
    safeRetractDistance = machineConfiguration.getSafeRetractDistance();
    safePlungeFeed = machineConfiguration.getSafePlungeFeedrate();
    safeRetractFeed = machineConfiguration.getSafeRetractFeedrate();
  }
  if (typeof safeRetractDistance == "number" && getProperty("safeRetractDistance") != undefined && getProperty("safeRetractDistance") != 0) {
    safeRetractDistance = getProperty("safeRetractDistance");
  }

  if (machineConfiguration.isHeadConfiguration()) {
    compensateToolLength = typeof compensateToolLength == "undefined" ? false : compensateToolLength;
  }

  if (machineConfiguration.isHeadConfiguration() && compensateToolLength) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var section = getSection(i);
      if (section.isMultiAxis()) {
        machineConfiguration.setToolLength(getBodyLength(section.getTool())); // define the tool length for head adjustments
        section.optimizeMachineAnglesByMachine(machineConfiguration, OPTIMIZE_AXIS);
      }
    }
  } else {
    optimizeMachineAngles2(OPTIMIZE_AXIS);
  }
}

function getBodyLength(tool) {
  for (var i = 0; i < getNumberOfSections(); ++i) {
    var section = getSection(i);
    if (tool.number == section.getTool().number) {
      return section.getParameter("operation:tool_overallLength", tool.bodyLength + tool.holderLength);
    }
  }
  return tool.bodyLength + tool.holderLength;
}

function defineMachine() {
  var useTCP = false;
  if (getProperty("rotaryTableAxis") != "none") {
    // Define rotary attributes from properties
    var rotary = parseChoice(getProperty("rotaryTableAxis"), "-Z", "-Y", "-X", "NONE", "X", "Y", "Z");
    if (rotary < 0) {
      error(localize("Valid rotaryTableAxis values are: None, X, Y, Z, -X, -Y, -Z"));
      return;
    }
    rotary -= 3;

    // Define Master (carrier) axis
    masterAxis = Math.abs(rotary) - 1;
    if (masterAxis >= 0) {
      var rotaryVector = [0, 0, 0];
      rotaryVector[masterAxis] = rotary / Math.abs(rotary);
      var aAxis = createAxis({coordinate:0, table:true, axis:rotaryVector, cyclic:true, preference:0, tcp:useTCP, reset:3});
      machineConfiguration = new MachineConfiguration(aAxis);

      setMachineConfiguration(machineConfiguration);
      if (receivedMachineConfiguration) {
        warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
        receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
      }
    }
  } else {
    if (false) { // note: setup your machine here
      var aAxis = createAxis({coordinate:0, table:true, axis:[1, 0, 0], range:[-120, 120], preference:1, tcp:useTCP});
      var cAxis = createAxis({coordinate:2, table:true, axis:[0, 0, 1], range:[-360, 360], preference:0, tcp:useTCP});
      machineConfiguration = new MachineConfiguration(aAxis, cAxis);

      setMachineConfiguration(machineConfiguration);
      if (receivedMachineConfiguration) {
        warning(localize("The provided CAM machine configuration is overwritten by the postprocessor."));
        receivedMachineConfiguration = false; // CAM provided machine configuration is overwritten
      }
    }
  }

  if (!receivedMachineConfiguration) {
    // multiaxis settings
    if (machineConfiguration.isHeadConfiguration()) {
      machineConfiguration.setVirtualTooltip(false); // translate the pivot point to the virtual tool tip for nonTCP rotary heads
    }

    // retract / reconfigure
    var performRewinds = false; // set to true to enable the rewind/reconfigure logic
    if (performRewinds) {
      machineConfiguration.enableMachineRewinds(); // enables the retract/reconfigure logic
      safeRetractDistance = (unit == IN) ? 1 : 25; // additional distance to retract out of stock, can be overridden with a property
      safeRetractFeed = (unit == IN) ? 20 : 500; // retract feed rate
      safePlungeFeed = (unit == IN) ? 10 : 250; // plunge feed rate
      machineConfiguration.setSafeRetractDistance(safeRetractDistance);
      machineConfiguration.setSafeRetractFeedrate(safeRetractFeed);
      machineConfiguration.setSafePlungeFeedrate(safePlungeFeed);
      var stockExpansion = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN)); // expand stock XYZ values
      machineConfiguration.setRewindStockExpansion(stockExpansion);
    }

    // multi-axis feedrates
    if (machineConfiguration.isMultiAxisConfiguration()) {
      machineConfiguration.setMultiAxisFeedrate(
        useTCP ? FEED_FPM : getProperty("useDPMFeeds") ? FEED_DPM : FEED_INVERSE_TIME,
        99999.9999, // maximum output value for inverse time feed rates
        getProperty("useDPMFeeds") ? DPM_COMBINATION : INVERSE_MINUTES, // INVERSE_MINUTES/INVERSE_SECONDS or DPM_COMBINATION/DPM_STANDARD
        0.5, // tolerance to determine when the DPM feed has changed
        1.0 // ratio of rotary accuracy to linear accuracy for DPM calculations
      );
      setMachineConfiguration(machineConfiguration);
    }

    /* home positions */
    // machineConfiguration.setHomePositionX(toPreciseUnit(0, IN));
    // machineConfiguration.setHomePositionY(toPreciseUnit(0, IN));
    // machineConfiguration.setRetractPlane(toPreciseUnit(0, IN));
  }
}
// End of machine configuration logic

function onOpen() {
  // define and enable machine configuration
  receivedMachineConfiguration = machineConfiguration.isReceived();

  if (typeof defineMachine == "function") {
    defineMachine(); // hardcoded machine configuration
  }
  activateMachine(); // enable the machine optimizations and settings

  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90); // avoid potential center calculation errors for CNC
  }
  if (getProperty("sequenceNumberOperation")) {
    setProperty("showSequenceNumbers", "false");
  }

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  sequenceNumber = getProperty("sequenceNumberStart");

  writeln("%");
  if (programName) {
    writeComment(programName);
  }
  if (programComment) {
    writeComment(programComment);
  }

  if (getProperty("writeVersion")) {
    if (typeof getHeaderVersion == "function" && getHeaderVersion()) {
      writeComment(localize("post version") + ": " + getHeaderVersion());
    }
    if (typeof getHeaderDate == "function" && getHeaderDate()) {
      writeComment(localize("post modified") + ": " + getHeaderDate());
    }
  }

  // dump machine configuration
  var vendor = machineConfiguration.getVendor();
  var model = machineConfiguration.getModel();
  var description = machineConfiguration.getDescription();

  if (getProperty("writeMachine") && (vendor || model || description)) {
    writeComment(localize("Machine"));
    if (vendor) {
      writeComment("  " + localize("vendor") + ": " + vendor);
    }
    if (model) {
      writeComment("  " + localize("model") + ": " + model);
    }
    if (description) {
      writeComment("  " + localize("description") + ": "  + description);
    }
  }

  // dump tool information
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var comment = "T" + toolFormat.format(tool.number) + "  " +
          "D=" + xyzFormat.format(tool.diameter) + " " +
          localize("CR") + "=" + xyzFormat.format(tool.cornerRadius);
        if ((tool.taperAngle > 0) && (tool.taperAngle < Math.PI)) {
          comment += " " + localize("TAPER") + "=" + taperFormat.format(tool.taperAngle) + localize("deg");
        }
        if (zRanges[tool.number]) {
          comment += " - " + localize("ZMIN") + "=" + xyzFormat.format(zRanges[tool.number].getMinimum());
        }
        comment += " - " + getToolTypeName(tool.type);
        writeComment(comment);
      }
    }
  }

  if (false) {
    // check for duplicate tool number
    for (var i = 0; i < getNumberOfSections(); ++i) {
      var sectioni = getSection(i);
      var tooli = sectioni.getTool();
      for (var j = i + 1; j < getNumberOfSections(); ++j) {
        var sectionj = getSection(j);
        var toolj = sectionj.getTool();
        if (tooli.number == toolj.number) {
          if (xyzFormat.areDifferent(tooli.diameter, toolj.diameter) ||
              xyzFormat.areDifferent(tooli.cornerRadius, toolj.cornerRadius) ||
              abcFormat.areDifferent(tooli.taperAngle, toolj.taperAngle) ||
              (tooli.numberOfFlutes != toolj.numberOfFlutes)) {
            error(
              subst(
                localize("Using the same tool number for different cutter geometry for operation '%1' and '%2'."),
                sectioni.hasParameter("operation-comment") ? sectioni.getParameter("operation-comment") : ("#" + (i + 1)),
                sectionj.hasParameter("operation-comment") ? sectionj.getParameter("operation-comment") : ("#" + (j + 1))
              )
            );
            return;
          }
        }
      }
    }
  }

  if ((getNumberOfSections() > 0) && (getSection(0).workOffset == 0)) {
    for (var i = 0; i < getNumberOfSections(); ++i) {
      if (getSection(i).workOffset > 0) {
        error(localize("Using multiple work offsets is not possible if the initial work offset is 0."));
        return;
      }
    }
  }

  // absolute coordinates and feed per min
  writeBlock(gAbsIncModal.format(90), gFormat.format(54), gFormat.format(64), gFormat.format(50), gPlaneModal.format(17), gFormat.format(40), gFormat.format(80), gFeedModeModal.format(94), gFormat.format(91.1), gFormat.format(49));

  switch (unit) {
  case IN:
    writeBlock(gUnitModal.format(20), formatComment(localize("Inch")));
    break;
  case MM:
    writeBlock(gUnitModal.format(21), formatComment(localize("Metric")));
    break;
  }
}

function onParameter(name, value) {
  if (name == "display") {
    writeComment("MSG, " + value);
  }
}

function onComment(message) {
  var comments = String(message).split(";");
  for (comment in comments) {
    writeComment(comments[comment]);
  }
}

/** Force output of X, Y, and Z. */
function forceXYZ() {
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
}

/** Force output of A, B, and C. */
function forceABC() {
  aOutput.reset();
  bOutput.reset();
  cOutput.reset();
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  previousDPMFeed = 0;
  feedOutput.reset();
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function positionABC(abc, force) {
  if (typeof unwindABC == "function") {
    unwindABC(abc, false);
  }
  if (force) {
    forceABC();
  }
  var a = aOutput.format(abc.x);
  var b = bOutput.format(abc.y);
  var c = cOutput.format(abc.z);
  if (a || b || c) {
    if (!retracted) {
      if (typeof moveToSafeRetractPosition == "function") {
        moveToSafeRetractPosition();
      } else {
        writeRetract(Z);
      }
    }
    onCommand(COMMAND_UNLOCK_MULTI_AXIS);
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), a, b, c);
    currentMachineABC = new Vector(abc);
    setCurrentABC(abc); // required for machine simulation
  }
}

function setWorkPlane(abc) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return; // no change
  }
  positionABC(abc, true);
  onCommand(COMMAND_LOCK_MULTI_AXIS);
  currentWorkPlaneABC = abc;
}

var closestABC = true; // choose closest machine angles
var currentMachineABC = new Vector(0, 0, 0);

// resets the rotary axes to 0 if reset is specified when creating the axis
function resetABC(previousABC) {
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  var abc = new Vector(previousABC);
  for (var i in axis) {
    if (axis[i].isEnabled() && (axis[i].getReset() & 1)) {
      var coordinate = axis[i].getCoordinate();
      if (abcFormat.getResultingValue(Math.abs(abc.getCoordinate(coordinate))) > 360) {
        abc.setCoordinate(coordinate, 0);
      }
    }
  }
  return abc;
}

function getPreferenceWeight(_abc) {
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  var abc = new Array(_abc.x, _abc.y, _abc.z);
  var preference = 0;
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      preference += ((abcFormat.getResultingValue(abc[axis[i].getCoordinate()]) * axis[i].getPreference()) < 0) ? -1 : 1;
    }
  }
  return preference;
}

function remapToABC(currentABC, previousABC, useReset) {
  if (useReset) {
    previousABC = resetABC(previousABC); // support 'reset' flag in axes definitions
  }

  var both = machineConfiguration.getABCByDirectionBoth(machineConfiguration.getDirection(currentABC));
  var abc1 = machineConfiguration.remapToABC(both[0], previousABC);
  abc1 = machineConfiguration.remapABC(abc1);
  var abc2 = machineConfiguration.remapToABC(both[1], previousABC);
  abc2 = machineConfiguration.remapABC(abc2);

  // choose angles based on preference
  var preference1 = getPreferenceWeight(abc1);
  var preference2 = getPreferenceWeight(abc2);
  if (preference1 > preference2) {
    return abc1;
  } else if (preference2 > preference1) {
    return abc2;
  }

  // choose angles based on closest solution
  if (Vector.diff(abc1, previousABC).length < Vector.diff(abc2, previousABC).length) {
    return abc1;
  } else {
    return abc2;
  }
}

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = remapToABC(abc, currentMachineABC, true);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }

  try {
    abc = machineConfiguration.remapABC(abc);
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var direction = machineConfiguration.getDirection(abc);
  if (!isSameDirection(direction, W.forward)) {
    error(localize("Orientation not supported."));
  }

  if (!machineConfiguration.isABCSupported(abc)) {
    error(
      localize("Work plane is not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = false;
  cancelTransformation();
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    var rotate = true;
    var axis = machineConfiguration.getAxisU();
    if (axis.isEnabled() && axis.isTable()) {
      var ix = axis.getCoordinate();
      var rotAxis = axis.getAxis();
      if (isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ||
          isSameDirection(machineConfiguration.getDirection(abc), Vector.product(rotAxis, -1))) {
        var direction = isSameDirection(machineConfiguration.getDirection(abc), rotAxis) ? 1 : -1;
        abc.setCoordinate(ix, Math.atan2(R.right.y, R.right.x) * direction);
        rotate = false;
      }
    }
    if (rotate) {
      setRotation(R);
    }
  }
  return abc;
}

function unwindABC(abc, force) {
  var method = "G92"; // supported methods are "G28" and "G92"
  if (method != "G92" && method != "G28") {
    error(localize("Unsupported unwindABC method."));
    return;
  }
  var axes = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i in axes) {
    if (axes[i].isEnabled()) {
      if (axes[i].getReset() > 0 || force) {
        var j = axes[i].getCoordinate();
        var nearestABC = remapToABC(currentMachineABC, abc, false);
        var distanceABC = abcFormat.getResultingValue(Math.abs(Vector.diff(currentMachineABC, abc).getCoordinate(j)));
        var distanceOrigin = 0;
        if (method == "G92") {
          distanceOrigin = abcFormat.getResultingValue(Math.abs(Vector.diff(nearestABC, abc).getCoordinate(j)));
        } else { // G28
          distanceOrigin = abcFormat.getResultingValue(Math.abs(currentMachineABC.getCoordinate(j))) % 360; // calculate distance for unwinding axis
          distanceOrigin = (distanceOrigin > 180) ? 360 - distanceOrigin : distanceOrigin; // take shortest route to 0
          distanceOrigin += abcFormat.getResultingValue(Math.abs(abc.getCoordinate(j))); // add distance from 0 to new position
        }
        var revolutions = distanceABC / 360;
        if (distanceABC > distanceOrigin && (revolutions > 1)) {
          var angle = method == "G92" ? nearestABC.getCoordinate(j) : 0;
          var words = method == "G92" ? [gFormat.format(92)] : [gFormat.format(28), gAbsIncModal.format(91)];
          var outputs = [aOutput, bOutput, cOutput];
          outputs[j].reset();
          words.push(outputs[j].format(angle));
          if (!retracted) {
            if (typeof moveToSafeRetractPosition == "function") {
              moveToSafeRetractPosition();
            } else {
              writeRetract(Z);
            }
          }
          onCommand(COMMAND_UNLOCK_MULTI_AXIS);
          writeBlock(words);
          writeBlock((gAbsIncModal.getCurrent() == 91) ? gAbsIncModal.format(90) : "");
          currentMachineABC.setCoordinate(j, angle);
        }
      }
    }
  }
}

function onSection() {
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);

  retracted = false; // specifies that the tool has been retracted to the safe plane
  var newWorkOffset = isFirstSection() ||
    (getPreviousSection().workOffset != currentSection.workOffset); // work offset changes
  var newWorkPlane = isFirstSection() ||
    !isSameDirection(getPreviousSection().getGlobalFinalToolAxis(), currentSection.getGlobalInitialToolAxis()) ||
    (currentSection.isOptimizedForMachine() && getPreviousSection().isOptimizedForMachine() &&
      Vector.diff(getPreviousSection().getFinalToolAxisABC(), currentSection.getInitialToolAxisABC()).length > 1e-4) ||
    (!machineConfiguration.isMultiAxisConfiguration() && currentSection.isMultiAxis()) ||
    (!getPreviousSection().isMultiAxis() && currentSection.isMultiAxis() ||
      getPreviousSection().isMultiAxis() && !currentSection.isMultiAxis()); // force newWorkPlane between indexing and simultaneous operations
  if (insertToolCall || newWorkOffset || newWorkPlane) {
    writeRetract(Z);
    forceWorkPlane();
  }
  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      if (getProperty("sequenceNumberOperation")) {
        writeCommentSeqno(comment);
      } else {
        writeComment(comment);
      }
    }
  }

  // optional stop
  if (!isFirstSection() && ((insertToolCall && getProperty("optionalStop")) || getProperty("optionalStopOperation"))) {
    onCommand(COMMAND_OPTIONAL_STOP);
  }

  if (insertToolCall) {
    forceWorkPlane();
    // onCommand(COMMAND_COOLANT_OFF);

    if (tool.number > getProperty("maxTool")) {
      warning(localize("Tool number exceeds maximum value."));
    }

    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > getProperty("maxTool")) {
      error(localize("Length offset out of range."));
      return;
    }

    if (getProperty("useM06")) {
      writeToolBlock("T" + toolFormat.format(tool.number),
        gFormat.format(43),
        hFormat.format(lengthOffset),
        mFormat.format(6));
    } else {
      writeToolBlock("T" + toolFormat.format(tool.number), gFormat.format(43), hFormat.format(lengthOffset));
    }

    if (tool.comment) {
      writeComment(tool.comment);
    }
    var showToolZMin = false;
    if (showToolZMin) {
      if (is3D()) {
        var numberOfSections = getNumberOfSections();
        var zRange = currentSection.getGlobalZRange();
        var number = tool.number;
        for (var i = currentSection.getId() + 1; i < numberOfSections; ++i) {
          var section = getSection(i);
          if (section.getTool().number != number) {
            break;
          }
          zRange.expandToRange(section.getGlobalZRange());
        }
        writeComment(localize("ZMIN") + "=" + zRange.getMinimum());
      }
    }
  }

  // Define coolant code
  var topOfPart = undefined;
  if (hasParameter("operation:surfaceZHigh")) {
    topOfPart = getParameter("operation:surfaceZHigh"); // TAG: not safe
  }
  var c = setCoolant(tool.coolant, topOfPart);

  if (true ||
      insertToolCall ||
      isFirstSection() ||
      (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise)) {
    if (spindleSpeed < 0) {
      error(localize("Spindle speed out of range."));
      return;
    }
    if (spindleSpeed > 99999) {
      warning(localize("Spindle speed exceeds maximum value."));
    }
    if (spindleSpeed == 0) {
      writeBlock(mFormat.format(5), c[0], c[1], c[2], c[3], formatComment("SPINDLE IS OFF"));
    } else {
      writeBlock(
        sOutput.format(spindleSpeed), mFormat.format(tool.clockwise ? 3 : 4),
        c[0], c[1], c[2], c[3]
      );
      if ((spindleSpeed > 5000) && getProperty("waitForSpindle")) {
        onDwell(getProperty("waitForSpindle"));
      }
    }
  }

  // wcs
  if (insertToolCall && getProperty("forceWorkOffset")) { // force work offset when changing tool
    currentWorkOffset = undefined;
  }

  if (currentSection.workOffset != currentWorkOffset) {
    writeBlock(currentSection.wcs);
    currentWorkOffset = currentSection.workOffset;
  }

  forceXYZ();

  if (machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode
    var abc = currentSection.isMultiAxis() ? currentSection.getInitialToolAxisABC() : getWorkPlaneMachineABC(currentSection.workPlane);
    if (currentSection.isMultiAxis()) {
      forceWorkPlane();
      cancelTransformation();
      positionABC(abc, true);
    } else {
      setWorkPlane(abc);
    }
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  if (currentSection) {
    operationSupportsTCP = (currentSection.isMultiAxis() || !useMultiAxisFeatures) && currentSection.getOptimizedTCPMode() == OPTIMIZE_NONE;
  }

  forceXYZ();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted && !insertToolCall) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    }
  }

  if (!insertToolCall && retracted) { // G43 already called above on tool change
    var lengthOffset = tool.lengthOffset;
    if (lengthOffset > getProperty("maxTool")) {
      error(localize("Length offset out of range."));
      return;
    }

    gMotionModal.reset();
    writeBlock(gPlaneModal.format(17));

    if (!machineConfiguration.isHeadConfiguration()) {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0), xOutput.format(initialPosition.x), yOutput.format(initialPosition.y)
      );
      writeBlock(gMotionModal.format(0), gFormat.format(43), zOutput.format(initialPosition.z), hFormat.format(lengthOffset));
    } else {
      writeBlock(
        gAbsIncModal.format(90),
        gMotionModal.format(0),
        gFormat.format(43), xOutput.format(initialPosition.x),
        yOutput.format(initialPosition.y),
        zOutput.format(initialPosition.z), hFormat.format(lengthOffset)
      );
    }
  } else {
    writeBlock(
      gAbsIncModal.format(90),
      gMotionModal.format(0),
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }
}

// allow manual insertion of comma delimited g-code
function onPassThrough(text) {
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

function onDwell(seconds) {
  if (seconds > 99999.999) {
    warning(localize("Dwelling time is out of range."));
  }
  if (getProperty("dwellInSeconds")) {
    writeBlock(gFormat.format(4), "P" + secFormat.format(seconds));
  } else {
    milliseconds = clamp(1, seconds * 1000, 99999999);
    writeBlock(gFormat.format(4), "P" + milliFormat.format(milliseconds));
  }
}

function onSpindleSpeed(spindleSpeed) {
  writeBlock(sOutput.format(spindleSpeed));
}

function setCoolant(coolant, topOfPart) {
  var coolCodes = ["", "", "", ""];
  coolantZHeight = 9999.0;
  var coolantCode = 9;

  if (!getProperty("outputCoolants")) {
    return coolCodes;
  }
  // Smart coolant is not enabled
  if (!getProperty("smartCoolEquipped")) {
    if (coolant == COOLANT_OFF) {
      coolantCode = 9;
    } else if (coolant == COOLANT_MIST) {
      coolantCode = 7;
    } else {
      coolantCode = 8; // default all coolant modes to flood
      if (coolant != COOLANT_FLOOD) {
        warning(localize("Unsupported coolant setting. Defaulting to FLOOD."));
      }
    }
    coolCodes[0] = mFormat.format(coolantCode);
  } else { // Smart coolant is enabled
    if ((coolant == COOLANT_MIST) || (coolant == COOLANT_AIR)) {
      coolantCode = 7;
      coolCodes[0] = mFormat.format(coolantCode);
    } else if (coolant == COOLANT_FLOOD_MIST) { // flood with air blast
      coolantCode = 8;
      coolCodes[0] = mFormat.format(coolantCode);
      if (getProperty("multiCoolEquipped")) {
        if (getProperty("multiCoolAirBlastSeconds") != 0) {
          coolCodes[3] = qFormat.format(getProperty("multiCoolAirBlastSeconds"));
        }
      } else {
        warning(localize("COOLANT_FLOOD_MIST programmed without Multi-Coolant support. Defaulting to FLOOD."));
      }
    } else if (coolant == COOLANT_OFF) {
      coolantCode = 9;
      coolCodes[0] = mFormat.format(coolantCode);
    } else {
      coolantCode = 8;
      coolCodes[0] = mFormat.format(coolantCode);
      if (coolant != COOLANT_FLOOD) {
        warning(localize("Unsupported coolant setting. Defaulting to FLOOD."));
      }
    }

    // Determine Smart Coolant location based on machining operation
    if (hasParameter("operation-strategy")) {
      var strategy = getParameter("operation-strategy");
      if (strategy) {

        // Drilling strategy. Keep coolant at top of part
        if (strategy == "drill") {
          if (topOfPart != undefined) {
            coolantZHeight = topOfPart;
            coolCodes[1] = "E" + xyzFormat.format(coolantZHeight);
          }

        // Tool end point milling. Keep coolant at end of tool
        } else if ((strategy == "face") ||
                   (strategy == "engrave") ||
                   (strategy == "contour_new") ||
                   (strategy == "horizontal_new") ||
                   (strategy == "parallel_new") ||
                   (strategy == "scallop_new") ||
                   (strategy == "pencil_new") ||
                   (strategy == "radial_new") ||
                   (strategy == "spiral_new") ||
                   (strategy == "morphed_spiral") ||
                   (strategy == "ramp") ||
                   (strategy == "project")) {
          coolCodes[1] = "P" + coolantOptionFormat.format(0);

        // Side Milling. Sweep the coolant along the length of the tool
        } else {
          coolCodes[1] = "P" + coolantOptionFormat.format(0);
          coolCodes[2] = "R" + xyzFormat.format(tool.fluteLength * (getProperty("smartCoolToolSweepPercentage") / 100.0));
        }
      }
    }
  }

  currentCoolantMode = coolant;
  return coolCodes;
}

function onCycle() {
  writeBlock(gPlaneModal.format(17));
}

function getCommonCycle(x, y, z, r) {
  forceXYZ();
  return [xOutput.format(x), yOutput.format(y),
    zOutput.format(z),
    "R" + xyzFormat.format(r)];
}

function expandTappingPoint(x, y, z) {
  onExpandedRapid(x, y, cycle.clearance);
  onExpandedLinear(x, y, z, cycle.feedrate);
  onExpandedLinear(x, y, cycle.clearance, cycle.feedrate * getProperty("reversingHeadFeed"));
}

function onCyclePoint(x, y, z) {
  if (!isSameDirection(getRotation().forward, new Vector(0, 0, 1))) {
    expandCyclePoint(x, y, z);
    return;
  }

  if (isFirstCyclePoint()) {
    repositionToCycleClearance(cycle, x, y, z);

    // return to initial Z which is clearance plane and set absolute mode

    var F = cycle.feedrate;
    var P = !cycle.dwell ? 0 : cycle.dwell; // in seconds

    // Adjust SmartCool to top of part if it changes
    if (getProperty("smartCoolEquipped") && xyzFormat.areDifferent((z + cycle.depth), coolantZHeight)) {
      var c = setCoolant(currentCoolantMode, z + cycle.depth);
      if (c) {
        writeBlock(c[0], c[1], c[2], c[3]);
      }
    }

    switch (cycleType) {
    case "drilling":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
        getCommonCycle(x, y, z, cycle.retract),
        feedOutput.format(F)
      );
      break;
    case "counter-boring":
      if (P > 0) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(82),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(81),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "chip-breaking":
      if ((P > 0) || (cycle.accumulatedDepth < cycle.depth)) {
        expandCyclePoint(x, y, z);
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(73),
          getCommonCycle(x, y, z, cycle.retract),
          "Q" + xyzFormat.format(cycle.incrementalDepth),
          feedOutput.format(F)
        );
      }
      break;
    case "deep-drilling":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(83),
        getCommonCycle(x, y, z, cycle.retract),
        "Q" + xyzFormat.format(cycle.incrementalDepth),
        // conditional(P > 0, "P" + secFormat.format(P)),
        feedOutput.format(F)
      );
      break;
    case "tapping":
      if (getProperty("reversingHead")) {
        expandTappingPoint(x, y, z);
      } else {
        if (!F) {
          F = tool.getTappingFeedrate();
        }
        writeBlock(sOutput.format(spindleSpeed));
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format((tool.type == TOOL_TAP_LEFT_HAND) ? 74 : 84),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // dwell is required
          feedOutput.format(F)
        );
      }
      break;
    case "left-tapping":
      if (getProperty("reversingHead")) {
        expandTappingPoint(x, y, z);
      } else {
        if (!F) {
          F = tool.getTappingFeedrate();
        }
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(74),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // dwell is required
          feedOutput.format(F)
        );
      }
      break;
    case "right-tapping":
      if (getProperty("reversingHead")) {
        expandTappingPoint(x, y, z);
      } else {
        if (!F) {
          F = tool.getTappingFeedrate();
        }
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(84),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P), // dwell is required
          feedOutput.format(F)
        );
      }
      break;
    case "fine-boring":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(76),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P),
        "Q" + xyzFormat.format(cycle.shift),
        feedOutput.format(F)
      );
      break;
    case "back-boring":
      var dx = (gPlaneModal.getCurrent() == 19) ? cycle.backBoreDistance : 0;
      var dy = (gPlaneModal.getCurrent() == 18) ? cycle.backBoreDistance : 0;
      var dz = (gPlaneModal.getCurrent() == 17) ? cycle.backBoreDistance : 0;
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(87),
        getCommonCycle(x - dx, y - dy, z - dz, cycle.bottom),
        "I" + xyzFormat.format(cycle.shift),
        "J" + xyzFormat.format(0),
        "P" + secFormat.format(P),
        feedOutput.format(F)
      );
      break;
    case "reaming":
      if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
        expandCyclePoint(x, y, z);
        break;
      }
      if (P > 0) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    case "stop-boring":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(86),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P),
        feedOutput.format(F)
      );
      break;
    case "manual-boring":
      writeBlock(
        gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(88),
        getCommonCycle(x, y, z, cycle.retract),
        "P" + secFormat.format(P),
        feedOutput.format(F)
      );
      break;
    case "boring":
      if (feedFormat.getResultingValue(cycle.feedrate) != feedFormat.getResultingValue(cycle.retractFeedrate)) {
        expandCyclePoint(x, y, z);
        break;
      }
      if (P > 0) {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(89),
          getCommonCycle(x, y, z, cycle.retract),
          "P" + secFormat.format(P),
          feedOutput.format(F)
        );
      } else {
        writeBlock(
          gRetractModal.format(98), gAbsIncModal.format(90), gCycleModal.format(85),
          getCommonCycle(x, y, z, cycle.retract),
          feedOutput.format(F)
        );
      }
      break;
    default:
      expandCyclePoint(x, y, z);
    }
  } else {
    if (cycleExpanded) {
      expandCyclePoint(x, y, z);
    } else if (((cycleType == "tapping") || (cycleType == "right-tapping") || (cycleType == "left-tapping")) && getProperty("reversingHead")) {
      expandTappingPoint(x, y, z);
    } else {
      writeBlock(xOutput.format(x), yOutput.format(y));
    }
  }
}

function onCycleEnd() {
  if (!cycleExpanded) {
    writeBlock(gCycleModal.format(80));
    zOutput.reset();
  }
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onMovement(movement) {
  movementType = movement;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, y, z);
    feedOutput.reset();
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var f = feedOutput.format(feed);
  if (x || y || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      var d = tool.diameterOffset;
      if (d > getProperty("maxTool")) {
        warning(localize("The diameter offset exceeds the maximum value."));
      }
      writeBlock(gPlaneModal.format(17));
      switch (radiusCompensation) {
      case RADIUS_COMPENSATION_LEFT:
        dOutput.reset();
        writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(41), x, y, z, dOutput.format(d), f);
        // error(localize("Radius compensation mode is not supported by the CNC control."));
        break;
      case RADIUS_COMPENSATION_RIGHT:
        dOutput.reset();
        writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(42), x, y, z, dOutput.format(d), f);
        // error(localize("Radius compensation mode is not supported by the CNC control."));
        break;
      default:
        writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), gFormat.format(40), x, y, z, f);
      }
    } else {
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), x, y, z, f);
    }
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      feedOutput.reset(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(94), gMotionModal.format(1), f);
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation mode cannot be changed at rapid traversal."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (x || y || z || a || b || c) {
    writeBlock(gMotionModal.format(0), x, y, z, a, b, c);
    feedOutput.reset();
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed, feedMode) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for 5-axis move."));
    return;
  }
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  var c = cOutput.format(_c);
  if (feedMode == FEED_INVERSE_TIME) {
    feedOutput.reset();
  }
  var f = feedMode == FEED_INVERSE_TIME ? inverseTimeOutput.format(feed) : feedOutput.format(feed);
  var fMode = feedMode == FEED_INVERSE_TIME ? 93 : 94;

  if (x || y || z || a || b || c) {
    writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), x, y, z, a, b, c, f);
  } else if (f) {
    if (getNextRecord().isMotion()) { // try not to output feed without motion
      feedOutput.reset(); // force feed on next line
    } else {
      writeBlock(gFeedModeModal.format(fMode), gMotionModal.format(1), f);
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  // controller does not handle transition between planes well
  if (((movementType == MOVEMENT_LEAD_IN) ||
       (movementType == MOVEMENT_LEAD_OUT) ||
       (movementType == MOVEMENT_RAMP) ||
       (movementType == MOVEMENT_PLUNGE) ||
       (movementType == MOVEMENT_RAMP_HELIX) ||
       (movementType == MOVEMENT_RAMP_PROFILE) ||
       (movementType == MOVEMENT_RAMP_ZIG_ZAG)) &&
       (getCircularPlane() != PLANE_XY)) {
    linearize(tolerance);
    return;
  }

  var start = getCurrentPosition();

  if (isFullCircle()) {
    if (getProperty("useRadius") || isHelical()) { // radius mode does not support full arcs
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else if (!getProperty("useRadius")) {
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), jOutput.format(cy - start.y, 0), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), iOutput.format(cx - start.x, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gAbsIncModal.format(90), gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), jOutput.format(cy - start.y, 0), kOutput.format(cz - start.z, 0), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  } else { // use radius mode
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      r = -r; // allow up to <360 deg arcs
    }
    switch (getCircularPlane()) {
    case PLANE_XY:
      writeBlock(gPlaneModal.format(17), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    case PLANE_ZX:
      writeBlock(gPlaneModal.format(18), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    case PLANE_YZ:
      writeBlock(gPlaneModal.format(19), gFeedModeModal.format(94), gMotionModal.format(clockwise ? 2 : 3), xOutput.format(x), yOutput.format(y), zOutput.format(z), "R" + rFormat.format(r), feedOutput.format(feed));
      break;
    default:
      linearize(tolerance);
    }
  }
}

var mapCommand = {
  COMMAND_STOP                    : 0,
  COMMAND_OPTIONAL_STOP           : 1,
  COMMAND_END                     : 2,
  COMMAND_SPINDLE_CLOCKWISE       : 3,
  COMMAND_SPINDLE_COUNTERCLOCKWISE: 4,
  COMMAND_STOP_SPINDLE            : 5,
  COMMAND_ORIENTATE_SPINDLE       : 19,
  COMMAND_LOAD_TOOL               : 6,
  COMMAND_COOLANT_ON              : 8, // flood
  COMMAND_COOLANT_OFF             : 9
};

function onCommand(command) {
  switch (command) {
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_LOCK_MULTI_AXIS:
    return;
  case COMMAND_UNLOCK_MULTI_AXIS:
    return;
  case COMMAND_BREAK_CONTROL:
    return;
  case COMMAND_TOOL_MEASURE:
    return;
  }

  var stringId = getCommandStringId(command);
  var mcode = mapCommand[stringId];
  if (mcode != undefined) {
    writeBlock(mFormat.format(mcode));
  } else {
    onUnsupportedCommand(command);
  }
}

function onSectionEnd() {
  writeBlock(gPlaneModal.format(17));

  if (currentSection.isMultiAxis()) {
    writeBlock(gFeedModeModal.format(94)); // inverse time feed off
  }

  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    onCommand(COMMAND_BREAK_CONTROL);
  }

  forceAny();

  if (((getCurrentSectionId() + 1) >= getNumberOfSections()) ||
      (tool.number != getNextSection().getTool().number)) {
    writeBlock(
      mFormat.format(5),
      mFormat.format(9)
    );
  }

  // the code below gets the machine angles from previous operation.  closestABC must also be set to true
  if (currentSection.isMultiAxis() && currentSection.isOptimizedForMachine()) {
    currentMachineABC = currentSection.getFinalToolAxisABC();
  }
}

/** Output block to do safe retract and/or move to home position. */
function writeRetract() {
  var words = []; // store all retracted axes in an array
  var retractAxes = new Array(false, false, false);
  var method = getProperty("safePositionMethod");
  if (method == "clearanceHeight") {
    if (!is3D()) {
      error(localize("Safe retract option 'Clearance Height' is only supported when all operations are along the setup Z-axis."));
    }
    return;
  }
  validate(arguments.length != 0, "No axis specified for writeRetract().");

  for (i in arguments) {
    retractAxes[arguments[i]] = true;
  }
  if ((retractAxes[0] || retractAxes[1]) && !retracted) { // retract Z first before moving to X/Y home
    error(localize("Retracting in X/Y is not possible without being retracted in Z."));
    return;
  }
  // special conditions
  if (retractAxes[2] && (retractAxes[0] || retractAxes[1])) { // XY don't use G28
    error(localize("You cannot move home in XY & Z in the same block."));
    return;
  }
  if (retractAxes[0] != retractAxes[1]) {
    error(localize("X & Y must be moved to home in the same block."));
  }
  if (retractAxes[2]) {
    if (method == "G28") {
      return;
    }
    method = "G30";
  }
  if (retractAxes[0] || retractAxes[1]) {
    if (method == "G30") {
      return;
    }
    method = "G28";
  }

  // define home positions
  var _xHome;
  var _yHome;
  var _zHome;
  if (method == "G28") {
    _xHome = toPreciseUnit(0, MM);
    _yHome = toPreciseUnit(0, MM);
    _zHome = toPreciseUnit(0, MM);
  } else {
    _xHome = machineConfiguration.hasHomePositionX() ? machineConfiguration.getHomePositionX() : toPreciseUnit(0, MM);
    _yHome = machineConfiguration.hasHomePositionY() ? machineConfiguration.getHomePositionY() : toPreciseUnit(0, MM);
    _zHome = machineConfiguration.getRetractPlane() != 0 ? machineConfiguration.getRetractPlane() : toPreciseUnit(0, MM);
  }
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      words.push("X" + xyzFormat.format(_xHome));
      xOutput.reset();
      break;
    case Y:
      words.push("Y" + xyzFormat.format(_yHome));
      yOutput.reset();
      break;
    case Z:
      words.push("Z" + xyzFormat.format(_zHome));
      zOutput.reset();
      retracted = true;
      break;
    default:
      error(localize("Unsupported axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    switch (method) {
    case "G28":
      writeBlock(gFormat.format(28));
      break;
    case "G53":
      gMotionModal.reset();
      writeBlock(gAbsIncModal.format(90), gFormat.format(53), gMotionModal.format(0), words);
      break;
    case "G30":
      writeBlock(gFormat.format(30));
      break;
    default:
      error(localize("Unsupported safe position method."));
      return;
    }
  }
}

// Start of onRewindMachine logic
/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function onMoveToSafeRetractPosition() {
  writeRetract(Z);
}

/** Rotate axes to new position above reentry position */
function onRotateAxes(_x, _y, _z, _a, _b, _c) {
  // position rotary axes
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  unwindABC(new Vector(_a, _b, _c), false);
  invokeOnRapid5D(_x, _y, _z, _a, _b, _c);
  setCurrentABC(new Vector(_a, _b, _c));
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();
}

/** Return from safe position after indexing rotaries. */
function onReturnFromSafeRetractPosition(_x, _y, _z) {
  // position in XY
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.disable();
  invokeOnRapid(_x, _y, _z);

  // position in Z
  zOutput.enable();
  invokeOnRapid(_x, _y, _z);
}
// End of onRewindMachine logic

function onClose() {
  writeln("");

  // onCommand(COMMAND_COOLANT_OFF);

  writeRetract(Z);

  retracted = true;
  writeRetract(X, Y);

  if (machineConfiguration.isMultiAxisConfiguration()) {
    unwindABC(new Vector(0, 0, 0), true);
    positionABC(new Vector(0, 0, 0), true);
  }

  onImpliedCommand(COMMAND_END);
  onImpliedCommand(COMMAND_STOP_SPINDLE);
  writeBlock(mFormat.format(30)); // stop program, spindle stop, coolant off
  writeln("%");
}

function setProperty(property, value) {
  properties[property].current = value;
}
