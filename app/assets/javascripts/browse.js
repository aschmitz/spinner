let latestTimeout;

$(document).ready(() => {
  $('form[data-remote]').on('ajax:success', function(event, data){
    $('#toast').toggleClass('success').text("Queued!");
    clearTimeout(latestTimeout);
    latestTimeout = setTimeout(() => {
      $("#toast").addClass('hidden');
    }, 750);
  });
  $('form[data-remote]').on('ajax:error', function(event, data){
    $('#toast').toggleClass('error').text("Failed");
    clearTimeout(latestTimeout);
    latestTimeout = setTimeout(() => {
      $("#toast").addClass('hidden');
    }, 750);
  });
  $('form[data-remote]').on('ajax:send', function(event, data){
    $('#toast').removeClass('hidden success error').text("Queuing...");
    clearTimeout(latestTimeout);
  });
});

