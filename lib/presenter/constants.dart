import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

const kExtraSmallSpace = 4.0;
const kSmallSpace = 8.0;
const kMediumSpace = 16.0;
const kLargeSpace = 32.0;
const kExtraLargeSpace = 64.0;

const kLargeFontSize = 32.0;

const kSmallEdgeInsets = EdgeInsets.all(kSmallSpace);
const kMediumEdgeInsets = EdgeInsets.all(kMediumSpace);

const kSmallSpacerVertical = SizedBox(height: kSmallSpace);
const kMediumSpacerVertical = SizedBox(height: kMediumSpace);
const kExtraLargeSpacerVertical = SizedBox(height: kExtraLargeSpace);
const kMediumSpacerHorizontal = SizedBox(width: kMediumSpace);

const kExtraSmallRadius = Radius.circular(kExtraSmallSpace);
const kMediumRadius = Radius.circular(kMediumSpace);

const kExtraSmallBorder = BorderRadius.all(kExtraSmallRadius);
const kMediumBorder = BorderRadius.all(kMediumRadius);

const kFastDuration = Duration(milliseconds: 300);
