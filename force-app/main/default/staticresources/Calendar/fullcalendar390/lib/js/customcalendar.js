var userTimezone, timeZoneOffsetString, todaySystemDate, todaySystemDateIsoString, todayLocaleDate;

function hideLoading() {
    $("#spinner").hide();
}

function showLoading() {
    $("#spinner").show();
}

function hideCalendar() {
    $(".calender-wrap").hide();
}

function showCalendar() {
    initNewCalendar();
    // initCalendar();
    // $(".calender-wrap").show();
}

function hideBookingSlots() {
    $(".timeslots-picker").hide();
}

function showBookingSlots() {
    $(".timeslots-picker").show();
}

function createdialogflowNode() {
    var getcurrentSessionId = $('input[name=currentSessionId]').val();
    var createmessengerdivWrap = document.createElement("div");
    var dialogflowScript = document.createElement("script");
    dialogflowScript.setAttribute("src", "https://www.gstatic.com/dialogflow-console/fast/messenger-cx/bootstrap.js?v=1");
    createmessengerdivWrap.appendChild(dialogflowScript);
    var dialogflowMessenger = document.createElement("df-messenger");
    dialogflowMessenger.setAttribute("df-cx", "true");
    dialogflowMessenger.setAttribute("wait-open", "true");
    dialogflowMessenger.setAttribute("intent", "WelcomeWebsiteChat");
    dialogflowMessenger.setAttribute("expand", "false");
    dialogflowMessenger.setAttribute("chat-title", "MedicalWebsiteChatBot");
    dialogflowMessenger.setAttribute("session-id", getcurrentSessionId);
    dialogflowMessenger.setAttribute("agent-id", "34ee0037-1494-4a21-bc3c-fcdecacd081f");
    dialogflowMessenger.setAttribute("language-code", "en");
    createmessengerdivWrap.append(dialogflowMessenger);
    $('.body-wrap').append(createmessengerdivWrap);
}

function clearSessionStorage() { //clears the entire sessionStorage
    sessionStorage.clear();
    console.log("clearSessionStorage");
}

function removeSessionVariable(sessionVariableName) { //deletes item from sessionStorage
    sessionStorage.removeItem(sessionVariableName);
    console.log("removeSessionVariable");
}

function storeSessionVariable(sessionVariableName, elementId, value) { //stores items in sessionStorage
    var updatedValue;
    if (value != undefined) {
        updatedValue = value;
    } else {
        updatedValue = document.getElementById(elementId).value;
    }
    sessionStorage.setItem(sessionVariableName, updatedValue);
}

function retrieveSessionVariable(sessionVariableName) { //retrieves items in sessionStorage
    console.log("retrieveSessionRecords");
    var fetchsessionVariable = window.sessionStorage.getItem(sessionVariableName);
    return fetchsessionVariable;
}

function displayMessage(title, message, type) {
    if (type == 'success') {
        toastr.success(message, title);
    } else if (type == 'warning') {
        toastr.warning(message, title);
    } else {
        toastr.error(message, title);
    }
}


function showUpcomingAppointments(){
    fetchUpcomingAppointments();
    onclickBindEventHandlers();
    hideLoading();
}

function hideLoadingAndBindEventHandlers(){
    onclickBindEventHandlers();
    hideLoading();
    // var selectedproductuuid = $('input[name=selectedproductuuid]').val();

    var selectedproductuuid = getUtmParam('productuuid');
    if ((selectedproductuuid != '') && (selectedproductuuid != undefined)) {
        // $(".productbutton").addClass("hide-section");
        $('.productbutton[data-productuuid="' + selectedproductuuid + '"]').show();
    } 
    else {
        $('.productbutton').show();
    }
}

function showAvailableSlots() {
    hideLoading();
    try {
        var freebusyResponseJson = $('input[name=freebusyResponseJson]').val();
        var availableBookingSlotsUTC = $('input[name=availableBookingSlotsUTC]').val();
        var availableBookingSlotsTimezone = $('input[name=availableBookingSlotsTimezone]').val();
        console.log('freebusyResponseJson ' + freebusyResponseJson);
        console.log('availableBookingSlotsUTC ' + availableBookingSlotsUTC);
        console.log('availableBookingSlotsTimezone ' + availableBookingSlotsTimezone);
        console.log('showAvailableSlots ');
        hideCalendar();
        showBookingSlots();  
    } catch (ex) {
        console.log('Exception ' + ex);
    }
}

function storeSelectedTimeSlot(event){
    try {
        $(".timeslotbookingbtn").removeClass("active");
        var timeslotbookingbtnElement =$(event.target);
        var selectedstarttime = timeslotbookingbtnElement.attr('data-starttime');
        console.log('selectedstarttime ' + selectedstarttime);
        timeslotbookingbtnElement.addClass("active");
        //Confirm Button Styles
        $(".booking-confirm").removeClass("show");
        timeslotbookingbtnElement.siblings().addClass("show");
        timeslotbookingbtnElement.siblings().show();
    } catch (ex) {
        console.log('Exception Occured ' + ex);
    }
}

function confirmAppointment(event) {
    try {
        showLoading();
        var timeslotbookingbtnElement = $(event.target);
        var selectedstarttime = timeslotbookingbtnElement.attr('data-starttime');
        console.log('createAppointment ' + selectedstarttime);
        $('input[name=selectedAppointmentStartDateTime]').val(selectedstarttime);
        createAppointment(selectedstarttime);
        // fetchUpcomingAppointments();
        
    } catch (ex) {
        console.log('Exception ' + ex);
        console.log('Exception ' + ex.message);
    }
    hideSecondPage();
}

function showAppointmentDetails(){
    try {
        var selectedAppointmentStartDateTime = $('input[name=selectedAppointmentStartDateTime]').val();
        var specificError = $('input[name=specificError]').val();
        if ((specificError != "") && (specificError != null) && (specificError != undefined)) {
            displayMessage('Failure!', 'Selected slot is already booked. Please refresh and book another slot', 'error');
            var selectedproductuuid = $('input[name=selectedproductuuid]').val();
            var IsoStartDateTime = $('input[name=startDateTime]').val();
            var IsoEndDateTime = $('input[name=endDateTime]').val();
            checkFreeBusy(selectedproductuuid, IsoStartDateTime, IsoEndDateTime);
            fetchUpcomingAppointments();
            onclickBindEventHandlers();
        } else {
            $('.timeslotbookingbtn[data-starttime="' + selectedAppointmentStartDateTime + '"]').addClass('active');
            $('.booking-confirm[data-starttime="' + selectedAppointmentStartDateTime + '"]').addClass('show');
            fetchUpcomingAppointments();
            onclickBindEventHandlers();
            hideLoading();
            hideSecondPage();
            var selectedproductuuid = $('input[name=selectedproductuuid]').val();

            if ((selectedproductuuid != '') && (selectedproductuuid != undefined)) {
                // $(".productbutton").addClass("hide-section");
                $('.productbutton[data-productuuid="' + selectedproductuuid + '"]').show();
            }
        }
    } catch (ex) {
        console.log('Exception ' + ex);
        console.log('Exception ' + ex.message);
    }
}

function initTimezones() {
    var timezoneSelect = document.getElementById("timezone-select");
    // var timezones = Intl.supportedValuesOf('timeZone');
    var timezones = moment.tz.names(); 

    for (var i = 0; i < timezones.length; i++) {
        var option = document.createElement("option");
        option.value = timezones[i];
        option.text = timezones[i];
        timezoneSelect.appendChild(option);
    }
}

function changeTimezone(date, ianatz) {
    // suppose the date is 12:00 UTC
    var invdate = new Date(date.toLocaleString('en-US', {
        timeZone: ianatz
    }));

    // then invdate will be 07:00 in Toronto
    // and the diff is 5 hours
    var diff = date.getTime() - invdate.getTime();

    // so 12:00 in Toronto is 17:00 UTC
    return new Date(date.getTime() - diff); // needs to substract

}

function initToaster() {
    toastr.options = {
        "closeButton": true,
        "newestOnTop": false,
        "progressBar": true,
        "positionClass": "toast-top-right",
        "preventDuplicates": true,
        "onclick": null,
        "showDuration": "300",
        "hideDuration": "1000",
        "timeOut": "5000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    };
}


function getOffsetFromTimeZoneString() {
    userTimezone = $('input[name=displayTimeZone]').val();
    // current datetime string in timezone
    var selectedUserLocalDatetimeStr = new Date().toLocaleString("en-US", { timeZone: userTimezone ,timeZoneName: 'longOffset'});
    var selectedUserLocalDatetimeArr = selectedUserLocalDatetimeStr.split('GMT')
    if (selectedUserLocalDatetimeArr.length > 0) {
        return selectedUserLocalDatetimeArr[1];
    } else {
        return '';
    }
}

function getLocaleCurrentDateTime(){
    userTimezone = $('input[name=displayTimeZone]').val();

    // current datetime string in timezone
    var userLocalDatetimeStr = new Date().toLocaleString("en-US", { timeZone: userTimezone, timeZoneName : 'longOffset' });

    // create new Date object based on selected timezone
    todaySystemDate = new Date(userLocalDatetimeStr);
    var todayDate = todaySystemDate.getDate();
    todayDate = (todayDate < 10) ? '0'+todayDate : todayDate;
    var todayMonth = (todaySystemDate.getMonth() + 1);
    todayMonth = (todayMonth < 10) ? '0'+todayMonth : todayMonth;
    var todayYear = todaySystemDate.getFullYear();
    
    todayLocaleDate = todayYear + "-" + todayMonth + "-" + todayDate;

    // todaySystemDate = new Date();
    todaySystemDateIsoString = todaySystemDate.toISOString('en-US', { timeZone: userTimezone, timeZoneName : 'longOffset' });
}

function initCalendar() {
    getLocaleCurrentDateTime();
    $('#calendar').fullCalendar({
        header: {
            left: 'prev',
            center: 'title',
            right: 'next'
        },
        themeSystem: 'jquery-ui',
        defaultView: 'month',
        height: '100',
        aspectRatio: 3,
        fixedWeekCount: false,
        showNonCurrentDates: false,
        selectable: true,
        defaultDate: todayLocaleDate,
        eventLimit: false,
        eventLimit: true,
        selectAllow: function (info) {
            if (info.start.isBefore(moment().add(-1, 'days')))
                return false;
            return true;
        },
        dayClick: function (date, jsEvent, view) {
            showLoading();
            getLocaleCurrentDateTime();
            var clickeddate = date.format('YYYY-MM-DD');

            //Check if user Selected Past Date to Show Alert
            if (clickeddate < todayLocaleDate) {
                hideLoading();
                displayMessage('Failure!', 'Please Select Any Future Date greater than ' + todayLocaleDate, 'error');
                return;
            }
            //Set Selected Date as Start DateTime
            var startDateTime = new Date(clickeddate + 'T00:00:00');
            // startDateTime.setHours(0, 0, 0, 0);

            console.log('startDateTime  ' + startDateTime);
            timeZoneOffsetString = getOffsetFromTimeZoneString();
            
            //Set Current DateTime as StartDateTime
            if(clickeddate == todayLocaleDate){
                startDateTime = todaySystemDate;
            }else{
                startDateTime.setHours(0, 0, 0, 0);
            }
            var IsoStartDateTime = startDateTime.toISOString();
            $('input[name=startDateTime]').val(IsoStartDateTime);

            var endDateTime = startDateTime;
            endDateTime.setHours(23, 59, 59, 0);
            var IsoEndDateTime = endDateTime.toISOString('en-US', { timeZone: userTimezone });
            $('input[name=endDateTime]').val(IsoEndDateTime);

            var selectedproductuuid = $('input[name=selectedproductuuid]').val();

            console.log(IsoStartDateTime + ':' + IsoEndDateTime);
            try {
                checkFreeBusy(selectedproductuuid, IsoStartDateTime, IsoEndDateTime);
            } catch (ex) {
                console.log('Exception got ' + ex);
                hideLoading();
            }
        },
    });
}

function startUp() {
    showLoading();

    initToaster();
    // initTimezones();
    // hideCalendar();
    hideBookingSlots();
    var memberuuid = $('input[name=memberuuid]').val();
    var currentSessionId = $('input[name=currentSessionId]').val();
    var selectedproductuuid = $('input[name=selectedproductuuid]').val();
    // hideLoading();
    if ((currentSessionId != '') && (currentSessionId != undefined)) {
        createdialogflowNode();
    }
    if ((selectedproductuuid != '') && (selectedproductuuid != undefined)) {
        $(".productbutton").addClass("hide-section");
        $('.productbutton[data-productuuid="' + selectedproductuuid + '"]').show();
        showCalendar(); 
    } else if ((selectedproductuuid == '') || (selectedproductuuid == undefined)) {
        $(".productbutton").show();
        showCalendar(); 
    }
    userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    $('select[name=inputDisplayTimeZone]').val(userTimezone);
    console.log('userTimezone  ' + userTimezone);
    // hideLoading();
   
    if(userTimezone){
        changeSelectedDisplayTimeZone(userTimezone);
    }   

    // hideLoading();
}

function postTimezoneChange(){
    fetchUpcomingAppointments();
}

function onclickBindEventHandlers(){
    $('.productbutton').click(function () {
        try {
            $(".productbutton").removeClass("active");
            var selectedproductuuid = this.dataset.productuuid;
            var selectedproductname = this.dataset.productname;
            $(this).addClass("active");
            $('input[name=selectedproductuuid]').val(selectedproductuuid);
            changeSelectedProductUuid(selectedproductuuid);
            // hideBookingSlots(); //Hide upcoming slot
            // hideFirstPage();
            // showCalendar();
            let startDateTime = new Date();
            // startDateTime.setHours(0, 0, 0, 0);
            let currentDate = startDateTime.toISOString();
            console.log('fetching slots',currentDate, startDateTime);
            fetchAvailableSlot(selectedproductuuid, currentDate, 90);
            showLoading();
            $(".spinner-schedule").show();
        } catch (ex) {
            console.log('Exception Occured ' + ex);
        }
    });

    $('.upcoming-appointments-tab').click(function () {
        showLoading();
        fetchUpcomingAppointments();
    });
    
    $('.custom-tab').click(function () {
        try {
            $(".custom-tab").removeClass("active");
            if($(".custom-panel").hasClass("show")){
                $(".custom-panel").removeClass("show");
            }            
            $(this).addClass("active");
            var selectedtabid = this.dataset.tabid;
            $('.custom-panel[data-tabid="' + selectedtabid + '"]').addClass("show");
        } catch (ex) {
            console.log('Exception Occured ' + ex);
        }
    });

    // $('.cancelbookingbtn').click(function () {
    //     try {
    //         $(".cancelbookingbtn").removeClass("active");
    //         var selectedappointmentuuid = this.dataset.appointmentuuid;
    //         console.log('selectedappointmentuuid ' + selectedappointmentuuid);
    //         $(this).addClass("active");
    //         //Confirm Button Styles
    //         $(".cancel-confirm").removeClass("show");
    //         $('.cancel-confirm[data-appointmentUuid="' + selectedappointmentuuid + '"]').addClass("show");
    //     } catch (ex) {
    //         console.log('Exception Occured ' + ex);
    //     }
    // });

    $('.cancel-confirm').click(function () {
        try {
            showLoading();
            var selectedappointmentuuid = this.dataset.appointmentuuid;
            console.log('selectedappointmentuuid ' + selectedappointmentuuid);
            $('input[name=selectedappointmentUuid]').val(selectedappointmentuuid);
            cancelAppointment(selectedappointmentuuid);
        } catch (ex) {
            console.log('Exception Occured ' + ex);
        }
    });

    $('.checkin-confirm').click(function () {
        try {
            showLoading();
            var selectedappointmentuuid = this.dataset.appointmentuuid;
            console.log('selectedappointmentuuid to checkin' + selectedappointmentuuid);
            $('input[name=selectedappointmentUuid]').val(selectedappointmentuuid);
            checkinAppointment(selectedappointmentuuid);
        } catch (ex) {
            console.log('Exception Occured ' + ex);
        }
    });

    $('#timezone-select').change(function () {
        try {
            var selectedTimeZone = $('#timezone-select').val();
            if(selectedTimeZone){
                // $('input[name=displayTimeZone]').val(selectedTimeZone);
                changeSelectedDisplayTimeZone(selectedTimeZone);  
            }            
        } catch (ex) {
            console.log('Exception Occured ' + ex);
        }
    });
}

function getUtmParam(param) {
    var url = new URL(window.location.href);
    var value = url.searchParams.get(param);
    return value;
}

function setUtmParam(pamam, value) {
    var url = new URL(window.location.href);
    var params = new URLSearchParams(url.search);
    params.set("utm_source", "example_source");
    url.search = params.toString();
    window.history.replaceState({}, '', url);

}



$(document).ready(function () {

    onclickBindEventHandlers();
        
    window.addEventListener("message", function (event) {
        console.log('Appoint message recived ');
        console.log(event.data);
        if (event.data.bookingconfirmation) {
            const dfMessenger = document.querySelector('df-messenger');
            document.querySelector('df-messenger').showMinChat();
            dfMessenger.renderCustomText(event.data.bookingconfirmation);
        }
    }, false);

    var productId = getUtmParam('productuuid');
    if (productId) {
        // $(".productbutton").addClass("section-hide");
        
        $('.productbutton[data-productuuid="' + productId + '"]').show();

        let startDateTime = new Date();
        // startDateTime.setHours(0, 0, 0, 0);
        let currentDate = startDateTime.toISOString();
        console.log('fetching slots',currentDate, startDateTime);
        fetchAvailableSlot(productId, currentDate, 30);
        showLoading();
        $(".spinner-schedule").show();
        // sample();
        // showCalendar();

        // initNewCalendar();
    } else {
        $('.productbutton').show();
    }

    startUp();
});

function afterSlotsFetched() {
    try {
        console.log('afterSlotsFetched called');
        let x = document.querySelector(".available-slot-value").value;
        var slotmap = $('input[name=slotMap]').val();
        console.log('after slot fetch ', (slotmap), x);
        
        let slotObj = JSON.parse(slotmap);
        slotObj = convertSlotMapToLocal(JSON.parse(slotmap));
        const entries = Object.entries(slotObj);
        const slotCount = {};
        entries.forEach(function([key, value]) {
            slotCount[key] = value.length;
        });
        initNewCalendar(slotCount);
    } catch (e) {
        console.log('error ',e);
    }
    hideLoading();
    $(".spinner-schedule").hide();
    hideFirstPage();
    
}

function fetchTimeSlotMap() {

}

function hideFirstPage() {
    $(".upcoming-event-tiles").hide();
    $(".section-container-calendar").show();
}

function hideSecondPage() {
    $(".upcoming-event-tiles").show();
    $(".section-container-calendar").hide();
}


function initNewCalendar(datemap) {
    // const datemap = {
    //     "2023-09-25" : 3,
    //     "2023-09-23" : 1,
    //     "2023-09-19" : 4,
    //     "2023-10-01" : 4,
    //     "2023-10-30" : 4,
    //     "2023-11-02" : 4,
    //     "2023-12-02" : 4
    // };

    let param = datemap ? datemap : {};
    const calendarControl = new CalendarControl(param);   
    // showAvailableSlots();
    if ($(".back-button")) {
        $(".back-button").click(function () {
            try {
                hideSecondPage();
            } catch (ex) {
                console.log('Exception Occured ' + ex);
            }
        });
    }
    if ($(".back-button-rev")) {
        $(".back-button-rev").click(function () {
            try {
                $(".calendar-section").removeClass("inactive-s-view");
                $(".available-slot-section").hide();
            } catch (ex) {
                console.log('Exception Occured ' + ex);
            }
        });
    }
    
}


function getDate(utcdate) {
    let targetTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone+'';
    const istDate = new Intl.DateTimeFormat('en-US', {
        timeZone: targetTimezone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      }).format(utcdate);
    
    let date = new Date(istDate);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Add 1 to the month since it's zero-based
    const day = String(date.getDate()).padStart(2, '0');

    // Create the formatted date string
    const formattedDate = `${year}-${month}-${day}`;
    return formattedDate;
}



function convertDatetime(formattedString) {
    const date = new Date(formattedString);

    // Get the year, month, day, hours, minutes, and seconds in UTC
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-based
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const milliseconds = String(date.getMilliseconds()).padStart(3, '0');

    // Get the UTC offset in hours and minutes
    const offsetMinutes = date.getTimezoneOffset();
    const offsetHours = String(Math.floor(Math.abs(offsetMinutes) / 60)).padStart(2, '0');
    const offsetMinutesRemainder = String(Math.abs(offsetMinutes) % 60).padStart(2, '0');
    
    const sign = offsetMinutes < 0 ? "+" : "-";
    
    // Construct the formatted datetime string
    const formattedDatetime = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${milliseconds}${sign}${offsetHours}:${offsetMinutesRemainder}`;

    //console.log(formattedDatetime);
    return formattedDatetime;
}

function convertDate(formattedString) {
    const date = new Date(formattedString);

    // Get the year, month, day, hours, minutes, and seconds in UTC
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Month is 0-based
    const day = String(date.getDate()).padStart(2, '0');
    const formattedDatetime = `${year}-${month}-${day}`;

    //console.log(formattedDatetime);
    return formattedDatetime;
}

function convertSlotMapToLocal(utcObject) {
    const targetObject = {};

    for (const utcDate in utcObject) {
    const utcDatetimeList = utcObject[utcDate];
    let newDateKey;
        for (const utcDatetimeString of utcDatetimeList) {
            const convertedDatetime = convertDatetime(utcDatetimeString);//convertTimezone(utcDatetimeString, targetTimezone);
            newDateKey = convertDate(utcDatetimeString);//convertedDatetime.slice(0, 10); // Extract yyyy-MM-dd from the converted datetime

            if (!targetObject[newDateKey]) {
            targetObject[newDateKey] = [];
            }

            targetObject[newDateKey].push(convertedDatetime);
        }
        targetObject[newDateKey]?.sort((a, b) => {
            return new Date(a) - new Date(b);
        });
    }
    return targetObject;
}

function dateClickEvent(event, dateString) {
    var slotmap = $('input[name=slotMap]').val();
    let allSlots = JSON.parse(slotmap);
    // let targetTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone+'';
    allSlots = convertSlotMapToLocal(JSON.parse(slotmap));
    let date = event.target.getAttribute("date");
    console.log('slots available today ', allSlots[date]);
    console.log(getSlotCount());
    $(".calendar-section").addClass("inactive-s-view");
    $(".available-slot-section").show();
    let slotElement = document.querySelector(".timeslots-list-available");
    slotElement.innerHTML = '';
    allSlots[date].forEach(slot => {
        let time = getTime(slot);
        let timestamp = new Date(slot);
        // let epoch = Math.floor(timestamp.getTime() / 1000)?.toString();
        let startTimeString = getDateTimeStamp(slot);
        slotElement.innerHTML += `<div role="listitem" class="mb-10 fs-16px d-flex d-flex-justify-space-between">` +
        `<div tabindex="0" data-starttime=${startTimeString} class="timeslots-btn timeslots-btn-border btn-tile-normalize timeslotbookingbtn" onclick="storeSelectedTimeSlot(event)"> ${time}  </div><div tabindex="0"`+
        `data-starttime=${startTimeString} class="timeslots-btn btn-tile-normalize booking-confirm" onclick="confirmAppointment(event)"> Confirm</div></div>`;
        
    }); 
    document.querySelector(".selecteddateweekday").textContent = dateString;
    // hideFirstPage();
    
    
}

function getTime(param) {
    let myDate = new Date(param);
    // Get the hours from the Date object
    const hours = myDate.getHours();
    const minutes = myDate.getMinutes();

    // Determine if it's AM or PM
    const meridiem = hours >= 12 ? 'PM' : 'AM';

    // Adjust hours for PM format (if needed)
    const displayHours = hours > 12 ? hours - 12 : hours;

    // Format and display the time with AM/PM
    const formattedTime = `${displayHours}:${minutes < 10 ? '0' : ''}${minutes} ${meridiem}`;

    return formattedTime;

}

function getDateTimeStamp (param) {
    let datetime = new Date(param);
    return datetime.toISOString();

}



function getSlotCount() {
    var slotmap = $('input[name=slotMap]').val();
    let slotCountMap = {};
    if (slotmap) {
        let slotObj = JSON.parse(slotmap);
        let keys = Object.keys(JSON.parse(slotmap));
        keys.forEach( key => {
            slotCountMap[key] = slotObj[key].length;
        });
    }
    return slotCountMap;
}

function formatDateToYYYYMMDD(date) {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0'); // Adding 1 to month because it's zero-based
    const day = date.getDate().toString().padStart(2, '0');
    
    return `${year}-${month}-${day}`;
}

function CalendarControl(param) {
    const calendar = new Date();

    const calendarControl = {
        localDate: new Date(),
        prevMonthLastDate: null,
        calWeekDays: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        calMonthName: [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec",
        ],
        daysInMonth: function (month, year) {
            return new Date(year, month, 0).getDate();
        },
        
        firstDay: function () {
            return new Date(calendar.getFullYear(), calendar.getMonth(), 1);
        },
        lastDay: function () {
            return new Date(calendar.getFullYear(), calendar.getMonth() + 1, 0);
        },
        firstDayNumber: function () {
            return calendarControl.firstDay().getDay() + 1;
        },
        lastDayNumber: function () {
            return calendarControl.lastDay().getDay() + 1;
        },
        getPreviousMonthLastDate: function () {
            let lastDate = new Date(
                calendar.getFullYear(),
                calendar.getMonth(),
                0
            ).getDate();
            return lastDate;
        },
        navigateToPreviousMonth: function () {
            calendar.setMonth(calendar.getMonth() - 1);
            calendarControl.attachEventsOnNextPrev();
        },
        navigateToNextMonth: function () {
            calendar.setMonth(calendar.getMonth() + 1);
            calendarControl.attachEventsOnNextPrev();
        },
        navigateToCurrentMonth: function () {
            let currentMonth = calendarControl.localDate.getMonth();
            let currentYear = calendarControl.localDate.getFullYear();
            calendar.setMonth(currentMonth);
            calendar.setYear(currentYear);
            calendarControl.attachEventsOnNextPrev();
        },
        displayYear: function () {
            let yearLabel = document.querySelector(
                ".calendar .calendar-year-label"
            );
            yearLabel.innerHTML = calendar.getFullYear();
        },
        displayMonth: function () {
            let monthLabel = document.querySelector(
                ".calendar .calendar-month-label"
            );
            monthLabel.innerHTML =
                calendarControl.calMonthName[calendar.getMonth()];
        },
        selectDate: function (e) {
            console.log(
                `${e.target.textContent} ${
                    calendarControl.calMonthName[calendar.getMonth()]
                } ${calendar.getFullYear()}`
            );
            let dateString = `${e.target.textContent} ${
                calendarControl.calMonthName[calendar.getMonth()]
            } ${calendar.getFullYear()}`;
            console.log('date ', e.target.getAttribute("date"));
            var elements = document.querySelectorAll(".calendar-today");

            elements.forEach(function (element) {
                element.classList.remove("calendar-today");
            });
            elements = document.querySelectorAll(".calendar-selected-day");
            elements.forEach(function (element) {
                element.classList.remove("calendar-selected-day");
            });
            
            // document
            //     .querySelectorAll(".number-item")
            //     [e.target.textContent - 1].classList.add("calendar-selected-day");
            e.target.parentNode.classList.add("calendar-selected-day");
            dateClickEvent(e, dateString);
        },
        plotSelectors: function () {
            document.querySelector(
                ".calendar"
            ).innerHTML += `<div class="calendar-inner calendar-exists"><div class="calendar-controls">
          <div class="calendar-prev"><a href="#"><svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><path fill="#666" d="M88.2 3.8L35.8 56.23 28 64l7.8 7.78 52.4 52.4 9.78-7.76L45.58 64l52.4-52.4z"/></svg></a></div>
          <div class="calendar-year-month">
          <div class="calendar-month-label"></div>
          <div>-</div>
          <div class="calendar-year-label"></div>
          </div>
          <div class="calendar-next"><a href="#"><svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><path fill="#666" d="M38.8 124.2l52.4-52.42L99 64l-7.77-7.78-52.4-52.4-9.8 7.77L81.44 64 29 116.42z"/></svg></a></div>
          </div>
          <div class="calendar-today-date">Today: 
            ${calendarControl.calWeekDays[calendarControl.localDate.getDay()]}, 
            ${calendarControl.localDate.getDate()}, 
            ${
                calendarControl.calMonthName[
                    calendarControl.localDate.getMonth()
                ]
            } 
            ${calendarControl.localDate.getFullYear()}
          </div>
          <div class="calendar-body"></div></div>`;
        },
        plotDayNames: function () {
            for (let i = 0; i < calendarControl.calWeekDays.length; i++) {
                document.querySelector(
                    ".calendar .calendar-body"
                ).innerHTML += `<div class="day-names">${calendarControl.calWeekDays[i]}</div>`;
            }
        },
        plotDates: function () {
            document.querySelector(".calendar .calendar-body").innerHTML = "";
            calendarControl.plotDayNames();
            calendarControl.displayMonth();
            calendarControl.displayYear();
            let count = 1;
            let prevDateCount = 0;

            calendarControl.prevMonthLastDate =
                calendarControl.getPreviousMonthLastDate();
            let prevMonthDatesArray = [];
            let calendarDays = calendarControl.daysInMonth(
                calendar.getMonth() + 1,
                calendar.getFullYear()
            );
            
            
            let currentMonth = calendar.getMonth() + 1;
            let currentYear = calendar.getFullYear();
            let paddedCurrentMonth = currentMonth.toString().padStart(2, '0');
            // dates of current month
            for (let i = 1; i < calendarDays; i++) {
                let paddedDate = count.toString().padStart(2, '0');
                // let dateInThePlot = formatDateToYYYYMMDD(new Date(currentYear + "-" + paddedCurrentMonth + "-" + paddedDate));
                let dateInThePlot = currentYear + "-" + paddedCurrentMonth + "-" + paddedDate;//formatDateToYYYYMMDD(new Date(currentYear + "-" + paddedCurrentMonth + "-" + paddedDate));
                // console.log('plotted date ',dateInThePlot,' count',count+'date ',currentYear + "-" + paddedCurrentMonth + "-" + paddedDate);
                if (i < calendarControl.firstDayNumber()) {
                    prevDateCount += 1;
                    document.querySelector(
                        ".calendar .calendar-body"
                    ).innerHTML += `<div class="prev-dates"></div>`;
                    prevMonthDatesArray.push(
                        calendarControl.prevMonthLastDate--
                    );
                } else {
                    
                    document.querySelector(
                        ".calendar .calendar-body"
                    ).innerHTML += `<div class="number-item" data-num=${count}><a class="dateNumber date-info" date=${dateInThePlot} href="#">${count++}</a></div>`;
                    
                }
            }
            //remaining dates after month dates
            
            
            for (let j = 0; j < prevDateCount + 1; j++) {
                let dateInThePlot = formatDateToYYYYMMDD(new Date(currentYear + "-" + currentMonth + "-" + count));
                document.querySelector(
                    ".calendar .calendar-body"
                ).innerHTML += `<div class="number-item" data-num=${count}><a class="dateNumber date-info" date=${dateInThePlot} href="#">${count++}</a></div>`;
            }
            
            calendarControl.highlightToday();
            calendarControl.plotPrevMonthDates(prevMonthDatesArray);
            calendarControl.plotNextMonthDates();
            calendarControl.disableUnavailableDates();
        },
        attachEvents: function () {
            let prevBtn = document.querySelector(".calendar .calendar-prev a");
            let nextBtn = document.querySelector(".calendar .calendar-next a");
            let todayDate = document.querySelector(
                ".calendar .calendar-today-date"
            );
            let dateNumber = document.querySelectorAll(".calendar .dateNumber");

            prevBtn.addEventListener(
                "click",
                calendarControl.navigateToPreviousMonth
            );
            nextBtn.addEventListener(
                "click",
                calendarControl.navigateToNextMonth
            );
            todayDate.addEventListener(
                "click",
                calendarControl.navigateToCurrentMonth
            );
            for (var i = 0; i < dateNumber.length; i++) {
                
                dateNumber[i].addEventListener(
                    "click",
                    calendarControl.selectDate,
                    false
                );
            }
        },
        highlightToday: function () {
            let currentMonth = calendarControl.localDate.getMonth() + 1;
            let changedMonth = calendar.getMonth() + 1;
            let currentYear = calendarControl.localDate.getFullYear();
            let changedYear = calendar.getFullYear();
            if (
                currentYear === changedYear &&
                currentMonth === changedMonth &&
                document.querySelectorAll(".number-item")
            ) {
                document
                    .querySelectorAll(".number-item")
                    [calendar.getDate() - 1].classList.add("calendar-today");
            }
        },
        plotPrevMonthDates: function (dates) {
            dates.reverse();
            let currentMonth = calendar.getMonth() ; //prev month
            let currentYear = calendar.getFullYear(); //selected year

            for (let i = 0; i < dates.length; i++) {
                if (document.querySelectorAll(".prev-dates")) {
                    // document.querySelectorAll(".prev-dates")[i].textContent =
                    //     dates[i];
                    let dateInThePlot = formatDateToYYYYMMDD(new Date(currentYear + "-" + currentMonth + "-" + dates[i]));
                    document.querySelectorAll(".prev-dates")[i].innerHTML = `<a class="dateNumber date-info-prev" date=${dateInThePlot} href="#">${dates[i]}</a>`;
                }
            }
        },
        plotNextMonthDates: function () {
            let childElemCount =
                document.querySelector(".calendar-body").childElementCount;
            //7 lines
            if (childElemCount > 42) {
                let diff = 49 - childElemCount;
                calendarControl.loopThroughNextDays(diff);
            }

            //6 lines
            if (childElemCount > 35 && childElemCount <= 42) {
                let diff = 42 - childElemCount;
                calendarControl.loopThroughNextDays(42 - childElemCount);
            }
        },
        loopThroughNextDays: function (count) {
            if (count > 0) {
                let currentMonth = calendar.getMonth() + 2 ; //next month
                let currentYear = calendar.getFullYear(); //selected year
                for (let i = 1; i <= count; i++) {
                    let dateInThePlot = formatDateToYYYYMMDD(new Date(currentYear + "-" + currentMonth + "-" + i));
                    document.querySelector(
                        ".calendar-body"
                    ).innerHTML += `<div class="next-dates"><a class="dateNumber date-info-next" date=${dateInThePlot} href="#">${i}</a></div>`;
                }
            }
        },
        attachEventsOnNextPrev: function () {
            calendarControl.plotDates();
            calendarControl.attachEvents();
        },
        disableUnavailableDates: function () {
            let elements = document.querySelectorAll(".date-info, .date-info-prev, .date-info-next");
            if (elements) {
                elements.forEach((element) => {
                    let date = element.getAttribute("date");
                    // console.log(element);
                    if (param && !param[date]) {
                        // console.log(date);
                        // element.classList.add("disable-date-block");
                        element.parentNode.classList.add("disable-date-block");
                    } else {
                        console.log(date);
                    }
                })
            }
        },
        init: function (param) {
            console.log(param);
            if (!document.querySelector(".calendar-exists"))
                calendarControl.plotSelectors();
            calendarControl.plotDates();
            calendarControl.attachEvents();
            
        },
    };
    
    calendarControl.init(param);
}
