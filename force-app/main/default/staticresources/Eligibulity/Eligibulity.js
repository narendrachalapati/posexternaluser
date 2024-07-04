
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
function handleCompleteTodo() {
    try {
    todocomplete();
    window.location.reload();

    } catch (ex) {
      console.log('Exception ' + ex);
      console.log('Exception ' + ex.message);
    }
}
