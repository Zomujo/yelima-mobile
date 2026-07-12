import 'package:intl/intl.dart';

/// Centralized, statically cached DateFormats to prevent CPU thrashing
/// from instantiating DateFormats inside build methods or loops.
class AppDateFormats {
  // e.g. "9:41 AM"
  static final DateFormat timeShort = DateFormat('h:mm a');
  
  // e.g. "October 2023"
  static final DateFormat monthYear = DateFormat('MMMM yyyy');
  
  // e.g. "Mon"
  static final DateFormat dayOfWeekShort = DateFormat('E');
  
  // e.g. "Mon 15 Oct • 09:41"
  static final DateFormat appointmentCard = DateFormat('EEE d MMM • HH:mm');
  
  // e.g. "October 15, 2023"
  static final DateFormat monthDayYear = DateFormat('MMMM d, yyyy');
  
  // e.g. "2023-10-15" (forced to 15th of month)
  static final DateFormat yyyyMM15 = DateFormat('yyyy-MM-15');
  
  // e.g. "09:41" (24-hour)
  static final DateFormat time24h = DateFormat('HH:mm');
  
  // e.g. "15 OCT"
  static final DateFormat dayMonthShort = DateFormat('dd MMM');
  
  // e.g. "15"
  static final DateFormat dayOnly = DateFormat('dd');
  
  // e.g. "OCT"
  static final DateFormat monthShort = DateFormat('MMM');
  
  // e.g. "Monday 15 October"
  static final DateFormat dayDateMonth = DateFormat('EEEE d MMMM');
  
  // e.g. "October 15"
  static final DateFormat monthDay = DateFormat('MMMM d');

  // Prevent instantiation
  AppDateFormats._();
}
