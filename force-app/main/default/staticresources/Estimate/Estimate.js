
function hideLoading() {
    $("#spinner").hide();
}

function showLoading() {
    $("#spinner").show();
}
function CancelEstimate() {
try {
Estimatecancle();
} catch (ex) {
  console.log('Exception ' + ex);
  console.log('Exception ' + ex.message);
}
}
function handlePay() {
    try {
    paymentNavigation();
    } catch (ex) {
      console.log('Exception ' + ex);
      console.log('Exception ' + ex.message);
    }
}