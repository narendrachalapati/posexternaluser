public with sharing class freeBusyResponseWrapper {

    public String kind {get;set;} 
    public Datetime timeMin {get;set;} 
    public Datetime timeMax {get;set;} 
    public Calendars calendars {get;set;} 

    public FreeBusyResponseWrapper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'kind') {
                        kind = parser.getText();
                    } else if (text == 'timeMin') {
                        timeMin = formatDateTime(parser.getText(), 'YYYY-MM-DDThh:mm:ssZ');
                    } else if (text == 'timeMax') {
                        timeMax = formatDateTime(parser.getText(), 'YYYY-MM-DDThh:mm:ssZ');
                    } else if (text == 'calendars') {
                        calendars = new Calendars(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'FreeBusyResponseWrapper consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
	
	public class Calendars {
        public Map<String , List<Busy>> calendarIdBusySlotsMap = new Map<String , List<Busy>>();

		public Calendars(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {

                    String calSysKey = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        //Loop All calendars
                        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                String text = parser.getText();
                                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                                    if (text == 'busy') {
                                        List<Busy> busy = new List<Busy>(); 
                                        busy = arrayOfBusy(parser);
                                        if ( calSysKey != null ) {
                                            if( busy.size()>0 ){
                                                calendarIdBusySlotsMap.put(String.valueOf(calSysKey), busy);
                                            }else{
                                                calendarIdBusySlotsMap.put(String.valueOf(calSysKey), new List<Busy>());
                                            }
                                        }
                                    } else {
                                        System.debug(LoggingLevel.WARN, 'CalenderExId consuming unrecognized property: '+text);
                                        consumeObject(parser);
                                    }
                                }
                            }
                        }

					} else {
                        System.debug(LoggingLevel.WARN, 'CalenderExId consuming unrecognized property: '+calSysKey);
                        consumeObject(parser);
                    } 
				}
			}
		}
	}
	
    private static List<Busy> arrayOfBusy(System.JSONParser p) {
        List<Busy> res = new List<Busy>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Busy(p));
        }
        return res;
    }
    
	public class Busy {
		public Datetime start_x {get;set;} 
		public Datetime end_x {get;set;} 

		public Busy(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'start') {
							start_x = formatDateTime(parser.getText(), 'YYYY-MM-DDThh:mm:ssZ');
						} else if (text == 'end') {
							end_x = formatDateTime(parser.getText(), 'YYYY-MM-DDThh:mm:ssZ');
						} else {
							System.debug(LoggingLevel.WARN, 'Busy consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
    public static Datetime formatDateTime(String dt, String format) {
        Datetime newDatetime;

        Integer yearIndex = format.indexOf('YYYY');
        Integer monthIndex = format.indexOf('MM');
        Integer dateIndex = format.indexOf('DD');
        Integer hoursIndex = format.indexOf('hh');
        Integer minutesIndex = format.indexOf('mm');
        Integer secondsIndex = format.indexOf('ss');
        Integer millisecondsIndex = format.indexOf('sss');

        Integer tzHours = format.indexOf('zh');
        Integer tzMins = format.indexOf('zm');

        String value = dt.substring(yearIndex, yearIndex + 4) + '-' +
            dt.substring(monthIndex, monthIndex + 2) + '-' +
            dt.substring(dateIndex, dateIndex + 2) +
            ' ' +
            dt.substring(hoursIndex, hoursIndex + 2) + ':' +
            dt.substring(minutesIndex, minutesIndex + 2) + ':' +
            (secondsIndex > 0 ? dt.substring(secondsIndex, secondsIndex + 2) : '00');

        Integer tzHoursOffset = 0;
        Integer tzMinsOffset = 0;
        if (tzHours > 0 && tzMins > 0) {
            Integer tzSymbol = format.indexOf('_');

            tzHoursOffset = Integer.valueOf((dt.substring(tzSymbol, tzSymbol + 1) + dt.substring(tzHours, tzHours + 2)));
            tzMinsOffset = Integer.valueOf((dt.substring(tzSymbol, tzSymbol + 1) + dt.substring(tzMins)));
        }
newDatetime = DateTime.valueOfGmt(value).addHours(-tzHoursOffset).addMinutes(-tzMinsOffset);
        return newDatetime;
    }
	
	public static FreeBusyResponseWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new FreeBusyResponseWrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}


}