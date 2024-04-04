
function hideLoading() {
    $("#spinner").hide();
}

function showLoading() {
    $("#spinner").show();
}

function onScanSuccess(decodedText, decodedResult) {
    // Handle on success condition with the decoded text or result.
    console.log(`Scan result: ${decodedText}`, decodedResult);
    if (decodedText) {
        checkin(decodedText);
        
    }
    
}

function onCompleteCheckin() {
    hideLoading();
    showAppointmentTime();
}

function checkin(decodedText = '') {
    showLoading();
    checkinAppointment(decodedText);
}

function eventHandler() {
    $('#check-in-woqrcode').click( function() {
        console.log('clicked button qrscanner::')
        checkin();
    });
}

function convertToLocal(userDateTime) {
    const parsedDate = new Date(userDateTime);

    // Format the date to the user's local time with a specific format (12-hour format)
    const options = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    hour12: true,
    timeZoneName: 'long'
    };

    const localDateString = new Intl.DateTimeFormat(undefined, options).format(parsedDate);
    return localDateString;
}

function showAppointmentTime() {
    let userDateTime = $('input[name=appointmentStartTime]').val();
    if (!userDateTime) {
        userDateTime = $('input[name=appointmentStartTimeString]').val();
    }
    console.log('datetime ',userDateTime);
    let localString = convertToLocal(userDateTime);
    $(".date-time-local").text(localString);
}

$(document).ready(function () {

    // let userDateTime = $('input[name=appointmentStartTime]').val();

    // let localString = convertToLocal(userDateTime);
    // $(".date-time-local").text(localString);

    eventHandler();
    showAppointmentTime();
   
    // var html5QrcodeScanner = new Html5QrcodeScanner(
    //     "reader-tag", { fps: 10, qrbox: 250 });
    // console.log('scanned ');
    // html5QrcodeScanner.render(onScanSuccess);
    
    // var Html5Qrcode =  new Html5Qrcode(
    //     "reader-tag", true
    // );
    const html5QrCode = new Html5Qrcode("reader-tag");
    const qrCodeSuccessCallback = (decodedText, decodedResult) => {
        /* handle success */
        if (decodedText) {
            onScanSuccess(decodedText, decodedResult);
            html5QrCode.stop().then((ignore) => {
                console.log('scaner stopped');
            }).catch((err) => {
                console.log('scaner stopped error ',err);
            });
        }
        
    };
    const config = { fps: 10, qrbox: { width: 250, height: 250 } };

    html5QrCode.start({ facingMode: "environment" }, config, qrCodeSuccessCallback);

    // html5QrCode.start({ facingMode: { exact: "environment"} }, config, qrCodeSuccessCallback);

    //NEW SCANNER CODE

    // let videoElem = $('#video-element');

    // const qrScanner = new QrScanner(
    //     videoElem,
    //     result => console.log('decoded qr code:', result),
    //     { /* your options or returnDetailedScanResult: true if you're not specifying any other options */ },
    // );

});