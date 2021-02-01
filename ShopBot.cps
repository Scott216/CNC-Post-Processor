/**
  Copyright (C) 2012-2020 by Autodesk, Inc.
  All rights reserved.

  ShopBot OpenSBP post processor configuration.

  $Revision: 42961 93454aaffccabe3254a9a8dd1560f5f2ebdb11b7 $
  $Date: 2020-10-16 06:14:52 $
  
  FORKID {866F31A2-119D-485c-B228-090CC89C9BE8}

  Ver 43004, https://cam.autodesk.com/hsmposts   - SRG

  2/1/21 - Added support for Manual NC passthrough.  Ref - http://autode.sk/3jdxNnK

*/

description = "ShopBot OpenSBP";
vendor = "ShopBot Tools";
vendorUrl = "http://www.shopbottools.com";
legal = "Copyright (C) 2012-2020 by Autodesk, Inc.";
certificationLevel = 2;
minimumRevision = 45500;

longDescription = "Generic post for the Shopbot OpenSBP format with support for both manual and automatic tool changes. By default the post operates in 3-axis mode. For a 5-axis tool set the 'fiveAxis' property to Yes. 5-axis users must set the 'gaugeLength' property in inches before cutting which can be calculated through the tool's calibration macro. For a 4-axis tool set the 'fourAxis' property to YES. For 4-axis mode, the B-axis will turn around the X-axis by default. For the Y-axis configurations set the 'bAxisTurnsAroundX' property to NO. Users running older versions of SB3 - V3.5 or earlier should set the 'SB3v36' property to NO.";

extension = "sbp";
setCodePage("ascii");

capabilities = CAPABILITY_MILLING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = true;
allowedCircularPlanes = undefined; // allow any circular motion

var maxZFeed = toPreciseUnit(180, IN); // max Z feed used for VS command
var stockHeight;

// user-defined properties
properties = {
  fiveAxis: false, // 5-axis machine model
  fourAxis: false, // 4-axis machine model
  bAxisTurnsAroundX: true, // choose between B-axis along X or Y - only for 4-axis mode
  SB3v36: true, // specifies that the version of control is SB3 V3.6 or greater
  gaugeLength: 6.3, // in INCHES always - change this for your particular machine and if recalibration is required - use calibration macro to get value
  safeRetractDistance: 2.0, // in INCHES always - safe retract distance above part in Z to position 5-axis head
  useDPMFeeds: "tooltip", // enabled uses DPM feeds for multi-axis moves, disabled uses FPM
  minimizeFeedOutput: true // enabled uses all feed rates from CAM, disabled only uses the cutting and plunge feeds
};

// user-defined property definitions
propertyDefinitions = {
  fiveAxis: {title:"Five axis", description:"Defines whether the machine is a 5-axis model.", type:"boolean"},
  fourAxis: {title:"Four axis", description:"Defines whether the machine is a 4-axis model.", type:"boolean"},
  bAxisTurnsAroundX: {title:"B axis rotates around X", description:"Choose between B-axis along X or Y. This is only applicable when the machine is a 4-axis model.", type:"boolean"},
  SB3v36: {title:"SB3 V3.6 or greater", description:"Specifies that the version of control is SB3 V3.6 or greater", type:"boolean"},
  gaugeLength: {title:"Gauge length (IN)", description:"Always set in inches. Change this for your particular machine and if recalibration is required. Use calibration macro to get value.", type:"number"},
  safeRetractDistance: {title:"Safe retract distance", description:"A set distance to add to the tool length for rewind C-axis tool retract.", type:"number"},
  useDPMFeeds: {
    title: "Rotary moves feed rate output",
    description: "'VS feeds' outputs DPM .",
    type: "enum",
    values:[
      {title:"VS feeds", id:"true"},
      {title:"Linear axis MS feeds", id:"false"},
      {title:"Programmed feeds", id:"tooltip"}
    ]
  },
  minimizeFeedOutput: {title:"Minimize feedrate output", description:"Enable to limit feed rate output to the cutting (XY) and plunge (Z) feedrates (for multi-axis moves, 'Rotary moves feed rate output' must be set to 'Programmed feeds'). Disable to output all programmed feed rates.", type:"boolean"},
};

function CustomVariable(specifiers, format) {
  if (!(this instanceof CustomVariable)) {
    throw new Error(localize("CustomVariable constructor called as a function."));
  }
  this.variable = createVariable(specifiers, format);
  this.offset = 0;
}

CustomVariable.prototype.format = function (value) {
  return this.variable.format(value + this.offset);
};

CustomVariable.prototype.format2 = function (value) {
  return this.variable.format(value);
};

CustomVariable.prototype.reset = function () {
  return this.variable.reset();
};

CustomVariable.prototype.disable = function () {
  return this.variable.disable();
};

CustomVariable.prototype.enable = function () {
  return this.variable.enable();
};

var xyzFormat = createFormat({decimals:(unit == MM ? 3 : 4)});
var abcFormat = createFormat({decimals:3, scale:DEG});
var feedFormat = createFormat({decimals:(unit == MM ? 3 : 4), scale:1.0 / 60.0}); // feed is mm/s or in/s
var dpmFormat = createFormat({decimals:3, scale:1.0 / 60.0}); // feed is mm/s or in/s
var secFormat = createFormat({decimals:2}); // seconds
var rpmFormat = createFormat({decimals:0});

var xOutput = new CustomVariable({force:true}, xyzFormat);
var yOutput = new CustomVariable({force:true}, xyzFormat);
var zOutput = new CustomVariable({force:true}, xyzFormat);
var aOutput = createVariable({force:true}, abcFormat);
var bOutput = createVariable({force:true}, abcFormat);
var feedOutput = createVariable({}, feedFormat);
var dpmOutput1 = createVariable({}, dpmFormat);
var dpmOutput2 = createVariable({}, dpmFormat);
var feedZOutput = createVariable({force:true}, feedFormat);
var sOutput = createVariable({prefix:"TR, ", force:true}, rpmFormat);

// collected state
var useSimpleFeeds;

// Manual NC PassThrough - added by SRG 2/1/21
function onPassThrough(text) {
  writeComment("Manual NC Passthrough");
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}


/**
  Writes the specified block.
*/
function writeBlock() {
  var result = "";
  for (var i = 0; i < arguments.length; ++i) {
    if (i > 0) {
      result += ", ";
    }
    result += arguments[i];
  }
  writeln(result);
}

/**
  Output a comment.
*/
function writeComment(text) {
  writeln("' " + text);
}

function onOpen() {
  
  if (properties.fiveAxis && properties.fourAxis) {
    error(localize("You cannot enable both fiveAxis and fourAxis properties at the same time."));
    return;
  }

  if (properties.fiveAxis) {
    var aAxis = createAxis({coordinate:0, table:false, axis:[0, 0, -1], range:[-450, 450], preference:0});
    var bAxis = createAxis({coordinate:1, table:false, axis:[0, -1, 0], range:[-120, 120], preference:0});
    machineConfiguration = new MachineConfiguration(bAxis, aAxis);

    setMachineConfiguration(machineConfiguration);
    optimizeMachineAngles2(0); // TCP mode - we compensate below
  } else if (properties.fourAxis) {
    if (properties.bAxisTurnsAroundX) {
      // yes - still called B even when rotating around X-axis
      var bAxis = createAxis({coordinate:1, table:true, axis:[-1, 0, 0], cyclic:true, preference:1});
      machineConfiguration = new MachineConfiguration(bAxis);
      setMachineConfiguration(machineConfiguration);
      optimizeMachineAngles2(1);
    } else {
      var bAxis = createAxis({coordinate:1, table:true, axis:[0, -1, 0], cyclic:true, preference:1});
      machineConfiguration = new MachineConfiguration(bAxis);
      setMachineConfiguration(machineConfiguration);
      optimizeMachineAngles2(1);
    }
  }

  if (!machineConfiguration.isMachineCoordinate(0)) {
    aOutput.disable();
  }
  if (!machineConfiguration.isMachineCoordinate(1)) {
    bOutput.disable();
  }
  
  if (programName) {
    writeComment(programName);
  }
  if (programComment) {
    writeComment(programComment);
  }

  writeBlock("SA"); // absolute
  
  if (properties.SB3v36) {
    writeln("CN, 90"); // calls up user variables in controller
  }
  
  switch (unit) {
  case IN:
    writeBlock("IF %(25)=1 THEN GOTO UNIT_ERROR");
    break;
  case MM:
    writeBlock("IF %(25)=0 THEN GOTO UNIT_ERROR");
    break;
  }

  var tools = getToolTable();
  if ((tools.getNumberOfTools() > 1) && !properties.SB3v36) {
    error(localize("Cannot use more than one tool without tool changer."));
    return;
  }

  var workpiece = getWorkpiece();
  var zStock = unit ? (workpiece.upper.z - workpiece.lower.z) : (workpiece.upper.z - workpiece.lower.z);
  stockHeight = workpiece.upper.z;
  writeln("&PWMaterial = " + xyzFormat.format(zStock));
  var partDatum = workpiece.lower.z;
  if (partDatum > 0) {
    writeln("&PWZorigin = Table Surface");
  } else {
    writeln("&PWZorigin = Part Surface");
  }
  machineConfiguration.setRetractPlane(stockHeight + properties.safeRetractDistance);
}

function onComment(message) {
  writeComment(message);
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
}

/** Force output of X, Y, Z, A, B, C, and F on next output. */
function forceAny() {
  forceXYZ();
  forceABC();
  previousDPMFeed[0] = 0;
  previousDPMFeed[1] = 0;
  feedOutput.reset();
}

function onParameter(name, value) {
}

var currentWorkPlaneABC = undefined;

function forceWorkPlane() {
  currentWorkPlaneABC = undefined;
}

function setWorkPlane(abc) {
  if (!machineConfiguration.isMultiAxisConfiguration()) {
    return true; // ignore
  }

  if (!((currentWorkPlaneABC == undefined) ||
        abcFormat.areDifferent(abc.x, currentWorkPlaneABC.x) ||
        abcFormat.areDifferent(abc.y, currentWorkPlaneABC.y) ||
        abcFormat.areDifferent(abc.z, currentWorkPlaneABC.z))) {
    return false; // no change
  }

  // retract to safe plane
  writeBlock(
    "JZ",
    zOutput.format(machineConfiguration.getRetractPlane())
  );

  // move XY to home position
  writeBlock("JH");

  writeBlock(
    "J5",
    "", // x
    "", // y
    "", // z
    conditional(machineConfiguration.isMachineCoordinate(0), abcFormat.format(abc.x)),
    conditional(machineConfiguration.isMachineCoordinate(1), abcFormat.format(abc.y))
    // conditional(machineConfiguration.isMachineCoordinate(2), abcFormat.format(abc.z))
  );
  
  currentWorkPlaneABC = abc;
  return true;
}

var closestABC = false; // choose closest machine angles
var currentMachineABC;

function getWorkPlaneMachineABC(workPlane) {
  var W = workPlane; // map to global frame

  var abc = machineConfiguration.getABC(W);
  if (closestABC) {
    if (currentMachineABC) {
      abc = machineConfiguration.remapToABC(abc, currentMachineABC);
    } else {
      abc = machineConfiguration.getPreferredABC(abc);
    }
  } else {
    abc = machineConfiguration.getPreferredABC(abc);
  }
  
  try {
    abc = machineConfiguration.remapABC(abc);
    currentMachineABC = abc;
  } catch (e) {
    error(
      localize("Machine angles not supported") + ":"
      + conditional(machineConfiguration.isMachineCoordinate(0), " A" + abcFormat.format(abc.x))
      + conditional(machineConfiguration.isMachineCoordinate(1), " B" + abcFormat.format(abc.y))
      // + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
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
      // + conditional(machineConfiguration.isMachineCoordinate(2), " C" + abcFormat.format(abc.z))
    );
  }

  var tcp = properties.fiveAxis; // 4-axis adjusts for rotations, 5-axis does not
  if (tcp) {
    setRotation(W); // TCP mode
  } else {
    var O = machineConfiguration.getOrientation(abc);
    var R = machineConfiguration.getRemainingOrientation(abc, W);
    setRotation(R);
  }
  
  return abc;
}

var headOffset = 0;

function onSection() {
  var insertToolCall = isFirstSection() ||
    currentSection.getForceToolChange && currentSection.getForceToolChange() ||
    (tool.number != getPreviousSection().getTool().number);
  
  writeln("");

  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      writeComment(comment);
    }
  }
  
  if (properties.showNotes && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }
  
  var retracted = false;
  if (machineConfiguration.isMultiAxisConfiguration()) { // use 5-axis indexing for multi-axis mode

    // set working plane after datum shift
    var abc;
    if (currentSection.isMultiAxis()) {
      abc = currentSection.getInitialToolAxisABC();
      cancelTransformation();
    } else {
      abc = getWorkPlaneMachineABC(currentSection.workPlane);
    }
    retracted = setWorkPlane(abc);
  } else { // pure 3D
    var remaining = currentSection.workPlane;
    if (!isSameDirection(remaining.forward, new Vector(0, 0, 1))) {
      error(localize("Tool orientation is not supported."));
      return;
    }
    setRotation(remaining);
  }

  feedOutput.reset();

  if (insertToolCall && properties.SB3v36) {
    // forceWorkPlane();
    
    if (tool.number > 99) {
      warning(localize("Tool number exceeds maximum value."));
    }
    if (isFirstSection() ||
        currentSection.getForceToolChange && currentSection.getForceToolChange() ||
        (tool.number != getPreviousSection().getTool().number)) {
      /*
      if (hasParameter("operation:clearanceHeight_offset")) {
           var safeZ = getParameter("operation:clearanceHeight_offset");
        writeln("&PWSafeZ = " + safeZ);
      }
*/
      onCommand(COMMAND_STOP_SPINDLE);
      writeln("&Tool = " + tool.number);
      if (!currentSection.isMultiAxis() && !retracted) {
        writeln("C9"); // call macro 9
      }
    }
    if (tool.comment) {
      writeln("&ToolName = \"" + tool.comment + "\"");
    }
  }

  /*
  if (!properties.SB3v36) {
    // we only allow a single tool without a tool changer
    writeBlock("PAUSE"); // wait for user
  }
*/

  if (insertToolCall ||
      isFirstSection() ||
      (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent())) ||
      (tool.clockwise != getPreviousSection().getTool().clockwise)) {
    if (spindleSpeed < 5000) {
      warning(localize("Spindle speed is below minimum value."));
    }
    if (spindleSpeed > 24000) {
      warning(localize("Spindle speed exceeds maximum value."));
    }

    writeBlock(sOutput.format(spindleSpeed));
    onCommand(COMMAND_START_SPINDLE);
  }

  headOffset = 0;
  if (properties.fiveAxis) {
    headOffset = tool.bodyLength + toPreciseUnit(properties.gaugeLength, IN); // control will compensate for tool length
    var displacement = currentSection.getGlobalInitialToolAxis();
    // var displacement = currentSection.workPlane.forward;
    displacement.multiply(headOffset);
    displacement = Vector.diff(displacement, new Vector(0, 0, headOffset));
    // writeComment("DISPLACEMENT: X" + xyzFormat.format(displacement.x) + " Y" + xyzFormat.format(displacement.y) + " Z" + xyzFormat.format(displacement.z));
    // setTranslation(displacement);

    // temporary solution
    xOutput.offset = displacement.x;
    yOutput.offset = displacement.y;
    zOutput.offset = displacement.z;
  } else {
    // temporary solution
    xOutput.offset = 0;
    yOutput.offset = 0;
    zOutput.offset = 0;
  }

  forceAny();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (!retracted) {
    if (getCurrentPosition().z < initialPosition.z) {
      writeBlock("JZ", zOutput.format(initialPosition.z));
      retracted = true;
    } else {
      retracted = false;
    }
  }

  if (true /*insertToolCall*/) {
    if (!retracted) {
      writeBlock(
        "JZ",
        zOutput.format(initialPosition.z)
      );
    }
    writeBlock(
      "J2",
      xOutput.format(initialPosition.x),
      yOutput.format(initialPosition.y)
    );
  }

  if (currentSection.isMultiAxis()) {
    xOutput.offset = 0;
    yOutput.offset = 0;
    zOutput.offset = 0;
  }

  useSimpleFeeds = false;
  if ((!currentSection.isMultiAxis() && properties.minimizeFeedOutput) ||
      (properties.minimizeFeedOutput && properties.useDPMFeeds == "tooltip")) {
    if (hasParameter("operation:tool_feedCutting") && hasParameter("operation:tool_feedPlunge")) {
      useSimpleFeeds = true;
      var f = feedOutput.format(getParameter("operation:tool_feedCutting"));
      var z = feedZOutput.format(Math.min(getParameter("operation:tool_feedPlunge"), maxZFeed));
      if (f || z) {
        writeBlock("MS", f, z);
      }
    }
  }
}

function onDwell(seconds) {
  seconds = clamp(0.01, seconds, 99999);
  writeBlock("PAUSE", secFormat.format(seconds));
}

function onSpindleSpeed(spindleSpeed) {
  if (spindleSpeed < 5000) {
    warning(localize("Spindle speed out of range."));
    return;
  }
  if (spindleSpeed > 24000) {
    warning(localize("Spindle speed exceeds maximum value."));
  }
  writeBlock(sOutput.format(spindleSpeed));
  onCommand(COMMAND_START_SPINDLE);
}

function onRadiusCompensation() {
}

function writeFeed(feed, moveInZ, multiAxis) {
  if (useSimpleFeeds) {
    return;
  }
  var fCode = multiAxis ? "VS" : "MS";
  if (multiAxis) {
    if (dpmFormat.getResultingValue(feed[0]) != dpmFormat.getResultingValue(dpmOutput1.getCurrent()) ||
        dpmFormat.getResultingValue(feed[1]) != dpmFormat.getResultingValue(dpmOutput2.getCurrent())) {
      dpmOutput1.reset();
      dpmOutput2.reset();
      var f1 = dpmOutput1.format(feed[0]);
      var f2 = dpmOutput2.format(feed[1]);
      if (properties.fiveAxis) {
        writeBlock(fCode, "", "", f1, f2);
      } else {
        writeBlock(fCode, "", "", "", f2);
      }
      feedOutput.reset();
    }
  } else {
    var xyFeed = dpmAsXY ? feed[0] : feed;
    var zFeed = dpmAsXY ? feed[1] : feed;
    xyFeed = Math.max(xyFeed, 0.001 * 60);
    zFeed = Math.max(zFeed, 0.001 * 60);
    if (properties.SB3v36) {
      var f = feedOutput.format(xyFeed);
      var f1 = feedFormat.areDifferent(zFeed, feedZOutput.getCurrent());
      if (f || (moveInZ && f1)) {
        writeBlock(fCode, f, feedZOutput.format(zFeed));
        if (!dpmAsXY) {
          dpmOutput1.reset();
          dpmOutput2.reset();
          previousDPMFeed[0] = 0;
          previousDPMFeed[1] = 0;
        }
      }
    } else {
      if (moveInZ) { // limit feed if moving in Z
        xyFeed = Math.min((xyFeed, maxZFeed));
      }
      var f = feedOutput.format(xyFeed);
      if (f) {
        writeBlock(fCode, f, feedZOutput.format(Math.min(zFeed, maxZFeed)));
        if (!dpmAsXY) {
          dpmOutput1.reset();
          dpmOutput2.reset();
          previousDPMFeed[0] = 0;
          previousDPMFeed[1] = 0;
        }
      }
    }
  }
  dpmAsXY = false;
}

function onRapid(_x, _y, _z) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  if (x || y || z) {
    writeBlock("J3", x, y, z);
  }
}

function onLinear(_x, _y, _z, feed) {
  var x = xOutput.format(_x);
  var y = yOutput.format(_y);
  var z = zOutput.format(_z);
  writeFeed(feed, !!z, false);
  if (x || y || z) {
    writeBlock("M3", x, y, z);
  }
}

function getOptimizedHeads(_x, _y, _z, _a, _b, _c) {
  var xyz = new Vector();
  if (properties.fiveAxis) {
    var displacement = machineConfiguration.getDirection(new Vector(_a, _b, _c));
    displacement.multiply(headOffset); // control will compensate for tool length
    displacement = Vector.diff(displacement, new Vector(0, 0, headOffset));
    xyz.setX(_x + displacement.x);
    xyz.setY(_y + displacement.y);
    xyz.setZ(_z + displacement.z);
  } else { // don't adjust points for 4-axis machines
    xyz.setX(_x);
    xyz.setY(_y);
    xyz.setZ(_z);
  }
  return xyz;
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }

  var xyz = getOptimizedHeads(_x, _y, _z, _a, _b, _c);
  var x = xOutput.format2(xyz.x);
  var y = yOutput.format2(xyz.y);
  var z = zOutput.format2(xyz.z);

  var a = aOutput.format(_a);
  var b = bOutput.format(_b);
  writeBlock("J5", x, y, z, a, b);
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (!currentSection.isOptimizedForMachine()) {
    error(localize("This post configuration has not been customized for 5-axis simultaneous toolpath."));
    return;
  }
  
  var xyz = getOptimizedHeads(_x, _y, _z, _a, _b, _c);
  var x = xOutput.format2(xyz.x);
  var y = yOutput.format2(xyz.y);
  var z = zOutput.format2(xyz.z);

  var multiAxis = (aOutput.isEnabled() && abcFormat.areDifferent(_a, aOutput.getCurrent())) ||
    (bOutput.isEnabled() && abcFormat.areDifferent(_b, bOutput.getCurrent()));
  var a = aOutput.format(_a);
  var b = bOutput.format(_b);

  if (x || y || z || a || b) {
    if (multiAxis) {
      var f = getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed);
      if (dpmAsXY) {
        writeFeed(f.frn, !!z, false);
      } else {
        writeFeed(f.frn, !!z, multiAxis);
      }
      writeBlock("M5", x, y, z, a, b);
    } else {
      writeFeed(feed, !!z, multiAxis);
      writeBlock("M3", x, y, z);
    }
  }
}

// Start of onRewindMachine logic
/***** Be sure to add 'safeRetractDistance' to post properties. *****/
var performRewinds = false; // enables the onRewindMachine logic
var safeRetractFeed = (unit == IN) ? 20 : 500;
var safePlungeFeed = (unit == IN) ? 10 : 250;
var stockAllowance = new Vector(toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN), toPreciseUnit(0.1, IN));

/** Allow user to override the onRewind logic. */
function onRewindMachineEntry(_a, _b, _c) {
  return false;
}

/** Retract to safe position before indexing rotaries. */
function moveToSafeRetractPosition(isRetracted) {
  writeBlock(
    "JZ",
    zOutput.format(machineConfiguration.getRetractPlane())
  );
  writeBlock("JH");
  if (properties.forceHomeOnIndexing) {
    writeBlock(
      "JX",
      xOutput.format(machineConfiguration.getRetractPlane()),
      "JY",
      yOutput.format(machineConfiguration.getRetractPlane())
    );
    writeBlock("JH");
  }
}

/** Return from safe position after indexing rotaries. */
function returnFromSafeRetractPosition(position, abc) {
  forceXYZ();
  xOutput.reset();
  yOutput.reset();
  zOutput.reset();
  onRapid5D(position.x, position.y, position.z, abc.x, abc.y, abc.z);
  //zOutput.enable();
  //onExpandedRapid(position.x, position.y, position.z);
}

/** Intersect the point-vector with the stock box. */
function intersectStock(point, direction) {
  var intersection = getWorkpiece().getRayIntersection(point, direction, stockAllowance);
  return intersection === null ? undefined : intersection.second;
}

/** Calculates the retract point using the stock box and safe retract distance. */
function getRetractPosition(currentPosition, currentDirection) {
  var retractPos = intersectStock(currentPosition, currentDirection);
  if (retractPos == undefined) {
    if (tool.getFluteLength() != 0) {
      retractPos = Vector.sum(currentPosition, Vector.product(currentDirection, tool.getFluteLength()));
    }
  }
  if ((retractPos != undefined) && properties.safeRetractDistance) {
    retractPos = Vector.sum(retractPos, Vector.product(currentDirection, properties.safeRetractDistance));
  }
  return retractPos;
}

/** Determines if the angle passed to onRewindMachine is a valid starting position. */
function isRewindAngleValid(_a, _b, _c) {
  // make sure the angles are different from the last output angles
  if (!abcFormat.areDifferent(getCurrentDirection().x, _a) &&
      !abcFormat.areDifferent(getCurrentDirection().y, _b) &&
      !abcFormat.areDifferent(getCurrentDirection().z, _c)) {
    error(
      localize("REWIND: Rewind angles are the same as the previous angles: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  // make sure angles are within the limits of the machine
  var abc = new Array(_a, _b, _c);
  var ix = machineConfiguration.getAxisU().getCoordinate();
  var failed = false;
  if ((ix != -1) && !machineConfiguration.getAxisU().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisV().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisV().isSupported(abc[ix])) {
    failed = true;
  }
  ix = machineConfiguration.getAxisW().getCoordinate();
  if ((ix != -1) && !machineConfiguration.getAxisW().isSupported(abc[ix])) {
    failed = true;
  }
  if (failed) {
    error(
      localize("REWIND: Rewind angles are outside the limits of the machine: ") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return false;
  }
  
  return true;
}

function onRewindMachine(_a, _b, _c) {
  
  if (!performRewinds) {
    error(localize("REWIND: Rewind of machine is required for simultaneous multi-axis toolpath and has been disabled."));
    return;
  }
  
  // Allow user to override rewind logic
  if (onRewindMachineEntry(_a, _b, _c)) {
    return;
  }

  // Determine if input angles are valid or will cause a crash
  if (!isRewindAngleValid(_a, _b, _c)) {
    error(
      localize("REWIND: Rewind angles are invalid:") +
      abcFormat.format(_a) + ", " + abcFormat.format(_b) + ", " + abcFormat.format(_c)
    );
    return;
  }
  
  // Work with the tool end point
  if (currentSection.getOptimizedTCPMode() == 0) {
    currentTool = getCurrentPosition();
  } else {
    currentTool = machineConfiguration.getOrientation(getCurrentDirection()).multiply(getCurrentPosition());
  }
  var currentABC = getCurrentDirection();
  var currentDirection = machineConfiguration.getDirection(currentABC);
  
  // Calculate the retract position
  var retractPosition = getRetractPosition(currentTool, currentDirection);

  // Output warning that axes take longest route
  if (retractPosition == undefined) {
    error(localize("REWIND: Cannot calculate retract position."));
    return;
  } else {
    var text = localize("REWIND: Tool is retracting due to rotary axes limits.");
    warning(text);
    writeComment(text);
  }

  // Move to retract position
  var position;
  if (currentSection.getOptimizedTCPMode() == 0) {
    position = retractPosition;
  } else {
    position = machineConfiguration.getOrientation(getCurrentDirection()).getTransposed().multiply(retractPosition);
  }
  onLinear5D(position.x, position.y, position.z, currentABC.x, currentABC.y, currentABC.z, safeRetractFeed);
  
  // Cancel so that tool doesn't follow tables
  //writeBlock(gFormat.format(49), formatComment("TCPC OFF"));

  // Position to safe machine position for rewinding axes
  moveToSafeRetractPosition(false);

  // Rotate axes to new position above reentry position
  xOutput.disable();
  yOutput.disable();
  zOutput.disable();
  onRapid5D(position.x, position.y, position.z, _a, _b, _c);
  xOutput.enable();
  yOutput.enable();
  zOutput.enable();

  // Reinstate
  // writeBlock(gFormat.format(234), //hFormat.format(tool.lengthOffset), formatComment("TCPC ON"));

  // Move back to position above part
  var workpiece = getWorkpiece();
  var partDatum = workpiece.lower.z;
  if (partDatum > 0) {
    writeln("&PWZorigin = Table Surface");
  } else {
    writeln("&PWZorigin = Part Surface");
  }
  if (currentSection.getOptimizedTCPMode() != 0) {
    position = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(retractPosition);
  }
  returnFromSafeRetractPosition(position, new Vector(_a, _b, _c));

  // Plunge tool back to original position
  if (currentSection.getOptimizedTCPMode() != 0) {
    currentTool = machineConfiguration.getOrientation(new Vector(_a, _b, _c)).getTransposed().multiply(currentTool);
  }
  onLinear5D(currentTool.x, currentTool.y, currentTool.z, _a, _b, _c, safePlungeFeed);
}
// End of onRewindMachine logic

// Start of multi-axis feedrate logic
/***** Be sure to add 'useInverseTime' to post properties if necessary. *****/
/***** 'inverseTimeOutput' should be defined if Inverse Time feedrates are supported. *****/
/***** 'previousABC' can be added throughout to maintain previous rotary positions. Required for Mill/Turn machines. *****/
/***** 'headOffset' should be defined when a head rotary axis is defined. *****/
/***** The feedrate mode must be included in motion block output (linear, circular, etc.) for Inverse Time feedrate support. *****/
var dpmBPW = 0.1; // ratio of rotary accuracy to linear accuracy for DPM calculations
var inverseTimeUnits = 1.0; // 1.0 = minutes, 60.0 = seconds
var maxInverseTime = 45000; // maximum value to output for Inverse Time feeds
var maxDPM = 99999; // maximum value to output for DPM feeds
var useInverseTimeFeed = false; // use DPM feeds
var previousDPMFeed = new Array(0, 0); // previously output DPM feed
var dpmFeedToler = 0.1 * 60; // tolerance to determine when the DPM feed has changed
var dpmFeedMin = 0.002 * 60; // minimum DPM feed
// var previousABC = new Vector(0, 0, 0); // previous ABC position if maintained in post, don't define if not used
var forceOptimized = undefined; // used to override optimized-for-angles points (XZC-mode)

/** Calculate the multi-axis feedrate number. */
function getMultiaxisFeed(_x, _y, _z, _a, _b, _c, feed) {
  var f = {frn:[0, 0], fmode:0};
  if (feed <= 0) {
    error(localize("Feedrate is less than or equal to 0."));
    return f;
  }
  
  var length = getMoveLength(_x, _y, _z, _a, _b, _c);
  
  if (useInverseTimeFeed) { // inverse time
    f.frn = getInverseTime(length.tool, feed);
    f.fmode = 93;
    feedOutput.reset();
  } else { // degrees per minute
    f.frn = getFeedDPM(length, feed);
    f.fmode = 94;
  }
  return f;
}

/** Returns point optimization mode. */
function getOptimizedMode() {
  if (forceOptimized != undefined) {
    return forceOptimized;
  }
  // return (currentSection.getOptimizedTCPMode() != 0); // TAG:doesn't return correct value
  return !properties.fiveAxis; // false for 5-axis and true for 4-axis
}
  
/** Calculate the DPM feedrate number. */
var dpmAsXY = false; // multi-axis feeds output as IPM feeds (true) or DPM feeds (false)
function getFeedDPM(_moveLength, _feed) {
  dpmAsXY = false;
  if ((_feed == 0) || (_moveLength.tool < 0.0001) || (toDeg(_moveLength.abcLength) < 0.0005)) {
    previousDPMFeed[0] = 0;
    previousDPMFeed[1] = 0;
    return [_feed, _feed];
  }
  var moveTime = _moveLength.tool / _feed;
  if (moveTime == 0) {
    return [_feed, _feed];
  }

  var dpmFeed;
  var tcp = false; // !getOptimizedMode() && (forceOptimized == undefined);  // set to false for rotary heads
  if (tcp) { // TCP mode is supported, output feed as FPM
    dpmFeed = new Array(_feed, _feed);
  } else if (false) { // standard DPM
    dpmFeed = Math.min(toDeg(_moveLength.abcLength) / moveTime, maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed[0]) < dpmFeedToler) {
      dpmFeed = previousDPMFeed[0];
    }
  } else if (false) { // combination FPM/DPM
    var length = Math.sqrt(Math.pow(_moveLength.xyzLength, 2.0) + Math.pow((toDeg(_moveLength.abcLength) * dpmBPW), 2.0));
    dpmFeed = Math.min((length / moveTime), maxDPM);
    if (Math.abs(dpmFeed - previousDPMFeed[0]) < dpmFeedToler) {
      dpmFeed = previousDPMFeed[0];
    }
  } else { // machine specific calculation
    var dpmA;
    var dpmB;
    var xy = new Vector(_moveLength.xyz.x, _moveLength.xyz.y, 0).length;
    if (properties.useDPMFeeds == "false" &&
        ((xyzFormat.getResultingValue(_moveLength.xyz.x) != 0) ||
        (xyzFormat.getResultingValue(_moveLength.xyz.y) != 0) ||
        (xyzFormat.getResultingValue(_moveLength.xyz.z) != 0))) {
      dpmA = xy / moveTime;
      dpmB = _moveLength.xyz.z / moveTime;
      dpmAsXY = true;
    } else if (properties.useDPMFeeds == "tooltip") {
      dpmA = _feed;
      dpmB = _feed;
      dpmAsXY = true;
    } else {
      dpmA = toDeg(_moveLength.abc.x) / moveTime;
      dpmB = toDeg(_moveLength.abc.y) / moveTime;
      dpmA = Math.max(dpmA, dpmFeedMin);
      dpmB = Math.max(dpmB, dpmFeedMin);
      dpmAsXY = false;
    }
    dpmFeed = new Array(Math.min(dpmA, maxDPM), Math.min(dpmB, maxDPM));
    if ((Math.abs(dpmFeed[0] - previousDPMFeed[0]) < dpmFeedToler) && (previousDPMFeed[0] != 0)) {
      dpmFeed[0] = previousDPMFeed[0];
    }
    if ((Math.abs(dpmFeed[1] - previousDPMFeed[1]) < dpmFeedToler) && (previousDPMFeed[1] != 0)) {
      dpmFeed[1] = previousDPMFeed[1];
    }
  }
  previousDPMFeed[0] = dpmFeed[0];
  previousDPMFeed[1] = dpmFeed[1];
  return dpmFeed;
}

/** Calculate the Inverse time feedrate number. */
function getInverseTime(_length, _feed) {
  var inverseTime;
  if (_length < 1.e-6) { // tool doesn't move
    if (typeof maxInverseTime === "number") {
      inverseTime = maxInverseTime;
    } else {
      inverseTime = 999999;
    }
  } else {
    inverseTime = _feed / _length / inverseTimeUnits;
    if (typeof maxInverseTime === "number") {
      if (inverseTime > maxInverseTime) {
        inverseTime = maxInverseTime;
      }
    }
  }
  return inverseTime;
}

/** Calculate radius for each rotary axis. */
function getRotaryRadii(startTool, endTool, startABC, endABC) {
  var radii = new Vector(0, 0, 0);
  var startRadius;
  var endRadius;
  var axis = new Array(machineConfiguration.getAxisU(), machineConfiguration.getAxisV(), machineConfiguration.getAxisW());
  for (var i = 0; i < 3; ++i) {
    if (axis[i].isEnabled()) {
      var startRadius = getRotaryRadius(axis[i], startTool, startABC);
      var endRadius = getRotaryRadius(axis[i], endTool, endABC);
      radii.setCoordinate(axis[i].getCoordinate(), Math.max(startRadius, endRadius));
    }
  }
  return radii;
}

/** Calculate the distance of the tool position to the center of a rotary axis. */
function getRotaryRadius(axis, toolPosition, abc) {
  if (!axis.isEnabled()) {
    return 0;
  }

  var direction = axis.getEffectiveAxis();
  var normal = direction.getNormalized();
  // calculate the rotary center based on head/table
  var center;
  var radius;
  if (axis.isHead()) {
    var pivot;
    if (typeof headOffset === "number") {
      pivot = headOffset;
    } else {
      pivot = tool.getBodyLength();
    }
    if (axis.getCoordinate() == machineConfiguration.getAxisU().getCoordinate()) { // rider
      center = Vector.sum(toolPosition, Vector.product(machineConfiguration.getDirection(abc), pivot));
      center = Vector.sum(center, axis.getOffset());
      radius = Vector.diff(toolPosition, center).length;
    } else { // carrier
      var angle = abc.getCoordinate(machineConfiguration.getAxisU().getCoordinate());
      radius = Math.abs(pivot * Math.sin(angle));
      radius += axis.getOffset().length;
    }
  } else {
    center = axis.getOffset();
    var d1 = toolPosition.x - center.x;
    var d2 = toolPosition.y - center.y;
    var d3 = toolPosition.z - center.z;
    var radius = Math.sqrt(
      Math.pow((d1 * normal.y) - (d2 * normal.x), 2.0) +
      Math.pow((d2 * normal.z) - (d3 * normal.y), 2.0) +
      Math.pow((d3 * normal.x) - (d1 * normal.z), 2.0)
    );
  }
  return radius;
}
  
/** Calculate the linear distance based on the rotation of a rotary axis. */
function getRadialDistance(radius, startABC, endABC) {
  // calculate length of radial move
  var delta = Math.abs(endABC - startABC);
  if (delta > Math.PI) {
    delta = 2 * Math.PI - delta;
  }
  var radialLength = (2 * Math.PI * radius) * (delta / (2 * Math.PI));
  return radialLength;
}
  
/** Calculate tooltip, XYZ, and rotary move lengths. */
function getMoveLength(_x, _y, _z, _a, _b, _c) {
  // get starting and ending positions
  var moveLength = {};
  var startTool;
  var endTool;
  var startXYZ;
  var endXYZ;
  var startABC;
  if (typeof previousABC !== "undefined") {
    startABC = new Vector(previousABC.x, previousABC.y, previousABC.z);
  } else {
    startABC = getCurrentDirection();
  }
  var endABC = new Vector(_a, _b, _c);
    
  if (!getOptimizedMode()) { // calculate XYZ from tool tip
    startTool = getCurrentPosition();
    endTool = new Vector(_x, _y, _z);
    startXYZ = startTool;
    endXYZ = endTool;

    // adjust points for tables
    if (!machineConfiguration.getTableABC(startABC).isZero() || !machineConfiguration.getTableABC(endABC).isZero()) {
      startXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).getTransposed().multiply(startXYZ);
      endXYZ = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).getTransposed().multiply(endXYZ);
    }

    // adjust points for heads
    if (machineConfiguration.getAxisU().isEnabled() && machineConfiguration.getAxisU().isHead()) {
      if (typeof getOptimizedHeads === "function") { // use post processor function to adjust heads
        startXYZ = getOptimizedHeads(startXYZ.x, startXYZ.y, startXYZ.z, startABC.x, startABC.y, startABC.z);
        endXYZ = getOptimizedHeads(endXYZ.x, endXYZ.y, endXYZ.z, endABC.x, endABC.y, endABC.z);
      } else { // guess at head adjustments
        var startDisplacement = machineConfiguration.getDirection(startABC);
        startDisplacement.multiply(headOffset);
        var endDisplacement = machineConfiguration.getDirection(endABC);
        endDisplacement.multiply(headOffset);
        startXYZ = Vector.sum(startTool, startDisplacement);
        endXYZ = Vector.sum(endTool, endDisplacement);
      }
    }
  } else { // calculate tool tip from XYZ, heads are always programmed in TCP mode, so not handled here
    startXYZ = getCurrentPosition();
    endXYZ = new Vector(_x, _y, _z);
    startTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(startABC)).multiply(startXYZ);
    endTool = machineConfiguration.getOrientation(machineConfiguration.getTableABC(endABC)).multiply(endXYZ);
  }

  // calculate axes movements
  moveLength.xyz = Vector.diff(endXYZ, startXYZ).abs;
  moveLength.xyzLength = moveLength.xyz.length;
  moveLength.abc = Vector.diff(endABC, startABC).abs;
  for (var i = 0; i < 3; ++i) {
    if (moveLength.abc.getCoordinate(i) > Math.PI) {
      moveLength.abc.setCoordinate(i, 2 * Math.PI - moveLength.abc.getCoordinate(i));
    }
  }
  moveLength.abcLength = moveLength.abc.length;

  // calculate radii
  moveLength.radius = getRotaryRadii(startTool, endTool, startABC, endABC);
  
  // calculate the radial portion of the tool tip movement
  var radialLength = Math.sqrt(
    Math.pow(getRadialDistance(moveLength.radius.x, startABC.x, endABC.x), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.y, startABC.y, endABC.y), 2.0) +
    Math.pow(getRadialDistance(moveLength.radius.z, startABC.z, endABC.z), 2.0)
  );
  
  // calculate the tool tip move length
  // tool tip distance is the move distance based on a combination of linear and rotary axes movement
  moveLength.tool = moveLength.xyzLength + radialLength;

  // debug
  if (false) {
    writeComment("DEBUG - tool   = " + moveLength.tool);
    writeComment("DEBUG - xyz    = " + moveLength.xyz);
    var temp = Vector.product(moveLength.abc, 180 / Math.PI);
    writeComment("DEBUG - abc    = " + temp);
    writeComment("DEBUG - radius = " + moveLength.radius);
  }
  return moveLength;
}
// End of multi-axis feedrate logic

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  var start = getCurrentPosition();

  if (isHelical()) {
    linearize(tolerance);
    return;
  }

  switch (getCircularPlane()) {
  case PLANE_XY:
    writeFeed(feed, false, false);
    writeBlock("CG", "", xOutput.format(x), yOutput.format(y), xyzFormat.format(cx - start.x), xyzFormat.format(cy - start.y), "", clockwise ? 1 : -1);
    break;
  default:
    linearize(tolerance);
  }
}

function onCommand(command) {
  switch (command) {
  case COMMAND_STOP_SPINDLE:
    if (properties.SB3v36) {
      writeln("C7"); // call macro 7
    } else {
      writeln("SO 1,0");
    }
    break;
  case COMMAND_START_SPINDLE:
    if (properties.SB3v36) {
      writeln("C6"); // call macro 6
    } else {
      writeln("SO 1,1");
    }
    writeln("PAUSE 2"); // wait for 2 seconds for spindle to ramp up
    break;
  }
}

function onSectionEnd() {
  xOutput.offset = 0;
  yOutput.offset = 0;
  zOutput.offset = 0;
  // the code below gets the machine angles from previous operation.  closestABC must also be set to true
  if (currentSection.isMultiAxis() && currentSection.isOptimizedForMachine()) {
    currentMachineABC = currentSection.getFinalToolAxisABC();
  }
  forceAny();
}

function onClose() {
  onCommand(COMMAND_STOP_SPINDLE);

  retracted = setWorkPlane(new Vector(0, 0, 0)); // reset working plane
  if (!retracted) {
    writeBlock(
      "JZ",
      zOutput.format(machineConfiguration.getRetractPlane())
    );
    writeBlock("JH");
  }

  writeBlock("END");
  writeln("");
  writeln("");
  writeBlock("UNIT_ERROR:");
  writeBlock("CN, 91");
  writeBlock("END");
}
